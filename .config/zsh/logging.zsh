# Define color codes
autoload -U colors && colors

LOG_TIME_FORMAT="%Y-%m-%d %H:%M:%S"
LOG_FILE="${LOG_FILE:-/tmp/zsh_script.log}"

log_timestamp() {
  date "+${LOG_TIME_FORMAT}"
}

log_raw() {
  local level="$1"
  local message="$2"
  local timestamp="$(log_timestamp)"
  printf "%s [%s] %s\n" "$timestamp" "$level" "$message" | tee -a "$LOG_FILE"
}

log_info() {
  local msg="$*"
  print -P "%F{blue}[INFO]%f $msg"
  log_raw "INFO" "$msg"
}

log_success() {
  local msg="$*"
  print -P "%F{green}[SUCCESS]%f $msg"
  log_raw "SUCCESS" "$msg"
}

log_warn() {
  local msg="$*"
  print -P "%F{yellow}[WARNING]%f $msg"
  log_raw "WARNING" "$msg"
}

log_error() {
  local msg="$*"
  print -P "%F{red}[ERROR]%f $msg" >&2
  log_raw "ERROR" "$msg"
}

log_fatal() {
  local msg="$*"
  print -P "%F{red}[FATAL]%f $msg" >&2
  log_raw "FATAL" "$msg"
  exit 1
}

log_debug() {
  [[ "$LOG_DEBUG" == "1" ]] && {
    local msg="$*"
    print -P "%F{cyan}[DEBUG]%f $msg"
    log_raw "DEBUG" "$msg"
  }
}