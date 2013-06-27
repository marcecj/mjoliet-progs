#!/bin/bash

# This small script uses qcheck to find missing files and qfile to find the
# associated packages. It prints out the resulting list of packages.

# NOTE: For "qcheck -a", this would be so much faster and elegant if it would
# remember the current package and check if lines under it include the string
# "AFK".

COUNTER=1
TMP_COUNTER=1

# Set paramater for qcheck.
if [[ ! $1 ]]
then
    echo "No package given. Defaulting to checking *all* packages!"
    PARAM="-a"
else
    PARAM=$1
fi

echo -e "Doing a \"qcheck $PARAM\" now...\n"

# Save list of files in an array.
FILE_LIST=($(qcheck $PARAM | grep AFK | awk '{print $2}'))

# Determine number of files.
i_max=$( echo -e ${FILE_LIST[@]} | wc -w )
echo -e "Number of files to be assigned: $i_max.\n"

echo -e "Assigning files to packages now...\n"

for i in $(seq 1 $i_max)
do
    # Get package owning current file.
    TEMP[$TMP_COUNTER]=$( qfile -C ${FILE_LIST[$i]} | awk '{print $1}' )

    # If the current package is the same as the previous package, skip this.
    if [[ ${LIST[(($COUNTER-1))]} != ${TEMP[$TMP_COUNTER]} ]]
    then
        # Set next entry in LIST to new package.
        LIST[$COUNTER]=${TEMP[$TMP_COUNTER]}
        echo ${LIST[$COUNTER]}
        COUNTER=$(($COUNTER + 1))
    fi

    TMP_COUNTER=$(($TMP_COUNTER + 1))
done

echo "Were done now! Phew."
#EOF
