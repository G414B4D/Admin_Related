for disk in $(lsblk -nd -o NAME); do echo "/dev/$disk: $(udevadm info --query=all --name=/dev/$disk | grep ID_SERIAL"; done
