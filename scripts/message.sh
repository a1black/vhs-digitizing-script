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
en_msg[invalid_timestamp]="Error: invalid value of stop timestamp."
en_msg[empty_standard]="Error: video signal standard is not specified."
en_msg[invalid_standard]="Error: unknown video signal standard."
## Truncate Errors
en_msg[nonexisting_file]="Error: provided file does not exist."
en_msg[notreadable_file]="Error: cannot read file."

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
ru_msg[invalid_timestamp]="Ошибка: некорректное значение время записи."
ru_msg[empty_standard]="Ошибка: неуказан стандарт видео сигнала."
ru_msg[invalid_standard]="Ошибка: неизвестный стандарт видео сигнала."
ru_msg[nonexisting_file]="Ошибка: указанный файл не найден."
ru_msg[notreadable_file]="Ошибка: файл не доступен для чтения."

# Returns message by its identifier.
# Args:
#   $1      message identifier
#   $2      language identifier (en is default)
function get_msg() {
    local id="$1" lang="$2"
    [ -z "$id" ] && return 1
    [ -z "$lang" ] && lang="$A1_GLOBAL_LANG"
    if [ "$lang" = ru ]; then
        [[ -n ${ru_msg[$id]} || -z ${ru_msg[$id]+foo} ]] && echo ${ru_msg[$id]}
    else
        [[ -n ${en_msg[$id]} || -z ${en_msg[$id]+foo} ]] && echo ${en_msg[$id]}
    fi
    return 0
}
