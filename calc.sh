#!/bin/bash

usage() {
    echo "Использование: $0 -o <операция> -n \"<числа>\" -l <log_file>" >&2
    echo "Доступные операции: sum, sub, mul, div, pow" >&2
    exit 1
}

log_error() {
    local message="$1"
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $message" >> "$log_file"
    echo "$message" >&2
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
            if [ ${#numbers[@]} -ne 2 ]; then
                log_error "Ошибка: для pow требуется ровно 2 числа"
                exit 1
            fi
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
        \?) log_error "Неверный ключ: -$OPTARG"; usage ;;
        :) log_error "Ключ -$OPTARG требует аргумента"; usage ;;
    esac
done

if [ -z "$operation" ] || [ -z "$numbers_str" ] || [ -z "$log_file" ]; then
    log_error "Не все обязательные аргументы указаны"
    usage
fi

case "$operation" in
    sum|sub|mul|div|pow) ;;
    *) log_error "Неверная операция: $operation. Допустимые: sum, sub, mul, div, pow"; exit 1 ;;
esac

IFS=' ' read -ra numbers <<< "$numbers_str"

if [ "$operation" == "pow" ]; then
    if [ ${#numbers[@]} -lt 1 ]; then
        log_error "Ошибка: для pow требуется минимум 1 число"
        exit 1
    fi
else
    if [ ${#numbers[@]} -lt 2 ]; then
        log_error "Ошибка: для $operation требуется минимум 2 числа"
        exit 1
    fi
fi

for num in "${numbers[@]}"; do
    if ! [[ "$num" =~ ^-?[0-9]+$ ]]; then
        log_error "Ошибка: '$num' не является целым числом"
        exit 1
    fi
done

calculate "$operation" "${numbers[@]}"
