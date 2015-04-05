#!/bin/bash

qsub -cwd -b y -l h_vmem=8g -o $HOME/$clusterOutputDir/ -e $HOME/$clusterOutputDir/ perl extract_quality_snips.pl --vcf ALL.chr12.phase1_release_v3.20101123.snps_indels_svs.genotypes.vcf -t 5 --outputdir output
qsub -cwd -b y -l h_vmem=8g -o $HOME/$clusterOutputDir/ -e $HOME/$clusterOutputDir/ perl extract_quality_snips.pl --vcf ALL.chr2.phase1_release_v3.20101123.snps_indels_svs.genotypes.vcf -t 5 --outputdir output
qsub -cwd -b y -l h_vmem=8g -o $HOME/$clusterOutputDir/ -e $HOME/$clusterOutputDir/ perl extract_quality_snips.pl --vcf ALL.chr3.phase1_release_v3.20101123.snps_indels_svs.genotypes.vcf -t 5 --outputdir output
qsub -cwd -b y -l h_vmem=8g -o $HOME/$clusterOutputDir/ -e $HOME/$clusterOutputDir/ perl extract_quality_snips.pl --vcf ALL.chr4.phase1_release_v3.20101123.snps_indels_svs.genotypes.vcf -t 5 --outputdir output
qsub -cwd -b y -l h_vmem=8g -o $HOME/$clusterOutputDir/ -e $HOME/$clusterOutputDir/ perl extract_quality_snips.pl --vcf ALL.chr13.phase1_release_v3.20101123.snps_indels_svs.genotypes.vcf -t 5 --outputdir output
qsub -cwd -b y -l h_vmem=8g -o $HOME/$clusterOutputDir/ -e $HOME/$clusterOutputDir/ perl extract_quality_snips.pl --vcf ALL.chr5.phase1_release_v3.20101123.snps_indels_svs.genotypes.vcf -t 5 --outputdir output
qsub -cwd -b y -l h_vmem=8g -o $HOME/$clusterOutputDir/ -e $HOME/$clusterOutputDir/ perl extract_quality_snips.pl --vcf ALL.chr14.phase1_release_v3.20101123.snps_indels_svs.genotypes.vcf -t 5 --outputdir output
qsub -cwd -b y -l h_vmem=8g -o $HOME/$clusterOutputDir/ -e $HOME/$clusterOutputDir/ perl extract_quality_snips.pl --vcf ALL.chr15.phase1_release_v3.20101123.snps_indels_svs.genotypes.vcf -t 5 --outputdir output
qsub -cwd -b y -l h_vmem=8g -o $HOME/$clusterOutputDir/ -e $HOME/$clusterOutputDir/ perl extract_quality_snips.pl --vcf ALL.chr7.phase1_release_v3.20101123.snps_indels_svs.genotypes.vcf -t 5 --outputdir output
qsub -cwd -b y -l h_vmem=8g -o $HOME/$clusterOutputDir/ -e $HOME/$clusterOutputDir/ perl extract_quality_snips.pl --vcf ALL.chr16.phase1_release_v3.20101123.snps_indels_svs.genotypes.vcf -t 5 --outputdir output
qsub -cwd -b y -l h_vmem=8g -o $HOME/$clusterOutputDir/ -e $HOME/$clusterOutputDir/ perl extract_quality_snips.pl --vcf ALL.chr8.phase1_release_v3.20101123.snps_indels_svs.genotypes.vcf -t 5 --outputdir output
qsub -cwd -b y -l h_vmem=8g -o $HOME/$clusterOutputDir/ -e $HOME/$clusterOutputDir/ perl extract_quality_snips.pl --vcf ALL.chr17.phase1_release_v3.20101123.snps_indels_svs.genotypes.vcf -t 5 --outputdir output
qsub -cwd -b y -l h_vmem=8g -o $HOME/$clusterOutputDir/ -e $HOME/$clusterOutputDir/ perl extract_quality_snips.pl --vcf ALL.chr9.phase1_release_v3.20101123.snps_indels_svs.genotypes.vcf -t 5 --outputdir output
qsub -cwd -b y -l h_vmem=8g -o $HOME/$clusterOutputDir/ -e $HOME/$clusterOutputDir/ perl extract_quality_snips.pl --vcf ALL.chr18.phase1_release_v3.20101123.snps_indels_svs.genotypes.vcf -t 5 --outputdir output
qsub -cwd -b y -l h_vmem=8g -o $HOME/$clusterOutputDir/ -e $HOME/$clusterOutputDir/ perl extract_quality_snips.pl --vcf ALL.chr19.phase1_release_v3.20101123.snps_indels_svs.genotypes.vcf -t 5 --outputdir output
qsub -cwd -b y -l h_vmem=8g -o $HOME/$clusterOutputDir/ -e $HOME/$clusterOutputDir/ perl extract_quality_snips.pl --vcf ALL.chr1.phase1_release_v3.20101123.snps_indels_svs.genotypes.vcf -t 5 --outputdir output
qsub -cwd -b y -l h_vmem=8g -o $HOME/$clusterOutputDir/ -e $HOME/$clusterOutputDir/ perl extract_quality_snips.pl --vcf ALL.chr20.phase1_release_v3.20101123.snps_indels_svs.genotypes.vcf -t 5 --outputdir output
qsub -cwd -b y -l h_vmem=8g -o $HOME/$clusterOutputDir/ -e $HOME/$clusterOutputDir/ perl extract_quality_snips.pl --vcf ALL.chr21.phase1_release_v3.20101123.snps_indels_svs.genotypes.vcf -t 5 --outputdir output
qsub -cwd -b y -l h_vmem=8g -o $HOME/$clusterOutputDir/ -e $HOME/$clusterOutputDir/ perl extract_quality_snips.pl --vcf ALL.chr22.phase1_release_v3.20101123.snps_indels_svs.genotypes.vcf -t 5 --outputdir output
qsub -cwd -b y -l h_vmem=8g -o $HOME/$clusterOutputDir/ -e $HOME/$clusterOutputDir/ perl extract_quality_snips.pl --vcf ALL.chr6.phase1_release_v3.20101123.snps_indels_svs.genotypes.vcf -t 5 --outputdir output





