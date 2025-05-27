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

array_read-0-err() {
    local elt aname last eof
    local ret="$1"
    shift
    while true; do
        idx=0
        for aname in "$@"; do
            last=$idx

            declare -n cur="$aname"
            IFS='' read -r -d '' elt || {
                eof="elt"
                read -r -d '' -- "$ret" <<<"${!eof}"
                break 2
            }
            last="$elt"
            cur+=("$elt")
            ((idx++))
        done
    done
    [ -z "$eof" ] || {
        if [ "$last" != 0 ]; then
            echo "Error: ${FUNCNAME[0]} couldn't fill all value" >&2
            read -r -- "$ret" <<<"127"
        else
            if [ -z "${!ret}" ]; then
                echo "Error: last value is empty, did you finish with an errorlevel ?" >&2
                read -r -- "$ret" <<<"126"
            elif ! [[ "${!ret}" =~ ^[0-9]+$ ]]; then
                echo "Error: last value is not a number (is '${!ret}'), did you finish with an errorlevel ?" >&2
                read -r -- "$ret" <<<"125"
            fi
        fi
        false
    }

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
