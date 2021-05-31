#!/bin/sh
##
## This file is part of the sigrok-util project.
##
## Copyright (C) 2017 Uwe Hermann <uwe@hermann-uwe.de>
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
set -x

# Path to Qt5 binaries.
QTBINDIR=`brew list $QTVER | grep bin | head -n 1 | xargs dirname`

# Path to Python 3 framework.
PYTHONFRAMEWORKDIR=`brew list python3 | grep Python.framework/Python | head -n 1 | xargs dirname`

# Get Python version
PYVER=`python3 -c 'import sys; print(".".join(map(str, sys.version_info[0:2])))'`

DMG_BUILD_DIR=./build_dmg
mkdir $DMG_BUILD_DIR
cd $DMG_BUILD_DIR

CONTENTSDIR="$SV_TITLE.app/Contents"
MACOSDIR="$CONTENTSDIR/MacOS"
FRAMEWORKSDIR="$CONTENTSDIR/Frameworks"
PYDIR="$FRAMEWORKSDIR/Python.framework/Versions/$PYVER"

mkdir -p $MACOSDIR $FRAMEWORKSDIR

cp $INSTALL_DIR/bin/$SV_BIN_NAME $MACOSDIR

$QTBINDIR/macdeployqt $SV_TITLE.app

# Copy Python framework and fix it up.
cp -R $PYTHONFRAMEWORKDIR $FRAMEWORKSDIR
chmod 644 $PYDIR/lib/libpython*.dylib
rm -rf $PYDIR/Headers
rm -rf $PYDIR/bin
rm -rf $PYDIR/include
rm -rf $PYDIR/share
rm -rf $PYDIR/lib/pkgconfig
rm -rf $PYDIR/lib/python$PYVER/lib2to3
rm -rf $PYDIR/lib/python$PYVER/distutils
rm -rf $PYDIR/lib/python$PYVER/idlelib
rm -rf $PYDIR/lib/python$PYVER/test
rm -rf $PYDIR/lib/python$PYVER/**/test
rm -rf $PYDIR/lib/python$PYVER/tkinter
rm -rf $PYDIR/lib/python$PYVER/turtledemo
rm -rf $PYDIR/lib/python$PYVER/unittest
rm -rf $PYDIR/lib/python$PYVER/__pycache__
rm -rf $PYDIR/lib/python$PYVER/**/__pycache__
rm -rf $PYDIR/lib/python$PYVER/**/**/__pycache__
rm -rf $PYDIR/Resources
install_name_tool -change \
	/usr/local/opt/python/Frameworks/Python.framework/Versions/$PYVER/Python \
	@executable_path/../Frameworks/Python.framework/Versions/$PYVER/Python \
	$MACOSDIR/$SV_BIN_NAME

# Add SmuView wrapper (sets PYTHONHOME).
mv $MACOSDIR/$SV_BIN_NAME $MACOSDIR/$SV_BIN_NAME.real
cat > $MACOSDIR/$SV_BIN_NAME << EOF
#!/bin/sh

DIR="\$(dirname "\$0")"
cd "\$DIR"
export PYTHONHOME="../Frameworks/Python.framework/Versions/$PYVER"
exec ./$SV_BIN_NAME.real "\$@"
EOF
chmod 755 $MACOSDIR/$SV_BIN_NAME

xsltproc --stringparam VERSION "${SV_VERSION_STRING}" -o $CONTENTSDIR/Info.plist ../contrib-macos/Info-smuview.xslt ../contrib-macos/Info-smuview.plist
cp ../contrib-macos/smuview.icns $CONTENTSDIR/Resources

hdiutil create "${SV_TITLE}-${SV_VERSION_STRING}.dmg" -volname "$SV_TITLE $SV_VERSION_STRING" \
	-fs HFS+ -srcfolder "$SV_TITLE.app"

# Move DMG to parent directory, so it is accessible without knowing $DMG_BUILD_DIR
mv "${SV_TITLE}-${SV_VERSION_STRING}.dmg" ..
