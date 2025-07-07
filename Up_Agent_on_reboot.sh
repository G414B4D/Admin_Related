#I would recommend running the script as root just to avoid any complications,
#but if you run it as your user account (assuming you have rights) it should
#still prompt for password and work.

#Script removes the 'noexec' flag from /scratch, and restarts bot of the agents on the system.
#!/bin/bash
echo "Remounting /scratch to remove 'noexec' and restarting services"
echo -e "\n \n"
dzdo mount -o remount,exec /dev/mapper/scratch /scratch && dzdo systemctl restart vsts.agent.tfs.*
sleep 2
echo"Checking Agent(s) status. Should be running now."
echo -e "\n \n"
sleep 2
systemctl status vsts.agent.tfs.*
echo -e "\n \n"
sleep 2
echo "If they show running, everything should be good to go."
