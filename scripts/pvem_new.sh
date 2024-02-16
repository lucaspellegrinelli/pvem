# Function: _pvem_new
# Summary: Create a new virtual envirorment
# Parameters:
#   $1: Name of the virtual environment to create
#   $2: Python version to use 
# Return: 0 if the virtual environment was created, 1 otherwise
_pvem_new() {
    if [ -z "$1" ] || [ -z "$2" ]; then
        printf "${C_RED}Error: Missing arguments for 'new' function.\n"
        printf "${C_RESET}\n"
        printf "Usage: pvem new ${C_BLUE}<name> <python version>\n"
        printf "  ${C_BLUE}<name>${C_RESET}              The name of the virtual environment to create.\n"
        printf "  ${C_BLUE}<python version>${C_RESET}    The version of Python to use in the virtual environment.\n"
        return 1
    fi

    env_name=$1
    python_version=$2

    if ! __pvem_check_version_could_be_valid "$python_version"; then
        printf "${C_RED}Error: Python version $python_version is not a valid version\n"
        return 1
    fi

    version=$(__pvem_find_best_matching_installed_version "$python_version")

    if [ -z "$version" ]; then
        printf "${C_RED}Error: Python version $python_version is not installed. Install it with pvem install $python_version\n"
        return 1
    fi

    python_version=$version

    if __pvem_check_env_exists "$env_name"; then
        echo "${C_RED}Error: Virtual envirorment $env_name already exists\n"
        return 1
    fi

    "$VERSIONPATH/$python_version/bin/python3" -m venv "$ENVPATH/$env_name"
    printf "${C_GREEN}Virtual envirorment $env_name created\n"
    return 0
}
