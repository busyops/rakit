#!/bin/bash
SRC_FILE="Rakit.sh"
TMP_FILE="/tmp/Rakit.sh"

cp "$SRC_FILE" "$TMP_FILE"

tmp_clean=$(mktemp)

egrep -v "^[[:space:]]*$" "$TMP_FILE" \
| egrep -v "^###.*" \
| sed 's/^[[:space:]]*//' \
| egrep -v "^[[:space:]]*#{2,}" \
| sed -E 's/^(address|netmask)\b/    \1/' \
> "$tmp_clean"

mv "$tmp_clean" "$TMP_FILE"
