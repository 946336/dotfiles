
[[ -n $_DOTFILE_TEST ]] && return || readonly $_DOTFILE_TEST=1

source common.bash

testdir=conf-test

make_test_confs() {
    MKDIR "$testdir"

    make_empty_test
    make_noconfig_test
    make_empty_script_test
    make_empty_links_test
    make_empty_copy_test
    make_links_test
    make_copy_test
}

remove_tests() {
    RM "$testdir"

    RM empty
    RM noconfig
    RM empty-script
    RM empty-links
    RM empty-copy
    RM links
    RM copy
}

MKDIR() {
    if [[ -e $1 ]] && [[ -d $1 ]]; then
        printf "Not creating %15s (Already exists)\n" "$1"
        return 0
    fi

    if [[ -f $1 ]]; then
        error "Regular file with name $1 already exists. Not overwriting."
        return 1
    fi

    echo "Creating $1"
    mkdir -p "$1"
}

RM() {
    if [[ ! -d $1 ]]; then
        error "Not a directory ($1)"
        return 1
    fi
    rm -rvf "$1"
}

# Empty dir
#   Should not be detected as a valid conf
make_empty_test() {
    if ! MKDIR empty; then
        return 1
    fi
}

# Directory not containing installation instructions
#   Should not be detected as a valid conf
make_noconfig_test() {
    if ! MKDIR noconfig; then
        return 1
    fi
    touch noconfig/{a,b,35,configure.sh,CMakeLists.txt}
}

# Directory containing an empty installation script
#   Should be detected as a valid conf
#   Installing should result in no action
make_empty_script_test() {
    if ! MKDIR empty-script; then
        return 1
    fi
    touch empty-script/dotfile-install.sh
    chmod u+x empty-script/dotfile-install.sh
}

# Directory containing empty dotfile-links.txt
#   Should be detected as a valid conf
#   Installing should result in no action
make_empty_links_test() {
    if ! MKDIR empty-links; then
        return 1
    fi
    touch empty-links/dotfile-links.txt
}

# Directory containing empty dotfile-copy.txt
#   Should be detected as a valid conf
#   Installing should result in no action
make_empty_copy_test() {
    if ! MKDIR empty-copy; then
        return 1
    fi
    touch empty-copy/dotfile-copy.txt
}

make_links_test() {
    if ! MKDIR links; then
        return 1
    fi

    touch "links/$link_locations"

    touch links/ohno.conf

    MKDIR links/ohno.d
    touch    links/ohno.d/ohyes.conf

    echo "$PWD/$testdir/links/ohno.conf |   ohno.conf" \
        >> links/dotfile-links.txt
    echo "$PWD/$testdir/links/ohno.d    |   ohno.d"    \
        >> links/dotfile-links.txt
}

make_copy_test() {
    if ! MKDIR copy; then
        return 1
    fi

    touch "copy/$copy_locations"

    touch copy/ohno.conf

    MKDIR copy/ohno.d
    touch    copy/ohno.d/ohyes.conf

    echo "$PWD/$testdir/copy/ohno.conf |   ohno.conf" \
        >> copy/dotfile-copy.txt
    echo "$PWD/$testdir/copy/ohno.d    |   ohno.d"    \
        >> copy/dotfile-copy.txt
}

