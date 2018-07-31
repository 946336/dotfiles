
[[ -n $_DOTFILE_COMMON ]] && return || readonly _DOTFILE_COMMON=1

link_locations="dotfile-links.txt"
copy_locations="dotfile-copy.txt"

 install_script="dotfile-install.sh"
rollback_script="dotfile-rollback.sh"

_red() {
    echo -e -n "\033[1;37;41m"
}

_yellow() {
    echo -e -n "\033[1;37;43m"
}

_bold() {
    echo -e -n "\033[1m"
}

reset_color() {
    echo -e -n "\033[0m"
}

black() {
    echo -e -n "\033[1;30;47m"
}

error() {
    if [ -z ${failure+x} ]; then
        failure=1
    else
        failure=$(($failure + 1))
    fi
    (>&2 _red )
    (>&2 echo -e -n "Error:")
    (>&2 reset_color)
    if [ $# -gt 0 ]; then (>&2  echo -e " $@" ); else (>&2 echo -n " "); fi
}

warning() {
    ( >&2 _yellow)
    ( >&2 echo -e -n "Warning:")
    ( >&2 reset_color)
    if [ $# -gt 0 ]; then ( >&2 echo -e " $@" ); else ( >&2 echo -n " " ); fi
}

bold() {
    _bold
    if [ $# -gt 0 ]; then echo -e "${@}"; fi
    reset_color
}

info() {
    _bold
    echo -e -n "Info:"
    reset_color
    if [ $# -gt 0 ]; then echo -e " $@"; else echo -n " "; fi
}

say() {
    echo -e $@
}

fail() {
    (>&2 _red)
    (>&2 echo "$1")
    (>&2 reset_color)
    ${cleanup-true}
    exit ${2:-1}
}

