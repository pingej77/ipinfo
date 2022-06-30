#!/bin/bash

if [[ $1 == "--help" ]]; then
	echo "this program prints network and network interface information"
	echo "passing no switch shows network info and MAC and IP info for each interface"
	echo "use -b, -br, or --brief to only show basic router and IP address info"
	echo "use -a, -all, or --all to show DHCP, DNS, and loopback info"
	echo "this command does not support multiple switches; they are mutually exclusive."
	echo "colors can be changed by editing the script file"
	exit 0
fi

#formatting variables; data types are colored differently
reset=$(tput sgr0)	#removes formatting
fmt_header=$(tput smul;tput bold;tput setaf 67)	#headers are underlined, bold, and cobalt blue
fmt_lo=$(tput setaf 8)		#loopback is gray
fmt_IPv4=$(tput setaf 5)	#IPv4 is purple
fmt_IPv6=$(tput setaf 4)	#IPv6 is blue
fmt_if=$(tput setaf 6)		#interface is teal
fmt_MAC=$(tput setaf 11)	#MAC addr is yellow
fmt_DHCP=$(tput setaf 253)	#DHCP is light gray (232-255 are shades of gray)
fmt_DNS=$(tput setaf 7)		#Domain is white

#network info:
echo "${fmt_header}Network Info:$reset"		#header/formatting
IFS=$'\n'	#delim=new line
routing=($((ip route && ip -6 route) | sed 's/dev.*//' | sed -e 's/::1.*//'))	#routing info stored as an array
IFS=$' '	#reset delim
#print network ID
printf "${reset}network ID\t$fmt_IPv4"
echo ${routing[1]}
tput sgr0
#print gateway info
echo ${routing[0]} | sed -e "s/via/gateway${fmt_IPv4}/"
for (( i=2;i < ${#routing[@]};i++ ));do
	echo -e "${fmt_IPv6}\t\t${routing[$i]}"
done

#use -b, -br, -brief or --brief to get short answers
if [[ $1 == "-b"* ]];then
	tput sgr0
	ip route | grep -m 1 "src" | sed -e "s/proto.*src /\n\t\t${fmt_IPv4}/" -e 's/metric.*//' -e "s/.*dev/default if     ${fmt_if}/"
	echo $reset
	exit 0
fi
echo $reset

#set interface/ip info into variables
ip_info=$(ip --brief address show | cut -c33-)
if_info=$(ip --brief link)
MAC_adr=$(printf "$if_info" | cut -c33- | sed 's/<.*//g')
line_ct=$(printf "$ip_info\n" | wc -l)

#iterate over each interface
for (( i=2;i <= $line_ct; i++ ))
do
	#put each if's IP info in a variable and then put all IP addresses in an array named #address#
	line_ip=$(printf "$ip_info" | sed -n ${i}p)
	address=($line_ip)
	#set each if header to start with its own color; starting with white
	let color=($i + 12)%15+1
	tput smul;tput bold;tput setaf $color
	#print header
	(( --i ))
	printf "if ${i}\t"	#if # (start at 1 with decrement and re-increment)
	(( i++ ))
	#print interface name
	echo -n $fmt_if
	line_if=$(printf "$if_info" | sed -n ${i}p | cut -b 1-8 | sed 's/ //g')
	echo -n $line_if
	tput setaf 8
	printf "\t\t\tStatus:\t$reset"	#print {Status:} in gray
	#print status and format
	tput bold
	line_stat=$(printf "${if_info}" | sed -n ${i}p | cut -b 8-30 | sed 's/ //g')
	[[ $line_stat == *"UP"* ]] && tput setaf 2 || tput setaf 9	#UP=Green, otherwise=red
	echo ${line_stat}$reset
	#print MAC address
	printf "${fmt_MAC}\tLAN\tMAC address\t"
	printf "$MAC_adr\n" | sed -n ${i}p

	#prints IP addresses for each if and labels each one according to its type
	for j in ${!address[@]}
	do
		#labelling IPv4
		if [[ ${address[$j]} == *"."* ]]; then
			printf "${fmt_IPv4}\tIPv4\t"
			[[ ${address[$j]} == "10."* ]] && printf "private"
			[[ ${address[$j]} == "192.168."* ]] && printf "private"
			printf "\t\t"
		#labelling IPv6
		elif [[ ${address[$j]} == *":"* ]]; then
			printf "${fmt_IPv6}\tIPv6\t"
			[[ ${address[$j]} == "fc"??":"* ]] && printf "ULA"	#ULA
			[[ ${address[$j]} == "fd"??":"* ]] && printf "ULA"	#Unique local address
			[[ ${address[$j]} == "2"???":"* ]] && printf "global"	#global address
			[[ ${address[$j]} == "fe80:"* ]] && printf "link-local" || printf "\t"	#link-local +extra tab for non-link-local
			printf "\t"	#each type gets 2 tabs, except link-local, which gets 1, due to its length
		fi
		#print IP address
		echo -e "${address[$j]}"
	done
done
printf "\n$reset"

#only show dhcp and dns info if you call -a, --all or similar variants
[[ $1 == *"a"* ]] || exit 0

#print loopback
echo -e -n "${fmt_header}Loopback${reset}${fmt_lo}\nMAC\t"
printf "$if_info" | cut -c33- | head -1
printf "IP\t$ip_info" | head -1 | sed -e 's/ /\t/'
printf "\n"

#DNS & dhcp info:
dp_info=$(nmcli -f DHCP4 con show "$(nmcli -g NAME con show --active)" | cut -c41- | grep -v "requested")

#dhcp info as var
echo -e "${fmt_header}DHCP Lease:${reset}"
#convert lease time into human-readable; T = lease time in second
T=$(printf "$dp_info" | grep 'dhcp_lease_time' | cut -c18-)
printf "${fmt_DHCP}dhcp_lease_time \t"
       	S=$((T%60))
       	T=$((T/60))
        M=$((T%60))
        T=$((T/60))
	H=$((T%24))
	D=$((T/24))
        (( $D > 1 )) && printf '%d days ' $D
        (( $D == 1 )) && printf '%d day ' $D
        (( $H > 0 )) && printf '%d hours ' $H
        (( $M > 0 )) && printf '%d minutes ' $M
        (( $D > 0 || $H > 0 || $M > 0 )) && A="and "
        (( $S > 0 )) && printf '$A$S seconds'
printf "\n"
        #get expiration date and convert from Unix-Epoch
printf "$dp_info" | grep 'dhcp_server_identifier' | sed -e "s/_identifier = /\t\t${fmt_IPv4}/"
printf "${fmt_DHCP}expiration\t"
exp_date=@$(printf "$dp_info" | grep 'expiry' | cut -c10-)
printf "\t"
date -d $exp_date
printf  "\n"

#dns info:
echo "${fmt_header}Default DNS:"        #DNS header
echo -n "${reset}"      #reformat
#fetch DNS info
dns_info=$(printf "$dp_info" | grep 'domain_name' | sed -e 's/domain_name.* = //' -e 's/ /\n/' -e "2 s/./${fmt_IPv4}&/")
echo ${fmt_DNS}$dns_info
#printf "${fmt_IPv4}$dns_info" | head -1 | tr -d '\n'      #print DNS 1
#printf "$fmt_DNS"
#printf "$dns_info" | head -1 | nslookup | head -1 | sed -e 's/.*name = /\t\t/'  #get DNS1 name
#printf "${fmt_IPv4}"
#printf "$dns_info" | tail -1    #print DNS 2
#printf "$fmt_DNS"
#printf "$dns_info" | tail -1 | nslookup | head -1 | sed -e 's/.*name = /\t\t/'  #get DNS2 name

echo $reset

