#!/bin/sh
FOLDER=${1}
DATASET=${2}
SCHEMA=${3}
PROJECT="eminent-torch-384"
FOLDERLOGS="/home/ubuntu/logs"
BQ_PROC_CNT=0
# gsutil allows up to 50 files in parallel
LIMIT=50
TIMEOUT=30

if [ "$#" -ne 3 ]
then
  echo "Parameters expected: [FOLDER] [DATASET] [SCHEMA]"
  exit 1
fi

if [ ${DATASET} = "my_prod_dataset" ]; then
  echo "You cant use 'my_prod_dataset'"
  exit 1
fi


# create array with filenames
declare -a FILENAMES=( "${FOLDER}"/* )
LENGTH=${#FILENAMES[@]}

#echo "LENGTH ${LENGTH}"
#exit
#######################################

rm -rf ${FOLDERLOGS}/*.log
echo "Folder ${FOLDERLOGS} cleared"

i=0;
while [ ${i} -lt ${LENGTH} ]
do

    # check load processes count
    BQ_PROC_CNT=$(ps aux | grep 'bq load' | wc -l)

    echo ""
    date "+%m-%d-%Y %H:%M:%S"
    echo "File ${i} of ${LENGTH}"
    echo "BQ_PROC_CNT: ${BQ_PROC_CNT} "

    if [ ${BQ_PROC_CNT} -ge ${LIMIT} ] ;
    then
        echo "Sleeping for ${TIMEOUT} sec..."
        sleep ${TIMEOUT}
    else
        FILEPATH=${FILENAMES[$i]}
        # get filename from path
        FILE="${FILEPATH##*/}"
        #table name cant contain - or .
        TABLE_NAME=${FILE//[-.]/_}
        echo "Importing ${FILE} ..."

        #bq mk --table --description table_from_CLI ${PROJECT}:${DATASET}.${TABLE_NAME} ${SCHEMA}
        #create table during  load
        # https://cloud.google.com/bigquery/docs/loading-data-cloud-storage-csv#bigquery-import-gcs-file-cli

        if [ ${DATASET} = "my_dataset_temp" ]
        then
            #master is pipe delimited, with a header
            bq load -F "|" --replace --source_format=CSV --max_bad_records=10000 --skip_leading_rows=1 ${DATASET}.${TABLE_NAME} ${FOLDER}/${FILE} ${SCHEMA} &
        else
            #email and postal are comma delimited, no header
            bq load --replace --max_bad_records=10000 ${DATASET}.${TABLE_NAME} ${FOLDER}/${FILE} ${SCHEMA}&
        fi

        i=$(($i + 1))
    fi
done
