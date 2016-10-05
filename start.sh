#! /bin/bash

apt-get install -y tesseract-ocr-${LANGUAGE}

cron -fl7
