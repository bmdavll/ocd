# cd convenience functions for bash

function o {
    local IFS=$'\n' WD="$PWD"
    local -i levels limit=16
    local opts=() args=() prefix='..' prefixes=() arg path
    if [ "$1" = "-n" ]; then
        arg="$1"
        levels="$2"
        [[ ! "$levels" =~ ^[1-9][0-9]?$ ]] && return 2
        shift 2
    fi
    while [ $# -gt 0 ]; do
        if [[ "$1" =~ ^[1-9][0-9]?$ && ! "$levels" ]]; then
            levels="$1"
        elif [[ "$1" == -- ]]; then
            shift && break
        elif [[ "$1" == -[PL]* ]]; then
            opts+=("$1")
        else
            args+=("$1")
        fi
        shift
    done
    if [ ! "$levels" ]; then
        levels=1
    elif (cd "${opts[@]}" "$prefix/$levels" &>/dev/null) && [[ ! "$arg" && ${#args[@]} -eq 0 ]]; then
        args=("$levels")
        levels=1
    fi
    while (( --levels > 0 )); do
        prefix+='/..'
    done
    prefixes=("$prefix")
    while true; do
        if (( ! limit-- )) || (cd "${opts[@]}" "$prefix" && [ "$PWD" = / ])
        then break
        else prefix+='/..' && prefixes+=("$prefix")
        fi
    done
    args+=("$@")
    if [ ${#args[@]} -eq 0 ]; then
        cd "${opts[@]}" "${prefixes[0]}"
        return
    else
        set -- "$(echo "${args[0]}" | sed 's|/\+$||')"
        for prefix in "${prefixes[@]}"; do
            if (cd "${opts[@]}" "$prefix/$1" &>/dev/null && [ ! "$PWD" -ef "$WD" ]); then
                cd "${opts[@]}" "$prefix/$1"
                return
            fi
            args=()
            for arg in $(cd "${opts[@]}" "$prefix" && ls -d $1* 2>/dev/null)
            do
                arg="$prefix/$arg"
                (cd "${opts[@]}" "$arg" &>/dev/null && [ ! "$PWD" -ef "$WD" ]) &&
                    args+=("$arg")
            done
            if   [ ${#args[@]} -eq 0 ]; then
                continue
            elif [ ${#args[@]} -eq 1 ]; then
                cd "${opts[@]}" "${args[0]}"
                return
            fi
            path=$(cd "${opts[@]}" "$prefix" && pwd) && path="${path/#$HOME/~}"
            select arg in "${args[@]/#$prefix/${path%/}}"; do
                [ ! "$arg" ] && break
                arg="${arg/#${path%/}/$prefix}"
                cd "${opts[@]}" "$arg"
                return
            done || return 0
        done
        return 1
    fi
}

_o() {
    local IFS=$'\n'
    local -i levels limit=16
    local opts=() prefix='..' prefixes=() replies=() cur="$2" arg path i
    for arg in "${COMP_WORDS[@]}"; do
        if [[ "$arg" == -- ]]; then
            break
        elif [[ "$arg" == -[PL]* ]]; then
            opts+=("$arg")
        fi
    done
    if [[ "$1" == 'o' && "${COMP_WORDS[1]}" =~ ^[1-9][0-9]?$ ]]; then
        if [ "$COMP_CWORD" -eq 1 ]; then
            levels=1
        else
            levels=${COMP_WORDS[1]}
        fi
    else
        levels=${#1}
    fi
    while (( --levels > 0 )); do
        prefix+='/..'
    done
    prefixes=("$prefix")
    if [ "$cur" -o "$COMP_TYPE" -eq 63 ]; then
        while true; do
            if (( ! limit-- )) || (cd "${opts[@]}" "$prefix" && [ "$PWD" = / ])
            then break
            else prefix+='/..' && prefixes+=("$prefix")
            fi
        done
    fi
    if [[ "$cur" == '~'* ]]; then
        eval cur=$cur
        cur="${cur#/}"
    fi
    COMPREPLY=()
    for prefix in "${prefixes[@]}"; do
        path=$(cd "${opts[@]}" "$prefix" && pwd)
        replies=($(compgen -d -- "${path%/}/$cur"))
        COMPREPLY+=("${replies[@]#${path%/}/}")
    done
    for i in "${!COMPREPLY[@]}"; do
        [ ! -d "${COMPREPLY[$i]}" ] && COMPREPLY[$i]+=/
    done
    return 0
}

alias oo='o -n 2'
alias ooo='o -n 3'
alias oooo='o -n 4'
alias ooooo='o -n 5'
complete -o nospace -o filenames -F _o  o oo ooo oooo ooooo


type cdl &>/dev/null && return

function cdl {
    local opts=("$@") args=() arg
    eval "set -- $(history -p '!!' | sed 's/[&|!<>$();]//g')"
    while [ $# -gt 0 ]; do
        args[$#]="$1" && shift
    done
    for arg in "${args[@]}"; do
        if [ ! -d "$arg" ]; then
            if [ -d "${arg%%.*}" ]; then
                arg="${arg%%.*}"
            else
                arg=$(dirname -- "$arg")
            fi
        fi
        if [[ -d "$arg" && ! "$arg" -ef "$PWD" && "$arg" != / ]]; then
            cd -- "$arg" && ls "${opts[@]}"
            return
        else
            continue
        fi
    done
    return 1
}

# vim:set ts=4 sw=4 et:
