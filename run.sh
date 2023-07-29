#!/bin/bash

runShell=false

if [ "$1" == '--shell' ]; then
    runShell=true
    shift
fi

if [ -n "$1" ]; then
    echo "Usage: $0 [--shell]"
    exit 1
fi

if [ $runShell = true ]; then
    EntryPointArgs=()
else
    EntryPointArgs=(--entrypoint emacs)
fi

exec docker run -it --rm \
       --net=host \
       --hostname=emacs-box \
       -e DISPLAY \
       -u ubuntu \
       "${EntryPointArgs[@]}" \
       emacs/ubuntu:mantic
