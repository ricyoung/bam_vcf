#!/bin/bash

#PBS -l select=8:ncpus=16:mpiprocs=8:nmics=0
#PBS -l walltime=12:00:0
#PBS -j oe
#PBS -m bea
#PBS -N simple-2
#PBS -M ryoung@unlv.edu
 

echo "Sorting"
java -Xmx4g -jar /storage/nipm/APPS/picard/dist/picard.jar SortSam \
	INPUT=/storage/nipm/1KG-RIC/RAW/HG01971.mapped.ILLUMINA.bwa.PEL.exome.20120522.bam  \
	OUTPUT=/storage/nipm/ric/temp/sorted_HG0001971.bam SORT_ORDER=coordinate VALIDATION_STRINGENCY=LENIENT


echo "done"