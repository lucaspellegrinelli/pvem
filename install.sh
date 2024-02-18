#!/usr/bin/env bash

_pvem_version() {
    echo "v0.1.1"
}

if [ ! -f pvem.sh ]; then
    echo "pvem.sh not found. Downloading from GitHub..."
    mkdir -p /tmp
    wget -O /tmp/pvem-source.tar.gz -q "https://github.com/lucaspellegrinelli/pvem/archive/refs/tags/$( _pvem_version ).tar.gz"
    tar -xf /tmp/pvem-source.tar.gz -C /tmp
    mv "/tmp/pvem-$( _pvem_version | sed 's/v//g' )" /tmp/pvem-source
else
    echo "Using local pvem.sh"
    mkdir -p /tmp/pvem-source
    cp pvem.sh /tmp/pvem-source/pvem.sh
    cp -r scripts /tmp/pvem-source/scripts
    cp -r completions /tmp/pvem-source/completions
fi

INSTALL_PATH="${HOME}/.pvem"

if [ "$1" = "--no-prompt" ]; then
    user_path=""
else
    read -rp "Enter installation path [${INSTALL_PATH}]: " user_path
fi

if [ -n "${user_path}" ]; then
    INSTALL_PATH="${user_path}"
fi

mkdir -p "${INSTALL_PATH}"
mv /tmp/pvem-source/pvem.sh "${INSTALL_PATH}/pvem.sh"

mkdir -p "${INSTALL_PATH}/scripts"
mv /tmp/pvem-source/scripts/* "${INSTALL_PATH}/scripts"

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
