#!/usr/bin/env sh

Minimal shim to make pre-commit runnable without 'husky install'
if [ -z "$husky_skip_init" ]; then
readonly husky_skip_init=1
export husky_skip_init
sh -e "$0" "$@"
exit $?
fi
