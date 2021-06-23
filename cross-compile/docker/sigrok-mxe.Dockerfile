FROM debian:latest AS sigrok-mxe
MAINTAINER Frank Stettner <frank-stettner@gmx.net>

ENV BASE_DIR /opt
ENV MXE_DIR $BASE_DIR/mxe
ENV MXE_TARGETS "i686-w64-mingw32.static.posix x86_64-w64-mingw32.static.posix"
ENV MXE_PLUGIN_DIRS plugins/examples/qt5-freeze

RUN apt-get update \
	&& apt-get upgrade -y \
	&& apt-get install -y --no-install-recommends \
		sudo \
		autoconf \
		automake \
		autopoint \
		bash \
		bison \
		bzip2 \
		flex \
		g++ \
		g++-multilib \
		gettext \
		git \
		gperf \
		intltool \
		libc6-dev-i386 \
		libgdk-pixbuf2.0-dev \
		libltdl-dev \
		libssl-dev \
		libtool-bin \
		libxml-parser-perl \
		lzip \
		make \
		openssl \
		p7zip-full \
		patch \
		perl \
		pkg-config \
		python \
		ruby \
		sed \
		unzip \
		wget \
		xz-utils \
		doxygen \
		nsis \
	&& apt-get clean \
	&& rm -rf /var/lib/apt/lists/*

WORKDIR $BASE_DIR
COPY mxe_fixes.patch $BASE_DIR
RUN git clone --depth 1 https://github.com/mxe/mxe.git $MXE_DIR \
	&& cd $MXE_DIR \
	&& patch -p1 < $BASE_DIR/mxe_fixes.patch \
	&& make -j$(nproc) MXE_USE_CCACHE= DONT_CHECK_REQUIREMENTS=1 MXE_TARGETS="$MXE_TARGETS" MXE_PLUGIN_DIRS="$MXE_PLUGIN_DIRS" \
		gcc \
		glib \
		libzip \
		libusb1 \
		libftdi1 \
		hidapi \
		glibmm \
		qtbase \
		qtimageformats \
		qtsvg \
		qttranslations \
		boost \
		check \
		gendef \
		libieee1284 \
		nettle \
		qwt \
		qtbase_CONFIGURE_OPTS='-no-sql-mysql' \
	&& rm -rf $MXE_DIR/.log \
	&& rm -rf $MXE_DIR/mxe/pkg
