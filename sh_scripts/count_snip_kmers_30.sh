#!/bin/bash
snipKmersFile="/FOLDER_NAME/snippairs31_ref.txt"
fileNamesFile="/FOLDER_NAME/FILE_NAMES_30.txt"


#2. Count snip pairs k-mers in input files
while read line;
do
if [ "$line" = "" ] ; then
    echo "empty line.";
else
        INPUTDIR="/FOLDER_NAME/reads/ftp.1000genomes.ebi.ac.uk/vol1/ftp/data/${line}/sequence_read"
        OUTPUTDIR="/FOLDER_NAME/streamcount_paper/g1k/variants/output/snipcounts/SNIP_COUNTS31_${line}.txt"
     qsub -cwd -b y -l h_vmem=8g ./count_one_dir.sh $snipKmersFile $INPUTDIR $OUTPUTDIR
fi
done < $fileNamesFile





