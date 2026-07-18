#!/bin/sh
##
## This file is part of the sigrok-util project.
##
## Copyright (C) 2013-2018 Uwe Hermann <uwe@hermann-uwe.de>
## Copyright (C) 2018-2026 Frank Stettner <frank-stettner@gmx.net>
##
## This program is free software; you can redistribute it and/or modify
## it under the terms of the GNU General Public License as published by
## the Free Software Foundation; either version 2 of the License, or
## (at your option) any later version.
##
## This program is distributed in the hope that it will be useful,
## but WITHOUT ANY WARRANTY; without even the implied warranty of
## MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
## GNU General Public License for more details.
##
## You should have received a copy of the GNU General Public License
## along with this program; if not, see <http://www.gnu.org/licenses/>.
##

set -e

mkdir -p $INSTALL_DIR

BUILD_DIR=./build
mkdir -p $BUILD_DIR
cd $BUILD_DIR

PY_VER=3.14.6
PY_ABI=314

case "$TARGET" in
  i686)   PY_ARCH=win32 ;;
  x86_64) PY_ARCH=amd64 ;;
esac

# Python headers
$WGET https://www.python.org/ftp/python/$PY_VER/Python-$PY_VER.tgz -O $INSTALL_DIR/Python-src.tgz
mkdir -p $INSTALL_DIR/Python3/include
tar xzf $INSTALL_DIR/Python-src.tgz -C $INSTALL_DIR/Python3/include \
    --strip-components=2 Python-$PY_VER/Include
tar xzf $INSTALL_DIR/Python-src.tgz -C $INSTALL_DIR/Python3/include \
    --strip-components=2 Python-$PY_VER/PC/pyconfig.h
rm -f $INSTALL_DIR/Python-src.tgz


# Cross-compiling Python is highly non-trivial, so we avoid it for now.
# The download below is a repackaged tarball of the official Python 3.4.4 MSI
# installer for Windows:
#   - https://www.python.org/ftp/python/3.4.4/python-3.4.4.msi
#   - https://www.python.org/ftp/python/3.4.4/python-3.4.4.amd64.msi
# The MSI file has been installed on a Windows box and then c:\Python34\libs
# and c:\Python34\include have been stored in the Python34_*.tar.gz tarball.
#$WGET https://sigrok.org/tmp/Python34_$TARGET.tar.gz -O $INSTALL_DIR/Python34.tar.gz
#tar xzf $INSTALL_DIR/Python34.tar.gz -C $INSTALL_DIR

# Fix for bug #1195.
#if [ $TARGET = "x86_64" ]; then
#	patch -p1 $INSTALL_DIR/Python34/include/pyconfig.h < ../contrib-mxe/pyconfig.patch
#fi

# Fix for MXE build error with old Python 3.4
#patch -p1 $INSTALL_DIR/Python34/include/pyerrors.h < ../contrib-mxe/pyerrors.patch

# Runtime + DLL
$WGET https://www.python.org/ftp/python/$PY_VER/python-$PY_VER-embed-$PY_ARCH.zip \
    -O $INSTALL_DIR/python-embed.zip
mkdir -p $INSTALL_DIR/Python3/runtime
unzip -q $INSTALL_DIR/python-embed.zip -d $INSTALL_DIR/Python3/runtime
rm -f $INSTALL_DIR/python-embed.zip

# The python34.dll and python34.zip files will be shipped in the NSIS
# Windows installers (required for SmuView Python scripts to work).
# The file python34.dll (NOT the same as python3.dll) is copied from an
# installed Python 3.4.4 (see above) from c:\Windows\system32\python34.dll.
# The file python34.zip contains all files from the 'DLLs', 'Lib', and 'libs'
# subdirectories from an installed Python on Windows (c:\python34), i.e. some
# libraries and all Python stdlib modules.
#$WGET https://sigrok.org/tmp/python34_$TARGET.dll -O $INSTALL_DIR/python34.dll
#$WGET https://sigrok.org/tmp/python34_$TARGET.zip -O $INSTALL_DIR/python34.zip

# Generate the MinGW-w64 import lib from the DLL
cp $INSTALL_DIR/Python3/runtime/python$PY_ABI.dll .
$MXE_DIR/usr/$TARGET-w64-mingw32.static.posix/bin/gendef python$PY_ABI.dll
$MXE_DIR/usr/bin/$TARGET-w64-mingw32.static.posix-dlltool \
    --dllname python$PY_ABI.dll --def python$PY_ABI.def \
    --output-lib libpython$PY_ABI.a
mkdir -p $INSTALL_DIR/Python3/libs
mv -f libpython$PY_ABI.a $INSTALL_DIR/Python3/libs
rm -f python$PY_ABI.dll python$PY_ABI.def

# In order to link against Python we need libpython34.a.
# The upstream Python 32bit installer ships this, the x86_64 installer
# doesn't. Thus, we generate the file manually here.
#if [ $TARGET = "x86_64" ]; then
#	cp $INSTALL_DIR/python34.dll .
#	$MXE_DIR/usr/$TARGET-w64-mingw32.static.posix/bin/gendef python34.dll
#	$MXE_DIR/usr/bin/$TARGET-w64-mingw32.static.posix-dlltool \
#		--dllname python34.dll --def python34.def \
#		--output-lib libpython34.a
#	mv -f libpython34.a $INSTALL_DIR/Python34/libs
#	rm -f python34.dll
#fi

# We need to include the *.pyd files from python34.zip into the installers,
# otherwise importing certain modules (e.g. ctypes) won't work (bug #1409).
#unzip -q $INSTALL_DIR/python34.zip *.pyd -d $INSTALL_DIR


# Create a dummy python3.pc file so that pkg-config finds Python 3.
mkdir -p $INSTALL_DIR/lib/pkgconfig
cat >$INSTALL_DIR/lib/pkgconfig/python3.pc <<EOF
prefix=$INSTALL_DIR
exec_prefix=\${prefix}
libdir=\${exec_prefix}/Python3/libs
includedir=\${prefix}/Python3/include
Name: Python
Description: Python library
Version: $PY_VER
Libs: -L\${libdir} -lpython$PY_ABI
Cflags: -I\${includedir}
EOF

# libserialport
$GIT_CLONE $LIBSERIALPORT_REPO libserialport
cd libserialport
./autogen.sh
./configure $C $L
make $PARALLEL $V
make install $V
cd ..

# libsigrok
$GIT_CLONE -b ${LIBSIGROK_BRANCH:-master} $LIBSIGROK_REPO libsigrok
cd libsigrok
./autogen.sh
./configure $C $L
make $PARALLEL $V
make install $V
cd ..
