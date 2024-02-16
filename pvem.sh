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

source $PVEM_PATH/scripts/utils.sh

# Function: _pvem_help
# Summary: Show help message for pvem
# Parameters: None
_pvem_help() {
    echo "Usage: pvem <function> [arguments]"
    echo ""
    echo "pvem is a tool for managing python virtual environments and python versions."
    echo ""
    echo "Functions:"
    echo "  new <name> <python version>       Create a new virtual environment with the specified name and Python version."
    echo "  install <python version>          Install the specified Python version."
    echo "  use <name>                        Activate the virtual environment with the specified name."
    echo "  delete <name>                     Delete the virtual environment with the specified name."
    echo "  uninstall <python version>        Uninstall the specified Python version."
    echo "  list                              List all available virtual environments."
    echo "  versions                          List all installed Python versions."
    echo "  help                              Show this help message."
    echo ""
    echo "Examples:"
    echo "  pvem install 3.9                  Install Python 3.9."
    echo "  pvem new myenv 3.9                Create a new virtual environment named 'myenv' with Python 3.9."
    echo "  pvem use myenv                    Activate the 'myenv' virtual environment."
    echo "  pvem delete myenv                 Delete the 'myenv' virtual environment."
}

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
            source $PVEM_PATH/scripts/pvem_new.sh
            _pvem_new "$2" "$3"
            ;;
        "install")
            source $PVEM_PATH/scripts/pvem_install.sh
            _pvem_install "$2"
            ;;
        "use")
            source $PVEM_PATH/scripts/pvem_use.sh
            _pvem_use "$2"
            ;;
        "delete")
            source $PVEM_PATH/scripts/pvem_delete.sh
            _pvem_delete "$2"
            ;;
        "uninstall")
            source $PVEM_PATH/scripts/pvem_uninstall.sh
            _pvem_uninstall "$2"
            ;;
        "list")
            source $PVEM_PATH/scripts/pvem_list.sh
            _pvem_list
            ;;
        "versions")
            source $PVEM_PATH/scripts/pvem_versions.sh
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
}

# Source completions
if [ -n "$ZSH_VERSION" ]; then
    source "$PVEM_PATH/completions/zsh"
elif [ -n "$BASH_VERSION" ]; then
    source "$PVEM_PATH/completions/bash"
fi
