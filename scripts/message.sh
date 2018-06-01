# Arrays of message used in main script.
declare -A en_msg ru_msg

# English messages.
## Convert Errors
en_msg[root_exec]="Error: script was started with root privilages."
en_msg[ffmpeg_missing]="Error: package 'ffmpeg' is missing."
en_msg[empty_video_input]="Error: input video device is not specified."
en_msg[invalid_video_input]="Error: cannot open provided video device."
en_msg[empty_audio_input]="Error: input audio device is not specified."
en_msg[invalid_audio_input]="Error: cannot open provided audio device."
en_msg[empty_output_file]="Error: output file is not specified."
en_msg[invalid_output_file]="Error: invalid file path."
en_msg[notwritable_output_file]="Error: provided path is not writable."
en_msg[empty_timestamp]="Error: stop timestamp is not specified."
en_msg[invalid_timestamp]="Error: invalid value of stop timestamp, correct syntax is HH:MM:SS."
en_msg[empty_standard]="Error: video signal standard is not specified."
en_msg[invalid_standard]="Error: unknown video signal standard."
## Truncate Errors
en_msg[nonexisting_file]="Error: provided file does not exist."
en_msg[notreadable_file]="Error: cannot read file."
en_msg[invalid_time_slice]="Error: invalid time slice."
## Launch dialog options
en_msg[select_launch_option]="Select lanch option: "
en_msg[select_video_input]="Select video capturing device: "
en_msg[select_audio_input]="Select audio capturing device: "
en_msg[select_output_name]="Name for saving captured input: "
en_msg[select_tape_standard]="Select VHS video standard: "
en_msg[select_stop_time]="Set capture stop time: "
en_msg[shutdown_on_complete]="Shutdown on completion [y/n] "
en_msg[select_video_file]="Select video file: "
en_msg[select_start_time]="Set cut mark at the beginning, leave empty to skip: "
en_msg[select_end_time]="Set cut mark at the end, leave empty to skip: "
en_msg[output_save_path]="Save as ... "
en_msg[capture_launch_confirmation]="Hit play on VHS player and press Enter to start recording. Or press 'q' to exit."
en_msg[capture_started]="Capturing process was successfully started."
en_msg[truncate_launch_confirmation]="Please press Enter to confirm truncate operation, or press 'q' to exit: "
## Actions
en_msg[record_action]="Start script for captuting video stream."
en_msg[record]="Capture video"
en_msg[trim]="Truncate video"
en_msg[quiet]="Quiet"

# Russian translations.
ru_msg[root_exec]="Ошибка: скрипт был запущен с административными правами."
ru_msg[ffmpeg_missing]="Ошибка: фреймворк 'ffmpeg' не найден."
ru_msg[empty_video_input]="Ошибка: необходимо указать путь до видео устройства."
ru_msg[invalid_video_input]="Ошибка: некорректный путь до видео устройства."
ru_msg[empty_audio_input]="Ошибка: необходимо указать аудио устройство."
ru_msg[invalid_audio_input]="Ошибка: некорректный идентификатор аудио устройства."
ru_msg[empty_output_file]="Ошибка: необходимо указать файл для сохранения видео потока."
ru_msg[invalid_output_file]="Ошибка: некорректный путь до файла сохранения."
ru_msg[notwritable_output_file]="Ошибка: указанный путь недоступен для записи."
ru_msg[empty_timestamp]="Ошибка: необходимо указать продолжительность записи."
ru_msg[invalid_timestamp]="Ошибка: некорректное значение время записи, укажите ЧЧ:ММ:СС."
ru_msg[empty_standard]="Ошибка: неуказан стандарт видео сигнала."
ru_msg[invalid_standard]="Ошибка: неизвестный стандарт видео сигнала."
## Truncate Errors
ru_msg[nonexisting_file]="Ошибка: указанный файл не найден."
ru_msg[notreadable_file]="Ошибка: файл не доступен для чтения."
ru_msg[invalid_time_slice]="Ошибка: некорректный отрезок времени."
## Launcher dialog options
ru_msg[select_launch_option]="Выбирете опцию для запуска: "
ru_msg[select_video_input]="Выбирете устройство для записи видео: "
ru_msg[select_audio_input]="Выбирете устройство для записи аудио: "
ru_msg[select_output_name]="Укажите имя файла для сохранения видео: "
ru_msg[select_tape_standard]="Укажите стандарт кодирования видео записи: "
ru_msg[select_stop_time]="Указите продолжительность записи: "
ru_msg[shutdown_on_complete]="Выключить компьютер по завершению [y/n] "
ru_msg[select_video_file]="Выбирете видео файл: "
ru_msg[select_start_time]="Время обрезки в начале видео (оставте пустым, чтобы пропустить): "
ru_msg[select_end_time]="Время обрезки в конце видео (оставте пустым, чтобы пропустить): "
ru_msg[output_save_path]="Файл будет сохранен как ... "
ru_msg[capture_launch_confirmation]="Начните воспроизведение кассеты и нажмите Enter для старта записи. Или нажмите 'q' для выхода: "
ru_msg[capture_started]="Процесс записи был успешно запущен!"
ru_msg[truncate_launch_confirmation]="Нажмите Enter для подтверждения или 'q' для выхода: "
## Actions
ru_msg[record_action]="Запуск скрипта записи видео."
ru_msg[truncate_action]="Запуск скрипта обрезки видео."
ru_msg[record]="Запись видео"
ru_msg[trim]="Обрезать видео"
ru_msg[quiet]="Выход"

# Returns message by its identifier.
# Args:
#   $1      message identifier
#   $2      language identifier (en is default)
function get_msg() {
    local id="$1" lang="$2"
    [ -z "$id" ] && return 1
    [ -z "$lang" ] && lang="$A1_GLOBAL_LANG"
    if [ "$lang" = ru ]; then
        [[ -v ru_msg["$id"] ]] && echo -n "${ru_msg["$id"]}"
    else
        [[ -v en_msg["$id"] ]] && echo -n "${en_msg["$id"]}"
    fi
    return 0
}

# Same as `get_msg` but adds NL to the end of message.
function print_msg() {
    get_msg "$1" "$2"
    [ $? -eq 0 ] && printf "\n"
}
