#!/bin/bash

if [[ $# -eq 0 ]]
then
    echo 'Please provide the crossfire-client-gtk2 binary.'
    exit 1
fi

NICENAME="Crossfire GTK 2 Client"
APPNAME="Crossfire-GTK2"
APPDIR="$APPNAME.app"
INSTALLDIR="/Applications/$APPDIR"
DMGDIR="Crossfire-GTK2"
MACDIR="$APPDIR/Contents/MacOS"
RESDIR="$APPDIR/Contents/Resources"
INFOPL="$APPDIR/Contents/Info.plist"
SCRIPT="$MACDIR/$APPNAME"
LIBDIR="/opt/homebrew"
ICONS="$RESDIR/$APPNAME.icns"
LONGVER="1.0.0-unknown"
SHORTVER="1.0.0"
THEMETAR="https://github.com/vinceliuice/WhiteSur-gtk-theme/raw/refs/heads/master/release/WhiteSur-Light.tar.xz"

LAUNCH_ENV="DYLD_LIBRARY_PATH=\$DIR/Resources GTK2_RC_FILES=\$DIR/Resources/gtk-2.0/gtkrc"

echo " * Getting Version"
if command -v git 2>&1 >/dev/null
then
    LONGVER=$(git describe --tags)
    SHORTVER=$(git describe --tags --abbrev=0)
    echo "  ok"
else
    echo "  ! git missing"
fi

echo " * Removing/Creating app directories "
rm -rf $APPDIR
mkdir -p $MACDIR
mkdir -p $RESDIR/bin
echo "  ok"

# Create our icns if possible.
echo " * Creating icons"
if command -v icns2png 2>&1 >/dev/null
then
    png2icns $ICONS ../pixmaps/48x48.png
    echo "  ok"
else
    echo "  ! icns2png missing"
fi

# Copy crossfire binary to our resource dir
PROGPATH="$RESDIR/bin/$(basename $1)"
echo " * Copying $1 to $PROGPATH"
cp $1 $PROGPATH
echo "  ok"

# Find and copy all used dylibs to our resources dir and fix our binary to point to our local ones.
echo " * Copying libraries and adjusting binary lib paths"
otool -L $PROGPATH
LIBS=$(otool -L $PROGPATH | grep -E '^\s*$LIBDIR/(.*)' | awk -F ' ' '{print $1}')
for i in $LIBS
do
	echo $i
	cp $i $RESDIR
	install_name_tool -change $i @executable_path/$(basename $i) $PROGPATH
done
echo "  ok"

# Create our plist file.
echo " * Writing Info.plist"
cat <<EOF> $INFOPL
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>CFBundleInfoDictionaryVersion</key>
    <string>6.0</string>
    <key>CFBundleDevelopmentRegion</key>
    <string>en</string>
    <key>CFBundlePackageType</key>
    <string>APPL</string>
    <key>CFBundleIdentifier</key>
    <string>com.real-time.crossfire.$APPNAME</string>
    <key>CFBundleExecutable</key>
    <string>$APPNAME</string>
    <key>CFBundleIconFile</key>
    <string>$APPNAME.icns</string>
    <key>CFBundleDisplayName</key>
    <string>$NICENAME</string>
    <key>CFBundleName</key>
    <string>$APPNAME</string>
    <key>CFBundleVersion</key>
    <string>$LONGVER</string>
    <key>CFBundleShortVersionString</key>
    <string>$SHORTVER</string>
    <key>NSHumanReadableCopyright</key>
    <string>(c) 2024, The Crossfire Developers</string>
    <key>CFBundleSignature</key>
    <string>????</string>
</dict>
</plist>
EOF
echo "  ok"

# Create our launcher script

echo " * Creating launcher script"
cat <<EOF> $SCRIPT
#!/bin/bash
DIR=\$(cd "\$(dirname "\$0")"/..; pwd)
cd \$DIR/Resources
$LAUNCH_ENV \$DIR/Resources/bin/crossfire-client-gtk2
EOF
chmod +x $SCRIPT
echo "  ok"

# Get a nicer theme

echo " * Downloading and embedding GTK Theme"
mkdir theme
curl -s -L $THEMETAR | tar zxvf - -C theme --strip-components=1
mv theme/gtk-2.0 $RESDIR/
rm -rf theme
echo "  ok"

# Copy over share
cp -rfpv share $RESDIR/

# Create a DMG as well.

git clone https://github.com/create-dmg/create-dmg.git create-dmg
./create-dmg/create-dmg \
--volname "$APPNAME-Installer" \
--volicon "$ICONS" \
--window-size 550 442 \
--icon-size 48 \
--icon $APPDIR 125 180 \
--hide-extension $APPDIR \
--app-drop-link 415 180 \
"$DMGDIR.dmg" \
"$APPDIR"
