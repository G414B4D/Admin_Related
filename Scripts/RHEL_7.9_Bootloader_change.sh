############################################################
#
# Run as root and reboot to confirm changes. Then re-run the first grubby command.
#
############################################################

#!/usr/bin/bash
set -e
#Check current configuration
grubby --info=$(grubby --default-kernel)
sleep 2
#Modify CPUs to isolate the amount of cores requested 
grubby --update-kernel=$(grubby --default-kernel) --args="isolcpus=1-29"
