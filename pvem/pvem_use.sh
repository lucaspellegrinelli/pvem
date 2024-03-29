#!/usr/bin/env bash

# Function: _pvem_use
# Summary: Activate a virtual envirorment
# Parameters:
#   $1: Name of the virtual environment to source into
# Return: 0 if the virtual environment was sourced, 1 otherwise
_pvem_use() {
    if [ -z "$1" ]; then
        __pvem_print_command_args_error "use" "name" \
            "The name of the virtual environment to source into."
        return 1
    fi

    local env_name=$1

    if ! __pvem_check_env_exists "$env_name"; then
        printf "%bError:%b Virtual environment %b%s%b does not exist\n" "$C_RED" "$C_RESET" "$C_BLUE" "$env_name" "$C_RESET"
        printf "%bUse %b%s%b to see all available virtual environments\n" "$C_RESET" "$C_BLUE" "pvem list" "$C_RESET"
        return 1
    fi

    . "$ENVPATH/$env_name/bin/activate"
    return 0
}
