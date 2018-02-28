#!/bin/sh
FOLDER="/mnt/bqfiles"
FOLDERLOGS="/home/ubuntu/logs2"
BQTABLE=${1}
START=${2}
END=${3}
TS=`date "+%Y-%m-%d-%H:%M"`

#######################################
if [ ${BQTABLE} = "master_table" ]; then
  echo "You cant use name 'master_table'"
  exit 1
fi

for FILE in ${FOLDER}/*.csv
do
    parts=(${FILE//-/ })
    ID=$((10#${parts[1]} + 0))
    if [ "$ID" -ge "$START" -a "$ID" -le "$END" ];
        then
        echo "$FILE" >> ${logpath}
        bq load -F "|" --noreplace --source_format=CSV --skip_leading_rows=1 --max_bad_records=100000 my_dataset.${BQTABLE} ${FILE} &
    fi
done
