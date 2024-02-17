#!/usr/bin/env bash

# Function: _pvem_delete
# Summary: Delete a virtual environment
# Parameters:
#   $1: Name of the virtual environment to delete
# Return: 0 if the virtual environment was deleted, 1 otherwise
_pvem_delete() {
    if [ -z "$1" ]; then
        printf "%bError: Missing arguments for 'delete' function.\n" "${C_RED}"
        printf "%b\n" "${C_RESET}"
        printf "Usage: pvem delete %b<name>\n" "${C_BLUE}"
        printf "  %b<name>%b              The name of the virtual environment to delete.\n" "${C_BLUE}" "${C_RESET}"
        return 1
    fi

    env_name=$1

    if ! __pvem_check_env_exists "$env_name"; then
        printf "%bError: Virtual environment %s does not exist\n" "${C_RED}" "$env_name"
        printf "%bUse %b%s%b to see all available virtual environments\n" "${C_RESET}" "${C_BLUE}" "pvem list" "${C_RESET}"
        return 1
    fi

    rm -rf "${ENVPATH:?}/$env_name"
    printf "%bVirtual environment %s deleted\n" "${C_GREEN}" "$env_name"
    return 0
}
