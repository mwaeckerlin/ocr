#! /bin/bash

function do_ocr() {
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
        chmod -R ugo+rw "${target}-${f##*/}"
    else
        echo "**** WARNING pdfsandwich failed"
        echo "++++ new file ${target}${f##*/}"
        mv "${f}" "${target}${f##*/}"
        chown -R boar.boar "${target}-${f##*/}"
        chmod -R ugo+rw "${target}-${f##*/}"
    fi
}

function process_file() {
    filename="$1"
    case "${filename}" in
        (${INPUT_DIR}*.pdf)
            do_ocr "${filename}"
            ;;
        (${ROTATE_DIR}*.pdf)
            rotated="${filename%.pdf}-rotated.pdf"
            rotated="${OUTPUT_DIR}/${rotated##*/}"
            echo ".... rotating pdf $filename"
            if pdftk "${filename}" cat 1-endeast output "${rotated}"; then
                rm "${filename}"
                do_ocr "${rotated}"
            else
                ! test -e "${rotated}" || rm "${rotated}"
                do_ocr "${filename}"
            fi
            ;;
        (${ROTATEPASS_DIR}*.pdf)
                rotated="${filename%.pdf}-rotated.pdf"
                rotated="${OUTPUT_DIR}/$(date +%Y%m%d-)${rotated##*/}"
                echo ".... rotating pdf $filename"
                if pdftk "${filename}" cat 1-endeast output "${rotated}"; then
                    rm "${filename}"
                else
                    mv "${filename}" "${rotated}"
                fi
                echo "++++ new file ${rotated}"
                chown -R boar.boar "${rotated}"
                chmod -R ugo+rw "${rotated}"
                ;;
        (${ROTATEPASS_DIR}*.jpg)
            rotated="${filename%.jpg}-rotated.jpg"
            rotated="${OUTPUT_DIR}/$(date +%Y%m%d-)${rotated##*/}"
            echo ".... rotating jpg $filename"
            jpegtran -rotate 90 -outfile "${rotated}" "${filename}"
            echo "++++ new file ${rotated}"
            chown -R boar.boar "${rotated}"
            chmod -R ugo+rw "${rotated}"
            ;;
        (${PASS_DIR}*)
            target="${OUTPUT_DIR}/$(date +%Y%m%d-)${filename##*/}"
            mv "${filename}" "${target}"
            echo "++++ new file ${target}"
            chown -R boar.boar "${target}"
            chmod -R ugo+rw "${target}"
            ;;
        (*)
            echo "**** ERROR: Unknown file: ${filename}" 1>&2
            exit 1
            ;;
    esac
}

if test $# -eq 0; then
    for f in $(find "${INPUT_DIR}" "${ROTATE_DIR}" "${ROTATEPASS_DIR}" "${PASS_DIR}" -type f); do
        process_file "$f"
    done
else
    while test $# -gt 0; do
        process_file "$1"
        shift
    done
fi
