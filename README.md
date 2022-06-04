# ipconfig.sh
A bash script that gives a concise output for the ip command "show" functions
Reminiscent of the ipconfig command in windows (with no args added) or the original ifconfig (no args) in unix/linux.

Goal is to take outputs to get ip address, network ID, MAC address, default gateway, DHCP lease and server info, and default DNS server(s) and put it in an easily-reachable command.
May add new info, improve display or information, or make it more efficient in the future

## Configuring:
You'll want to download the file and place it in /usr/local/bin/ or any other folder in $PATH

You can remove the .sh file extensionin order to make it easier to call.

Alternatively, you can give it an alias in your .bashrc file

For this you can use ipinfo, ipconfig, or anything else easy for you to type

   Ex:   alias ipinfo='ipconfig.sh'

## Changing Colors:
Colors are defined early in the script and are assigned based on data type.

You can change the colors for a particular data type by changing the "tput setaf" value to any other value between 1 and 255.

The color of each interface heading cycles through 15 colors, starting at white.  To change this, edit the $color variable.

1=red, 2=green, 3=yellow/orange, 4=blue, 5=purple, 6=teal/cyan, 7=white, 8=gray, 9=faded red, 10=light teal, 11=yellow, 12=light blue, 13=dark purple, 14=dark teal, 15=white

0 is BG color and will render text unreadable.
(colors may vary based on terminal settings)

## Switches
As of the new version; there are now switch options:
   
   -b, -br, or --brief  will shorten the output to not show the information for every interface
   
   -a, a, -all, or variations will show the DHCP and DNS info
   
   --help recaps the basic usage info
   
Switches are implemented roughly to allow for misspellings; this will need to be changed if more switches are added
