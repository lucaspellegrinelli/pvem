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

_pvem_new() {
    # Create a new virtual envirorment
    # $1 is the name of the virtual envirorment
    # $2 is the python version to use
    # Usage: pvem new <name> <python version>

    # Check if arguments are not empty
    if [ -z "$1" ] || [ -z "$2" ]; then
        echo "Error: Missing arguments for 'new' function."
        echo ""
        echo "Usage: pvem new <name> <python version>"
        echo "  <name>              The name of the virtual environment to create."
        echo "  <python version>    The version of Python to use in the virtual environment."
        return 1
    fi

    env_name=$1
    python_version=$2

    # Check if python version looks like a version (X, X.X, X.X.X)
    if ! [[ "$python_version" =~ ^[0-9]+(\.[0-9]+){0,2}$ ]]; then
        echo "Error: Python version $python_version is not a valid version"
        return 1
    fi

    # Search the versions directory for the latest version that starts with
    # the given version
    version=$(ls "$VERSIONPATH" | grep -E "^$python_version\.?" | sort -V | tail -n 1)

    # If no version was found, return
    if [ -z "$version" ]; then
        echo "Error: Python version $python_version is not installed. Install it with pvem install $python_version"
        return 1
    fi

    python_version=$version

    # Check if virtual envirorment already exists
    if [ -d "$ENVPATH/$env_name" ]; then
        echo "Error: Virtual envirorment $env_name already exists"
        return 1
    fi

    # Create virtual envirorment
    "$VERSIONPATH/$python_version/bin/python3" -m venv "$ENVPATH/$env_name"
}

_pvem_install() {
    # Installs a new python version in $VERSIONPATH
    # $1 is the python version to install
    # Usage: pvem install <python version>

    # Check if argument is not empty
    if [ -z "$1" ]; then
        echo "Error: Missing arguments for 'install' function."
        echo ""
        echo "Usage: pvem install <python version>"
        echo "  <python version>    The version of Python to install."
        return 1
    fi

    target_version=$1

    # Check if python version looks like a version (X, X.X, X.X.X)
    if ! [[ "$target_version" =~ ^[0-9]+(\.[0-9]+){0,2}$ ]]; then
        echo "Error: Python version $target_version is not a valid version"
        return 1
    fi

    # Search the python FTP server for the latest version that starts with the
    # given version
    version=$(curl -s https://www.python.org/ftp/python/ | grep -oE "[0-9]+\.[0-9]+\.[0-9]+" | grep -E "^$target_version\.?" | sort -V | tail -n 1)

    # If no version was found, return
    if [ -z "$version" ]; then
        echo "Error: Python version $given_version is not available"
        return 1
    fi

    target_version=$version

    # Check if python version is already installed
    if [ -d "$VERSIONPATH/$target_version" ]; then
        echo "Error: Python version $target_version is already installed"
        echo "Use 'pvem versions' to see all installed versions"
        return 1
    fi

    # Make sure a tmp directory exists
    mkdir -p "$VERSIONPATH/tmp"

    # Download python version
    wget -q -O "$VERSIONPATH/tmp/Python-$target_version.tgz" "https://www.python.org/ftp/python/$target_version/Python-$target_version.tgz"
    tar -zxvf "$VERSIONPATH/tmp/Python-$target_version.tgz" -C "$VERSIONPATH/tmp"

    # Store current directory
    cwd=$(pwd)

    # Install python version
    cd "$VERSIONPATH/tmp/Python-$target_version"
    ./configure --prefix="$VERSIONPATH/$target_version" --enable-optimizations
    make
    make install

    # Remove tmp directory
    rm -rf "$VERSIONPATH/tmp"

    # Return to previous directory
    cd "$cwd"
}

_pvem_use() {
    # Activate a virtual envirorment
    # $1 is the name of the virtual envirorment
    # Usage: pvem use <name>

    # Check if argument is not empty
    if [ -z "$1" ]; then
        echo "Error: Missing arguments for 'use' function."
        echo ""
        echo "Usage: pvem use <name>"
        echo "  <name>              The name of the virtual environment to source into."
        return 1
    fi

    env_name=$1

    # Check if virtual envirorment exists
    if ! [ -d "$ENVPATH/$env_name" ]; then
        echo "Error: Virtual envirorment $env_name does not exist"
        echo "Use 'pvem list' to see all available virtual envirorments"
        return 1
    fi

    # Activate virtual envirorment
    source "$ENVPATH/$env_name/bin/activate"
}

_pvem_delete() {
    # Delete a virtual envirorment
    # $1 is the name of the virtual envirorment
    # Usage: pvem delete <name>

    # Check if argument is not empty
    if [ -z "$1" ]; then
        echo "Error: Missing arguments for 'delete' function."
        echo ""
        echo "Usage: pvem delete <name>"
        echo "  <name>              The name of the virtual environment to delete."
        return 1
    fi

    env_name=$1

    # Check if virtual envirorment exists
    if ! [ -d "$ENVPATH/$env_name" ]; then
        echo "Error: Virtual envirorment $env_name does not exist"
        echo "Use 'pvem list' to see all available virtual envirorments"
        return 1
    fi

    # Delete virtual envirorment
    rm -rf "$ENVPATH/$env_name"
}

_pvem_uninstall() {
    # Uninstall a python version
    # $1 is the python version to uninstall
    # Usage: pvem uninstall <python version>

    # Check if argument is not empty
    if [ -z "$1" ]; then
        echo "Error: Missing arguments for 'uninstall' function."
        echo ""
        echo "Usage: pvem uninstall <python version>"
        echo "  <python version>    The version of Python to uninstall."
        return 1
    fi

    python_version=$1

    # Check if python version looks like a version (X, X.X, X.X.X)
    if ! [[ "$python_version" =~ ^[0-9]+(\.[0-9]+){0,2}$ ]]; then
        echo "Error: Python version $python_version is not a valid version"
        return 1
    fi

    # Search the versions directory for the latest version that starts with
    # the given version
    version=$(ls "$VERSIONPATH" | grep -E "^$python_version\.?" | sort -V | tail -n 1)

    # If no version was found, return
    if [ -z "$version" ]; then
        echo "Error: Python version $python_version is not installed"
        echo "Use 'pvem versions' to see all installed versions"
        return 1
    fi

    python_version=$version

    # Check if python version is installed
    if ! [ -d "$VERSIONPATH/$python_version" ]; then
        echo "Error: Python version $python_version is not installed"
        echo "Use 'pvem versions' to see all installed versions"
        return 1
    fi

    # Delete python version
    rm -rf "$VERSIONPATH/$python_version"
}

_pvem_list() {
    # List all available virtual envirorments
    # Usage: pvem list

    # If the virtual envirorments directory does not exist, return
    if ! [ -d "$ENVPATH" ]; then
        return 1
    fi

    # Print the virtual envirorment name and version
    for env in $(ls "$ENVPATH"); do
        if ! [ -f "$ENVPATH/$env/pyvenv.cfg" ]; then
            continue
        fi

        version=$(cat "$ENVPATH/$env/pyvenv.cfg" | grep -oE "version = [0-9]+\.[0-9]+\.[0-9]+" | cut -d " " -f 3)
        printf "%-20s %s\n" "$env" "$version"
    done
}

_pvem_versions() {
    # List all installed python versions
    # Usage: pvem versions

    # If the versions directory does not exist, return
    if ! [ -d "$VERSIONPATH" ]; then
        return 1
    fi

    # Print all installed python versions one per line
    for version in $(ls "$VERSIONPATH"); do
        echo "$version"
    done
}

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

pvem() {
    # Run the pvem_X functions based on the first argument
    # $1 is the function to run
    # Usage: pvem <function> <arguments>

    # Check if argument is not empty
    if [ -z "$1" ]; then
        _pvem_help
        return 1
    fi

    # Switch case for the first argument
    case "$1" in
        "new")
            _pvem_new "$2" "$3"
            ;;
        "install")
            _pvem_install "$2"
            ;;
        "use")
            _pvem_use "$2"
            ;;
        "delete")
            _pvem_delete "$2"
            ;;
        "uninstall")
            _pvem_uninstall "$2"
            ;;
        "list")
            _pvem_list
            ;;
        "versions")
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
