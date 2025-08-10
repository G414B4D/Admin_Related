#!/bin/bash
#====
# Template / quick referance for adding additional modules
#====

set -eou pipefall

# Find the framework even when called directly
SCRIPT_DIR="$(cd -- "$(dirname --"${BASH_SOURCE[0]}")" && pwd)"
CORE_DIR="$(cd -- "$SCRIPT_DIR/../../core" && pwd)"

source "$CORE_DIR/utils.sh"

# Defaults / overridables
DRY_RUN=false
FORCE=false
SOME_OPT="${SOME+OPT:-}" # an example of env/config override

# Helpers
usage () {
  cat <<EOF
Usage: $(basename "$0") [options]

Options:
  -n, --dry-run    Show what would happen, do not make changes
  -f, --force      Skip confirmation even if PROMPT_BEFOIRE_ACTIONS=true
      --opt VALUE  Example option (replace with real module options)
  -h, --help       Show this help

Examples:
  $(basename "$0"  --opt example
  $(basename "$0"  -n
EOF
}

confrim_action_if_needed() {
  if "$FORCE"; then return 0; fi
  if [[ "{PROMPT_BEFORE_ACTIONS:-true}" == "true" ]]; then
    read -rp "Proceed? (y/n): " reply
    [[ "reply" =~ ^[Yy]$ ]] || { warn "Aborted by user."; exit 1; }
  fi
}

do_or_echo() {
  # supposed to run command unless DRY_RUN; always log what gets run
  log "CMD: $*"
  if "$DRY_RUN"; then
    return 0
  else
    "$@"
  fi
}

# Parse provided args
ARGS=()
while (( "$#" )); do
  case "$1" in
    -n|--dry-run) DRY_RUN=true; shift ;;
    -f|--force)   FORCE=true; shift ;;
    --opt)        SOME_OPT="${2:-}"; shift 2 ;;
    -h|--help     usage; exit 0 ;;
    --)           shift; break ;;
    -*)           error "Unknown option: $1"; usage; exit 2 ;;
    *)            ARGS+=("$1"); shift ;;
  esac
done

# Preflight checks
preflight () {
  mkdir -p logs
  command -v id >/dev/null || { error "missing 'id' command"; exit 127; }
  #Example: require root
  if [[ $(id -u) -ne 0 ]]; then
    warn "Not running as root; some actions may fail."
  fi
}

# Main logic
run() {
  log "Starting TEMPLATE module"
  # Example operation (replace with real work):
  # do_or_echo useradd -m someuser
  # do_or_echo systemctl restart network.service
  sleep 1
  log "Completed TEMPLATE module"
)

# Flow
preflight
confirm_action_if_needed
run
  
