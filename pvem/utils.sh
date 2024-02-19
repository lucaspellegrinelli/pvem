#!/usr/bin/env bash

# Text color codes
export C_RESET="\033[0m"
export C_RED="\033[1;31m"
export C_GREEN="\033[1;32m"
export C_YELLOW="\033[1;33m"
export C_BLUE="\033[1;36m"

# Function: __pvem_print_command_args_error
# Summary: Prints an error message when a command is called with incorrect arguments.
# Parameters:
#   $1: Name of the command
#   $2,3...k: Argument names (should be half the total number of arguments)
#   $k+1, k+2...n: Corresponding argument descriptions
__pvem_print_command_args_error() {
    local command_name=$1
    shift

    if (( $# % 2 != 0 )); then
        echo "Error: Incorrect usage of __pvem_print_command_args_error. Arguments and descriptions must be paired."
        return 1
    fi

    local -a args=("$@")
    local num_args=$((${#args[@]} / 2))

    printf "%bError: Missing or incorrect arguments for '%s' function.\n" "$C_RED" "$command_name"
    printf "%b\n" "$C_RESET"
    printf "Usage: pvem %s %b" "$command_name" "$C_BLUE"

    for ((i = 1; i <= num_args; i++)); do
        printf "%s " "${args[$i]}"
    done

    printf "%b\n" "$C_RESET"

    for ((i = 1; i <= num_args; i++)); do
        printf "  %b%-30s%b %s\n" "$C_BLUE" "${args[$i]}" "$C_RESET" "${args[$i + num_args]}"
    done
}

# Function: __pvem_output_to_single_line
# Summary: Print the live output of a command to a single line
# Example:
#  ping -c 25 google.com | __pvem_output_to_single_line
__pvem_output_to_single_line() {
    local max_width
    max_width=$(tput cols)

    local target_width=$((max_width - 10))
    if [ $target_width -gt 120 ]; then
        target_width=120
    fi

    local half_width
    half_width=$((target_width / 2 - 2))

    while read -r line; do
        if [ ${#line} -gt $target_width ]; then
            echo -ne "\r\033[K${line:0:$half_width}...${line: -$half_width}"
        else
            echo -ne "\r\033[K$line"
        fi
    done

    echo -ne "\r\033[K"
}

# Function: __pvem_check_version_could_be_valid
# Summary: Check if a python version could be valid (X, X.X, X.X.X)
# Parameters:
#   $1: Python version to check
# Return: 0 if the python version could be valid, 1 otherwise
__pvem_check_version_could_be_valid() {
    local python_version=$1

    if ! [[ "$python_version" =~ ^[0-9]+(\.[0-9]+){0,2}$ ]]; then
        return 1
    fi

    return 0
}

# Function: __pvem_check_env_exists
# Summary: Check if a virtual envirorment exists
# Parameters:
#  $1: Name of the virtual environment to check
# Return: 0 if the virtual environment exists, 1 otherwise
__pvem_check_env_exists() {
    local env_name=$1

    if [ -d "$ENVPATH/$env_name" ]; then
        return 0
    fi

    return 1
}

# Function: __pvem_check_version_installed
# Summary: Check if a python version is installed
# Parameters:
#   $1: Python version to check
# Return: 0 if the python version is installed, 1 otherwise
__pvem_check_version_installed() {
    local python_version=$1

    if [ -d "$VERSIONPATH/$python_version" ]; then
        return 0
    fi

    return 1
}

# Function: __pvem_find_best_matching_installed_version
# Summary: Find the best matching installed python version for a given version
#          Ex: 3.9 -> 3.9.7 or 3.9.6 -> 3.9.6
# Parameters:
#  $1: Python version to check
# Return: The best matching installed python version
__pvem_find_best_matching_installed_version() {
    local python_version=$1
    local version_list=""

    for version in "$VERSIONPATH"/*; do
        if ! [ -d "$version" ]; then
            continue
        fi

        version=$(basename "$version")
        version_list="$version_list $version"
    done

    echo "$version_list" | tr " " "\n" | grep -E "^${python_version}([^0-9]|$)" | sort -V | tail -n 1
}
