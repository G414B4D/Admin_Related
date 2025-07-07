#Preferred to be run as root, but should not be needed if you have correct perms.
#!/bin/bash

read -p "Enter your username: " user
read -p "Enter host to copy from: " host
read -p "Enter full path of the file to copy from the remote host: " filecop
read -p "Enter the destination filder: " filedest
echo ""
sleep 1
rsync -avs --rsync-path="dzdo rsync" "$user@$host:$filecop" "$filedest"
echo ""
echo ""
echo "File copied successfully."
echo ""
