#!/usr/bin/env bash

# Function: _pvem_versions
# Summary: List all installed python versions
# Return: 0 if the versions were listed, 1 otherwise
_pvem_versions() {
    if ! [ -d "$VERSIONPATH" ]; then
        return 1
    fi

    printf "INSTALLED VERSIONS\n"
    for version_path in "$VERSIONPATH"/*; do
        if ! [ -d "$version_path" ]; then
            continue
        fi

        if [[ "$version_path" == *tmp ]]; then
            continue
        fi

        version=$(basename "$version_path")
        printf "%b%s\n" "${C_BLUE}" "${version}"
    done

    return 0
}
