# Helper functions.
# Varifies timestamp value as empty.
# Args:
#   $1      timestamp
function is_timestamp_empty() {
    echo "$1" | grep -qE '^(\s*|0+)$'
}

# Trunclate HH:MM:SS timestamp into seconds.
# Args:
#   $1      timestamp
function timestamp_to_secconds() {
    local timestamp="$1"
    if [[ "$timestamp" =~ ^[[:digit:]]+$ ]]; then
        echo "$timestamp"
    elif [[ "$timestamp" =~ ^([[:digit:]]+):([[:digit:]]+)$ ]]; then
        echo $((${BASH_REMATCH[1]} * 60 + ${BASH_REMATCH[2]}))
    elif [[ "$timestamp" =~ ^([[:digit:]]+):([[:digit:]]+):([[:digit:]]+)$ ]]; then
        echo $((${BASH_REMATCH[1]} * 3600 + ${BASH_REMATCH[2]} * 60 + ${BASH_REMATCH[3]}))
    else
        return 1
    fi
    return 0
}

# Requests user to set cut mark at the beginning of file.
dialog_start_timestamp() {
    local tmp_time
    declare -g start_timestamp
    printf "\n"
    while read -p "$(get_msg "select_start_time" "$language")" tmp_time; do
        if is_timestamp_empty "$tmp_time"; then
            start_timestamp=''
            return 0
        elif validate_timestamp "$tmp_time" &> /dev/null; then
            start_timestamp="$tmp_time"
            return 0
        else
            print_msg "invalid_timestamp" "$language"
            printf "\n"
        fi
    done
}

# requests user to set cut mark at the end of file.
dialog_end_timestamp() {
    local tmp_time tmp_end_sec
    local tmp_start_sec=$(timestamp_to_secconds "$start_timestamp")
    declare -g end_timestamp
    printf "\n"
    while read -p "$(get_msg "select_end_time" "$language")" tmp_time; do
        if is_timestamp_empty "$tmp_time"; then
            end_timestamp=''
            return 0
        elif validate_timestamp "$tmp_time" &> /dev/null; then
            tmp_end_sec=$(timestamp_to_secconds "$tmp_time")
            if [[ -z "$tmp_start_sec" || -z "$tmp_end_sec" ]] || ((tmp_end_sec > tmp_start_sec)); then
                end_timestamp="$tmp_time"
                return 0
            else
                print_msg "invalid_time_slice" "$language"
                printf "\n"
            fi
        else
            print_msg "invalid_timestamp" "$language"
            printf "\n"
        fi
    done
}

# Requests user for video file to truncate.
dialog_video_input() {
    local tmp_file pwd_changed
    declare -g video_input
    printf "\n"
    if [[ -n "$A1_GLOBAL_SAVE_PATH" && -d "$A1_GLOBAL_SAVE_PATH" ]]; then
        cd "$A1_GLOBAL_SAVE_PATH" &> /dev/null
        pwd_changed=$?
    fi
    while read -e -p "$(get_msg "select_video_file" "$language")" tmp_file; do
        tmp_file="$(realpath "$tmp_file")"
        if [ -f "$tmp_file" ]; then
            video_input="$(printf %q "$tmp_file")"
            break
        fi
        print_msg "nonexisting_file" "$language"
        printf "\n"
    done
    if [ "$pwd_changed" = 0 ]; then
        cd - &> /dev/null
    fi
    return 0
}

# Execute all steps to prepare and start video truncate script.
main() {
    printf -- "\n-----\n"
    print_msg "truncate_action" "$language"
    printf -- "----\n"
    # Select file to truncate.
    dialog_video_input
    # Set cut mark at the begginning of video.
    dialog_start_timestamp
    # Set cut mark at the end of video.
    dialog_end_timestamp
    # Check if cut marks are set.
    if is_timestamp_empty "$start_timestamp" && is_timestamp_empty "$end_timestamp"; then
        printf "\n"
        print_msg "nothing_to_cut" "$language"
        exit 0
    fi
    # Confirm and launch truncate script.
    local yq
    printf "\n"
    get_msg "truncate_launch_confirmation" "$language"
    while read -sn 1 yq; do
        if [ "$yq" = "q" ]; then
            exit 0
        elif [ -z "$yq" ]; then
            printf "\n"
            break;
        fi
    done
    # Assemble truncate command.
    local cmd
    cmd="$(printf "%s -l %s -i %s" \
        "$current_dir/truncate.sh" \
        "${language:-en}" \
        "$video_input" \
    )"
    [ -n "$start_timestamp" ] && cmd+=" -s $start_timestamp"
    [ -n "$end_timestamp" ] && cmd+=" -e $end_timestamp"
    bash -c "$cmd"
}

main
