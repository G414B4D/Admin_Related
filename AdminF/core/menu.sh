#/bin/bash

show_menu() {
  echo "=== Admin Framework For General Tasks: AdminF === "
  echo "1) Create User"
  echo "2) Show IP Info"
  echo "3) Update Packages"
  echo "4) Update root password age to now"
  echo "5) Rsync file from remote host"
  echo "6) exit"
  read -rp "Please select an option: " choice

  case "$choice" in
    1) run_modules users/create_user.sh ;;
    2) run_modules network/show_ip.sh ;;
    3) run_modules packages/update_all.sh ;;
    4) run_modules accounts/root_PW_date.sh ;;
    5) run_modules root_copy.sh ;;
    6) exit 0 ;;
    *) echo "Invalid choice"; sleep 1; show_menu ;;
  esac
}    
