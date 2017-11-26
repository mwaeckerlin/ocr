#! /bin/bash

f="$1"
out="${TMP_DIR}/${f##*/}"
target="${OUTPUT_DIR}/$(date +%Y%m%d)"
echo ".... processing pdf $f"
if pdfsandwich -lang "${LANGUAGE}" -o "${out}" -maxpixels "${MAXPIXELS}" -resolution "${RESOLUTION}" ${OPTIONS} "${f}" 2> /dev/null && test -f "${out}"; then
    pdftotext "${out}" "${out%.pdf}.txt"
    for c in ${CONFIG_DIR}/*; do
        if test -f "$c"; then
            while read l; do
                if grep -qi "$l" "${out%.pdf}.txt"; then
                    target+="-$(echo $l | tr '[:upper:] ' '[:lower:]-')"
                    break
                fi
            done < "$c"
        fi
    done
    echo "++++ new file ${target}-${f##*/}"
    mv "${out}" "${target}-${f##*/}" && rm "$f"
    chown -R boar.boar "${target}-${f##*/}"
    chmod -R +rw "${target}-${f##*/}"
else
    echo "**** WARNING pdfsandwich failed"
    echo "++++ new file ${target}${f##*/}"
    mv "${f}" "${target}${f##*/}"
    chown -R boar.boar "${target}-${f##*/}"
    chmod -R +rw "${target}-${f##*/}"
fi
