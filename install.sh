#!/bin/bash

if [ ! -f pvem.sh ]; then
    echo "pvem.sh not found. Downloading from GitHub..."
    wget -q https://raw.githubusercontent.com/lucaspellegrinelli/pvem/main/pvem.sh
fi

INSTALL_PATH="${HOME}/.pvem"

read -p "Enter installation path [${INSTALL_PATH}]: " user_path

if [ -n "${user_path}" ]; then
    INSTALL_PATH="${user_path}"
fi

mkdir -p "${INSTALL_PATH}"
cp pvem.sh "${INSTALL_PATH}/pvem.sh"
echo "pvem.sh has been installed to ${INSTALL_PATH}"

if ! grep -q "export PVEM_PATH=${INSTALL_PATH}" "${HOME}/.bashrc"; then
    echo "export PVEM_PATH=${INSTALL_PATH}" >> "${HOME}/.bashrc"
fi

if ! grep -q "source ${INSTALL_PATH}/pvem.sh" "${HOME}/.bashrc"; then
    echo "source ${INSTALL_PATH}/pvem.sh" >> "${HOME}/.bashrc"
fi

if ! grep -q "export PVEM_PATH=${INSTALL_PATH}" "${HOME}/.zshrc"; then
    echo "export PVEM_PATH=${INSTALL_PATH}" >> "${HOME}/.zshrc"
fi

if ! grep -q "source ${INSTALL_PATH}/pvem.sh" "${HOME}/.zshrc"; then
    echo "source ${INSTALL_PATH}/pvem.sh" >> "${HOME}/.zshrc"
fi
