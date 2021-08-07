#!/bin/bash
#
##############################################################
# File name       : build_addonv2.sh
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
if { [ ! -n "$COMMONADDONRELEASE" ] ||
     [ ! -n "$ADDON_RELEASE" ] ||
     [ ! -n "$TARGET_CONFIG_VERSION" ]; }; then
     echo "! Environmental variables not set. Aborting..."
  exit 1
fi

# Set defaults
VARIANT="$1"
ARCH="common"
COMMONADDONRELEASE="$COMMONADDONRELEASE"

# Build defaults
BUILDDIR="build"
OUTDIR="out"

# Signing tool
ZIPSIGNER="BiTGApps/tools/zipsigner-resources/zipsigner.jar"

# Set Boot Image Editor sources
AIK="Build-Tools/AIK/AIK.tar.xz"

# Set installer sources
UPDATEBINARY="BiTGApps/scripts/update-binary.sh"
UPDATERSCRIPT="BiTGApps/scripts/updater-script.sh"
INSTALLER="BiTGApps/scripts/installer.sh"
BROMITESCRIPT="BiTGApps/scripts/bromite.sh"
VANCEDINIT="BiTGApps/scripts/init.vanced.rc"
VANCEDSCRIPT="BiTGApps/scripts/vanced.sh"
VANCEDROOT="BiTGApps/scripts/vanced-root.sh"
BUSYBOX="BiTGApps/tools/busybox-resources/busybox-arm"

# Set ZIP structure
METADIR="META-INF/com/google/android"
ZIP="zip"
CORE="$ZIP/core"
SYS="$ZIP/sys"
OVERLAY="$ZIP/overlay"

# replace_line <file> <line replace string> <replacement line>
replace_line() {
  if grep -q "$2" $1; then
    local line=$(grep -n "$2" $1 | head -n1 | cut -d: -f1)
    sed -i "${line}s;.*;${3};" $1
  fi
}

# remove_line <file> <line match string>
remove_line() {
  if grep -q "$2" $1; then
    local line=$(grep -n "$2" $1 | head -n1 | cut -d: -f1)
    sed -i "${line}d" $1
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
TARGET_GAPPS_RELEASE=""
TARGET_DIRTY_INSTALL=""
ADDON=""
TARGET_ASSISTANT_GOOGLE="false"
TARGET_BROMITE_GOOGLE="false"
TARGET_CALCULATOR_GOOGLE="false"
TARGET_CALENDAR_GOOGLE="false"
TARGET_CHROME_GOOGLE="false"
TARGET_CONTACTS_GOOGLE="false"
TARGET_DESKCLOCK_GOOGLE="false"
TARGET_DIALER_GOOGLE="false"
TARGET_DPS_GOOGLE="false"
TARGET_GBOARD_GOOGLE="false"
TARGET_GEARHEAD_GOOGLE="false"
TARGET_LAUNCHER_GOOGLE="false"
TARGET_MAPS_GOOGLE="false"
TARGET_MARKUP_GOOGLE="false"
TARGET_MESSAGES_GOOGLE="false"
TARGET_PHOTOS_GOOGLE="false"
TARGET_SOUNDPICKER_GOOGLE="false"
TARGET_TTS_GOOGLE="false"
TARGET_VANCED_MICROG="false"
TARGET_VANCED_ROOT="false"
TARGET_VANCED_NONROOT="false"
TARGET_WELLBEING_GOOGLE="false"
TARGET_CONFIG_VERSION=""' >"$BUILDDIR/$ARCH/$RELEASEDIR/util_functions.sh"
}

# Compress and add YouTube Vanced boot scripts
makevanced() {
  cp -f $VANCEDINIT $BUILDDIR/$ARCH/$RELEASEDIR/$ZIP
  cp -f $VANCEDSCRIPT $BUILDDIR/$ARCH/$RELEASEDIR/$ZIP
  cp -f $VANCEDROOT $BUILDDIR/$ARCH/$RELEASEDIR/$ZIP
  cd $BUILDDIR/$ARCH/$RELEASEDIR/$ZIP
  # Only compress in 'xz' format
  tar -cJf "Vanced.tar.xz" init.vanced.rc vanced.sh vanced-root.sh
  rm -rf init.vanced.rc vanced.sh vanced-root.sh
  # Checkout path
  cd ../../../..
}

# Set license for pre-built package
makelicense() {
echo "Sources used for distributing pre-built packages of BiTGApps:

[1] BiTGApps.github.io
[2] BiTGApps.com
[3] BiTGApps.org

This BiTGApps build is provided ONLY as courtesy by [1],[2],[3] and is without warranty of ANY kind.

This build is authored by the TheHitMan7 and is as such protected by [1],[2],[3]'s copyright.
This build is provided under the terms that it can be freely used for personal use only and is not allowed to be mirrored to the public other than [1],[2],[3].
You are not allowed to modify this build for further (re)distribution.

The APKs found in this build are developed and owned by Google Inc.
They are included only for your convenience, neither [1],[2],[3] and The BiTGApps Project have no ownership over them.
The user self is responsible for obtaining the proper licenses for the APKs, e.g. via Google's Play Store.
To use Google's applications you accept to Google's license agreement and further distribution of Google's application
are subject of Google's terms and conditions, these can be found at http://www.google.com/policies/

BusyBox is subject to the GPLv2, its license can be found at https://www.busybox.net/license.html

Any other intellectual property of this build, like e.g. the file and folder structure and the installation scripts are part of The BiTGApps Project and are subject
to the GPLv3. The applicable license can be found at https://github.com/BiTGApps/BiTGApps/blob/master/LICENSE" >"$BUILDDIR/$ARCH/$RELEASEDIR/LICENSE"
}

# Main
makeaddonv2() {
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
  NONCONFIG='"sep"'
  # Assistant
  if [ "$VARIANT" == "assistant" ]; then
    # Set Addon package sources
    SOURCES_ALL="sources/addon-sources/all"
    SOURCES_ARMEABI="sources/addon-sources/arm"
    SOURCES_AARCH64="sources/addon-sources/arm64"
    echo "Generating BiTGApps Assistant Addon package"
    # Create release directory
    mkdir "$BUILDDIR/$ARCH/BiTGApps-addon-assistant-${COMMONADDONRELEASE}"
    RELEASEDIR="BiTGApps-addon-assistant-${COMMONADDONRELEASE}"
    # Create package components
    mkdir -p $BUILDDIR/$ARCH/$RELEASEDIR/$METADIR
    mkdir -p $BUILDDIR/$ARCH/$RELEASEDIR/$ZIP
    mkdir -p $BUILDDIR/$ARCH/$RELEASEDIR/$CORE
    # Install priv-app packages
    cp -f $SOURCES_ARMEABI/priv-app/Velvet_arm.tar.xz $BUILDDIR/$ARCH/$RELEASEDIR/$CORE
    cp -f $SOURCES_AARCH64/priv-app/Velvet_arm64.tar.xz $BUILDDIR/$ARCH/$RELEASEDIR/$CORE
    # Installer components
    cp -f $UPDATEBINARY $BUILDDIR/$ARCH/$RELEASEDIR/$METADIR/update-binary
    cp -f $UPDATERSCRIPT $BUILDDIR/$ARCH/$RELEASEDIR/$METADIR/updater-script
    cp -f $INSTALLER $BUILDDIR/$ARCH/$RELEASEDIR
    cp -f $BUSYBOX $BUILDDIR/$ARCH/$RELEASEDIR
    # Create utility script
    makeutilityscript
    replace_line $BUILDDIR/$ARCH/$RELEASEDIR/util_functions.sh REL="" REL="$ADDON_RELEASE"
    replace_line $BUILDDIR/$ARCH/$RELEASEDIR/util_functions.sh ZIPTYPE="" ZIPTYPE="$ZIPTYPE"
    replace_line $BUILDDIR/$ARCH/$RELEASEDIR/util_functions.sh TARGET_GAPPS_RELEASE="" TARGET_GAPPS_RELEASE="$TARGET_GAPPS_RELEASE"
    replace_line $BUILDDIR/$ARCH/$RELEASEDIR/util_functions.sh TARGET_DIRTY_INSTALL="" TARGET_DIRTY_INSTALL="$TARGET_DIRTY_INSTALL"
    replace_line $BUILDDIR/$ARCH/$RELEASEDIR/util_functions.sh ADDON="" ADDON="$NONCONFIG"
    replace_line $BUILDDIR/$ARCH/$RELEASEDIR/util_functions.sh TARGET_ASSISTANT_GOOGLE="" TARGET_ASSISTANT_GOOGLE="$TARGET_ASSISTANT_GOOGLE"
    replace_line $BUILDDIR/$ARCH/$RELEASEDIR/util_functions.sh TARGET_CONFIG_VERSION="" TARGET_CONFIG_VERSION="$TARGET_CONFIG_VERSION"
    # Create LICENSE
    makelicense
    # Create ZIP
    cd $BUILDDIR/$ARCH/$RELEASEDIR
    zip -qr9 ${RELEASEDIR}.zip *
    cd ../../..
    mv $BUILDDIR/$ARCH/$RELEASEDIR/${RELEASEDIR}.zip $OUTDIR/$ARCH/${RELEASEDIR}.zip
    # Sign ZIP
    java -jar $ZIPSIGNER $OUTDIR/$ARCH/${RELEASEDIR}.zip $OUTDIR/$ARCH/${RELEASEDIR}_signed.zip 2>/dev/null
    # Set build VARIANT in global environment
    echo "TARGET_VARIANT_ASSISTANT" >> $OUTDIR/ENV/env_variant.sh
    # List signed ZIP
    ls $OUTDIR/$ARCH/${RELEASEDIR}_signed.zip
    # Wipe unsigned ZIP
    rm -rf $OUTDIR/$ARCH/${RELEASEDIR}.zip
  fi
  # Bromite
  if [ "$VARIANT" == "bromite" ]; then
    # Set Addon package sources
    SOURCES_ALL="sources/addon-sources/all"
    SOURCES_ARMEABI="sources/addon-sources/arm"
    SOURCES_AARCH64="sources/addon-sources/arm64"
    echo "Generating BiTGApps Bromite Addon package"
    # Create release directory
    mkdir "$BUILDDIR/$ARCH/BiTGApps-addon-bromite-${COMMONADDONRELEASE}"
    RELEASEDIR="BiTGApps-addon-bromite-${COMMONADDONRELEASE}"
    # Create package components
    mkdir -p $BUILDDIR/$ARCH/$RELEASEDIR/$METADIR
    mkdir -p $BUILDDIR/$ARCH/$RELEASEDIR/$ZIP
    mkdir -p $BUILDDIR/$ARCH/$RELEASEDIR/$SYS
    # Install app package
    cp -f $SOURCES_ARMEABI/app/BromitePrebuilt_arm.tar.xz $BUILDDIR/$ARCH/$RELEASEDIR/$SYS
    cp -f $SOURCES_ARMEABI/app/WebViewBromite_arm.tar.xz $BUILDDIR/$ARCH/$RELEASEDIR/$SYS
    cp -f $SOURCES_AARCH64/app/BromitePrebuilt_arm64.tar.xz $BUILDDIR/$ARCH/$RELEASEDIR/$SYS
    cp -f $SOURCES_AARCH64/app/WebViewBromite_arm64.tar.xz $BUILDDIR/$ARCH/$RELEASEDIR/$SYS
    # Installer components
    cp -f $UPDATEBINARY $BUILDDIR/$ARCH/$RELEASEDIR/$METADIR/update-binary
    cp -f $UPDATERSCRIPT $BUILDDIR/$ARCH/$RELEASEDIR/$METADIR/updater-script
    cp -f $INSTALLER $BUILDDIR/$ARCH/$RELEASEDIR
    cp -f $BUSYBOX $BUILDDIR/$ARCH/$RELEASEDIR
    # Create utility script
    makeutilityscript
    replace_line $BUILDDIR/$ARCH/$RELEASEDIR/util_functions.sh REL="" REL="$ADDON_RELEASE"
    replace_line $BUILDDIR/$ARCH/$RELEASEDIR/util_functions.sh ZIPTYPE="" ZIPTYPE="$ZIPTYPE"
    replace_line $BUILDDIR/$ARCH/$RELEASEDIR/util_functions.sh TARGET_GAPPS_RELEASE="" TARGET_GAPPS_RELEASE="$TARGET_GAPPS_RELEASE"
    replace_line $BUILDDIR/$ARCH/$RELEASEDIR/util_functions.sh TARGET_DIRTY_INSTALL="" TARGET_DIRTY_INSTALL="$TARGET_DIRTY_INSTALL"
    replace_line $BUILDDIR/$ARCH/$RELEASEDIR/util_functions.sh ADDON="" ADDON="$NONCONFIG"
    replace_line $BUILDDIR/$ARCH/$RELEASEDIR/util_functions.sh TARGET_BROMITE_GOOGLE="" TARGET_BROMITE_GOOGLE="$TARGET_BROMITE_GOOGLE"
    replace_line $BUILDDIR/$ARCH/$RELEASEDIR/util_functions.sh TARGET_CONFIG_VERSION="" TARGET_CONFIG_VERSION="$TARGET_CONFIG_VERSION"
    # Create LICENSE
    makelicense
    # Create ZIP
    cd $BUILDDIR/$ARCH/$RELEASEDIR
    zip -qr9 ${RELEASEDIR}.zip *
    cd ../../..
    mv $BUILDDIR/$ARCH/$RELEASEDIR/${RELEASEDIR}.zip $OUTDIR/$ARCH/${RELEASEDIR}.zip
    # Sign ZIP
    java -jar $ZIPSIGNER $OUTDIR/$ARCH/${RELEASEDIR}.zip $OUTDIR/$ARCH/${RELEASEDIR}_signed.zip 2>/dev/null
    # Set build VARIANT in global environment
    echo "TARGET_VARIANT_BROMITE" >> $OUTDIR/ENV/env_variant.sh
    # List signed ZIP
    ls $OUTDIR/$ARCH/${RELEASEDIR}_signed.zip
    # Wipe unsigned ZIP
    rm -rf $OUTDIR/$ARCH/${RELEASEDIR}.zip
  fi
  # Calculator
  if [ "$VARIANT" == "calculator" ]; then
    # Set Addon package sources
    SOURCES_ALL="sources/addon-sources/all"
    SOURCES_ARMEABI="sources/addon-sources/arm"
    SOURCES_AARCH64="sources/addon-sources/arm64"
    echo "Generating BiTGApps Calculator Addon package"
    # Create release directory
    mkdir "$BUILDDIR/$ARCH/BiTGApps-addon-calculator-${COMMONADDONRELEASE}"
    RELEASEDIR="BiTGApps-addon-calculator-${COMMONADDONRELEASE}"
    # Create package components
    mkdir -p $BUILDDIR/$ARCH/$RELEASEDIR/$METADIR
    mkdir -p $BUILDDIR/$ARCH/$RELEASEDIR/$ZIP
    mkdir -p $BUILDDIR/$ARCH/$RELEASEDIR/$SYS
    # Install app package
    cp -f $SOURCES_ALL/app/CalculatorGooglePrebuilt.tar.xz $BUILDDIR/$ARCH/$RELEASEDIR/$SYS
    # Installer components
    cp -f $UPDATEBINARY $BUILDDIR/$ARCH/$RELEASEDIR/$METADIR/update-binary
    cp -f $UPDATERSCRIPT $BUILDDIR/$ARCH/$RELEASEDIR/$METADIR/updater-script
    cp -f $INSTALLER $BUILDDIR/$ARCH/$RELEASEDIR
    cp -f $BUSYBOX $BUILDDIR/$ARCH/$RELEASEDIR
    # Create utility script
    makeutilityscript
    replace_line $BUILDDIR/$ARCH/$RELEASEDIR/util_functions.sh REL="" REL="$ADDON_RELEASE"
    replace_line $BUILDDIR/$ARCH/$RELEASEDIR/util_functions.sh ZIPTYPE="" ZIPTYPE="$ZIPTYPE"
    replace_line $BUILDDIR/$ARCH/$RELEASEDIR/util_functions.sh TARGET_GAPPS_RELEASE="" TARGET_GAPPS_RELEASE="$TARGET_GAPPS_RELEASE"
    replace_line $BUILDDIR/$ARCH/$RELEASEDIR/util_functions.sh TARGET_DIRTY_INSTALL="" TARGET_DIRTY_INSTALL="$TARGET_DIRTY_INSTALL"
    replace_line $BUILDDIR/$ARCH/$RELEASEDIR/util_functions.sh ADDON="" ADDON="$NONCONFIG"
    replace_line $BUILDDIR/$ARCH/$RELEASEDIR/util_functions.sh TARGET_CALCULATOR_GOOGLE="" TARGET_CALCULATOR_GOOGLE="$TARGET_CALCULATOR_GOOGLE"
    replace_line $BUILDDIR/$ARCH/$RELEASEDIR/util_functions.sh TARGET_CONFIG_VERSION="" TARGET_CONFIG_VERSION="$TARGET_CONFIG_VERSION"
    # Create LICENSE
    makelicense
    # Create ZIP
    cd $BUILDDIR/$ARCH/$RELEASEDIR
    zip -qr9 ${RELEASEDIR}.zip *
    cd ../../..
    mv $BUILDDIR/$ARCH/$RELEASEDIR/${RELEASEDIR}.zip $OUTDIR/$ARCH/${RELEASEDIR}.zip
    # Sign ZIP
    java -jar $ZIPSIGNER $OUTDIR/$ARCH/${RELEASEDIR}.zip $OUTDIR/$ARCH/${RELEASEDIR}_signed.zip 2>/dev/null
    # Set build VARIANT in global environment
    echo "TARGET_VARIANT_CALCULATOR" >> $OUTDIR/ENV/env_variant.sh
    # List signed ZIP
    ls $OUTDIR/$ARCH/${RELEASEDIR}_signed.zip
    # Wipe unsigned ZIP
    rm -rf $OUTDIR/$ARCH/${RELEASEDIR}.zip
  fi
  # Calendar
  if [ "$VARIANT" == "calendar" ]; then
    # Set Addon package sources
    SOURCES_ALL="sources/addon-sources/all"
    SOURCES_ARMEABI="sources/addon-sources/arm"
    SOURCES_AARCH64="sources/addon-sources/arm64"
    echo "Generating BiTGApps Calendar Addon package"
    # Create release directory
    mkdir "$BUILDDIR/$ARCH/BiTGApps-addon-calendar-${COMMONADDONRELEASE}"
    RELEASEDIR="BiTGApps-addon-calendar-${COMMONADDONRELEASE}"
    # Create package components
    mkdir -p $BUILDDIR/$ARCH/$RELEASEDIR/$METADIR
    mkdir -p $BUILDDIR/$ARCH/$RELEASEDIR/$ZIP
    mkdir -p $BUILDDIR/$ARCH/$RELEASEDIR/$SYS
    # Install app package
    cp -f $SOURCES_ALL/app/CalendarGooglePrebuilt.tar.xz $BUILDDIR/$ARCH/$RELEASEDIR/$SYS
    # Installer components
    cp -f $UPDATEBINARY $BUILDDIR/$ARCH/$RELEASEDIR/$METADIR/update-binary
    cp -f $UPDATERSCRIPT $BUILDDIR/$ARCH/$RELEASEDIR/$METADIR/updater-script
    cp -f $INSTALLER $BUILDDIR/$ARCH/$RELEASEDIR
    cp -f $BUSYBOX $BUILDDIR/$ARCH/$RELEASEDIR
    # Create utility script
    makeutilityscript
    replace_line $BUILDDIR/$ARCH/$RELEASEDIR/util_functions.sh REL="" REL="$ADDON_RELEASE"
    replace_line $BUILDDIR/$ARCH/$RELEASEDIR/util_functions.sh ZIPTYPE="" ZIPTYPE="$ZIPTYPE"
    replace_line $BUILDDIR/$ARCH/$RELEASEDIR/util_functions.sh TARGET_GAPPS_RELEASE="" TARGET_GAPPS_RELEASE="$TARGET_GAPPS_RELEASE"
    replace_line $BUILDDIR/$ARCH/$RELEASEDIR/util_functions.sh TARGET_DIRTY_INSTALL="" TARGET_DIRTY_INSTALL="$TARGET_DIRTY_INSTALL"
    replace_line $BUILDDIR/$ARCH/$RELEASEDIR/util_functions.sh ADDON="" ADDON="$NONCONFIG"
    replace_line $BUILDDIR/$ARCH/$RELEASEDIR/util_functions.sh TARGET_CALENDAR_GOOGLE="" TARGET_CALENDAR_GOOGLE="$TARGET_CALENDAR_GOOGLE"
    replace_line $BUILDDIR/$ARCH/$RELEASEDIR/util_functions.sh TARGET_CONFIG_VERSION="" TARGET_CONFIG_VERSION="$TARGET_CONFIG_VERSION"
    # Create LICENSE
    makelicense
    # Create ZIP
    cd $BUILDDIR/$ARCH/$RELEASEDIR
    zip -qr9 ${RELEASEDIR}.zip *
    cd ../../..
    mv $BUILDDIR/$ARCH/$RELEASEDIR/${RELEASEDIR}.zip $OUTDIR/$ARCH/${RELEASEDIR}.zip
    # Sign ZIP
    java -jar $ZIPSIGNER $OUTDIR/$ARCH/${RELEASEDIR}.zip $OUTDIR/$ARCH/${RELEASEDIR}_signed.zip 2>/dev/null
    # Set build VARIANT in global environment
    echo "TARGET_VARIANT_CALENDAR" >> $OUTDIR/ENV/env_variant.sh
    # List signed ZIP
    ls $OUTDIR/$ARCH/${RELEASEDIR}_signed.zip
    # Wipe unsigned ZIP
    rm -rf $OUTDIR/$ARCH/${RELEASEDIR}.zip
  fi
  # Chrome
  if [ "$VARIANT" == "chrome" ]; then
    # Set Addon package sources
    SOURCES_ALL="sources/addon-sources/all"
    SOURCES_ARMEABI="sources/addon-sources/arm"
    SOURCES_AARCH64="sources/addon-sources/arm64"
    echo "Generating BiTGApps Chrome Addon package"
    # Create release directory
    mkdir "$BUILDDIR/$ARCH/BiTGApps-addon-chrome-${COMMONADDONRELEASE}"
    RELEASEDIR="BiTGApps-addon-chrome-${COMMONADDONRELEASE}"
    # Create package components
    mkdir -p $BUILDDIR/$ARCH/$RELEASEDIR/$METADIR
    mkdir -p $BUILDDIR/$ARCH/$RELEASEDIR/$ZIP
    mkdir -p $BUILDDIR/$ARCH/$RELEASEDIR/$SYS
    # Install app package
    cp -f $SOURCES_ALL/app/ChromeGooglePrebuilt.tar.xz $BUILDDIR/$ARCH/$RELEASEDIR/$SYS
    cp -f $SOURCES_ALL/app/TrichromeLibrary.tar.xz $BUILDDIR/$ARCH/$RELEASEDIR/$SYS
    cp -f $SOURCES_ALL/app/WebViewGoogle.tar.xz $BUILDDIR/$ARCH/$RELEASEDIR/$SYS
    # Installer components
    cp -f $UPDATEBINARY $BUILDDIR/$ARCH/$RELEASEDIR/$METADIR/update-binary
    cp -f $UPDATERSCRIPT $BUILDDIR/$ARCH/$RELEASEDIR/$METADIR/updater-script
    cp -f $INSTALLER $BUILDDIR/$ARCH/$RELEASEDIR
    cp -f $BUSYBOX $BUILDDIR/$ARCH/$RELEASEDIR
    # Create utility script
    makeutilityscript
    replace_line $BUILDDIR/$ARCH/$RELEASEDIR/util_functions.sh REL="" REL="$ADDON_RELEASE"
    replace_line $BUILDDIR/$ARCH/$RELEASEDIR/util_functions.sh ZIPTYPE="" ZIPTYPE="$ZIPTYPE"
    replace_line $BUILDDIR/$ARCH/$RELEASEDIR/util_functions.sh TARGET_GAPPS_RELEASE="" TARGET_GAPPS_RELEASE="$TARGET_GAPPS_RELEASE"
    replace_line $BUILDDIR/$ARCH/$RELEASEDIR/util_functions.sh TARGET_DIRTY_INSTALL="" TARGET_DIRTY_INSTALL="$TARGET_DIRTY_INSTALL"
    replace_line $BUILDDIR/$ARCH/$RELEASEDIR/util_functions.sh ADDON="" ADDON="$NONCONFIG"
    replace_line $BUILDDIR/$ARCH/$RELEASEDIR/util_functions.sh TARGET_CHROME_GOOGLE="" TARGET_CHROME_GOOGLE="$TARGET_CHROME_GOOGLE"
    replace_line $BUILDDIR/$ARCH/$RELEASEDIR/util_functions.sh TARGET_CONFIG_VERSION="" TARGET_CONFIG_VERSION="$TARGET_CONFIG_VERSION"
    # Create LICENSE
    makelicense
    # Create ZIP
    cd $BUILDDIR/$ARCH/$RELEASEDIR
    zip -qr9 ${RELEASEDIR}.zip *
    cd ../../..
    mv $BUILDDIR/$ARCH/$RELEASEDIR/${RELEASEDIR}.zip $OUTDIR/$ARCH/${RELEASEDIR}.zip
    # Sign ZIP
    java -jar $ZIPSIGNER $OUTDIR/$ARCH/${RELEASEDIR}.zip $OUTDIR/$ARCH/${RELEASEDIR}_signed.zip 2>/dev/null
    # Set build VARIANT in global environment
    echo "TARGET_VARIANT_CHROME" >> $OUTDIR/ENV/env_variant.sh
    # List signed ZIP
    ls $OUTDIR/$ARCH/${RELEASEDIR}_signed.zip
    # Wipe unsigned ZIP
    rm -rf $OUTDIR/$ARCH/${RELEASEDIR}.zip
  fi
  # Contacts
  if [ "$VARIANT" == "contacts" ]; then
    # Set Addon package sources
    SOURCES_ALL="sources/addon-sources/all"
    SOURCES_ARMEABI="sources/addon-sources/arm"
    SOURCES_AARCH64="sources/addon-sources/arm64"
    echo "Generating BiTGApps Contacts Addon package"
    # Create release directory
    mkdir "$BUILDDIR/$ARCH/BiTGApps-addon-contacts-${COMMONADDONRELEASE}"
    RELEASEDIR="BiTGApps-addon-contacts-${COMMONADDONRELEASE}"
    # Create package components
    mkdir -p $BUILDDIR/$ARCH/$RELEASEDIR/$METADIR
    mkdir -p $BUILDDIR/$ARCH/$RELEASEDIR/$ZIP
    mkdir -p $BUILDDIR/$ARCH/$RELEASEDIR/$CORE
    # Install priv-app package
    cp -f $SOURCES_ALL/priv-app/ContactsGooglePrebuilt.tar.xz $BUILDDIR/$ARCH/$RELEASEDIR/$CORE
    # Installer components
    cp -f $UPDATEBINARY $BUILDDIR/$ARCH/$RELEASEDIR/$METADIR/update-binary
    cp -f $UPDATERSCRIPT $BUILDDIR/$ARCH/$RELEASEDIR/$METADIR/updater-script
    cp -f $INSTALLER $BUILDDIR/$ARCH/$RELEASEDIR
    cp -f $BUSYBOX $BUILDDIR/$ARCH/$RELEASEDIR
    # Create utility script
    makeutilityscript
    replace_line $BUILDDIR/$ARCH/$RELEASEDIR/util_functions.sh REL="" REL="$ADDON_RELEASE"
    replace_line $BUILDDIR/$ARCH/$RELEASEDIR/util_functions.sh ZIPTYPE="" ZIPTYPE="$ZIPTYPE"
    replace_line $BUILDDIR/$ARCH/$RELEASEDIR/util_functions.sh TARGET_GAPPS_RELEASE="" TARGET_GAPPS_RELEASE="$TARGET_GAPPS_RELEASE"
    replace_line $BUILDDIR/$ARCH/$RELEASEDIR/util_functions.sh TARGET_DIRTY_INSTALL="" TARGET_DIRTY_INSTALL="$TARGET_DIRTY_INSTALL"
    replace_line $BUILDDIR/$ARCH/$RELEASEDIR/util_functions.sh ADDON="" ADDON="$NONCONFIG"
    replace_line $BUILDDIR/$ARCH/$RELEASEDIR/util_functions.sh TARGET_CONTACTS_GOOGLE="" TARGET_CONTACTS_GOOGLE="$TARGET_CONTACTS_GOOGLE"
    replace_line $BUILDDIR/$ARCH/$RELEASEDIR/util_functions.sh TARGET_CONFIG_VERSION="" TARGET_CONFIG_VERSION="$TARGET_CONFIG_VERSION"
    # Create LICENSE
    makelicense
    # Create ZIP
    cd $BUILDDIR/$ARCH/$RELEASEDIR
    zip -qr9 ${RELEASEDIR}.zip *
    cd ../../..
    mv $BUILDDIR/$ARCH/$RELEASEDIR/${RELEASEDIR}.zip $OUTDIR/$ARCH/${RELEASEDIR}.zip
    # Sign ZIP
    java -jar $ZIPSIGNER $OUTDIR/$ARCH/${RELEASEDIR}.zip $OUTDIR/$ARCH/${RELEASEDIR}_signed.zip 2>/dev/null
    # Set build VARIANT in global environment
    echo "TARGET_VARIANT_CONTACTS" >> $OUTDIR/ENV/env_variant.sh
    # List signed ZIP
    ls $OUTDIR/$ARCH/${RELEASEDIR}_signed.zip
    # Wipe unsigned ZIP
    rm -rf $OUTDIR/$ARCH/${RELEASEDIR}.zip
  fi
  # DeskClock
  if [ "$VARIANT" == "deskclock" ]; then
    # Set Addon package sources
    SOURCES_ALL="sources/addon-sources/all"
    SOURCES_ARMEABI="sources/addon-sources/arm"
    SOURCES_AARCH64="sources/addon-sources/arm64"
    echo "Generating BiTGApps DeskClock Addon package"
    # Create release directory
    mkdir "$BUILDDIR/$ARCH/BiTGApps-addon-deskclock-${COMMONADDONRELEASE}"
    RELEASEDIR="BiTGApps-addon-deskclock-${COMMONADDONRELEASE}"
    # Create package components
    mkdir -p $BUILDDIR/$ARCH/$RELEASEDIR/$METADIR
    mkdir -p $BUILDDIR/$ARCH/$RELEASEDIR/$ZIP
    mkdir -p $BUILDDIR/$ARCH/$RELEASEDIR/$SYS
    # Install app package
    cp -f $SOURCES_ALL/app/DeskClockGooglePrebuilt.tar.xz $BUILDDIR/$ARCH/$RELEASEDIR/$SYS
    # Installer components
    cp -f $UPDATEBINARY $BUILDDIR/$ARCH/$RELEASEDIR/$METADIR/update-binary
    cp -f $UPDATERSCRIPT $BUILDDIR/$ARCH/$RELEASEDIR/$METADIR/updater-script
    cp -f $INSTALLER $BUILDDIR/$ARCH/$RELEASEDIR
    cp -f $BUSYBOX $BUILDDIR/$ARCH/$RELEASEDIR
    # Create utility script
    makeutilityscript
    replace_line $BUILDDIR/$ARCH/$RELEASEDIR/util_functions.sh REL="" REL="$ADDON_RELEASE"
    replace_line $BUILDDIR/$ARCH/$RELEASEDIR/util_functions.sh ZIPTYPE="" ZIPTYPE="$ZIPTYPE"
    replace_line $BUILDDIR/$ARCH/$RELEASEDIR/util_functions.sh TARGET_GAPPS_RELEASE="" TARGET_GAPPS_RELEASE="$TARGET_GAPPS_RELEASE"
    replace_line $BUILDDIR/$ARCH/$RELEASEDIR/util_functions.sh TARGET_DIRTY_INSTALL="" TARGET_DIRTY_INSTALL="$TARGET_DIRTY_INSTALL"
    replace_line $BUILDDIR/$ARCH/$RELEASEDIR/util_functions.sh ADDON="" ADDON="$NONCONFIG"
    replace_line $BUILDDIR/$ARCH/$RELEASEDIR/util_functions.sh TARGET_DESKCLOCK_GOOGLE="" TARGET_DESKCLOCK_GOOGLE="$TARGET_DESKCLOCK_GOOGLE"
    replace_line $BUILDDIR/$ARCH/$RELEASEDIR/util_functions.sh TARGET_CONFIG_VERSION="" TARGET_CONFIG_VERSION="$TARGET_CONFIG_VERSION"
    # Create LICENSE
    makelicense
    # Create ZIP
    cd $BUILDDIR/$ARCH/$RELEASEDIR
    zip -qr9 ${RELEASEDIR}.zip *
    cd ../../..
    mv $BUILDDIR/$ARCH/$RELEASEDIR/${RELEASEDIR}.zip $OUTDIR/$ARCH/${RELEASEDIR}.zip
    # Sign ZIP
    java -jar $ZIPSIGNER $OUTDIR/$ARCH/${RELEASEDIR}.zip $OUTDIR/$ARCH/${RELEASEDIR}_signed.zip 2>/dev/null
    # Set build VARIANT in global environment
    echo "TARGET_VARIANT_DESKCLOCK" >> $OUTDIR/ENV/env_variant.sh
    # List signed ZIP
    ls $OUTDIR/$ARCH/${RELEASEDIR}_signed.zip
    # Wipe unsigned ZIP
    rm -rf $OUTDIR/$ARCH/${RELEASEDIR}.zip
  fi
  # Dialer
  if [ "$VARIANT" == "dialer" ]; then
    # Set Addon package sources
    SOURCES_ALL="sources/addon-sources/all"
    SOURCES_ARMEABI="sources/addon-sources/arm"
    SOURCES_AARCH64="sources/addon-sources/arm64"
    echo "Generating BiTGApps Dialer Addon package"
    # Create release directory
    mkdir "$BUILDDIR/$ARCH/BiTGApps-addon-dialer-${COMMONADDONRELEASE}"
    RELEASEDIR="BiTGApps-addon-dialer-${COMMONADDONRELEASE}"
    # Create package components
    mkdir -p $BUILDDIR/$ARCH/$RELEASEDIR/$METADIR
    mkdir -p $BUILDDIR/$ARCH/$RELEASEDIR/$ZIP
    mkdir -p $BUILDDIR/$ARCH/$RELEASEDIR/$CORE
    # Install etc package
    cp -f $SOURCES_ALL/etc/DialerPermissions.tar.xz $BUILDDIR/$ARCH/$RELEASEDIR/$ZIP
    # Install framework package
    cp -f $SOURCES_ALL/framework/DialerFramework.tar.xz $BUILDDIR/$ARCH/$RELEASEDIR/$ZIP
    # Install priv-app packages
    cp -f $SOURCES_ARMEABI/priv-app/DialerGooglePrebuilt_arm.tar.xz $BUILDDIR/$ARCH/$RELEASEDIR/$CORE
    cp -f $SOURCES_AARCH64/priv-app/DialerGooglePrebuilt_arm64.tar.xz $BUILDDIR/$ARCH/$RELEASEDIR/$CORE
    # Installer components
    cp -f $UPDATEBINARY $BUILDDIR/$ARCH/$RELEASEDIR/$METADIR/update-binary
    cp -f $UPDATERSCRIPT $BUILDDIR/$ARCH/$RELEASEDIR/$METADIR/updater-script
    cp -f $INSTALLER $BUILDDIR/$ARCH/$RELEASEDIR
    cp -f $BUSYBOX $BUILDDIR/$ARCH/$RELEASEDIR
    # Create utility script
    makeutilityscript
    replace_line $BUILDDIR/$ARCH/$RELEASEDIR/util_functions.sh REL="" REL="$ADDON_RELEASE"
    replace_line $BUILDDIR/$ARCH/$RELEASEDIR/util_functions.sh ZIPTYPE="" ZIPTYPE="$ZIPTYPE"
    replace_line $BUILDDIR/$ARCH/$RELEASEDIR/util_functions.sh TARGET_GAPPS_RELEASE="" TARGET_GAPPS_RELEASE="$TARGET_GAPPS_RELEASE"
    replace_line $BUILDDIR/$ARCH/$RELEASEDIR/util_functions.sh TARGET_DIRTY_INSTALL="" TARGET_DIRTY_INSTALL="$TARGET_DIRTY_INSTALL"
    replace_line $BUILDDIR/$ARCH/$RELEASEDIR/util_functions.sh ADDON="" ADDON="$NONCONFIG"
    replace_line $BUILDDIR/$ARCH/$RELEASEDIR/util_functions.sh TARGET_DIALER_GOOGLE="" TARGET_DIALER_GOOGLE="$TARGET_DIALER_GOOGLE"
    replace_line $BUILDDIR/$ARCH/$RELEASEDIR/util_functions.sh TARGET_CONFIG_VERSION="" TARGET_CONFIG_VERSION="$TARGET_CONFIG_VERSION"
    # Create LICENSE
    makelicense
    # Create ZIP
    cd $BUILDDIR/$ARCH/$RELEASEDIR
    zip -qr9 ${RELEASEDIR}.zip *
    cd ../../..
    mv $BUILDDIR/$ARCH/$RELEASEDIR/${RELEASEDIR}.zip $OUTDIR/$ARCH/${RELEASEDIR}.zip
    # Sign ZIP
    java -jar $ZIPSIGNER $OUTDIR/$ARCH/${RELEASEDIR}.zip $OUTDIR/$ARCH/${RELEASEDIR}_signed.zip 2>/dev/null
    # Set build VARIANT in global environment
    echo "TARGET_VARIANT_DIALER" >> $OUTDIR/ENV/env_variant.sh
    # List signed ZIP
    ls $OUTDIR/$ARCH/${RELEASEDIR}_signed.zip
    # Wipe unsigned ZIP
    rm -rf $OUTDIR/$ARCH/${RELEASEDIR}.zip
  fi
  # DPS
  if [ "$VARIANT" == "dps" ]; then
    # Set Addon package sources
    SOURCES_ALL="sources/addon-sources/all"
    SOURCES_ARMEABI="sources/addon-sources/arm"
    SOURCES_AARCH64="sources/addon-sources/arm64"
    echo "Generating BiTGApps DPS Addon package"
    # Create release directory
    mkdir "$BUILDDIR/$ARCH/BiTGApps-addon-dps-${COMMONADDONRELEASE}"
    RELEASEDIR="BiTGApps-addon-dps-${COMMONADDONRELEASE}"
    # Create package components
    mkdir -p $BUILDDIR/$ARCH/$RELEASEDIR/$METADIR
    mkdir -p $BUILDDIR/$ARCH/$RELEASEDIR/$ZIP
    mkdir -p $BUILDDIR/$ARCH/$RELEASEDIR/$CORE
    # Install etc packages
    cp -f $SOURCES_ALL/etc/DPSFirmware.tar.xz $BUILDDIR/$ARCH/$RELEASEDIR/$ZIP
    cp -f $SOURCES_ALL/etc/DPSPermissions.tar.xz $BUILDDIR/$ARCH/$RELEASEDIR/$ZIP
    # Install overlay package
    cp -f $SOURCES_ALL/overlay/DPSOverlay.tar.xz $BUILDDIR/$ARCH/$RELEASEDIR/$OVERLAY
    # Install priv-app packages
    cp -f $SOURCES_ARMEABI/priv-app/DPSGooglePrebuilt_arm.tar.xz $BUILDDIR/$ARCH/$RELEASEDIR/$CORE
    cp -f $SOURCES_AARCH64/priv-app/DPSGooglePrebuilt_arm64.tar.xz $BUILDDIR/$ARCH/$RELEASEDIR/$CORE
    # Installer components
    cp -f $UPDATEBINARY $BUILDDIR/$ARCH/$RELEASEDIR/$METADIR/update-binary
    cp -f $UPDATERSCRIPT $BUILDDIR/$ARCH/$RELEASEDIR/$METADIR/updater-script
    cp -f $INSTALLER $BUILDDIR/$ARCH/$RELEASEDIR
    cp -f $BUSYBOX $BUILDDIR/$ARCH/$RELEASEDIR
    # Create utility script
    makeutilityscript
    replace_line $BUILDDIR/$ARCH/$RELEASEDIR/util_functions.sh REL="" REL="$ADDON_RELEASE"
    replace_line $BUILDDIR/$ARCH/$RELEASEDIR/util_functions.sh ZIPTYPE="" ZIPTYPE="$ZIPTYPE"
    replace_line $BUILDDIR/$ARCH/$RELEASEDIR/util_functions.sh TARGET_GAPPS_RELEASE="" TARGET_GAPPS_RELEASE="$TARGET_GAPPS_RELEASE"
    replace_line $BUILDDIR/$ARCH/$RELEASEDIR/util_functions.sh TARGET_DIRTY_INSTALL="" TARGET_DIRTY_INSTALL="$TARGET_DIRTY_INSTALL"
    replace_line $BUILDDIR/$ARCH/$RELEASEDIR/util_functions.sh ADDON="" ADDON="$NONCONFIG"
    replace_line $BUILDDIR/$ARCH/$RELEASEDIR/util_functions.sh TARGET_DPS_GOOGLE="" TARGET_DPS_GOOGLE="$TARGET_DPS_GOOGLE"
    replace_line $BUILDDIR/$ARCH/$RELEASEDIR/util_functions.sh TARGET_CONFIG_VERSION="" TARGET_CONFIG_VERSION="$TARGET_CONFIG_VERSION"
    # Create LICENSE
    makelicense
    # Create ZIP
    cd $BUILDDIR/$ARCH/$RELEASEDIR
    zip -qr9 ${RELEASEDIR}.zip *
    cd ../../..
    mv $BUILDDIR/$ARCH/$RELEASEDIR/${RELEASEDIR}.zip $OUTDIR/$ARCH/${RELEASEDIR}.zip
    # Sign ZIP
    java -jar $ZIPSIGNER $OUTDIR/$ARCH/${RELEASEDIR}.zip $OUTDIR/$ARCH/${RELEASEDIR}_signed.zip 2>/dev/null
    # Set build VARIANT in global environment
    echo "TARGET_VARIANT_DPS" >> $OUTDIR/ENV/env_variant.sh
    # List signed ZIP
    ls $OUTDIR/$ARCH/${RELEASEDIR}_signed.zip
    # Wipe unsigned ZIP
    rm -rf $OUTDIR/$ARCH/${RELEASEDIR}.zip
  fi
  # Gboard
  if [ "$VARIANT" == "gboard" ]; then
    # Set Addon package sources
    SOURCES_ALL="sources/addon-sources/all"
    SOURCES_ARMEABI="sources/addon-sources/arm"
    SOURCES_AARCH64="sources/addon-sources/arm64"
    echo "Generating BiTGApps Gboard Addon package"
    # Create release directory
    mkdir "$BUILDDIR/$ARCH/BiTGApps-addon-gboard-${COMMONADDONRELEASE}"
    RELEASEDIR="BiTGApps-addon-gboard-${COMMONADDONRELEASE}"
    # Create package components
    mkdir -p $BUILDDIR/$ARCH/$RELEASEDIR/$METADIR
    mkdir -p $BUILDDIR/$ARCH/$RELEASEDIR/$ZIP
    mkdir -p $BUILDDIR/$ARCH/$RELEASEDIR/$SYS
    # Install app packages
    cp -f $SOURCES_ARMEABI/app/GboardGooglePrebuilt_arm.tar.xz $BUILDDIR/$ARCH/$RELEASEDIR/$SYS
    cp -f $SOURCES_AARCH64/app/GboardGooglePrebuilt_arm64.tar.xz $BUILDDIR/$ARCH/$RELEASEDIR/$SYS
    # Install usr packages
    cp -f $SOURCES_ALL/usr/usr_share.tar.xz $BUILDDIR/$ARCH/$RELEASEDIR/$ZIP
    cp -f $SOURCES_ALL/usr/usr_srec.tar.xz $BUILDDIR/$ARCH/$RELEASEDIR/$ZIP
    # Installer components
    cp -f $UPDATEBINARY $BUILDDIR/$ARCH/$RELEASEDIR/$METADIR/update-binary
    cp -f $UPDATERSCRIPT $BUILDDIR/$ARCH/$RELEASEDIR/$METADIR/updater-script
    cp -f $INSTALLER $BUILDDIR/$ARCH/$RELEASEDIR
    cp -f $BUSYBOX $BUILDDIR/$ARCH/$RELEASEDIR
    # Create utility script
    makeutilityscript
    replace_line $BUILDDIR/$ARCH/$RELEASEDIR/util_functions.sh REL="" REL="$ADDON_RELEASE"
    replace_line $BUILDDIR/$ARCH/$RELEASEDIR/util_functions.sh ZIPTYPE="" ZIPTYPE="$ZIPTYPE"
    replace_line $BUILDDIR/$ARCH/$RELEASEDIR/util_functions.sh TARGET_GAPPS_RELEASE="" TARGET_GAPPS_RELEASE="$TARGET_GAPPS_RELEASE"
    replace_line $BUILDDIR/$ARCH/$RELEASEDIR/util_functions.sh TARGET_DIRTY_INSTALL="" TARGET_DIRTY_INSTALL="$TARGET_DIRTY_INSTALL"
    replace_line $BUILDDIR/$ARCH/$RELEASEDIR/util_functions.sh ADDON="" ADDON="$NONCONFIG"
    replace_line $BUILDDIR/$ARCH/$RELEASEDIR/util_functions.sh TARGET_GBOARD_GOOGLE="" TARGET_GBOARD_GOOGLE="$TARGET_GBOARD_GOOGLE"
    replace_line $BUILDDIR/$ARCH/$RELEASEDIR/util_functions.sh TARGET_CONFIG_VERSION="" TARGET_CONFIG_VERSION="$TARGET_CONFIG_VERSION"
    # Create LICENSE
    makelicense
    # Create ZIP
    cd $BUILDDIR/$ARCH/$RELEASEDIR
    zip -qr9 ${RELEASEDIR}.zip *
    cd ../../..
    mv $BUILDDIR/$ARCH/$RELEASEDIR/${RELEASEDIR}.zip $OUTDIR/$ARCH/${RELEASEDIR}.zip
    # Sign ZIP
    java -jar $ZIPSIGNER $OUTDIR/$ARCH/${RELEASEDIR}.zip $OUTDIR/$ARCH/${RELEASEDIR}_signed.zip 2>/dev/null
    # Set build VARIANT in global environment
    echo "TARGET_VARIANT_GBOARD" >> $OUTDIR/ENV/env_variant.sh
    # List signed ZIP
    ls $OUTDIR/$ARCH/${RELEASEDIR}_signed.zip
    # Wipe unsigned ZIP
    rm -rf $OUTDIR/$ARCH/${RELEASEDIR}.zip
  fi
  # Gearhead
  if [ "$VARIANT" == "gearhead" ]; then
    # Set Addon package sources
    SOURCES_ALL="sources/addon-sources/all"
    SOURCES_ARMEABI="sources/addon-sources/arm"
    SOURCES_AARCH64="sources/addon-sources/arm64"
    echo "Generating BiTGApps Gearhead Addon package"
    # Create release directory
    mkdir "$BUILDDIR/$ARCH/BiTGApps-addon-gearhead-${COMMONADDONRELEASE}"
    RELEASEDIR="BiTGApps-addon-gearhead-${COMMONADDONRELEASE}"
    # Create package components
    mkdir -p $BUILDDIR/$ARCH/$RELEASEDIR/$METADIR
    mkdir -p $BUILDDIR/$ARCH/$RELEASEDIR/$ZIP
    mkdir -p $BUILDDIR/$ARCH/$RELEASEDIR/$CORE
    # Install priv-app packages
    cp -f $SOURCES_ARMEABI/priv-app/GearheadGooglePrebuilt_arm.tar.xz $BUILDDIR/$ARCH/$RELEASEDIR/$CORE
    cp -f $SOURCES_AARCH64/priv-app/GearheadGooglePrebuilt_arm64.tar.xz $BUILDDIR/$ARCH/$RELEASEDIR/$CORE
    # Installer components
    cp -f $UPDATEBINARY $BUILDDIR/$ARCH/$RELEASEDIR/$METADIR/update-binary
    cp -f $UPDATERSCRIPT $BUILDDIR/$ARCH/$RELEASEDIR/$METADIR/updater-script
    cp -f $INSTALLER $BUILDDIR/$ARCH/$RELEASEDIR
    cp -f $BUSYBOX $BUILDDIR/$ARCH/$RELEASEDIR
    # Create utility script
    makeutilityscript
    replace_line $BUILDDIR/$ARCH/$RELEASEDIR/util_functions.sh REL="" REL="$ADDON_RELEASE"
    replace_line $BUILDDIR/$ARCH/$RELEASEDIR/util_functions.sh ZIPTYPE="" ZIPTYPE="$ZIPTYPE"
    replace_line $BUILDDIR/$ARCH/$RELEASEDIR/util_functions.sh TARGET_GAPPS_RELEASE="" TARGET_GAPPS_RELEASE="$TARGET_GAPPS_RELEASE"
    replace_line $BUILDDIR/$ARCH/$RELEASEDIR/util_functions.sh TARGET_DIRTY_INSTALL="" TARGET_DIRTY_INSTALL="$TARGET_DIRTY_INSTALL"
    replace_line $BUILDDIR/$ARCH/$RELEASEDIR/util_functions.sh ADDON="" ADDON="$NONCONFIG"
    replace_line $BUILDDIR/$ARCH/$RELEASEDIR/util_functions.sh TARGET_GEARHEAD_GOOGLE="" TARGET_GEARHEAD_GOOGLE="$TARGET_GEARHEAD_GOOGLE"
    replace_line $BUILDDIR/$ARCH/$RELEASEDIR/util_functions.sh TARGET_CONFIG_VERSION="" TARGET_CONFIG_VERSION="$TARGET_CONFIG_VERSION"
    # Create LICENSE
    makelicense
    # Create ZIP
    cd $BUILDDIR/$ARCH/$RELEASEDIR
    zip -qr9 ${RELEASEDIR}.zip *
    cd ../../..
    mv $BUILDDIR/$ARCH/$RELEASEDIR/${RELEASEDIR}.zip $OUTDIR/$ARCH/${RELEASEDIR}.zip
    # Sign ZIP
    java -jar $ZIPSIGNER $OUTDIR/$ARCH/${RELEASEDIR}.zip $OUTDIR/$ARCH/${RELEASEDIR}_signed.zip 2>/dev/null
    # Set build VARIANT in global environment
    echo "TARGET_VARIANT_GEARHEAD" >> $OUTDIR/ENV/env_variant.sh
    # List signed ZIP
    ls $OUTDIR/$ARCH/${RELEASEDIR}_signed.zip
    # Wipe unsigned ZIP
    rm -rf $OUTDIR/$ARCH/${RELEASEDIR}.zip
  fi
  # Launcher
  if [ "$VARIANT" == "launcher" ]; then
    # Set Addon package sources
    SOURCES_ALL="sources/addon-sources/all"
    SOURCES_ARMEABI="sources/addon-sources/arm"
    SOURCES_AARCH64="sources/addon-sources/arm64"
    echo "Generating BiTGApps Launcher Addon package"
    # Create release directory
    mkdir "$BUILDDIR/$ARCH/BiTGApps-addon-launcher-${COMMONADDONRELEASE}"
    RELEASEDIR="BiTGApps-addon-launcher-${COMMONADDONRELEASE}"
    # Create package components
    mkdir -p $BUILDDIR/$ARCH/$RELEASEDIR/$METADIR
    mkdir -p $BUILDDIR/$ARCH/$RELEASEDIR/$ZIP
    mkdir -p $BUILDDIR/$ARCH/$RELEASEDIR/$CORE
    mkdir -p $BUILDDIR/$ARCH/$RELEASEDIR/$OVERLAY
    # Install etc packages
    cp -f $SOURCES_ALL/etc/LauncherPermissions.tar.xz $BUILDDIR/$ARCH/$RELEASEDIR/$ZIP
    cp -f $SOURCES_ALL/etc/LauncherSysconfig.tar.xz $BUILDDIR/$ARCH/$RELEASEDIR/$ZIP
    # Install overlay package
    cp -f $SOURCES_ALL/overlay/NexusLauncherOverlay.tar.xz $BUILDDIR/$ARCH/$RELEASEDIR/$OVERLAY
    # Install priv-app packages
    cp -f $SOURCES_ALL/priv-app/NexusLauncherPrebuilt.tar.xz $BUILDDIR/$ARCH/$RELEASEDIR/$CORE
    cp -f $SOURCES_ALL/priv-app/NexusQuickAccessWallet.tar.xz $BUILDDIR/$ARCH/$RELEASEDIR/$CORE
    # Installer components
    cp -f $UPDATEBINARY $BUILDDIR/$ARCH/$RELEASEDIR/$METADIR/update-binary
    cp -f $UPDATERSCRIPT $BUILDDIR/$ARCH/$RELEASEDIR/$METADIR/updater-script
    cp -f $INSTALLER $BUILDDIR/$ARCH/$RELEASEDIR
    cp -f $BUSYBOX $BUILDDIR/$ARCH/$RELEASEDIR
    # Create utility script
    makeutilityscript
    replace_line $BUILDDIR/$ARCH/$RELEASEDIR/util_functions.sh REL="" REL="$ADDON_RELEASE"
    replace_line $BUILDDIR/$ARCH/$RELEASEDIR/util_functions.sh ZIPTYPE="" ZIPTYPE="$ZIPTYPE"
    replace_line $BUILDDIR/$ARCH/$RELEASEDIR/util_functions.sh TARGET_GAPPS_RELEASE="" TARGET_GAPPS_RELEASE="$TARGET_GAPPS_RELEASE"
    replace_line $BUILDDIR/$ARCH/$RELEASEDIR/util_functions.sh TARGET_DIRTY_INSTALL="" TARGET_DIRTY_INSTALL="$TARGET_DIRTY_INSTALL"
    replace_line $BUILDDIR/$ARCH/$RELEASEDIR/util_functions.sh ADDON="" ADDON="$NONCONFIG"
    replace_line $BUILDDIR/$ARCH/$RELEASEDIR/util_functions.sh TARGET_LAUNCHER_GOOGLE="" TARGET_LAUNCHER_GOOGLE="$TARGET_LAUNCHER_GOOGLE"
    replace_line $BUILDDIR/$ARCH/$RELEASEDIR/util_functions.sh TARGET_CONFIG_VERSION="" TARGET_CONFIG_VERSION="$TARGET_CONFIG_VERSION"
    # Create LICENSE
    makelicense
    # Create ZIP
    cd $BUILDDIR/$ARCH/$RELEASEDIR
    zip -qr9 ${RELEASEDIR}.zip *
    cd ../../..
    mv $BUILDDIR/$ARCH/$RELEASEDIR/${RELEASEDIR}.zip $OUTDIR/$ARCH/${RELEASEDIR}.zip
    # Sign ZIP
    java -jar $ZIPSIGNER $OUTDIR/$ARCH/${RELEASEDIR}.zip $OUTDIR/$ARCH/${RELEASEDIR}_signed.zip 2>/dev/null
    # Set build VARIANT in global environment
    echo "TARGET_VARIANT_LAUNCHER" >> $OUTDIR/ENV/env_variant.sh
    # List signed ZIP
    ls $OUTDIR/$ARCH/${RELEASEDIR}_signed.zip
    # Wipe unsigned ZIP
    rm -rf $OUTDIR/$ARCH/${RELEASEDIR}.zip
  fi
  # Maps
  if [ "$VARIANT" == "maps" ]; then
    # Set Addon package sources
    SOURCES_ALL="sources/addon-sources/all"
    SOURCES_ARMEABI="sources/addon-sources/arm"
    SOURCES_AARCH64="sources/addon-sources/arm64"
    echo "Generating BiTGApps Maps Addon package"
    # Create release directory
    mkdir "$BUILDDIR/$ARCH/BiTGApps-addon-maps-${COMMONADDONRELEASE}"
    RELEASEDIR="BiTGApps-addon-maps-${COMMONADDONRELEASE}"
    # Create package components
    mkdir -p $BUILDDIR/$ARCH/$RELEASEDIR/$METADIR
    mkdir -p $BUILDDIR/$ARCH/$RELEASEDIR/$ZIP
    mkdir -p $BUILDDIR/$ARCH/$RELEASEDIR/$SYS
    # Install etc package
    cp -f $SOURCES_ALL/etc/MapsPermissions.tar.xz $BUILDDIR/$ARCH/$RELEASEDIR/$ZIP
    # Install framework package
    cp -f $SOURCES_ALL/framework/MapsFramework.tar.xz $BUILDDIR/$ARCH/$RELEASEDIR/$ZIP
    # Install app packages
    cp -f $SOURCES_ARMEABI/app/MapsGooglePrebuilt_arm.tar.xz $BUILDDIR/$ARCH/$RELEASEDIR/$SYS
    cp -f $SOURCES_AARCH64/app/MapsGooglePrebuilt_arm64.tar.xz $BUILDDIR/$ARCH/$RELEASEDIR/$SYS
    # Installer components
    cp -f $UPDATEBINARY $BUILDDIR/$ARCH/$RELEASEDIR/$METADIR/update-binary
    cp -f $UPDATERSCRIPT $BUILDDIR/$ARCH/$RELEASEDIR/$METADIR/updater-script
    cp -f $INSTALLER $BUILDDIR/$ARCH/$RELEASEDIR
    cp -f $BUSYBOX $BUILDDIR/$ARCH/$RELEASEDIR
    # Create utility script
    makeutilityscript
    replace_line $BUILDDIR/$ARCH/$RELEASEDIR/util_functions.sh REL="" REL="$ADDON_RELEASE"
    replace_line $BUILDDIR/$ARCH/$RELEASEDIR/util_functions.sh ZIPTYPE="" ZIPTYPE="$ZIPTYPE"
    replace_line $BUILDDIR/$ARCH/$RELEASEDIR/util_functions.sh TARGET_GAPPS_RELEASE="" TARGET_GAPPS_RELEASE="$TARGET_GAPPS_RELEASE"
    replace_line $BUILDDIR/$ARCH/$RELEASEDIR/util_functions.sh TARGET_DIRTY_INSTALL="" TARGET_DIRTY_INSTALL="$TARGET_DIRTY_INSTALL"
    replace_line $BUILDDIR/$ARCH/$RELEASEDIR/util_functions.sh ADDON="" ADDON="$NONCONFIG"
    replace_line $BUILDDIR/$ARCH/$RELEASEDIR/util_functions.sh TARGET_MAPS_GOOGLE="" TARGET_MAPS_GOOGLE="$TARGET_MAPS_GOOGLE"
    replace_line $BUILDDIR/$ARCH/$RELEASEDIR/util_functions.sh TARGET_CONFIG_VERSION="" TARGET_CONFIG_VERSION="$TARGET_CONFIG_VERSION"
    # Create LICENSE
    makelicense
    # Create ZIP
    cd $BUILDDIR/$ARCH/$RELEASEDIR
    zip -qr9 ${RELEASEDIR}.zip *
    cd ../../..
    mv $BUILDDIR/$ARCH/$RELEASEDIR/${RELEASEDIR}.zip $OUTDIR/$ARCH/${RELEASEDIR}.zip
    # Sign ZIP
    java -jar $ZIPSIGNER $OUTDIR/$ARCH/${RELEASEDIR}.zip $OUTDIR/$ARCH/${RELEASEDIR}_signed.zip 2>/dev/null
    # Set build VARIANT in global environment
    echo "TARGET_VARIANT_MAPS" >> $OUTDIR/ENV/env_variant.sh
    # List signed ZIP
    ls $OUTDIR/$ARCH/${RELEASEDIR}_signed.zip
    # Wipe unsigned ZIP
    rm -rf $OUTDIR/$ARCH/${RELEASEDIR}.zip
  fi
  # Markup
  if [ "$VARIANT" == "markup" ]; then
    # Set Addon package sources
    SOURCES_ALL="sources/addon-sources/all"
    SOURCES_ARMEABI="sources/addon-sources/arm"
    SOURCES_AARCH64="sources/addon-sources/arm64"
    echo "Generating BiTGApps Markup Addon package"
    # Create release directory
    mkdir "$BUILDDIR/$ARCH/BiTGApps-addon-markup-${COMMONADDONRELEASE}"
    RELEASEDIR="BiTGApps-addon-markup-${COMMONADDONRELEASE}"
    # Create package components
    mkdir -p $BUILDDIR/$ARCH/$RELEASEDIR/$METADIR
    mkdir -p $BUILDDIR/$ARCH/$RELEASEDIR/$ZIP
    mkdir -p $BUILDDIR/$ARCH/$RELEASEDIR/$SYS
    # Install app packages
    cp -f $SOURCES_ARMEABI/app/MarkupGooglePrebuilt_arm.tar.xz $BUILDDIR/$ARCH/$RELEASEDIR/$SYS
    cp -f $SOURCES_AARCH64/app/MarkupGooglePrebuilt_arm64.tar.xz $BUILDDIR/$ARCH/$RELEASEDIR/$SYS
    # Installer components
    cp -f $UPDATEBINARY $BUILDDIR/$ARCH/$RELEASEDIR/$METADIR/update-binary
    cp -f $UPDATERSCRIPT $BUILDDIR/$ARCH/$RELEASEDIR/$METADIR/updater-script
    cp -f $INSTALLER $BUILDDIR/$ARCH/$RELEASEDIR
    cp -f $BUSYBOX $BUILDDIR/$ARCH/$RELEASEDIR
    # Create utility script
    makeutilityscript
    replace_line $BUILDDIR/$ARCH/$RELEASEDIR/util_functions.sh REL="" REL="$ADDON_RELEASE"
    replace_line $BUILDDIR/$ARCH/$RELEASEDIR/util_functions.sh ZIPTYPE="" ZIPTYPE="$ZIPTYPE"
    replace_line $BUILDDIR/$ARCH/$RELEASEDIR/util_functions.sh TARGET_GAPPS_RELEASE="" TARGET_GAPPS_RELEASE="$TARGET_GAPPS_RELEASE"
    replace_line $BUILDDIR/$ARCH/$RELEASEDIR/util_functions.sh TARGET_DIRTY_INSTALL="" TARGET_DIRTY_INSTALL="$TARGET_DIRTY_INSTALL"
    replace_line $BUILDDIR/$ARCH/$RELEASEDIR/util_functions.sh ADDON="" ADDON="$NONCONFIG"
    replace_line $BUILDDIR/$ARCH/$RELEASEDIR/util_functions.sh TARGET_MARKUP_GOOGLE="" TARGET_MARKUP_GOOGLE="$TARGET_MARKUP_GOOGLE"
    replace_line $BUILDDIR/$ARCH/$RELEASEDIR/util_functions.sh TARGET_CONFIG_VERSION="" TARGET_CONFIG_VERSION="$TARGET_CONFIG_VERSION"
    # Create LICENSE
    makelicense
    # Create ZIP
    cd $BUILDDIR/$ARCH/$RELEASEDIR
    zip -qr9 ${RELEASEDIR}.zip *
    cd ../../..
    mv $BUILDDIR/$ARCH/$RELEASEDIR/${RELEASEDIR}.zip $OUTDIR/$ARCH/${RELEASEDIR}.zip
    # Sign ZIP
    java -jar $ZIPSIGNER $OUTDIR/$ARCH/${RELEASEDIR}.zip $OUTDIR/$ARCH/${RELEASEDIR}_signed.zip 2>/dev/null
    # Set build VARIANT in global environment
    echo "TARGET_VARIANT_MARKUP" >> $OUTDIR/ENV/env_variant.sh
    # List signed ZIP
    ls $OUTDIR/$ARCH/${RELEASEDIR}_signed.zip
    # Wipe unsigned ZIP
    rm -rf $OUTDIR/$ARCH/${RELEASEDIR}.zip
  fi
  # Messages
  if [ "$VARIANT" == "messages" ]; then
    # Set Addon package sources
    SOURCES_ALL="sources/addon-sources/all"
    SOURCES_ARMEABI="sources/addon-sources/arm"
    SOURCES_AARCH64="sources/addon-sources/arm64"
    echo "Generating BiTGApps Messages Addon package"
    # Create release directory
    mkdir "$BUILDDIR/$ARCH/BiTGApps-addon-messages-${COMMONADDONRELEASE}"
    RELEASEDIR="BiTGApps-addon-messages-${COMMONADDONRELEASE}"
    # Create package components
    mkdir -p $BUILDDIR/$ARCH/$RELEASEDIR/$METADIR
    mkdir -p $BUILDDIR/$ARCH/$RELEASEDIR/$ZIP
    mkdir -p $BUILDDIR/$ARCH/$RELEASEDIR/$CORE
    mkdir -p $BUILDDIR/$ARCH/$RELEASEDIR/$SYS
    # Install app package
    cp -f $SOURCES_ALL/app/MessagesGooglePrebuilt.tar.xz $BUILDDIR/$ARCH/$RELEASEDIR/$SYS
    # Install priv-app package
    cp -f $SOURCES_ALL/priv-app/CarrierServices.tar.xz $BUILDDIR/$ARCH/$RELEASEDIR/$CORE
    # Installer components
    cp -f $UPDATEBINARY $BUILDDIR/$ARCH/$RELEASEDIR/$METADIR/update-binary
    cp -f $UPDATERSCRIPT $BUILDDIR/$ARCH/$RELEASEDIR/$METADIR/updater-script
    cp -f $INSTALLER $BUILDDIR/$ARCH/$RELEASEDIR
    cp -f $BUSYBOX $BUILDDIR/$ARCH/$RELEASEDIR
    # Create utility script
    makeutilityscript
    replace_line $BUILDDIR/$ARCH/$RELEASEDIR/util_functions.sh REL="" REL="$ADDON_RELEASE"
    replace_line $BUILDDIR/$ARCH/$RELEASEDIR/util_functions.sh ZIPTYPE="" ZIPTYPE="$ZIPTYPE"
    replace_line $BUILDDIR/$ARCH/$RELEASEDIR/util_functions.sh TARGET_GAPPS_RELEASE="" TARGET_GAPPS_RELEASE="$TARGET_GAPPS_RELEASE"
    replace_line $BUILDDIR/$ARCH/$RELEASEDIR/util_functions.sh TARGET_DIRTY_INSTALL="" TARGET_DIRTY_INSTALL="$TARGET_DIRTY_INSTALL"
    replace_line $BUILDDIR/$ARCH/$RELEASEDIR/util_functions.sh ADDON="" ADDON="$NONCONFIG"
    replace_line $BUILDDIR/$ARCH/$RELEASEDIR/util_functions.sh TARGET_MESSAGES_GOOGLE="" TARGET_MESSAGES_GOOGLE="$TARGET_MESSAGES_GOOGLE"
    replace_line $BUILDDIR/$ARCH/$RELEASEDIR/util_functions.sh TARGET_CONFIG_VERSION="" TARGET_CONFIG_VERSION="$TARGET_CONFIG_VERSION"
    # Create LICENSE
    makelicense
    # Create ZIP
    cd $BUILDDIR/$ARCH/$RELEASEDIR
    zip -qr9 ${RELEASEDIR}.zip *
    cd ../../..
    mv $BUILDDIR/$ARCH/$RELEASEDIR/${RELEASEDIR}.zip $OUTDIR/$ARCH/${RELEASEDIR}.zip
    # Sign ZIP
    java -jar $ZIPSIGNER $OUTDIR/$ARCH/${RELEASEDIR}.zip $OUTDIR/$ARCH/${RELEASEDIR}_signed.zip 2>/dev/null
    # Set build VARIANT in global environment
    echo "TARGET_VARIANT_MESSAGES" >> $OUTDIR/ENV/env_variant.sh
    # List signed ZIP
    ls $OUTDIR/$ARCH/${RELEASEDIR}_signed.zip
    # Wipe unsigned ZIP
    rm -rf $OUTDIR/$ARCH/${RELEASEDIR}.zip
  fi
  # Photos
  if [ "$VARIANT" == "photos" ]; then
    # Set Addon package sources
    SOURCES_ALL="sources/addon-sources/all"
    SOURCES_ARMEABI="sources/addon-sources/arm"
    SOURCES_AARCH64="sources/addon-sources/arm64"
    echo "Generating BiTGApps Photos Addon package"
    # Create release directory
    mkdir "$BUILDDIR/$ARCH/BiTGApps-addon-photos-${COMMONADDONRELEASE}"
    RELEASEDIR="BiTGApps-addon-photos-${COMMONADDONRELEASE}"
    # Create package components
    mkdir -p $BUILDDIR/$ARCH/$RELEASEDIR/$METADIR
    mkdir -p $BUILDDIR/$ARCH/$RELEASEDIR/$ZIP
    mkdir -p $BUILDDIR/$ARCH/$RELEASEDIR/$SYS
    # Install app packages
    cp -f $SOURCES_ARMEABI/app/PhotosGooglePrebuilt_arm.tar.xz $BUILDDIR/$ARCH/$RELEASEDIR/$SYS
    cp -f $SOURCES_AARCH64/app/PhotosGooglePrebuilt_arm64.tar.xz $BUILDDIR/$ARCH/$RELEASEDIR/$SYS
    # Installer components
    cp -f $UPDATEBINARY $BUILDDIR/$ARCH/$RELEASEDIR/$METADIR/update-binary
    cp -f $UPDATERSCRIPT $BUILDDIR/$ARCH/$RELEASEDIR/$METADIR/updater-script
    cp -f $INSTALLER $BUILDDIR/$ARCH/$RELEASEDIR
    cp -f $BUSYBOX $BUILDDIR/$ARCH/$RELEASEDIR
    # Create utility script
    makeutilityscript
    replace_line $BUILDDIR/$ARCH/$RELEASEDIR/util_functions.sh REL="" REL="$ADDON_RELEASE"
    replace_line $BUILDDIR/$ARCH/$RELEASEDIR/util_functions.sh ZIPTYPE="" ZIPTYPE="$ZIPTYPE"
    replace_line $BUILDDIR/$ARCH/$RELEASEDIR/util_functions.sh TARGET_GAPPS_RELEASE="" TARGET_GAPPS_RELEASE="$TARGET_GAPPS_RELEASE"
    replace_line $BUILDDIR/$ARCH/$RELEASEDIR/util_functions.sh TARGET_DIRTY_INSTALL="" TARGET_DIRTY_INSTALL="$TARGET_DIRTY_INSTALL"
    replace_line $BUILDDIR/$ARCH/$RELEASEDIR/util_functions.sh ADDON="" ADDON="$NONCONFIG"
    replace_line $BUILDDIR/$ARCH/$RELEASEDIR/util_functions.sh TARGET_PHOTOS_GOOGLE="" TARGET_PHOTOS_GOOGLE="$TARGET_PHOTOS_GOOGLE"
    replace_line $BUILDDIR/$ARCH/$RELEASEDIR/util_functions.sh TARGET_CONFIG_VERSION="" TARGET_CONFIG_VERSION="$TARGET_CONFIG_VERSION"
    # Create LICENSE
    makelicense
    # Create ZIP
    cd $BUILDDIR/$ARCH/$RELEASEDIR
    zip -qr9 ${RELEASEDIR}.zip *
    cd ../../..
    mv $BUILDDIR/$ARCH/$RELEASEDIR/${RELEASEDIR}.zip $OUTDIR/$ARCH/${RELEASEDIR}.zip
    # Sign ZIP
    java -jar $ZIPSIGNER $OUTDIR/$ARCH/${RELEASEDIR}.zip $OUTDIR/$ARCH/${RELEASEDIR}_signed.zip 2>/dev/null
    # Set build VARIANT in global environment
    echo "TARGET_VARIANT_PHOTOS" >> $OUTDIR/ENV/env_variant.sh
    # List signed ZIP
    ls $OUTDIR/$ARCH/${RELEASEDIR}_signed.zip
    # Wipe unsigned ZIP
    rm -rf $OUTDIR/$ARCH/${RELEASEDIR}.zip
  fi
  # SoundPicker
  if [ "$VARIANT" == "soundpicker" ]; then
    # Set Addon package sources
    SOURCES_ALL="sources/addon-sources/all"
    SOURCES_ARMEABI="sources/addon-sources/arm"
    SOURCES_AARCH64="sources/addon-sources/arm64"
    echo "Generating BiTGApps SoundPicker Addon package"
    # Create release directory
    mkdir "$BUILDDIR/$ARCH/BiTGApps-addon-soundpicker-${COMMONADDONRELEASE}"
    RELEASEDIR="BiTGApps-addon-soundpicker-${COMMONADDONRELEASE}"
    # Create package components
    mkdir -p $BUILDDIR/$ARCH/$RELEASEDIR/$METADIR
    mkdir -p $BUILDDIR/$ARCH/$RELEASEDIR/$ZIP
    mkdir -p $BUILDDIR/$ARCH/$RELEASEDIR/$SYS
    # Install app package
    cp -f $SOURCES_ALL/app/SoundPickerPrebuilt.tar.xz $BUILDDIR/$ARCH/$RELEASEDIR/$SYS
    # Installer components
    cp -f $UPDATEBINARY $BUILDDIR/$ARCH/$RELEASEDIR/$METADIR/update-binary
    cp -f $UPDATERSCRIPT $BUILDDIR/$ARCH/$RELEASEDIR/$METADIR/updater-script
    cp -f $INSTALLER $BUILDDIR/$ARCH/$RELEASEDIR
    cp -f $BUSYBOX $BUILDDIR/$ARCH/$RELEASEDIR
    # Create utility script
    makeutilityscript
    replace_line $BUILDDIR/$ARCH/$RELEASEDIR/util_functions.sh REL="" REL="$ADDON_RELEASE"
    replace_line $BUILDDIR/$ARCH/$RELEASEDIR/util_functions.sh ZIPTYPE="" ZIPTYPE="$ZIPTYPE"
    replace_line $BUILDDIR/$ARCH/$RELEASEDIR/util_functions.sh TARGET_GAPPS_RELEASE="" TARGET_GAPPS_RELEASE="$TARGET_GAPPS_RELEASE"
    replace_line $BUILDDIR/$ARCH/$RELEASEDIR/util_functions.sh TARGET_DIRTY_INSTALL="" TARGET_DIRTY_INSTALL="$TARGET_DIRTY_INSTALL"
    replace_line $BUILDDIR/$ARCH/$RELEASEDIR/util_functions.sh ADDON="" ADDON="$NONCONFIG"
    replace_line $BUILDDIR/$ARCH/$RELEASEDIR/util_functions.sh TARGET_SOUNDPICKER_GOOGLE="" TARGET_SOUNDPICKER_GOOGLE="$TARGET_SOUNDPICKER_GOOGLE"
    replace_line $BUILDDIR/$ARCH/$RELEASEDIR/util_functions.sh TARGET_CONFIG_VERSION="" TARGET_CONFIG_VERSION="$TARGET_CONFIG_VERSION"
    # Create LICENSE
    makelicense
    # Create ZIP
    cd $BUILDDIR/$ARCH/$RELEASEDIR
    zip -qr9 ${RELEASEDIR}.zip *
    cd ../../..
    mv $BUILDDIR/$ARCH/$RELEASEDIR/${RELEASEDIR}.zip $OUTDIR/$ARCH/${RELEASEDIR}.zip
    # Sign ZIP
    java -jar $ZIPSIGNER $OUTDIR/$ARCH/${RELEASEDIR}.zip $OUTDIR/$ARCH/${RELEASEDIR}_signed.zip 2>/dev/null
    # Set build VARIANT in global environment
    echo "TARGET_VARIANT_SOUNDPICKER" >> $OUTDIR/ENV/env_variant.sh
    # List signed ZIP
    ls $OUTDIR/$ARCH/${RELEASEDIR}_signed.zip
    # Wipe unsigned ZIP
    rm -rf $OUTDIR/$ARCH/${RELEASEDIR}.zip
  fi
  # TTS
  if [ "$VARIANT" == "tts" ]; then
    # Set Addon package sources
    SOURCES_ALL="sources/addon-sources/all"
    SOURCES_ARMEABI="sources/addon-sources/arm"
    SOURCES_AARCH64="sources/addon-sources/arm64"
    echo "Generating BiTGApps TTS Addon package"
    # Create release directory
    mkdir "$BUILDDIR/$ARCH/BiTGApps-addon-tts-${COMMONADDONRELEASE}"
    RELEASEDIR="BiTGApps-addon-tts-${COMMONADDONRELEASE}"
    # Create package components
    mkdir -p $BUILDDIR/$ARCH/$RELEASEDIR/$METADIR
    mkdir -p $BUILDDIR/$ARCH/$RELEASEDIR/$ZIP
    mkdir -p $BUILDDIR/$ARCH/$RELEASEDIR/$SYS
    # Install app packages
    cp -f $SOURCES_ARMEABI/app/GoogleTTSPrebuilt_arm.tar.xz $BUILDDIR/$ARCH/$RELEASEDIR/$SYS
    cp -f $SOURCES_AARCH64/app/GoogleTTSPrebuilt_arm64.tar.xz $BUILDDIR/$ARCH/$RELEASEDIR/$SYS
    # Installer components
    cp -f $UPDATEBINARY $BUILDDIR/$ARCH/$RELEASEDIR/$METADIR/update-binary
    cp -f $UPDATERSCRIPT $BUILDDIR/$ARCH/$RELEASEDIR/$METADIR/updater-script
    cp -f $INSTALLER $BUILDDIR/$ARCH/$RELEASEDIR
    cp -f $BUSYBOX $BUILDDIR/$ARCH/$RELEASEDIR
    # Create utility script
    makeutilityscript
    replace_line $BUILDDIR/$ARCH/$RELEASEDIR/util_functions.sh REL="" REL="$ADDON_RELEASE"
    replace_line $BUILDDIR/$ARCH/$RELEASEDIR/util_functions.sh ZIPTYPE="" ZIPTYPE="$ZIPTYPE"
    replace_line $BUILDDIR/$ARCH/$RELEASEDIR/util_functions.sh TARGET_GAPPS_RELEASE="" TARGET_GAPPS_RELEASE="$TARGET_GAPPS_RELEASE"
    replace_line $BUILDDIR/$ARCH/$RELEASEDIR/util_functions.sh TARGET_DIRTY_INSTALL="" TARGET_DIRTY_INSTALL="$TARGET_DIRTY_INSTALL"
    replace_line $BUILDDIR/$ARCH/$RELEASEDIR/util_functions.sh ADDON="" ADDON="$NONCONFIG"
    replace_line $BUILDDIR/$ARCH/$RELEASEDIR/util_functions.sh TARGET_TTS_GOOGLE="" TARGET_TTS_GOOGLE="$TARGET_TTS_GOOGLE"
    replace_line $BUILDDIR/$ARCH/$RELEASEDIR/util_functions.sh TARGET_CONFIG_VERSION="" TARGET_CONFIG_VERSION="$TARGET_CONFIG_VERSION"
    # Create LICENSE
    makelicense
    # Create ZIP
    cd $BUILDDIR/$ARCH/$RELEASEDIR
    zip -qr9 ${RELEASEDIR}.zip *
    cd ../../..
    mv $BUILDDIR/$ARCH/$RELEASEDIR/${RELEASEDIR}.zip $OUTDIR/$ARCH/${RELEASEDIR}.zip
    # Sign ZIP
    java -jar $ZIPSIGNER $OUTDIR/$ARCH/${RELEASEDIR}.zip $OUTDIR/$ARCH/${RELEASEDIR}_signed.zip 2>/dev/null
    # Set build VARIANT in global environment
    echo "TARGET_VARIANT_TTS" >> $OUTDIR/ENV/env_variant.sh
    # List signed ZIP
    ls $OUTDIR/$ARCH/${RELEASEDIR}_signed.zip
    # Wipe unsigned ZIP
    rm -rf $OUTDIR/$ARCH/${RELEASEDIR}.zip
  fi
  # YouTube Vanced MicroG Version
  if [ "$VARIANT" == "vancedmicrog" ]; then
    # Set Addon package sources
    SOURCES_ALL="sources/addon-sources/all"
    SOURCES_ARMEABI="sources/addon-sources/arm"
    SOURCES_AARCH64="sources/addon-sources/arm64"
    echo "Generating BiTGApps YouTube Vanced MicroG Addon package"
    # Create release directory
    mkdir "$BUILDDIR/$ARCH/BiTGApps-addon-vanced-microg-${COMMONADDONRELEASE}"
    RELEASEDIR="BiTGApps-addon-vanced-microg-${COMMONADDONRELEASE}"
    # Create package components
    mkdir -p $BUILDDIR/$ARCH/$RELEASEDIR/$METADIR
    mkdir -p $BUILDDIR/$ARCH/$RELEASEDIR/$ZIP
    mkdir -p $BUILDDIR/$ARCH/$RELEASEDIR/$SYS
    # Install app packages
    cp -f $SOURCES_ALL/app/MicroGGMSCore.tar.xz $BUILDDIR/$ARCH/$RELEASEDIR/$SYS
    cp -f $SOURCES_ARMEABI/app/YouTube_arm.tar.xz $BUILDDIR/$ARCH/$RELEASEDIR/$SYS
    cp -f $SOURCES_AARCH64/app/YouTube_arm64.tar.xz $BUILDDIR/$ARCH/$RELEASEDIR/$SYS
    # Installer components
    cp -f $UPDATEBINARY $BUILDDIR/$ARCH/$RELEASEDIR/$METADIR/update-binary
    cp -f $UPDATERSCRIPT $BUILDDIR/$ARCH/$RELEASEDIR/$METADIR/updater-script
    cp -f $INSTALLER $BUILDDIR/$ARCH/$RELEASEDIR
    cp -f $BUSYBOX $BUILDDIR/$ARCH/$RELEASEDIR
    cp -f $AIK $BUILDDIR/$ARCH/$RELEASEDIR/$ZIP
    # Create utility script
    makeutilityscript
    replace_line $BUILDDIR/$ARCH/$RELEASEDIR/util_functions.sh REL="" REL="$ADDON_RELEASE"
    replace_line $BUILDDIR/$ARCH/$RELEASEDIR/util_functions.sh ZIPTYPE="" ZIPTYPE="$ZIPTYPE"
    replace_line $BUILDDIR/$ARCH/$RELEASEDIR/util_functions.sh TARGET_GAPPS_RELEASE="" TARGET_GAPPS_RELEASE="$TARGET_GAPPS_RELEASE"
    replace_line $BUILDDIR/$ARCH/$RELEASEDIR/util_functions.sh TARGET_DIRTY_INSTALL="" TARGET_DIRTY_INSTALL="$TARGET_DIRTY_INSTALL"
    replace_line $BUILDDIR/$ARCH/$RELEASEDIR/util_functions.sh ADDON="" ADDON="$NONCONFIG"
    replace_line $BUILDDIR/$ARCH/$RELEASEDIR/util_functions.sh TARGET_VANCED_MICROG="" TARGET_VANCED_MICROG="$TARGET_VANCED_MICROG"
    replace_line $BUILDDIR/$ARCH/$RELEASEDIR/util_functions.sh TARGET_CONFIG_VERSION="" TARGET_CONFIG_VERSION="$TARGET_CONFIG_VERSION"
    # Create LICENSE
    makelicense
    # Create ZIP
    cd $BUILDDIR/$ARCH/$RELEASEDIR
    zip -qr9 ${RELEASEDIR}.zip *
    cd ../../..
    mv $BUILDDIR/$ARCH/$RELEASEDIR/${RELEASEDIR}.zip $OUTDIR/$ARCH/${RELEASEDIR}.zip
    # Sign ZIP
    java -jar $ZIPSIGNER $OUTDIR/$ARCH/${RELEASEDIR}.zip $OUTDIR/$ARCH/${RELEASEDIR}_signed.zip 2>/dev/null
    # Set build VARIANT in global environment
    echo "TARGET_VARIANT_VANCED_MICROG" >> $OUTDIR/ENV/env_variant.sh
    # List signed ZIP
    ls $OUTDIR/$ARCH/${RELEASEDIR}_signed.zip
    # Wipe unsigned ZIP
    rm -rf $OUTDIR/$ARCH/${RELEASEDIR}.zip
  fi
  # YouTube Vanced Root Version
  if [ "$VARIANT" == "vancedroot" ]; then
    # Set Addon package sources
    SOURCES_ALL="sources/addon-sources/all"
    SOURCES_ARMEABI="sources/addon-sources/arm"
    SOURCES_AARCH64="sources/addon-sources/arm64"
    echo "Generating BiTGApps YouTube Vanced Root Addon package"
    # Create release directory
    mkdir "$BUILDDIR/$ARCH/BiTGApps-addon-vanced-root-${COMMONADDONRELEASE}"
    RELEASEDIR="BiTGApps-addon-vanced-root-${COMMONADDONRELEASE}"
    # Create package components
    mkdir -p $BUILDDIR/$ARCH/$RELEASEDIR/$METADIR
    mkdir -p $BUILDDIR/$ARCH/$RELEASEDIR/$ZIP
    mkdir -p $BUILDDIR/$ARCH/$RELEASEDIR/$SYS
    # Install app packages
    cp -f $SOURCES_ALL/app/YouTubeStock.tar.xz $BUILDDIR/$ARCH/$RELEASEDIR/$SYS
    cp -f $SOURCES_ALL/app/YouTubeVanced.tar.xz $BUILDDIR/$ARCH/$RELEASEDIR/$SYS
    # Installer components
    cp -f $UPDATEBINARY $BUILDDIR/$ARCH/$RELEASEDIR/$METADIR/update-binary
    cp -f $UPDATERSCRIPT $BUILDDIR/$ARCH/$RELEASEDIR/$METADIR/updater-script
    cp -f $INSTALLER $BUILDDIR/$ARCH/$RELEASEDIR
    cp -f $BUSYBOX $BUILDDIR/$ARCH/$RELEASEDIR
    cp -f $AIK $BUILDDIR/$ARCH/$RELEASEDIR/$ZIP
    # Create utility script
    makeutilityscript
    replace_line $BUILDDIR/$ARCH/$RELEASEDIR/util_functions.sh REL="" REL="$ADDON_RELEASE"
    replace_line $BUILDDIR/$ARCH/$RELEASEDIR/util_functions.sh ZIPTYPE="" ZIPTYPE="$ZIPTYPE"
    replace_line $BUILDDIR/$ARCH/$RELEASEDIR/util_functions.sh TARGET_GAPPS_RELEASE="" TARGET_GAPPS_RELEASE="$TARGET_GAPPS_RELEASE"
    replace_line $BUILDDIR/$ARCH/$RELEASEDIR/util_functions.sh TARGET_DIRTY_INSTALL="" TARGET_DIRTY_INSTALL="$TARGET_DIRTY_INSTALL"
    replace_line $BUILDDIR/$ARCH/$RELEASEDIR/util_functions.sh ADDON="" ADDON="$NONCONFIG"
    replace_line $BUILDDIR/$ARCH/$RELEASEDIR/util_functions.sh TARGET_VANCED_ROOT="" TARGET_VANCED_ROOT="$TARGET_VANCED_ROOT"
    replace_line $BUILDDIR/$ARCH/$RELEASEDIR/util_functions.sh TARGET_CONFIG_VERSION="" TARGET_CONFIG_VERSION="$TARGET_CONFIG_VERSION"
    # Add YouTube Vanced boot scripts
    makevanced
    # Create LICENSE
    makelicense
    # Create ZIP
    cd $BUILDDIR/$ARCH/$RELEASEDIR
    zip -qr9 ${RELEASEDIR}.zip *
    cd ../../..
    mv $BUILDDIR/$ARCH/$RELEASEDIR/${RELEASEDIR}.zip $OUTDIR/$ARCH/${RELEASEDIR}.zip
    # Sign ZIP
    java -jar $ZIPSIGNER $OUTDIR/$ARCH/${RELEASEDIR}.zip $OUTDIR/$ARCH/${RELEASEDIR}_signed.zip 2>/dev/null
    # Set build VARIANT in global environment
    echo "TARGET_VARIANT_VANCED_ROOT" >> $OUTDIR/ENV/env_variant.sh
    # List signed ZIP
    ls $OUTDIR/$ARCH/${RELEASEDIR}_signed.zip
    # Wipe unsigned ZIP
    rm -rf $OUTDIR/$ARCH/${RELEASEDIR}.zip
  fi
  # YouTube Vanced Non-Root Version
  if [ "$VARIANT" == "vancednonroot" ]; then
    # Set Addon package sources
    SOURCES_ALL="sources/addon-sources/all"
    SOURCES_ARMEABI="sources/addon-sources/arm"
    SOURCES_AARCH64="sources/addon-sources/arm64"
    echo "Generating BiTGApps YouTube Vanced Non-Root Addon package"
    # Create release directory
    mkdir "$BUILDDIR/$ARCH/BiTGApps-addon-vanced-nonroot-${COMMONADDONRELEASE}"
    RELEASEDIR="BiTGApps-addon-vanced-nonroot-${COMMONADDONRELEASE}"
    # Create package components
    mkdir -p $BUILDDIR/$ARCH/$RELEASEDIR/$METADIR
    mkdir -p $BUILDDIR/$ARCH/$RELEASEDIR/$ZIP
    mkdir -p $BUILDDIR/$ARCH/$RELEASEDIR/$SYS
    # Install app packages
    cp -f $SOURCES_ALL/app/YouTubeStock.tar.xz $BUILDDIR/$ARCH/$RELEASEDIR/$SYS
    cp -f $SOURCES_ALL/app/YouTubeVanced.tar.xz $BUILDDIR/$ARCH/$RELEASEDIR/$SYS
    # Installer components
    cp -f $UPDATEBINARY $BUILDDIR/$ARCH/$RELEASEDIR/$METADIR/update-binary
    cp -f $UPDATERSCRIPT $BUILDDIR/$ARCH/$RELEASEDIR/$METADIR/updater-script
    cp -f $INSTALLER $BUILDDIR/$ARCH/$RELEASEDIR
    cp -f $BUSYBOX $BUILDDIR/$ARCH/$RELEASEDIR
    cp -f $AIK $BUILDDIR/$ARCH/$RELEASEDIR/$ZIP
    # Create utility script
    makeutilityscript
    replace_line $BUILDDIR/$ARCH/$RELEASEDIR/util_functions.sh REL="" REL="$ADDON_RELEASE"
    replace_line $BUILDDIR/$ARCH/$RELEASEDIR/util_functions.sh ZIPTYPE="" ZIPTYPE="$ZIPTYPE"
    replace_line $BUILDDIR/$ARCH/$RELEASEDIR/util_functions.sh TARGET_GAPPS_RELEASE="" TARGET_GAPPS_RELEASE="$TARGET_GAPPS_RELEASE"
    replace_line $BUILDDIR/$ARCH/$RELEASEDIR/util_functions.sh TARGET_DIRTY_INSTALL="" TARGET_DIRTY_INSTALL="$TARGET_DIRTY_INSTALL"
    replace_line $BUILDDIR/$ARCH/$RELEASEDIR/util_functions.sh ADDON="" ADDON="$NONCONFIG"
    replace_line $BUILDDIR/$ARCH/$RELEASEDIR/util_functions.sh TARGET_VANCED_NONROOT="" TARGET_VANCED_NONROOT="$TARGET_VANCED_NONROOT"
    replace_line $BUILDDIR/$ARCH/$RELEASEDIR/util_functions.sh TARGET_CONFIG_VERSION="" TARGET_CONFIG_VERSION="$TARGET_CONFIG_VERSION"
    # Add YouTube Vanced boot scripts
    makevanced
    # Create LICENSE
    makelicense
    # Create ZIP
    cd $BUILDDIR/$ARCH/$RELEASEDIR
    zip -qr9 ${RELEASEDIR}.zip *
    cd ../../..
    mv $BUILDDIR/$ARCH/$RELEASEDIR/${RELEASEDIR}.zip $OUTDIR/$ARCH/${RELEASEDIR}.zip
    # Sign ZIP
    java -jar $ZIPSIGNER $OUTDIR/$ARCH/${RELEASEDIR}.zip $OUTDIR/$ARCH/${RELEASEDIR}_signed.zip 2>/dev/null
    # Set build VARIANT in global environment
    echo "TARGET_VARIANT_VANCED_NONROOT" >> $OUTDIR/ENV/env_variant.sh
    # List signed ZIP
    ls $OUTDIR/$ARCH/${RELEASEDIR}_signed.zip
    # Wipe unsigned ZIP
    rm -rf $OUTDIR/$ARCH/${RELEASEDIR}.zip
  fi
  # Wellbeing
  if [ "$VARIANT" == "wellbeing" ]; then
    # Set Addon package sources
    SOURCES_ALL="sources/addon-sources/all"
    SOURCES_ARMEABI="sources/addon-sources/arm"
    SOURCES_AARCH64="sources/addon-sources/arm64"
    echo "Generating BiTGApps Wellbeing Addon package"
    # Create release directory
    mkdir "$BUILDDIR/$ARCH/BiTGApps-addon-wellbeing-${COMMONADDONRELEASE}"
    RELEASEDIR="BiTGApps-addon-wellbeing-${COMMONADDONRELEASE}"
    # Create package components
    mkdir -p $BUILDDIR/$ARCH/$RELEASEDIR/$METADIR
    mkdir -p $BUILDDIR/$ARCH/$RELEASEDIR/$ZIP
    mkdir -p $BUILDDIR/$ARCH/$RELEASEDIR/$CORE
    # Install priv-app package
    cp -f $SOURCES_ALL/priv-app/WellbeingPrebuilt.tar.xz $BUILDDIR/$ARCH/$RELEASEDIR/$CORE
    # Installer components
    cp -f $UPDATEBINARY $BUILDDIR/$ARCH/$RELEASEDIR/$METADIR/update-binary
    cp -f $UPDATERSCRIPT $BUILDDIR/$ARCH/$RELEASEDIR/$METADIR/updater-script
    cp -f $INSTALLER $BUILDDIR/$ARCH/$RELEASEDIR
    cp -f $BUSYBOX $BUILDDIR/$ARCH/$RELEASEDIR
    # Create utility script
    makeutilityscript
    replace_line $BUILDDIR/$ARCH/$RELEASEDIR/util_functions.sh REL="" REL="$ADDON_RELEASE"
    replace_line $BUILDDIR/$ARCH/$RELEASEDIR/util_functions.sh ZIPTYPE="" ZIPTYPE="$ZIPTYPE"
    replace_line $BUILDDIR/$ARCH/$RELEASEDIR/util_functions.sh TARGET_GAPPS_RELEASE="" TARGET_GAPPS_RELEASE="$TARGET_GAPPS_RELEASE"
    replace_line $BUILDDIR/$ARCH/$RELEASEDIR/util_functions.sh TARGET_DIRTY_INSTALL="" TARGET_DIRTY_INSTALL="$TARGET_DIRTY_INSTALL"
    replace_line $BUILDDIR/$ARCH/$RELEASEDIR/util_functions.sh ADDON="" ADDON="$NONCONFIG"
    replace_line $BUILDDIR/$ARCH/$RELEASEDIR/util_functions.sh TARGET_WELLBEING_GOOGLE="" TARGET_WELLBEING_GOOGLE="$TARGET_WELLBEING_GOOGLE"
    replace_line $BUILDDIR/$ARCH/$RELEASEDIR/util_functions.sh TARGET_CONFIG_VERSION="" TARGET_CONFIG_VERSION="$TARGET_CONFIG_VERSION"
    # Create LICENSE
    makelicense
    # Create ZIP
    cd $BUILDDIR/$ARCH/$RELEASEDIR
    zip -qr9 ${RELEASEDIR}.zip *
    cd ../../..
    mv $BUILDDIR/$ARCH/$RELEASEDIR/${RELEASEDIR}.zip $OUTDIR/$ARCH/${RELEASEDIR}.zip
    # Sign ZIP
    java -jar $ZIPSIGNER $OUTDIR/$ARCH/${RELEASEDIR}.zip $OUTDIR/$ARCH/${RELEASEDIR}_signed.zip 2>/dev/null
    # Set build VARIANT in global environment
    echo "TARGET_VARIANT_WELLBEING" >> $OUTDIR/ENV/env_variant.sh
    # List signed ZIP
    ls $OUTDIR/$ARCH/${RELEASEDIR}_signed.zip
    # Wipe unsigned ZIP
    rm -rf $OUTDIR/$ARCH/${RELEASEDIR}.zip
  fi
}

# Build
makeaddonv2
