#!/bin/sh
FOLDER=${1}
FOLDERLOGS="/home/ubuntu/logs"
TO_ADDRESS="lev.savranskiy@example.com"
FROM_ADDRESS="sender"
TS=`date "+%Y-%m-%d-%H:%M"`
SUBJECT1="BQ Import started ${TS}"
FILE=${2}
DATASET=${3}
SCHEMA=${4}

if [ "$#" -ne 4 ]
then
  echo "Parameters expected: [FOLDER] [NAME] [DATASET] [SCHEMA]"
  exit 1
fi
#######################################
logpath="${FOLDERLOGS}/import-${FILE}.log"
echo 'started ' >> ${logpath}
date "+%m-%d-%Y %H:%M:%S" >> ${logpath}

#table name cant contain - and .
TABLE_NAME=${FILE//[-.]/_}

#if [ ${DATASET} = "test" ]
#then
#TABLE_NAME=${TABLE_NAME//[.csv]/}
#fi


echo "${DATASET}.${TABLE_NAME}"

bq mk --table --description table_from_CLI eminent-torch-384:${DATASET}.${TABLE_NAME} ${SCHEMA} >> ${logpath}


if [ ${DATASET} = "test" ]
then
    #master is pipe delimited, with header
    bq load -F "|" --replace --source_format=CSV --max_bad_records=100000 --skip_leading_rows=1 ${DATASET}.${TABLE_NAME} ${FOLDER}/${FILE} &
else
    #email and postal are comma delimited, no header
    bq load --replace --max_bad_records=100000 ${DATASET}.${TABLE_NAME} ${FOLDER}/${FILE} &
fi


echo 'done ' >> ${logpath}
date "+%m-%d-%Y %H:%M:%S" >> ${logpath}
