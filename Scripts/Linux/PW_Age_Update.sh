############################################################
#
# True to name, and only used with the BEST of secuirty practices in mind.
#
############################################################

#!/usr/bin/bash
tdate=$(date +%F)
echo ""
echo "Changing the date of the root password to todays date."
echo ""
sleep 2
dzdo chage -d $tdate root
echo "Verifying.."
sleep 2 
echo ""
dzdo chage -l root | grep -i last
echo ""
echo "As long as todays date is reflected you are good to go."
echo ""
