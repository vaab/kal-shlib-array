## Begin libarray.sh


array_read-0() {
    local elt
    while true; do
        for a_name in "$@"; do
            declare -n cur="$a_name"
            elt="$(next-0)" || return 0
            cur+=("$elt")
        done
    done
}


array_values_to_stdin() {
    local e
    if [ "$#" -ne "1" ]; then
        print_syntax_warning "$FUNCNAME: need one argument."
        return 1
    fi
    var="$1"
    eval "for e in \"\${$var[@]}\"; do echo -en \"\$e\\0\"; done"
}


array_keys_to_stdin() {
    local e
    if [ "$#" -ne "1" ]; then
        print_syntax_warning "$FUNCNAME: need one argument."
        return 1
    fi
    var="$1"
    eval "for e in \"\${!$var[@]}\"; do echo -en \"\$e\\0\"; done"
}


array_kv_to_stdin() {
    local e
    if [ "$#" -ne "1" ]; then
        print_syntax_warning "$FUNCNAME: need one argument."
        return 1
    fi
    var="$1"
    eval "for e in \"\${!$var[@]}\"; do echo -n \"\$e\"; echo -en '\0'; echo -n \"\${$var[\$e]}\"; echo -en '\0'; done"
}


array_pop() {
    local narr="$1" nres="$2"
    for key in $(eval "echo \${!$narr[@]}"); do
        eval "$nres=\${$narr[\"\$key\"]}"
        eval "unset $narr[\"\$key\"]"
        return 0
    done
}


array_member() {
    local src elt
    src="$1"
    elt="$2"
    while read-0 key; do
        vname="$src[$key]"
        if [ "${!vname}" == "$elt" ]; then
            return 0
        fi
    done < <(array_keys_to_stdin "$src")
    return 1
}

## End libarray.sh
