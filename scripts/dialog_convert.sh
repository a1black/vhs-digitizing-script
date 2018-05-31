# Current directory.
dc_source="$(realpath "${BASH_SOURCE[0]}" 2> /dev/null)"
dc_current_dir="${dc_source%/*}"
[[ -z "$dc_current_dir" || ! -d "$dc_current_dir" ]] && dc_current_dir="$PWD"
# Include general functions.
source "$dc_current_dir/helper.sh"
source "$dc_current_dir/message.sh"
source "$dc_current_dir/validator.sh"

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
    local tmp_name
    declare -g output_file
    printf "\n"
    get_msg "select_output_name" "$language"
    read tmp_name
    output_file=$(process_output_filename "$tmp_name")
    [[ -n "$A1_GLOBAL_SAVE_PATH" && ${output_file:0:1} != '/' ]] && output_file="$A1_GLOBAL_SAVE_PATH/$output_file"
    get_msg "output_save_path" "$language"
    echo "$output_file"
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
        if validate_timestamp "$tmp_time" &> /dev/null; then
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

    video_input=$(get_video_device_by_num "$video_input")
    audio_input=$(get_audio_device_by_num "$audio_input")
    output_file=$(printf "%q" "$output_file")
    bash -c "$dc_current_dir/../convert.sh -v $video_input -a $audio_input -t $stop_time -o $output_file -s $tape_standard -l ${language:-en}"
    [ "$shutdown_on_complete" -eq 1 ] && shutdown -h
}

main
