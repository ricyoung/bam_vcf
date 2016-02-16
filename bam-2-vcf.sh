#!/bin/bash

echo start job


date


declare -a fileName=( 

'index38_CTAGCT_L006_R1_001-bwa-sorted.bam'


		 );


   export GATK_DATA_DIR="/data-ric/done"

for FILEVAR in ${fileName[@]}
do
    # get name of the file being read
    prefix=${FILEVAR:0:7}
    export GATK_TEMP_DIR="/data-ric/temp/${prefix}"
    export GATK_RESULT_DIR="$GATK_DATA_DIR/${prefix}"
    echo "Data Directory: " $GATK_DATA_DIR
    echo "Temporary Directory: " $GATK_TEMP_DIR
    echo "Result Directory: " $GATK_RESULT_DIR

  #  rm -rf $GATK_TEMP_DIR
  #  mkdir $GATK_TEMP_DIR
    date
    echo "copying $FILEVAR to ram disk"
  #  cp $GATK_DATA_DIR/$FILEVAR $GATK_TEMP_DIR/$FILEVAR
  #  cp /storage/schillerlab/REFERENCES/g1k-human_v37/human_g1k_v37.* $GATK_TEMP_DIR

    echo "Sorting $FILEVAR"
    /usr/bin/time java -XX:ParallelGCThreads=1 -Xmx20g \
        -Djava.io.tmpdir=$GATK_TEMP_DIR \
        -jar SortSam.jar \
        INPUT=$GATK_TEMP_DIR/$FILEVAR \
   OUTPUT=$GATK_TEMP_DIR/$prefix.bam \
        SORT_ORDER=coordinate VALIDATION_STRINGENCY=LENIENT \
        TMP_DIR=$GATK_TEMP_DIR

    echo "Marking duplicates $FILEVAR"
    /usr/bin/time java -XX:ParallelGCThreads=1 -Xmx20g \
        -jar MarkDuplicates.jar \
        INPUT=$GATK_TEMP_DIR/$prefix.bam \
        OUTPUT=$GATK_TEMP_DIR/dedup$prefix.bam \
        METRICS_FILE=metrics.txt VALIDATION_STRINGENCY=LENIENT

    echo "Add Or Replace Groups $FILEVAR"
    /usr/bin/time java -XX:ParallelGCThreads=1 -Xmx20g \
        -jar AddOrReplaceReadGroups.jar \
        INPUT=$GATK_TEMP_DIR/dedup$prefix.bam \
        OUTPUT=$GATK_TEMP_DIR/addrg$prefix.bam \
        RGID=group$prefix RGLB=lib$prefix RGPL=illumina \
        RGPU=unit$prefix RGSM=$prefix VALIDATION_STRINGENCY=LENIENT

# So far the dirtory is working.. I have a folder with the files in it.



   echo "Build Bam Index $FILEVAR"
   /usr/bin/time java -XX:ParallelGCThreads=1 -Xmx20g \


       -jar BuildBamIndex.jar \
#added by ric for debuging     
       MODE=Mode\
#end       
       INPUT=$GATK_TEMP_DIR/addrg$prefix.bam \
      echo "FUCK ME HERE --- $GATK_TEMP_DIR/addrg$prefix.bam"

#add for output
#	OUTPUT=$GATK_TEMP_DIR/indexed-$prefix.bai \
#end

       VALIDATION_STRINGENCY=LENIENT


    echo "Variant Discovery $FILEVAR"
      /usr/bin/time java -XX:ParallelGCThreads=1 -Xmx20g \
                -Djava.io.tmpdir=$GATK_TEMP_DIR \
                -jar GenomeAnalysisTK.jar \
                -T UnifiedGenotyper \
                -R /data-ric/g1k-human_v37/human_g1k_v37.fasta \
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
