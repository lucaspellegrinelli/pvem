# How it works

## What the installation does

When you install `pvem` a folder `~/.pvem` will be created in your system with the following:
* A file `pvem.sh` which is sourced into your shell on startup. It is the entrypoint for the tool
* A folder `pvem` which has the scripts for each of the commands `pvem` has
* A folder `completions` which has scripts for the completions for both `bash` and `zsh` which are sourced by `pvem.sh`.
* A folder `versions` which will store all the locally installed python versions pvem will use
* A folder `envs` which will store all the virtual environments created through pvem

Also, the user's `~/.bashrc`/`~/.zshrc` is updated with the lines

```
export PVEM_PATH=/Users/lucasmachado/.pvem
source /Users/lucasmachado/.pvem/pvem.sh
```

These lines add the `pvem` command to the user's shell.

## How the tool actually works

When you run `pvem install`, the tool downloads Python's source code from the official Python FTP server for the specified version. It then unzips the source code and compiles it manually into the folder `~/.pvem/versions`. With that we have a locally installed python ready for use available on that folder.

Now when you try to run `pvem new`, it just has to go into the chosen version's folder, find the python executable in there and run `python -m venv [env_name]`. These venvs are then saved into another folder (`~/.pvem/envs`) so we can access them later.

With that, when you run `pvem use` we just `source` the target venv that is located on the `~/.pvem/envs` folder.

Uninstalling python versions and deleting environments is just `rm -rf` in the `~/.pvem/versions` and `~/.pvem/envs` folders respectivelly.
