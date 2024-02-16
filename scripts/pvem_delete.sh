# Function: _pvem_delete
# Summary: Delete a virtual environment
# Parameters:
#   $1: Name of the virtual environment to delete
# Return: 0 if the virtual environment was deleted, 1 otherwise
_pvem_delete() {
    if [ -z "$1" ]; then
        printf "${C_RED}Error: Missing arguments for 'delete' function.\n"
        printf "${C_RESET}\n"
        printf "Usage: pvem delete ${C_BLUE}<name>\n"
        printf "  ${C_BLUE}<name>${C_RESET}              The name of the virtual environment to delete.\n"
        return 1
    fi

    env_name=$1

    if ! __pvem_check_env_exists "$env_name"; then
        printf "${C_RED}Error: Virtual envirorment $env_name does not exist\n"
        printf "${C_RESET}Use ${C_BLUE}pvem list${C_RESET} to see all available virtual envirorments\n"
        return 1
    fi

    rm -rf "$ENVPATH/$env_name"
    printf "${C_GREEN}Virtual envirorment $env_name deleted\n"
    return 0
}
