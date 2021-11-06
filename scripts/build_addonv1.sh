#!/bin/bash
#
##############################################################
# File name       : build_addonv1.sh
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

# Check availability of Additional sources
if [ ! -d "sources/addon-sources" ]; then
  echo "! Additional sources not found. Aborting..."
  exit 1
fi

# Set defaults
ARCH="$1"
COMMONADDONRELEASE="$COMMONADDONRELEASE"

# Build defaults
BUILDDIR="build"
OUTDIR="out"
TYPE="Addon"

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
ARMEABI=""
AARCH64=""
TARGET_CONFIG_VERSION=""' >"$BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/util_functions.sh"
}

# Compress and add YouTube Vanced boot scripts
makevanced() {
  cp -f $VANCEDINIT $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$ZIP
  cp -f $VANCEDSCRIPT $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$ZIP
  cp -f $VANCEDROOT $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$ZIP
  cd $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$ZIP
  # Only compress in 'xz' format
  tar -cJf "Vanced.tar.xz" init.vanced.rc vanced.sh vanced-root.sh
  rm -rf init.vanced.rc vanced.sh vanced-root.sh
  # Checkout path
  cd ../../../../..
}

# Add stock YouTube library
makeyoutubestock() {
  # Set APP
  SOURCES_APP="sources/addon-sources/all/app"
  # Decompress stock YouTube
  tar -xf $SOURCES_APP/YouTubeStock.tar.xz -C $SOURCES_APP
  # Add stock YouTube library
  tar -xf $SOURCES_APP/YouTubeStockLib.tar.xz -C $SOURCES_APP/YouTube
  # Remove without library stock YouTube
  rm -rf $SOURCES_APP/YouTubeStock.tar.xz
  # Only compress in 'xz' format
  cd $SOURCES_APP; tar -cJf "YouTubeStock.tar.xz" YouTube; cd ../../../..
  # Remove decompress stock YouTube
  rm -rf $SOURCES_APP/YouTube
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
to the GPLv3. The applicable license can be found at https://github.com/BiTGApps/BiTGApps/blob/master/LICENSE" >"$BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/LICENSE"
}

# Main
makeaddonv1() {
  # Create build directory
  test -d $BUILDDIR || mkdir $BUILDDIR
  test -d $BUILDDIR/$TYPE || mkdir $BUILDDIR/$TYPE
  test -d $BUILDDIR/$TYPE/$ARCH || mkdir $BUILDDIR/$TYPE/$ARCH
  # Create out directory
  test -d $OUTDIR || mkdir $OUTDIR
  test -d $OUTDIR/$TYPE || mkdir $OUTDIR/$TYPE
  test -d $OUTDIR/$TYPE/$ARCH || mkdir $OUTDIR/$TYPE/$ARCH
  # Create ENV directory
  test -d $OUTDIR/ENV || mkdir $OUTDIR/ENV
  # Repack with stock YouTube library
  makeyoutubestock
  # Install variable; Do not modify
  ZIPTYPE='"addon"'
  CONFIG='"conf"'
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
    mkdir "$BUILDDIR/$TYPE/$ARCH/BiTGApps-addon-${ARCH}-${COMMONADDONRELEASE}"
    RELEASEDIR="BiTGApps-addon-${ARCH}-${COMMONADDONRELEASE}"
    # Create package components
    mkdir -p $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$METADIR
    mkdir -p $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$ZIP
    mkdir -p $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$CORE
    mkdir -p $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$SYS
    mkdir -p $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$OVERLAY
    # Install app packages
    cp -f $SOURCES_ARMEABI/app/BromitePrebuilt_arm.tar.xz $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$SYS/BromitePrebuilt.tar.xz
    cp -f $SOURCES_ALL/app/CalculatorGooglePrebuilt.tar.xz $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$SYS
    cp -f $SOURCES_ALL/app/CalendarGooglePrebuilt.tar.xz $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$SYS
    cp -f $SOURCES_ALL/app/ChromeGooglePrebuilt.tar.xz $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$SYS
    cp -f $SOURCES_ALL/app/DeskClockGooglePrebuilt.tar.xz $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$SYS
    cp -f $SOURCES_ARMEABI/app/GboardGooglePrebuilt_arm.tar.xz $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$SYS/GboardGooglePrebuilt.tar.xz
    cp -f $SOURCES_ARMEABI/app/GoogleTTSPrebuilt_arm.tar.xz $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$SYS/GoogleTTSPrebuilt.tar.xz
    cp -f $SOURCES_ARMEABI/app/MapsGooglePrebuilt_arm.tar.xz $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$SYS/MapsGooglePrebuilt.tar.xz
    cp -f $SOURCES_ARMEABI/app/MarkupGooglePrebuilt_arm.tar.xz $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$SYS/MarkupGooglePrebuilt.tar.xz
    cp -f $SOURCES_ALL/app/MessagesGooglePrebuilt.tar.xz $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$SYS
    cp -f $SOURCES_ALL/app/MicroGGMSCore.tar.xz $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$SYS
    cp -f $SOURCES_ARMEABI/app/PhotosGooglePrebuilt_arm.tar.xz $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$SYS/PhotosGooglePrebuilt.tar.xz
    cp -f $SOURCES_ALL/app/SoundPickerPrebuilt.tar.xz $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$SYS
    cp -f $SOURCES_ALL/app/YouTubeStock.tar.xz $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$SYS
    cp -f $SOURCES_ALL/app/YouTubeVanced.tar.xz $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$SYS
    cp -f $SOURCES_ARMEABI/app/YouTube_arm.tar.xz $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$SYS/YouTube.tar.xz
    # Install etc packages
    cp -f $SOURCES_ALL/etc/DialerPermissions.tar.xz $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$ZIP
    cp -f $SOURCES_ALL/etc/DPSFirmware.tar.xz $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$ZIP
    cp -f $SOURCES_ALL/etc/DPSFirmwareSc.tar.xz $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$ZIP
    cp -f $SOURCES_ALL/etc/DPSPermissions.tar.xz $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$ZIP
    cp -f $SOURCES_ALL/etc/LauncherPermissions.tar.xz $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$ZIP
    cp -f $SOURCES_ALL/etc/LauncherSysconfig.tar.xz $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$ZIP
    cp -f $SOURCES_ALL/etc/MapsPermissions.tar.xz $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$ZIP
    # Install framework packages
    cp -f $SOURCES_ALL/framework/DialerFramework.tar.xz $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$ZIP
    cp -f $SOURCES_ALL/framework/MapsFramework.tar.xz $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$ZIP
    # Install overlay packages
    cp -f $SOURCES_ALL/overlay/NexusLauncherOverlay.tar.xz $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$OVERLAY
    cp -f $SOURCES_ALL/overlay/NexusLauncherOverlaySc.tar.xz $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$OVERLAY
    cp -f $SOURCES_ALL/overlay/DPSOverlay.tar.xz $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$OVERLAY
    # Install priv-app packages
    cp -f $SOURCES_ALL/priv-app/CarrierServices.tar.xz $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$CORE
    cp -f $SOURCES_ALL/priv-app/ContactsGooglePrebuilt.tar.xz $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$CORE
    cp -f $SOURCES_ARMEABI/priv-app/DialerGooglePrebuilt_arm.tar.xz $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$CORE/DialerGooglePrebuilt.tar.xz
    cp -f $SOURCES_ARMEABI/priv-app/DPSGooglePrebuilt_arm.tar.xz $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$CORE/DPSGooglePrebuilt.tar.xz
    cp -f $SOURCES_ARMEABI/priv-app/DPSGooglePrebuiltSc_arm.tar.xz $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$CORE/DPSGooglePrebuiltSc.tar.xz
    cp -f $SOURCES_ARMEABI/priv-app/DINGooglePrebuiltSc_arm.tar.xz $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$CORE/DINGooglePrebuiltSc.tar.xz
    cp -f $SOURCES_ARMEABI/priv-app/GearheadGooglePrebuilt_arm.tar.xz $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$CORE/GearheadGooglePrebuilt.tar.xz
    cp -f $SOURCES_ALL/priv-app/NexusLauncherPrebuilt.tar.xz $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$CORE
    cp -f $SOURCES_ALL/priv-app/NexusLauncherPrebuiltSc.tar.xz $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$CORE
    cp -f $SOURCES_ALL/priv-app/NexusQuickAccessWallet.tar.xz $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$CORE
    cp -f $SOURCES_ALL/priv-app/NexusQuickAccessWalletSc.tar.xz $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$CORE
    cp -f $SOURCES_ARMEABI/priv-app/Velvet_arm.tar.xz $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$CORE/Velvet.tar.xz
    cp -f $SOURCES_ALL/priv-app/WellbeingPrebuilt.tar.xz $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$CORE
    # Install usr packages
    cp -f $SOURCES_ALL/usr/usr_share.tar.xz $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$ZIP
    cp -f $SOURCES_ALL/usr/usr_srec.tar.xz $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$ZIP
    # Installer components
    cp -f $UPDATEBINARY $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$METADIR/update-binary
    cp -f $UPDATERSCRIPT $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$METADIR/updater-script
    cp -f $INSTALLER $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR
    cp -f $BUSYBOX $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR
    cp -f $AIK $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$ZIP
    # Create utility script
    makeutilityscript
    replace_line $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/util_functions.sh REL="" REL="$ADDON_RELEASE"
    replace_line $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/util_functions.sh ZIPTYPE="" ZIPTYPE="$ZIPTYPE"
    replace_line $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/util_functions.sh TARGET_GAPPS_RELEASE="" TARGET_GAPPS_RELEASE="$TARGET_GAPPS_RELEASE"
    replace_line $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/util_functions.sh TARGET_DIRTY_INSTALL="" TARGET_DIRTY_INSTALL="$TARGET_DIRTY_INSTALL"
    replace_line $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/util_functions.sh ADDON="" ADDON="$CONFIG"
    replace_line $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/util_functions.sh ARMEABI="" ARMEABI="$ARMEABI"
    replace_line $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/util_functions.sh AARCH64="" AARCH64="$AARCH64"
    replace_line $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/util_functions.sh TARGET_CONFIG_VERSION="" TARGET_CONFIG_VERSION="$TARGET_CONFIG_VERSION"
    # Add YouTube Vanced boot scripts
    makevanced
    # Create LICENSE
    makelicense
    # Create ZIP
    cd $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR
    zip -qr9 ${RELEASEDIR}.zip *
    cd ../../../..
    mv $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/${RELEASEDIR}.zip $OUTDIR/$TYPE/$ARCH/${RELEASEDIR}.zip
    # Sign ZIP
    java -jar $ZIPSIGNER $OUTDIR/$TYPE/$ARCH/${RELEASEDIR}.zip $OUTDIR/$TYPE/$ARCH/${RELEASEDIR}_signed.zip 2>/dev/null
    # Set build PLATFORM in global environment
    echo "TARGET_PLATFORM_ARM" >> $OUTDIR/ENV/env_platform.sh
    # List signed ZIP
    ls $OUTDIR/$TYPE/$ARCH/${RELEASEDIR}_signed.zip
    # Wipe unsigned ZIP
    rm -rf $OUTDIR/$TYPE/$ARCH/${RELEASEDIR}.zip
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
    mkdir "$BUILDDIR/$TYPE/$ARCH/BiTGApps-addon-${ARCH}-${COMMONADDONRELEASE}"
    RELEASEDIR="BiTGApps-addon-${ARCH}-${COMMONADDONRELEASE}"
    # Create package components
    mkdir -p $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$METADIR
    mkdir -p $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$ZIP
    mkdir -p $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$CORE
    mkdir -p $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$SYS
    mkdir -p $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$OVERLAY
    # Install app packages
    cp -f $SOURCES_AARCH64/app/BromitePrebuilt_arm64.tar.xz $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$SYS/BromitePrebuilt.tar.xz
    cp -f $SOURCES_ALL/app/CalculatorGooglePrebuilt.tar.xz $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$SYS
    cp -f $SOURCES_ALL/app/CalendarGooglePrebuilt.tar.xz $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$SYS
    cp -f $SOURCES_ALL/app/ChromeGooglePrebuilt.tar.xz $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$SYS
    cp -f $SOURCES_ALL/app/DeskClockGooglePrebuilt.tar.xz $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$SYS
    cp -f $SOURCES_AARCH64/app/GboardGooglePrebuilt_arm64.tar.xz $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$SYS/GboardGooglePrebuilt.tar.xz
    cp -f $SOURCES_AARCH64/app/GoogleTTSPrebuilt_arm64.tar.xz $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$SYS/GoogleTTSPrebuilt.tar.xz
    cp -f $SOURCES_AARCH64/app/MapsGooglePrebuilt_arm64.tar.xz $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$SYS/MapsGooglePrebuilt.tar.xz
    cp -f $SOURCES_AARCH64/app/MarkupGooglePrebuilt_arm64.tar.xz $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$SYS/MarkupGooglePrebuilt.tar.xz
    cp -f $SOURCES_ALL/app/MessagesGooglePrebuilt.tar.xz $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$SYS
    cp -f $SOURCES_ALL/app/MicroGGMSCore.tar.xz $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$SYS
    cp -f $SOURCES_AARCH64/app/PhotosGooglePrebuilt_arm64.tar.xz $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$SYS/PhotosGooglePrebuilt.tar.xz
    cp -f $SOURCES_ALL/app/SoundPickerPrebuilt.tar.xz $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$SYS
    cp -f $SOURCES_ALL/app/YouTubeStock.tar.xz $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$SYS
    cp -f $SOURCES_ALL/app/YouTubeVanced.tar.xz $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$SYS
    cp -f $SOURCES_AARCH64/app/YouTube_arm64.tar.xz $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$SYS/YouTube.tar.xz
    # Install etc packages
    cp -f $SOURCES_ALL/etc/DialerPermissions.tar.xz $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$ZIP
    cp -f $SOURCES_ALL/etc/DPSFirmware.tar.xz $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$ZIP
    cp -f $SOURCES_ALL/etc/DPSFirmwareSc.tar.xz $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$ZIP
    cp -f $SOURCES_ALL/etc/DPSPermissions.tar.xz $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$ZIP
    cp -f $SOURCES_ALL/etc/LauncherPermissions.tar.xz $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$ZIP
    cp -f $SOURCES_ALL/etc/LauncherSysconfig.tar.xz $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$ZIP
    cp -f $SOURCES_ALL/etc/MapsPermissions.tar.xz $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$ZIP
    # Install framework packages
    cp -f $SOURCES_ALL/framework/DialerFramework.tar.xz $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$ZIP
    cp -f $SOURCES_ALL/framework/MapsFramework.tar.xz $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$ZIP
    # Install overlay packages
    cp -f $SOURCES_ALL/overlay/NexusLauncherOverlay.tar.xz $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$OVERLAY
    cp -f $SOURCES_ALL/overlay/NexusLauncherOverlaySc.tar.xz $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$OVERLAY
    cp -f $SOURCES_ALL/overlay/DPSOverlay.tar.xz $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$OVERLAY
    # Install priv-app packages
    cp -f $SOURCES_ALL/priv-app/CarrierServices.tar.xz $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$CORE
    cp -f $SOURCES_ALL/priv-app/ContactsGooglePrebuilt.tar.xz $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$CORE
    cp -f $SOURCES_AARCH64/priv-app/DialerGooglePrebuilt_arm64.tar.xz $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$CORE/DialerGooglePrebuilt.tar.xz
    cp -f $SOURCES_AARCH64/priv-app/DPSGooglePrebuilt_arm64.tar.xz $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$CORE/DPSGooglePrebuilt.tar.xz
    cp -f $SOURCES_AARCH64/priv-app/DPSGooglePrebuiltSc_arm64.tar.xz $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$CORE/DPSGooglePrebuiltSc.tar.xz
    cp -f $SOURCES_AARCH64/priv-app/DINGooglePrebuiltSc_arm64.tar.xz $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$CORE/DINGooglePrebuiltSc.tar.xz
    cp -f $SOURCES_AARCH64/priv-app/GearheadGooglePrebuilt_arm64.tar.xz $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$CORE/GearheadGooglePrebuilt.tar.xz
    cp -f $SOURCES_ALL/priv-app/NexusLauncherPrebuilt.tar.xz $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$CORE
    cp -f $SOURCES_ALL/priv-app/NexusLauncherPrebuiltSc.tar.xz $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$CORE
    cp -f $SOURCES_ALL/priv-app/NexusQuickAccessWallet.tar.xz $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$CORE
    cp -f $SOURCES_ALL/priv-app/NexusQuickAccessWalletSc.tar.xz $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$CORE
    cp -f $SOURCES_AARCH64/priv-app/Velvet_arm64.tar.xz $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$CORE/Velvet.tar.xz
    cp -f $SOURCES_ALL/priv-app/WellbeingPrebuilt.tar.xz $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$CORE
    # Install usr packages
    cp -f $SOURCES_ALL/usr/usr_share.tar.xz $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$ZIP
    cp -f $SOURCES_ALL/usr/usr_srec.tar.xz $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$ZIP
    # Installer components
    cp -f $UPDATEBINARY $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$METADIR/update-binary
    cp -f $UPDATERSCRIPT $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$METADIR/updater-script
    cp -f $INSTALLER $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR
    cp -f $BUSYBOX $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR
    cp -f $AIK $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/$ZIP
    # Create utility script
    makeutilityscript
    replace_line $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/util_functions.sh REL="" REL="$ADDON_RELEASE"
    replace_line $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/util_functions.sh ZIPTYPE="" ZIPTYPE="$ZIPTYPE"
    replace_line $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/util_functions.sh TARGET_GAPPS_RELEASE="" TARGET_GAPPS_RELEASE="$TARGET_GAPPS_RELEASE"
    replace_line $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/util_functions.sh TARGET_DIRTY_INSTALL="" TARGET_DIRTY_INSTALL="$TARGET_DIRTY_INSTALL"
    replace_line $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/util_functions.sh ADDON="" ADDON="$CONFIG"
    replace_line $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/util_functions.sh ARMEABI="" ARMEABI="$ARMEABI"
    replace_line $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/util_functions.sh AARCH64="" AARCH64="$AARCH64"
    replace_line $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/util_functions.sh TARGET_CONFIG_VERSION="" TARGET_CONFIG_VERSION="$TARGET_CONFIG_VERSION"
    # Add YouTube Vanced boot scripts
    makevanced
    # Create LICENSE
    makelicense
    # Create ZIP
    cd $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR
    zip -qr9 ${RELEASEDIR}.zip *
    cd ../../../..
    mv $BUILDDIR/$TYPE/$ARCH/$RELEASEDIR/${RELEASEDIR}.zip $OUTDIR/$TYPE/$ARCH/${RELEASEDIR}.zip
    # Sign ZIP
    java -jar $ZIPSIGNER $OUTDIR/$TYPE/$ARCH/${RELEASEDIR}.zip $OUTDIR/$TYPE/$ARCH/${RELEASEDIR}_signed.zip 2>/dev/null
    # Set build PLATFORM in global environment
    echo "TARGET_PLATFORM_ARM64" >> $OUTDIR/ENV/env_platform.sh
    # List signed ZIP
    ls $OUTDIR/$TYPE/$ARCH/${RELEASEDIR}_signed.zip
    # Wipe unsigned ZIP
    rm -rf $OUTDIR/$TYPE/$ARCH/${RELEASEDIR}.zip
  fi
}

# Build
makeaddonv1
