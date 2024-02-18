#!/usr/bin/env bash

# Function: _pvem_uninstall
# Summary: Uninstall a python version
# Parameters:
#   $1: Python version to uninstall
# Return: 0 if the python version was uninstalled, 1 otherwise
_pvem_uninstall() {
    if [ -z "$1" ]; then
        printf "%bError: Missing arguments for 'uninstall' function.\n" "$C_RED"
        printf "%b\n" "$C_RESET"
        printf "Usage: pvem uninstall %b<python version>\n" "$C_BLUE"
        printf "  %b<python version>%b    The version of Python to uninstall.\n" "$C_BLUE" "$C_RESET"
        return 1
    fi

    python_version=$1

    if ! __pvem_check_version_could_be_valid "$python_version"; then
        printf "%bError: Python version %s is not a valid version\n" "$C_RED" "$python_version"
        return 1
    fi

    version=$(__pvem_find_best_matching_installed_version "$python_version")

    if [ -z "$version" ]; then
        printf "%bError: Python version %s is not installed\n" "$C_RED" "$python_version"
        printf "%bUse %b%s%b to see all installed versions\n" "$C_RESET" "$C_BLUE" "pvem versions" "$C_RESET"
        return 1
    fi

    python_version=$version

    if ! __pvem_check_version_installed "$python_version"; then
        printf "%bError: Python version %s is not installed\n" "$C_RED" "$python_version"
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
