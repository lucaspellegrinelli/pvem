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
        echo "Usage: pvem new <name> <python version>"
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
        echo "Usage: pvem install <python version>"
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
        echo "Usage: pvem use <name>"
        return 1
    fi

    env_name=$1

    # Check if virtual envirorment exists
    if ! [ -d "$ENVPATH/$env_name" ]; then
        echo "Error: Virtual envirorment $env_name does not exist"
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
        echo "Usage: pvem delete <name>"
        return 1
    fi

    env_name=$1

    # Check if virtual envirorment exists
    if ! [ -d "$ENVPATH/$env_name" ]; then
        echo "Error: Virtual envirorment $env_name does not exist"
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
        echo "Usage: pvem uninstall <python version>"
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
        return 1
    fi

    python_version=$version

    # Check if python version is installed
    if ! [ -d "$VERSIONPATH/$python_version" ]; then
        echo "Error: Python version $python_version is not installed"
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

    ls "$ENVPATH"
}

_pvem_versions() {
    # List all installed python versions
    # Usage: pvem versions

    # If the versions directory does not exist, return
    if ! [ -d "$VERSIONPATH" ]; then
        return 1
    fi

    ls "$VERSIONPATH"
}

_pvem_help() {
    echo "Usage: pvem <function> <arguments>"
    echo "Functions:"
    printf "  %-10s %-25s %s\n" "new" "<name> <python version>" "Create a new virtual environment"
    printf "  %-10s %-25s %s\n" "install" "<python version>" "Install a python version"
    printf "  %-10s %-25s %s\n" "use" "<name>" "Activate a virtual environment"
    printf "  %-10s %-25s %s\n" "delete" "<name>" "Delete a virtual environment"
    printf "  %-10s %-25s %s\n" "uninstall" "<python version>" "Uninstall a python version"
    printf "  %-10s %-25s %s\n" "list" "" "List all available virtual environments"
    printf "  %-10s %-25s %s\n" "versions" "" "List all installed python versions"
    printf "  %-10s %-25s %s\n" "help" "" "Show this help message"
}

pvem() {
    # Run the pvem_X functions based on the first argument
    # $1 is the function to run
    # Usage: pvem <function> <arguments>

    # Check if argument is not empty
    if [ -z "$1" ]; then
        echo "Usage: pvem <function> <arguments>"
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

_pvem_completions() {
    local cur prev firstword lastword complete_words complete_options

    COMP_WORDBREAKS=${COMP_WORDBREAKS//[:=]}

    GLOBAL_OPTS="new install use delete uninstall list versions help"
    ENV_OPTS=$(ls "$ENVPATH" 2>/dev/null)
    VERSION_OPTS=$(ls "$VERSIONPATH" 2>/dev/null)

    # If there's only one word, complete with the functions
    if [ "${COMP_CWORD}" -eq 1 ]; then
        COMPREPLY=($(compgen -W "${GLOBAL_OPTS}" -- "${COMP_WORDS[1]}"))
        return 0
    fi

    # If there's 2 or more words, get the second word to know which function to
    # complete
    function_name="${COMP_WORDS[1]}"

    # If function is "new" and there's more than 2 words, complete with the
    # python versions
    if [ "${function_name}" = "new" ] && [ "${COMP_CWORD}" -gt 2 ]; then
        COMPREPLY=($(compgen -W "${VERSION_OPTS}" -- "${COMP_WORDS[3]}"))
        return 0
    fi

    # If the function is "use" and there's 2 words, complete with the virtual
    # envirorments
    if [ "${function_name}" = "use" ] && [ "${COMP_CWORD}" -eq 2 ]; then
        COMPREPLY=($(compgen -W "${ENV_OPTS}" -- "${COMP_WORDS[2]}"))
        return 0
    fi

    # If the function is "delete" and there's 2 words, complete with the virtual
    # envirorments
    if [ "${function_name}" = "delete" ] && [ "${COMP_CWORD}" -eq 2 ]; then
        COMPREPLY=($(compgen -W "${ENV_OPTS}" -- "${COMP_WORDS[2]}"))
        return 0
    fi

    # If the function is "uninstall" and there's 2 words, complete with the
    # python versions
    if [ "${function_name}" = "uninstall" ] && [ "${COMP_CWORD}" -eq 2 ]; then
        COMPREPLY=($(compgen -W "${VERSION_OPTS}" -- "${COMP_WORDS[2]}"))
        return 0
    fi
}

complete -F _pvem_completions pvem
