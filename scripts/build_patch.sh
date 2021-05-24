#!/bin/bash
#
##############################################################
# File name       : build_patch.sh
#
# Description     : BiTGApps build script
#
# Copyright       : Copyright (C) 2018-2021 TheHitMan7
#
# License         : GPL-3.0-or-later
##############################################################
# The BiTGApps scripts are free software: you can redistribute it
# and/or modify it under the terms of the GNU General Public License
# as published by the Free Software Foundation, either version 3 of
# the License, or (at your option) any later version.
#
# These scripts are distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
# GNU General Public License for more details.
##############################################################

# Check existance of required tools and notify user of missing tools
command -v grep >/dev/null 2>&1 || { echo "! GREP is required but it's not installed. Aborting..." >&2; exit 1; }
command -v install >/dev/null 2>&1 || { echo "! Coreutils is required but it's not installed. Aborting..." >&2; exit 1; }
command -v java >/dev/null 2>&1 || { echo "! JAVA is required but it's not installed. Aborting..." >&2; exit 1; }
command -v tar >/dev/null 2>&1 || { echo "! TAR is required but it's not installed. Aborting..." >&2; exit 1; }
command -v zip >/dev/null 2>&1 || { echo "! ZIP is required but it's not installed. Aborting..." >&2; exit 1; }

# Check availability of environmental variables
if { [ ! -n "$COMMONPATCHRELEASE" ] ||
     [ ! -n "$PATCH_RELEASE" ]; }; then
     echo "! Environmental variables not set. Aborting..."
  exit 1
fi

# Set defaults
ARCH="generic"
PATCH="$1"

# Build defaults
BUILDDIR="build"
OUTDIR="out"

# Signing tool
ZIPSIGNER="BiTGApps/tools/zipsigner-resources/zipsigner.jar"

# Set installer sources
INSTALLER="BiTGApps/scripts/installer.sh"
BUSYBOX="BiTGApps/tools/busybox-resources/busybox-arm"

# Set patched keystore sources
API_26_KEYSTORE="BiTGApps/tools/safetynet-resources/26"
API_27_KEYSTORE="BiTGApps/tools/safetynet-resources/27"
API_28_KEYSTORE="BiTGApps/tools/safetynet-resources/28"
API_29_KEYSTORE="BiTGApps/tools/safetynet-resources/29"
API_30_KEYSTORE="BiTGApps/tools/safetynet-resources/30"

# Set Boot Image Editor sources
AIK_ARMEABI="BiTGApps/tools/aik-resources/armeabi-v7a"
AIK_AARCH64="BiTGApps/tools/aik-resources/arm64-v8a"

# Set ZIP structure
METADIR="META-INF/com/google/android"
ZIP="zip"

# replace_line <file> <line replace string> <replacement line>
replace_line() {
  if grep -q "$2" $1; then
    local line=$(grep -n "$2" $1 | head -n1 | cut -d: -f1)
    sed -i "${line}s;.*;${3};" $1
  fi
}

# Set updater script
makeupdaterscript() {
echo '# Dummy file; update-binary is a shell script.' >"$BUILDDIR/$ARCH/$RELEASEDIR/$METADIR/updater-script"
}

# Set update binary
makeupdatebinary() {
echo '#!/sbin/sh
#
##############################################################
# File name       : update-binary
#
# Description     : Setup installation, environmental variables
#                   and helper functions
#
# Copyright       : Copyright (C) 2018-2021 TheHitMan7
#
# License         : GPL-3.0-or-later
##############################################################
# The BiTGApps scripts are free software: you can redistribute it
# and/or modify it under the terms of the GNU General Public License
# as published by the Free Software Foundation, either version 3 of
# the License, or (at your option) any later version.
#
# These scripts are distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
# GNU General Public License for more details.
##############################################################

# Set environmental variables in the global environment
export ZIPFILE="$3"
export OUTFD="$2"
export TMP="/tmp"
export ASH_STANDALONE=1

# Check unsupported architecture and abort installation
# without any error message
ARCH=$(uname -m)
if [ "$ARCH" == "x86" ] || [ "$ARCH" == "x86_64" ]; then exit 1; fi

# Extract installer script
unzip -o "$ZIPFILE" "installer.sh" -d "$TMP"
chmod +x "$TMP/installer.sh"

# Extract utility script
unzip -o "$ZIPFILE" "util_functions.sh" -d "$TMP"
chmod +x "$TMP/util_functions.sh"

# Execute installer script
exec $TMP/busybox-arm sh "$TMP/installer.sh" "$@"
exit "$?"' >"$BUILDDIR/$ARCH/$RELEASEDIR/$METADIR/update-binary"
}

# Set utility script
makeutilityscript() {
echo '#!/sbin/sh
#
##############################################################
# File name       : util_functions.sh
#
# Description     : Set installation variables
#
# Copyright       : Copyright (C) 2018-2021 TheHitMan7
#
# License         : GPL-3.0-or-later
##############################################################
# The BiTGApps scripts are free software: you can redistribute it
# and/or modify it under the terms of the GNU General Public License
# as published by the Free Software Foundation, either version 3 of
# the License, or (at your option) any later version.
#
# These scripts are distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
# GNU General Public License for more details.
##############################################################

REL=""
ZIPTYPE=""
TARGET_BOOTLOG_PATCH=""
TARGET_SAFETYNET_PATCH=""
TARGET_WHITELIST_PATCH=""' >"$BUILDDIR/$ARCH/$RELEASEDIR/util_functions.sh"
}

# Set logcat script
makelogcatscript() {
echo '##############################################################
# File name       : init.logcat.rc
#
# Description     : Generate boot logs
#
# Copyright       : Copyright (C) 2018-2021 TheHitMan7
#
# License         : GPL-3.0-or-later
##############################################################
# The BiTGApps scripts are free software: you can redistribute it
# and/or modify it under the terms of the GNU General Public License
# as published by the Free Software Foundation, either version 3 of
# the License, or (at your option) any later version.
#
# These scripts are distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
# GNU General Public License for more details.
##############################################################

service boot_lc_main /system/bin/logcat -f /cache/boot_lc_main.txt
    class main
    user root
    group root system
    disabled
    oneshot

service boot_dmesg /system/bin/sh -c "dmesg -w > /cache/boot_dmesg.txt"
    class main
    user root
    group root system
    disabled
    oneshot

on fs
    rm /cache/boot_lc_main.txt
    rm /cache/boot_dmesg.txt
    start boot_lc_main
    start boot_dmesg

on property:sys.boot_completed=1
    stop boot_lc_main
    stop boot_dmesg' >"$BUILDDIR/$ARCH/$RELEASEDIR/init.logcat.rc"
}

# Set license for pre-built package
makelicense() {
echo "This BiTGApps build is provided ONLY as courtesy by BiTGApps.org and is without warranty of ANY kind.

This build is authored by the TheHitMan7 and is as such protected by BiTGApps.org's copyright.
This build is provided under the terms that it can be freely used for personal use only and is not allowed to be mirrored to the public other than BiTGApps.org.
You are not allowed to modify this build for further (re)distribution.

BusyBox is subject to the GPLv2, its license can be found at https://www.busybox.net/license.html

Any other intellectual property of this build, like e.g. the file and folder structure and the installation scripts are part of The BiTGApps Project and are subject
to the GPLv3. The applicable license can be found at https://github.com/BiTGApps/BiTGApps/blob/master/LICENSE" >"$BUILDDIR/$ARCH/$RELEASEDIR/LICENSE"
}

# Compress and add Boot Image Editor
makebooteditorARM() {
  cd $AIK_ARMEABI
  # Only compress in 'xz' format
  tar -cJf "AIK_arm.tar.xz" *
  cd ../../../..
  cp -f $AIK_ARMEABI/AIK_arm.tar.xz $BUILDDIR/$ARCH/$RELEASEDIR/$ZIP
  rm -rf $AIK_ARMEABI/AIK_arm.tar.xz
}

makebooteditorARM64() {
  cd $AIK_AARCH64
  # Only compress in 'xz' format
  tar -cJf "AIK_arm64.tar.xz" *
  cd ../../../..
  cp -f $AIK_AARCH64/AIK_arm64.tar.xz $BUILDDIR/$ARCH/$RELEASEDIR/$ZIP
  rm -rf $AIK_AARCH64/AIK_arm64.tar.xz
}

# Compress and add patched keystore
makekeystore26() {
  cd $API_26_KEYSTORE
  # Only compress in 'xz' format
  tar -cJf "Keystore26.tar.xz" *
  cd ../../../..
  cp -f $API_26_KEYSTORE/Keystore26.tar.xz $BUILDDIR/$ARCH/$RELEASEDIR/$ZIP
  rm -rf $API_26_KEYSTORE/Keystore26.tar.xz
}

makekeystore27() {
  cd $API_27_KEYSTORE
  # Only compress in 'xz' format
  tar -cJf "Keystore27.tar.xz" *
  cd ../../../..
  cp -f $API_27_KEYSTORE/Keystore27.tar.xz $BUILDDIR/$ARCH/$RELEASEDIR/$ZIP
  rm -rf $API_27_KEYSTORE/Keystore27.tar.xz
}

makekeystore28() {
  cd $API_28_KEYSTORE
  # Only compress in 'xz' format
  tar -cJf "Keystore28.tar.xz" *
  cd ../../../..
  cp -f $API_28_KEYSTORE/Keystore28.tar.xz $BUILDDIR/$ARCH/$RELEASEDIR/$ZIP
  rm -rf $API_28_KEYSTORE/Keystore28.tar.xz
}

makekeystore29() {
  cd $API_29_KEYSTORE
  # Only compress in 'xz' format
  tar -cJf "Keystore29.tar.xz" *
  cd ../../../..
  cp -f $API_29_KEYSTORE/Keystore29.tar.xz $BUILDDIR/$ARCH/$RELEASEDIR/$ZIP
  rm -rf $API_29_KEYSTORE/Keystore29.tar.xz
}

makekeystore30() {
  cd $API_30_KEYSTORE
  # Only compress in 'xz' format
  tar -cJf "Keystore30.tar.xz" *
  cd ../../../..
  cp -f $API_30_KEYSTORE/Keystore30.tar.xz $BUILDDIR/$ARCH/$RELEASEDIR/$ZIP
  rm -rf $API_30_KEYSTORE/Keystore30.tar.xz
}

# Main
makepatch() {
  # Create build directory
  test -d $BUILDDIR || mkdir $BUILDDIR
  test -d $BUILDDIR/$ARCH || mkdir $BUILDDIR/$ARCH
  # Create out directory
  test -d $OUTDIR || mkdir $OUTDIR
  test -d $OUTDIR/$ARCH || mkdir $OUTDIR/$ARCH
  # Create ENV directory
  test -d $OUTDIR/ENV || mkdir $OUTDIR/ENV
  # Install variable; Do not modify
  ZIPTYPE='"patch"'
  # Bootlog Package
  if [ "$PATCH" == "bootlog" ]; then
    # Install variable; Do not modify
    TARGET_BOOTLOG_PATCH='"true"'
    TARGET_SAFETYNET_PATCH='"false"'
    TARGET_WHITELIST_PATCH='"false"'
    echo "Generating BiTGApps $PATCH package"
    # Create release directory
    mkdir "$BUILDDIR/$ARCH/BiTGApps-${PATCH}-patch-${COMMONPATCHRELEASE}"
    RELEASEDIR="BiTGApps-${PATCH}-patch-${COMMONPATCHRELEASE}"
    # Create package components
    mkdir -p $BUILDDIR/$ARCH/$RELEASEDIR/$METADIR
    mkdir -p $BUILDDIR/$ARCH/$RELEASEDIR/$ZIP
    # Installer component
    cp -f $INSTALLER $BUILDDIR/$ARCH/$RELEASEDIR
    cp -f $BUSYBOX $BUILDDIR/$ARCH/$RELEASEDIR
    # Create updater script
    makeupdaterscript
    # Create update binary
    makeupdatebinary
    # Create utility script
    makeutilityscript
    replace_line $BUILDDIR/$ARCH/$RELEASEDIR/util_functions.sh REL="" REL="$PATCH_RELEASE"
    replace_line $BUILDDIR/$ARCH/$RELEASEDIR/util_functions.sh ZIPTYPE="" ZIPTYPE="$ZIPTYPE"
    replace_line $BUILDDIR/$ARCH/$RELEASEDIR/util_functions.sh TARGET_BOOTLOG_PATCH="" TARGET_BOOTLOG_PATCH="$TARGET_BOOTLOG_PATCH"
    replace_line $BUILDDIR/$ARCH/$RELEASEDIR/util_functions.sh TARGET_SAFETYNET_PATCH="" TARGET_SAFETYNET_PATCH="$TARGET_SAFETYNET_PATCH"
    replace_line $BUILDDIR/$ARCH/$RELEASEDIR/util_functions.sh TARGET_WHITELIST_PATCH="" TARGET_WHITELIST_PATCH="$TARGET_WHITELIST_PATCH"
    # Create logcat script
    makelogcatscript
    # Create LICENSE
    makelicense
    # Add Boot Image Editor
    makebooteditorARM
    makebooteditorARM64
    # Create ZIP
    cd $BUILDDIR/$ARCH/$RELEASEDIR
    zip -qr9 ${RELEASEDIR}.zip *
    cd ../../..
    mv $BUILDDIR/$ARCH/$RELEASEDIR/${RELEASEDIR}.zip $OUTDIR/$ARCH/${RELEASEDIR}.zip
    # Sign ZIP
    java -jar $ZIPSIGNER $OUTDIR/$ARCH/${RELEASEDIR}.zip $OUTDIR/$ARCH/${RELEASEDIR}_signed.zip 2>/dev/null
    # Set PATCH in global environment
    echo "TARGET_BOOTLOG_PACKAGE" >> $OUTDIR/ENV/env_patch.sh
    # List signed ZIP
    ls $OUTDIR/$ARCH/${RELEASEDIR}_signed.zip
    # Wipe unsigned ZIP
    rm -rf $OUTDIR/$ARCH/${RELEASEDIR}.zip
  fi
  # Safetynet Package
  if [ "$PATCH" == "safetynet" ]; then
    # Install variable; Do not modify
    TARGET_BOOTLOG_PATCH='"false"'
    TARGET_SAFETYNET_PATCH='"true"'
    TARGET_WHITELIST_PATCH='"false"'
    echo "Generating BiTGApps $PATCH package"
    # Create release directory
    mkdir "$BUILDDIR/$ARCH/BiTGApps-${PATCH}-patch-${COMMONPATCHRELEASE}"
    RELEASEDIR="BiTGApps-${PATCH}-patch-${COMMONPATCHRELEASE}"
    # Create package components
    mkdir -p $BUILDDIR/$ARCH/$RELEASEDIR/$METADIR
    mkdir -p $BUILDDIR/$ARCH/$RELEASEDIR/$ZIP
    # Installer component
    cp -f $INSTALLER $BUILDDIR/$ARCH/$RELEASEDIR
    cp -f $BUSYBOX $BUILDDIR/$ARCH/$RELEASEDIR
    # Create updater script
    makeupdaterscript
    # Create update binary
    makeupdatebinary
    # Create utility script
    makeutilityscript
    replace_line $BUILDDIR/$ARCH/$RELEASEDIR/util_functions.sh REL="" REL="$PATCH_RELEASE"
    replace_line $BUILDDIR/$ARCH/$RELEASEDIR/util_functions.sh ZIPTYPE="" ZIPTYPE="$ZIPTYPE"
    replace_line $BUILDDIR/$ARCH/$RELEASEDIR/util_functions.sh TARGET_BOOTLOG_PATCH="" TARGET_BOOTLOG_PATCH="$TARGET_BOOTLOG_PATCH"
    replace_line $BUILDDIR/$ARCH/$RELEASEDIR/util_functions.sh TARGET_SAFETYNET_PATCH="" TARGET_SAFETYNET_PATCH="$TARGET_SAFETYNET_PATCH"
    replace_line $BUILDDIR/$ARCH/$RELEASEDIR/util_functions.sh TARGET_WHITELIST_PATCH="" TARGET_WHITELIST_PATCH="$TARGET_WHITELIST_PATCH"
    # Create LICENSE
    makelicense
    # Add Boot Image Editor
    makebooteditorARM
    makebooteditorARM64
    # Add patched keystore
    makekeystore26
    makekeystore27
    makekeystore28
    makekeystore29
    makekeystore30
    # Create ZIP
    cd $BUILDDIR/$ARCH/$RELEASEDIR
    zip -qr9 ${RELEASEDIR}.zip *
    cd ../../..
    mv $BUILDDIR/$ARCH/$RELEASEDIR/${RELEASEDIR}.zip $OUTDIR/$ARCH/${RELEASEDIR}.zip
    # Sign ZIP
    java -jar $ZIPSIGNER $OUTDIR/$ARCH/${RELEASEDIR}.zip $OUTDIR/$ARCH/${RELEASEDIR}_signed.zip 2>/dev/null
    # Set PATCH in global environment
    echo "TARGET_SAFETYNET_PACKAGE" >> $OUTDIR/ENV/env_patch.sh
    # List signed ZIP
    ls $OUTDIR/$ARCH/${RELEASEDIR}_signed.zip
    # Wipe unsigned ZIP
    rm -rf $OUTDIR/$ARCH/${RELEASEDIR}.zip
  fi
  # Whitelist Package
  if [ "$PATCH" == "whitelist" ]; then
    # Install variable; Do not modify
    TARGET_BOOTLOG_PATCH='"false"'
    TARGET_SAFETYNET_PATCH='"false"'
    TARGET_WHITELIST_PATCH='"true"'
    echo "Generating BiTGApps $PATCH package"
    # Create release directory
    mkdir "$BUILDDIR/$ARCH/BiTGApps-${PATCH}-patch-${COMMONPATCHRELEASE}"
    RELEASEDIR="BiTGApps-${PATCH}-patch-${COMMONPATCHRELEASE}"
    # Create package components
    mkdir -p $BUILDDIR/$ARCH/$RELEASEDIR/$METADIR
    mkdir -p $BUILDDIR/$ARCH/$RELEASEDIR/$ZIP
    # Installer component
    cp -f $INSTALLER $BUILDDIR/$ARCH/$RELEASEDIR
    cp -f $BUSYBOX $BUILDDIR/$ARCH/$RELEASEDIR
    # Create updater script
    makeupdaterscript
    # Create update binary
    makeupdatebinary
    # Create utility script
    makeutilityscript
    replace_line $BUILDDIR/$ARCH/$RELEASEDIR/util_functions.sh REL="" REL="$PATCH_RELEASE"
    replace_line $BUILDDIR/$ARCH/$RELEASEDIR/util_functions.sh ZIPTYPE="" ZIPTYPE="$ZIPTYPE"
    replace_line $BUILDDIR/$ARCH/$RELEASEDIR/util_functions.sh TARGET_BOOTLOG_PATCH="" TARGET_BOOTLOG_PATCH="$TARGET_BOOTLOG_PATCH"
    replace_line $BUILDDIR/$ARCH/$RELEASEDIR/util_functions.sh TARGET_SAFETYNET_PATCH="" TARGET_SAFETYNET_PATCH="$TARGET_SAFETYNET_PATCH"
    replace_line $BUILDDIR/$ARCH/$RELEASEDIR/util_functions.sh TARGET_WHITELIST_PATCH="" TARGET_WHITELIST_PATCH="$TARGET_WHITELIST_PATCH"
    # Create LICENSE
    makelicense
    # Add Boot Image Editor
    makebooteditorARM
    makebooteditorARM64
    # Create ZIP
    cd $BUILDDIR/$ARCH/$RELEASEDIR
    zip -qr9 ${RELEASEDIR}.zip *
    cd ../../..
    mv $BUILDDIR/$ARCH/$RELEASEDIR/${RELEASEDIR}.zip $OUTDIR/$ARCH/${RELEASEDIR}.zip
    # Sign ZIP
    java -jar $ZIPSIGNER $OUTDIR/$ARCH/${RELEASEDIR}.zip $OUTDIR/$ARCH/${RELEASEDIR}_signed.zip 2>/dev/null
    # Set PATCH in global environment
    echo "TARGET_WHITELIST_PACKAGE" >> $OUTDIR/ENV/env_patch.sh
    # List signed ZIP
    ls $OUTDIR/$ARCH/${RELEASEDIR}_signed.zip
    # Wipe unsigned ZIP
    rm -rf $OUTDIR/$ARCH/${RELEASEDIR}.zip
  fi
}

# Build
makepatch
