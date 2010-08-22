# cd convenience functions for bash

function o {
    local -i code=0 levels limit=16
    local IFS=$'\n' prefix='..' prefixes=() opts=() args=() arg path
    if [[ "$1" =~ ^[1-9][0-9]*$ ]]; then
        levels="$1" && shift
        while (( --levels > 0 )); do
            prefix+='/..'
        done
    fi
    prefixes+=("$prefix")
    while true; do
        if (( ! limit-- )) || [ "$(cd -P "$prefix" && pwd)" = '/' ]
        then break
        else prefix+='/..' && prefixes+=("$prefix")
        fi
    done
    while [ $# -gt 0 ]; do
        if [[ "$1" == -- ]]; then
            shift && break
        elif [[ "$1" == -[PL]* ]]; then
            opts+=("$1")
        else
            args+=("$1")
        fi
        shift
    done
    args+=("$@")
    if [ ${#args[@]} -eq 0 ]; then
        cd "${opts[@]}" -- "${prefixes[0]}" || code=$?
    else
        set -- "$(echo "${args[0]}" | sed 's|/\+$||')"
        code=1
        for prefix in "${prefixes[@]}"; do
            if [ -d "$prefix/$1" -a ! "$prefix/$1" -ef . ]; then
                cd "${opts[@]}" -- "$prefix/$1"
                return
            fi
            args=() && for arg in $prefix/$1*
            do [ -d "$arg" -a ! "$arg" -ef . ] && args+=("$arg")
            done
            if [ ${#args[@]} -eq 0 ]; then
                continue
            elif [ ${#args[@]} -eq 1 ]; then
                cd "${opts[@]}" -- "${args[0]}"
                return
            fi
            path=$(cd "$prefix" && pwd) && path="${path/#$HOME/~}"
            select arg in "${args[@]/#$prefix/${path%/}}"; do
                arg="${arg/#${path%/}/$prefix}"
                if [ -d "$arg" ]; then
                    cd "${opts[@]}" -- "$arg"
                    return
                else
                    break 2
                fi
            done || return 0
        done
    fi
    return $code
}
_o() {
    local -i levels limit=16
    local IFS=$'\n' prefix='..' prefixes=() replies=() cur="$2" i
    if [[ "$1" == 'o' && "${COMP_WORDS[1]}" =~ ^[1-9][0-9]*$ ]]; then
        if [ "$COMP_CWORD" -eq 1 ]; then
            COMPREPLY=("$cur") && return
        fi
        levels=${COMP_WORDS[1]}
    else
        levels=${#1}
    fi
    while (( --levels > 0 )); do
        prefix+='/..'
    done
    prefixes+=("$prefix")
    if [ "$cur" -o "$COMP_TYPE" -eq 63 ]; then
        while true; do
            if (( ! limit-- )) || [ "$(cd -P "$prefix" && pwd)" = '/' ]
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
        replies=($(compgen -d -- "$prefix/$cur"))
        COMPREPLY+=("${replies[@]#$prefix/}")
    done
    for i in "${!COMPREPLY[@]}"; do
        [ ! -d "${COMPREPLY[$i]}" ] && COMPREPLY[$i]+='/'
    done
    return 0
}
alias oo='o 2'
alias ooo='o 3'
alias oooo='o 4'
alias ooooo='o 5'
alias oooooo='o 6'
alias ooooooo='o 7'
alias oooooooo='o 8'
complete -o nospace -o filenames -F _o \
    o oo ooo oooo ooooo oooooo ooooooo oooooooo


type cdl &>/dev/null && return

function cdl {
    local opts=("$@") args=() arg
    eval "set -- $(history -p '!!' | sed 's/[&|!<>$();]//g')"
    while [ $# -gt 0 ]; do
        args[$#]="$1" && shift
    done
    for arg in "${args[@]}"; do
        if [ ! -d "$arg" ]; then
            arg=$(dirname -- "$arg")
        fi
        if [ -d "$arg" -a ! "$arg" -ef "$PWD" -a "$arg" != '/' ]; then
            cd -- "$arg" && ls "${opts[@]}"
            return
        else
            continue
        fi
    done
    return 1
}

# vim:set ts=4 sw=4 et:
