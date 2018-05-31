#!/usr/bin/env bash

show_usage() {
    cat << EOF
$(basename $0) [OPTIONS]
Capture and encode VHS video and audio streams.

OPTIONS:
    -o      output file name
    -v      video input (/dev/video*)
    -a      audio input (hw:*,0)
    -t      recording duration ([HH:]MM:SS)
    -s      standard PAL or NTSC
    -l      language code (default: en)
EOF
    exit 0
}

# Global values.
A1_GLOBAL_VIDEO_API=v4l2
A1_GLOBAL_AUDIO_API=alsa
A1_GLOBAL_VIDEO_CODEC=h264
A1_GLOBAL_AUDIO_CODEC=aac
A1_GLOBAL_PIXEL_FMT=yuv420p
# Default values.
tape_standard=auto
# Read script arguments.
while getopts ':ho:v:a:t:s:l:' OPTION; do
    case "$OPTION" in
        o) output_file="$OPTARG";;
        v) video_input="$OPTARG";;
        a) audio_input="$OPTARG";;
        t) stop_time="$OPTARG";;
        s) tape_standard="$OPTARG";;
        l) language="$OPTARG";;
        *) show_usage;;
    esac
done

# Current directory.
source="$(realpath "${BASH_SOURCE[0]}" 2> /dev/null)"
current_dir="${source%/*}"
[[ -z "$current_dir" || ! -d "$current_dir" ]] && current_dir="$PWD"
# Include general functions.
source "$current_dir/scripts/helper.sh"
source "$current_dir/scripts/message.sh"
source "$current_dir/scripts/validator.sh"

if ! cmd_exists "ffmpeg"; then
    # Check dependencies.
    print_msg "ffmpeg_missing" "$language"
    exit 1
elif [ $UID -eq 0 ]; then
    # Check execution privilages.
    print_msg "root_exec" "$language"
    exit 1
fi

# Validate script arguments.
declare -a validation_errors
validation_errors+=($(validate_output_file_name "$output_file"))
validation_errors+=($(validate_video_grabbing_device "$video_input"))
validation_errors+=($(validate_audio_grabbing_device "$audio_input"))
validation_errors+=($(validate_timestamp "$stop_time"))
validation_errors+=($(validate_standard_name "$tape_standard"))
if [ ${#validation_errors[@]} -ne 0 ]; then
    for verror in ${validation_errors[@]}; do
        print_msg "$verror" "$language"
    done
    exit 1
fi
unset validation_errors

# Form part of video input options.
# Args:
#   $1      video device
get_video_input_options() {
    local input="$1"
    local api=${A1_GLOBAL_VIDEO_API:-}
    local cmd_part=''
    if [ -n "$input" ]; then
        [ -n "$api" ] && cmd_part+="-f $api "
        cmd_part+="-thread_queue_size 512 -i $input"
    fi
    printf -- "$cmd_part"
}
# Form part of audio input options.
# Args:
#   $1      audio device
get_audio_input_options() {
    local input="$1"
    local api=${A1_GLOBAL_AUDIO_API:-}
    local cmd_part=''
    if [ -n "$input" ]; then
        [ -n "$api" ] && cmd_part+="-f $api "
        cmd_part+="-thread_queue_size 512 -i $input"
    fi
    printf -- "$cmd_part"
}
# Form part of video output options.
# Args:
#   $1      video device
get_video_output_options() {
    local input="$1"
    local color=${A1_GLOBAL_PIXEL_FMT:-}
    local codec=${A1_GLOBAL_VIDEO_CODEC:-}
    local cmd_part=''
    if [ -n "$input" ]; then
        [ -n "$color" ] && cmd_part+=" -pix_fmt $color"
        [ -n "$codec" ] && cmd_part+=" -c:v $codec"
        [ "$codec" = h264 ] && cmd_part+=" -preset veryfast -crf=25"
    fi
    printf -- "$cmd_part"
}
# Form part of audio output options.
# Args:
#   $1      audio device
get_audio_output_options() {
    local input="$1"
    local codec=${A1_GLOBAL_AUDIO_CODEC:-}
    local cmd_part=''
    if [ -n "$input" ]; then
        [ -n "$codec" ] && cmd_part+=" -c:a $codec"
    fi
    printf -- "$cmd_part"
}
# Form part of encode options for specifiec signal standard.
# Args:
#   $1      signal standard
#   $2      video device
get_standard_output_options() {
    local video="$2"
    local standard="$1"
    local cmd_part=''
    if [[ -n "$video" && -n "$standard" ]]; then
        [ "${standard^^}" = PAL ] && cmd_part+=" -s 720x576 -r 25 -aspect 4:3"
        [ "${standard^^}" = NTSC ] && cmd_part+=" -s 720x580 -r 29.97 -aspect 4:3"
    fi
    printf -- "$cmd_part"
}
# Assemble ffmpeg command.
ffmpeg_command=$(printf -- "ffmpeg -loglevel 16 %s %s %s %s %s -t %s -y '%s'" \
    "$(get_video_input_options "$video_input")" \
    "$(get_audio_input_options "$audio_input")" \
    "$(get_video_output_options "$video_input")" \
    "$(get_standard_output_options "$tape_standard" "$video_input")" \
    "$(get_audio_output_options "$audio_input")" \
    "$stop_time" \
    "$output_file" \
)

echo "$ffmpeg_command"
bash -c "$ffmpeg_command"
