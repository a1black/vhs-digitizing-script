#!/usr/bin/env bash

set -u

# Defined variables.
video_input=
output_file=
start_timestamp=
end_timestamp=
language=en
replace_file=0

# Help message.
show_usage() {
    cat << EOF
$(basename $0) [OPTIONS]
Truncate video file at the beginning and/or the end.

OPTIONS:
    -i      path to file
    -o      path to truncated file
    -s      start timestamp
    -e      end timestamp
    -l      language code (default: en)
EOF
    exit 0
}

# Read script arguments.
while getopts ':hi:o:s:e:l:' OPTION; do
    case "$OPTION" in
        i) video_input="$OPTARG";;
        o) output_file="$OPTARG";;
        s) start_timestamp="$OPTARG";;
        e) end_timestamp="$OPTARG";;
        l) language="$OPTARG";;
        *) show_usage;;
    esac
done

# Current directory.
source="$(realpath "${BASH_SOURCE[0]}" 2> /dev/null)"
current_dir="${source%/*}"
[[ -z "$current_dir" || ! -d "$current_dir" ]] && current_dir="$PWD"
# Include general functions.
source "$current_dir/scripts/helper.sh" || exit 1
source "$current_dir/scripts/message.sh" || exit 1
source "$current_dir/scripts/validator.sh" || exit 1

if ! cmd_exists "ffmpeg"; then
    # Check dependencies.
    print_msg "ffmpeg_missing" "$language"
    exit 1
elif [ $UID -eq 0 ]; then
    # Check execution privilages.
    print_msg "root_exec" "$language"
    exit 1
fi

# Check output file name.
if [ -z "$output_file" ] || [[ "$video_input" -ef "$output_file" ]]; then
    output_file=$(echo "$video_input" | sed -E 's/\.[a-z0-9]{3,4}$/.new\0/')
    replace_file=1
fi

# Validate script arguments.
declare -a validation_errors
validation_errors+=($(validate_file_exists "$video_input"))
validation_errors+=($(validate_output_file_name "$output_file"))
validation_errors+=($(validate_timestamp "$start_timestamp"))
validation_errors+=($(validate_timestamp "$end_timestamp"))
if [ ${#validation_errors[@]} -ne 0 ]; then
    for verror in ${validation_errors[@]}; do
        print_msg "$verror" "$language"
    done
    exit 1
fi
unset validation_errors verror
if [[ -z "$start_timestamp" && -z "$end_timestamp" ]]; then
    exit 0
fi

get_start_time_option() {
    [ -n "$1" ] && printf -- " -ss %s" "$1"
}
get_end_time_option() {
    [ -n "$1" ] && printf -- " -to %s" "$1"
}

# Assemle and execute ffmpeg command.
ffmpeg_command=$(printf -- "ffmpeg -loglevel 8 %s -i %s -c:v copy -c:a copy -async 1 %s -y %s" \
    "$(get_start_time_option "$start_timestamp")" \
    "$(printf %q "$video_input")" \
    "$(get_end_time_option "$end_timestamp")" \
    "$(printf %q "$output_file")" \
)

printf "\n%s\n" "$(get_msg "truncate_started" "$language")"
echo "$ffmpeg_command"
bash -c "$ffmpeg_command"
# Move files if required.
if [[ $? -eq 0 && "$replace_file" -eq 1 && -f "$output_file" ]]; then
    mv "$video_input" "$video_input.old"
    mv "$output_file" "$video_input"
fi
