#!/usr/bin/env bash

# Function: _pvem_list
# Summary: List all available virtual envirorments
# Return: 0 if the virtual envirorments were listed, 1 otherwise
_pvem_list() {
    if ! [ -d "$ENVPATH" ]; then
        return 1
    fi

    ALL_VERSIONS_OK=1
    printf "%-20s %-10s\n" "ENVIRONMENT" "VERSION"
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
            ALL_VERSIONS_OK=0
        fi
    done

    if [ $ALL_VERSIONS_OK -eq 0 ]; then
        printf "%b\n" "$C_RED"
        printf "Not all virtual envirorments have their Python version installed. These will not work.\n"
        printf "Use 'pvem versions' to see all installed versions\n"
    fi

    return 0
}
