#!/usr/bin/env bash

# Install pvem
./install.sh --no-prompt > /dev/null 2> install_error.log

# Load pvem
source ~/.pvem/pvem.sh

# ------------------------------------------------------------------------

echo "Verifying if pvem is installed in the system"

# Assert ~/.pvem exists
if [ ! -d ~/.pvem ]; then
    cat install_error.log
    echo " > Error: ~/.pvem does not exist"
    exit 1
fi
echo " > ~/.pvem exists"

# Assert ~/.pvem/pvem.sh exists
if [ ! -f ~/.pvem/pvem.sh ]; then
    cat install_error.log
    echo " > Error: ~/.pvem/pvem.sh does not exist"
    exit 1
fi
echo " > ~/.pvem/pvem.sh exists"

echo "Success!"
echo ""

# ------------------------------------------------------------------------

echo "Verifying if pvem is available in the system"

# Assert the "pvem" command is available
if ! command -v pvem &> /dev/null; then
    echo " > Error: pvem command is not available"
    exit 1
fi
echo " > pvem command is available"

echo "Success!"
echo ""

# ------------------------------------------------------------------------

echo "Trying to install a python version using pvem. This will take a while"
yes | pvem install 3.11.4 > /dev/null 2> install_error.log

# Assert ~/.pvem/versions/3.11.4 exists
if [ ! -d ~/.pvem/versions/3.11.4 ]; then
    cat install_error.log
    echo " > Error: ~/.pvem/versions/3.11.4 does not exist"
    exit 1
fi
echo " > ~/.pvem/versions/3.11.4 exists"

# Assert ~/.pvem/versions/3.11.4/bin/python3 exists
if [ ! -f ~/.pvem/versions/3.11.4/bin/python3 ]; then
    cat install_error.log
    echo " > Error: ~/.pvem/versions/3.11.4/bin/python3 does not exist"
    exit 1
fi
echo " > ~/.pvem/versions/3.11.4/bin/python3 exists"

echo "Success!"
echo ""

# ------------------------------------------------------------------------

echo "Trying to create a virtual environment using pvem"
pvem new test 3.11.4 > /dev/null 2> new_error.log

# Assert ~/.pvem/envs/test exists
if [ ! -d ~/.pvem/envs/test ]; then
    cat new_error.log
    echo " > Error: ~/.pvem/envs/test does not exist"
    exit 1
fi
echo " > ~/.pvem/envs/test exists"

# Assert ~/.pvem/envs/test/bin/activate exists
if [ ! -f ~/.pvem/envs/test/bin/activate ]; then
    cat new_error.log
    echo " > Error: ~/.pvem/envs/test/bin/activate does not exist"
    exit 1
fi
echo " > ~/.pvem/envs/test/bin/activate exists"

echo "Success!"
echo ""

# ------------------------------------------------------------------------

echo "Trying to delete the virtual environment using pvem"
pvem delete test > /dev/null 2> delete_error.log

# Assert ~/.pvem/envs/test does not exist
if [ -d ~/.pvem/envs/test ]; then
    cat delete_error.log
    echo " > Error: ~/.pvem/envs/test exists"
    exit 1
fi
echo " > ~/.pvem/envs/test was deleted"

echo "Success!"
echo ""

# ------------------------------------------------------------------------

echo "Trying to uninstall the python version using pvem"
yes | pvem uninstall 3.11.4 > /dev/null 2> uninstall_error.log

# Assert ~/.pvem/versions/3.11.4 does not exist
if [ -d ~/.pvem/versions/3.11.4 ]; then
    cat uninstall_error.log
    echo " > Error: ~/.pvem/versions/3.11.4 exists"
    exit 1
fi
echo " > ~/.pvem/versions/3.11.4 was deleted"

echo "Success!"
