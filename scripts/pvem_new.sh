#!/usr/bin/env bash

# Function: _pvem_new
# Summary: Create a new virtual envirorment
# Parameters:
#   $1: Name of the virtual environment to create
#   $2: Python version to use 
# Return: 0 if the virtual environment was created, 1 otherwise
_pvem_new() {
    if [ -z "$1" ] || [ -z "$2" ]; then
        printf "%bError: Missing arguments for 'new' function.\n" "$C_RED"
        printf "%b\n" "$C_RESET"
        printf "Usage: pvem new %b<name> <python version>\n" "$C_BLUE"
        printf "  %b<name>%b              The name of the virtual environment to create.\n" "$C_BLUE" "$C_RESET"
        printf "  %b<python version>%b    The version of Python to use in the virtual environment.\n" "$C_BLUE" "$C_RESET"
        return 1
    fi

    env_name=$1
    python_version=$2

    if ! __pvem_check_version_could_be_valid "$python_version"; then
        printf "%bError: Python version %s is not a valid version\n" "$C_RED" "$python_version"
        return 1
    fi

    version=$(__pvem_find_best_matching_installed_version "$python_version")

    if [ -z "$version" ]; then
        printf "%bError: Python version %s is not installed. Install it with pvem install %s\n" "$C_RED" "$python_version" "$python_version"
        return 1
    fi

    python_version=$version

    if __pvem_check_env_exists "$env_name"; then
        printf "%bError: Virtual envirorment %s already exists\n" "$C_RED" "$env_name"
        return 1
    fi

    "$VERSIONPATH/$python_version/bin/python3" -m venv "$ENVPATH/$env_name"
    printf "Virtual envirorment %b%s%b successfully created\n" "$C_GREEN" "$env_name" "$C_RESET"
    return 0
}
