#/usr/bin/env bash

source config/settings.conf
source core/colors.sh
source core/utils.sh
source core/menu.sh

if [[ -z "$1" ]]; then
  show_menu
else
  run_module "$@"
fi
