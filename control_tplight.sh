
PINK_SEQ="\x1b[38;2;255;192;203m"
GREEN_SEQ="\x1b[38;2;237;246;125m"
RESET_SEQ="\x1b[0m"

PS3="Select: "
CHOICES=("off" "on")
bulb_options=("Scan" "Manage Individual" "All On" "All Off" "Quit")

printf "$PINK_SEQ------------------------------------------------$RESET_SEQ\n"
printf "$PINK_SEQ--$RESET_SEQ Claire's Tp-Link \
Lightbulb Control Program $PINK_SEQ--$RESETSEQ\n"
printf "$PINK_SEQ------------------------------------------------$RESET_SEQ\n"

# end of greeting screen
FOUND_DEVICES=()
select OPT in "${bulb_options[@]}"
do 
    case $OPT in 
	"Scan")
	    readarray -t FOUND_DEVICES < <(tplight scan -t 3 | cut -d " " -f1)
	    ;;
	"Manage Individual")
	    if [ -z "$FOUND_DEVICES" ]; then
		echo "Please run a scan first :)"
		break
	    fi
	    # that's how we grep on_off
	    for ip in "${FOUND_DEVICES[@]}"; do
		printf "${PINK_SEQ}Lightbulb${RESET_SEQ}: ${GREEN_SEQ}$ip: \
Status:${RESET_SEQ} "
		tplight details $ip | \
		    grep '"on_off": \d,' | tr -dc '0-9' | \
		    grep -q '1' && printf "on\n" || printf "off\n"
		
		
		printf "\n"
	    done
	    
	    printf "Please Select Bulb to Manage [1-${#FOUND_DEVICES[@]}]: "
	    read choice1
	    printf "Would you like the bulb to be off or on? [0-1]: "
	    read choice2
	    
	    tplight "${CHOICES[$choice2]}" "${FOUND_DEVICES[$choice1-1]}" > \
		    /dev/null
	    ;;
	"All On")
	    echo "all on"
	    ;;
	"All Off")
	    echo "all off"
	    ;;
	"Quit")
	    echo "Exiting :)"
	    break
	    ;;
	*)
	    echo "invlid option $REPLY"
	    ;;
    esac
done
if [ -n "${FOUND_DEVICES}" ]; then
    echo "${FOUND_DEVICES[@]}"
fi
