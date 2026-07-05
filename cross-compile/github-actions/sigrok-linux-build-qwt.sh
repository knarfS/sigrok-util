#!/bin/sh
##
## This file is part of the sigrok-util project.
##
## Copyright (C) 2022-2026 Frank Stettner <frank-stettner@gmx.net>
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
set -x

mkdir -p $INSTALL_DIR

BUILD_DIR=./build
mkdir -p $BUILD_DIR
cd $BUILD_DIR

# Qwt 6.1.6
$WGET https://sourceforge.net/projects/qwt/files/qwt/6.3.0/qwt-6.3.0.tar.bz2
tar xf qwt-6.3.0.tar.bz2
cd qwt-6.3.0
qmake qwt.pro
make $PARALLEL $V
# Change the QWT_INSTALL_PREFIX in qwtconfig.pri to $INSTALL_DIR
sed -i 's|^\([[:space:]]*QWT_INSTALL_PREFIX[[:space:]]*=[[:space:]]*\)/usr.*$|\1'"$INSTALL_DIR"'|g' qwtconfig.pri
make install $V
