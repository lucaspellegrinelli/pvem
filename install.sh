#!/bin/bash

if [ ! -f pvem.sh ]; then
    echo "pvem.sh not found. Downloading from GitHub..."
    wget -O pvem-main.tar.gz -q https://github.com/lucaspellegrinelli/pvem/archive/refs/heads/main.tar.gz
    tar -xf pvem-main.tar.gz
    mv pvem-main/pvem.sh pvem.sh
    mv pvem-main/scripts scripts/
    mv pvem-main/completions completions/
fi

INSTALL_PATH="${HOME}/.pvem"

if [ "$1" == "--no-prompt" ]; then
    user_path=""
else
    read -p "Enter installation path [${INSTALL_PATH}]: " user_path
fi

if [ -n "${user_path}" ]; then
    INSTALL_PATH="${user_path}"
fi

mkdir -p "${INSTALL_PATH}"
cp pvem.sh "${INSTALL_PATH}/pvem.sh"

mkdir -p "${INSTALL_PATH}/scripts"
cp -r scripts/* "${INSTALL_PATH}/scripts"

mkdir -p "${INSTALL_PATH}/completions"
cp -r completions/* "${INSTALL_PATH}/completions"

if [ -f "${HOME}/.bashrc" ]; then
    if ! grep -q "source ${INSTALL_PATH}/pvem.sh" "${HOME}/.bashrc"; then
        echo "" >> "${HOME}/.bashrc"
        echo "export PVEM_PATH=${INSTALL_PATH}" >> "${HOME}/.bashrc"
        echo "source ${INSTALL_PATH}/pvem.sh" >> "${HOME}/.bashrc"
    fi
fi

if [ -f "${HOME}/.zshrc" ]; then
    if ! grep -q "source ${INSTALL_PATH}/pvem.sh" "${HOME}/.zshrc"; then
        echo "" >> "${HOME}/.zshrc"
        echo "export PVEM_PATH=${INSTALL_PATH}" >> "${HOME}/.zshrc"
        echo "source ${INSTALL_PATH}/pvem.sh" >> "${HOME}/.zshrc"
    fi
fi

echo "pvem.sh has been installed to ${INSTALL_PATH}"
