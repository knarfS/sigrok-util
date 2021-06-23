FROM i386/ubuntu:18.04
MAINTAINER Frank Stettner <frank-stettner@gmx.net>

ENV DEBIAN_FRONTEND noninteractive
ENV BASE_DIR /opt
# AppImage related setting
ENV APPIMAGE_EXTRACT_AND_RUN 1
ENV ARCH i386

RUN apt-get update \
	&& apt-get upgrade -y \
	# Install basic stuff
	&& apt-get install -y --no-install-recommends \
		sudo bash apt-utils software-properties-common git \
		wget ca-certificates gnupg2 unzip bzip2 lzip sed \
	# Install build stuff
	&& apt-get install -y --no-install-recommends \
		gcc g++ make autoconf autoconf-archive automake libtool \
		pkg-config check doxygen swig shellcheck \
	# Install libserialport, libsigrok and smuview dependencies
	&& apt-get install -y --no-install-recommends \
		libglib2.0-dev libglibmm-2.4-dev libzip-dev libusb-1.0-0-dev \
		libftdi1-dev libhidapi-dev libbluetooth-dev libvisa-dev nettle-dev \
		libavahi-client-dev libieee1284-3-dev libboost1.65-dev \
	# Install Qt stuff
	&& apt-get install -y --no-install-recommends \
		qt5-default qtbase5-dev libqt5svg5-dev libqwt-qt5-dev \
	#
	# Update certificates
	&& update-ca-certificates \
	#
	# Install current cmake
	&& wget https://apt.kitware.com/keys/kitware-archive-latest.asc \
	&& apt-key add kitware-archive-latest.asc \
	&& apt-add-repository 'deb https://apt.kitware.com/ubuntu/ bionic main' \
	&& apt-get update \
	&& apt-get install -y kitware-archive-keyring \
	&& apt-key --keyring /etc/apt/trusted.gpg del C1F34CDD40CD72DA \
	&& apt-get install -y cmake \
	#
	# Cleanup apt
	&& apt-get clean \
	&& rm -rf /var/lib/apt/lists/*
	##
	## Install Qt 5.12.9 LTS
	#&& add-apt-repository -y ppa:beineri/opt-qt-5.12.9-bionic \
	#&& apt-get update \
	#&& apt-get install -y qt512base qt512svg qt512tools qt512translations \
	#&& . /opt/qt512/bin/qt512-env.sh \
	##
	## Install Qwt 6.1.5
	#&& apt-get install -y mesa-common-dev libgl1-mesa-dev \
	#&& wget https://sourceforge.net/projects/qwt/files/qwt/6.1.5/qwt-6.1.5.tar.bz2 \
	#&& tar xf qwt-6.1.5.tar.bz2 \
	#&& cd qwt-6.1.5 \
	## Change the QWT_INSTALL_PREFIX in qwtconfig.pri to /usr
	#&& sed -i 's|^\([[:space:]]*QWT_INSTALL_PREFIX[[:space:]]*=[[:space:]]*\)/usr.*$|\1/usr|g' qwtconfig.pri \
	#&& qmake qwt.pro \
	#&& make \
	#&& make install \
	## Cleanup
	#&& cd .. \
	#&& rm qwt-6.1.5.tar.bz2 \
	#&& rm -rf qwt-6.1.5 \
