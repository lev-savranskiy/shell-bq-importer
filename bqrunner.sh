#!/bin/sh
FOLDER=${1}
DATASET=${2}
SCHEMA=${3}
OFFSET=${4}
FOLDERLOGS="/home/ubuntu/logs"
TO_ADDRESS="lev.savranskiy@example.com"
FROM_ADDRESS="sender"
TS=`date "+%Y-%m-%d-%H:%M"`
SUBJECT1="BQ Import started ${TS}"
BQ_PROC_CNT=0
LIMIT=50
TIMEOUT=30

if [ "$#" -ne 4 ]
then
  echo "Parameters expected: [FOLDER] [DATASET] [SCHEMA] [OFFSET]"
  exit 1
fi

## create array woth filenames
#cd ${FOLDER}
declare -a FILENAMES=( "${FOLDER}"/* )
LENGTH=${#FILENAMES[@]}

#echo "LENGTH ${LENGTH}"
#exit
#######################################

rm -rf ${FOLDERLOGS}/*.log
echo "Folder ${FOLDERLOGS} cleared"
echo ${SUBJECT1}
i=0;
while [ $i -lt $LENGTH ]
do
    date "+%m-%d-%Y %H:%M:%S"
    echo "i: ${i} "
    BQ_PROC_CNT=$(ps aux | grep 'bq load' | wc -l)
    echo "BQ_PROC_CNT: ${BQ_PROC_CNT} "
    if [ ${BQ_PROC_CNT} -ge ${LIMIT} ] ;
    then
        echo "sleeping for ${TIMEOUT} sec..."
        sleep ${TIMEOUT}
    else
        FILEPATH=${FILENAMES[$i]}
        # get filename from path
        FILE="${FILEPATH##*/}"
        echo "Importing ${FILE}"
        sudo bash /home/ubuntu/bqimportrange.sh ${FOLDER} ${FILE} ${DATASET} ${SCHEMA}
        i=$(($i + 1))
    fi
done

TS=`date "+%Y-%m-%d-%H:%M"`
SUBJECT2="BQ Import finished ${TS}"
BODY="${SUBJECT1} ${SUBJECT2} URL https://bigquery.cloud.google.com/table/"
echo ${BODY}
mail -s ${SUBJECT2} ${TO_ADDRESS} -- -r ${FROM_ADDRESS}
