# Preferably run as root. Purpose is to completely stop xrdp as a service to kill all open xrdp sessions. Then find all other open sessions, and kill \
# them made to be run as part of a cronjob that would have the potential to run nightly.
#!/bin/bash

echo -e "\n \n"
echo "Starting Session_wiper. I hope you saved your stuff.| "
echo -e "\n \n"
systemctl stop xrdp.service
echo -e "\n \n"
sleep 2
echo "XRDP should no longer be running, lets check. | |"
echo -e "\n \n"
systemctl status xrdp.service
echo -e "\n \n"
sleep 2
echo "Moving on. | | |"
echo -e "\n \n"
systemctl start xrdp.service
echo -e "\n \n"
echo "Now it should be back. Lets check again. | | | |"
echo -e "\n \n"
sleep 2
systemctl status xrdp.service
echo -e "\n \n"
sleep 2
echo "Sweet. Now that we no longerhave to worry about those guys. Later nerd. | | | | |"
#-------------------------------

who | awk '{print $1}' | sort | uniq | paste -sd, - | xargs -I {} pkill -HUP -u {}

#-------------------------------
