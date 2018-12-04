## Begin libarray.sh


array_read-0() {
    local elt aname
    while true; do
        for aname in "$@"; do
            declare -n cur="$aname"
            elt="$(next-0)" || return 0
            cur+=("$elt")
        done
    done
}


array_values_to_stdin() {
    local var="$1" e aname
    if [ "$#" -ne "1" ]; then
        print_syntax_warning "$FUNCNAME: need one argument."
        return 1
    fi
    declare -n aname="$var"
    for e in "${aname[@]}"; do
        printf "%s\0"  "$e"
    done
}


array_keys_to_stdin() {
    local var="$1" e aname
    if [ "$#" -ne "1" ]; then
        print_syntax_warning "$FUNCNAME: need one argument."
        return 1
    fi
    declare -n aname="$var"
    for e in "${!aname[@]}"; do
        printf "%s\0" "$e"
    done
}


array_kv_to_stdin() {
    local var="$1" e aname
    if [ "$#" -ne "1" ]; then
        print_syntax_warning "$FUNCNAME: need one argument."
        return 1
    fi
    declare -n aname="$var"
    for e in "${!aname[@]}"; do
        printf "%s\0" "$e" "${aname[$e]}"
    done
}


array_pop() {
    local narr="$1" nres="$2" aname
    declare -n aname="$narr"
    declare -n rname="$nres"
    for key in "${!aname[@]}"; do
        rname="${aname[$key]}"
        unset aname["$key"]
        return 0
    done
}


array_member() {
    local src="$1" elt="$2" vname
    while read-0 key; do
        vname="$src[$key]"
        if [ "${!vname}" == "$elt" ]; then
            return 0
        fi
    done < <(array_keys_to_stdin "$src")
    return 1
}

## End libarray.sh
