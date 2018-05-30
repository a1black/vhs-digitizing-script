# Checks if provided command is accessible.
# Args:
#   $1      command name
function cmd_exists() {
    type "$1" &> /dev/null
}
