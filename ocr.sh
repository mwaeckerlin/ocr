#! /bin/bash

for f in ${INPUT_DIR}/*.pdf; do
    if test -f ${f}; then
        if pdfsandwitch -lang "${LANGUAGE}" -o "${TMP_DIR}/${f##*/}" -resolution "${RESOLUTION}" "${OPTIONS}" "${f}"; then
            target="${TMP_DIR}/$(date +%Y%m%d-)${f##*/}"
            mv "${TMP_DIR}/${f##*/}" "${target}"
        else
            mv "${f}" "${OUTPUT_DIR}"
        fi
    fi
done
