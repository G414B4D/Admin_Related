##
#!/bin/bash

run_module() {
  local module_path="modules/$1"
  
  if [[ ! -x "$module_path" ]]; then
    echo "Module not found or not executable: $module_path"
    return 1
  fi

  log "Running module: $1"
  bash "$module_path"
}

log() {
  local logfile="log/$(date +%F).log"
  echo "[$(date '+%T')] $*" | tee -a "$logfile"
}
