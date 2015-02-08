#!/bin/bash

####Use: ./csv2root.sh argv1 argv2
###argv1 is the full path + file name of the csv file you wish to convert
###argv2 is the name you want to give the tree that will store the data

INPUT_CSV=$1
TREE_NAME=$2
CSV_NAME=$1

###Isolate CSV file name from full path

needle="/"
num_slash=$(grep -o "$needle" <<< "$INPUT_CSV" | wc -l)

  COUNTER=0
  while [ $COUNTER -lt $num_slash ]; do
      CSV_NAME=`echo ${CSV_NAME#*/}`
      let COUNTER=COUNTER+1
  done

echo "The full path of the .csv file is "$INPUT_CSV
echo "The name of the .csv file is "$CSV_NAME

###Make directory for file we will convert
##Directory will house generated macro, .dat from .csv file, and .root from .dat file

folder_ending="_csv_conversion"
csv_ending=".csv"

NEW_DIRECTORY_NAME=${CSV_NAME//$csv_ending/$folder_ending}
mkdir $NEW_DIRECTORY_NAME

###Make .dat file from .csv and put it into the new directory

dat_ending=".dat"
DATA_FILE=${CSV_NAME//$csv_ending/$dat_ending}
NEW_PATH_FILE=$NEW_DIRECTORY_NAME"/"$DATA_FILE

sed -e "1d" -e "s|,| |g" $INPUT_CSV > $NEW_PATH_FILE

###Generate the macro for converting the .dat file to .root

root_ending=".root"
ROOT_FILE=${CSV_NAME//$csv_ending/$root_ending}
Feature_Names_comma=$(head -n 1 $INPUT_CSV)
INPUT_CHARACTERS=">>"
Feature_Names_in=${Feature_Names_comma//,/$INPUT_CHARACTERS}
Feature_Names=${Feature_Names_comma//,/$IFS}

for x in $Feature_Names; do     echo "TBranch *b_$x = tree->Branch(\"$x\",&$x);"; done > text.txt 

BRANCH_BLOCK=$(<text.txt)
BRANCH_BLOCK_escaped=$(printf '%s\n' "$BRANCH_BLOCK" | sed 's,[\/&],\\&,g;s/$/\\/')
BRANCH_BLOCK_escaped=${BRANCH_BLOCK_escaped%?}
rm text.txt

NEW_PATH_C_FILE=$NEW_DIRECTORY_NAME"/convert_train_to_ROOT.C"

sed -e "s|TREE_NAME|$TREE_NAME|g" -e "s|ROOT_FILE|$ROOT_FILE|g" -e "s|DATA_FILE|$DATA_FILE|g" -e "s|FEATURE_NAMES_COMMA|$Feature_Names_comma|g" -e "s|BRANCH_BLOCK|$BRANCH_BLOCK_escaped|g" -e "s|FEATURE_NAMES_IN|$Feature_Names_in|g" convert_csv_skeleton.C > $NEW_PATH_C_FILE

###change to the new directory and run the generated macro

cd $NEW_DIRECTORY_NAME
root -b -q convert_train_to_ROOT.C