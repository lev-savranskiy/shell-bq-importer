#!/bin/bash
FOLDER="/mnt/bqfiles"
FOLDERLOGS="/home/ubuntu/logs2"
TO_ADDRESS="admin@example.com"
BQTABLE=${1}
LIMIT=${2}
FROM_ADDRESS="sender"
SUBJECT1="BQ Import started"
SUBJECT2="BQ Import finished"
BODY="BQ Import started. URL https://bigquery.cloud.google.com/table/eminent-torch-384:my_dataset.${BQTABLE}?tab=details"
TS=`date "+%Y-%m-%d-%H:%M"`
#######################################

if [ "$#" -ne 2 ]
then
  echo "2 parameters  expected [mastertable] [limit]"
  exit 1
fi
if [ ${BQTABLE} = "master_table" ]; then
  echo "You cant use name 'master_table'"
  exit 1
fi

logpath="${FOLDERLOGS}/create-${TS}-${BQTABLE}.log"

echo "Creating table ${BQTABLE}..."

bq mk --table --description master_table_from_CLI eminent-torch-384:my_dataset.${BQTABLE} /home/ubuntu/schemes/schema_exported_fixed.json >> ${logpath}

echo ${SUBJECT1}

FILENAMES=`ls $FOLDER`

i=0; while [ $i -lt $LIMIT ]; do
    START=`expr $i \* $LIMIT`
    END=`expr $START + $LIMIT - 1`
    echo $START "-" $END;
    cmd=`sudo bash /home/ubuntu/bqimportrange.sh ${BQTABLE} ${START} ${END}`
    #bq has limit of 50 load at once
    #sleep to let files proceed
    sleep 10
    echo '--------';
    i=$(($i + 1))
done


echo ${SUBJECT2}
echo ${BODY}| mail -s ${SUBJECT2} ${TO_ADDRESS} -- -r ${FROM_ADDRESS}

