#!/bin/bash

#PBS -l select=8:ncpus=16:mpiprocs=8:nmics=0
#PBS -l walltime=12:00:0
#PBS -j oe
#PBS -m bea
#PBS -N simple-test
#PBS -M ryoung@unlv.edu
 

echo "Sorting"
java -Xmx4g -jar /storage/nipm/APPS/picard/dist/picard.jar SortSam \
	INPUT=/storage/nipm/1KG-RIC/RAW/HG01971.mapped.ILLUMINA.bwa.PEL.exome.20120522.bam  \
	OUTPUT=/storage/nipm/ric/temp/sorted_HG0001971.bam SORT_ORDER=coordinate VALIDATION_STRINGENCY=LENIENT

echo "Marking duplicates"
java -Xmx4g -jar /storage/nipm/APPS/picard/dist/picard.jar MarkDuplicates \
	INPUT=/storage/nipm/ric/temp/sorted_HG0001971.bam  \
	OUTPUT=/storage/nipm/ric/temp/dedup_HG0001971.bam \
	METRICS_FILE=metrics.txt VALIDATION_STRINGENCY=LENIENT

echo "Add Or Replace Groups"
java -Xmx4g -jar /storage/nipm/APPS/picard/dist/picard.jar  AddOrReplaceReadGroups \
	INPUT=/storage/nipm/ric/temp/dedup_HG0001971.bam \
	OUTPUT=/storage/nipm/ric/temp/addrg_HG0001971.bam \
	RGID=group1 RGLB=lib1 RGPL=illumina RGPU=unit1 RGSM=HG00097 VALIDATION_STRINGENCY=LENIENT

echo "Build Bam Index"
java -Xmx4g -jar -jar /storage/nipm/APPS/picard/dist/picard.jar BuildBamIndex  \
	INPUT=/storage/nipm/ric/temp/addrg_HG0001971.bam  \
	VALIDATION_STRINGENCY=LENIENT 

echo "Variant Discovery"
java -jar /storage/nipm/APPS/GATK/GenomeAnalysisTK.jar -T UnifiedGenotyper -R /storage/nipm/REFERENCES/G1k-v37/human_g1k_v37.fasta  -I /storage/nipm/ric/temp/addrg_HG0001971.bam -o /storage/nipm/ric/bam-vcf-pipeline/varHG0001971.vcf
  
echo "done"