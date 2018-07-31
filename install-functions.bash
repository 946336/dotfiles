
[[ -n $_DOTFILE_INSTALL ]] && return || readonly _DOTFILE_INSTALL=1

DOTFILE_VERBOSE=0
DOTFILE_UPGRADE=0
DOTFILE_BACKUPDIR=backup

# Defines $link_locations, $copy_locations, and $install_script
# Defines some useful colors too
source common.bash

# Holds paths to installation instruction files, relative to repository root.
declare -a confs

usage() {
    echo -e "$(basename "$0") [-h] [-v] [--upgrade] [ configurations ]"
    echo -e "Install or update dotfiles and/or configurations"
}

help() {
    usage
    echo -e "Configurations available:"
    configurations_available
}

if_verbose() {
    if option_set "$DOTFILE_VERBOSE"; then
        $@
    fi
}

has_shebang() {
    head -n1 "$1" | grep '^#!'
}

# Backup target file or directory with a name
backup_as() { # target name
    local target="$1"
    local name="$(realpath "$DOTFILE_BACKUPDIR")/$(basename "$2")"
    mkdir -p "$DOTFILE_BACKUPDIR"

    if [[ -e $name ]]; then
        i=1
        while [[ -e "$name.$i" ]]; do
            i=$((i + 1))
        done
        name="$name.$i"
    fi

    if [ ! -e "$target" ]; then
        if_verbose info "Nothing to backup"
    elif [ -d "$target" ]; then
        if_verbose info "Backing up directory $target as $name"
        tar cf "$name" -C / "${target#\/}"
    elif [ -f "$target" ]; then
        if_verbose info "Backing up file $target as $name"
        tar cf "$name" -C / "${target#\/}"
    else
        listing="\t$(ls -lf "$target")\n\t$(file "$target")"
        if_verbose info "Backing up something strange: \n$listing"
        tar cf "$name" -C / "${target#\/}"
    fi
}

backup_file() { # name
    local displayname="$1"
    local name="$(realpath "$DOTFILE_BACKUPDIR")/$(basename "$1").tar.gz"
    mkdir -p "$DOTFILE_BACKUPDIR"

    local last="$name"
    if [[ ! -e "$name" ]]; then
        local i=1
        while [[ -e "$name.$i" ]]; do
            i=$((i + 1))
            last="$name.$i"
        done
        name="$last"
    fi

    if [[ ! -e "$name" ]]; then
        if_verbose error "Did not find any backups for configuration " \
            "\"$(basename "$displayname")\""
        return 1
    fi
    echo "$name"
}

# Rollback to previous configuration
rollback_to() { # name
    local name=$(backup_file "$1")

    info "Rolling back to configuration $name"

    tar xv --file "$name" -C /
}

# Print a list of available configurations
configurations_available() {
    for d in */; do
        local dname=$(dirname "$(get_installation_instructions "$d")")
        if [ "$dname" != "." ]; then
            echo "$dname"
        fi
    done
}

# Get the name of the installation instruction file for a configuration
# directory and print to standard output. If output is empty, no installation
# instructions were found, and the function returns nonzero.
get_installation_instructions() {
    (readable_file "$1/$link_locations" && echo "$1/$link_locations") || \
    (readable_file "$1/$copy_locations" && echo "$1/$copy_locations") || \
    (readable_file "$1/$install_script" && echo "$1/$install_script")
}

# Test that a path refers to a readable regular file
# This function is suitable for use as a predicate
# Positional parameters:
#   Path to be tested
readable_file() {
    [ -r "$1" ] && [ -f "$1" ]
}

option_set() {
    [ "$1" -eq 1 ]
}

rule_name() {
    echo "$1" | cut -d\| -f1 | sed 's/^\s\+//g' | \
        sed 's/\s\+$//g'  | sed "s|~|${HOME}|g"
}

rule_target() {
    echo "$1" | cut -d\| -f2 | sed 's/^\s\+//g' | \
        sed 's/\s\+$//g'  | sed "s|~|${HOME}|g"
}

# $1: path to file to read
# Returns: The number of invalid rules
valid_rules_file() {
    local retval=0
    while read rule; do
        if [ -z "$rule" ]; then continue; fi
        if [ "${rule:0:1}" == "#" ]; then continue; fi

        target=$(rule_target "$rule")
        name=$(rule_name "$rule")

        if [ ! -e "$target" ]; then
            error "Rule \"$rule\" doesn't target valid configuration."
            retval=$((retval + 1))
            continue
        fi

    done < "$1"
    return $retval
}

