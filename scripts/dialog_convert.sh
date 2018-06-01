# Requests user to select video capturing device.
dialog_video_input_list() {
    local device_list="$(get_video_devices)"
    printf "\n"
    print_msg "select_video_input" "$language"
    echo "$device_list"
    printf "q) %s\n" "$(get_msg "quiet" "$language")"
    local label=$(echo "$device_list" | cut -d ')' -f1 | tr "\n" "/")
    echo -n "${label}q: "
}
dialog_video_input() {
    local option
    declare -g video_input
    dialog_video_input_list
    while read option; do
        case "$option" in
            q) exit 0;;
            [0-9]*) if get_video_device_by_num $option &> /dev/null; then
                        video_input=$option
                        return 0
                    fi;;
        esac
        dialog_video_input_list
    done
}

# Requests user to select audio capturing device.
dialog_audio_input_list() {
    local device_list="$(get_audio_devices)"
    printf "\n"
    print_msg "select_audio_input" "$language"
    echo "$device_list"
    printf "q) %s\n" "$(get_msg "quiet" "$language")"
    local label=$(echo "$device_list" | cut -d ')' -f1 | tr "\n" "/")
    echo -n "${label}q: "
}
dialog_audio_input() {
    local option
    declare -g audio_input
    dialog_audio_input_list
    while read option; do
        case "$option" in
            q) exit 0;;
            [0-9]*) if get_audio_device_by_num $option &> /dev/null; then
                        audio_input=$option
                        return 0
                    fi;;
        esac
        dialog_audio_input_list
    done
}

# Requests user to enter file name for saving captured steams.
dialog_output_file() {
    local tmp_name pwd_changed
    declare -g output_file
    printf "\n"
    if [[ -n "$A1_GLOBAL_SAVE_PATH" && -d "$A1_GLOBAL_SAVE_PATH" ]]; then
        cd "$A1_GLOBAL_SAVE_PATH" &> /dev/null
        pwd_changed=$?
    fi
    while read -p "$(get_msg "select_output_name" "$language")" tmp_name; do
        if [ -z "$tmp_name" ]; then
            print_msg "empty_output_file" "$language"
            printf "\n"
            continue
        fi
        ! echo "$tmp_name" | grep -qE '\.[a-z0-9]{3,4}$' && tmp_name+=".mkv"
        tmp_name="$(realpath "$tmp_name" 2> /dev/null)"
        if [[ -z "$tmp_name" || -d "$tmp_name" ]]; then
            print_msg "invalid_output_file" "$language"
            printf "\n"
        else
            output_file="$tmp_name"
            break
        fi
    done
    if [ "$pwd_changed" = 0 ]; then
        cd - &> /dev/null
    fi
    printf "%s %s\n" "$(get_msg "output_save_path" "$language")" "$output_file"
    output_file=$(printf "%q" "$output_file")
    return 0
}

# Requests user to specify signal encoding standard.
dialog_tape_standard() {
    local option label=''
    declare -g tape_standard
    declare -A options
    options[0]=auto
    options[1]=PAL
    options[2]=NTSC
    printf "\n"
    print_msg "select_tape_standard" "$language"
    for option in ${!options[@]}; do
        printf "%s) %s\n" $option ${options[$option]}
        label+="$option/"
    done
    printf "q) %s\n" "$(get_msg "quiet" "$language")"
    label+="q: "
    while read -p "$label" option; do
        case "$option" in
            q) exit 0;;
            1) tape_standard=${options[1]}; return 0;;
            2) tape_standard=${options[2]}; return 0;;
            *) tape_standard=${options[0]}; return 0;;
        esac
    done
}

# Requests user for duration of video recording.
dialog_stop_time() {
    local tmp_time
    declare -g stop_time
    printf "\n"
    while read -p "$(get_msg "select_stop_time" "$language")" tmp_time; do
        if [ -z "$tmp_time" ]; then
            print_msg "empty_timestamp" "$language"
            printf "\n"
        elif validate_timestamp "$tmp_time" &> /dev/null; then
            stop_time="$tmp_time"
            return 0
        else
            print_msg "invalid_timestamp" "$language"
            printf "\n"
        fi
    done
}

# Requests user for system shutdown on task completion.
dialog_shutdown_on_complete() {
    local yn
    declare -g shutdown_on_complete=0
    printf "\n"
    get_msg "shutdown_on_complete" "$language"
    read -sn 1 yn
    case "$yn" in
        yY) shutdown_on_complete=1;;
    esac
    printf "\n"
}

# Execute all steps to prepare and start converting process.
main() {
    printf -- "\n-----\n"
    print_msg "record_action" "$language"
    printf -- "------\n"
    # Set video input.
    dialog_video_input
    local video_vendor_product=$(get_vieo_vendorxproduct_by_num "$video_input")
    local video_idvendor=$(echo "$video_vendor_product" | cut -d: -f1)
    local video_idproduct=$(echo "$video_vendor_product" | cut -d: -f2)
    # Set audio input.
    local tmp_audio_input=$(get_audio_device_by_vendorxproduct "$video_idvendor" "$video_idproduct")
    if [ -n "$tmp_audio_input" ]; then
        audio_input="$tmp_audio_input"
    else
        dialog_audio_input
    fi
    # Set VHS encoding standard.
    dialog_tape_standard
    # Set VHS record length.
    dialog_stop_time
    # Set filename for converted video.
    dialog_output_file
    dialog_shutdown_on_complete
    # Final preparetions.
    video_input=$(get_video_device_by_num "$video_input")
    audio_input=$(get_audio_device_by_num "$audio_input")
    # Confirm start.
    local yq
    printf "\n"
    get_msg "capture_launch_confirmation" "$language"
    while read -sn 1 yq; do
        if [ "$yq" = "q" ]; then
            exit 0
        elif [ -z "$yq" ]; then
            printf "\n"
            break;
        fi
    done
    bash -c "$current_dir/convert.sh -v $video_input -a $audio_input -o $output_file -t $stop_time -s $tape_standard -l ${language:-en}"
    [[ $? -eq 0 && "$shutdown_on_complete" -eq 1 ]] && shutdown -h
}

main
