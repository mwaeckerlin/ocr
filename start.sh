#! /bin/bash -e

for f in "${INPUT_DIR}" "${ROTATE_DIR}" "${ROTATEPASS_DIR}" "${PASS_DIR}" "${OUTPUT_DIR}" "${CONFIG_DIR}" "${TMP_DIR}"; do
    test -d "$f" || mkdir -p "$f"
    chmod +rwx "$f"
done

/ocr.sh

inotifywait -r -m --format '%w%f' -e close_write "${INPUT_DIR}" "${ROTATE_DIR}" "${ROTATEPASS_DIR}" "${PASS_DIR}" |
    while read filename; do
        /ocr.sh "${filename}"
    done
