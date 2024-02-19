#!/usr/bin/env bash

# Function: _pvem_uninstall
# Summary: Uninstall a python version
# Parameters:
#   $1: Python version to uninstall
# Return: 0 if the python version was uninstalled, 1 otherwise
_pvem_uninstall() {
    if [ -z "$1" ]; then
        __pvem_print_command_args_error "uninstall" "version" \
            "The version of Python to uninstall."
        return 1
    fi

    local python_version=$1

    if ! __pvem_check_version_could_be_valid "$python_version"; then
        printf "%bError:%b Python version %b%s%b is not a valid version\n" "$C_RED" "$C_RESET" "$C_BLUE" "$python_version" "$C_RESET"
        return 1
    fi

    local version
    version=$(__pvem_find_best_matching_installed_version "$python_version")

    if [ -z "$version" ]; then
        printf "%bError:%b Python version %b%s%b is not installed\n" "$C_RED" "$C_RESET" "$C_BLUE" "$python_version" "$C_RESET"
        printf "%bUse %b%s%b to see all installed versions\n" "$C_RESET" "$C_BLUE" "pvem versions" "$C_RESET"
        return 1
    fi

    local python_version=$version

    if ! __pvem_check_version_installed "$python_version"; then
        printf "%bError:%b Python version %b%s%b is not installed\n" "$C_RED" "$C_RESET" "$C_BLUE" "$python_version" "$C_RESET"
        printf "%bUse %b%s%b to see all installed versions\n" "$C_RESET" "$C_BLUE" "pvem versions" "$C_RESET"
        return 1
    fi

    if __pvem_check_version_is_used "$python_version"; then
        printf "%bWarning: Python version %s is used by one or more virtual envirorments\n" "$C_YELLOW" "$python_version"
        printf "%bAre you sure you want to uninstall it? (y/N) " "$C_RESET"
        read -r CONFIRM
        if [ "$CONFIRM" != "y" ]; then
            printf "%bUninstall aborted\n" "$C_RED"
            return 1
        fi
    fi

    rm -rf "${VERSIONPATH:?}/$python_version"
    printf "Python version %b%s%b successfully uninstalled\n" "$C_GREEN" "$python_version" "$C_RESET"
    return 0
}

# Function: __pvem_check_version_is_used
# Summary: Check if a python version is used by a virtual envirorment
# Parameters:
#  $1: Python version to check
# Return: 0 if the python version is used, 1 otherwise
__pvem_check_version_is_used() {
    local python_version=$1
    local version

    python_version=$(__pvem_find_best_matching_installed_version "$python_version")

    for env in "$ENVPATH"/*; do
        if ! [ -d "$env" ]; then
            continue
        fi

        if [ -f "$env/pyvenv.cfg" ]; then
            version=$(__pvem_get_env_python_version "$(basename "$env")")
            if [ "$version" = "$python_version" ]; then
                return 0
            fi
        fi
    done

    return 1
}
