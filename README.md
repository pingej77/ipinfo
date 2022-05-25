# ipconfig.sh
A bash script that gives a concise output for the ip command "show" functions
Reminiscent of the ipconfig command in windows (with no args added) or the original ifconfig (no args) in unix/linux.

Goal is to take outputs to get ip address, network ID, MAC address, default gateway, and default DNS server(s) and put it in an easily-reachable command.
May add new info, improve display or information, or make it more efficient in the future

## Configuring:
You'll want to download the file and place it in /usr/local/bin/ or any other folder in $PATH

You can remove the .sh file extensionin order to make it easier to call.

Alternatively, you can give it an alias in your .bashrc file

For this you can use ipinfo, ipconfig, or anything else easy for you to type

   Ex:   alias ipinfo='ipconfig.sh'

## Changing Colors:
Colors are defined in lines 3 through 9

You can change the colors for a particular data type by changing the "tput setaf" value to any other value between 1 and 7.

The color of each interface heading cycles through the colors, starting at white.  To change this, edit the $color variable on line 32

1=red, 2=green, 3=yellow/orange, 4=blue, 5=purple, 6=teal/cyan, 7=white.  0 is BG color and will render text unreadable
(colors may vary based on terminal settings)
