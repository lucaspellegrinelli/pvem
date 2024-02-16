# Function: _pvem_list
# Summary: List all available virtual envirorments
# Return: 0 if the virtual envirorments were listed, 1 otherwise
_pvem_list() {
    if ! [ -d "$ENVPATH" ]; then
        return 1
    fi

    ALL_VERSIONS_OK=1
    printf "%-20s %-10s\n" "ENVIRONMENT" "VERSION"
    for env in $(ls "$ENVPATH"); do
        if ! [ -f "$ENVPATH/$env/pyvenv.cfg" ]; then
            continue
        fi

        version=$(__pvem_get_env_python_version "$env")

        if __pvem_check_version_installed "$version"; then
            printf "${C_BLUE}%-20s ${C_GREEN}%s\n" "$env" "$version"
        else
            printf "${C_BLUE}%-20s ${C_RED}%s*\n" "$env" "$version"
            ALL_VERSIONS_OK=0
        fi
    done

    if [ $ALL_VERSIONS_OK -eq 0 ]; then
        printf "${C_RED}\n"
        printf "Not all virtual envirorments have their Python version installed. These will not work.\n"
        printf "Use 'pvem versions' to see all installed versions\n"
    fi

    return 0
}
