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

COPY addons /tmp/

RUN \
 ls -altr /tmp/ && \
 apt update && \
 echo "**** install build packages ****" && \
 apt-get install -y \
 	--no-install-recommends \
	$BUILD_PACKAGES && \
 apt-get install -y \
 	--no-install-recommends \
	$RUNTIME_PACKAGES && \
 echo "**** clone TrinityCore ****" && \
 git clone --branch 3.3.5 https://github.com/TrinityCore/TrinityCore /trinitycore && \
 cd /trinitycore && \
 git checkout c73037322e && \
 rm -rf .git && \
 echo "**** installing Eluna ****" && \
 git clone https://github.com/ElunaLuaEngine/ElunaTrinityWotlk.git && \
 cd ElunaTrinityWotlk && \
 git submodule init && \
 git submodule update && \
 echo "**** installing Solocraft ****" && \
 cd /trinitycore/src/server/scripts/Custom && \
 mv /tmp/Solocraft.cpp . && \
 patch -p1 custom_script_loader.cpp < /tmp/solocraft.patch && \
 echo "**** installing npcbots ****" && \
 git clone https://bitbucket.org/trickerer/trinity-bots.git /trinity-bots && \
 mv /trinity-bots/last/NPCBots.patch /trinitycore && \
 cd /trinitycore && \
 patch -p1 < NPCBots.patch && \
 echo "**** building core ****" && \
 cd /trinitycore && \
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
