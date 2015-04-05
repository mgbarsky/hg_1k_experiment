#!/bin/bash

for i in {1..22}
do
	perl snipstocontext.pl --vcf /FOLDER_NAME/ALL.chr${i}_SELECTED_30.csv --ref /FOLDER_NAME/hs37d5.fa --context 141 --jump 350 outputdir /FOLDER_NAME/streamcount_paper/g1k/variants/output/context
done

