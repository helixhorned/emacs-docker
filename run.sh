#!/bin/bash

runShell=false
prefixDir="$HOME"
explicitlyChangedPrefixDir=false

if [ "$1" == '--shell' ]; then
    runShell=true
    shift
fi

if [[ "$1" =~ ^--prefix= ]]; then
    prefixDir="${1:9}"
    explicitlyChangedPrefixDir=true
    shift
fi

if [[ ! -d "$prefixDir" ]]; then
    echo "ERROR: '$prefixDir' does not exist or is not a directory." 1>&2
    exit 1
fi

mountKind=
dirSuffix=

if [[ "$1" =~ ^--elisp-dir-r[ow]= ]]; then
    mountKind="${1:12:2}"
    dirSuffix="${1:15}"
    shift
elif [[ -n "$1" ]]; then
    echo "Usage: $0 [--help|--shell] [--prefix=<dir>] [--elisp-dir-(ro|rw)=<suffix>]"
    echo
    echo " If one of '--elisp-dir-ro=' or '--elisp-dir-rw=' is passed,"
    echo " the following mounts are made from the host system into the"
    echo " container (all relative to <dir> which defaults to '\$HOME'):"
    echo "  - <suffix>/"
    echo "  - .emacs"
    echo "  - .emacs-custom"
    echo "  - .emacs-d/"
    echo
    echo " The path '<dir>/<suffix>' must be canonical: redundant slashes,"
    echo " symlinks, and '.' or '..' as components are not allowed."
    echo
    echo " When mounting read-write ('--elisp-dir-rw='), '--prefix' *must* be specified."
    exit 1
fi

if [[ "$mountKind" == rw && "$explicitlyChangedPrefixDir" == false ]]; then
    echo "ERROR: When mounting read-write, must explicitly specify '--prefix'." 1>&2
    exit 2
fi

## ----------

MountArgs=()

if [ -n "$dirSuffix" ]; then
    hostDir="$prefixDir/$dirSuffix"
    realHostDir="$(realpath --quiet -e "$hostDir")"

    if [ "$realHostDir" != "$hostDir" ]; then
        echo "ERROR: invalid directory suffix '$dirSuffix'." 1>&2
        echo "       (Does not point to an existing directory or is not canonical.)" 1>&2
        echo "       See '$0 --help' for the expected format." 1>&2
        exit 2
    fi

    mountDirSuffixes=("$dirSuffix/" .emacs .emacs-custom .emacs.d/)
    n=${#mountDirSuffixes[@]}

    guestHome="/home/ubuntu"
    echo "INFO: Mounts from '$prefixDir' of the host into '$guestHome' of the container:"
    for ((i=0; i < n; i++)) do
        dirSuffix="${mountDirSuffixes[$i]}"
        path="$prefixDir/$dirSuffix"

        if [ ! -e "$path" ]; then
            echo "  SKIPPED: $dirSuffix"
            continue
        fi

        echo "  $mountKind: $dirSuffix"

        j="$((2*i))"
        k="$((2*i+1))"
        MountArgs[$j]='-v'
        MountArgs[$k]="$prefixDir/$dirSuffix:$guestHome/$dirSuffix:$mountKind"
    done
fi

if [ $runShell = true ]; then
    EntryPointArgs=()
else
    EntryPointArgs=(--entrypoint emacs)
fi

## ----------

exec docker run -it --rm \
       --net=host \
       --hostname=emacs-box \
       -e DISPLAY \
       -u ubuntu \
       "${MountArgs[@]}" \
       "${EntryPointArgs[@]}" \
       emacs/ubuntu:noble
