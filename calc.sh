#!/bin/bash

log_error() {
    echo "$(date) - $1" >> "$log_file"
    echo "$1" >&2
}
calculate() {
    case $1 in
        sum)   result=0; for num in "${@:2}"; do ((result += num)); done ;;
        sub)   result=$2; for num in "${@:3}"; do ((result -= num)); done ;;
        mul)   result=1; for num in "${@:2}"; do ((result *= num)); done ;;
        div)   result=$2
               for num in "${@:3}"; do
                   ((num == 0)) && { log_error "Ошибка: деление на ноль"; exit 1; }
                   ((result /= num))
               done ;;
        pow)   ((result = $2 ** 2)) ;;
        *)     log_error "Неверная операция: $1"; exit 1 ;;
    esac
    echo "Результат: $result"
}
while getopts ":o:n:l:" opt; do
    case $opt in
        o) operation=$OPTARG ;;
        n) IFS=' ' read -ra numbers <<< "$OPTARG" ;;
        l) log_file=$OPTARG ;;
        \?) log_error "Неверный ключ: -$OPTARG"; exit 1 ;;
        :) log_error "Ключ -$OPTARG требует аргумента"; exit 1 ;;
    esac
done
calculate "$operation" "${numbers[@]}"