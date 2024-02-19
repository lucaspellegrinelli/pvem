#!/usr/bin/env bash

# Function: _pvem_list
# Summary: List all available virtual envirorments
# Return: 0 if the virtual envirorments were listed, 1 otherwise
_pvem_list() {
    if ! [ -d "$ENVPATH" ]; then
        return 1
    fi

    local all_versions_ok=1
    printf "%-20s %-10s\n" "ENVIRONMENT" "VERSION"

    local env version
    for env_path in "$ENVPATH"/*; do

        if ! [ -d "$env_path" ]; then
            continue
        fi

        env=$(basename "$env_path")

        if ! [ -f "$ENVPATH/$env/pyvenv.cfg" ]; then
            continue
        fi

        version=$(__pvem_get_env_python_version "$env")

        if __pvem_check_version_installed "$version"; then
            printf "%b%-20s %b%s\n" "$C_BLUE" "$env" "$C_GREEN" "$version"
        else
            printf "%b%-20s %b%s*\n" "$C_BLUE" "$env" "$C_RED" "$version"
            all_versions_ok=0
        fi
    done

    if [ $all_versions_ok -eq 0 ]; then
        printf "%b\n" "$C_RED"
        printf "Not all envirorments have their Python version installed. These will not work.%b\n" "$C_RESET"
        printf "Use 'pvem versions' to see all installed versions\n"
    fi

    return 0
}