# Updated / upgraded version of Root_PW_Update.sh
#!/usr/bin/env bash

set -euo pipefail

# Resolve core dir and load framework utilities (which source settings + colors)
SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
CORE_DIR="$(cd -- "$SCRIPT_DIR/../../core" && pwd)"

source "$CORE_DIR/utils.sh"

DRY_RUN=false
FORCE=false
DATE_TODAY="$(date +%F)"
DATE_VALUE="$DATE_TODAY"

usage() {
  cat <<EOF
Usage: $(basename "$0") [options]

Options:
  -n, --dry-run          Show what would happen, but don't change anything
  -f, --force            Skip confirmation even if PROMPT_BEFORE_ACTIONS=true
      --date YYYY-MM-DD  Set explicit date instead of today
  -h, --help             Show this help
EOF
}

# Parse args
while (( "$#" )); do
  case "$1" in
    -n|--dry-run) DRY_RUN=true; shift ;;
    -f|--force)   FORCE=true; shift ;;
    --date)       DATE_VALUE="${2:-}"; shift 2 ;;
    -h|--help)    usage; exit 0 ;;
    --)           shift; break ;;
    -*)           error "Unknown option: $1"; usage; exit 2 ;;
    *)            error "Unexpected argument: $1"; usage; exit 2 ;;
  esac
done

# Helpers
confirm_action_if_needed() {
  if "$FORCE"; then return 0; fi
  if [[ "${PROMPT_BEFORE_ACTIONS:-true}" == "true" ]]; then
    read -rp "Set root's last password change date to '$DATE_VALUE'? (y/n): " reply
    [[ "$reply" =~ ^[Yy]$ ]] || { warn "Aborted by user."; exit 1; }
  fi
}

do_or_echo() {
  log "CMD: $*"
  if "$DRY_RUN"; then
    return 0
  else
    "$@"
  fi
}

validate_date() {
  # Basic ISO date sanity check (YYYY-MM-DD)
  if [[ ! "$DATE_VALUE" =~ ^[0-9]{4}-[0-9]{2}-[0-9]{2}$ ]]; then
    error "Invalid date format: '$DATE_VALUE' (expected YYYY-MM-DD)"
    exit 2
  fi
}

preflight() {
  mkdir -p logs
  command -v chage >/dev/null || { error "'chage' not found"; exit 127; }

  # Resolve elevate command (from settings.conf), default to dzdo if unset
  ELEVATE="${ELEVATE_CMD:-dzdo}"
  if ! command -v "$ELEVATE" >/dev/null; then
    warn "Elevate command '$ELEVATE' not found; attempting without elevation (may fail)."
    ELEVATE=""  # Let command run without elevation and fail if needed
  fi
}

run() {
  log "Changing root password last-change date to ${BOLD}$DATE_VALUE${RESET}"
  if [[ -n "${ELEVATE:-}" ]]; then
    do_or_echo "$ELEVATE" chage -d "$DATE_VALUE" root
  else
    do_or_echo chage -d "$DATE_VALUE" root
  fi

  log "Verifying last password change date..."
  sleep 1
  if [[ -n "${ELEVATE:-}" ]]; then
    LAST_LINE="$("$ELEVATE" chage -l root | grep -i '^Last password change')"
  else
    LAST_LINE="$(chage -l root | grep -i '^Last password change')"
  fi

  echo
  if [[ -n "$LAST_LINE" ]]; then
    echo -e "${GREEN}${LAST_LINE}${RESET}"
  else
    warn "Could not read verification line from 'chage -l root'."
  fi

  echo
  log "If today's date (${DATE_TODAY}) is reflected (or the date you provided), you're good to go."
}

# Flow
validate_date
preflight
confirm_action_if_needed
run
