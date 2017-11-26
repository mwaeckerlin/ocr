#! /bin/bash -e

for f in "${INPUT_DIR}" "${ROTATE_DIR}" "${ROTATEPASS_DIR}" "${PASS_DIR}" "${OUTPUT_DIR}" "${CONFIG_DIR}" "${TMP_DIR}"; do
    test -d "$f" || ( mkdir -p "$f" && chown -R boar.boar "$f" )
done

/ocr.sh

inotifywait -r -m --format '%w%f' -e close_write "${INPUT_DIR}" "${ROTATE_DIR}" "${ROTATEPASS_DIR}" "${PASS_DIR}" |
    while read filename; do
        case "${filename}" in
            (${INPUT_DIR}*.pdf)
                /ocr.sh "${filename}"
                ;;
            (${ROTATE_DIR}*.pdf)
                rotated="${filename%.pdf}-rotated.pdf"
                rotated="${OUTPUT_DIR}/${rotated##*/}"
                echo ".... rotating pdf $filename"
                if pdftk "${filename}" cat 1-endeast output "${rotated}"; then
                    rm "${filename}"
                    /ocr.sh "${rotated}"
                else
                    ! test -e "${rotated}" || rm "${rotated}"
                    /ocr.sh "${filename}"
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
                chmod -R +rw "${rotated}"
                ;;
            (${ROTATEPASS_DIR}*.jpg)
                rotated="${filename%.jpg}-rotated.jpg"
                rotated="${OUTPUT_DIR}/$(date +%Y%m%d-)${rotated##*/}"
                echo ".... rotating jpg $filename"
                jpegtran -rotate 90 -outfile "${rotated}" "${filename}"
                echo "++++ new file ${rotated}"
                chown -R boar.boar "${rotated}"
                chmod -R +rw "${rotated}"
                ;;
            (${PASS_DIR}*)
                target="${OUTPUT_DIR}/$(date +%Y%m%d-)${filename##*/}"
                mv "${filename}" "${target}"
                echo "++++ new file ${target}"
                chown -R boar.boar "${target}"
                chmod -R +rw "${target}"
                ;;
            (*)
                echo "**** ERROR: Unknown file: ${filename}" 1>&2
                exit 1
                ;;
        esac
    done
