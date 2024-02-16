# Function: _pvem_versions
# Summary: List all installed python versions
# Return: 0 if the versions were listed, 1 otherwise
_pvem_versions() {
    if ! [ -d "$VERSIONPATH" ]; then
        return 1
    fi

    printf "INSTALLED VERSIONS\n"
    for version in $(ls "$VERSIONPATH"); do
        if [ "$version" = "tmp" ]; then
            continue
        fi

        printf "${C_BLUE}$version\n"
    done

    return 0
}
