##
#!/bin/bash

CORE_DIR="$(cd -- "$(dirname --"${BASH_SOURCE[0]}")" && pwd)"

source "$CORE_DIR/../config/settings.conf" 2>/dev/null || true
source "$CORE_DIR/colors.sh"

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
  local timestamp="[$(date '+%T')]"
  local message='$*'

  # Color printing
  echo -e "${GREEN}${timestamp} [INFO]${RESET} $message"

  # Add to log file without color
  echo "${timestamp} [INFO] $message" >> "$logfile"
}

warn() {
  local logfile="logs/$(date +%F).log"
  local timestamp="[$(date '+%T')]"
  local message="$*"

  echo -e "${YELLOW}${timestamp} [WARN]${RESET} $message"
  echo "${timestamp} [WARN] $message" >> "$logfile"
}

error() {
  local logfile="logs/$(date +%F).log"
  local timestamp="[$(date '+%T')]"
  local message="$*"

  echo -e "${RED}${timestamp} [ERROR]${RESET} $message"
  echo "${timestamp} [ERROR] $message" >> "logfile"
}
