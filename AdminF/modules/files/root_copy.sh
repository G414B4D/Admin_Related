# Upgraded version of root_copy.sh more aligned with AdminF
#!/usr/bin/env bash

set -euo pipefail

# Resolve core dir and load framework utilities (which source settings + colors)
SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
CORE_DIR="$(cd -- "$SCRIPT_DIR/../../core" && pwd)"
# shellcheck source=/dev/null
source "$CORE_DIR/utils.sh"

# -------------------------
# Defaults (overridable via CLI)
# -------------------------
USER_ARG="${USER_ARG:-}"
HOST_ARG="${HOST_ARG:-}"
SRC_ARG="${SRC_ARG:-}"
DEST_ARG="${DEST_ARG:-}"

SSH_PORT="${SSH_PORT:-22}"
SSH_IDENTITY="${SSH_IDENTITY:-}"   # e.g., ~/.ssh/id_ed25519
BWLIMIT="${BWLIMIT:-}"             # KB/s, e.g., 5000
SHOW_PROGRESS=false
DRY_RUN=false
FORCE=false

# Elevation for remote rsync (from config), default to dzdo if unset
ELEVATE="${ELEVATE_CMD:-dzdo}"

usage() {
  cat <<EOF
Usage: $(basename "$0") [options]

Options:
  --user USER            SSH username (if omitted, you'll be prompted)
  --host HOST            Remote host (name or IP)
  --src  PATH            Remote source path (file or dir)
  --dest PATH            Local destination directory
  --port N               SSH port (default: 22)
  --identity PATH        SSH identity (private key) to use
  --bwlimit KBPS         Limit rsync bandwidth (in KB/s)
  --progress             Show rsync progress
  -n, --dry-run          Show what would happen, do not copy
  -f, --force            Skip confirmation even if PROMPT_BEFORE_ACTIONS=true
  -h, --help             Show this help

Examples:
  $(basename "$0") --user alice --host srv01 --src /var/log/secure --dest ./downloads
  $(basename "$0") --user alice --host srv01 --src '/root/reports/*.txt' --dest ./reports --progress
  $(basename "$0") --user alice --host srv01 --src /etc --dest ./etc_backup --bwlimit 8000 -n
EOF
}

# -------------------------
# Parse args
# -------------------------
while (( "$#" )); do
  case "$1" in
    --user)      USER_ARG="${2:-}"; shift 2 ;;
    --host)      HOST_ARG="${2:-}"; shift 2 ;;
    --src)       SRC_ARG="${2:-}"; shift 2 ;;
    --dest)      DEST_ARG="${2:-}"; shift 2 ;;
    --port)      SSH_PORT="${2:-}"; shift 2 ;;
    --identity)  SSH_IDENTITY="${2:-}"; shift 2 ;;
    --bwlimit)   BWLIMIT="${2:-}"; shift 2 ;;
    --progress)  SHOW_PROGRESS=true; shift ;;
    -n|--dry-run) DRY_RUN=true; shift ;;
    -f|--force)  FORCE=true; shift ;;
    -h|--help)   usage; exit 0 ;;
    --)          shift; break ;;
    -*)          error "Unknown option: $1"; usage; exit 2 ;;
    *)           error "Unexpected arg: $1"; usage; exit 2 ;;
  esac
done

# -------------------------
# Helpers
# -------------------------
prompt_if_missing() {
  [[ -n "$USER_ARG" ]] || read -rp "Enter your username: " USER_ARG
  [[ -n "$HOST_ARG" ]] || read -rp "Enter host to copy from: " HOST_ARG
  [[ -n "$SRC_ARG"  ]] || read -rp "Enter full remote path to copy: " SRC_ARG
  [[ -n "$DEST_ARG" ]] || read -rp "Enter local destination directory: " DEST_ARG
}

confirm_action_if_needed() {
  if "$FORCE"; then return 0; fi
  if [[ "${PROMPT_BEFORE_ACTIONS:-true}" == "true" ]]; then
    echo
    echo -e "${BOLD}About to run rsync from:${RESET}"
    echo "  ${USER_ARG}@${HOST_ARG}:${SRC_ARG}"
    echo "to:"
    echo "  ${DEST_ARG}"
    echo
    read -rp "Proceed? (y/n): " reply
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

preflight() {
  mkdir -p logs
  command -v rsync >/dev/null || { error "'rsync' not found locally"; exit 127; }
  command -v ssh   >/dev/null || { error "'ssh' not found locally"; exit 127; }

  # Build SSH options
  SSH_OPTS=(-p "$SSH_PORT" -o BatchMode=yes -o StrictHostKeyChecking=accept-new)
  [[ -n "$SSH_IDENTITY" ]] && SSH_OPTS+=(-i "$SSH_IDENTITY")

  # Verify remote rsync exists (non-fatal if ELEVATE handles PATH, but we try)
  if ! ssh "${SSH_OPTS[@]}" "${USER_ARG}@${HOST_ARG}" 'command -v rsync' >/dev/null 2>&1; then
    warn "Remote 'rsync' not found in default PATH; will try elevated path via '${ELEVATE:-<none>}'"
  fi

  # Resolve elevate command
  if [[ -n "$ELEVATE" ]] && ! ssh "${SSH_OPTS[@]}" "${USER_ARG}@${HOST_ARG}" "command -v $ELEVATE" >/dev/null 2>&1; then
    warn "Elevation command '$ELEVATE' not found remotely; proceeding without elevation (may fail if permissions require it)."
    ELEVATE=""
  fi

  # Destination sanity
  mkdir -p -- "$DEST_ARG"
}

build_rsync_cmd() {
  local remote_spec="${USER_ARG}@${HOST_ARG}:${SRC_ARG}"

  # rsync base flags:
  # -a  : archive (preserve perms/times/links)
  # -v  : verbose
  # -s  : handle spaces in filenames (protect-args)
  local RSYNC_FLAGS=(-a -v -s)
  "$SHOW_PROGRESS" && RSYNC_FLAGS+=(--info=progress2)
  [[ -n "$BWLIMIT" ]] && RSYNC_FLAGS+=(--bwlimit "$BWLIMIT")

  # Remote rsync path (elevated if configured)
  local RPATH="rsync"
  [[ -n "$ELEVATE" ]] && RPATH="$ELEVATE rsync"

  # Compose final command
  RSYNC_CMD=(rsync "${RSYNC_FLAGS[@]}"
             --rsync-path="$RPATH"
             -e "ssh ${SSH_OPTS[*]}"
             -- "$remote_spec" "$DEST_ARG")
}

run() {
  build_rsync_cmd
  echo
  log "Starting transfer from ${BOLD}${USER_ARG}@${HOST_ARG}:${SRC_ARG}${RESET} to ${BOLD}${DEST_ARG}${RESET}"
  do_or_echo "${RSYNC_CMD[@]}"
  echo
  log "If there were no errors above, your file(s) copied successfully."
}

# -------------------------
# Flow
# -------------------------
prompt_if_missing
preflight
confirm_action_if_needed
run
