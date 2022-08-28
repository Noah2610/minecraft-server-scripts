# vim: set syntax=sh filetype=sh :

# shellcheck source=./util.sh disable=SC2155
function _dl_util_sh {
    local UTIL_VERSION="v2.2.5"
    local dir="$( dirname "$1" )"
    [ -f "${dir}/util.sh" ] || bash "${dir}/download-util.sh" "$UTIL_VERSION" || exit 1
    source "${dir}/util.sh"
}; _dl_util_sh "$0"

exit

SCRIPT_NAME="$( basename "$0" )"

# Default config.env variables.
LOGFILE="${ROOT}/logs/${SCRIPT_NAME}.log"
WORLD_DIR="world"
TMUX_SESSION="mc-server"
SERVER_JAR="server.jar"
TMUX_WINDOW="game"
JAVA_ARGS=
BACKUP_DIR="${ROOT}/backup/$( date +"%Y%m%d-%H%M%S" )"
BACKUP_CHAT_MSG_START="Creating backup of world..."
BACKUP_CHAT_MSG_END="Backup complete."
BACKUP_CHAT_MSG_BACKING_UP="Backing-up ${WORLD_DIR} directory... (hopefully game has finished saving)"
BACKUP_SLEEP_AFTER_SAVE=3
RESOURCEPACK_ZIP=
RESOURCEPACK_TMUX_WINDOW="resourcepack"
RESOURCEPACK_PORT=25566

source "${ROOT}/config.env"

TMUX_PANE="${TMUX_SESSION}:${TMUX_WINDOW}.0"

logfile_dir="$( dirname "$LOGFILE" )"
[ -d "$logfile_dir" ] || mkdir -p "$logfile_dir"
unset logfile_dir

# Prints the current date to the logfile (and stdout).
function print_date {
    msg "--- $( date "+%F %T" ) ---"
}

# Returns 0 if the server is running.
function is_server_running {
    # TODO: Properly check if the actual java server app is running.
    tmux has-session -t $TMUX_SESSION &> /dev/null
}

# Runs the given command on the server, if it is running.
function server_cmd {
    is_server_running && \
        tmux send-keys -t "$TMUX_PANE" Enter "$1" Enter
            # Start command with an Enter press, to ensure nothing has been typed previously (hacky).
        }

# Write a message to the minecraft server by sending keystrokes to the correct tmux session/window/pane.
function print_chat {
    server_cmd "say ${1//$'\n'/$'\n'say }"
}

# Verify that some programs are available.
check tee
check tmux
check java
