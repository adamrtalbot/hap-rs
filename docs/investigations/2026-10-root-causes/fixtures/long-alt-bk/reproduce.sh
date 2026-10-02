#!/usr/bin/env bash
set -euo pipefail
# Run from this directory. Supply absolute path to hap from native pin58da323.
NATIVE_HAP=${1:-hap}
REFERENCE_IMAGE=community.wave.seqera.io/library/happy-0.3.15@sha256:1a9cbcff999927913de87c3f7533c18622d08362e2f2accff336a49aa18d8c7b
mkdir -p run
for case in long 511 512 513; do
    case_input=query.vcf
    if [ "$case" != long ]; then case_input="control-$case-query.vcf"; fi
    "$NATIVE_HAP" germline truth.vcf "$case_input" -r ref.fa -f conf.bed -o "run/native-$case" --threads 1 --no-roc --output-vtc --preserve-info >"run/native-$case.log" 2>&1
    docker run --rm --platform linux/amd64 --mount "type=bind,src=$PWD,dst=/work" "$REFERENCE_IMAGE" hap.py /work/truth.vcf "/work/$case_input" -r /work/ref.fa -f /work/conf.bed -o "/work/run/reference-$case" --threads 1 --no-roc --output-vtc --preserve-info >"run/reference-$case.log" 2>&1
done
python3 - <<'PY'
import gzip
for case in ['long','511','512','513']:
    for arm in ['reference','native']:
        records=[l.rstrip().split('\t') for l in gzip.open('run/'+arm+'-'+case+'.vcf.gz','rt') if not l.startswith('#')]
        row=records[-1]
        print(case,arm,'ALT_lengths='+','.join(str(len(a)) for a in row[4].split(',')),row[-1],row[7])
PY
