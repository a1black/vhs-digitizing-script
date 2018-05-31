# Checks if provided command is accessible.
# Args:
#   $1      command name
function cmd_exists() {
    type "$1" &> /dev/null
}

# Processes file name for saving captured video input.
# Args:
#   $1      file name
function process_output_filename() {
    local filename="$1"
    [ -z "$filename" ] && return 1
    if echo "$filename" | grep -qE '\.(mpg|mp4|mkv|avi)$'; then
        :
    else
        filename="${filename%.*}.mkv"
    fi
    echo "$filename" | tr " " "."
}

# Returns list of video streaming devices.
function get_video_devices() {
    local device_path dnum dname dproduct
    for device_path in /sys/class/video4linux/*; do
        device_path="$(realpath "$device_path" 2> /dev/null)"
        [ ! -e "$device_path" ] && continue;
        dnum=$(echo "$device_path" | grep -oE '[0-9]+$')
        dname=$(cat "$device_path/name" 2> /dev/null)
        while [ -n "$device_path" ]; do
            device_path="${device_path%/*}"
            if [ -f "$device_path/product" ]; then
                dproduct=$(cat "$device_path/product" 2> /dev/null)
                break
            fi
        done
        [ -z "$dproduct" ] && dproduct="$dname"
        printf "%s) %s\n" $dnum "$dproduct"
    done
}

# Returns list of audio steaming devices.
function get_audio_devices() {
    local device_path dnum dname
    for device_path in /sys/class/sound/card*; do
        device_path="$(realpath "$device_path" 2> /dev/null)"
        [ ! -e "$device_path" ] && continue
        dnum=$(echo "$device_path" | grep -oE '[0-9]+$')
        dname=$(cat "$device_path/id" 2> /dev/null)
        printf "%s) %s\n" $dnum "$dname"
    done
}

# Returns video device path by its number.
# Args:
#   $1      video device number
function get_video_device_by_num() {
    [ -z "$1" ] && return 1
    local device_path="/dev/video$1"
    [ ! -c "$device_path" ] && return 1
    echo "$device_path"
}

# Returns audio divice identifier by its number.
# Args:
#   $1      audio device number
function get_audio_device_by_num() {
    [ -z "$1" ] && return 1
    local device_id="hw:$1,0"
    [ ! -e "/sys/class/sound/card$1" ] && return 1
    echo "$device_id"
}

# Returns video device idVendor:idProduct by its number.
# Args:
#   $1      video device number
function get_vieo_vendorxproduct_by_num() {
    [ -z "$1" ] && return 1
    local device=$(realpath "/sys/class/video4linux/video$1" 2> /dev/null)
    [ ! -e "$device" ] && return 1
    while [ -n "$device" ]; do
        if [[ -f "$device/idVendor" && -f "$device/idProduct" ]]; then
            printf "%s:%s" $(cat "$device/idVendor" 2> /dev/null) $(cat "$device/idProduct" 2> /dev/null)
            return 0
        fi
        device="${device%/*}"
    done
    return 1
}

# Searchs audio device by idVendor:idProduct.
# Args:
#   $1      idVendor
#   $2      idProduct
function get_audio_device_by_vendorxproduct() {
    [[ -z "$1" || -z "$2" ]] && return 1
    local device dnum
    for device in /sys/class/sound/card*; do
        device=$(realpath "$device" 2> /dev/null)
        [ ! -e "$device" ] && continue
        dnum=$(echo "$device" | grep -oE '[0-9]+$')
        while [ -n "$device" ]; do
            if [[ -f "$device/idVendor" && -f "$device/idProduct" ]]; then
                if [[ "$1" = $(cat "$device/idVendor") && "$2" = $(cat "$device/idProduct") ]]; then
                    echo "$dnum"
                    return 0
                fi
            fi
            device="${device%/*}"
        done
    done
    return 1
}
