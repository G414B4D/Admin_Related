# Quick script that will pull the information from the drives in your system.
#!/bin/bash
for disk in $(lsblk -nd -o NAME); do echo "/dev/$disk: $(udevadm info --query=all --name=/dev/$disk | grep ID_SERIAL"; done
