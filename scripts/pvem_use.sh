#!/usr/bin/env bash

# Function: _pvem_use
# Summary: Activate a virtual envirorment
# Parameters:
#   $1: Name of the virtual environment to source into
# Return: 0 if the virtual environment was sourced, 1 otherwise
_pvem_use() {
    if [ -z "$1" ]; then
        printf "%bError: Missing arguments for 'use' function.\n" "$C_RED"
        printf "%b\n" "$C_RESET"
        printf "Usage: pvem use %b<name>\n" "$C_BLUE"
        printf "  %b<name>%b              The name of the virtual environment to source into.\n" "$C_BLUE" "$C_RESET"
        return 1
    fi

    env_name=$1

    if ! __pvem_check_env_exists "$env_name"; then
        printf "%bError: Virtual environment %s does not exist\n" "$C_RED" "$env_name"
        printf "%bUse %b%s%b to see all available virtual environments\n" "$C_RESET" "$C_BLUE" "pvem list" "$C_RESET"
        return 1
    fi

    . "$ENVPATH/$env_name/bin/activate"
    return 0
}
