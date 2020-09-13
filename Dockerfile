FROM lsiobase/ubuntu:bionic

# set version label
ARG BUILD_DATE
ARG VERSION
ARG SABNZBD_VERSION
LABEL build_version="Linuxserver.io version:- ${VERSION} Build-date:- ${BUILD_DATE}"
LABEL maintainer="thelamer"

# environment settings
ARG DEBIAN_FRONTEND="noninteractive"
ENV HOME="/config" \
PYTHONIOENCODING=utf-8

RUN \
 echo "***** install gnupg ****" && \
 apt-get update && \
 apt-get install -y \
	gnupg && \
 echo "***** add sabnzbd repositories ****" && \
 apt-key adv --keyserver hkp://keyserver.ubuntu.com:11371 --recv-keys 0x98703123E0F52B2BE16D586EF13930B14BB9F05F && \
 echo "deb http://ppa.launchpad.net/jcfp/nobetas/ubuntu bionic main" >> /etc/apt/sources.list.d/sabnzbd.list && \
 echo "deb-src http://ppa.launchpad.net/jcfp/nobetas/ubuntu bionic main" >> /etc/apt/sources.list.d/sabnzbd.list && \
 echo "deb http://ppa.launchpad.net/jcfp/sab-addons/ubuntu bionic main" >> /etc/apt/sources.list.d/sabnzbd.list && \
 echo "deb-src http://ppa.launchpad.net/jcfp/sab-addons/ubuntu bionic main" >> /etc/apt/sources.list.d/sabnzbd.list && \
 echo "**** install packages ****" && \
 apt-get update && \
 apt-get install -y \
	libffi-dev \
	libssl-dev \
	p7zip-full \
	par2-tbb \
	python3 \
	python3-cryptography \
	python3-distutils \
	python3-pip \
	ffmpeg \
	nano \
	git \
	unrar && \
 if [ -z ${SABNZBD_VERSION+x} ]; then \
	SABNZBD_VERSION=$(curl -s https://api.github.com/repos/sabnzbd/sabnzbd/releases/latest \
	| awk '/tag_name/{print $4;exit}' FS='[""]'); \
 fi && \
 mkdir -p /app/sabnzbd && \
 curl -o \
	/tmp/sabnzbd.tar.gz -L \
	"https://github.com/sabnzbd/sabnzbd/releases/download/${SABNZBD_VERSION}/SABnzbd-${SABNZBD_VERSION}-src.tar.gz" && \
 tar xf \
	/tmp/sabnzbd.tar.gz -C \
	/app/sabnzbd --strip-components=1 && \
 cd /app/sabnzbd && \
 pip3 install -U pip && \
 pip install -U --no-cache-dir \
	apprise \
	pynzb \
    chardet \
    requests \
	requests[security] \
	requests-cache \
	babelfish \
	tmdbsimple \
	idna \
	mutagen \
	guessit \
	subliminal \
	python-dateutil \
	stevedore \
	qtfaststart \
	setuptools \
	requests && \
 pip install -U --no-cache-dir -r requirements.txt && \
 echo "**** cleanup ****" && \
 ln -s \
	/usr/bin/python3 \
	/usr/bin/python && \
 apt-get purge --auto-remove -y \
	libffi-dev \
	libssl-dev \
	python3-pip && \
 apt-get clean
#mp4automator
RUN git clone https://github.com/pazport/sickbeard_mp4_automator.git mp4automator
RUN chmod -R 777 /mp4automator
RUN chown -R 1000:1000 /mp4automator
RUN ln -s /config/mp4automator /mp4automator

#update and install latest ffmpeg
RUN pip3 install -U pip --no-cache-dir
RUN apt-get update && apt-get upgrade -y
RUN apt-get install software-properties-common -y
RUN add-apt-repository ppa:savoury1/graphics -y
RUN add-apt-repository ppa:savoury1/multimedia -y
RUN add-apt-repository ppa:savoury1/ffmpeg4 -y
RUN apt-get update && apt-get upgrade -y
RUN apt-get install ffmpeg -y
RUN apt-get update && apt-get upgrade -y
RUN pip install -U --no-cache-dir feedparser==5.2.1

# add local files
COPY root/ /

# ports and volumes
EXPOSE 8080 9090
VOLUME /config
