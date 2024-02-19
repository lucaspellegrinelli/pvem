#!/usr/bin/env bash

_pvem_version() {
    echo "v0.1.3"
}

# Check which flags are set
local_flag=false
no_prompt_flag=false
for arg in "$@"; do
    if [ "$arg" = "--local" ]; then
        local_flag=true
    fi
    if [ "$arg" = "--no-prompt" ]; then
        no_prompt_flag=true
    fi
done

# Check if --local flag is set
if [ "$local_flag" = true ]; then
    echo "Using local pvem source..."
    mkdir -p /tmp/pvem-source
    cp pvem.sh /tmp/pvem-source/pvem.sh
    cp -r pvem /tmp/pvem-source/pvem
    cp -r completions /tmp/pvem-source/completions
else
    echo "Using remote pvem source. Downloading from GitHub..."
    mkdir -p /tmp
    wget -O /tmp/pvem-source.tar.gz -q "https://github.com/lucaspellegrinelli/pvem/archive/refs/tags/$( _pvem_version ).tar.gz"
    tar -xf /tmp/pvem-source.tar.gz -C /tmp
    mv "/tmp/pvem-$( _pvem_version | sed 's/v//g' )" /tmp/pvem-source
fi

INSTALL_PATH="${HOME}/.pvem"

if [ "$no_prompt_flag" = true ]; then
    user_path=""
else
    read -rp "Enter installation path [${INSTALL_PATH}]: " user_path
fi

if [ -n "${user_path}" ]; then
    INSTALL_PATH="${user_path}"
fi

mkdir -p "${INSTALL_PATH}"
mv /tmp/pvem-source/pvem.sh "${INSTALL_PATH}/pvem.sh"

mkdir -p "${INSTALL_PATH}/pvem"
mv /tmp/pvem-source/pvem/* "${INSTALL_PATH}/pvem"

mkdir -p "${INSTALL_PATH}/completions"
mv /tmp/pvem-source/completions/* "${INSTALL_PATH}/completions"

if [ -f "${HOME}/.bashrc" ]; then
    if ! grep -q "source ${INSTALL_PATH}/pvem.sh" "${HOME}/.bashrc"; then
        {
            echo ""
            echo "export PVEM_PATH=${INSTALL_PATH}"
            echo "source ${INSTALL_PATH}/pvem.sh"
        } >> "${HOME}/.bashrc"
    fi
fi

if [ -f "${HOME}/.zshrc" ]; then
    if ! grep -q "source ${INSTALL_PATH}/pvem.sh" "${HOME}/.zshrc"; then
        {
            echo ""
            echo "export PVEM_PATH=${INSTALL_PATH}"
            echo "source ${INSTALL_PATH}/pvem.sh"
        } >> "${HOME}/.zshrc"
    fi
fi

if [ -d /tmp/pvem-source ]; then
    rm -rf /tmp/pvem-source
fi

if [ -f /tmp/pvem-source.tar.gz ]; then
    rm -f /tmp/pvem-source.tar.gz
fi

echo "pvem.sh has been installed to ${INSTALL_PATH}"
