#!/bin/sh
##
## This file is part of the sigrok-util project.
##
## Copyright (C) 2015 Uwe Hermann <uwe@hermann-uwe.de>
## Copyright (C) 2021 Frank Stettner <frank-stettner@gmx.net>
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
mkdir $BUILD_DIR
cd $BUILD_DIR

# libserialport
$GIT_CLONE $SIGROK_REPO_BASE/libserialport
cd libserialport
./autogen.sh
./configure $C
make $PARALLEL $V
make install $V
cd ..

# libsigrok
$GIT_CLONE $SIGROK_REPO_BASE/libsigrok
cd libsigrok
./autogen.sh
PKG_CONFIG_PATH=$P ./configure $C
make $PARALLEL $V
make install $V
cd ..
