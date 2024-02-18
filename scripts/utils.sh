#!/usr/bin/env bash

# Text color codes
export C_RESET="\033[0m"
export C_RED="\033[1;31m"
export C_GREEN="\033[1;32m"
export C_YELLOW="\033[1;33m"
export C_BLUE="\033[1;36m"

# Function: __pvem_print_command_args_error
# Summary: Print an error message when a command is called with the wrong arguments
# Parameters:
#   $1: Name of the command
#   $2,3...k: Argument names
#   $k+1, k+2...n: Argument descriptions
__pvem_print_command_args_error() {
    command_name=$1
    shift
    args=("$@")
    half=$((${#args[@]} / 2))

    printf "%bError: Missing arguments for '%s' function.\n" "$C_RED" "$command_name"
    printf "%b\n" "$C_RESET"
    printf "Usage: pvem %s %b" "$command_name" "$C_BLUE"

    for ((i = 1; i <= half; i++)); do
        printf "<%s> " "${args[$i]}"
    done

    printf "%b\n" "$C_RESET"

    for ((i = 1; i <= half; i++)); do
        printf "  %b%-20s%b %s\n" "$C_BLUE" "<${args[$i]}>" "$C_RESET" "${args[$i + ${half}]}"
    done
}

# Function: __pvem_output_to_single_line
# Summary: Print the live output of a command to a single line
# Example:
#  ping -c 25 google.com | __pvem_output_to_single_line
__pvem_output_to_single_line() {
    while read -r line; do
        if [ ${#line} -gt 120 ]; then
            echo -ne "\r\033[K${line:0:60}...${line: -60}"
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
    python_version=$1

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
    env_name=$1

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
    python_version=$1

    if [ -d "$VERSIONPATH/$python_version" ]; then
        return 0
    fi

    return 1
}

# Function: __pvem_get_env_python_version
# Summary: Get the python version of a virtual envirorment
# Parameters:
#  $1: Name of the virtual environment
# Return: The python version of the virtual environment
__pvem_get_env_python_version() {
    env_name=$1

    if ! __pvem_check_env_exists "$env_name"; then
        return 1
    fi

    version=$(grep -oE "version = [0-9]+\.[0-9]+\.[0-9]+" "$ENVPATH/$env_name/pyvenv.cfg" | cut -d " " -f 3)
    echo "$version"
}

# Function: __pvem_check_version_is_used
# Summary: Check if a python version is used by a virtual envirorment
# Parameters:
#  $1: Python version to check
# Return: 0 if the python version is used, 1 otherwise
__pvem_check_version_is_used() {
    python_version=$1

    for env in "$ENVPATH"/*; do
        if ! [ -d "$env" ]; then
            continue
        fi

        if [ -f "$ENVPATH/$env/pyvenv.cfg" ]; then
            version=$(__pvem_get_env_python_version "$env")
            if [ "$version" = "$python_version" ]; then
                return 0
            fi
        fi
    done

    return 1
}

# Function: __pvem_find_best_matching_installed_version
# Summary: Find the best matching installed python version for a given version
#          Ex: 3.9 -> 3.9.7 or 3.9.6 -> 3.9.6
# Parameters:
#  $1: Python version to check
# Return: The best matching installed python version
__pvem_find_best_matching_installed_version() {
    python_version=$1

    version_list=""
    for version in "$VERSIONPATH"/*; do
        if ! [ -d "$version" ]; then
            continue
        fi

        version=$(basename "$version")
        version_list="$version_list $version"
    done

    version=$(echo "$version_list" | tr " " "\n" | grep -E "^${python_version}(?:[^0-9]|$)" | sort -V | tail -n 1)
    echo "$version"
}
