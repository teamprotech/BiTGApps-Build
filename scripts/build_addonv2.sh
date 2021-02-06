#!/bin/bash
#
##############################################################
# File name       : build_addonv2.sh
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

# Check variants
if { [ "$1" != "assistant" ] &&
     [ "$1" != "calculator" ] &&
     [ "$1" != "calendar" ] &&
     [ "$1" != "contacts" ] &&
     [ "$1" != "deskclock" ] &&
     [ "$1" != "dialer" ] &&
     [ "$1" != "gboard" ] &&
     [ "$1" != "markup" ] &&
     [ "$1" != "messages" ] &&
     [ "$1" != "photos" ] &&
     [ "$1" != "soundpicker" ] &&
     [ "$1" != "vanced" ] &&
     [ "$1" != "wellbeing" ]; }; then
     echo "Usage: $0 [VARIANT]"
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
ADDON=""
TARGET_ASSISTANT_GOOGLE="false"
TARGET_CALCULATOR_GOOGLE="false"
TARGET_CALENDAR_GOOGLE="false"
TARGET_CONTACTS_GOOGLE="false"
TARGET_DESKCLOCK_GOOGLE="false"
TARGET_DIALER_GOOGLE="false"
TARGET_GBOARD_GOOGLE="false"
TARGET_MARKUP_GOOGLE="false"
TARGET_MESSAGES_GOOGLE="false"
TARGET_PHOTOS_GOOGLE="false"
TARGET_SOUNDPICKER_GOOGLE="false"
TARGET_VANCED_GOOGLE="false"
TARGET_WELLBEING_GOOGLE="false"' >"$BUILDDIR/$ARCH/$RELEASEDIR/util_functions.sh"
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
    mkdir $BUILDDIR/$ARCH/BiTGApps-addon-assistant-${COMMONADDONRELEASE}
    RELEASEDIR="BiTGApps-addon-assistant-${COMMONADDONRELEASE}"
    # Create package components
    mkdir -p $BUILDDIR/$ARCH/$RELEASEDIR/$METADIR
    mkdir -p $BUILDDIR/$ARCH/$RELEASEDIR/$ZIP
    mkdir -p $BUILDDIR/$ARCH/$RELEASEDIR/$CORE
    # Install priv-app package
    cp -f $SOURCES_ARMEABI/priv-app/Velvet_arm.tar.xz $BUILDDIR/$ARCH/$RELEASEDIR/$CORE
    cp -f $SOURCES_AARCH64/priv-app/Velvet_arm64.tar.xz $BUILDDIR/$ARCH/$RELEASEDIR/$CORE
    # Installer components
    cp -f $UPDATEBINARY $BUILDDIR/$ARCH/$RELEASEDIR/$METADIR
    cp -f $UPDATESCRIPT $BUILDDIR/$ARCH/$RELEASEDIR/$METADIR
    cp -f $INSTALLER $BUILDDIR/$ARCH/$RELEASEDIR
    cp -f $BUSYBOX $BUILDDIR/$ARCH/$RELEASEDIR
    # Create utility script
    makeutilityscript
    replace_line $BUILDDIR/$ARCH/$RELEASEDIR/util_functions.sh REL="" REL="$ADDON_RELEASE"
    replace_line $BUILDDIR/$ARCH/$RELEASEDIR/util_functions.sh ZIPTYPE="" ZIPTYPE="$ZIPTYPE"
    replace_line $BUILDDIR/$ARCH/$RELEASEDIR/util_functions.sh ADDON="" ADDON="$NONCONFIG"
    replace_line $BUILDDIR/$ARCH/$RELEASEDIR/util_functions.sh TARGET_ASSISTANT_GOOGLE="" TARGET_ASSISTANT_GOOGLE="$TARGET_ASSISTANT_GOOGLE"
    # Create LICENSE
    makelicense
    # Create ZIP
    cd $BUILDDIR/$ARCH/$RELEASEDIR
    zip -qr9 ${RELEASEDIR}.zip *
    cd ../../..
    mv $BUILDDIR/$ARCH/$RELEASEDIR/${RELEASEDIR}.zip $OUTDIR/$ARCH/${RELEASEDIR}.zip
    # Sign ZIP
    java -jar $ZIPSIGNER $OUTDIR/$ARCH/${RELEASEDIR}.zip $OUTDIR/$ARCH/${RELEASEDIR}_signed.zip 2>/dev/null
    if [ -f "$OUTDIR/$ARCH/${RELEASEDIR}_signed.zip" ]; then
      echo "TARGET_VARIANT_ASSISTANT" >> $OUTDIR/ENV/env_variant.sh
    fi
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
    mkdir $BUILDDIR/$ARCH/BiTGApps-addon-calculator-${COMMONADDONRELEASE}
    RELEASEDIR="BiTGApps-addon-calculator-${COMMONADDONRELEASE}"
    # Create package components
    mkdir -p $BUILDDIR/$ARCH/$RELEASEDIR/$METADIR
    mkdir -p $BUILDDIR/$ARCH/$RELEASEDIR/$ZIP
    mkdir -p $BUILDDIR/$ARCH/$RELEASEDIR/$SYS
    # Install app package
    cp -f $SOURCES_ALL/app/CalculatorGooglePrebuilt.tar.xz $BUILDDIR/$ARCH/$RELEASEDIR/$SYS
    # Installer components
    cp -f $UPDATEBINARY $BUILDDIR/$ARCH/$RELEASEDIR/$METADIR
    cp -f $UPDATESCRIPT $BUILDDIR/$ARCH/$RELEASEDIR/$METADIR
    cp -f $INSTALLER $BUILDDIR/$ARCH/$RELEASEDIR
    cp -f $BUSYBOX $BUILDDIR/$ARCH/$RELEASEDIR
    # Create utility script
    makeutilityscript
    replace_line $BUILDDIR/$ARCH/$RELEASEDIR/util_functions.sh REL="" REL="$ADDON_RELEASE"
    replace_line $BUILDDIR/$ARCH/$RELEASEDIR/util_functions.sh ZIPTYPE="" ZIPTYPE="$ZIPTYPE"
    replace_line $BUILDDIR/$ARCH/$RELEASEDIR/util_functions.sh ADDON="" ADDON="$NONCONFIG"
    replace_line $BUILDDIR/$ARCH/$RELEASEDIR/util_functions.sh TARGET_CALCULATOR_GOOGLE="" TARGET_CALCULATOR_GOOGLE="$TARGET_CALCULATOR_GOOGLE"
    # Create LICENSE
    makelicense
    # Create ZIP
    cd $BUILDDIR/$ARCH/$RELEASEDIR
    zip -qr9 ${RELEASEDIR}.zip *
    cd ../../..
    mv $BUILDDIR/$ARCH/$RELEASEDIR/${RELEASEDIR}.zip $OUTDIR/$ARCH/${RELEASEDIR}.zip
    # Sign ZIP
    java -jar $ZIPSIGNER $OUTDIR/$ARCH/${RELEASEDIR}.zip $OUTDIR/$ARCH/${RELEASEDIR}_signed.zip 2>/dev/null
    if [ -f "$OUTDIR/$ARCH/${RELEASEDIR}_signed.zip" ]; then
      echo "TARGET_VARIANT_CALCULATOR" >> $OUTDIR/ENV/env_variant.sh
    fi
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
    mkdir $BUILDDIR/$ARCH/BiTGApps-addon-calendar-${COMMONADDONRELEASE}
    RELEASEDIR="BiTGApps-addon-calendar-${COMMONADDONRELEASE}"
    # Create package components
    mkdir -p $BUILDDIR/$ARCH/$RELEASEDIR/$METADIR
    mkdir -p $BUILDDIR/$ARCH/$RELEASEDIR/$ZIP
    mkdir -p $BUILDDIR/$ARCH/$RELEASEDIR/$SYS
    # Install app package
    cp -f $SOURCES_ALL/app/CalendarGooglePrebuilt.tar.xz $BUILDDIR/$ARCH/$RELEASEDIR/$SYS
    # Installer components
    cp -f $UPDATEBINARY $BUILDDIR/$ARCH/$RELEASEDIR/$METADIR
    cp -f $UPDATESCRIPT $BUILDDIR/$ARCH/$RELEASEDIR/$METADIR
    cp -f $INSTALLER $BUILDDIR/$ARCH/$RELEASEDIR
    cp -f $BUSYBOX $BUILDDIR/$ARCH/$RELEASEDIR
    # Create utility script
    makeutilityscript
    replace_line $BUILDDIR/$ARCH/$RELEASEDIR/util_functions.sh REL="" REL="$ADDON_RELEASE"
    replace_line $BUILDDIR/$ARCH/$RELEASEDIR/util_functions.sh ZIPTYPE="" ZIPTYPE="$ZIPTYPE"
    replace_line $BUILDDIR/$ARCH/$RELEASEDIR/util_functions.sh ADDON="" ADDON="$NONCONFIG"
    replace_line $BUILDDIR/$ARCH/$RELEASEDIR/util_functions.sh TARGET_CALENDAR_GOOGLE="" TARGET_CALENDAR_GOOGLE="$TARGET_CALENDAR_GOOGLE"
    # Create LICENSE
    makelicense
    # Create ZIP
    cd $BUILDDIR/$ARCH/$RELEASEDIR
    zip -qr9 ${RELEASEDIR}.zip *
    cd ../../..
    mv $BUILDDIR/$ARCH/$RELEASEDIR/${RELEASEDIR}.zip $OUTDIR/$ARCH/${RELEASEDIR}.zip
    # Sign ZIP
    java -jar $ZIPSIGNER $OUTDIR/$ARCH/${RELEASEDIR}.zip $OUTDIR/$ARCH/${RELEASEDIR}_signed.zip 2>/dev/null
    if [ -f "$OUTDIR/$ARCH/${RELEASEDIR}_signed.zip" ]; then
      echo "TARGET_VARIANT_CALENDAR" >> $OUTDIR/ENV/env_variant.sh
    fi
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
    mkdir $BUILDDIR/$ARCH/BiTGApps-addon-contacts-${COMMONADDONRELEASE}
    RELEASEDIR="BiTGApps-addon-contacts-${COMMONADDONRELEASE}"
    # Create package components
    mkdir -p $BUILDDIR/$ARCH/$RELEASEDIR/$METADIR
    mkdir -p $BUILDDIR/$ARCH/$RELEASEDIR/$ZIP
    mkdir -p $BUILDDIR/$ARCH/$RELEASEDIR/$CORE
    # Install priv-app package
    cp -f $SOURCES_ALL/priv-app/ContactsGooglePrebuilt.tar.xz $BUILDDIR/$ARCH/$RELEASEDIR/$CORE
    # Installer components
    cp -f $UPDATEBINARY $BUILDDIR/$ARCH/$RELEASEDIR/$METADIR
    cp -f $UPDATESCRIPT $BUILDDIR/$ARCH/$RELEASEDIR/$METADIR
    cp -f $INSTALLER $BUILDDIR/$ARCH/$RELEASEDIR
    cp -f $BUSYBOX $BUILDDIR/$ARCH/$RELEASEDIR
    # Create utility script
    makeutilityscript
    replace_line $BUILDDIR/$ARCH/$RELEASEDIR/util_functions.sh REL="" REL="$ADDON_RELEASE"
    replace_line $BUILDDIR/$ARCH/$RELEASEDIR/util_functions.sh ZIPTYPE="" ZIPTYPE="$ZIPTYPE"
    replace_line $BUILDDIR/$ARCH/$RELEASEDIR/util_functions.sh ADDON="" ADDON="$NONCONFIG"
    replace_line $BUILDDIR/$ARCH/$RELEASEDIR/util_functions.sh TARGET_CONTACTS_GOOGLE="" TARGET_CONTACTS_GOOGLE="$TARGET_CONTACTS_GOOGLE"
    # Create LICENSE
    makelicense
    # Create ZIP
    cd $BUILDDIR/$ARCH/$RELEASEDIR
    zip -qr9 ${RELEASEDIR}.zip *
    cd ../../..
    mv $BUILDDIR/$ARCH/$RELEASEDIR/${RELEASEDIR}.zip $OUTDIR/$ARCH/${RELEASEDIR}.zip
    # Sign ZIP
    java -jar $ZIPSIGNER $OUTDIR/$ARCH/${RELEASEDIR}.zip $OUTDIR/$ARCH/${RELEASEDIR}_signed.zip 2>/dev/null
    if [ -f "$OUTDIR/$ARCH/${RELEASEDIR}_signed.zip" ]; then
      echo "TARGET_VARIANT_CONTACTS" >> $OUTDIR/ENV/env_variant.sh
    fi
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
    mkdir $BUILDDIR/$ARCH/BiTGApps-addon-deskclock-${COMMONADDONRELEASE}
    RELEASEDIR="BiTGApps-addon-deskclock-${COMMONADDONRELEASE}"
    # Create package components
    mkdir -p $BUILDDIR/$ARCH/$RELEASEDIR/$METADIR
    mkdir -p $BUILDDIR/$ARCH/$RELEASEDIR/$ZIP
    mkdir -p $BUILDDIR/$ARCH/$RELEASEDIR/$SYS
    # Install app package
    cp -f $SOURCES_ALL/app/DeskClockGooglePrebuilt.tar.xz $BUILDDIR/$ARCH/$RELEASEDIR/$SYS
    # Installer components
    cp -f $UPDATEBINARY $BUILDDIR/$ARCH/$RELEASEDIR/$METADIR
    cp -f $UPDATESCRIPT $BUILDDIR/$ARCH/$RELEASEDIR/$METADIR
    cp -f $INSTALLER $BUILDDIR/$ARCH/$RELEASEDIR
    cp -f $BUSYBOX $BUILDDIR/$ARCH/$RELEASEDIR
    # Create utility script
    makeutilityscript
    replace_line $BUILDDIR/$ARCH/$RELEASEDIR/util_functions.sh REL="" REL="$ADDON_RELEASE"
    replace_line $BUILDDIR/$ARCH/$RELEASEDIR/util_functions.sh ZIPTYPE="" ZIPTYPE="$ZIPTYPE"
    replace_line $BUILDDIR/$ARCH/$RELEASEDIR/util_functions.sh ADDON="" ADDON="$NONCONFIG"
    replace_line $BUILDDIR/$ARCH/$RELEASEDIR/util_functions.sh TARGET_DESKCLOCK_GOOGLE="" TARGET_DESKCLOCK_GOOGLE="$TARGET_DESKCLOCK_GOOGLE"
    # Create LICENSE
    makelicense
    # Create ZIP
    cd $BUILDDIR/$ARCH/$RELEASEDIR
    zip -qr9 ${RELEASEDIR}.zip *
    cd ../../..
    mv $BUILDDIR/$ARCH/$RELEASEDIR/${RELEASEDIR}.zip $OUTDIR/$ARCH/${RELEASEDIR}.zip
    # Sign ZIP
    java -jar $ZIPSIGNER $OUTDIR/$ARCH/${RELEASEDIR}.zip $OUTDIR/$ARCH/${RELEASEDIR}_signed.zip 2>/dev/null
    if [ -f "$OUTDIR/$ARCH/${RELEASEDIR}_signed.zip" ]; then
      echo "TARGET_VARIANT_DESKCLOCK" >> $OUTDIR/ENV/env_variant.sh
    fi
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
    mkdir $BUILDDIR/$ARCH/BiTGApps-addon-dialer-${COMMONADDONRELEASE}
    RELEASEDIR="BiTGApps-addon-dialer-${COMMONADDONRELEASE}"
    # Create package components
    mkdir -p $BUILDDIR/$ARCH/$RELEASEDIR/$METADIR
    mkdir -p $BUILDDIR/$ARCH/$RELEASEDIR/$ZIP
    mkdir -p $BUILDDIR/$ARCH/$RELEASEDIR/$CORE
    # Install priv-app package
    cp -f $SOURCES_ARMEABI/priv-app/DialerGooglePrebuilt_arm.tar.xz $BUILDDIR/$ARCH/$RELEASEDIR/$CORE
    cp -f $SOURCES_AARCH64/priv-app/DialerGooglePrebuilt_arm64.tar.xz $BUILDDIR/$ARCH/$RELEASEDIR/$CORE
    # Installer components
    cp -f $UPDATEBINARY $BUILDDIR/$ARCH/$RELEASEDIR/$METADIR
    cp -f $UPDATESCRIPT $BUILDDIR/$ARCH/$RELEASEDIR/$METADIR
    cp -f $INSTALLER $BUILDDIR/$ARCH/$RELEASEDIR
    cp -f $BUSYBOX $BUILDDIR/$ARCH/$RELEASEDIR
    # Create utility script
    makeutilityscript
    replace_line $BUILDDIR/$ARCH/$RELEASEDIR/util_functions.sh REL="" REL="$ADDON_RELEASE"
    replace_line $BUILDDIR/$ARCH/$RELEASEDIR/util_functions.sh ZIPTYPE="" ZIPTYPE="$ZIPTYPE"
    replace_line $BUILDDIR/$ARCH/$RELEASEDIR/util_functions.sh ADDON="" ADDON="$NONCONFIG"
    replace_line $BUILDDIR/$ARCH/$RELEASEDIR/util_functions.sh TARGET_DIALER_GOOGLE="" TARGET_DIALER_GOOGLE="$TARGET_DIALER_GOOGLE"
    # Create LICENSE
    makelicense
    # Create ZIP
    cd $BUILDDIR/$ARCH/$RELEASEDIR
    zip -qr9 ${RELEASEDIR}.zip *
    cd ../../..
    mv $BUILDDIR/$ARCH/$RELEASEDIR/${RELEASEDIR}.zip $OUTDIR/$ARCH/${RELEASEDIR}.zip
    # Sign ZIP
    java -jar $ZIPSIGNER $OUTDIR/$ARCH/${RELEASEDIR}.zip $OUTDIR/$ARCH/${RELEASEDIR}_signed.zip 2>/dev/null
    if [ -f "$OUTDIR/$ARCH/${RELEASEDIR}_signed.zip" ]; then
      echo "TARGET_VARIANT_DIALER" >> $OUTDIR/ENV/env_variant.sh
    fi
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
    mkdir $BUILDDIR/$ARCH/BiTGApps-addon-gboard-${COMMONADDONRELEASE}
    RELEASEDIR="BiTGApps-addon-gboard-${COMMONADDONRELEASE}"
    # Create package components
    mkdir -p $BUILDDIR/$ARCH/$RELEASEDIR/$METADIR
    mkdir -p $BUILDDIR/$ARCH/$RELEASEDIR/$ZIP
    mkdir -p $BUILDDIR/$ARCH/$RELEASEDIR/$CORE
    # Install app package
    cp -f $SOURCES_ARMEABI/app/GboardGooglePrebuilt_arm.tar.xz $BUILDDIR/$ARCH/$RELEASEDIR/$CORE
    cp -f $SOURCES_AARCH64/app/GboardGooglePrebuilt_arm64.tar.xz $BUILDDIR/$ARCH/$RELEASEDIR/$CORE
    # Installer components
    cp -f $UPDATEBINARY $BUILDDIR/$ARCH/$RELEASEDIR/$METADIR
    cp -f $UPDATESCRIPT $BUILDDIR/$ARCH/$RELEASEDIR/$METADIR
    cp -f $INSTALLER $BUILDDIR/$ARCH/$RELEASEDIR
    cp -f $BUSYBOX $BUILDDIR/$ARCH/$RELEASEDIR
    # Create utility script
    makeutilityscript
    replace_line $BUILDDIR/$ARCH/$RELEASEDIR/util_functions.sh REL="" REL="$ADDON_RELEASE"
    replace_line $BUILDDIR/$ARCH/$RELEASEDIR/util_functions.sh ZIPTYPE="" ZIPTYPE="$ZIPTYPE"
    replace_line $BUILDDIR/$ARCH/$RELEASEDIR/util_functions.sh ADDON="" ADDON="$NONCONFIG"
    replace_line $BUILDDIR/$ARCH/$RELEASEDIR/util_functions.sh TARGET_GBOARD_GOOGLE="" TARGET_GBOARD_GOOGLE="$TARGET_GBOARD_GOOGLE"
    # Create LICENSE
    makelicense
    # Create ZIP
    cd $BUILDDIR/$ARCH/$RELEASEDIR
    zip -qr9 ${RELEASEDIR}.zip *
    cd ../../..
    mv $BUILDDIR/$ARCH/$RELEASEDIR/${RELEASEDIR}.zip $OUTDIR/$ARCH/${RELEASEDIR}.zip
    # Sign ZIP
    java -jar $ZIPSIGNER $OUTDIR/$ARCH/${RELEASEDIR}.zip $OUTDIR/$ARCH/${RELEASEDIR}_signed.zip 2>/dev/null
    if [ -f "$OUTDIR/$ARCH/${RELEASEDIR}_signed.zip" ]; then
      echo "TARGET_VARIANT_GBOARD" >> $OUTDIR/ENV/env_variant.sh
    fi
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
    mkdir $BUILDDIR/$ARCH/BiTGApps-addon-markup-${COMMONADDONRELEASE}
    RELEASEDIR="BiTGApps-addon-markup-${COMMONADDONRELEASE}"
    # Create package components
    mkdir -p $BUILDDIR/$ARCH/$RELEASEDIR/$METADIR
    mkdir -p $BUILDDIR/$ARCH/$RELEASEDIR/$ZIP
    mkdir -p $BUILDDIR/$ARCH/$RELEASEDIR/$SYS
    # Install app package
    cp -f $SOURCES_ALL/app/MarkupGooglePrebuilt.tar.xz $BUILDDIR/$ARCH/$RELEASEDIR/$SYS
    # Install lib package
    cp -f $SOURCES_ARMEABI/lib/markup_lib32.tar.xz $BUILDDIR/$ARCH/$RELEASEDIR/$ZIP
    cp -f $SOURCES_AARCH64/lib64/markup_lib64.tar.xz $BUILDDIR/$ARCH/$RELEASEDIR/$ZIP
    # Installer components
    cp -f $UPDATEBINARY $BUILDDIR/$ARCH/$RELEASEDIR/$METADIR
    cp -f $UPDATESCRIPT $BUILDDIR/$ARCH/$RELEASEDIR/$METADIR
    cp -f $INSTALLER $BUILDDIR/$ARCH/$RELEASEDIR
    cp -f $BUSYBOX $BUILDDIR/$ARCH/$RELEASEDIR
    # Create utility script
    makeutilityscript
    replace_line $BUILDDIR/$ARCH/$RELEASEDIR/util_functions.sh REL="" REL="$ADDON_RELEASE"
    replace_line $BUILDDIR/$ARCH/$RELEASEDIR/util_functions.sh ZIPTYPE="" ZIPTYPE="$ZIPTYPE"
    replace_line $BUILDDIR/$ARCH/$RELEASEDIR/util_functions.sh ADDON="" ADDON="$NONCONFIG"
    replace_line $BUILDDIR/$ARCH/$RELEASEDIR/util_functions.sh TARGET_MARKUP_GOOGLE="" TARGET_MARKUP_GOOGLE="$TARGET_MARKUP_GOOGLE"
    # Create LICENSE
    makelicense
    # Create ZIP
    cd $BUILDDIR/$ARCH/$RELEASEDIR
    zip -qr9 ${RELEASEDIR}.zip *
    cd ../../..
    mv $BUILDDIR/$ARCH/$RELEASEDIR/${RELEASEDIR}.zip $OUTDIR/$ARCH/${RELEASEDIR}.zip
    # Sign ZIP
    java -jar $ZIPSIGNER $OUTDIR/$ARCH/${RELEASEDIR}.zip $OUTDIR/$ARCH/${RELEASEDIR}_signed.zip 2>/dev/null
    if [ -f "$OUTDIR/$ARCH/${RELEASEDIR}_signed.zip" ]; then
      echo "TARGET_VARIANT_MARKUP" >> $OUTDIR/ENV/env_variant.sh
    fi
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
    mkdir $BUILDDIR/$ARCH/BiTGApps-addon-messages-${COMMONADDONRELEASE}
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
    cp -f $UPDATEBINARY $BUILDDIR/$ARCH/$RELEASEDIR/$METADIR
    cp -f $UPDATESCRIPT $BUILDDIR/$ARCH/$RELEASEDIR/$METADIR
    cp -f $INSTALLER $BUILDDIR/$ARCH/$RELEASEDIR
    cp -f $BUSYBOX $BUILDDIR/$ARCH/$RELEASEDIR
    # Create utility script
    makeutilityscript
    replace_line $BUILDDIR/$ARCH/$RELEASEDIR/util_functions.sh REL="" REL="$ADDON_RELEASE"
    replace_line $BUILDDIR/$ARCH/$RELEASEDIR/util_functions.sh ZIPTYPE="" ZIPTYPE="$ZIPTYPE"
    replace_line $BUILDDIR/$ARCH/$RELEASEDIR/util_functions.sh ADDON="" ADDON="$NONCONFIG"
    replace_line $BUILDDIR/$ARCH/$RELEASEDIR/util_functions.sh TARGET_MESSAGES_GOOGLE="" TARGET_MESSAGES_GOOGLE="$TARGET_MESSAGES_GOOGLE"
    # Create LICENSE
    makelicense
    # Create ZIP
    cd $BUILDDIR/$ARCH/$RELEASEDIR
    zip -qr9 ${RELEASEDIR}.zip *
    cd ../../..
    mv $BUILDDIR/$ARCH/$RELEASEDIR/${RELEASEDIR}.zip $OUTDIR/$ARCH/${RELEASEDIR}.zip
    # Sign ZIP
    java -jar $ZIPSIGNER $OUTDIR/$ARCH/${RELEASEDIR}.zip $OUTDIR/$ARCH/${RELEASEDIR}_signed.zip 2>/dev/null
    if [ -f "$OUTDIR/$ARCH/${RELEASEDIR}_signed.zip" ]; then
      echo "TARGET_VARIANT_MESSAGES" >> $OUTDIR/ENV/env_variant.sh
    fi
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
    mkdir $BUILDDIR/$ARCH/BiTGApps-addon-photos-${COMMONADDONRELEASE}
    RELEASEDIR="BiTGApps-addon-photos-${COMMONADDONRELEASE}"
    # Create package components
    mkdir -p $BUILDDIR/$ARCH/$RELEASEDIR/$METADIR
    mkdir -p $BUILDDIR/$ARCH/$RELEASEDIR/$ZIP
    mkdir -p $BUILDDIR/$ARCH/$RELEASEDIR/$SYS
    # Install app package
    cp -f $SOURCES_ARMEABI/app/PhotosGooglePrebuilt_arm.tar.xz $BUILDDIR/$ARCH/$RELEASEDIR/$SYS
    cp -f $SOURCES_AARCH64/app/PhotosGooglePrebuilt_arm64.tar.xz $BUILDDIR/$ARCH/$RELEASEDIR/$SYS
    # Installer components
    cp -f $UPDATEBINARY $BUILDDIR/$ARCH/$RELEASEDIR/$METADIR
    cp -f $UPDATESCRIPT $BUILDDIR/$ARCH/$RELEASEDIR/$METADIR
    cp -f $INSTALLER $BUILDDIR/$ARCH/$RELEASEDIR
    cp -f $BUSYBOX $BUILDDIR/$ARCH/$RELEASEDIR
    # Create utility script
    makeutilityscript
    replace_line $BUILDDIR/$ARCH/$RELEASEDIR/util_functions.sh REL="" REL="$ADDON_RELEASE"
    replace_line $BUILDDIR/$ARCH/$RELEASEDIR/util_functions.sh ZIPTYPE="" ZIPTYPE="$ZIPTYPE"
    replace_line $BUILDDIR/$ARCH/$RELEASEDIR/util_functions.sh ADDON="" ADDON="$NONCONFIG"
    replace_line $BUILDDIR/$ARCH/$RELEASEDIR/util_functions.sh TARGET_PHOTOS_GOOGLE="" TARGET_PHOTOS_GOOGLE="$TARGET_PHOTOS_GOOGLE"
    # Create LICENSE
    makelicense
    # Create ZIP
    cd $BUILDDIR/$ARCH/$RELEASEDIR
    zip -qr9 ${RELEASEDIR}.zip *
    cd ../../..
    mv $BUILDDIR/$ARCH/$RELEASEDIR/${RELEASEDIR}.zip $OUTDIR/$ARCH/${RELEASEDIR}.zip
    # Sign ZIP
    java -jar $ZIPSIGNER $OUTDIR/$ARCH/${RELEASEDIR}.zip $OUTDIR/$ARCH/${RELEASEDIR}_signed.zip 2>/dev/null
    if [ -f "$OUTDIR/$ARCH/${RELEASEDIR}_signed.zip" ]; then
      echo "TARGET_VARIANT_PHOTOS" >> $OUTDIR/ENV/env_variant.sh
    fi
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
    mkdir $BUILDDIR/$ARCH/BiTGApps-addon-soundpicker-${COMMONADDONRELEASE}
    RELEASEDIR="BiTGApps-addon-soundpicker-${COMMONADDONRELEASE}"
    # Create package components
    mkdir -p $BUILDDIR/$ARCH/$RELEASEDIR/$METADIR
    mkdir -p $BUILDDIR/$ARCH/$RELEASEDIR/$ZIP
    mkdir -p $BUILDDIR/$ARCH/$RELEASEDIR/$SYS
    # Install app package
    cp -f $SOURCES_ALL/app/SoundPickerPrebuilt.tar.xz $BUILDDIR/$ARCH/$RELEASEDIR/$SYS
    # Installer components
    cp -f $UPDATEBINARY $BUILDDIR/$ARCH/$RELEASEDIR/$METADIR
    cp -f $UPDATESCRIPT $BUILDDIR/$ARCH/$RELEASEDIR/$METADIR
    cp -f $INSTALLER $BUILDDIR/$ARCH/$RELEASEDIR
    cp -f $BUSYBOX $BUILDDIR/$ARCH/$RELEASEDIR
    # Create utility script
    makeutilityscript
    replace_line $BUILDDIR/$ARCH/$RELEASEDIR/util_functions.sh REL="" REL="$ADDON_RELEASE"
    replace_line $BUILDDIR/$ARCH/$RELEASEDIR/util_functions.sh ZIPTYPE="" ZIPTYPE="$ZIPTYPE"
    replace_line $BUILDDIR/$ARCH/$RELEASEDIR/util_functions.sh ADDON="" ADDON="$NONCONFIG"
    replace_line $BUILDDIR/$ARCH/$RELEASEDIR/util_functions.sh TARGET_SOUNDPICKER_GOOGLE="" TARGET_SOUNDPICKER_GOOGLE="$TARGET_SOUNDPICKER_GOOGLE"
    # Create LICENSE
    makelicense
    # Create ZIP
    cd $BUILDDIR/$ARCH/$RELEASEDIR
    zip -qr9 ${RELEASEDIR}.zip *
    cd ../../..
    mv $BUILDDIR/$ARCH/$RELEASEDIR/${RELEASEDIR}.zip $OUTDIR/$ARCH/${RELEASEDIR}.zip
    # Sign ZIP
    java -jar $ZIPSIGNER $OUTDIR/$ARCH/${RELEASEDIR}.zip $OUTDIR/$ARCH/${RELEASEDIR}_signed.zip 2>/dev/null
    if [ -f "$OUTDIR/$ARCH/${RELEASEDIR}_signed.zip" ]; then
      echo "TARGET_VARIANT_SOUNDPICKER" >> $OUTDIR/ENV/env_variant.sh
    fi
    # List signed ZIP
    ls $OUTDIR/$ARCH/${RELEASEDIR}_signed.zip
    # Wipe unsigned ZIP
    rm -rf $OUTDIR/$ARCH/${RELEASEDIR}.zip
  fi
  # YouTube Vanced
  if [ "$VARIANT" == "vanced" ]; then
    # Set Addon package sources
    SOURCES_ALL="sources/addon-sources/all"
    SOURCES_ARMEABI="sources/addon-sources/arm"
    SOURCES_AARCH64="sources/addon-sources/arm64"
    echo "Generating BiTGApps YouTube Vanced Addon package"
    # Create release directory
    mkdir $BUILDDIR/$ARCH/BiTGApps-addon-vanced-${COMMONADDONRELEASE}
    RELEASEDIR="BiTGApps-addon-vanced-${COMMONADDONRELEASE}"
    # Create package components
    mkdir -p $BUILDDIR/$ARCH/$RELEASEDIR/$METADIR
    mkdir -p $BUILDDIR/$ARCH/$RELEASEDIR/$ZIP
    mkdir -p $BUILDDIR/$ARCH/$RELEASEDIR/$SYS
    # Install app package
    cp -f $SOURCES_ALL/app/MicroGGMSCore.tar.xz $BUILDDIR/$ARCH/$RELEASEDIR/$SYS
    cp -f $SOURCES_ALL/app/YouTube.tar.xz $BUILDDIR/$ARCH/$RELEASEDIR/$SYS
    # Installer components
    cp -f $UPDATEBINARY $BUILDDIR/$ARCH/$RELEASEDIR/$METADIR
    cp -f $UPDATESCRIPT $BUILDDIR/$ARCH/$RELEASEDIR/$METADIR
    cp -f $INSTALLER $BUILDDIR/$ARCH/$RELEASEDIR
    cp -f $BUSYBOX $BUILDDIR/$ARCH/$RELEASEDIR
    # Create utility script
    makeutilityscript
    replace_line $BUILDDIR/$ARCH/$RELEASEDIR/util_functions.sh REL="" REL="$ADDON_RELEASE"
    replace_line $BUILDDIR/$ARCH/$RELEASEDIR/util_functions.sh ZIPTYPE="" ZIPTYPE="$ZIPTYPE"
    replace_line $BUILDDIR/$ARCH/$RELEASEDIR/util_functions.sh ADDON="" ADDON="$NONCONFIG"
    replace_line $BUILDDIR/$ARCH/$RELEASEDIR/util_functions.sh TARGET_VANCED_GOOGLE="" TARGET_VANCED_GOOGLE="$TARGET_VANCED_GOOGLE"
    # Create LICENSE
    makelicense
    # Create ZIP
    cd $BUILDDIR/$ARCH/$RELEASEDIR
    zip -qr9 ${RELEASEDIR}.zip *
    cd ../../..
    mv $BUILDDIR/$ARCH/$RELEASEDIR/${RELEASEDIR}.zip $OUTDIR/$ARCH/${RELEASEDIR}.zip
    # Sign ZIP
    java -jar $ZIPSIGNER $OUTDIR/$ARCH/${RELEASEDIR}.zip $OUTDIR/$ARCH/${RELEASEDIR}_signed.zip 2>/dev/null
    if [ -f "$OUTDIR/$ARCH/${RELEASEDIR}_signed.zip" ]; then
      echo "TARGET_VARIANT_VANCED" >> $OUTDIR/ENV/env_variant.sh
    fi
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
    mkdir $BUILDDIR/$ARCH/BiTGApps-addon-wellbeing-${COMMONADDONRELEASE}
    RELEASEDIR="BiTGApps-addon-wellbeing-${COMMONADDONRELEASE}"
    # Create package components
    mkdir -p $BUILDDIR/$ARCH/$RELEASEDIR/$METADIR
    mkdir -p $BUILDDIR/$ARCH/$RELEASEDIR/$ZIP
    mkdir -p $BUILDDIR/$ARCH/$RELEASEDIR/$CORE
    # Install priv-app package
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
    replace_line $BUILDDIR/$ARCH/$RELEASEDIR/util_functions.sh ADDON="" ADDON="$NONCONFIG"
    replace_line $BUILDDIR/$ARCH/$RELEASEDIR/util_functions.sh TARGET_WELLBEING_GOOGLE="" TARGET_WELLBEING_GOOGLE="$TARGET_WELLBEING_GOOGLE"
    # Create LICENSE
    makelicense
    # Create ZIP
    cd $BUILDDIR/$ARCH/$RELEASEDIR
    zip -qr9 ${RELEASEDIR}.zip *
    cd ../../..
    mv $BUILDDIR/$ARCH/$RELEASEDIR/${RELEASEDIR}.zip $OUTDIR/$ARCH/${RELEASEDIR}.zip
    # Sign ZIP
    java -jar $ZIPSIGNER $OUTDIR/$ARCH/${RELEASEDIR}.zip $OUTDIR/$ARCH/${RELEASEDIR}_signed.zip 2>/dev/null
    if [ -f "$OUTDIR/$ARCH/${RELEASEDIR}_signed.zip" ]; then
      echo "TARGET_VARIANT_WELLBEING" >> $OUTDIR/ENV/env_variant.sh
    fi
    # List signed ZIP
    ls $OUTDIR/$ARCH/${RELEASEDIR}_signed.zip
    # Wipe unsigned ZIP
    rm -rf $OUTDIR/$ARCH/${RELEASEDIR}.zip
  fi
}

# Build
makeaddonv2
