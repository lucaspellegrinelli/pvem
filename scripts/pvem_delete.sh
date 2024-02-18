#!/usr/bin/env bash

# Function: _pvem_delete
# Summary: Delete a virtual environment
# Parameters:
#   $1: Name of the virtual environment to delete
# Return: 0 if the virtual environment was deleted, 1 otherwise
_pvem_delete() {
    if [ -z "$1" ]; then
        __pvem_print_command_args_error "delete" "name" \
            "The name of the virtual environment to delete."
        return 1
    fi

    local env_name=$1

    if ! __pvem_check_env_exists "$env_name"; then
        printf "%bError: Virtual environment %s does not exist\n" "$C_RED" "$env_name"
        printf "%bUse %b%s%b to see all available virtual environments\n" "$C_RESET" "$C_BLUE" "pvem list" "$C_RESET"
        return 1
    fi

    rm -rf "${ENVPATH:?}/$env_name"
    printf "Virtual environment %b%s%b successfully deleted\n" "$C_GREEN" "$env_name" "$C_RESET"
    return 0
}
