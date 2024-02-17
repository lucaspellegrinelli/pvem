# Function: _pvem_install
# Summary: Install a new python version
# Parameters:
#   $1: Python version to install
# Return: 0 if the python version was installed, 1 otherwise
_pvem_install() {
    if [ -z "$1" ]; then
        printf "${C_RED}Error: Missing arguments for 'install' function.\n"
        printf "${C_RESET}\n"
        printf "Usage: pvem install ${C_BLUE}<python version>\n"
        printf "  ${C_BLUE}<python version>${CRESET}    The version of Python to install.\n"
        return 1
    fi

    target_version=$1
    
    if ! __pvem_check_version_could_be_valid "$target_version"; then
        printf "${C_RED}Error: Python version $target_version is not a valid version\n"
        return 1
    fi

    # Search the python FTP server for the latest version that starts with the
    # given version (3.11 -> 3.11.8, 3.11.7 -> 3.11.7...)
    version=$(curl -s https://www.python.org/ftp/python/ | grep -oE "[0-9]+\.[0-9]+\.[0-9]+" | grep -E "^$target_version(?:\D|$)" | sort -V | tail -n 1)

    if [ -z "$version" ]; then
        printf "${C_RED}Error: Python version $target_version is not available\n"
        return 1
    fi

    target_version=$version

    if __pvem_check_version_installed "$target_version"; then
        printf "${C_RED}Error: Python version $target_version is already installed\n"
        printf "${C_RESET}Use ${C_BLUE}pvem versions${C_RESET} to see all installed versions\n"
        return 1
    fi

    printf "${C_YELLOW}You are about to install Python version $target_version\n"
    printf "${C_RESET}Do you want to continue? (Y/n) "
    read -r response

    if [ "$response" = "n" ]; then
        printf "${C_RED}Installation aborted\n"
        return 1
    fi

    printf "\n"
    if ! __pvem_download_and_install_version "$target_version"; then
        printf "${C_RED}Error: Python version $target_version could not be installed\n"
        return 1
    fi

    printf "${C_GREEN}Python version $target_version installed\n"
    return 0
}

# Function: __pvem_download_and_install_version
# Summary: Download and install a new python version
# Parameters:
#   $1: Python version to install
# Return: 0 if the python version was installed, 1 otherwise
__pvem_download_and_install_version() {
    if [ -d "$VERSIONPATH/tmp" ]; then
        rm -rf "$VERSIONPATH/tmp"
    fi

    VERSION=$1
    UNPACK_PATH="$VERSIONPATH/tmp"
    TAR_PATH="$UNPACK_PATH/Python-$VERSION.tgz"
    INSTALL_PATH="$VERSIONPATH/$VERSION"
    
    if ! __pvem_download_python_source "$VERSION" "$TAR_PATH"; then
        return 1
    fi

    if ! __pvem_unpack_python_source "$TAR_PATH" "$UNPACK_PATH"; then
        return 1
    fi

    install_exit_status=0
    if ! __pvem_install_python_source "$UNPACK_PATH/Python-$VERSION" "$INSTALL_PATH"; then
        install_exit_status=1
    fi

    if [ -d "$VERSIONPATH/tmp" ]; then
        rm -rf "$VERSIONPATH/tmp"
    fi

    return $install_exit_status
}

# Function: __pvem_download_python_source
# Summary: Download the source code of a python version
# Parameters:
#  $1: Python version to download
#  $2: Target path for the tar source code
# Return: 0 if the source code was downloaded, 1 otherwise
__pvem_download_python_source() {
    version=$1
    target_path=$2

    WGET_LOG_FILE=$(mktemp)

    printf "${C_BLUE}Downloading source code${C_RESET} "
    mkdir -p $(dirname $target_path)
    wget -O $target_path "https://www.python.org/ftp/python/$version/Python-$version.tgz" 2>$WGET_LOG_FILE

    if [ $? -ne 0 ]; then
        printf "\n"
        tail -n 10 $WGET_LOG_FILE
        return 1
    fi

    if [ -f $WGET_LOG_FILE ]; then
        rm $WGET_LOG_FILE
    fi

    printf "Done.\n"
    return 0
}

# Function: __pvem_unpack_python_source
# Summary: Extract the source code of a python version
# Parameters:
#   $1: Path to the tar source code
#   $2: Path to extract the source code
# Return: 0 if the source code was extracted, 1 otherwise
__pvem_unpack_python_source() {
    source_path=$1
    target_path=$2

    TAR_LOG_FILE=$(mktemp)

    printf "${C_BLUE}Extracting source code${C_RESET} "
    tar -zxf $source_path -C $target_path 2>$TAR_LOG_FILE

    if [ $? -ne 0 ]; then
        printf "\n"
        tail -n 10 $TAR_LOG_FILE
        return 1
    fi

    if [ -f $TAR_LOG_FILE ]; then
        rm $TAR_LOG_FILE
    fi

    printf "Done.\n"
    return 0
}

# Function: __pvem_install_python_source
# Summary: Install the source code of a python version
# Parameters:
#  $1: Path to the source code
#  $2: Path to install the source code
# Return: 0 if the source code was installed, 1 otherwise
__pvem_install_python_source() {
    source_path=$1
    target_path=$2

    INSTALL_LOG_FILE=$(mktemp)
    INSTALL_EXIT_STATUS_FILE=$(mktemp)

    printf "${C_BLUE}Installing Python${C_RESET}\n"
    (
        set -e
        cd $source_path &&
        ./configure --prefix=$target_path &&
        make -j4 &&
        make install
        echo $? > $INSTALL_EXIT_STATUS_FILE
    ) 2>$INSTALL_LOG_FILE | __pvem_output_to_single_line

    if [ -f $INSTALL_EXIT_STATUS_FILE ]; then
        read exit_status < $INSTALL_EXIT_STATUS_FILE
        rm $INSTALL_EXIT_STATUS_FILE
    else
        exit_status=0
    fi

    if [ $exit_status -ne 0 ]; then
        tail -n 10 $INSTALL_LOG_FILE
        rm -rf $target_path
    fi

    if [ -f $INSTALL_LOG_FILE ]; then
        rm $INSTALL_LOG_FILE
    fi

    return $exit_status
}
