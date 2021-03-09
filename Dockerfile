FROM debian:buster-slim

# environment settings
ARG DEBIAN_FRONTEND="noninteractive"
ENV HOME="/config" \
PYTHONIOENCODING=utf-8

RUN \
 echo "**** install apt-transport-https first ****" && \
 apt-get update && \
 apt-get install -y apt-transport-https gnupg2 curl && \
 echo "**** install packages ****" && \
 echo "deb http://ftp.nl.debian.org/debian buster main non-free" >> /etc/apt/sources.list.d/sabnzbd.list && \
 apt-get update && \
 apt-get install -y \
	libffi-dev \
	libssl-dev \
	p7zip-full \
	automake \
	make \
	python3 \
	python3-cryptography \
	python3-distutils \
	python-sabyenc \
	par2-tbb \
	python3-pip \
	nano \
        git \
	unrar && \
 echo "**** installing par2cmdline ****" && \
 git clone https://github.com/Parchive/par2cmdline.git && \
 cd par2cmdline && \
 aclocal && \
 automake --add-missing && \
 autoconf && \
 ./configure && \
 make && \
 make install && \
 cd / && \
 rm -rf par2cmdline && \
 echo "**** installing sabnzbd ****" && \
 cd /opt && \
 git clone https://github.com/sabnzbd/sabnzbd.git && \
 cd sabnzbd && \
 git checkout master && \
  pip3 install -U pip --no-cache-dir \
    apprise \
    chardet \
    pynzb \
	setuptools \
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
    sabyenc && \
 pip install -U --no-cache-dir -r requirements.txt

 #mp4automator
RUN git clone https://github.com/pazport/sickbeard_mp4_automator.git /mp4automator
RUN chmod -R 777 /mp4automator
RUN chown -R 1000:1000 /mp4automator
RUN ln -s /config/mp4automator /mp4automator

#update and install latest ffmpeg
RUN pip3 install -U pip --no-cache-dir
RUN apt-get install software-properties-common -y
RUN apt-get update
RUN apt-get upgrade -y
RUN apt-get install ffmpeg -y
RUN apt-get update 
RUN apt upgrade -y

WORKDIR /opt/sabnzbd
COPY start.sh .
COPY healthcheck.sh .
RUN chmod +x *.sh

EXPOSE 8080
VOLUME /config

HEALTHCHECK --interval=90s --timeout=10s \
  CMD /opt/sabnzbd/healthcheck.sh

ENTRYPOINT ["/opt/sabnzbd/start.sh"]