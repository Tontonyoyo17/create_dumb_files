#!/bin/bash
set -e
#########################
#       Help            #
#########################

help="$(basename "$0") [-h] [-v] [-d DIRECTORY] [-i random|zero] [-c filecount] [-s filesize] [-u b|kb|mb] [-p MAX_PROC]
This script is used to create dumb files
    -h Shows this help text
    -d Directory where the files should be created
    -i Input data type (random of zero) (default: 0)
    -c Number of files to create (default: 5)
    -s Size of unit per file (min/default: 1)
    -u Unit (default: MB)
    -p Maximum process to run in parallel (default: 5 - max: 50)"

#########################
#       Main Program    #
#########################
VERSION=1.0

#########################
#   Default values      #
#########################

FILE_COUNT=5
BLOCK_COUNT=1
BLOCK_SIZE=1048576
INPUT_DATA="/dev/zero"
MAX_PROC=5

#############################################################################
#       Process the input options. Add options as needed                    #
#############################################################################

# Get the options
while getopts "hvd:i:c:s:p:u:" option; do
    case $option in
        h) #display help
            echo "$help"
            exit 0;;
        v) #display the script version
            echo "You are currently running $(basename "0") v$VERSION"
            exit;;
        d) #Directory to create the files in
            MY_DIR=${OPTARG}
            ;;
        i) # Choose between /dev/zero and /dev/urandom
           # Default value is /dev/zero
            if [ "${OPTARG}" = "zero" ]
            then
                INPUT_DATA="/dev/random"
            elif [ "${OPTARG}" = "random" ]
            then
                INPUT_DATA="/dev/urandom"
            else
                echo "ERROR: Incorrect value for -i"
                echo "Possible values are:"
                echo "zero: to use /dev/zero"
                echo "random: to use /dev/urandom"
                echo
                echo "$help"
                exit 1
            fi
            ;;
        c) # File count to create
           # Default is 5
            FILE_COUNT=${OPTARG}
            ;;
        s) # File size
            BLOCK_COUNT=${OPTARG}
            ;;
        p) # Max Concurrent processes
            MAX_PROC=${OPTARG}
            ;;
        u) # Set unit
            unit=$(echo "${OPTARG}" | tr "[:upper:]" "[:lower:]")
            case $unit in
                b)
                    BLOCK_SIZE=1  
                    ;;
                kb)
                    BLOCK_SIZE=1024
                    ;;
                mb)
                    BLOCK_SIZE=1048576
                    ;;
                \?)
                    echo "The script only support a block size of 1B, 1KB or 1MB"
                    echo "Default is 1MB"
                    echo "You can re-run the script with a supported unit (block size)"
                    exit 1;;
            esac
            ;;
        \?) # Any other flag
            echo "ERROR: Invalid flag used" 
            echo
            echo "$help"
            exit 1
            ;;
    esac
done

# Check if MY_DIR received a value

if [ -z "$MY_DIR" ]
then
    echo "ERROR: -d DIRECTORY must be provided"
    echo 
    echo "$help"
    exit 1;
fi

# Check if MY_DIR is a dir
if [ -d "$MY_DIR" ]
then
    i=0
    while [ $i -lt "$FILE_COUNT" ]
    do
        # Wait until we have less than MAX_PROC running dd commands
        while [ $(pgrep --full -c "dd if") -ge "$MAX_PROC" ]
        do
            sleep 1
        done 

        # Launch a dd command in the background
        dd if="$INPUT_DATA" bs="$BLOCK_SIZE" count="$BLOCK_COUNT" conv=fsync of="$MY_DIR/file_$i.dat" 2> /dev/null &

        i=$((i+1))
        
        # Progress output every 10 files written
        if (( i % 10 == 0 ))
        then
            echo "File $i out of $FILE_COUNT written"
        fi
    done

# If MY_DIR is a file
elif [ -f "$MY_DIR" ]
then 
    echo """$MY_DIR"" is a file, not a directory"
# If the file doesn't exist
else 
    echo "$MY_DIR does not exist"
fi 
wait