# A rudimentary antigen wrapper for bash. Only supports the core functionality -
# cloning repos and sourcing the appropriate scripts. Looks for '*.plugin.bash'
# instead of '*.plugin.zsh'.

this_dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

antigen-bundle () {
    local tmp="$(mktemp)"

    zsh <(cat <<'EOF'
source "$1/antigen.zsh" >&2

# This run downloads any missing repos
antigen bundle "${@:2}" >&2

# This run reports which files to source
antigen_shell='bash'
antigen bundle "${@:2}"
EOF
         ) "$this_dir" "$@" > "$tmp"

    while read script; do
        ANTIGEN_THIS_PLUGIN_DIR="$(dirname "$script")"
        source "$script"
        unset ANTIGEN_THIS_PLUGIN_DIR
    done < "$tmp"

    rm "$tmp"
}

antigen-update () {
    -antigen-command update "$@"
}

antigen-revert () {
    -antigen-command revert "$@"
}

antigen-selfupdate () {
    -antigen-command selfupdate "$@"
}

antigen-apply () {
    # A no-op, not an error
    return
}

antigen-help () {
    cat <<EOF
This is a minimal bash wrapper for antigen. It supports 'antigen bundle',
'antigen update', and 'antigen selfupdate'.

EOF
    -antigen-command help
}

-antigen-command () {
    zsh <(cat <<'EOF'
source "$1/antigen.zsh"
antigen "${@:2}"
EOF
         ) "$this_dir" "$@"
}

# A syntax sugar to avoid the `-` when calling antigen commands. With this
# function, you can write `antigen-bundle` as `antigen bundle` and so on.
antigen () {
    local cmd="$1"
    if [[ -z "$cmd" ]]; then
        echo 'Antigen: Please give a command to run.' >&2
        return 1
    fi
    shift

    if type "antigen-$cmd" &> /dev/null; then
        "antigen-$cmd" "$@"
    else
        echo "Antigen: command not available in the bash version of antigen: $cmd" >&2
    fi
}
