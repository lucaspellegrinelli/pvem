#!/usr/bin/env bash

# If PVEM_PATH is not set, set it to ~/.pvem
if [ -z "$PVEM_PATH" ]; then
    PVEM_PATH="$HOME/.pvem"
fi

# If the directory does not exist, raise an error
if ! [ -d "$PVEM_PATH" ]; then
    echo "Error: PVEM_PATH is not set to a valid directory"
    return 1
fi

ENVPATH="$PVEM_PATH/envs"
VERSIONPATH="$PVEM_PATH/versions"

# If the envs directory does not exist, create it
if ! [ -d "$ENVPATH" ]; then
    mkdir -p "$ENVPATH"
fi

# If the versions directory does not exist, create it
if ! [ -d "$VERSIONPATH" ]; then
    mkdir -p "$VERSIONPATH"
fi

. "$PVEM_PATH"/scripts/utils.sh

# Source completions
if [ -n "$ZSH_VERSION" ]; then
    . "$PVEM_PATH/completions/zsh"
elif [ -n "$BASH_VERSION" ]; then
    . "$PVEM_PATH/completions/bash"
fi

# Function: pvem
# Summary: Main function for pvem
# Parameters:
#   $1: Function to call
#   $2 ~ $n: Arguments for the function
pvem() {
    if [ -z "$1" ]; then
        _pvem_help
        return 1
    fi

    case "$1" in
        "new")
            . "$PVEM_PATH"/scripts/pvem_new.sh
            _pvem_new "$2" "$3"
            ;;
        "install")
            . "$PVEM_PATH"/scripts/pvem_install.sh
            _pvem_install "$2"
            ;;
        "use")
            . "$PVEM_PATH"/scripts/pvem_use.sh
            _pvem_use "$2"
            ;;
        "delete")
            . "$PVEM_PATH"/scripts/pvem_delete.sh
            _pvem_delete "$2"
            ;;
        "uninstall")
            . "$PVEM_PATH"/scripts/pvem_uninstall.sh
            _pvem_uninstall "$2"
            ;;
        "list")
            . "$PVEM_PATH"/scripts/pvem_list.sh
            _pvem_list
            ;;
        "versions")
            . "$PVEM_PATH"/scripts/pvem_versions.sh
            _pvem_versions
            ;;
        "help")
            _pvem_help
            ;;
        *)
            _pvem_help
            return 1
            ;;
    esac

    printf "%b" "$C_RESET"
}

# Function: _pvem_help
# Summary: Show help message for pvem
# Parameters: None
_pvem_help() {
    echo "Usage: pvem <function> [arguments]"
    echo ""
    echo "Functions:"
    __pvem_print_command "new" "<name> <python version>" "Create a new virtual environment with the specified name and Python version."
    __pvem_print_command "install" "<python version>" "Install the specified Python version."
    __pvem_print_command "use" "<name>" "Activate the virtual environment with the specified name."
    __pvem_print_command "delete" "<name>" "Delete the virtual environment with the specified name."
    __pvem_print_command "uninstall" "<python version>" "Uninstall the specified Python version."
    __pvem_print_command "list" "" "List all available virtual environments."
    __pvem_print_command "versions" "" "List all installed Python versions."
    __pvem_print_command "help" "" "Show this help message."
    echo ""
    echo "Examples:"
    __pvem_print_example "pvem install 3.9" "Install Python 3.9."
    __pvem_print_example "pvem new myenv 3.9" "Create a new virtual environment named 'myenv' with Python 3.9."
    __pvem_print_example "pvem use myenv" "Activate the 'myenv' virtual environment."
    __pvem_print_example "pvem delete myenv" "Delete the 'myenv' virtual environment."
}

# Function: __pvem_print_command
# Summary: Print a command with its description
# Parameters:
#  $1: Command name
#  $2: Command arguments
#  $3: Command description
__pvem_print_command() {
    printf "  %b%-10s%b %-25s %s\n" "$C_BLUE" "$1" "$C_RESET" "$2" "$3"
}

# Function: __pvem_print_example
# Summary: Print an example with its description
# Parameters:
#   $1: Example
#   $2: Example description
__pvem_print_example() {
    printf "  %b%-36s%b %s\n" "$C_GREEN" "$1" "$C_RESET" "$2"
}
