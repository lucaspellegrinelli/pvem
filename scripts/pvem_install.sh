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
        
        if [ -d "$VERSIONPATH/tmp" ]; then
            rm -rf "$VERSIONPATH/tmp"
        fi

        if [ -d "$VERSIONPATH/$target_version" ]; then
            rm -rf "$VERSIONPATH/$target_version"
        fi

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

    mkdir -p "$VERSIONPATH/tmp" &&
    
    # Download python version
    wget -q -O "$VERSIONPATH/tmp/Python-$target_version.tgz" "https://www.python.org/ftp/python/$target_version/Python-$target_version.tgz" &&
    tar -zxvf "$VERSIONPATH/tmp/Python-$target_version.tgz" -C "$VERSIONPATH/tmp" &&

    cwd=$(pwd) &&

    cd "$VERSIONPATH/tmp/Python-$target_version" &&
    ./configure --prefix="$VERSIONPATH/$target_version" &&
    make &&
    make install &&
    
    cd "$cwd" &&
    rm -rf "$VERSIONPATH/tmp"

    return $?
}
