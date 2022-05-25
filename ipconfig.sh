#!/bin/bash

#formatting variables
reset=$(tput sgr0)	#reset to default formatting
fmt_header=$(tput smul;tput setaf 6;tput bold)	#headers are teal, bold, & underlined
fmt_IP=$(tput setaf 4)		#4=blue
fmt_MAC=$(tput setaf 3)		#3=yellow(orange)
fmt_DNS=$(tput setaf 7)		#7=white
fmt_DHCP=$(tput setaf 5) 	#5=purple

#sets IP & MAC information from ip command as variables
ip_info=$(ip --brief address show | cut -c33-)
if_info=$(ip --brief link)

#prints loopback info
echo "${fmt_header}loopback:"
printf "${reset}"
printf "$if_info\n" | head -1
printf "\t\t\t\t$ip_info\n" | head -1 | sed -e 's/ /\t/'
printf "\n"

#display network ID info
echo "${fmt_header}Network Info:${reset}$fmt_IP"	#header for Net info
ip route show | tail -1
printf "${reset}\n"

#print IP and MAC info for each interface
line_ct=$(ip --brief address show | wc -l)
for ((i=2;i<=$line_ct; i++))	#iterate over interfaces
do
	let x=$i-1		#set if num as i-1
	let color=(4+$i)%7+1	#cycle color between 1 and 7
	#format header with different color for each interface
	echo -e "${fmt_header}$(tput setaf $color)if ${x}\t\tStatus:\t\tAddress:"	#header
	#print if info with formatting
	echo -n "${reset}${fmt_MAC}"
	printf "${reset}${fmt_MAC}$if_info" | sed -n ${i}p | sed 's/<BROADCAST.*//'
	#puts interface line into a variable
	line_ip=$(printf "$ip_info" | sed -n ${i}p)
	printf "\n"
	#if blank (no ip address for this interface), skip formatting
	if [[ ! $line_ip =~ [^[:space:]] ]]
	then
		continue
	else
		printf "${fmt_IP}IPv4\t\t\t\t"
		#This line is quite long and simply has to do with the formatting of the IP addresses and labelling of each ipv6 address type
		printf "$line_ip" | sed -e 's/ /\nIPv6\t\t\t\t/g' -e 's/\t\tfe80/ link-local\tfe80/g' -e 's/\t\t2/ global\t\t2/g' -e 's/\t\tfc/ (ULA)\t\tfc/g' -e 's/\t\tfd/ (ULA)\t\tfd/g' | sed '$d'
	fi
	printf "\n"
done

#default gateway info
echo -e "${fmt_header}Default Gateway:"	#header
echo -n "${reset}${fmt_IP}"	#reformat to IP
echo -n $(ip -4 route show | head -1) | sed 's/dev.*//' | sed 's/default via //' #get ipv4 format
echo -e "\t\t$(ip -6 route show | grep 'fe80::')" | sed 's/dev.*//'			#get ipv6 format
printf "\n"

#dhcp info:
#dhcp info as var
dhcp_info=$(nmcli -f DHCP4 con show "$(nmcli -g NAME con show --active)")
echo -e "${fmt_header}DHCP Lease:${reset}"
#convert lease time into human-readable; T = lease time in second
T=$(printf "$dhcp_info" | grep 'dhcp_lease_time' | cut -c59-)
printf "${fmt_DHCP}dhcp_lease_time \t"
	D=$((T/60/60/24))
	H=$((T/60/60%24))
	M=$((T/60%60))
	S=$((T%60))
	(( $D > 1 )) && printf '%d days ' $D
	(( $D == 1 )) && printf '%d day ' $D
	(( $H > 0 )) && printf '%d hours ' $H
	(( $M > 0 )) && printf '%d minutes ' $M
 	(( $D > 0 || $H > 0 || $M > 0 )) && A="and "
	(( $S > 0 )) && printf '$A$S seconds'
printf "\n"
	#get expiration date and convert from Unix-Epoch
printf "$dhcp_info" | grep 'dhcp_server_identifier' | cut -c41- | sed -e 's/_identifier /\t/' -e 's/= /\t/g'
printf "expiration\t"
exp_date=@$(printf "$dhcp_info" | grep 'expiry' | cut -c50-)
printf "\t"
date -d $exp_date
printf  "\n"

#dns info:
echo "${fmt_header}Default DNS:"	#DNS header
echo -n "${reset}"   	#reformat
#fetch DNS info
dns_info=$(printf "$dhcp_info" | grep 'domain_name_servers' | head -1 | cut -c41- | sed -e 's/domain_name_servers = //' | sed -e 's/ /\n/')
printf "${fmt_IP}$dns_info" | head -1 | tr -d '\n'	#print DNS 1
printf "$fmt_DNS"
printf "$dns_info" | head -1 | nslookup | head -1 | sed -e 's/.*name = /\t\t/'	#get DNS1 name
printf "${fmt_IP}"
printf "$dns_info" | tail -1	#print DNS 2
printf "$fmt_DNS"
printf "$dns_info" | tail -1 | nslookup | head -1 | sed -e 's/.*name = /\t\t/'	#get DNS2 name
#reset formatting
printf "${reset}\n"

#END
