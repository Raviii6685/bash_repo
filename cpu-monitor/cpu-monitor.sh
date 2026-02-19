#this helps to watch cpu stats every 5 seconds 
# watch -n1 -d head -5 /proc/stat

declare  CURRENT=()
declare  PREVIOUS=()

progress-bar() {
    local processed="$1"
    local key="$2"
    local percent="$3"
    local bar='|'

    local empty_char=' '
    local length=100
    local number_of_bars=$((processed * length / 1000))

    local i 
    local s='['

    for (( i=0 ; i<number_of_bars ; i++))
    do 
        s+=$bar
    done

    for ((i=number_of_bars ; i<length ;i++))
    do 
        s+=$empty_char
    done

    s+=']'

    echo  "$s" "$key"  "$percent"

}

print-bar(){
    local key="$1"
    local busy_previous idle_previous
    local busy_current idle_current

    #this is we are using teh here string the variables will be automatically assigned as the string is passed
    read -r busy_previous idle_previous <<< "${PREVIOUS[$key]}"
    read -r busy_current idle_current <<< "${CURRENT[$key]}"

    local busy=$((busy_current-busy_previous))
    local idle=$((idle_current-idle_previous))
    #this variable is used to calculate percentage for the system
    local total=$((busy+idle))
    
    local busy_usage=$((busy*1000/total))
   # local idle_usage=$((idle*1000/total))

    local busy_perc_int_part=$((busy_usage/10))
    local busy_perc_frac_part=$((busy_usage%10))
    local busy_perc="$busy_perc_int_part.$busy_perc_frac_part"
    progress-bar "$busy_usage"  "$key" "$busy_perc"
}



#this function is used for the visulaize the data into the graphs
visulaize-data() {
    local now 
    printf -v now '%(%d-%m-%Y    %H:%M;%S%z)T'
    echo  "CPU usuage for the $HOSTNAME....  - $now"
    printf '%()T\n'

    local key  

    for key in "${!CURRENT[@]}";
    do
        print-bar "$key"
        
    done

}



#we are copying the current data insdie the previous array
copy-data(){
    PREVIOUS=()
    local key value
    for key in "${!CURRENT[@]}"
    do 
        PREVIOUS[$key]="${CURRENT[$key]}"
    done 
}

read-proc() {
    local system_busy system_idle
    local key user nice system idle iowait irq softirq steal guest guest_nice
    while read -r  key user nice system idle iowait irq softirq steal guest guest_nice
    do 
       if [[ "$key" != "cpu0" && "$key" != "cpu1" && "$key" != "cpu2" && "$key" != "cpu3"  ]] 
        then 
            continue 
        fi

        #how much cpu was busy doing something
        system_busy=$(( user + nice + system + irq + softirq + steal + guest + guest_nice ))

        #how much cpu was idle 
        system_idle=$((idle+iowait))

        num="${key#cpu}"
        CURRENT[$num]="$system_busy $system_idle"
    
       #this is the location from where we are going to get the stats for the cpus
    done < "/proc/stat"

}

cleanup() {
    printf '\e[?1049l' #this is to disable the alternate buffer
    printf '\e[?25h' #show the cursor
}

main(){
    read-proc
    echo "waiting for the data...."
    sleep 1

    #enable alternate buffer 
    #hide the cursor 
    #move the cursor home (optional)

    trap cleanup EXIT 

    printf '\e[?1049h' #enable the alternate buffer
    printf '\e[?25l' #hide the cursor
    printf '\e[H'
    local s
    while true;
    do 
        copy-data
        read-proc
        #printf '\e[3J'  #very dangerous clear the scroll upper screen
        s=$(visulaize-data;)
        printf '\e[2J'
        printf '\e[H'
        echo -n "$s"
        sleep 1
    done

}

main "$@"