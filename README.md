# ipconfig.sh
A bash script that gives a concise output for the ip command "show" functions
Reminiscent of the ipconfig command in windows (with no args added) or the original ifconfig (no args) in unix/linux.
Goal is to take outputs to get ip address, network ID, MAC address, default gateway, and default DNS server(s) and put it in an easily-reachable command.
May add new info, improve display or information, or make it more efficient in the future

Configuring:
You'll want to download the file and place it in /usr/local/bin/ or any other folder in $PATH
You can remove the .sh file extension or give the file an alias in your .bashrc file in order to make it easier to call.
Feel free to rename it if you'd like
