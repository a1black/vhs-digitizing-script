#!/usr/bin/env bash
# Interactive launcher for other scripts in project.

# Read script options.
while getopts ":l:" OPTION; do
    case "$OPTION" in
        l) language="$OPTARG";;
        *) exit 1
    esac
done

# Current directory.
source="$(realpath "${BASH_SOURCE[0]}" 2> /dev/null)"
current_dir="${source%/*}"
[[ -z "$current_dir" || ! -d "$current_dir" ]] && current_dir="$PWD"
# Include general functions.
source "$current_dir/scripts/message.sh"

if ! cmd_exists "ffmpeg"; then
    # Check dependencies.
    print_msg "ffmpeg_missing" "$language"
    exit 1
elif [ $UID -eq 0 ]; then
    # Check execution privilages.
    print_msg "root_exec" "$language"
    exit 1
fi

# Global values.
A1_GLOBAL_SAVE_PATH=$(realpath ~/Videos 2> /dev/null)

# Terminates script execution.
launch_quiet() {
    exit 0
}
# Configures and runs vhs convertion script.
launch_record() {
    source "$current_dir/scripts/dialog_convert.sh"
}
# Configures and runs video truncating script.
launch_truncate() {
    source "$current_dir/scripts/dialog_truncate.sh"
}
# Requests user to select thouther action.
dialog_launch_option() {
    local option label=''
    declare -g action=quiet
    declare -A options
    options[1]='record'
    options[2]='trim'
    options[q]='quiet'
    print_msg "select_launch_option" "$language"
    for option in ${!options[@]}; do
        printf "%s) %s\n" $option "$(get_msg "${options[$option]}" "$language")"
        label+="$option/"
    done
    label="${label:0:-1}: "
    while read -p "$label" option; do
       if [[ -v options["$option"] ]]; then
           action=${options[$option]}
           return 0
        fi
    done
}

# Select luanch option.
dialog_launch_option
if [ "$action" = 'quiet' ]; then
    launch_quiet
elif [ "$action" = 'record' ]; then
    launch_record
elif [ "$action" = 'trim' ]; then
    launch_truncate
else
    print_msg "unkhown_option" "$language"
    exit 1
fi
