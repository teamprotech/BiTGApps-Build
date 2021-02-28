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

# Check availability of environmental variables
if { [ ! -n "$COMMONADDONRELEASE" ] ||
     [ ! -n "$ADDON_RELEASE" ]; }; then
     echo "! Environmental variables not set. Aborting..."
  exit 1
fi

# Check architecture
if { [ "$1" != "arm" ] && [ "$1" != "arm64" ]; }; then
  echo "Usage: $0 (arm|arm64)"
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
BUSYBOX="BiTGApps/tools/busybox-resources/busybox-arm"

# Set ZIP structure
METADIR="META-INF/com/google/android"
ZIP="zip"
CORE="$ZIP/core"
SYS="$ZIP/sys"

# replace_line <file> <line replace string> <replacement line>
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
ADDON=""
ARMEABI=""
AARCH64=""' >"$BUILDDIR/$ARCH/$RELEASEDIR/util_functions.sh"
}

# Set license for pre-built package
makelicense() {
echo "This BiTGApps build is provided ONLY as courtesy by BiTGApps.com and is without warranty of ANY kind.

This build is authored by the TheHitMan7 and is as such protected by BiTGApps.com's copyright.
This build is provided under the terms that it can be freely used for personal use only and is not allowed to be mirrored to the public other than BiTGApps.com.
You are not allowed to modify this build for further (re)distribution.

The APKs found in this build are developed and owned by Google Inc.
They are included only for your convenience, neither BiTGApps.com and The BiTGApps Project have no ownership over them.
The user self is responsible for obtaining the proper licenses for the APKs, e.g. via Google's Play Store.
To use Google's applications you accept to Google's license agreement and further distribution of Google's application
are subject of Google's terms and conditions, these can be found at http://www.google.com/policies/

BusyBox is subject to the GPLv2, its license can be found at https://www.busybox.net/license.html

Any other intellectual property of this build, like e.g. the file and folder structure and the installation scripts are part of The BiTGApps Project and are subject
to the GPLv3. The applicable license can be found at https://github.com/BiTGApps/BiTGApps/blob/master/LICENSE" >"$BUILDDIR/$ARCH/$RELEASEDIR/LICENSE"
}

# Main
makeaddonv1() {
  # Create build directory
  test -d $BUILDDIR || mkdir $BUILDDIR
  test -d $BUILDDIR/$ARCH || mkdir $BUILDDIR/$ARCH
  # Create out directory
  test -d $OUTDIR || mkdir $OUTDIR
  test -d $OUTDIR/$ARCH || mkdir $OUTDIR/$ARCH
  # Create ENV directory
  test -d $OUTDIR/ENV || mkdir $OUTDIR/ENV
  # Install variable; Do not modify
  ZIPTYPE='"addon"'
  CONFIG='"conf"'
  # Architecture based package configuration; Do not modify
  GBOARD_NO_ARCH="GboardGooglePrebuilt.tar.xz"
  PHOTOS_NO_ARCH="PhotosGooglePrebuilt.tar.xz"
  DIALER_NO_ARCH="DialerGooglePrebuilt.tar.xz"
  VELVET_NO_ARCH="Velvet.tar.xz"
  # Platform ARM
  if [ "$ARCH" == "arm" ]; then
    # Install variable; Do not modify
    ARMEABI='"true"'
    AARCH64='"false"'
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
    cp -f $SOURCES_ARMEABI/app/GboardGooglePrebuilt_arm.tar.xz $BUILDDIR/$ARCH/$RELEASEDIR/$SYS/$GBOARD_NO_ARCH
    cp -f $SOURCES_ALL/app/MarkupGooglePrebuilt.tar.xz $BUILDDIR/$ARCH/$RELEASEDIR/$SYS
    cp -f $SOURCES_ALL/app/MessagesGooglePrebuilt.tar.xz $BUILDDIR/$ARCH/$RELEASEDIR/$SYS
    cp -f $SOURCES_ALL/app/MicroGGMSCore.tar.xz $BUILDDIR/$ARCH/$RELEASEDIR/$SYS
    cp -f $SOURCES_ARMEABI/app/PhotosGooglePrebuilt_arm.tar.xz $BUILDDIR/$ARCH/$RELEASEDIR/$SYS/$PHOTOS_NO_ARCH
    cp -f $SOURCES_ALL/app/SoundPickerPrebuilt.tar.xz $BUILDDIR/$ARCH/$RELEASEDIR/$SYS
    cp -f $SOURCES_ALL/app/YouTube.tar.xz $BUILDDIR/$ARCH/$RELEASEDIR/$SYS
    # Install lib package
    cp -f $SOURCES_ARMEABI/lib/markup_lib32.tar.xz $BUILDDIR/$ARCH/$RELEASEDIR/$ZIP
    # Install priv-app package
    cp -f $SOURCES_ALL/priv-app/CarrierServices.tar.xz $BUILDDIR/$ARCH/$RELEASEDIR/$CORE
    cp -f $SOURCES_ALL/priv-app/ContactsGooglePrebuilt.tar.xz $BUILDDIR/$ARCH/$RELEASEDIR/$CORE
    cp -f $SOURCES_ARMEABI/priv-app/DialerGooglePrebuilt_arm.tar.xz $BUILDDIR/$ARCH/$RELEASEDIR/$CORE/$DIALER_NO_ARCH
    cp -f $SOURCES_ARMEABI/priv-app/Velvet_arm.tar.xz $BUILDDIR/$ARCH/$RELEASEDIR/$CORE/$VELVET_NO_ARCH
    cp -f $SOURCES_ALL/priv-app/WellbeingPrebuilt.tar.xz $BUILDDIR/$ARCH/$RELEASEDIR/$CORE
    # Installer components
    cp -f $UPDATEBINARY $BUILDDIR/$ARCH/$RELEASEDIR/$METADIR
    cp -f $UPDATESCRIPT $BUILDDIR/$ARCH/$RELEASEDIR/$METADIR
    cp -f $INSTALLER $BUILDDIR/$ARCH/$RELEASEDIR
    cp -f $BUSYBOX $BUILDDIR/$ARCH/$RELEASEDIR
    # Create utility script
    makeutilityscript
    replace_line $BUILDDIR/$ARCH/$RELEASEDIR/util_functions.sh REL="" REL="$ADDON_RELEASE"
    replace_line $BUILDDIR/$ARCH/$RELEASEDIR/util_functions.sh ZIPTYPE="" ZIPTYPE="$ZIPTYPE"
    replace_line $BUILDDIR/$ARCH/$RELEASEDIR/util_functions.sh ADDON="" ADDON="$CONFIG"
    replace_line $BUILDDIR/$ARCH/$RELEASEDIR/util_functions.sh ARMEABI="" ARMEABI="$ARMEABI"
    replace_line $BUILDDIR/$ARCH/$RELEASEDIR/util_functions.sh AARCH64="" AARCH64="$AARCH64"
    # Create LICENSE
    makelicense
    # Create ZIP
    cd $BUILDDIR/$ARCH/$RELEASEDIR
    zip -qr9 ${RELEASEDIR}.zip *
    cd ../../..
    mv $BUILDDIR/$ARCH/$RELEASEDIR/${RELEASEDIR}.zip $OUTDIR/$ARCH/${RELEASEDIR}.zip
    # Sign ZIP; No token required for official release
    if [ ! -n "$TESTRELEASE" ]; then
      java -jar $ZIPSIGNER $OUTDIR/$ARCH/${RELEASEDIR}.zip $OUTDIR/$ARCH/${RELEASEDIR}_signed.zip 2>/dev/null
    fi
    # Sign ZIP; Add ZIP token for test release
    if [ -n "$TESTRELEASE" ]; then
      java -jar $ZIPSIGNER $OUTDIR/$ARCH/${RELEASEDIR}.zip $OUTDIR/$ARCH/${RELEASEDIR}_signed-${TOKEN}.zip 2>/dev/null
    fi
    # Set build PLATFORM in global environment
    if [ ! -n "$TESTRELEASE" ]; then
      if [ -f "$OUTDIR/$ARCH/${RELEASEDIR}_signed.zip" ]; then
        echo "TARGET_PLATFORM_ARM" >> $OUTDIR/ENV/env_platform.sh
      fi
    fi
    if [ -n "$TESTRELEASE" ]; then
      if [ -f "$OUTDIR/$ARCH/${RELEASEDIR}_signed-${TOKEN}.zip" ]; then
        echo "TARGET_PLATFORM_ARM" >> $OUTDIR/ENV/env_platform.sh
      fi
    fi
    # List signed ZIP
    if [ ! -n "$TESTRELEASE" ]; then
      ls $OUTDIR/$ARCH/${RELEASEDIR}_signed.zip
    fi
    if [ -n "$TESTRELEASE" ]; then
      ls $OUTDIR/$ARCH/${RELEASEDIR}_signed-${TOKEN}.zip
    fi
    # Wipe unsigned ZIP
    rm -rf $OUTDIR/$ARCH/${RELEASEDIR}.zip
  fi
  # Platform ARM64
  if [ "$ARCH" == "arm64" ]; then
    # Install variable; Do not modify
    ARMEABI='"false"'
    AARCH64='"true"'
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
    cp -f $SOURCES_AARCH64/app/GboardGooglePrebuilt_arm64.tar.xz $BUILDDIR/$ARCH/$RELEASEDIR/$SYS/$GBOARD_NO_ARCH
    cp -f $SOURCES_ALL/app/MarkupGooglePrebuilt.tar.xz $BUILDDIR/$ARCH/$RELEASEDIR/$SYS
    cp -f $SOURCES_ALL/app/MessagesGooglePrebuilt.tar.xz $BUILDDIR/$ARCH/$RELEASEDIR/$SYS
    cp -f $SOURCES_ALL/app/MicroGGMSCore.tar.xz $BUILDDIR/$ARCH/$RELEASEDIR/$SYS
    cp -f $SOURCES_AARCH64/app/PhotosGooglePrebuilt_arm64.tar.xz $BUILDDIR/$ARCH/$RELEASEDIR/$SYS/$PHOTOS_NO_ARCH
    cp -f $SOURCES_ALL/app/SoundPickerPrebuilt.tar.xz $BUILDDIR/$ARCH/$RELEASEDIR/$SYS
    cp -f $SOURCES_ALL/app/YouTube.tar.xz $BUILDDIR/$ARCH/$RELEASEDIR/$SYS
    # Install lib package
    cp -f $SOURCES_AARCH64/lib64/markup_lib64.tar.xz $BUILDDIR/$ARCH/$RELEASEDIR/$ZIP
    # Install priv-app package
    cp -f $SOURCES_ALL/priv-app/CarrierServices.tar.xz $BUILDDIR/$ARCH/$RELEASEDIR/$CORE
    cp -f $SOURCES_ALL/priv-app/ContactsGooglePrebuilt.tar.xz $BUILDDIR/$ARCH/$RELEASEDIR/$CORE
    cp -f $SOURCES_AARCH64/priv-app/DialerGooglePrebuilt_arm64.tar.xz $BUILDDIR/$ARCH/$RELEASEDIR/$CORE/$DIALER_NO_ARCH
    cp -f $SOURCES_AARCH64/priv-app/Velvet_arm64.tar.xz $BUILDDIR/$ARCH/$RELEASEDIR/$CORE/$VELVET_NO_ARCH
    cp -f $SOURCES_ALL/priv-app/WellbeingPrebuilt.tar.xz $BUILDDIR/$ARCH/$RELEASEDIR/$CORE
    # Installer components
    cp -f $UPDATEBINARY $BUILDDIR/$ARCH/$RELEASEDIR/$METADIR
    cp -f $UPDATESCRIPT $BUILDDIR/$ARCH/$RELEASEDIR/$METADIR
    cp -f $INSTALLER $BUILDDIR/$ARCH/$RELEASEDIR
    cp -f $BUSYBOX $BUILDDIR/$ARCH/$RELEASEDIR
    # Create utility script
    makeutilityscript
    replace_line $BUILDDIR/$ARCH/$RELEASEDIR/util_functions.sh REL="" REL="$ADDON_RELEASE"
    replace_line $BUILDDIR/$ARCH/$RELEASEDIR/util_functions.sh ZIPTYPE="" ZIPTYPE="$ZIPTYPE"
    replace_line $BUILDDIR/$ARCH/$RELEASEDIR/util_functions.sh ADDON="" ADDON="$CONFIG"
    replace_line $BUILDDIR/$ARCH/$RELEASEDIR/util_functions.sh ARMEABI="" ARMEABI="$ARMEABI"
    replace_line $BUILDDIR/$ARCH/$RELEASEDIR/util_functions.sh AARCH64="" AARCH64="$AARCH64"
    # Create LICENSE
    makelicense
    # Create ZIP
    cd $BUILDDIR/$ARCH/$RELEASEDIR
    zip -qr9 ${RELEASEDIR}.zip *
    cd ../../..
    mv $BUILDDIR/$ARCH/$RELEASEDIR/${RELEASEDIR}.zip $OUTDIR/$ARCH/${RELEASEDIR}.zip
    # Sign ZIP; No token required for official release
    if [ ! -n "$TESTRELEASE" ]; then
      java -jar $ZIPSIGNER $OUTDIR/$ARCH/${RELEASEDIR}.zip $OUTDIR/$ARCH/${RELEASEDIR}_signed.zip 2>/dev/null
    fi
    # Sign ZIP; Add ZIP token for test release
    if [ -n "$TESTRELEASE" ]; then
      java -jar $ZIPSIGNER $OUTDIR/$ARCH/${RELEASEDIR}.zip $OUTDIR/$ARCH/${RELEASEDIR}_signed-${TOKEN}.zip 2>/dev/null
    fi
    # Set build PLATFORM in global environment
    if [ ! -n "$TESTRELEASE" ]; then
      if [ -f "$OUTDIR/$ARCH/${RELEASEDIR}_signed.zip" ]; then
        echo "TARGET_PLATFORM_ARM64" >> $OUTDIR/ENV/env_platform.sh
      fi
    fi
    if [ -n "$TESTRELEASE" ]; then
      if [ -f "$OUTDIR/$ARCH/${RELEASEDIR}_signed-${TOKEN}.zip" ]; then
        echo "TARGET_PLATFORM_ARM64" >> $OUTDIR/ENV/env_platform.sh
      fi
    fi
    # List signed ZIP
    if [ ! -n "$TESTRELEASE" ]; then
      ls $OUTDIR/$ARCH/${RELEASEDIR}_signed.zip
    fi
    if [ -n "$TESTRELEASE" ]; then
      ls $OUTDIR/$ARCH/${RELEASEDIR}_signed-${TOKEN}.zip
    fi
    # Wipe unsigned ZIP
    rm -rf $OUTDIR/$ARCH/${RELEASEDIR}.zip
  fi
}

# Build
makeaddonv1
