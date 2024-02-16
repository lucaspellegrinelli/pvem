# Function: _pvem_uninstall
# Summary: Uninstall a python version
# Parameters:
#   $1: Python version to uninstall
# Return: 0 if the python version was uninstalled, 1 otherwise
_pvem_uninstall() {
    if [ -z "$1" ]; then
        printf "${C_RED}Error: Missing arguments for 'uninstall' function.\n"
        printf "${C_RESET}\n"
        printf "Usage: pvem uninstall ${C_BLUE}<python version>\n"
        printf "  ${C_BLUE}<python version>${C_RESET}    The version of Python to uninstall.\n"
        return 1
    fi

    python_version=$1

    if ! __pvem_check_version_could_be_valid "$python_version"; then
        printf "${C_RED}Error: Python version $python_version is not a valid version\n"
        return 1
    fi

    version=$(__pvem_find_best_matching_installed_version "$python_version")

    if [ -z "$version" ]; then
        printf "${C_RED}Error: Python version $python_version is not installed\n"
        printf "${C_RESET}Use ${C_BLUE}pvem versions${C_RESET} to see all installed versions\n"
        return 1
    fi

    python_version=$version

    if ! __pvem_check_version_installed "$python_version"; then
        printf "${C_RED}Error: Python version $python_version is not installed\n"
        printf "${C_RESET}Use ${C_BLUE}pvem versions${C_RESET} to see all installed versions\n"
        return 1
    fi

    if __pvem_check_version_is_used "$python_version"; then
        printf "${C_YELLOW}Warning: Python version $python_version is used by one or more virtual envirorments\n"
        printf "${C_RESET}Are you sure you want to uninstall it? (y/N)\n"
        read -r CONFIRM
        if [ "$CONFIRM" != "y" ]; then
            printf "${C_RED}Uninstall aborted\n"
            return 1
        fi
    fi

    rm -rf "$VERSIONPATH/$python_version"
    printf "${C_GREEN}Python version $python_version uninstalled\n"
    return 0
}
