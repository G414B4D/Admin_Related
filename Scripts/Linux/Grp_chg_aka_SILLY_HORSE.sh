echo "Checking /lib /lib64 /usr/lib /usr/lib64 for the silly horse."
sleep 1
echo ""
find /lib /lib64 /usr/lib /usr/lib64 ! -group root -exec ls -l {} \;
echo ""
echo "Fixing..."
find /lib /lib64 /usr/lib /usr/lib64 ! -user root -type d -exec stat -c "%n %U" '{}' \;
find /lib /lib64 /usr/lib /usr/lib64 ! -group root -type d -exec stat -C "%n %G" '{}' \;
find /lib /lib64 /usr/lib /usr/lib64 ! -group root -exec chgrp root {} +
find /lib /lib64 /usr/lib /usr/lib64 ! -group root -exec chgrp -h root {} +
echo ""
echo "Checking again. If you don't see anything after this. You good dawg."
find /lib /lib64 /usr/lib /usr/lib64 ! -group root -exec ls -l {} \;
echo ""
sleep 1
echo "If you did see output, hopefully its not a lot. Try running this again, or chown whatever you need."
echo ""
