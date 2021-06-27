#!/bin/bash
# README: https://github.com/joehehir/env-SetEnv#readme

set -eu

SCRIPT_NAME="${0##*/}"

errexit() { printf "[${SCRIPT_NAME}] \e[0;31mError: %s\n\e[0m" "${@}"; exit 1; }

[ $# -gt 0 ] || errexit "Not enough arguments"

# reference gnu sed
gnu_sed_bin=$(which sed)
fn_set_sed_bin() {
    fn_has_gnu_sed_bin() { $gnu_sed_bin --version >/dev/null 2>&1; }
    fn_has_gsed() { gsed --version >/dev/null 2>&1; }

    [ fn_has_gnu_sed_bin ] || [ fn_has_gsed ] && {
        gnu_sed_bin=$(which gsed)

        [ fn_has_gnu_sed_bin ] || errexit "GNU sed not found"
    }
}
fn_set_sed_bin

# argument vars
arg_vars=("$@")

# pop configuration path
APACHE_CONF="${arg_vars[$# - 1]}"
arg_vars=("${arg_vars[@]:0:$# - 1}")

# output strings
indentation=""
output=""

[ -f "${APACHE_CONF}" ] || errexit "Configuration '${APACHE_CONF}' not found"

# capture indentation
MARKER_COMMENT_RE="(^[[:space:]]*)#[[:space:]]*!${SCRIPT_NAME}"
has_marker_comment=0

# next marker search
while IFS= read -r conf
do
    if [[ "${conf}" =~ $MARKER_COMMENT_RE ]]
    then
        has_marker_comment=1
        indentation=${BASH_REMATCH[1]}
        break
    fi
done < "${APACHE_CONF}"

[ $has_marker_comment -eq 1 ] || errexit "No marker comment found"

GOT_SPACES_RE="[[:space:]]+"

# read exported env vars
while IFS= read -r exported
do
    key="${exported%%=*}"

    # skip unspecified vars
    if [[ ${#arg_vars[@]} -gt 0 ]] && [[ ! " ${arg_vars[@]} " =~ " ${key} " ]]
    then
        continue
    fi

    value="${exported##*=}"
    value="${value%\"}"; value="${value#\"}"

    # quote strings containing spaces
    [[ $value =~ $GOT_SPACES_RE ]] && value="\"${value}\""

    output="${output}${indentation}SetEnv ${key} ${value}\n"
done <<EOF
$(env)
$([ -f "${PWD}/.env" ] && cat "${PWD}/.env")
EOF

SED_ESCAPED_OUTPUT="${output//[^]/\^}"

# consume next marker and insert
$gnu_sed_bin -i -E \
    -e "0,/!${SCRIPT_NAME}/{s^!${SCRIPT_NAME}(.*$)^${SCRIPT_NAME}\1\n${SED_ESCAPED_OUTPUT}^" \
    -e "}" \
    "${APACHE_CONF}"
