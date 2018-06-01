#!/usr/bin/env bash
# Interactive launcher for other scripts in project.

set -u

# Global values.
A1_GLOBAL_SAVE_PATH=
# Defined variables.
root_dir=
language=en

# Read script options.
while getopts ":l:d:" OPTION; do
    case "$OPTION" in
        d) root_dir="$OPTARG";;
        l) language="$OPTARG";;
        *) exit 1
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

# Validate script arguments.
if [ -n "$root_dir" ]; then
    root_dir="$(realpath "$root_dir" 2> /dev/null)"
    if [[ -z "$root_dir" || ! -d "$root_dir" || ! -w "$root_dir" || ! -r "$root_dir" ]]; then
        get_msg "invalid_root_dir" "$language"
        exit 1
    fi
    A1_GLOBAL_SAVE_PATH="$root_dir"
fi

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
    exit 0
elif [ "$action" = 'record' ]; then
    source "$current_dir/scripts/dialog_convert.sh"
elif [ "$action" = 'trim' ]; then
    source "$current_dir/scripts/dialog_truncate.sh"
else
    print_msg "unkhown_option" "$language"
    exit 1
fi
