#!/bin/bash 


process_files() {
    local files=("$@")
    rm -rf "${files[@]}"
    sleep 0.5
}

progress_bar() {
    local current_processed=$1
    local total=$2

    local now=$(date +%s)
    local elapsed=$((now - $START_TIME))
    ((elapsed==0)) && elapsed=1

    local percent=$((   current_processed * 100 / total ))
    local filled=$((    percent * BARWIDTH / 100 ))
    local empty=$((BARWIDTH-filled))

    local speed=$(( current_processed / elapsed))
    local eta=$(( (total - current_processed ) / (speed > 0 ? speed : 1) ))
    local spinner="${SPINNER_CHARS:SPINNER_INDEX:1}"
    SPINNER_INDEX=$(( (SPINNER_INDEX + 1) % ${#SPINNER_CHARS} ))

    printf "\r${CYAN}%s${RESET} [" "$spinner"

    printf "${GREEN}%0.s#" $(seq 1 $filled)
    printf "%0.s " $(seq 1 $empty)

    printf "] ${YELLOW}%3d%%${RESET} %d/%d | %ds elapsed | %ds ETA | %d/s" \
        "$percent" "$current_processed" "$total" "$elapsed" "$eta" "$speed"
}






read -p "ENTER THE BATCH SIZE: " BATCHSIZE
BATCHSIZE=$BATCHSIZE

read -p "ENTER THE BAR WIDTH: " BARWIDTH
BARWIDTH=$BARWIDTH

#we can choose our own choice spinner
SPINNER_CHARS='▁▂▃▄▅▆▇█'
SPINNER_INDEX=0
START_TIME=$(date +%s)

#if we are outputing to terminal then colors else black and white so there is no garbagechars
if [[   -t 1    ]]
then 
    GREEN=$(tput setaf 2)
    CYAN=$(tput setaf 6)
    YELLOW=$(tput setaf 3)
    RESET=$(tput sgr0)
else    
    GREEN=""
    CYAN=""
    YELLOW=""
    RESET=""
fi

read -p "Enter the suffix of files: " SUFFIX

echo "  Finding the files......"
files=(./**/*$SUFFIX*)
total="${#files[@]}"
echo "Total files found inside the current directory is $total"

if ((total == 0))
then 
    echo "There is not any file to do Processing"
    exit 0
fi

processed=0

for (( i=0 ; i<= total ; i+=BATCHSIZE ))
do 
    #here we are doing the array slicing
    #array:start_idx:length
    batch=( "${files[@]:i:BATCHSIZE}" )
    process_files "${batch[@]}"
    processed=$((processed + ${#batch[@]} ))
    progress_bar "$processed" "$total"
done 

printf "\n Done in %ds \n" "$((  $(date +%s) - START_TIME ))"
echo 


