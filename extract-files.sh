#!/bin/sh

VENDOR=samsung
DEVICE=fascinatemtd

log() { printf %s\\n "$*"; }
error() { log "ERROR: $@" >&2; }
fatal() { error "$@"; exit 1; }
try() { "$@" || fatal "'$*' failed"; }

mydir=$(try dirname "$0") || exit 1
try cd "${mydir}"

BASE=../../../vendor/$VENDOR/$DEVICE/proprietary
try rm -rf "${BASE}"
CMD="adb pull "

if [ -e "$1" ]; then
    try rm -rf tmp
    try mkdir tmp
    unzip -q "$1" -d tmp || fatal "Failed to unzip $1"
    CMD="cp tmp"
fi

log "Copying proprietary files from device..."
# first make sure we can read proprietary-files.txt
proprietary_files_txt=$(try cat proprietary-files.txt) || exit 1
# filter out comments and blank/whitespace-only lines
printf %s\\n "${proprietary_files_txt}" |
grep -Ev '^[[:space:]]*(#|$)' |
while IFS= read -r FILE; do
    DIR=$(try dirname "${FILE}") || exit 1
    try mkdir -p "${BASE}"/"${DIR}"
    log "  /system/${FILE}"
    ${CMD}/system/"${FILE}" "${BASE}"/"${FILE}" \
        || fatal "Failed to pull or copy $FILE"
done || exit 1

try rm -rf tmp

./setup-makefiles.sh || exit 1
