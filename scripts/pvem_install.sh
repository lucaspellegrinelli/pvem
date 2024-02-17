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
    # given version
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
    target_version=$1

    if [ -d "$VERSIONPATH/tmp" ]; then
        rm -rf "$VERSIONPATH/tmp"
    fi

    mkdir -p "$VERSIONPATH/tmp"
    
    printf "\n"
    printf "${C_BLUE}Downloading Python version $target_version${C_RESET} "

    WGET_LOG_FILE=$(mktemp)
    wget -O "$VERSIONPATH/tmp/Python-$target_version.tgz" "https://www.python.org/ftp/python/$target_version/Python-$target_version.tgz" 2>$WGET_LOG_FILE

    if [ $? -ne 0 ]; then
        printf "\n"
        tail -n 10 $WGET_LOG_FILE
        return 1
    fi

    rm $WGET_LOG_FILE 2>/dev/null
    printf "Done.\n"

    printf "${C_BLUE}Extracting Python version $target_version${C_RESET} "

    TAR_LOG_FILE=$(mktemp)
    tar -zxf "$VERSIONPATH/tmp/Python-$target_version.tgz" -C "$VERSIONPATH/tmp" 2>$TAR_LOG_FILE

    if [ $? -ne 0 ]; then
        printf "\n"
        tail -n 10 $TAR_LOG_FILE
        return 1
    fi

    rm $TAR_LOG_FILE 2>/dev/null
    printf "Done.\n"

    printf "${C_BLUE}Installing Python version $target_version${C_RESET}\n"
    INSTALL_LOG_FILE=$(mktemp)
    INSTALL_EXIT_STATUS_FILE=$(mktemp)
    (
        set -e
        cd "$VERSIONPATH/tmp/Python-$target_version" &&
        ./configure --prefix="$VERSIONPATH/$target_version" &&
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

    if [ -d "$VERSIONPATH/tmp" ]; then
        rm -rf "$VERSIONPATH/tmp"
    fi

    if [ $exit_status -ne 0 ]; then
        tail -n 10 $INSTALL_LOG_FILE
        rm -rf "$VERSIONPATH/$target_version"
    fi

    rm $INSTALL_LOG_FILE 2>/dev/null
    return $exit_status
}
