#! /bin/bash

for f in "${INPUT_DIR}" "${OUTPUT_DIR}" "${CONFIG_DIR}" "${TMP_DIR}"; do
    test -d "$f" || mkdir -p "$f"
done

inotifywait -r -m --format '%w%f' -e close_write "${INPUT_DIR}" |
    while read filename; do
        /ocr.sh "${filename}"
    done
