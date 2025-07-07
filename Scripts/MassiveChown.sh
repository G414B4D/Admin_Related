#Script will pass a created list of folders/directories (one per line), and set ownership of all to root:root
#!/bin/bash
read -p "Enter the full path to your list of folders/directories to chown: " LIST
echo""
cat $LIST | xargs -I {} chown root:root "{}"
