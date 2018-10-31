#!/usr/bin/env bash

source common.bash
source install-functions.bash

failure=0

process_everything=0

while [ $# -gt 0 ]; do
    case "$1" in
        -h|--help)
            help
            exit 0
            ;;
        -v|--verbose)
            shift
            DOTFILE_VERBOSE=1
            ;;
        --upgrade)
            shift
            DOTFILE_UPGRADE=1
            ;;
        --all)
            shift
            process_everything=1
            ;;
        *)
            break
            ;;
    esac
done

# If there are no non-option arguments, and we're not doing everything, then
# there's nothing for us to do
if ! option_set "$process_everything" && [ $# -eq 0 ]; then
    verb="install"
    if option_set "$DOTFILE_UPGRADE"; then verb="upgrade"; fi
    info "No configurations to $verb. Exiting."
    info "Try $0 --help for help"
    exit 0
fi

# If we're doing everything, set confs to everything we have
if option_set "$process_everything"; then
    confs_available=$(configurations_available)

    i=0
    for line in $confs_available; do
        confs[$i]=$(get_installation_instructions "$line")
        i=$((i + 1))
    done
else
# If we're only doing a subset, set confs appropriately
    i=0
    while [ $# -gt 0 ]; do
        installfile=$(get_installation_instructions "$1")
        if [ -n "$installfile" ]; then
            confs[$i]="$installfile"
        else
            verb="installation"
            if option_set "$DOTFILE_UPGRADE"; then verb="upgrading"; fi
            warning "\"$1\" does not name a set of configurations with" \
                "recognized $verb instructions"
        fi
        i=$((i  +1))
        shift
    done
    installfile=
fi

# If there are no valid configurations to process, we're done
if [ "${#confs[@]}" -eq 0 ]; then
    verb="install"
    if option_set "$DOTFILE_UPGRADE"; then verb="upgrade"; fi
    info "No configurations to $verb."
    exit 0
fi

# Summarize the configurations we're going to process
verb="install"
if option_set "$DOTFILE_UPGRADE"; then verb="upgrade"; fi

if option_set "$process_everything"; then
    say "Attemping to $verb all available configurations:"
else
    say "Attempting to $verb the following configurations:"
fi

for each in "${confs[@]}"; do
    d=$(dirname  "$each")
    f=$(basename "$each")

    echo -n '--> '
    _bold
    printf '%-20s via %s\n' "$d" "$each"
    reset_color
done

# Process each set of configurations
for each in "${confs[@]}"; do
    d=$(dirname  "$each")
    f=$(basename "$each")

    pushd "$d" >/dev/null

    verb="Installing"
    if option_set "$DOTFILE_UPGRADE"; then verb="Upgrading"; fi
    info "$verb configuration for $d"

    if [ $f == "$install_script" ]; then
        # Run the installation script

        verb="installation"
        if option_set "$DOTFILE_UPGRADE"; then verb="upgrading"; fi

        if_verbose bold "Running $verb script $f in directory $d/"

        # Invoke the installation script
        if has_shebang "$f"; then
            chmod u+x "$f"
            env DOTFILE_UPGRADE="$DOTFILE_UPGRADE" \
                DOTFILE_VERBOSE="$DOTFILE_VERBOSE" "./$f"
        else
            env DOTFILE_UPGRADE="$DOTFILE_UPGRADE" \
                DOTFILE_VERBOSE="$DOTFILE_VERBOSE" sh "$f"
        fi

        # Invoke the rollback script if we detect that the installation script
        # failed in some way
        if [[ $? -ne 0 ]]; then
            error "Installation script for $d failed."

            if [[ -f $rollback_script ]] && [[ -x $rollback_script ]]; then
                info "Rolling back using $d/$rollback_script"

                if has_shebang "$rollback_script"; then
                    chmod u+x "$rollback_script"
                    env - DOTFILE_UPGRADE="$DOTFILE_UPGRADE" \
                        DOTFILE_VERBOSE="$DOTFILE_VERBOSE" "./$rollback_script"
                else
                    env - DOTFILE_UPGRADE="$DOTFILE_UPGRADE" \
                        DOTFILE_VERBOSE="$DOTFILE_VERBOSE" sh "$rollback_script"
                fi
            else
                error "Rollback script $d/$rollback_script not found,"
                error "Unable to restore previous configuration."
            fi
        fi

    elif [ "$f" == "$copy_locations" ]; then
        # Use the copy list

        if_verbose bold "Reading $f"

        if ! valid_rules_file "$f"; then
            error "Skipping invalid rules file $d"
            continue
        fi

        while read rule; do
            if [ -z "$rule" ]; then continue; fi
            if [ "${rule:0:1}" == "#" ]; then continue; fi

            target=$(rule_target "$rule")
            name=$(rule_name "$rule")

            dir=$(dirname "$name")
            if [ ! -d "$dir" ]; then
                if_verbose info "Creating directory $dir required by rule " \
                    "\"$rule\""
                if ! mkdir -p "$dir"; then
                    error "Failed to create directory $dir required by rule" \
                        "\"$rule\""
                    continue
                fi
            fi

            if_verbose say "Copying $target to $name"

            backup_as "$name" "$name.tar.gz"

            if [ -d "$name" ]; then
                if ! rm -r "$name"; then
                    error "Failed to remove old configuration from $name"
                    rm -f $(backup_file "$name")
                    continue
                fi
            fi

            scp -r "$target" "$name" || \
                (error "Failed to copy $target to $name" && rollback_to "$name")

            rm -f $(backup_file "$name")

        done < "$f"

    elif [ "$f" == "$link_locations" ]; then
        # Use the link list

        if_verbose bold "Reading $f"

        if ! valid_rules_file "$f"; then
            error "Skipping invalid rules file $d"
            continue
        fi

        while read rule; do
            if [ -z "$rule" ]; then continue; fi
            if [ "${rule:0:1}" == "#" ]; then continue; fi

            target=$(rule_target "$rule")
            name=$(rule_name "$rule")

            if_verbose say "Linking from $name to $PWD/$target"

            dir=$(dirname "$name")
            if [[ "$dir" == "." ]]; then
                dir="$PWD"
            fi

            if [ ! -d "$dir" ]; then
                if_verbose info "Creating directory $dir required by rule " \
                    "\"$rule\""
                if ! mkdir -p "$dir"; then
                    error "Failed to create directory $dir required by rule" \
                        "\"$rule\""
                    continue
                fi
            fi

            backup_as "$name" "$name.tar.gz"

            ln --symbolic --force "$PWD/$target" "$name" || \
                (error "Failed to link $PWD/$target to $name" && \
                rollback_to "$name")

            rm -f $(backup_file "$name")

        done < "$f"

    fi

    if_verbose info "Done processing $d"
    popd >/dev/null
done

exit $failure

