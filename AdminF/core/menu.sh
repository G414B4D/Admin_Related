#/usr/bin/env bash

show_menu() {
  while true; do
    echo "=== Admin Framework For General Tasks: AdminF === "
    echo "1) Create User"
    echo "2) Show IP Info"
    echo "3) Update Packages"
    echo "4) Update root password age to now"
    echo "5) Rsync file from remote host"
    echo "6) exit"
    read -rp "Please select an option: " choice

    case "$choice" in
      1) run_module users/create_user.sh ;;
      2) run_module network/show_ip.sh ;;
      3) run_module packages/update_all.sh ;;
      4) run_module accounts/root_PW_date.sh ;;
      5) run_module root_copy.sh ;;
      6) exit 0 ;;
      *) echo "Invalid choice"; sleep 1; show_menu ;;
    esac
  done
}    
