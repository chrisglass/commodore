# Project Syn: Commodore

This repository is part of Project Syn.
For documentation on Project Syn and this component, see https://syn.tools.

**Please note that this project is in its early stages and under active development**.

See [CHANGELOG.md](/CHANGELOG.md) for changelogs of each release version of
Commodore.

See [DockerHub](https://hub.docker.com/r/projectsyn/commodore) for pre-built
Docker images of Commodore.

## Overview

Commodore provides opinionated tenant-aware management of
[Kapitan](https://kapitan.dev/) inventories and templates. Commodore uses
Kapitan for the heavy lifting of rendering templates and resolving a
hierachical configuration structure.

Commodore introduces the concept of a component, which is a bundle of Kapitan
templates and associated Kapitan classes which describe how to render the
templates. Commodore fetches any components that are required for a given
configuration before running Kapitan, and sets up symlinks so Kapitan can find
the component classes.

Commodore also supports additional processing on the output of Kapitan, such
as patching in the desired namespace for a Helm chart which has been rendered
using `helm template`.

## System Requirements

* Python 3.6+, with `python3-dev` and `python3-venv` updated
* [Poetry](https://github.com/python-poetry/poetry)
* Docker

## Getting started

1. Install requirements

   Install poetry according to the upstream
   [documentation](https://github.com/python-poetry/poetry#installation).

   Create the Commodore environment:

    ```console
    poetry install
    ```

    Build the Kapitan helm binding:
    * Linux:

       ```console
       poetry run build_kapitan_helm_binding
       ```

    * OS X:

      Note: At the moment you'll need a working Go compiler to build the Kapitan Helm
      bindings on OS X.

      ```console
      poetry run sh -c '${VIRTUAL_ENV}/lib/python3.*/site-packages/kapitan/inputs/helm/build.sh'
      poetry run sh -c '${VIRTUAL_ENV}/lib/python3.*/site-packages/kapitan/dependency_manager/helm/build.sh'
      ```

1. Setup a `.env` file to configure Commodore (don't use quotes):

   ```shell
   # URL of Lieutenant API
   COMMODORE_API_URL=https://lieutenant-api.example.com/
   # Lieutenant API token
   COMMODORE_API_TOKEN=<my-token>
   # Base URL for global Git repositories
   COMMODORE_GLOBAL_GIT_BASE=ssh://git@github.com/projectsyn
   # Your local user ID to be used in the container (optional, defaults to root)
   USER_ID=<your-user-id>
   # Your username to be used in the commits (optional, defaults to your local git config)
   COMMODORE_USERNAME=<your name>
   # Your user email to be used in the commits (optional, defaults to your local git config)
   COMMODORE_USERMAIL=<your email>
   ```

   For Commodore to work, you need to run an instance of the
   [Lieutenant API](https://github.com/projectsyn/lieutenant-api) somewhere
   (locally is fine too).

   Commodore component repositories must exist in
   `${COMMODORE_GLOBAL_GIT_BASE}/commodore_components/` with the repository
   named identically to the component name.

   Or they must be configured in the `commodore.yml` config file in the
   `${COMMODORE_GLOBAL_GIT_BASE}/commodore-defaults.git` repository.

1. Run Commodore

   ```console
   poetry run commodore
   ```

1. Start hacking on Commodore

   ```console
   poetry shell
   ```

   - Write a line of test code, make the test fail
   - Write a line of application code, make the test pass
   - Repeat

1. Run linting and tests

   Auto format with autopep8
   ```console
   poetry run autopep
   ```

   List all Tox targets
   ```console
   poetry run tox -lv
   ```

   Run all linting and tests
   ```console
   poetry run tox
   ```

   Run just a specific target
   ```console
   poetry run tox -e py38
   ```


## Run Commodore in Docker

**IMPORTANT:** After checking out this project, run `mkdir -p catalog inventory dependencies` in it before running any Docker commands. This will ensure the folders are writable by the current user in the context of the Docker container.

A docker-compose setup enables running Commodore in a container.
The environment variables are picked up from the local `.env` file.
By default your `~/.ssh/` directory is mounted into the container and an `ssh-agent` is started.
You can skip starting an agent by setting the `SSH_AUTH_SOCK` env variable and mounting the socket into the container.

1. Build the Docker image inside of the cloned Commodore repository:

```console
docker-compose build
```

1. Run the built image:

```console
docker-compose run commodore catalog compile $CLUSTER_ID
```

## Documentation

Documentation for this component is written using [Asciidoc][asciidoc] and [Antora][antora].
It is located in the [docs/](docs) folder.
The [Divio documentation structure](https://documentation.divio.com/) is used to organize its content.

Run the `make docs-serve` command in the root of the project, and then browse to http://localhost:2020 to see a preview of the current state of the documentation.

After writing the documentation, please use the `make docs-vale` command and correct any warnings raised by the tool.

## Contributing and license

This library is licensed under [BSD-3-Clause](LICENSE).
For information about how to contribute see [CONTRIBUTING](CONTRIBUTING.md).

[asciidoc]: https://asciidoctor.org/
[antora]: https://antora.org/
