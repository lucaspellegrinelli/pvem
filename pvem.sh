export INSTALLPATH="/home/lucas/projects/venv-test"
ENVPATH="$INSTALLPATH/envs"
VERSIONPATH="$INSTALLPATH/versions"

pvem_new() {
    # Create a new virtual envirorment
    # $1 is the name of the virtual envirorment
    # $2 is the python version to use
    # Usage: pvem new <name> <python version>

    # Check if arguments are not empty
    if [ -z "$1" ] || [ -z "$2" ]; then
        echo "Usage: pvem new <name> <python version>"
        return 1
    fi

    # Check if python version looks like a version (X, X.X, X.X.X)
    if ! [[ "$2" =~ ^[0-9]+(\.[0-9]+){0,2}$ ]]; then
        echo "Error: Python version $2 is not a valid version"
        return 1
    fi

    # Search the versions directory for the latest version that starts with
    # the given version
    version=$(ls "$VERSIONPATH" | grep -E "^$2\." | sort -V | tail -n 1)

    # If no version was found, return
    if [ -z "$version" ]; then
        echo "Error: Python version $2 is not installed. Install it with pvem install $2"
        return 1
    fi

    2=$version

    # Check if virtual envirorment already exists
    if [ -d "$ENVPATH/$1" ]; then
        echo "Error: Virtual envirorment $1 already exists"
        return 1
    fi

    # Create virtual envirorment
    "$VERSIONPATH/$2/bin/python3" -m venv "$ENVPATH/$1"
}

pvem_install() {
    # Installs a new python version in $VERSIONPATH
    # $1 is the python version to install
    # Usage: pvem install <python version>

    # Check if argument is not empty
    if [ -z "$1" ]; then
        echo "Usage: pvem install <python version>"
        return 1
    fi

    # Check if python version looks like a version (X, X.X, X.X.X)
    if ! [[ "$1" =~ ^[0-9]+(\.[0-9]+){0,2}$ ]]; then
        echo "Error: Python version $1 is not a valid version"
        return 1
    fi

    # Search the python FTP server for the latest version that starts with the
    # given version
    version=$(curl -s https://www.python.org/ftp/python/ | grep -oE "[0-9]+\.[0-9]+\.[0-9]+" | grep -E "^$1\." | sort -V | tail -n 1)

    # If no version was found, return
    if [ -z "$version" ]; then
        echo "Error: Python version $given_version is not available"
        return 1
    fi

    1=$version

    # Check if python version is already installed
    if [ -d "$VERSIONPATH/$1" ]; then
        echo "Error: Python version $1 is already installed"
        return 1
    fi

    # Make sure a tmp directory exists
    mkdir -p "$VERSIONPATH/tmp"

    # Download python version
    wget -q -O "$VERSIONPATH/tmp/Python-$1.tgz" "https://www.python.org/ftp/python/$1/Python-$1.tgz"
    tar -zxvf "$VERSIONPATH/tmp/Python-$1.tgz" -C "$VERSIONPATH/tmp"

    # Store current directory
    cwd=$(pwd)

    # Install python version
    cd "$VERSIONPATH/tmp/Python-$1"
    ./configure --prefix="$VERSIONPATH/$1" --enable-optimizations
    make
    make install

    # Remove tmp directory
    rm -rf "$VERSIONPATH/tmp"

    # Return to previous directory
    cd "$cwd"
}

pvem_use() {
    # Activate a virtual envirorment
    # $1 is the name of the virtual envirorment
    # Usage: pvem use <name>

    # Check if argument is not empty
    if [ -z "$1" ]; then
        echo "Usage: pvem use <name>"
        return 1
    fi

    # Check if virtual envirorment exists
    if ! [ -d "$ENVPATH/$1" ]; then
        echo "Error: Virtual envirorment $1 does not exist"
        return 1
    fi

    # Activate virtual envirorment
    source "$ENVPATH/$1/bin/activate"
}

pvem_delete() {
    # Delete a virtual envirorment
    # $1 is the name of the virtual envirorment
    # Usage: pvem delete <name>

    # Check if argument is not empty
    if [ -z "$1" ]; then
        echo "Usage: pvem delete <name>"
        return 1
    fi

    # Check if virtual envirorment exists
    if ! [ -d "$ENVPATH/$1" ]; then
        echo "Error: Virtual envirorment $1 does not exist"
        return 1
    fi

    # Delete virtual envirorment
    rm -rf "$ENVPATH/$1"
}

pvem_uninstall() {
    # Uninstall a python version
    # $1 is the python version to uninstall
    # Usage: pvem uninstall <python version>

    # Check if argument is not empty
    if [ -z "$1" ]; then
        echo "Usage: pvem uninstall <python version>"
        return 1
    fi

    # Check if python version looks like a version (X, X.X, X.X.X)
    if ! [[ "$1" =~ ^[0-9]+(\.[0-9]+){0,2}$ ]]; then
        echo "Error: Python version $1 is not a valid version"
        return 1
    fi

    # Search the versions directory for the latest version that starts with
    # the given version
    version=$(ls "$VERSIONPATH" | grep -E "^$1\." | sort -V | tail -n 1)

    # If no version was found, return
    if [ -z "$version" ]; then
        echo "Error: Python version $1 is not installed"
        return 1
    fi

    1=$version

    # Check if python version is installed
    if ! [ -d "$VERSIONPATH/$1" ]; then
        echo "Error: Python version $1 is not installed"
        return 1
    fi

    # Delete python version
    rm -rf "$VERSIONPATH/$1"
}

pvem_list() {
    # List all available virtual envirorments
    # Usage: pvem list

    ls "$ENVPATH"
}

pvem_versions() {
    # List all installed python versions
    # Usage: pvem versions

    ls "$VERSIONPATH"
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
            pvem_new "$2" "$3"
            ;;
        "install")
            pvem_install "$2"
            ;;
        "use")
            pvem_use "$2"
            ;;
        "delete")
            pvem_delete "$2"
            ;;
        "uninstall")
            pvem_uninstall "$2"
            ;;
        "list")
            pvem_list
            ;;
        "versions")
            pvem_versions
            ;;
        *)
            echo "Usage: pvem [create|install|use|delete|uninstall|list] <arguments>"
            return 1
            ;;
    esac
}
