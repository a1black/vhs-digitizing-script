# Checks path to video capturing device.
# Args:
#   $1      path to file
function validate_video_grabbing_device() {
    local path="$1"
    if [ -z "$path" ]; then
        echo "empty_video_input"
        return 1
    elif [ ! -c "$path" ]; then
        echo "invalid_video_input"
        return 1
    fi
    return 0
}

# Checks string for valid audio device identifier.
# Args:
#   $1      audio device string
function validate_audio_grabbing_device() {
    local device="$1"
    if [ -z "$device" ]; then
        return 0
    elif [[ ! "$device" =~ ^hw:[[:digit:]]+,0$ ]]; then
        echo "invalid_audio_input"
        return 1
    fi
    local number=$(echo "$device" | grep -oP '(?<=^hw:)\d+')
    if [ ! -f "/sys/class/sound/card$number/id" ]; then
        echo "invalid_audio_input"
        return 1
    fi
    return 0
}

# Checks path for writing encoded stream.
# Args:
#   $1      path to file
function validate_output_file_name() {
    if [ -z "$1" ];then
        echo "empty_output_file"
        return 1
    fi
    local path=$(realpath "$1" 2> /dev/null)
    if [[ -z "$path" || -d "$path" ]]; then
        echo "invalid_output_file"
        return 1
    elif [[ -e "$path" && ! -w "$path" ]]; then
        echo "notwritable_output_file"
        return 1
    elif [ ! -w $(dirname "$path") ]; then
        echo "notwritable_output_file"
        return 1
    fi
    return 0
}

# Checks timestamp string for corrent syntax.
# Args:
#   $1      timestamp string
function validate_timestamp() {
    if [ -z "$1" ]; then
        return 0
    fi
    local timestamp="$1"
    echo "$timestamp" | grep -qE '^(([0-9]+:)?[0-5]?[0-9]:[0-5]?[0-9]|[0-9]+)$'
    if [ $? -ne 0 ]; then
        echo "invalid_timestamp"
        return 1
    fi
    return 0
}

# Checks name of recording standard.
# Args:
#   $1      standard name
function validate_standard_name() {
    if [ -z "$1" ]; then
        return 0
    fi
    local standard="$1"
    echo "$standard" | grep -qiE '^auto|PAL|NTSC$'
    if [ $? -ne 0 ]; then
        echo "invalid_standard"
        return 1
    fi
    return 0
}

# Checks existence of a file.
# Args:
#   $1      file path
function validate_file_exists() {
    local path="$1"
    if [ -z "$path" ]; then
        echo "empty_file_path"
        return 1
    elif [ ! -f "$path" ]; then
        echo "nonexisting_file"
        return 1
    elif [ ! -r "$path" ]; then
        echo "notreadable_file"
        return 1
    fi
    return 0
}
