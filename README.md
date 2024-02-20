# Python Version and Environment Manager

This is a tool to manage locally installed python versions and barebones (`python -m venv [env]`) virtual environments using the managed versions.

![usage example](https://github.com/lucaspellegrinelli/pvem/assets/19651296/aaf86622-9652-4b79-8c41-8868bfd87e2e)

## Installation

Install `pvem` from the standalone installer included in this repository

### Linux / macOS

There are some requirements necessary for downloading and compiling Python which can be installed (in debian based linux distros) with

```
apt-get install -y curl wget make gcc zlib1g-dev libssl-dev libffi-dev
```

Now to **install** or **update** pvem, you should run the install script:

```
# Direct installation
curl -LsSf https://raw.githubusercontent.com/lucaspellegrinelli/pvem/v0.1.4/install.sh | sh

# ... or via manual download
wget https://raw.githubusercontent.com/lucaspellegrinelli/pvem/v0.1.4/install.sh
chmod +x install.sh
./install.sh
```

Restart your shell and you should be good to go!

**Note**: The installation automatically adds 2 new lines to the end of your `.bashrc/.zshrc` file.

### Windows

Not supported

## Usage

You can also run `pvem help` to get information on the commands inside the terminal.

* `pvem install [python-version]`
Installs a specific python version. Note that pvem doesn't use the globally installed python versions in your system, so if you have one installed and want to use it, you'll still need to install it through this command. _Examples:_ `pvem install 3.11` or `pvem install 3.11.4`
* `pvem new [env-name] [python-version]`
Creates a new virtual environment with the specified name and python version. _Example:_ `pvem new test 3.11`
* `pvem use [env-name]`
Enters the specified virtual environment. _Example:_ `pvem use test`
* `pvem list`
Lists all available virtual environments
* `pvem versions`
Lists all installed python versions
* `pvem delete [env-name]`
Deletes the specified virtual environment. _Example:_ `pvem delete test`
* `pvem uninstall [python-version]`
Uninstalls a specific python version. _Examples:_ `pvem uninstall 3.11` or `pvem uninstall 3.11.4`
* `deactivate`
Default linux command to leave a virtual environment

## Running tests

With docker running, you can run

```
# within project directory
make test
```

This will basically run the [test.sh](https://github.com/lucaspellegrinelli/pvem/blob/main/test.sh) script inside a docker container which tests the funcionality of the commands and prints out the results

## License

[MIT](LICENSE)
