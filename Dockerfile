FROM ubuntu
MAINTAINER mwaeckerlin
env TERM=xterm

env INPUT_DIR=/home/ftp/upload
env OUTPUT_DIR=/boar/dokumente
env CONFIG_DIR=/boar/configs/scan
env TMP_DIR=/tmp
env LANGUAGE=deu
env RESOLUTION=600
env OPTIONS="-quiet -rgb -enforcehocr2pdf -sloppy_text"
env MAXPIXELS=40000000

RUN apt-get update
RUN apt-get upgrade -y
RUN apt-get install -y pdfsandwich cron poppler-utils

ADD ocr.sh /etc/cron.hourly/ocr
ADD start.sh /start.sh
CMD /start.sh
