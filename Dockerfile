FROM lsiobase/ubuntu:bionic

# set version label
ARG BUILD_DATE
ARG VERSION
ARG SNIBOX_VERSION
LABEL build_version="Linuxserver.io version:- ${VERSION} Build-date:- ${BUILD_DATE}"
LABEL maintainer="alex-phillips"

ARG BUILD_PACKAGES="\
	cmake \
	g++ \
	gcc \
	git \
	libboost-dev \
	libncurses-dev \
	libbz2-dev \
	libssl-dev \
	make"

# packages as variables
ARG RUNTIME_PACKAGES="\
	libboost-filesystem-dev \
	libboost-iostreams-dev \
	libboost-program-options-dev \
	libboost-system-dev \
	libboost-thread-dev \
	libmariadbclient-dev \
	libreadline-dev \
	mariadb-client \
	screen"

RUN \
 apt update && \
 echo "**** install build packages ****" && \
 apt-get install -y \
 	--no-install-recommends \
	$BUILD_PACKAGES && \
 apt-get install -y \
 	--no-install-recommends \
	$RUNTIME_PACKAGES && \
 echo "**** clone singlecore ****" && \
 git clone --branch 3.3.5 https://github.com/TrinityCore/TrinityCore /trinitycore && \
 cd /trinitycore && \
 git checkout e0835b4673 && \
 mkdir build && \
 cd build && \
 cmake ../ -DCMAKE_INSTALL_PREFIX=/app/server && \
 make -j $(nproc) install && \
 echo "**** cleanup ****" && \
 rm -rf /trinitycore/build
#  apt-get purge -y --auto-remove \
# 	$BUILD_PACKAGES && \
#  rm -rf \
# 	/root/.cache \
# 	/tmp/*

# copy local files
COPY root/ /
