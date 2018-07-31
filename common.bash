
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
    _red
    echo -e -n "Error:"
    reset_color
    if [ $# -gt 0 ]; then echo -e " $@"; else echo -n " "; fi
}

warning() {
    _yellow
    echo -e -n "Warning:"
    reset_color
    if [ $# -gt 0 ]; then echo -e " $@"; else echo -n " "; fi
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
    _red
    echo "$1"
    reset_color
    ${cleanup-true}
    exit ${2:-1}
}

