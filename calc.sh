#!/bin/bash
log_error() {
    echo "$1" >> "$log_file"
    echo "$1" >&2
}
calculate() {
    local operation=$1
    shift
    local numbers=("$@")
    local result
    case $operation in
        sum)
            result=0
            for num in "${numbers[@]}"; do
                result=$((result + num))
            done
            ;;
        sub)
            result=${numbers[0]}
            for ((i=1; i<${#numbers[@]}; i++)); do
                result=$((result - numbers[i]))
            done
            ;;
        mul)
            result=1
            for num in "${numbers[@]}"; do
                result=$((result * num))
            done
            ;;
        div)
            result=${numbers[0]}
            for ((i=1; i<${#numbers[@]}; i++)); do
                if [ "${numbers[i]}" -eq 0 ]; then
                    log_error "Ошибка: деление на ноль"
                    exit 1
                fi
                result=$((result / numbers[i]))
            done
            ;;
        pow)
            result=$((numbers[0] ** numbers[1]))
            ;;
    esac
    echo "Результат: $result"
}
while getopts ":o:n:l:" opt; do
    case $opt in
        o) operation=$OPTARG ;;
        n) numbers_str=$OPTARG ;;
        l) log_file=$OPTARG ;;
        \?) echo "Неверный ключ: -$OPTARG" >&2; exit 1 ;;
        :) echo "Ключ -$OPTARG требует аргумента" >&2; exit 1 ;;
    esac
done
IFS=' ' read -ra numbers <<< "$numbers_str"
calculate "$operation" "${numbers[@]}"
