#!/bin/bash

for i in 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22
do
   perl extract_quality_snips_from30.pl --vcf ALL.chr${i}.phase1_release_v3.20101123.snps_indels_svs.genotypes.vcf_QUALITY_SNIPS.csv --t 3 --samples ALL.chr${i}.phase1_release_v3.20101123.snps_indels_svs.genotypes.vcf_SAMPLE_KEYS.csv --selection FILE_LABELS_30.csv --skip 25
done





