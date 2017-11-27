#! /bin/bash -e

for f in "${INPUT_DIR}" "${ROTATE_DIR}" "${ROTATEPASS_DIR}" "${PASS_DIR}" "${OUTPUT_DIR}" "${TMP_DIR}"; do
    test -d "$f" || mkdir -p "$f"
    chown boar.boar "$f"
    chmod ugo+rwx "$f"
done
for f in "${CONFIG_DIR}"; do
    test -d "$f" || mkdir -p "$f"
    chmod ugo+rx "$f"
done

/ocr.sh

inotifywait -r -m --format '%w%f' -e close_write "${INPUT_DIR}" "${ROTATE_DIR}" "${ROTATEPASS_DIR}" "${PASS_DIR}" |
    while read filename; do
        /ocr.sh "${filename}"
    done
