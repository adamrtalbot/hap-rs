Related: #88. Implementation belongs in `adamrtalbot/variantbenchmarking`; its issue tracker is disabled, so this ticket is recorded here.

## Problem and confirmed cause

The pinned pipeline's VCF-to-CSV conversion retains every input record and its parsed INFO dictionary until EOF, then writes the CSV. The optional column discovery therefore makes peak memory proportional to the total number of records, even though the output can be produced with two bounded-memory passes. This is a confirmed source and measured scaling defect.

The two eight-caller conversions reported in #88 were killed with exit 137. This investigation establishes the converter's unbounded retention, **not** the executor's reason for those specific kills. Preserve that distinction: retrieve the task resource limit and executor termination reason before calling the historical failures confirmed OOMs.

## Immutable implementation references

Pipeline revision: `7ebe8f6bd4c170799949dfb38a15949cc1934198`.

- [`bin/vcf_to_csv.py`](https://github.com/adamrtalbot/variantbenchmarking/blob/7ebe8f6bd4c170799949dfb38a15949cc1934198/bin/vcf_to_csv.py): `records = []`, followed by `records.append((row, info_dict))` in the read loop, followed by a second loop over `records` to write. The only whole-file discovery state actually needed is five booleans for SUPP_VEC, SUPP, type_inferred, SVTYPE, and SVLEN, plus the VCF header.
- [`VCF_TO_CSV/main.nf`](https://github.com/adamrtalbot/variantbenchmarking/blob/7ebe8f6bd4c170799949dfb38a15949cc1934198/modules/local/custom/vcf_to_csv/main.nf): runs this converter, uses `process_single`, and publishes CSV files.
- [`conf/base.config`](https://github.com/adamrtalbot/variantbenchmarking/blob/7ebe8f6bd4c170799949dfb38a15949cc1934198/conf/base.config): `process_single` defaults to `6.GB * task.attempt`; exit 137 is retried once by default, with other failures finishing the workflow. This does not establish the effective configuration of the historical remote tasks.
- [`conf/modules.config`](https://github.com/adamrtalbot/variantbenchmarking/blob/7ebe8f6bd4c170799949dfb38a15949cc1934198/conf/modules.config): VCF_TO_CSV overrides prefix and publication only. The checked-in defaults do not explain why the run in #88 was marked SUCCEEDED.

## Measured evidence

Executed the **unmodified pinned converter**, CPython 3.12, Linux, in a separate process for each input size. The input was a clearly synthetic scaling diagnostic: eight GT sample columns, repeated `A>C` records, and `SUPP_VEC=11111111;SUPP=8`. It was not the real truth set or a replay of #88. Each conversion exited 0 and preserved all duplicate rows.

| Records | Input bytes | Peak RSS (KiB) | CSV data rows |
|---:|---:|---:|---:|
| 10,000 | 830,139 | 23,296 | 10,000 |
| 100,000 | 8,300,139 | 144,128 | 100,000 |
| 200,000 | 16,600,139 | 278,272 | 200,000 |

An extra 100,000 records adds about 131 MiB of retained process memory in this controlled case. Absolute RSS can vary by Python build and record content; the source-level retention and proportional growth are the finding. Do not extrapolate this to claim the historical tasks crossed an observed limit.

## Reproduction from a fresh session

Use the pipeline checkout at the exact revision above; this needs only Python's standard library. Run in a scratch directory:

```python
from pathlib import Path
import csv, json, subprocess, sys

converter = str(Path('/path/to/variantbenchmarking/bin/vcf_to_csv.py').resolve())
wrapper = ('import sys,runpy,resource,json;sys.argv=sys.argv[1:];'
           'runpy.run_path(sys.argv[0],run_name="__main__");'
           'print(json.dumps({"peak_rss_kib":'
           'resource.getrusage(resource.RUSAGE_SELF).ru_maxrss}),file=sys.stderr)')
for n in (10000, 100000, 200000):
    vcf, output = Path(f'scale-{n}.vcf'), Path(f'scale-{n}.csv')
    header = ('##fileformat=VCFv4.2\n'
              '#CHROM\tPOS\tID\tREF\tALT\tQUAL\tFILTER\tINFO\tFORMAT\t'
              + '\t'.join(f'caller_{i}' for i in range(8)) + '\n')
    row = ('chr1\t100\t.\tA\tC\t50\tPASS\tSUPP_VEC=11111111;SUPP=8\tGT\t'
           + '\t'.join(['0/1'] * 8) + '\n')
    with vcf.open('w') as stream:
        stream.write(header)
        for _ in range(n):
            stream.write(row)
    run = subprocess.run([sys.executable, '-c', wrapper, converter,
                          str(vcf), str(output)], capture_output=True, text=True)
    run.check_returncode()
    with output.open(newline='') as stream:
        rows = sum(1 for _ in csv.reader(stream)) - 1
    print(n, vcf.stat().st_size, run.stderr.strip(), rows)
```

`ru_maxrss` is in KiB on Linux. For final production validation, reuse the already-produced `happy.TP_base.vcf` and `happy.TP_comp.vcf` from #88; do not rerun scientific benchmark arms just to test report conversion.

## Causal change

Preserve the converter's existing output contract. Discover the optional columns in a first streaming pass, reopen the VCF, and write one CSV record at a time in a second pass. Retain only bounded per-record state. Temporary disk spooling is an alternative only if non-seekable inputs are deliberately supported. Increasing memory alone leaves the demonstrated scaling defect intact.

Do not change hap-rs scientific algorithms or process.maxForks for this issue.

## Acceptance

- Output is byte-identical to the pinned converter for representative inputs, including an optional INFO field appearing only in the last record, absent optional fields, multiple samples, missing GT, and repeated identical records. Preserve optional column ordering and duplicate multiplicity.
- Peak RSS stays bounded as record count grows; retain the same scaling diagnostic before and after the change.
- Both original large conversions complete with their full expected CSV row counts under the recorded production limits; capture elapsed time and peak RSS.
- Record the executor's kill reason and effective limits for the two original failed tasks. Do not call those kills OOM based on exit 137 alone.
- For the remaining workflow-completeness part of #88, inspect its effective configuration and logs: the pinned defaults retry/finish, so an assertion that checked-in `errorStrategy='ignore'` caused success would be unsupported. Keep #88 open until that separate question is resolved.
