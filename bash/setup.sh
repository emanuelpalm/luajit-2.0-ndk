#!/usr/bin/env bash

# Standard functions.
abspath() {
    if [ -d "$(dirname "$1")" ];
    then
        echo "$(cd "$(dirname "$1")" && pwd)/$(basename "$1")"
    fi
}
absdirname() {
    echo "$(dirname $(abspath "$1"))"
}

# Standard variables.
PROJECT_ROOT=$(dirname "$(absdirname "$0")")
PROJECT_BASH="$PROJECT_ROOT/bash"
PROJECT_CONF="$PROJECT_ROOT/conf"

# Modules.
. "$PROJECT_BASH/setup_tools.sh"
. "$PROJECT_BASH/setup_submodules.sh"
. "$PROJECT_BASH/setup_env.sh"
