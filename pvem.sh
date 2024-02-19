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

    . "$PVEM_PATH"/pvem/utils.sh

    local command="$1"
    shift

    local -a flags=()
    local -a args=()
    for arg in "$@"; do
        if [[ "$arg" == --* ]]; then
            flags+=("$arg")
        else
            args+=("$arg")
        fi
    done

    case "$command" in
        "new")
            . "$PVEM_PATH"/pvem/pvem_new.sh
            _pvem_new "$2" "$3"
            ;;
        "install")
            . "$PVEM_PATH"/pvem/pvem_install.sh
            local -a permitted_flags=("--enable-optimizations")
            local enable_optimizations=false
            local install_version="${args[1]}"

            for flag in "${flags[@]}"; do
                local flag_permitted=false
                for permitted_flag in "${permitted_flags[@]}"; do
                    if [ "$flag" = "$permitted_flag" ]; then
                        flag_permitted=true
                    fi
                done

                if [ "$flag_permitted" = false ]; then
                    printf "%bError:%b Flag %s is not permitted for this command\n" "$C_RED" "$C_RESET" "$flag"
                    printf "See '%bpvem help%b' for more information\n" "$C_BLUE" "$C_RESET"
                    return 1
                fi

                if [ "$flag" = "--enable-optimizations" ]; then
                    enable_optimizations=true
                fi
            done

            _pvem_install "$install_version" "$enable_optimizations"
            ;;
        "use")
            . "$PVEM_PATH"/pvem/pvem_use.sh
            local env_name="${args[1]}"
            _pvem_use "$env_name"
            ;;
        "delete")
            . "$PVEM_PATH"/pvem/pvem_delete.sh
            local env_name="${args[1]}"
            _pvem_delete "$env_name"
            ;;
        "uninstall")
            . "$PVEM_PATH"/pvem/pvem_uninstall.sh
            local uninstall_version="${args[1]}"
            _pvem_uninstall "$uninstall_version"
            ;;
        "list")
            . "$PVEM_PATH"/pvem/pvem_list.sh
            _pvem_list
            ;;
        "versions")
            . "$PVEM_PATH"/pvem/pvem_versions.sh
            _pvem_versions
            ;;
        "help"|"--help")
            _pvem_help
            ;;
        "-V"|"--version")
            _pvem_version
            ;;
        *)
            printf "%bError:%b Command %b%s%b not found\n" "$C_RED" "$C_RESET" "$C_BLUE" "$command" "$C_RESET"
            printf "See '%bpvem help%b' for more information\n" "$C_BLUE" "$C_RESET"
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
    __pvem_print_command "new" "<name> <version>" "Create a new virtual environment with the specified name and Python version."
    __pvem_print_command "install" "<version>" "Install the specified Python version."
    __pvem_print_command_flag "--enable-optimizations" "Enable optimizations in Python's compilation. This will increase installation time."
    __pvem_print_command "use" "<name>" "Activate the virtual environment with the specified name."
    __pvem_print_command "delete" "<name>" "Delete the virtual environment with the specified name."
    __pvem_print_command "uninstall" "<version>" "Uninstall the specified Python version."
    __pvem_print_command "list" "" "List all available virtual environments."
    __pvem_print_command "versions" "" "List all installed Python versions."
    __pvem_print_command "help, --help" "" "Show this help message."
    __pvem_print_command "-V, --version" "" "Show the current pvem version."
    echo ""
    echo "Examples:"
    __pvem_print_example "pvem install 3.9" "Install Python 3.9."
    __pvem_print_example "pvem new myenv 3.9" "Create a new virtual environment named 'myenv' with Python 3.9."
    __pvem_print_example "pvem use myenv" "Activate the 'myenv' virtual environment."
    __pvem_print_example "pvem delete myenv" "Delete the 'myenv' virtual environment."
}

# Function: _pvem_version
# Summary: Prints the current pvem version
# Parameters: None
_pvem_version() {
    echo "v0.1.2"
}

# Function: __pvem_print_command
# Summary: Print a command with its description
# Parameters:
#  $1: Command name
#  $2: Command arguments
#  $3: Command description
__pvem_print_command() {
    printf "  %b%-15s%b %-25s %s\n" "$C_BLUE" "$1" "$C_RESET" "$2" "$3"
}

# Function: __pvem_print_command_flag
# Summary: Print an optional flag for a command
# Parameters:
#  $1: Flag name
#  $3: Flag description
__pvem_print_command_flag() {
    printf "  %-15s %-25s %s\n" "" "[$1]" "$2"
}

# Function: __pvem_print_example
# Summary: Print an example with its description
# Parameters:
#   $1: Example
#   $2: Example description
__pvem_print_example() {
    printf "  %b%-36s%b %s\n" "$C_GREEN" "$1" "$C_RESET" "$2"
}
