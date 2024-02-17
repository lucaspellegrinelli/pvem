#!/usr/bin/env bash

# Function: _pvem_install
# Summary: Install a new python version
# Parameters:
#   $1: Python version to install
# Return: 0 if the python version was installed, 1 otherwise
_pvem_install() {
    if [ -z "$1" ]; then
        printf "%bError: Missing arguments for 'install' function.\n" "$C_RED"
        printf "%b\n" "$C_RESET"
        printf "Usage: pvem install %b<python version>\n" "$C_BLUE"
        printf "  %b<python version>%b    The version of Python to install.\n" "$C_BLUE" "$C_RESET"
        return 1
    fi

    target_version=$1
    
    if ! __pvem_check_version_could_be_valid "$target_version"; then
        printf "%bError: Python version %s is not a valid version\n" "$C_RED" "$target_version"
        return 1
    fi

    # Search the python FTP server for the latest version that starts with the
    # given version (3.11 -> 3.11.8, 3.11.7 -> 3.11.7...)
    version=$(curl -s https://www.python.org/ftp/python/ | grep -oE "[0-9]+\.[0-9]+\.[0-9]+" | grep -E "^${target_version}(?:[^0-9]|$)" | sort -V | tail -n 1)

    if [ -z "$version" ]; then
        printf "%bError: Python version %s is not available\n" "$C_RED" "$target_version"
        return 1
    fi

    target_version=$version

    if __pvem_check_version_installed "$target_version"; then
        printf "%bError: Python version %s is already installed\n" "$C_RED" "$target_version"
        printf "%bUse %b%s%b to see all installed versions\n" "$C_RESET" "$C_BLUE" "pvem versions" "$C_RESET"
        return 1
    fi

    printf "%bYou are about to install Python version %s\n" "$C_YELLOW" "$target_version"
    printf "%bDo you want to continue? (Y/n) " "$C_RESET"
    read -r response

    if [ "$response" = "n" ]; then
        printf "%bInstallation aborted\n" "$C_RED"
        return 1
    fi

    printf "\n"
    if ! __pvem_download_and_install_version "$target_version"; then
        printf "%bError: Python version %s could not be installed\n" "$C_RED" "$target_version"
        return 1
    fi

    printf "%bPython version %s installed\n" "$C_GREEN" "$target_version"
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

    mkdir -p "$(dirname "$target_path")"
    printf "%bDownloading source code%b " "$C_BLUE" "$C_RESET"
    if ! wget -O "$target_path" "https://www.python.org/ftp/python/$version/Python-$version.tgz" 2>"$WGET_LOG_FILE"; then
        printf "\n"

        if [ -f "$WGET_LOG_FILE" ]; then
            tail -n 10 "$WGET_LOG_FILE"
            rm "$WGET_LOG_FILE"
        fi

        return 1
    fi

    if [ -f "$WGET_LOG_FILE" ]; then
        rm "$WGET_LOG_FILE"
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

    printf "%bExtracting source code%b " "$C_BLUE" "$C_RESET"
    if ! tar -zxf "$source_path" -C "$target_path" 2>"$TAR_LOG_FILE"; then
        printf "\n"

        if [ -f "$TAR_LOG_FILE" ]; then
            tail -n 10 "$TAR_LOG_FILE"
            rm "$TAR_LOG_FILE"
        fi

        return 1
    fi

    if [ -f "$TAR_LOG_FILE" ]; then
        rm "$TAR_LOG_FILE"
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

    printf "%bInstalling Python%b\n" "$C_BLUE" "$C_RESET"
    (
        set -e
        cd "$source_path" &&
        ./configure --prefix="$target_path" &&
        make -j4 &&
        make install
        echo $? > "$INSTALL_EXIT_STATUS_FILE"
    ) 2>"$INSTALL_LOG_FILE" | __pvem_output_to_single_line

    if [ -f "$INSTALL_EXIT_STATUS_FILE" ]; then
        read -r exit_status < "$INSTALL_EXIT_STATUS_FILE"
        rm "$INSTALL_EXIT_STATUS_FILE"
    else
        exit_status=0
    fi

    if [ "$exit_status" -ne 0 ]; then
        if [ -f "$INSTALL_LOG_FILE" ]; then
            tail -n 10 "$INSTALL_LOG_FILE"
            rm "$INSTALL_LOG_FILE"
        fi

        rm -rf "$target_path"
    fi

    if [ -f "$INSTALL_LOG_FILE" ]; then
        rm "$INSTALL_LOG_FILE"
    fi

    return "$exit_status"
}
