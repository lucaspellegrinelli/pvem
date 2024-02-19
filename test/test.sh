#!/usr/bin/env bash

# Install pvem
./install.sh --local --no-prompt > /dev/null 2> install_error.log

# Load pvem
. ~/.pvem/pvem.sh

# ------------------------------------------------------------------------

echo "Verifying if pvem is installed in the system"

# Assert ~/.pvem exists
if [ ! -d ~/.pvem ]; then
    echo " > Error: ~/.pvem does not exist"
    exit 1
fi
echo " > ~/.pvem exists"

# Assert ~/.pvem/pvem.sh exists
if [ ! -f ~/.pvem/pvem.sh ]; then
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

echo "Verifying pvem can find python version given the full version (3.11.4)"
echo "n" | pvem install 3.11.4 > out_install.log

# Assert there's "You are about to install Python version 3.11.4" in the output
if ! grep -q "You are about to install Python version 3.11.4" out_install.log; then
    echo " > Error: pvem install could not find the python version 3.11.4"
    exit 1
fi
echo " > pvem install found the python version 3.11.4"

echo "Success!"
echo ""

# ------------------------------------------------------------------------

echo "Verifying pvem can find python version given the major version (3.8)"
echo "n" | pvem install 3.8 > out_install.log

# Assert there's "You are about to install Python version 3.8.18" in the output
if ! grep -q "You are about to install Python version 3.8.18" out_install.log; then
    echo " > Error: pvem install could not find the python version 3.8.18"
    exit 1
fi
echo " > pvem install found the python version 3.8.18"

echo "Success!"
echo ""

# ------------------------------------------------------------------------

echo "Trying to install python 3.11.4 using pvem. This will take a while"
echo "Y" | pvem install 3.11.4 &> /dev/null

# Assert ~/.pvem/versions/3.11.4 exists
if [ ! -d ~/.pvem/versions/3.11.4 ]; then
    echo " > Error: ~/.pvem/versions/3.11.4 does not exist"
    exit 1
fi
echo " > ~/.pvem/versions/3.11.4 exists"

# Assert ~/.pvem/versions/3.11.4/bin/python3 exists
if [ ! -f ~/.pvem/versions/3.11.4/bin/python3 ]; then
    echo " > Error: ~/.pvem/versions/3.11.4/bin/python3 does not exist"
    exit 1
fi
echo " > ~/.pvem/versions/3.11.4/bin/python3 exists"

echo "Success!"
echo ""

# ------------------------------------------------------------------------

echo "Verifying if pvem versions contains the installed version"
pvem versions > out_versions.log

# Assert there "3.11.4" in the output
if ! grep -q "3.11.4" out_versions.log; then
    echo " > Error: 3.11.4 is not in the output of pvem versions"
    exit 1
fi
echo " > 3.11.4 is in the output of pvem versions"

echo "Success!"
echo ""

# ------------------------------------------------------------------------

echo "Trying to create a virtual environment named 'test' with python's full version"
pvem new test 3.11.4 > out_new.log

# Assert ~/.pvem/envs/test exists
if [ ! -d ~/.pvem/envs/test ]; then
    echo " > Error: ~/.pvem/envs/test does not exist"
    exit 1
fi
echo " > ~/.pvem/envs/test exists"

# Assert ~/.pvem/envs/test/bin/activate exists
if [ ! -f ~/.pvem/envs/test/bin/activate ]; then
    echo " > Error: ~/.pvem/envs/test/bin/activate does not exist"
    exit 1
fi
echo " > ~/.pvem/envs/test/bin/activate exists"

# Check if there's "successfully created" in the output
if ! grep -q "successfully created" out_new.log; then
    echo " > Error: 'successfully created' is not in the output of pvem new"
    exit 1
fi
echo " > 'successfully created' is in the output of pvem new"

echo "Success!"
echo ""

# ------------------------------------------------------------------------

echo "Verifying if pvem list contains the virtual environment"
pvem list > out_list.log

# Assert there's "test", a bunch of spaces and then "3.11.4" in the output
if ! sed 's/\x1b\[[0-9;]*m//g' out_list.log | grep -q "test[[:space:]]\+3\.11\.4"; then
    echo " > Error: test 3.11.4 is not in the output of pvem list"
    exit 1
fi
echo " > test 3.11.4 is in the output of pvem list"

echo "Success!"
echo ""

# ------------------------------------------------------------------------

echo "Trying to delete the 'test' virtual environment"
pvem delete test > out_delete.log

# Assert ~/.pvem/envs/test does not exist
if [ -d ~/.pvem/envs/test ]; then
    echo " > Error: ~/.pvem/envs/test exists"
    exit 1
fi
echo " > ~/.pvem/envs/test was deleted"

# Assert there's "successfully deleted" in the output
if ! grep -q "successfully deleted" out_delete.log; then
    echo " > Error: 'successfully deleted' is not in the output of pvem delete"
    exit 1
fi
echo " > 'successfully deleted' is in the output of pvem delete"

echo "Success!"
echo ""

# ------------------------------------------------------------------------

echo "Verying pvem list does not contain the deleted virtual environment"
pvem list > out_list.log

# Assert there's no "test" in the output
if grep -q "test" out_list.log; then
    echo " > Error: test is in the output of pvem list"
    exit 1
fi
echo " > test is not in the output of pvem list"

echo "Success!"
echo ""

# ------------------------------------------------------------------------

echo "Trying to create a virtual environment named 'test' with python's partial version"
pvem new test 3.11 > out_new.log

# Assert ~/.pvem/envs/test exists
if [ ! -d ~/.pvem/envs/test ]; then
    echo " > Error: ~/.pvem/envs/test does not exist"
    exit 1
fi
echo " > ~/.pvem/envs/test exists"

# Assert ~/.pvem/envs/test/bin/activate exists
if [ ! -f ~/.pvem/envs/test/bin/activate ]; then
    echo " > Error: ~/.pvem/envs/test/bin/activate does not exist"
    exit 1
fi
echo " > ~/.pvem/envs/test/bin/activate exists"

# Check if there's "successfully created" in the output
if ! grep -q "successfully created" out_new.log; then
    echo " > Error: 'successfully created' is not in the output of pvem new"
    exit 1
fi
echo " > 'successfully created' is in the output of pvem new"

echo "Success!"
echo ""

# ------------------------------------------------------------------------

echo "Verifying if pvem list contains the virtual environment"
pvem list > out_list.log

# Assert there's "test", a bunch of spaces and then "3.11.4" in the output
if ! sed 's/\x1b\[[0-9;]*m//g' out_list.log | grep -q "test[[:space:]]\+3\.11\.4"; then
    echo " > Error: test 3.11.4 is not in the output of pvem list"
    exit 1
fi
echo " > test 3.11.4 is in the output of pvem list"

echo "Success!"
echo ""

# ------------------------------------------------------------------------

echo "Veryfing pvem is able to uninstall python 3.11.4 given the full version"
echo "n" | pvem uninstall 3.11.4 > out_uninstall.log

# Assert there's "Warning: Python version 3.11.4 is used by one or more virtual envirorments"
if ! grep -q "Warning: Python version 3.11.4 is used by one or more virtual envirorments" out_uninstall.log; then
    echo " > Error: Couldn't find the python version given the full version"
    exit 1
fi
echo " > Found the python version given the full version"

echo "Success!"
echo ""

# ------------------------------------------------------------------------

echo "Veryfing pvem is able to uninstall python 3.11.4 given the partial version"
echo "n" | pvem uninstall 3.11 > out_uninstall.log

# Assert there's "Warning: Python version 3.11.4 is used by one or more virtual envirorments"
if ! grep -q "Warning: Python version 3.11.4 is used by one or more virtual envirorments" out_uninstall.log; then
    echo " > Error: Couldn't find the python version given the partial version"
    exit 1
fi
echo " > Found the python version given the partial version"

echo "Success!"
echo ""

# ------------------------------------------------------------------------

echo "Trying to uninstall the python 3.11.4"
echo "y" | pvem uninstall 3.11.4 > out_uninstall.log

# Assert ~/.pvem/versions/3.11.4 does not exist
if [ -d ~/.pvem/versions/3.11.4 ]; then
    echo " > Error: ~/.pvem/versions/3.11.4 exists"
    exit 1
fi
echo " > ~/.pvem/versions/3.11.4 was deleted"

# Assert there's "successfully uninstalled" in the output
if ! grep -q "successfully uninstalled" out_uninstall.log; then
    echo " > Error: 'successfully uninstalled' is not in the output of pvem uninstall"
    exit 1
fi
echo " > 'successfully uninstalled' is in the output of pvem uninstall"

echo "Success!"
echo ""

# ------------------------------------------------------------------------

echo "Veryfing pvem versions does not contain the uninstalled version"
pvem versions > out_versions.log

# Assert there's no "3.11.4" in the output
if grep -q "3.11.4" out_versions.log; then
    echo " > Error: 3.11.4 is in the output of pvem versions"
    exit 1
fi
echo " > 3.11.4 is not in the output of pvem versions"

echo "Success!"
echo ""

# ------------------------------------------------------------------------

echo "Veryfing pvem list displays the warning message when listing uninstalled python versions"
pvem list > out_list.log

# Assert there's "test", a bunch of spaces and then "3.11.4" in the output
if ! sed 's/\x1b\[[0-9;]*m//g' out_list.log | grep -q "test[[:space:]]\+3\.11\.4"; then
    echo " > Error: test 3.11.4 is not in the output of pvem list"
    exit 1
fi
echo " > test 3.11.4 is in the output of pvem list"

# Assert there's "Not all envirorments have their Python version installed" in the output
if ! grep -q "Not all envirorments have their Python version installed" out_list.log; then
    echo " > Error: Output of pvem list does not contain the expected warning"
    exit 1
fi
echo " > Output of pvem list contains the expected warning"

echo "Success!"
echo ""

# ------------------------------------------------------------------------

echo "Trying to delete the 'test' virtual environment"
pvem delete test > out_delete.log

# Assert ~/.pvem/envs/test does not exist
if [ -d ~/.pvem/envs/test ]; then
    echo " > Error: ~/.pvem/envs/test exists"
    exit 1
fi
echo " > ~/.pvem/envs/test was deleted"

# Assert there's "successfully deleted" in the output
if ! grep -q "successfully deleted" out_delete.log; then
    echo " > Error: 'successfully deleted' is not in the output of pvem delete"
    exit 1
fi
echo " > 'successfully deleted' is in the output of pvem delete"

echo "Success!"
