#!/bin/bash

# Assign the input arguments to variables
sample=$1
ref=$2

# Clean up
samtools sort -O bam -o data/sorted/${sample}.bam data/bam/${sample}.bam
samtools fixmate -O bam data/sorted/${sample}.bam data/fixed/${sample}.bam

gatk RealignerTargetCreator -R data/ref/${ref} -I data/sorted/${sample}.sorted.bam -o data/realigned/${sample}.intervals --known data/ref/1000-genomes_vcf_ALL.wgs.integrated_phase1_v3.20101123.snps_indels_sv.sites.vcf
gatk IndelRealigner -R data/ref/${ref} -I data/sorted/${sample}.sorted.bam -targetIntervals data/realigned/${sample}.intervals --known data/ref/resources_broad_hg38_v0_Mills_and_1000G_gold_standard.indels.hg38.vcf.vcf -o ./data/realigned/${sample}.realigned.bam

gatk BaseRecalibrator -R data/ref/${ref} -I data/realigned/${sample}.realigned.bam -knownSites data/ref/resources_broad_hg38_v0_Homo_sapiens_assembly38.dbsnp138.vcf -o data/recal/${sample}.recal_data.table
gatk PrintReads -R data/ref/${ref} -I data/realigned/${sample}.realigned.bam -BQSR data/recal/${sample}.recal_data.table -o data/recal/${sample}.recal.bam

gatk MarkDuplicates INPUT=./data/recal/${sample}.recal.bam OUTPUT=data/dedup/${sample}.dedup.bam METRICS_FILE=data/dedup/${sample}.metrics REMOVE_DUPLICATES=true ASSUME_SORTED=true

samtools merge -r data/merged/${sample}.merged.bam ./data/dedup/${sample}.dedup.bam
samtools index data/merged/${sample}.merged.bam

# Basic Coverage
gatk DepthOfCoverage -R data/ref/${ref} -I data/merged/${sample}.merged.bam -o data/coverage/${sample}_depth_gatk.txt
samtools depth -a data/merged/${sample}.merged.bam > data/coverage/${sample}_depth_samtools.txt
bedtools coverage -hist -abam data/merged/${sample}.merged.bam | grep ^all > data/coverage/${sample}_depth_bedtools.txt

# Regions that lack coverage
bedtools genomecov -ibam data/merged/${sample}.merged.bam -bga | awk '$4 == 0' | bedtools intersect -b stdin > data/coverage/${sample}_no_coverage.bed

# Visualization of coverage
python3 coverage.py -dir data/coverage/ -sample ${sample}
