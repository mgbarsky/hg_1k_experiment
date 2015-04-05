#!/bin/bash
FILETOTAL="${1}"

if [ -f $FILETOTAL ]; then
    rm $FILETOTAL
fi

for i in 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22
do 
    FILENAME="/.FOLDER_NAME/ALL.chr${i}_SELECTED_30.csv_SNP_CONTEXT_LINES.txt"
    echo "Concatenating lines from file $FILENAME"
    cat $FILENAME >> $FILETOTAL
done 
