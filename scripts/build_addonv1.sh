#!/bin/bash
#
##############################################################
# File name       : build_addonv1.sh
#
# Description     : BiTGApps build script
#
# Copyright       : Copyright (C) 2018-2021 TheHitMan7
#
# License         : SPDX-License-Identifier: GPL-3.0-or-later
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

# Check architecture
if { [ "$1" != "arm" ] && [ "$1" != "arm64" ]; }; then
  exit 1
fi

# Set defaults
ARCH="$1"
COMMONADDONRELEASE="$COMMONADDONRELEASE"

# Build defaults
BUILDDIR="build"
OUTDIR="out"

# Signing tool
ZIPSIGNER="BiTGApps/tools/zipsigner-resources/zipsigner.jar"

# Set installer sources
UPDATEBINARY="BiTGApps/scripts/update-binary"
UPDATESCRIPT="BiTGApps/scripts/updater-script"
INSTALLER="BiTGApps/scripts/installer.sh"
LICENSE="BiTGApps/scripts/LICENSE"
BUSYBOX="BiTGApps/tools/busybox-resources/busybox-arm"

# Set ZIP structure
METADIR="META-INF/com/google/android"
ZIP="zip"
CORE="$ZIP/core"
SYS="$ZIP/sys"

# Set replace line
replace_line() {
  if grep -q "$2" $1; then
    local line=$(grep -n "$2" $1 | head -n1 | cut -d: -f1)
    sed -i "${line}s;.*;${3};" $1
  fi
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
# License         : SPDX-License-Identifier: GPL-3.0-or-later
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
ADDON=""' >"$BUILDDIR/$ARCH/$RELEASEDIR/util_functions.sh"
}

# Main
makeaddonv1() {
  # Create build directory
  test -d $BUILDDIR || mkdir $BUILDDIR
  test -d $BUILDDIR/$ARCH || mkdir $BUILDDIR/$ARCH
  # Create out directory
  test -d $OUTDIR || mkdir $OUTDIR
  test -d $OUTDIR/$ARCH || mkdir $OUTDIR/$ARCH
  # Install variable; Do not modify
  ZIPTYPE='"addon"'
  CONFIG='"conf"'
  # Platform ARM
  if [ "$ARCH" == "arm" ]; then
    # Set Addon package sources
    SOURCES_ALL="sources/addon-sources/all"
    SOURCES_ARMEABI="sources/addon-sources/$ARCH"
    echo "Generating BiTGApps Addon package for $ARCH architecture"
    # Create release directory
    mkdir $BUILDDIR/$ARCH/BiTGApps-addon-${ARCH}-${COMMONADDONRELEASE}
    RELEASEDIR="BiTGApps-addon-${ARCH}-${COMMONADDONRELEASE}"
    # Create package components
    mkdir -p $BUILDDIR/$ARCH/$RELEASEDIR/$METADIR
    mkdir -p $BUILDDIR/$ARCH/$RELEASEDIR/$ZIP
    mkdir -p $BUILDDIR/$ARCH/$RELEASEDIR/$CORE
    mkdir -p $BUILDDIR/$ARCH/$RELEASEDIR/$SYS
    # Install app packages
    cp -f $SOURCES_ALL/app/CalculatorGooglePrebuilt.tar.xz $BUILDDIR/$ARCH/$RELEASEDIR/$SYS
    cp -f $SOURCES_ALL/app/CalendarGooglePrebuilt.tar.xz $BUILDDIR/$ARCH/$RELEASEDIR/$SYS
    cp -f $SOURCES_ALL/app/DeskClockGooglePrebuilt.tar.xz $BUILDDIR/$ARCH/$RELEASEDIR/$SYS
    cp -f $SOURCES_ARMEABI/app/GboardGooglePrebuilt_arm.tar.xz $BUILDDIR/$ARCH/$RELEASEDIR/$SYS
    cp -f $SOURCES_ALL/app/MarkupGooglePrebuilt.tar.xz $BUILDDIR/$ARCH/$RELEASEDIR/$SYS
    cp -f $SOURCES_ALL/app/MessagesGooglePrebuilt.tar.xz $BUILDDIR/$ARCH/$RELEASEDIR/$SYS
    cp -f $SOURCES_ALL/app/MicroGGMSCore.tar.xz $BUILDDIR/$ARCH/$RELEASEDIR/$SYS
    cp -f $SOURCES_ARMEABI/app/PhotosGooglePrebuilt_arm.tar.xz $BUILDDIR/$ARCH/$RELEASEDIR/$SYS
    cp -f $SOURCES_ALL/app/SoundPickerPrebuilt.tar.xz $BUILDDIR/$ARCH/$RELEASEDIR/$SYS
    cp -f $SOURCES_ALL/app/YouTube.tar.xz $BUILDDIR/$ARCH/$RELEASEDIR/$SYS
    # Install lib package
    cp -f $SOURCES_ARMEABI/lib/markup_lib32.tar.xz $BUILDDIR/$ARCH/$RELEASEDIR/$ZIP
    # Install priv-app package
    cp -f $SOURCES_ALL/priv-app/CarrierServices.tar.xz $BUILDDIR/$ARCH/$RELEASEDIR/$CORE
    cp -f $SOURCES_ALL/priv-app/ContactsGooglePrebuilt.tar.xz $BUILDDIR/$ARCH/$RELEASEDIR/$CORE
    cp -f $SOURCES_ARMEABI/priv-app/DialerGooglePrebuilt_arm.tar.xz $BUILDDIR/$ARCH/$RELEASEDIR/$CORE
    cp -f $SOURCES_ARMEABI/priv-app/Velvet_arm.tar.xz $BUILDDIR/$ARCH/$RELEASEDIR/$CORE
    cp -f $SOURCES_ALL/priv-app/WellbeingPrebuilt.tar.xz $BUILDDIR/$ARCH/$RELEASEDIR/$CORE
    # Installer components
    cp -f $UPDATEBINARY $BUILDDIR/$ARCH/$RELEASEDIR/$METADIR
    cp -f $UPDATESCRIPT $BUILDDIR/$ARCH/$RELEASEDIR/$METADIR
    cp -f $INSTALLER $BUILDDIR/$ARCH/$RELEASEDIR
    cp -f $LICENSE $BUILDDIR/$ARCH/$RELEASEDIR
    cp -f $BUSYBOX $BUILDDIR/$ARCH/$RELEASEDIR
    # Create utility script
    makeutilityscript
    replace_line $BUILDDIR/$ARCH/$RELEASEDIR/util_functions.sh REL="" REL="$ADDON_RELEASE"
    replace_line $BUILDDIR/$ARCH/$RELEASEDIR/util_functions.sh ZIPTYPE="" ZIPTYPE="$ZIPTYPE"
    replace_line $BUILDDIR/$ARCH/$RELEASEDIR/util_functions.sh ADDON="" ADDON="$CONFIG"
    # Create ZIP
    cd $BUILDDIR/$ARCH/$RELEASEDIR
    zip -qr9 ${RELEASEDIR}.zip *
    cd ../../..
    mv $BUILDDIR/$ARCH/$RELEASEDIR/${RELEASEDIR}.zip $OUTDIR/$ARCH/${RELEASEDIR}.zip
    # Sign ZIP
    java -jar $ZIPSIGNER $OUTDIR/$ARCH/${RELEASEDIR}.zip $OUTDIR/$ARCH/${RELEASEDIR}_signed.zip 2>/dev/null
    # List signed ZIP
    ls $OUTDIR/$ARCH/${RELEASEDIR}_signed.zip
    # Wipe unsigned ZIP
    rm -rf $OUTDIR/$ARCH/${RELEASEDIR}.zip
  fi
  # Platform ARM64
  if [ "$ARCH" == "arm64" ]; then
    # Set Addon package sources
    SOURCES_ALL="sources/addon-sources/all"
    SOURCES_AARCH64="sources/addon-sources/$ARCH"
    echo "Generating BiTGApps Addon package for $ARCH architecture"
    # Create release directory
    mkdir $BUILDDIR/$ARCH/BiTGApps-addon-${ARCH}-${COMMONADDONRELEASE}
    RELEASEDIR="BiTGApps-addon-${ARCH}-${COMMONADDONRELEASE}"
    # Create package components
    mkdir -p $BUILDDIR/$ARCH/$RELEASEDIR/$METADIR
    mkdir -p $BUILDDIR/$ARCH/$RELEASEDIR/$ZIP
    mkdir -p $BUILDDIR/$ARCH/$RELEASEDIR/$CORE
    mkdir -p $BUILDDIR/$ARCH/$RELEASEDIR/$SYS
    # Install app packages
    cp -f $SOURCES_ALL/app/CalculatorGooglePrebuilt.tar.xz $BUILDDIR/$ARCH/$RELEASEDIR/$SYS
    cp -f $SOURCES_ALL/app/CalendarGooglePrebuilt.tar.xz $BUILDDIR/$ARCH/$RELEASEDIR/$SYS
    cp -f $SOURCES_ALL/app/DeskClockGooglePrebuilt.tar.xz $BUILDDIR/$ARCH/$RELEASEDIR/$SYS
    cp -f $SOURCES_AARCH64/app/GboardGooglePrebuilt_arm64.tar.xz $BUILDDIR/$ARCH/$RELEASEDIR/$SYS
    cp -f $SOURCES_ALL/app/MarkupGooglePrebuilt.tar.xz $BUILDDIR/$ARCH/$RELEASEDIR/$SYS
    cp -f $SOURCES_ALL/app/MessagesGooglePrebuilt.tar.xz $BUILDDIR/$ARCH/$RELEASEDIR/$SYS
    cp -f $SOURCES_ALL/app/MicroGGMSCore.tar.xz $BUILDDIR/$ARCH/$RELEASEDIR/$SYS
    cp -f $SOURCES_AARCH64/app/PhotosGooglePrebuilt_arm64.tar.xz $BUILDDIR/$ARCH/$RELEASEDIR/$SYS
    cp -f $SOURCES_ALL/app/SoundPickerPrebuilt.tar.xz $BUILDDIR/$ARCH/$RELEASEDIR/$SYS
    cp -f $SOURCES_ALL/app/YouTube.tar.xz $BUILDDIR/$ARCH/$RELEASEDIR/$SYS
    # Install lib package
    cp -f $SOURCES_AARCH64/lib64/markup_lib64.tar.xz $BUILDDIR/$ARCH/$RELEASEDIR/$ZIP
    # Install priv-app package
    cp -f $SOURCES_ALL/priv-app/CarrierServices.tar.xz $BUILDDIR/$ARCH/$RELEASEDIR/$CORE
    cp -f $SOURCES_ALL/priv-app/ContactsGooglePrebuilt.tar.xz $BUILDDIR/$ARCH/$RELEASEDIR/$CORE
    cp -f $SOURCES_AARCH64/priv-app/DialerGooglePrebuilt_arm64.tar.xz $BUILDDIR/$ARCH/$RELEASEDIR/$CORE
    cp -f $SOURCES_AARCH64/priv-app/Velvet_arm64.tar.xz $BUILDDIR/$ARCH/$RELEASEDIR/$CORE
    cp -f $SOURCES_ALL/priv-app/WellbeingPrebuilt.tar.xz $BUILDDIR/$ARCH/$RELEASEDIR/$CORE
    # Installer components
    cp -f $UPDATEBINARY $BUILDDIR/$ARCH/$RELEASEDIR/$METADIR
    cp -f $UPDATESCRIPT $BUILDDIR/$ARCH/$RELEASEDIR/$METADIR
    cp -f $INSTALLER $BUILDDIR/$ARCH/$RELEASEDIR
    cp -f $LICENSE $BUILDDIR/$ARCH/$RELEASEDIR
    cp -f $BUSYBOX $BUILDDIR/$ARCH/$RELEASEDIR
    # Create utility script
    makeutilityscript
    replace_line $BUILDDIR/$ARCH/$RELEASEDIR/util_functions.sh REL="" REL="$ADDON_RELEASE"
    replace_line $BUILDDIR/$ARCH/$RELEASEDIR/util_functions.sh ZIPTYPE="" ZIPTYPE="$ZIPTYPE"
    replace_line $BUILDDIR/$ARCH/$RELEASEDIR/util_functions.sh ADDON="" ADDON="$CONFIG"
    # Create ZIP
    cd $BUILDDIR/$ARCH/$RELEASEDIR
    zip -qr9 ${RELEASEDIR}.zip *
    cd ../../..
    mv $BUILDDIR/$ARCH/$RELEASEDIR/${RELEASEDIR}.zip $OUTDIR/$ARCH/${RELEASEDIR}.zip
    # Sign ZIP
    java -jar $ZIPSIGNER $OUTDIR/$ARCH/${RELEASEDIR}.zip $OUTDIR/$ARCH/${RELEASEDIR}_signed.zip 2>/dev/null
    # List signed ZIP
    ls $OUTDIR/$ARCH/${RELEASEDIR}_signed.zip
    # Wipe unsigned ZIP
    rm -rf $OUTDIR/$ARCH/${RELEASEDIR}.zip
  fi
}

# Build
makeaddonv1
