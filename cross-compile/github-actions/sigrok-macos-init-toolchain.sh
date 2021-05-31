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

export PARALLEL="-j "`sysctl -n hw.ncpu`

# We use Qt 5.15.x
export QTVER=qt@5

# Path to Qt5 binaries (needed for cmake to find the Qt5 libs).
export PATH="$(brew --prefix $QTVER)/bin:$PATH"

# PKG_CONFIG_PATH will need to point to pkg-config files of Homebrew's
# keg-only formulae.
P="$INSTALL_DIR/lib/pkgconfig"
for FORMULA in libffi python@3 "$QTVER"; do
    P="$P:$(brew --prefix "$FORMULA")/lib/pkgconfig"
done
export P

# Extra options to pass to configure.
export C="$C --prefix=$INSTALL_DIR"
