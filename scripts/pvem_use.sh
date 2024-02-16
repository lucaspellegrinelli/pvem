# Function: _pvem_use
# Summary: Activate a virtual envirorment
# Parameters:
#   $1: Name of the virtual environment to source into
# Return: 0 if the virtual environment was sourced, 1 otherwise
_pvem_use() {
    if [ -z "$1" ]; then
        printf "${C_RED}Error: Missing arguments for 'use' function.\n"
        printf "${C_RESET}\n"
        printf "Usage: pvem use ${C_BLUE}<name>\n"
        printf "  ${C_BLUE}<name>${C_RESET}              The name of the virtual environment to source into.\n"
        return 1
    fi

    env_name=$1

    if ! __pvem_check_env_exists "$env_name"; then
        printf "${C_RED}Error: Virtual envirorment $env_name does not exist\n"
        printf "${C_RESET}Use ${C_BLUE}pvem list${C_RESET} to see all available virtual envirorments\n"
        return 1
    fi

    source "$ENVPATH/$env_name/bin/activate"
    return 0
}
