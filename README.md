# Commodore: Build dynamic inventories and compile catalogs with Kapitan

## Getting started

1. Make sure [Pipenv](https://github.com/pypa/pipenv) is set up

1. Install requirements

   ```console
   pipenv install
   ```

1. Setup a `.env` file to configure Commodore (or provide command line flags):

   ```shell
   # URL of SYNventory API
   API_URL="http://localhost:5000/"
   # Base URL (local or remote) for global Git repositories
   GLOBAL_GIT_BASE="ssh://git@git.vshn.net/syn/"
   # Base URL (local or remote) for customer Git repositories
   CUSTOMER_GIT_BASE="ssh://git@git.vshn.net/syn/customers/"
   ```

1. Run the mock CI job script

   ```console
   pipenv run ./runjob
   ```

1. Start hacking on Commodore
