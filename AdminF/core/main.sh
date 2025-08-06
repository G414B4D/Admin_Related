# Will launch logic and dispatcher for the tool
#/bin/bash

source core/utils.sh
source core/menu.sh

if [[ -z "$1" ]]; then
  show_menu
else
  run_module "$@"
fi
