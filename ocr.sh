#! /bin/bash

do_file() {
    f="$1"
    if test -f ${f}; then
        if [[ ${f} =~ .pdf$ ]]; then
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
                chmod -R ugo+rw "${target}-${f##*/}"
            else
                echo "**** WARNING pdfsandwich failed"
                echo "++++ new file ${target}${f##*/}"
                mv "${f}" "${target}${f##*/}"
                chown -R boar.boar "${target}-${f##*/}"
                chmod -R ugo+rw "${target}-${f##*/}"
            fi
        else
            target="${OUTPUT_DIR}/$(date +%Y%m%d-)"
            out="$f"
            echo "++++ new file ${target}${f##*/}"
            mv "${out}" "${target}${f##*/}"
            chown -R boar.boar "${target}-${f##*/}"
            chmod -R ugo+rw "${target}-${f##*/}"
        fi
    else
        echo "**** ERROR not a file $f"
    fi
}

if test $# -gt 0; then
    while test $# -gt 0; do
        do_file "$1"
        shift
    done
else
    for f in ${INPUT_DIR}/*; do
        if test -f ${f}; then
            do_file "$f"
        fi
    done
fi
