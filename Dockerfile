FROM boar-data
MAINTAINER mwaeckerlin
env TERM=xterm

env INPUT_DIR=/home/ftp/upload
env OUTPUT_DIR=/data/dokumente
env CONFIG_DIR=/data/configs/scan
env TMP_DIR=/tmp
env LANGUAGE=deu
env RESOLUTION=600
env OPTIONS="-quiet -rgb -enforcehocr2pdf -sloppy_text"
env MAXPIXELS=40000000

RUN apt-get update
RUN apt-get upgrade -y
RUN apt-get install -y pdfsandwich inotify-tools poppler-utils
RUN apt-get install -y tesseract-ocr-.*

ADD ocr.sh /ocr.sh
ADD start.sh /start.sh
CMD /start.sh
