FROM ubuntu
MAINTAINER mwaeckerlin
env TERM=xterm

env INPUT_DIR=/home/ftp/upload
env OUTPUT_DIR=/boar/dokumente
env CONFIG_DIR=/boar/configs/scan
env TMP_DIR=/tmp
env LANGUAGE=ger
env RESOLUTION=600x600
env OPTIONS="-quiet -rgb"

RUN apt-get install pdfsandwich

ADD start.sh /start.sh
RUN /start.sh
