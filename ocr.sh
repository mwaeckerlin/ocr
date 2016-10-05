#! /bin/bash

for f in ${INPUT_DIR}/*.pdf; do
    if test -f ${f}; then
        out="${TMP_DIR}/${f##*/}"
        target="${OUTPUT_DIR}/$(date +%Y%m%d-)"
        if pdfsandwich -lang "${LANGUAGE}" -o "${out}" -maxpixels "${MAXPIXELS}" -resolution "${RESOLUTION}" "${OPTIONS}" "${f}" && test -f "${out}"; then
            for c in ${CONFIG_DIR}/*; do
                if test -f "$c"; then
                    target+=$(grep -if "$c" "$out" | tr "[:upper:]\n" "[:lower:]-")
                fi
            done
            mv "${out}" "${target}${f##*/}" && rm "$f"
        else
            mv "${f}" "${target}${f##*/}"
        fi
    fi
done
