#!/bin/bash

#PBS -l select=8:ncpus=16:mpiprocs=8:nmics=0
#PBS -l walltime=12:00:0
#PBS -j oe
#PBS -m bea
#PBS -N bam-2-vcf-test
#PBS -M ryoung@unlv.edu

echo start job - test



echo start job - test


date


declare -a fileName=( 

'HG00155.mapped.ILLUMINA.bwa.GBR.exome.20121211.bam'


		 );


   export GATK_DATA_DIR="/storage/nipm/1KG-RIC/RAW/"

for FILEVAR in ${fileName[@]}
do
    # get name of the file being read
    prefix=${FILEVAR:0:7}
    export GATK_TEMP_DIR="/storage/nipm/ric/temp/${prefix}"
    export GATK_RESULT_DIR="$GATK_DATA_DIR/${prefix}"
    echo "Data Directory: " $GATK_DATA_DIR
    echo "Temporary Directory: " $GATK_TEMP_DIR
    echo "Result Directory: " $GATK_RESULT_DIR

echo -ne '\n' 

    rm -rf $GATK_TEMP_DIR
    mkdir $GATK_TEMP_DIR
    date
    echo "copying $FILEVAR to ram disk or working location"
  cp $GATK_DATA_DIR/$FILEVAR $GATK_TEMP_DIR/$FILEVAR 
  # cp /#torage/schillerlab/REFERENCES/g1k-human_v37/human_g1k_v37.* $GATK_TEMP_DIR

#( turned off for testing)
#echo -ne '\n' | sorting sam

    echo "Sorting $FILEVAR"
    /usr/bin/time java -XX:ParallelGCThreads=1 -Xmx20g \
        -Djava.io.tmpdir=$GATK_TEMP_DIR \
        -jar /storage/nipm/APPS/picard/dist/picard.jar SortSam  \
        INPUT=$GATK_TEMP_DIR/$FILEVAR \
   OUTPUT=$GATK_TEMP_DIR/$prefix.bam \
        SORT_ORDER=coordinate VALIDATION_STRINGENCY=LENIENT \
        TMP_DIR=$GATK_TEMP_DIR

#( turned off for testing)
#echo -ne '\n' | Mark Dups

    echo "Marking duplicates $FILEVAR"
    /usr/bin/time java -XX:ParallelGCThreads=1 -Xmx20g \
        -jar /storage/nipm/APPS/picard/dist/picard.jar MarkDuplicates \
        INPUT=$GATK_TEMP_DIR/$prefix.bam \
        OUTPUT=$GATK_TEMP_DIR/dedup$prefix.bam \
        METRICS_FILE=metrics.txt VALIDATION_STRINGENCY=LENIENT

    echo "Add Or Replace Groups $FILEVAR"
    /usr/bin/time java -XX:ParallelGCThreads=1 -Xmx20g \
        -jar /storage/nipm/APPS/picard/dist/picard.jar AddOrReplaceReadGroups \
        INPUT=$GATK_TEMP_DIR/dedup$prefix.bam \
        OUTPUT=$GATK_TEMP_DIR/addrg$prefix.bam \
        RGID=group$prefix RGLB=lib$prefix RGPL=illumina \
        RGPU=unit$prefix RGSM=$prefix VALIDATION_STRINGENCY=LENIENT

# So far the dirtory is working.. I have a folder with the files in it.



   echo "Build Bam Index $FILEVAR"
   /usr/bin/time java -XX:ParallelGCThreads=1 -Xmx20g \


       -jar /storage/nipm/APPS/picard/dist/picard.jar BuildBamIndex \
#added by ric for debuging     
 #      MODE=Mode\
#end       
       INPUT=$GATK_TEMP_DIR/addrg$prefix.bam \
 #     echo "$GATK_TEMP_DIR/addrg$prefix.bam"

#add for output
	OUTPUT=$GATK_TEMP_DIR/indexed-$prefix.bai \
#end

       VALIDATION_STRINGENCY=LENIENT


    echo "Variant Discovery $FILEVAR"
      /usr/bin/time java -XX:ParallelGCThreads=1 -Xmx20g \
                -Djava.io.tmpdir=$GATK_TEMP_DIR \
                -jar /storage/nipm/APPS/GATK/GenomeAnalysisTK.jar \
                -T UnifiedGenotyper \
                -R /storage/nipm/REFERENCES/g1k-human_v37/human_g1k_v37.fasta \
                -nct 4 -nt 8 \
                -I $GATK_TEMP_DIR/indexed-$prefix.bai \
                -o $GATK_TEMP_DIR/var$prefix.vcf
#
#
      echo "Finalized $FILEVAR"
#
        echo "Cleaning Desktop"
#       rm -rf $GATK_RESULT_DIR
#        mkdir $GATK_RESULT_DIR
#        /usr/bin/time mv $GATK_TEMP_DIR/* $GATK_RESULT_DIR

        echo "Done!"
        date
done

date
        echo "The script has finished."
