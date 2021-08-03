#!/bin/bash
#
##############################################################
# File name       : build_gapps.sh
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
if { [ ! -n "$COMMONGAPPSRELEASE" ] ||
     [ ! -n "$GAPPS_RELEASE" ] ||
     [ ! -n "$TARGET_DIRTY_INSTALL" ] ||
     [ ! -n "$TARGET_GAPPS_RELEASE" ] ||
     [ ! -n "$TARGET_RELEASE_TAG" ] ||
     [ ! -n "$GAPPS_RELEASE_TAG" ] ||
     [ ! -n "$TARGET_CONFIG_VERSION" ] ||
     [ ! -n "$BuildDate" ] ||
     [ ! -n "$BuildID" ]; }; then
     echo "! Environmental variables not set. Aborting..."
  exit 1
fi

# Check availability of AOSP sources
if [ ! -d "sources/aosp-sources" ]; then
  echo "! AOSP sources not found. Aborting..."
  exit 1
fi

# Check availability of SetupWizard sources
if [ ! -d "sources/setup-sources" ]; then
  echo "! SetupWizard sources not found. Aborting..."
  exit 1
fi

# Check availability of build tools
if [ ! -d "Build-Tools" ]; then
  echo "! Build tools not found. Aborting..."
  exit 1
fi

# Set defaults
ARCH="$1"
API="$2"
COMMONGAPPSRELEASE="$COMMONGAPPSRELEASE"

# Build defaults
BUILDDIR="build"
OUTDIR="out"

# Signing tool
ZIPSIGNER="BiTGApps/tools/zipsigner-resources/zipsigner.jar"

# Set GApps package sources
SOURCESv25="sources/$ARCH-sources/25"
SOURCESv26="sources/$ARCH-sources/26"
SOURCESv27="sources/$ARCH-sources/27"
SOURCESv28="sources/$ARCH-sources/28"
SOURCESv29="sources/$ARCH-sources/29"
SOURCESv30="sources/$ARCH-sources/30"
SOURCESv31="sources/$ARCH-sources/31"

# Set AOSP package sources
AOSPSOURCESv25="sources/aosp-sources/$ARCH/25"
AOSPSOURCESv26="sources/aosp-sources/$ARCH/26"
AOSPSOURCESv27="sources/aosp-sources/$ARCH/27"
AOSPSOURCESv28="sources/aosp-sources/$ARCH/28"
AOSPSOURCESv29="sources/aosp-sources/$ARCH/29"
AOSPSOURCESv30="sources/aosp-sources/$ARCH/30"
AOSPSOURCESv31="sources/aosp-sources/$ARCH/31"

# Set SetupWizard package sources
SETUPSOURCESv25="sources/setup-sources/$ARCH/25"
SETUPSOURCESv26="sources/setup-sources/$ARCH/26"
SETUPSOURCESv27="sources/setup-sources/$ARCH/27"
SETUPSOURCESv28="sources/setup-sources/$ARCH/28"
SETUPSOURCESv29="sources/setup-sources/$ARCH/29"
SETUPSOURCESv30="sources/setup-sources/$ARCH/30"
SETUPSOURCESv31="sources/setup-sources/$ARCH/31"

# Set patched keystore sources
API_26_KEYSTORE="Build-Tools/Keystore/Keystore26.tar.xz"
API_27_KEYSTORE="Build-Tools/Keystore/Keystore27.tar.xz"
API_28_KEYSTORE="Build-Tools/Keystore/Keystore28.tar.xz"
API_29_KEYSTORE="Build-Tools/Keystore/Keystore29.tar.xz"
API_30_KEYSTORE="Build-Tools/Keystore/Keystore30.tar.xz"
API_31_KEYSTORE="Build-Tools/Keystore/Keystore31.tar.xz"

# Set Boot Image Editor sources
AIK="Build-Tools/AIK/AIK.tar.xz"

# Set installer sources
UPDATEBINARY="BiTGApps/scripts/update-binary.sh"
UPDATERSCRIPT="BiTGApps/scripts/updater-script.sh"
INSTALLER="BiTGApps/scripts/installer.sh"
OTASCRIPT="BiTGApps/scripts/bitgapps.sh"
BACKUPSCRIPT="BiTGApps/scripts/backup.sh"
RESTORESCRIPT="BiTGApps/scripts/restore.sh"
LOGCATSCRIPT="BiTGApps/scripts/init.logcat.rc"
BUSYBOX="BiTGApps/tools/busybox-resources/busybox-arm"

# Set ZIP structure
METADIR="META-INF/com/google/android"
ZIP="zip"
CORE="$ZIP/core"
SYS="$ZIP/sys"
AOSPZIP="$ZIP/aosp"
AOSPCORE="$ZIP/aosp/core"
AOSPSYS="$ZIP/aosp/sys"
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
TARGET_GAPPS_RELEASE=""
TARGET_DIRTY_INSTALL=""
TARGET_ANDROID_SDK=""
TARGET_ANDROID_ARCH=""
ARMEABI=""
AARCH64=""
TARGET_RELEASE_TAG=""
TARGET_CONFIG_VERSION=""' >"$BUILDDIR/$ARCH/$RELEASEDIR/util_functions.sh"
}

# Set build property
makegprop() {
echo 'CustomGAppsPackage=
platform=
sdk=
version=
BuildDate=
BuildID=
Developer=' >"$BUILDDIR/$ARCH/$RELEASEDIR/g.prop"
}

# Compress and add OTA survival script
makeota() {
  cp -f $OTASCRIPT $BUILDDIR/$ARCH/$RELEASEDIR/$ZIP
  cp -f $BACKUPSCRIPT $BUILDDIR/$ARCH/$RELEASEDIR/$ZIP
  cp -f $RESTORESCRIPT $BUILDDIR/$ARCH/$RELEASEDIR/$ZIP
  cd $BUILDDIR/$ARCH/$RELEASEDIR/$ZIP
  # Change Release Tag string
  replace_line "restore.sh" 'ro.gapps.release_tag' "  insert_line $COMMON_SYSTEM_LAYOUT/build.prop 'ro.gapps.release_tag=$GAPPS_RELEASE_TAG' after 'net.bt.name=Android' 'ro.gapps.release_tag=$GAPPS_RELEASE_TAG'"
  # Only compress in 'xz' format
  tar -cJf "Addon.tar.xz" bitgapps.sh backup.sh restore.sh
  rm -rf bitgapps.sh backup.sh restore.sh
  # Checkout path
  cd ../../../..
}

# Set OTA build property
makeotaprop() {
echo '#
# ADDITIONAL BITGAPPS BUILD PROPERTIES
#

# Begin build properties
# End build properties

# Begin addon properties
# End addon properties' >"$BUILDDIR/$ARCH/$RELEASEDIR/config.prop"
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
makegapps() {
  # Create build directory
  test -d $BUILDDIR || mkdir $BUILDDIR
  test -d $BUILDDIR/$ARCH || mkdir $BUILDDIR/$ARCH
  # Create out directory
  test -d $OUTDIR || mkdir $OUTDIR
  test -d $OUTDIR/$ARCH || mkdir $OUTDIR/$ARCH
  # Create ENV directory
  test -d $OUTDIR/ENV || mkdir $OUTDIR/ENV
  # Install variable; Do not modify
  ZIPTYPE='"basic"'
  # Build property variable; Do not modify
  Developer="TheHitMan @ XDA Developers"
  # Platform ARM
  if [ "$ARCH" == "arm" ]; then
    # Install variable; Do not modify
    TARGET_ANDROID_ARCH_32='"ARM"'
    ARMEABI='"true"'
    AARCH64='"false"'
    # Build property variable; Do not modify
    CustomGAppsPackage="BiTGApps"
    platform_32="arm"
    # API 25
    if [ "$API" == "25" ]; then
      # Install variable; Do not modify
      TARGET_ANDROID_SDK_V25='"25"'
      # Build property variable; Do not modify
      sdk_25="25"
      version_25="7.1.1"
      echo "Generating BiTGApps package for $ARCH with API level $API"
      # Create release directory
      mkdir "$BUILDDIR/$ARCH/BiTGApps-${ARCH}-7.1.1-${COMMONGAPPSRELEASE}"
      RELEASEDIR="BiTGApps-${ARCH}-7.1.1-${COMMONGAPPSRELEASE}"
      # Create package components
      mkdir -p $BUILDDIR/$ARCH/$RELEASEDIR/$METADIR
      mkdir -p $BUILDDIR/$ARCH/$RELEASEDIR/$ZIP
      mkdir -p $BUILDDIR/$ARCH/$RELEASEDIR/$CORE
      mkdir -p $BUILDDIR/$ARCH/$RELEASEDIR/$SYS
      mkdir -p $BUILDDIR/$ARCH/$RELEASEDIR/$AOSPCORE
      mkdir -p $BUILDDIR/$ARCH/$RELEASEDIR/$AOSPSYS
      # Install app packages
      cp -f $SOURCESv25/$version_25/app/FaceLock.tar.xz $BUILDDIR/$ARCH/$RELEASEDIR/$SYS
      cp -f $SOURCESv25/$version_25/app/GoogleCalendarSyncAdapter.tar.xz $BUILDDIR/$ARCH/$RELEASEDIR/$SYS
      cp -f $SOURCESv25/$version_25/app/GoogleContactsSyncAdapter.tar.xz $BUILDDIR/$ARCH/$RELEASEDIR/$SYS
      cp -f $SOURCESv25/$version_25/app/GoogleExtShared.tar.xz $BUILDDIR/$ARCH/$RELEASEDIR/$SYS
      # Install etc packages
      cp -f $SOURCESv25/$version_25/etc/Default.tar.xz $BUILDDIR/$ARCH/$RELEASEDIR/$ZIP
      cp -f $SOURCESv25/$version_25/etc/Permissions.tar.xz $BUILDDIR/$ARCH/$RELEASEDIR/$ZIP
      cp -f $SOURCESv25/$version_25/etc/Preferred.tar.xz $BUILDDIR/$ARCH/$RELEASEDIR/$ZIP
      cp -f $SOURCESv25/$version_25/etc/Sysconfig.tar.xz $BUILDDIR/$ARCH/$RELEASEDIR/$ZIP
      # Install priv-app packages
      cp -f $SOURCESv25/$version_25/priv-app/ConfigUpdater.tar.xz $BUILDDIR/$ARCH/$RELEASEDIR/$CORE
      cp -f $SOURCESv25/$version_25/priv-app/GmsCoreSetupPrebuilt.tar.xz $BUILDDIR/$ARCH/$RELEASEDIR/$CORE
      cp -f $SOURCESv25/$version_25/priv-app/GoogleExtServices.tar.xz $BUILDDIR/$ARCH/$RELEASEDIR/$CORE
      cp -f $SOURCESv25/$version_25/priv-app/GoogleLoginService.tar.xz $BUILDDIR/$ARCH/$RELEASEDIR/$CORE
      cp -f $SOURCESv25/$version_25/priv-app/GoogleServicesFramework.tar.xz $BUILDDIR/$ARCH/$RELEASEDIR/$CORE
      cp -f $SOURCESv25/$version_25/priv-app/Phonesky.tar.xz $BUILDDIR/$ARCH/$RELEASEDIR/$CORE
      cp -f $SOURCESv25/$version_25/priv-app/PrebuiltGmsCore.tar.xz $BUILDDIR/$ARCH/$RELEASEDIR/$CORE
      # Install AOSP packages
      cp -f $AOSPSOURCESv25/$version_25/app/Messaging.tar.xz $BUILDDIR/$ARCH/$RELEASEDIR/$AOSPSYS
      cp -f $AOSPSOURCESv25/$version_25/etc/Permissions.tar.xz $BUILDDIR/$ARCH/$RELEASEDIR/$AOSPZIP
      cp -f $AOSPSOURCESv25/$version_25/priv-app/Contacts.tar.xz $BUILDDIR/$ARCH/$RELEASEDIR/$AOSPCORE
      cp -f $AOSPSOURCESv25/$version_25/priv-app/Dialer.tar.xz $BUILDDIR/$ARCH/$RELEASEDIR/$AOSPCORE
      cp -f $AOSPSOURCESv25/$version_25/priv-app/ManagedProvisioning.tar.xz $BUILDDIR/$ARCH/$RELEASEDIR/$AOSPCORE
      cp -f $AOSPSOURCESv25/$version_25/priv-app/Provision.tar.xz $BUILDDIR/$ARCH/$RELEASEDIR/$AOSPCORE
      # Install SetupWizard packages
      cp -f $SETUPSOURCESv25/$version_25/priv-app/GoogleBackupTransport.tar.xz $BUILDDIR/$ARCH/$RELEASEDIR/$CORE
      cp -f $SETUPSOURCESv25/$version_25/priv-app/SetupWizardPrebuilt.tar.xz $BUILDDIR/$ARCH/$RELEASEDIR/$CORE
      # Installer components
      cp -f $UPDATEBINARY $BUILDDIR/$ARCH/$RELEASEDIR/$METADIR/update-binary
      cp -f $UPDATERSCRIPT $BUILDDIR/$ARCH/$RELEASEDIR/$METADIR/updater-script
      cp -f $INSTALLER $BUILDDIR/$ARCH/$RELEASEDIR
      cp -f $LOGCATSCRIPT $BUILDDIR/$ARCH/$RELEASEDIR
      cp -f $BUSYBOX $BUILDDIR/$ARCH/$RELEASEDIR
      cp -f $AIK $BUILDDIR/$ARCH/$RELEASEDIR/$ZIP
      # Create utility script
      makeutilityscript
      replace_line $BUILDDIR/$ARCH/$RELEASEDIR/util_functions.sh REL="" REL="$GAPPS_RELEASE"
      replace_line $BUILDDIR/$ARCH/$RELEASEDIR/util_functions.sh ZIPTYPE="" ZIPTYPE="$ZIPTYPE"
      replace_line $BUILDDIR/$ARCH/$RELEASEDIR/util_functions.sh TARGET_GAPPS_RELEASE="" TARGET_GAPPS_RELEASE="$TARGET_GAPPS_RELEASE"
      replace_line $BUILDDIR/$ARCH/$RELEASEDIR/util_functions.sh TARGET_DIRTY_INSTALL="" TARGET_DIRTY_INSTALL="$TARGET_DIRTY_INSTALL"
      replace_line $BUILDDIR/$ARCH/$RELEASEDIR/util_functions.sh TARGET_ANDROID_SDK="" TARGET_ANDROID_SDK="$TARGET_ANDROID_SDK_V25"
      replace_line $BUILDDIR/$ARCH/$RELEASEDIR/util_functions.sh TARGET_ANDROID_ARCH="" TARGET_ANDROID_ARCH="$TARGET_ANDROID_ARCH_32"
      replace_line $BUILDDIR/$ARCH/$RELEASEDIR/util_functions.sh ARMEABI="" ARMEABI="$ARMEABI"
      replace_line $BUILDDIR/$ARCH/$RELEASEDIR/util_functions.sh AARCH64="" AARCH64="$AARCH64"
      replace_line $BUILDDIR/$ARCH/$RELEASEDIR/util_functions.sh TARGET_RELEASE_TAG="" TARGET_RELEASE_TAG="$TARGET_RELEASE_TAG"
      replace_line $BUILDDIR/$ARCH/$RELEASEDIR/util_functions.sh TARGET_CONFIG_VERSION="" TARGET_CONFIG_VERSION="$TARGET_CONFIG_VERSION"
      # Create build property file
      makegprop
      replace_line $BUILDDIR/$ARCH/$RELEASEDIR/g.prop CustomGAppsPackage= CustomGAppsPackage="$CustomGAppsPackage"
      replace_line $BUILDDIR/$ARCH/$RELEASEDIR/g.prop platform= platform="$platform_32"
      replace_line $BUILDDIR/$ARCH/$RELEASEDIR/g.prop sdk= sdk="$sdk_25"
      replace_line $BUILDDIR/$ARCH/$RELEASEDIR/g.prop version= version="$version_25"
      replace_line $BUILDDIR/$ARCH/$RELEASEDIR/g.prop BuildDate= BuildDate="$BuildDate"
      replace_line $BUILDDIR/$ARCH/$RELEASEDIR/g.prop BuildID= BuildID="$BuildID"
      replace_line $BUILDDIR/$ARCH/$RELEASEDIR/g.prop Developer= Developer="$Developer"
      # Add OTA script
      makeota
      # Create OTA property file
      makeotaprop
      # Create LICENSE
      makelicense
      # Create ZIP
      cd $BUILDDIR/$ARCH/$RELEASEDIR
      zip -qr9 ${RELEASEDIR}.zip *
      cd ../../..
      mv $BUILDDIR/$ARCH/$RELEASEDIR/${RELEASEDIR}.zip $OUTDIR/$ARCH/${RELEASEDIR}.zip
      # Sign ZIP
      java -jar $ZIPSIGNER $OUTDIR/$ARCH/${RELEASEDIR}.zip $OUTDIR/$ARCH/${RELEASEDIR}_signed.zip 2>/dev/null
      # Set build API in global environment
      [ "$(grep -w -o TARGET_API_25 $OUTDIR/ENV/env_api.sh 2>/dev/null)" ] || echo "TARGET_API_25" >> $OUTDIR/ENV/env_api.sh
      # List signed ZIP
      ls $OUTDIR/$ARCH/${RELEASEDIR}_signed.zip
      # Wipe unsigned ZIP
      rm -rf $OUTDIR/$ARCH/${RELEASEDIR}.zip
    fi
    # API 25
    if [ "$API" == "25" ]; then
      # Install variable; Do not modify
      TARGET_ANDROID_SDK_V25='"25"'
      # Build property variable; Do not modify
      sdk_25="25"
      version_25="7.1.2"
      echo "Generating BiTGApps package for $ARCH with API level $API"
      # Create release directory
      mkdir "$BUILDDIR/$ARCH/BiTGApps-${ARCH}-7.1.2-${COMMONGAPPSRELEASE}"
      RELEASEDIR="BiTGApps-${ARCH}-7.1.2-${COMMONGAPPSRELEASE}"
      # Create package components
      mkdir -p $BUILDDIR/$ARCH/$RELEASEDIR/$METADIR
      mkdir -p $BUILDDIR/$ARCH/$RELEASEDIR/$ZIP
      mkdir -p $BUILDDIR/$ARCH/$RELEASEDIR/$CORE
      mkdir -p $BUILDDIR/$ARCH/$RELEASEDIR/$SYS
      mkdir -p $BUILDDIR/$ARCH/$RELEASEDIR/$AOSPCORE
      mkdir -p $BUILDDIR/$ARCH/$RELEASEDIR/$AOSPSYS
      # Install app packages
      cp -f $SOURCESv25/$version_25/app/FaceLock.tar.xz $BUILDDIR/$ARCH/$RELEASEDIR/$SYS
      cp -f $SOURCESv25/$version_25/app/GoogleCalendarSyncAdapter.tar.xz $BUILDDIR/$ARCH/$RELEASEDIR/$SYS
      cp -f $SOURCESv25/$version_25/app/GoogleContactsSyncAdapter.tar.xz $BUILDDIR/$ARCH/$RELEASEDIR/$SYS
      cp -f $SOURCESv25/$version_25/app/GoogleExtShared.tar.xz $BUILDDIR/$ARCH/$RELEASEDIR/$SYS
      # Install etc packages
      cp -f $SOURCESv25/$version_25/etc/Default.tar.xz $BUILDDIR/$ARCH/$RELEASEDIR/$ZIP
      cp -f $SOURCESv25/$version_25/etc/Permissions.tar.xz $BUILDDIR/$ARCH/$RELEASEDIR/$ZIP
      cp -f $SOURCESv25/$version_25/etc/Preferred.tar.xz $BUILDDIR/$ARCH/$RELEASEDIR/$ZIP
      cp -f $SOURCESv25/$version_25/etc/Sysconfig.tar.xz $BUILDDIR/$ARCH/$RELEASEDIR/$ZIP
      # Install priv-app packages
      cp -f $SOURCESv25/$version_25/priv-app/ConfigUpdater.tar.xz $BUILDDIR/$ARCH/$RELEASEDIR/$CORE
      cp -f $SOURCESv25/$version_25/priv-app/GmsCoreSetupPrebuilt.tar.xz $BUILDDIR/$ARCH/$RELEASEDIR/$CORE
      cp -f $SOURCESv25/$version_25/priv-app/GoogleExtServices.tar.xz $BUILDDIR/$ARCH/$RELEASEDIR/$CORE
      cp -f $SOURCESv25/$version_25/priv-app/GoogleLoginService.tar.xz $BUILDDIR/$ARCH/$RELEASEDIR/$CORE
      cp -f $SOURCESv25/$version_25/priv-app/GoogleServicesFramework.tar.xz $BUILDDIR/$ARCH/$RELEASEDIR/$CORE
      cp -f $SOURCESv25/$version_25/priv-app/Phonesky.tar.xz $BUILDDIR/$ARCH/$RELEASEDIR/$CORE
      cp -f $SOURCESv25/$version_25/priv-app/PrebuiltGmsCore.tar.xz $BUILDDIR/$ARCH/$RELEASEDIR/$CORE
      # Install AOSP packages
      cp -f $AOSPSOURCESv25/$version_25/app/Messaging.tar.xz $BUILDDIR/$ARCH/$RELEASEDIR/$AOSPSYS
      cp -f $AOSPSOURCESv25/$version_25/etc/Permissions.tar.xz $BUILDDIR/$ARCH/$RELEASEDIR/$AOSPZIP
      cp -f $AOSPSOURCESv25/$version_25/priv-app/Contacts.tar.xz $BUILDDIR/$ARCH/$RELEASEDIR/$AOSPCORE
      cp -f $AOSPSOURCESv25/$version_25/priv-app/Dialer.tar.xz $BUILDDIR/$ARCH/$RELEASEDIR/$AOSPCORE
      cp -f $AOSPSOURCESv25/$version_25/priv-app/ManagedProvisioning.tar.xz $BUILDDIR/$ARCH/$RELEASEDIR/$AOSPCORE
      cp -f $AOSPSOURCESv25/$version_25/priv-app/Provision.tar.xz $BUILDDIR/$ARCH/$RELEASEDIR/$AOSPCORE
      # Install SetupWizard packages
      cp -f $SETUPSOURCESv25/$version_25/priv-app/GoogleBackupTransport.tar.xz $BUILDDIR/$ARCH/$RELEASEDIR/$CORE
      cp -f $SETUPSOURCESv25/$version_25/priv-app/SetupWizardPrebuilt.tar.xz $BUILDDIR/$ARCH/$RELEASEDIR/$CORE
      # Installer components
      cp -f $UPDATEBINARY $BUILDDIR/$ARCH/$RELEASEDIR/$METADIR/update-binary
      cp -f $UPDATERSCRIPT $BUILDDIR/$ARCH/$RELEASEDIR/$METADIR/updater-script
      cp -f $INSTALLER $BUILDDIR/$ARCH/$RELEASEDIR
      cp -f $LOGCATSCRIPT $BUILDDIR/$ARCH/$RELEASEDIR
      cp -f $BUSYBOX $BUILDDIR/$ARCH/$RELEASEDIR
      cp -f $AIK $BUILDDIR/$ARCH/$RELEASEDIR/$ZIP
      # Create utility script
      makeutilityscript
      replace_line $BUILDDIR/$ARCH/$RELEASEDIR/util_functions.sh REL="" REL="$GAPPS_RELEASE"
      replace_line $BUILDDIR/$ARCH/$RELEASEDIR/util_functions.sh ZIPTYPE="" ZIPTYPE="$ZIPTYPE"
      replace_line $BUILDDIR/$ARCH/$RELEASEDIR/util_functions.sh TARGET_GAPPS_RELEASE="" TARGET_GAPPS_RELEASE="$TARGET_GAPPS_RELEASE"
      replace_line $BUILDDIR/$ARCH/$RELEASEDIR/util_functions.sh TARGET_DIRTY_INSTALL="" TARGET_DIRTY_INSTALL="$TARGET_DIRTY_INSTALL"
      replace_line $BUILDDIR/$ARCH/$RELEASEDIR/util_functions.sh TARGET_ANDROID_SDK="" TARGET_ANDROID_SDK="$TARGET_ANDROID_SDK_V25"
      replace_line $BUILDDIR/$ARCH/$RELEASEDIR/util_functions.sh TARGET_ANDROID_ARCH="" TARGET_ANDROID_ARCH="$TARGET_ANDROID_ARCH_32"
      replace_line $BUILDDIR/$ARCH/$RELEASEDIR/util_functions.sh ARMEABI="" ARMEABI="$ARMEABI"
      replace_line $BUILDDIR/$ARCH/$RELEASEDIR/util_functions.sh AARCH64="" AARCH64="$AARCH64"
      replace_line $BUILDDIR/$ARCH/$RELEASEDIR/util_functions.sh TARGET_RELEASE_TAG="" TARGET_RELEASE_TAG="$TARGET_RELEASE_TAG"
      replace_line $BUILDDIR/$ARCH/$RELEASEDIR/util_functions.sh TARGET_CONFIG_VERSION="" TARGET_CONFIG_VERSION="$TARGET_CONFIG_VERSION"
      # Create build property file
      makegprop
      replace_line $BUILDDIR/$ARCH/$RELEASEDIR/g.prop CustomGAppsPackage= CustomGAppsPackage="$CustomGAppsPackage"
      replace_line $BUILDDIR/$ARCH/$RELEASEDIR/g.prop platform= platform="$platform_32"
      replace_line $BUILDDIR/$ARCH/$RELEASEDIR/g.prop sdk= sdk="$sdk_25"
      replace_line $BUILDDIR/$ARCH/$RELEASEDIR/g.prop version= version="$version_25"
      replace_line $BUILDDIR/$ARCH/$RELEASEDIR/g.prop BuildDate= BuildDate="$BuildDate"
      replace_line $BUILDDIR/$ARCH/$RELEASEDIR/g.prop BuildID= BuildID="$BuildID"
      replace_line $BUILDDIR/$ARCH/$RELEASEDIR/g.prop Developer= Developer="$Developer"
      # Add OTA script
      makeota
      # Create OTA property file
      makeotaprop
      # Create LICENSE
      makelicense
      # Create ZIP
      cd $BUILDDIR/$ARCH/$RELEASEDIR
      zip -qr9 ${RELEASEDIR}.zip *
      cd ../../..
      mv $BUILDDIR/$ARCH/$RELEASEDIR/${RELEASEDIR}.zip $OUTDIR/$ARCH/${RELEASEDIR}.zip
      # Sign ZIP
      java -jar $ZIPSIGNER $OUTDIR/$ARCH/${RELEASEDIR}.zip $OUTDIR/$ARCH/${RELEASEDIR}_signed.zip 2>/dev/null
      # Set build API in global environment
      [ "$(grep -w -o TARGET_API_25 $OUTDIR/ENV/env_api.sh 2>/dev/null)" ] || echo "TARGET_API_25" >> $OUTDIR/ENV/env_api.sh
      # List signed ZIP
      ls $OUTDIR/$ARCH/${RELEASEDIR}_signed.zip
      # Wipe unsigned ZIP
      rm -rf $OUTDIR/$ARCH/${RELEASEDIR}.zip
    fi
    # API 26
    if [ "$API" == "26" ]; then
      # Install variable; Do not modify
      TARGET_ANDROID_SDK_V26='"26"'
      # Build property variable; Do not modify
      sdk_26="26"
      version_26="8.0.0"
      echo "Generating BiTGApps package for $ARCH with API level $API"
      # Create release directory
      mkdir "$BUILDDIR/$ARCH/BiTGApps-${ARCH}-8.0.0-${COMMONGAPPSRELEASE}"
      RELEASEDIR="BiTGApps-${ARCH}-8.0.0-${COMMONGAPPSRELEASE}"
      # Create package components
      mkdir -p $BUILDDIR/$ARCH/$RELEASEDIR/$METADIR
      mkdir -p $BUILDDIR/$ARCH/$RELEASEDIR/$ZIP
      mkdir -p $BUILDDIR/$ARCH/$RELEASEDIR/$CORE
      mkdir -p $BUILDDIR/$ARCH/$RELEASEDIR/$SYS
      mkdir -p $BUILDDIR/$ARCH/$RELEASEDIR/$AOSPCORE
      mkdir -p $BUILDDIR/$ARCH/$RELEASEDIR/$AOSPSYS
      # Install app packages
      cp -f $SOURCESv26/app/FaceLock.tar.xz $BUILDDIR/$ARCH/$RELEASEDIR/$SYS
      cp -f $SOURCESv26/app/GoogleCalendarSyncAdapter.tar.xz $BUILDDIR/$ARCH/$RELEASEDIR/$SYS
      cp -f $SOURCESv26/app/GoogleContactsSyncAdapter.tar.xz $BUILDDIR/$ARCH/$RELEASEDIR/$SYS
      cp -f $SOURCESv26/app/GoogleExtShared.tar.xz $BUILDDIR/$ARCH/$RELEASEDIR/$SYS
      # Install etc packages
      cp -f $SOURCESv26/etc/Default.tar.xz $BUILDDIR/$ARCH/$RELEASEDIR/$ZIP
      cp -f $SOURCESv26/etc/Permissions.tar.xz $BUILDDIR/$ARCH/$RELEASEDIR/$ZIP
      cp -f $SOURCESv26/etc/Preferred.tar.xz $BUILDDIR/$ARCH/$RELEASEDIR/$ZIP
      cp -f $SOURCESv26/etc/Sysconfig.tar.xz $BUILDDIR/$ARCH/$RELEASEDIR/$ZIP
      # Install priv-app packages
      cp -f $SOURCESv26/priv-app/ConfigUpdater.tar.xz $BUILDDIR/$ARCH/$RELEASEDIR/$CORE
      cp -f $SOURCESv26/priv-app/GmsCoreSetupPrebuilt.tar.xz $BUILDDIR/$ARCH/$RELEASEDIR/$CORE
      cp -f $SOURCESv26/priv-app/GoogleExtServices.tar.xz $BUILDDIR/$ARCH/$RELEASEDIR/$CORE
      cp -f $SOURCESv26/priv-app/GoogleServicesFramework.tar.xz $BUILDDIR/$ARCH/$RELEASEDIR/$CORE
      cp -f $SOURCESv26/priv-app/Phonesky.tar.xz $BUILDDIR/$ARCH/$RELEASEDIR/$CORE
      cp -f $SOURCESv26/priv-app/PrebuiltGmsCorePix.tar.xz $BUILDDIR/$ARCH/$RELEASEDIR/$CORE
      # Install AOSP packages
      cp -f $AOSPSOURCESv26/app/Messaging.tar.xz $BUILDDIR/$ARCH/$RELEASEDIR/$AOSPSYS
      cp -f $AOSPSOURCESv26/etc/Permissions.tar.xz $BUILDDIR/$ARCH/$RELEASEDIR/$AOSPZIP
      cp -f $AOSPSOURCESv26/priv-app/Contacts.tar.xz $BUILDDIR/$ARCH/$RELEASEDIR/$AOSPCORE
      cp -f $AOSPSOURCESv26/priv-app/Dialer.tar.xz $BUILDDIR/$ARCH/$RELEASEDIR/$AOSPCORE
      cp -f $AOSPSOURCESv26/priv-app/ManagedProvisioning.tar.xz $BUILDDIR/$ARCH/$RELEASEDIR/$AOSPCORE
      cp -f $AOSPSOURCESv26/priv-app/Provision.tar.xz $BUILDDIR/$ARCH/$RELEASEDIR/$AOSPCORE
      # Install SetupWizard packages
      cp -f $SETUPSOURCESv26/priv-app/GoogleBackupTransport.tar.xz $BUILDDIR/$ARCH/$RELEASEDIR/$CORE
      cp -f $SETUPSOURCESv26/priv-app/SetupWizardPrebuilt.tar.xz $BUILDDIR/$ARCH/$RELEASEDIR/$CORE
      # Installer components
      cp -f $UPDATEBINARY $BUILDDIR/$ARCH/$RELEASEDIR/$METADIR/update-binary
      cp -f $UPDATERSCRIPT $BUILDDIR/$ARCH/$RELEASEDIR/$METADIR/updater-script
      cp -f $INSTALLER $BUILDDIR/$ARCH/$RELEASEDIR
      cp -f $LOGCATSCRIPT $BUILDDIR/$ARCH/$RELEASEDIR
      cp -f $BUSYBOX $BUILDDIR/$ARCH/$RELEASEDIR
      cp -f $AIK $BUILDDIR/$ARCH/$RELEASEDIR/$ZIP
      cp -f $API_26_KEYSTORE $BUILDDIR/$ARCH/$RELEASEDIR/$ZIP
      # Create utility script
      makeutilityscript
      replace_line $BUILDDIR/$ARCH/$RELEASEDIR/util_functions.sh REL="" REL="$GAPPS_RELEASE"
      replace_line $BUILDDIR/$ARCH/$RELEASEDIR/util_functions.sh ZIPTYPE="" ZIPTYPE="$ZIPTYPE"
      replace_line $BUILDDIR/$ARCH/$RELEASEDIR/util_functions.sh TARGET_GAPPS_RELEASE="" TARGET_GAPPS_RELEASE="$TARGET_GAPPS_RELEASE"
      replace_line $BUILDDIR/$ARCH/$RELEASEDIR/util_functions.sh TARGET_DIRTY_INSTALL="" TARGET_DIRTY_INSTALL="$TARGET_DIRTY_INSTALL"
      replace_line $BUILDDIR/$ARCH/$RELEASEDIR/util_functions.sh TARGET_ANDROID_SDK="" TARGET_ANDROID_SDK="$TARGET_ANDROID_SDK_V26"
      replace_line $BUILDDIR/$ARCH/$RELEASEDIR/util_functions.sh TARGET_ANDROID_ARCH="" TARGET_ANDROID_ARCH="$TARGET_ANDROID_ARCH_32"
      replace_line $BUILDDIR/$ARCH/$RELEASEDIR/util_functions.sh ARMEABI="" ARMEABI="$ARMEABI"
      replace_line $BUILDDIR/$ARCH/$RELEASEDIR/util_functions.sh AARCH64="" AARCH64="$AARCH64"
      replace_line $BUILDDIR/$ARCH/$RELEASEDIR/util_functions.sh TARGET_RELEASE_TAG="" TARGET_RELEASE_TAG="$TARGET_RELEASE_TAG"
      replace_line $BUILDDIR/$ARCH/$RELEASEDIR/util_functions.sh TARGET_CONFIG_VERSION="" TARGET_CONFIG_VERSION="$TARGET_CONFIG_VERSION"
      # Create build property file
      makegprop
      replace_line $BUILDDIR/$ARCH/$RELEASEDIR/g.prop CustomGAppsPackage= CustomGAppsPackage="$CustomGAppsPackage"
      replace_line $BUILDDIR/$ARCH/$RELEASEDIR/g.prop platform= platform="$platform_32"
      replace_line $BUILDDIR/$ARCH/$RELEASEDIR/g.prop sdk= sdk="$sdk_26"
      replace_line $BUILDDIR/$ARCH/$RELEASEDIR/g.prop version= version="$version_26"
      replace_line $BUILDDIR/$ARCH/$RELEASEDIR/g.prop BuildDate= BuildDate="$BuildDate"
      replace_line $BUILDDIR/$ARCH/$RELEASEDIR/g.prop BuildID= BuildID="$BuildID"
      replace_line $BUILDDIR/$ARCH/$RELEASEDIR/g.prop Developer= Developer="$Developer"
      # Add OTA script
      makeota
      # Create OTA property file
      makeotaprop
      # Create LICENSE
      makelicense
      # Create ZIP
      cd $BUILDDIR/$ARCH/$RELEASEDIR
      zip -qr9 ${RELEASEDIR}.zip *
      cd ../../..
      mv $BUILDDIR/$ARCH/$RELEASEDIR/${RELEASEDIR}.zip $OUTDIR/$ARCH/${RELEASEDIR}.zip
      # Sign ZIP
      java -jar $ZIPSIGNER $OUTDIR/$ARCH/${RELEASEDIR}.zip $OUTDIR/$ARCH/${RELEASEDIR}_signed.zip 2>/dev/null
      # Set build API in global environment
      [ "$(grep -w -o TARGET_API_26 $OUTDIR/ENV/env_api.sh 2>/dev/null)" ] || echo "TARGET_API_26" >> $OUTDIR/ENV/env_api.sh
      # List signed ZIP
      ls $OUTDIR/$ARCH/${RELEASEDIR}_signed.zip
      # Wipe unsigned ZIP
      rm -rf $OUTDIR/$ARCH/${RELEASEDIR}.zip
    fi
    # API 27
    if [ "$API" == "27" ]; then
      # Install variable; Do not modify
      TARGET_ANDROID_SDK_V27='"27"'
      # Build property variable; Do not modify
      sdk_27="27"
      version_27="8.1.0"
      echo "Generating BiTGApps package for $ARCH with API level $API"
      # Create release directory
      mkdir "$BUILDDIR/$ARCH/BiTGApps-${ARCH}-8.1.0-${COMMONGAPPSRELEASE}"
      RELEASEDIR="BiTGApps-${ARCH}-8.1.0-${COMMONGAPPSRELEASE}"
      # Create package components
      mkdir -p $BUILDDIR/$ARCH/$RELEASEDIR/$METADIR
      mkdir -p $BUILDDIR/$ARCH/$RELEASEDIR/$ZIP
      mkdir -p $BUILDDIR/$ARCH/$RELEASEDIR/$CORE
      mkdir -p $BUILDDIR/$ARCH/$RELEASEDIR/$SYS
      mkdir -p $BUILDDIR/$ARCH/$RELEASEDIR/$AOSPCORE
      mkdir -p $BUILDDIR/$ARCH/$RELEASEDIR/$AOSPSYS
      # Install app packages
      cp -f $SOURCESv27/app/FaceLock.tar.xz $BUILDDIR/$ARCH/$RELEASEDIR/$SYS
      cp -f $SOURCESv27/app/GoogleCalendarSyncAdapter.tar.xz $BUILDDIR/$ARCH/$RELEASEDIR/$SYS
      cp -f $SOURCESv27/app/GoogleContactsSyncAdapter.tar.xz $BUILDDIR/$ARCH/$RELEASEDIR/$SYS
      cp -f $SOURCESv27/app/GoogleExtShared.tar.xz $BUILDDIR/$ARCH/$RELEASEDIR/$SYS
      # Install etc packages
      cp -f $SOURCESv27/etc/Default.tar.xz $BUILDDIR/$ARCH/$RELEASEDIR/$ZIP
      cp -f $SOURCESv27/etc/Permissions.tar.xz $BUILDDIR/$ARCH/$RELEASEDIR/$ZIP
      cp -f $SOURCESv27/etc/Preferred.tar.xz $BUILDDIR/$ARCH/$RELEASEDIR/$ZIP
      cp -f $SOURCESv27/etc/Sysconfig.tar.xz $BUILDDIR/$ARCH/$RELEASEDIR/$ZIP
      # Install priv-app packages
      cp -f $SOURCESv27/priv-app/ConfigUpdater.tar.xz $BUILDDIR/$ARCH/$RELEASEDIR/$CORE
      cp -f $SOURCESv27/priv-app/GmsCoreSetupPrebuilt.tar.xz $BUILDDIR/$ARCH/$RELEASEDIR/$CORE
      cp -f $SOURCESv27/priv-app/GoogleExtServices.tar.xz $BUILDDIR/$ARCH/$RELEASEDIR/$CORE
      cp -f $SOURCESv27/priv-app/GoogleServicesFramework.tar.xz $BUILDDIR/$ARCH/$RELEASEDIR/$CORE
      cp -f $SOURCESv27/priv-app/Phonesky.tar.xz $BUILDDIR/$ARCH/$RELEASEDIR/$CORE
      cp -f $SOURCESv27/priv-app/PrebuiltGmsCorePix.tar.xz $BUILDDIR/$ARCH/$RELEASEDIR/$CORE
      # Install AOSP packages
      cp -f $AOSPSOURCESv27/app/Messaging.tar.xz $BUILDDIR/$ARCH/$RELEASEDIR/$AOSPSYS
      cp -f $AOSPSOURCESv27/etc/Permissions.tar.xz $BUILDDIR/$ARCH/$RELEASEDIR/$AOSPZIP
      cp -f $AOSPSOURCESv27/priv-app/Contacts.tar.xz $BUILDDIR/$ARCH/$RELEASEDIR/$AOSPCORE
      cp -f $AOSPSOURCESv27/priv-app/Dialer.tar.xz $BUILDDIR/$ARCH/$RELEASEDIR/$AOSPCORE
      cp -f $AOSPSOURCESv27/priv-app/ManagedProvisioning.tar.xz $BUILDDIR/$ARCH/$RELEASEDIR/$AOSPCORE
      cp -f $AOSPSOURCESv27/priv-app/Provision.tar.xz $BUILDDIR/$ARCH/$RELEASEDIR/$AOSPCORE
      # Install SetupWizard packages
      cp -f $SETUPSOURCESv27/priv-app/GoogleBackupTransport.tar.xz $BUILDDIR/$ARCH/$RELEASEDIR/$CORE
      cp -f $SETUPSOURCESv27/priv-app/SetupWizardPrebuilt.tar.xz $BUILDDIR/$ARCH/$RELEASEDIR/$CORE
      # Installer components
      cp -f $UPDATEBINARY $BUILDDIR/$ARCH/$RELEASEDIR/$METADIR/update-binary
      cp -f $UPDATERSCRIPT $BUILDDIR/$ARCH/$RELEASEDIR/$METADIR/updater-script
      cp -f $INSTALLER $BUILDDIR/$ARCH/$RELEASEDIR
      cp -f $LOGCATSCRIPT $BUILDDIR/$ARCH/$RELEASEDIR
      cp -f $BUSYBOX $BUILDDIR/$ARCH/$RELEASEDIR
      cp -f $AIK $BUILDDIR/$ARCH/$RELEASEDIR/$ZIP
      cp -f $API_27_KEYSTORE $BUILDDIR/$ARCH/$RELEASEDIR/$ZIP
      # Create utility script
      makeutilityscript
      replace_line $BUILDDIR/$ARCH/$RELEASEDIR/util_functions.sh REL="" REL="$GAPPS_RELEASE"
      replace_line $BUILDDIR/$ARCH/$RELEASEDIR/util_functions.sh ZIPTYPE="" ZIPTYPE="$ZIPTYPE"
      replace_line $BUILDDIR/$ARCH/$RELEASEDIR/util_functions.sh TARGET_GAPPS_RELEASE="" TARGET_GAPPS_RELEASE="$TARGET_GAPPS_RELEASE"
      replace_line $BUILDDIR/$ARCH/$RELEASEDIR/util_functions.sh TARGET_DIRTY_INSTALL="" TARGET_DIRTY_INSTALL="$TARGET_DIRTY_INSTALL"
      replace_line $BUILDDIR/$ARCH/$RELEASEDIR/util_functions.sh TARGET_ANDROID_SDK="" TARGET_ANDROID_SDK="$TARGET_ANDROID_SDK_V27"
      replace_line $BUILDDIR/$ARCH/$RELEASEDIR/util_functions.sh TARGET_ANDROID_ARCH="" TARGET_ANDROID_ARCH="$TARGET_ANDROID_ARCH_32"
      replace_line $BUILDDIR/$ARCH/$RELEASEDIR/util_functions.sh ARMEABI="" ARMEABI="$ARMEABI"
      replace_line $BUILDDIR/$ARCH/$RELEASEDIR/util_functions.sh AARCH64="" AARCH64="$AARCH64"
      replace_line $BUILDDIR/$ARCH/$RELEASEDIR/util_functions.sh TARGET_RELEASE_TAG="" TARGET_RELEASE_TAG="$TARGET_RELEASE_TAG"
      replace_line $BUILDDIR/$ARCH/$RELEASEDIR/util_functions.sh TARGET_CONFIG_VERSION="" TARGET_CONFIG_VERSION="$TARGET_CONFIG_VERSION"
      # Create build property file
      makegprop
      replace_line $BUILDDIR/$ARCH/$RELEASEDIR/g.prop CustomGAppsPackage= CustomGAppsPackage="$CustomGAppsPackage"
      replace_line $BUILDDIR/$ARCH/$RELEASEDIR/g.prop platform= platform="$platform_32"
      replace_line $BUILDDIR/$ARCH/$RELEASEDIR/g.prop sdk= sdk="$sdk_27"
      replace_line $BUILDDIR/$ARCH/$RELEASEDIR/g.prop version= version="$version_27"
      replace_line $BUILDDIR/$ARCH/$RELEASEDIR/g.prop BuildDate= BuildDate="$BuildDate"
      replace_line $BUILDDIR/$ARCH/$RELEASEDIR/g.prop BuildID= BuildID="$BuildID"
      replace_line $BUILDDIR/$ARCH/$RELEASEDIR/g.prop Developer= Developer="$Developer"
      # Add OTA script
      makeota
      # Create OTA property file
      makeotaprop
      # Create LICENSE
      makelicense
      # Create ZIP
      cd $BUILDDIR/$ARCH/$RELEASEDIR
      zip -qr9 ${RELEASEDIR}.zip *
      cd ../../..
      mv $BUILDDIR/$ARCH/$RELEASEDIR/${RELEASEDIR}.zip $OUTDIR/$ARCH/${RELEASEDIR}.zip
      # Sign ZIP
      java -jar $ZIPSIGNER $OUTDIR/$ARCH/${RELEASEDIR}.zip $OUTDIR/$ARCH/${RELEASEDIR}_signed.zip 2>/dev/null
      # Set build API in global environment
      [ "$(grep -w -o TARGET_API_27 $OUTDIR/ENV/env_api.sh 2>/dev/null)" ] || echo "TARGET_API_27" >> $OUTDIR/ENV/env_api.sh
      # List signed ZIP
      ls $OUTDIR/$ARCH/${RELEASEDIR}_signed.zip
      # Wipe unsigned ZIP
      rm -rf $OUTDIR/$ARCH/${RELEASEDIR}.zip
    fi
    # API 28
    if [ "$API" == "28" ]; then
      # Install variable; Do not modify
      TARGET_ANDROID_SDK_V28='"28"'
      # Build property variable; Do not modify
      sdk_28="28"
      version_28="9.0.0"
      echo "Generating BiTGApps package for $ARCH with API level $API"
      # Create release directory
      mkdir "$BUILDDIR/$ARCH/BiTGApps-${ARCH}-9.0.0-${COMMONGAPPSRELEASE}"
      RELEASEDIR="BiTGApps-${ARCH}-9.0.0-${COMMONGAPPSRELEASE}"
      # Create package components
      mkdir -p $BUILDDIR/$ARCH/$RELEASEDIR/$METADIR
      mkdir -p $BUILDDIR/$ARCH/$RELEASEDIR/$ZIP
      mkdir -p $BUILDDIR/$ARCH/$RELEASEDIR/$CORE
      mkdir -p $BUILDDIR/$ARCH/$RELEASEDIR/$SYS
      mkdir -p $BUILDDIR/$ARCH/$RELEASEDIR/$AOSPCORE
      mkdir -p $BUILDDIR/$ARCH/$RELEASEDIR/$AOSPSYS
      # Install app packages
      cp -f $SOURCESv28/app/FaceLock.tar.xz $BUILDDIR/$ARCH/$RELEASEDIR/$SYS
      cp -f $SOURCESv28/app/GoogleCalendarSyncAdapter.tar.xz $BUILDDIR/$ARCH/$RELEASEDIR/$SYS
      cp -f $SOURCESv28/app/GoogleContactsSyncAdapter.tar.xz $BUILDDIR/$ARCH/$RELEASEDIR/$SYS
      cp -f $SOURCESv28/app/GoogleExtShared.tar.xz $BUILDDIR/$ARCH/$RELEASEDIR/$SYS
      # Install etc packages
      cp -f $SOURCESv28/etc/Default.tar.xz $BUILDDIR/$ARCH/$RELEASEDIR/$ZIP
      cp -f $SOURCESv28/etc/Permissions.tar.xz $BUILDDIR/$ARCH/$RELEASEDIR/$ZIP
      cp -f $SOURCESv28/etc/Preferred.tar.xz $BUILDDIR/$ARCH/$RELEASEDIR/$ZIP
      cp -f $SOURCESv28/etc/Sysconfig.tar.xz $BUILDDIR/$ARCH/$RELEASEDIR/$ZIP
      # Install priv-app packages
      cp -f $SOURCESv28/priv-app/ConfigUpdater.tar.xz $BUILDDIR/$ARCH/$RELEASEDIR/$CORE
      cp -f $SOURCESv28/priv-app/GoogleExtServices.tar.xz $BUILDDIR/$ARCH/$RELEASEDIR/$CORE
      cp -f $SOURCESv28/priv-app/GoogleServicesFramework.tar.xz $BUILDDIR/$ARCH/$RELEASEDIR/$CORE
      cp -f $SOURCESv28/priv-app/Phonesky.tar.xz $BUILDDIR/$ARCH/$RELEASEDIR/$CORE
      cp -f $SOURCESv28/priv-app/PrebuiltGmsCorePi.tar.xz $BUILDDIR/$ARCH/$RELEASEDIR/$CORE
      # Install AOSP packages
      cp -f $AOSPSOURCESv28/app/Messaging.tar.xz $BUILDDIR/$ARCH/$RELEASEDIR/$AOSPSYS
      cp -f $AOSPSOURCESv28/etc/Permissions.tar.xz $BUILDDIR/$ARCH/$RELEASEDIR/$AOSPZIP
      cp -f $AOSPSOURCESv28/priv-app/Contacts.tar.xz $BUILDDIR/$ARCH/$RELEASEDIR/$AOSPCORE
      cp -f $AOSPSOURCESv28/priv-app/Dialer.tar.xz $BUILDDIR/$ARCH/$RELEASEDIR/$AOSPCORE
      cp -f $AOSPSOURCESv28/priv-app/ManagedProvisioning.tar.xz $BUILDDIR/$ARCH/$RELEASEDIR/$AOSPCORE
      cp -f $AOSPSOURCESv28/priv-app/Provision.tar.xz $BUILDDIR/$ARCH/$RELEASEDIR/$AOSPCORE
      # Install SetupWizard packages
      cp -f $SETUPSOURCESv28/priv-app/GoogleBackupTransport.tar.xz $BUILDDIR/$ARCH/$RELEASEDIR/$CORE
      cp -f $SETUPSOURCESv28/priv-app/GoogleRestore.tar.xz $BUILDDIR/$ARCH/$RELEASEDIR/$CORE
      cp -f $SETUPSOURCESv28/priv-app/SetupWizardPrebuilt.tar.xz $BUILDDIR/$ARCH/$RELEASEDIR/$CORE
      # Installer components
      cp -f $UPDATEBINARY $BUILDDIR/$ARCH/$RELEASEDIR/$METADIR/update-binary
      cp -f $UPDATERSCRIPT $BUILDDIR/$ARCH/$RELEASEDIR/$METADIR/updater-script
      cp -f $INSTALLER $BUILDDIR/$ARCH/$RELEASEDIR
      cp -f $LOGCATSCRIPT $BUILDDIR/$ARCH/$RELEASEDIR
      cp -f $BUSYBOX $BUILDDIR/$ARCH/$RELEASEDIR
      cp -f $AIK $BUILDDIR/$ARCH/$RELEASEDIR/$ZIP
      cp -f $API_28_KEYSTORE $BUILDDIR/$ARCH/$RELEASEDIR/$ZIP
      # Create utility script
      makeutilityscript
      replace_line $BUILDDIR/$ARCH/$RELEASEDIR/util_functions.sh REL="" REL="$GAPPS_RELEASE"
      replace_line $BUILDDIR/$ARCH/$RELEASEDIR/util_functions.sh ZIPTYPE="" ZIPTYPE="$ZIPTYPE"
      replace_line $BUILDDIR/$ARCH/$RELEASEDIR/util_functions.sh TARGET_GAPPS_RELEASE="" TARGET_GAPPS_RELEASE="$TARGET_GAPPS_RELEASE"
      replace_line $BUILDDIR/$ARCH/$RELEASEDIR/util_functions.sh TARGET_DIRTY_INSTALL="" TARGET_DIRTY_INSTALL="$TARGET_DIRTY_INSTALL"
      replace_line $BUILDDIR/$ARCH/$RELEASEDIR/util_functions.sh TARGET_ANDROID_SDK="" TARGET_ANDROID_SDK="$TARGET_ANDROID_SDK_V28"
      replace_line $BUILDDIR/$ARCH/$RELEASEDIR/util_functions.sh TARGET_ANDROID_ARCH="" TARGET_ANDROID_ARCH="$TARGET_ANDROID_ARCH_32"
      replace_line $BUILDDIR/$ARCH/$RELEASEDIR/util_functions.sh ARMEABI="" ARMEABI="$ARMEABI"
      replace_line $BUILDDIR/$ARCH/$RELEASEDIR/util_functions.sh AARCH64="" AARCH64="$AARCH64"
      replace_line $BUILDDIR/$ARCH/$RELEASEDIR/util_functions.sh TARGET_RELEASE_TAG="" TARGET_RELEASE_TAG="$TARGET_RELEASE_TAG"
      replace_line $BUILDDIR/$ARCH/$RELEASEDIR/util_functions.sh TARGET_CONFIG_VERSION="" TARGET_CONFIG_VERSION="$TARGET_CONFIG_VERSION"
      # Create build property file
      makegprop
      replace_line $BUILDDIR/$ARCH/$RELEASEDIR/g.prop CustomGAppsPackage= CustomGAppsPackage="$CustomGAppsPackage"
      replace_line $BUILDDIR/$ARCH/$RELEASEDIR/g.prop platform= platform="$platform_32"
      replace_line $BUILDDIR/$ARCH/$RELEASEDIR/g.prop sdk= sdk="$sdk_28"
      replace_line $BUILDDIR/$ARCH/$RELEASEDIR/g.prop version= version="$version_28"
      replace_line $BUILDDIR/$ARCH/$RELEASEDIR/g.prop BuildDate= BuildDate="$BuildDate"
      replace_line $BUILDDIR/$ARCH/$RELEASEDIR/g.prop BuildID= BuildID="$BuildID"
      replace_line $BUILDDIR/$ARCH/$RELEASEDIR/g.prop Developer= Developer="$Developer"
      # Add OTA script
      makeota
      # Create OTA property file
      makeotaprop
      # Create LICENSE
      makelicense
      # Create ZIP
      cd $BUILDDIR/$ARCH/$RELEASEDIR
      zip -qr9 ${RELEASEDIR}.zip *
      cd ../../..
      mv $BUILDDIR/$ARCH/$RELEASEDIR/${RELEASEDIR}.zip $OUTDIR/$ARCH/${RELEASEDIR}.zip
      # Sign ZIP
      java -jar $ZIPSIGNER $OUTDIR/$ARCH/${RELEASEDIR}.zip $OUTDIR/$ARCH/${RELEASEDIR}_signed.zip 2>/dev/null
      # Set build API in global environment
      [ "$(grep -w -o TARGET_API_28 $OUTDIR/ENV/env_api.sh 2>/dev/null)" ] || echo "TARGET_API_28" >> $OUTDIR/ENV/env_api.sh
      # List signed ZIP
      ls $OUTDIR/$ARCH/${RELEASEDIR}_signed.zip
      # Wipe unsigned ZIP
      rm -rf $OUTDIR/$ARCH/${RELEASEDIR}.zip
    fi
    # API 29
    if [ "$API" == "29" ]; then
      # Install variable; Do not modify
      TARGET_ANDROID_SDK_V29='"29"'
      # Build property variable; Do not modify
      sdk_29="29"
      version_29="10.0.0"
      echo "Generating BiTGApps package for $ARCH with API level $API"
      # Create release directory
      mkdir "$BUILDDIR/$ARCH/BiTGApps-${ARCH}-10.0.0-${COMMONGAPPSRELEASE}"
      RELEASEDIR="BiTGApps-${ARCH}-10.0.0-${COMMONGAPPSRELEASE}"
      # Create package components
      mkdir -p $BUILDDIR/$ARCH/$RELEASEDIR/$METADIR
      mkdir -p $BUILDDIR/$ARCH/$RELEASEDIR/$ZIP
      mkdir -p $BUILDDIR/$ARCH/$RELEASEDIR/$CORE
      mkdir -p $BUILDDIR/$ARCH/$RELEASEDIR/$SYS
      mkdir -p $BUILDDIR/$ARCH/$RELEASEDIR/$AOSPCORE
      mkdir -p $BUILDDIR/$ARCH/$RELEASEDIR/$AOSPSYS
      # Install app packages
      cp -f $SOURCESv29/app/GoogleCalendarSyncAdapter.tar.xz $BUILDDIR/$ARCH/$RELEASEDIR/$SYS
      cp -f $SOURCESv29/app/GoogleContactsSyncAdapter.tar.xz $BUILDDIR/$ARCH/$RELEASEDIR/$SYS
      cp -f $SOURCESv29/app/GoogleExtShared.tar.xz $BUILDDIR/$ARCH/$RELEASEDIR/$SYS
      # Install etc packages
      cp -f $SOURCESv29/etc/Default.tar.xz $BUILDDIR/$ARCH/$RELEASEDIR/$ZIP
      cp -f $SOURCESv29/etc/Permissions.tar.xz $BUILDDIR/$ARCH/$RELEASEDIR/$ZIP
      cp -f $SOURCESv29/etc/Preferred.tar.xz $BUILDDIR/$ARCH/$RELEASEDIR/$ZIP
      cp -f $SOURCESv29/etc/Sysconfig.tar.xz $BUILDDIR/$ARCH/$RELEASEDIR/$ZIP
      # Install priv-app packages
      cp -f $SOURCESv29/priv-app/ConfigUpdater.tar.xz $BUILDDIR/$ARCH/$RELEASEDIR/$CORE
      cp -f $SOURCESv29/priv-app/GoogleExtServices.tar.xz $BUILDDIR/$ARCH/$RELEASEDIR/$CORE
      cp -f $SOURCESv29/priv-app/GoogleServicesFramework.tar.xz $BUILDDIR/$ARCH/$RELEASEDIR/$CORE
      cp -f $SOURCESv29/priv-app/Phonesky.tar.xz $BUILDDIR/$ARCH/$RELEASEDIR/$CORE
      cp -f $SOURCESv29/priv-app/PrebuiltGmsCoreQt.tar.xz $BUILDDIR/$ARCH/$RELEASEDIR/$CORE
      # Install AOSP packages
      cp -f $AOSPSOURCESv29/app/Messaging.tar.xz $BUILDDIR/$ARCH/$RELEASEDIR/$AOSPSYS
      cp -f $AOSPSOURCESv29/etc/Permissions.tar.xz $BUILDDIR/$ARCH/$RELEASEDIR/$AOSPZIP
      cp -f $AOSPSOURCESv29/priv-app/Contacts.tar.xz $BUILDDIR/$ARCH/$RELEASEDIR/$AOSPCORE
      cp -f $AOSPSOURCESv29/priv-app/Dialer.tar.xz $BUILDDIR/$ARCH/$RELEASEDIR/$AOSPCORE
      cp -f $AOSPSOURCESv29/priv-app/ManagedProvisioning.tar.xz $BUILDDIR/$ARCH/$RELEASEDIR/$AOSPCORE
      cp -f $AOSPSOURCESv29/priv-app/Provision.tar.xz $BUILDDIR/$ARCH/$RELEASEDIR/$AOSPCORE
      # Install SetupWizard packages
      cp -f $SETUPSOURCESv29/priv-app/GoogleRestore.tar.xz $BUILDDIR/$ARCH/$RELEASEDIR/$CORE
      cp -f $SETUPSOURCESv29/priv-app/SetupWizardPrebuilt.tar.xz $BUILDDIR/$ARCH/$RELEASEDIR/$CORE
      # Installer components
      cp -f $UPDATEBINARY $BUILDDIR/$ARCH/$RELEASEDIR/$METADIR/update-binary
      cp -f $UPDATERSCRIPT $BUILDDIR/$ARCH/$RELEASEDIR/$METADIR/updater-script
      cp -f $INSTALLER $BUILDDIR/$ARCH/$RELEASEDIR
      cp -f $LOGCATSCRIPT $BUILDDIR/$ARCH/$RELEASEDIR
      cp -f $BUSYBOX $BUILDDIR/$ARCH/$RELEASEDIR
      cp -f $AIK $BUILDDIR/$ARCH/$RELEASEDIR/$ZIP
      cp -f $API_29_KEYSTORE $BUILDDIR/$ARCH/$RELEASEDIR/$ZIP
      # Create utility script
      makeutilityscript
      replace_line $BUILDDIR/$ARCH/$RELEASEDIR/util_functions.sh REL="" REL="$GAPPS_RELEASE"
      replace_line $BUILDDIR/$ARCH/$RELEASEDIR/util_functions.sh ZIPTYPE="" ZIPTYPE="$ZIPTYPE"
      replace_line $BUILDDIR/$ARCH/$RELEASEDIR/util_functions.sh TARGET_GAPPS_RELEASE="" TARGET_GAPPS_RELEASE="$TARGET_GAPPS_RELEASE"
      replace_line $BUILDDIR/$ARCH/$RELEASEDIR/util_functions.sh TARGET_DIRTY_INSTALL="" TARGET_DIRTY_INSTALL="$TARGET_DIRTY_INSTALL"
      replace_line $BUILDDIR/$ARCH/$RELEASEDIR/util_functions.sh TARGET_ANDROID_SDK="" TARGET_ANDROID_SDK="$TARGET_ANDROID_SDK_V29"
      replace_line $BUILDDIR/$ARCH/$RELEASEDIR/util_functions.sh TARGET_ANDROID_ARCH="" TARGET_ANDROID_ARCH="$TARGET_ANDROID_ARCH_32"
      replace_line $BUILDDIR/$ARCH/$RELEASEDIR/util_functions.sh ARMEABI="" ARMEABI="$ARMEABI"
      replace_line $BUILDDIR/$ARCH/$RELEASEDIR/util_functions.sh AARCH64="" AARCH64="$AARCH64"
      replace_line $BUILDDIR/$ARCH/$RELEASEDIR/util_functions.sh TARGET_RELEASE_TAG="" TARGET_RELEASE_TAG="$TARGET_RELEASE_TAG"
      replace_line $BUILDDIR/$ARCH/$RELEASEDIR/util_functions.sh TARGET_CONFIG_VERSION="" TARGET_CONFIG_VERSION="$TARGET_CONFIG_VERSION"
      # Create build property file
      makegprop
      replace_line $BUILDDIR/$ARCH/$RELEASEDIR/g.prop CustomGAppsPackage= CustomGAppsPackage="$CustomGAppsPackage"
      replace_line $BUILDDIR/$ARCH/$RELEASEDIR/g.prop platform= platform="$platform_32"
      replace_line $BUILDDIR/$ARCH/$RELEASEDIR/g.prop sdk= sdk="$sdk_29"
      replace_line $BUILDDIR/$ARCH/$RELEASEDIR/g.prop version= version="$version_29"
      replace_line $BUILDDIR/$ARCH/$RELEASEDIR/g.prop BuildDate= BuildDate="$BuildDate"
      replace_line $BUILDDIR/$ARCH/$RELEASEDIR/g.prop BuildID= BuildID="$BuildID"
      replace_line $BUILDDIR/$ARCH/$RELEASEDIR/g.prop Developer= Developer="$Developer"
      # Add OTA script
      makeota
      # Create OTA property file
      makeotaprop
      # Create LICENSE
      makelicense
      # Create ZIP
      cd $BUILDDIR/$ARCH/$RELEASEDIR
      zip -qr9 ${RELEASEDIR}.zip *
      cd ../../..
      mv $BUILDDIR/$ARCH/$RELEASEDIR/${RELEASEDIR}.zip $OUTDIR/$ARCH/${RELEASEDIR}.zip
      # Sign ZIP
      java -jar $ZIPSIGNER $OUTDIR/$ARCH/${RELEASEDIR}.zip $OUTDIR/$ARCH/${RELEASEDIR}_signed.zip 2>/dev/null
      # Set build API in global environment
      [ "$(grep -w -o TARGET_API_29 $OUTDIR/ENV/env_api.sh 2>/dev/null)" ] || echo "TARGET_API_29" >> $OUTDIR/ENV/env_api.sh
      # List signed ZIP
      ls $OUTDIR/$ARCH/${RELEASEDIR}_signed.zip
      # Wipe unsigned ZIP
      rm -rf $OUTDIR/$ARCH/${RELEASEDIR}.zip
    fi
    # API 30
    if [ "$API" == "30" ]; then
      # Install variable; Do not modify
      TARGET_ANDROID_SDK_V30='"30"'
      # Build property variable; Do not modify
      sdk_30="30"
      version_30="11.0.0"
      echo "Generating BiTGApps package for $ARCH with API level $API"
      # Create release directory
      mkdir "$BUILDDIR/$ARCH/BiTGApps-${ARCH}-11.0.0-${COMMONGAPPSRELEASE}"
      RELEASEDIR="BiTGApps-${ARCH}-11.0.0-${COMMONGAPPSRELEASE}"
      # Create package components
      mkdir -p $BUILDDIR/$ARCH/$RELEASEDIR/$METADIR
      mkdir -p $BUILDDIR/$ARCH/$RELEASEDIR/$ZIP
      mkdir -p $BUILDDIR/$ARCH/$RELEASEDIR/$CORE
      mkdir -p $BUILDDIR/$ARCH/$RELEASEDIR/$SYS
      mkdir -p $BUILDDIR/$ARCH/$RELEASEDIR/$AOSPCORE
      mkdir -p $BUILDDIR/$ARCH/$RELEASEDIR/$AOSPSYS
      mkdir -p $BUILDDIR/$ARCH/$RELEASEDIR/$OVERLAY
      # Install app packages
      cp -f $SOURCESv30/app/GoogleCalendarSyncAdapter.tar.xz $BUILDDIR/$ARCH/$RELEASEDIR/$SYS
      cp -f $SOURCESv30/app/GoogleContactsSyncAdapter.tar.xz $BUILDDIR/$ARCH/$RELEASEDIR/$SYS
      cp -f $SOURCESv30/app/GoogleExtShared.tar.xz $BUILDDIR/$ARCH/$RELEASEDIR/$SYS
      # Install etc packages
      cp -f $SOURCESv30/etc/Default.tar.xz $BUILDDIR/$ARCH/$RELEASEDIR/$ZIP
      cp -f $SOURCESv30/etc/Permissions.tar.xz $BUILDDIR/$ARCH/$RELEASEDIR/$ZIP
      cp -f $SOURCESv30/etc/Preferred.tar.xz $BUILDDIR/$ARCH/$RELEASEDIR/$ZIP
      cp -f $SOURCESv30/etc/Sysconfig.tar.xz $BUILDDIR/$ARCH/$RELEASEDIR/$ZIP
      # Install overlay package
      cp -f $SOURCESv30/overlay/PlayStoreOverlay.tar.xz $BUILDDIR/$ARCH/$RELEASEDIR/$OVERLAY
      # Install priv-app packages
      cp -f $SOURCESv30/priv-app/ConfigUpdater.tar.xz $BUILDDIR/$ARCH/$RELEASEDIR/$CORE
      cp -f $SOURCESv30/priv-app/GoogleExtServices.tar.xz $BUILDDIR/$ARCH/$RELEASEDIR/$CORE
      cp -f $SOURCESv30/priv-app/GoogleServicesFramework.tar.xz $BUILDDIR/$ARCH/$RELEASEDIR/$CORE
      cp -f $SOURCESv30/priv-app/Phonesky.tar.xz $BUILDDIR/$ARCH/$RELEASEDIR/$CORE
      cp -f $SOURCESv30/priv-app/PrebuiltGmsCoreRvc.tar.xz $BUILDDIR/$ARCH/$RELEASEDIR/$CORE
      # Install AOSP packages
      cp -f $AOSPSOURCESv30/app/Messaging.tar.xz $BUILDDIR/$ARCH/$RELEASEDIR/$AOSPSYS
      cp -f $AOSPSOURCESv30/etc/Permissions.tar.xz $BUILDDIR/$ARCH/$RELEASEDIR/$AOSPZIP
      cp -f $AOSPSOURCESv30/priv-app/Contacts.tar.xz $BUILDDIR/$ARCH/$RELEASEDIR/$AOSPCORE
      cp -f $AOSPSOURCESv30/priv-app/Dialer.tar.xz $BUILDDIR/$ARCH/$RELEASEDIR/$AOSPCORE
      cp -f $AOSPSOURCESv30/priv-app/ManagedProvisioning.tar.xz $BUILDDIR/$ARCH/$RELEASEDIR/$AOSPCORE
      cp -f $AOSPSOURCESv30/priv-app/Provision.tar.xz $BUILDDIR/$ARCH/$RELEASEDIR/$AOSPCORE
      # Install SetupWizard packages
      cp -f $SETUPSOURCESv30/priv-app/AndroidMigratePrebuilt.tar.xz $BUILDDIR/$ARCH/$RELEASEDIR/$CORE
      cp -f $SETUPSOURCESv30/priv-app/SetupWizardPrebuilt.tar.xz $BUILDDIR/$ARCH/$RELEASEDIR/$CORE
      # Installer components
      cp -f $UPDATEBINARY $BUILDDIR/$ARCH/$RELEASEDIR/$METADIR/update-binary
      cp -f $UPDATERSCRIPT $BUILDDIR/$ARCH/$RELEASEDIR/$METADIR/updater-script
      cp -f $INSTALLER $BUILDDIR/$ARCH/$RELEASEDIR
      cp -f $LOGCATSCRIPT $BUILDDIR/$ARCH/$RELEASEDIR
      cp -f $BUSYBOX $BUILDDIR/$ARCH/$RELEASEDIR
      cp -f $AIK $BUILDDIR/$ARCH/$RELEASEDIR/$ZIP
      cp -f $API_30_KEYSTORE $BUILDDIR/$ARCH/$RELEASEDIR/$ZIP
      # Create utility script
      makeutilityscript
      replace_line $BUILDDIR/$ARCH/$RELEASEDIR/util_functions.sh REL="" REL="$GAPPS_RELEASE"
      replace_line $BUILDDIR/$ARCH/$RELEASEDIR/util_functions.sh ZIPTYPE="" ZIPTYPE="$ZIPTYPE"
      replace_line $BUILDDIR/$ARCH/$RELEASEDIR/util_functions.sh TARGET_GAPPS_RELEASE="" TARGET_GAPPS_RELEASE="$TARGET_GAPPS_RELEASE"
      replace_line $BUILDDIR/$ARCH/$RELEASEDIR/util_functions.sh TARGET_DIRTY_INSTALL="" TARGET_DIRTY_INSTALL="$TARGET_DIRTY_INSTALL"
      replace_line $BUILDDIR/$ARCH/$RELEASEDIR/util_functions.sh TARGET_ANDROID_SDK="" TARGET_ANDROID_SDK="$TARGET_ANDROID_SDK_V30"
      replace_line $BUILDDIR/$ARCH/$RELEASEDIR/util_functions.sh TARGET_ANDROID_ARCH="" TARGET_ANDROID_ARCH="$TARGET_ANDROID_ARCH_32"
      replace_line $BUILDDIR/$ARCH/$RELEASEDIR/util_functions.sh ARMEABI="" ARMEABI="$ARMEABI"
      replace_line $BUILDDIR/$ARCH/$RELEASEDIR/util_functions.sh AARCH64="" AARCH64="$AARCH64"
      replace_line $BUILDDIR/$ARCH/$RELEASEDIR/util_functions.sh TARGET_RELEASE_TAG="" TARGET_RELEASE_TAG="$TARGET_RELEASE_TAG"
      replace_line $BUILDDIR/$ARCH/$RELEASEDIR/util_functions.sh TARGET_CONFIG_VERSION="" TARGET_CONFIG_VERSION="$TARGET_CONFIG_VERSION"
      # Create build property file
      makegprop
      replace_line $BUILDDIR/$ARCH/$RELEASEDIR/g.prop CustomGAppsPackage= CustomGAppsPackage="$CustomGAppsPackage"
      replace_line $BUILDDIR/$ARCH/$RELEASEDIR/g.prop platform= platform="$platform_32"
      replace_line $BUILDDIR/$ARCH/$RELEASEDIR/g.prop sdk= sdk="$sdk_30"
      replace_line $BUILDDIR/$ARCH/$RELEASEDIR/g.prop version= version="$version_30"
      replace_line $BUILDDIR/$ARCH/$RELEASEDIR/g.prop BuildDate= BuildDate="$BuildDate"
      replace_line $BUILDDIR/$ARCH/$RELEASEDIR/g.prop BuildID= BuildID="$BuildID"
      replace_line $BUILDDIR/$ARCH/$RELEASEDIR/g.prop Developer= Developer="$Developer"
      # Add OTA script
      makeota
      # Create OTA property file
      makeotaprop
      # Create LICENSE
      makelicense
      # Create ZIP
      cd $BUILDDIR/$ARCH/$RELEASEDIR
      zip -qr9 ${RELEASEDIR}.zip *
      cd ../../..
      mv $BUILDDIR/$ARCH/$RELEASEDIR/${RELEASEDIR}.zip $OUTDIR/$ARCH/${RELEASEDIR}.zip
      # Sign ZIP
      java -jar $ZIPSIGNER $OUTDIR/$ARCH/${RELEASEDIR}.zip $OUTDIR/$ARCH/${RELEASEDIR}_signed.zip 2>/dev/null
      # Set build API in global environment
      [ "$(grep -w -o TARGET_API_30 $OUTDIR/ENV/env_api.sh 2>/dev/null)" ] || echo "TARGET_API_30" >> $OUTDIR/ENV/env_api.sh
      # List signed ZIP
      ls $OUTDIR/$ARCH/${RELEASEDIR}_signed.zip
      # Wipe unsigned ZIP
      rm -rf $OUTDIR/$ARCH/${RELEASEDIR}.zip
    fi
    # API 31
    if [ "$API" == "31" ]; then
      # Install variable; Do not modify
      TARGET_ANDROID_SDK_V31='"31"'
      # Build property variable; Do not modify
      sdk_31="31"
      version_31="12.0.0"
      echo "Generating BiTGApps package for $ARCH with API level $API"
      # Create release directory
      mkdir "$BUILDDIR/$ARCH/BiTGApps-${ARCH}-12.0.0-${COMMONGAPPSRELEASE}"
      RELEASEDIR="BiTGApps-${ARCH}-12.0.0-${COMMONGAPPSRELEASE}"
      # Create package components
      mkdir -p $BUILDDIR/$ARCH/$RELEASEDIR/$METADIR
      mkdir -p $BUILDDIR/$ARCH/$RELEASEDIR/$ZIP
      mkdir -p $BUILDDIR/$ARCH/$RELEASEDIR/$CORE
      mkdir -p $BUILDDIR/$ARCH/$RELEASEDIR/$SYS
      mkdir -p $BUILDDIR/$ARCH/$RELEASEDIR/$AOSPCORE
      mkdir -p $BUILDDIR/$ARCH/$RELEASEDIR/$AOSPSYS
      mkdir -p $BUILDDIR/$ARCH/$RELEASEDIR/$OVERLAY
      # Install app packages
      cp -f $SOURCESv31/app/GoogleCalendarSyncAdapter.tar.xz $BUILDDIR/$ARCH/$RELEASEDIR/$SYS
      cp -f $SOURCESv31/app/GoogleContactsSyncAdapter.tar.xz $BUILDDIR/$ARCH/$RELEASEDIR/$SYS
      cp -f $SOURCESv31/app/GoogleExtShared.tar.xz $BUILDDIR/$ARCH/$RELEASEDIR/$SYS
      # Install etc packages
      cp -f $SOURCESv31/etc/Default.tar.xz $BUILDDIR/$ARCH/$RELEASEDIR/$ZIP
      cp -f $SOURCESv31/etc/Permissions.tar.xz $BUILDDIR/$ARCH/$RELEASEDIR/$ZIP
      cp -f $SOURCESv31/etc/Preferred.tar.xz $BUILDDIR/$ARCH/$RELEASEDIR/$ZIP
      cp -f $SOURCESv31/etc/Sysconfig.tar.xz $BUILDDIR/$ARCH/$RELEASEDIR/$ZIP
      # Install overlay package
      cp -f $SOURCESv31/overlay/PlayStoreOverlay.tar.xz $BUILDDIR/$ARCH/$RELEASEDIR/$OVERLAY
      # Install priv-app packages
      cp -f $SOURCESv31/priv-app/ConfigUpdater.tar.xz $BUILDDIR/$ARCH/$RELEASEDIR/$CORE
      cp -f $SOURCESv31/priv-app/GoogleExtServices.tar.xz $BUILDDIR/$ARCH/$RELEASEDIR/$CORE
      cp -f $SOURCESv31/priv-app/GoogleServicesFramework.tar.xz $BUILDDIR/$ARCH/$RELEASEDIR/$CORE
      cp -f $SOURCESv31/priv-app/Phonesky.tar.xz $BUILDDIR/$ARCH/$RELEASEDIR/$CORE
      cp -f $SOURCESv31/priv-app/PrebuiltGmsCoreSvc.tar.xz $BUILDDIR/$ARCH/$RELEASEDIR/$CORE
      # Install AOSP packages
      cp -f $AOSPSOURCESv31/app/Messaging.tar.xz $BUILDDIR/$ARCH/$RELEASEDIR/$AOSPSYS
      cp -f $AOSPSOURCESv31/etc/Permissions.tar.xz $BUILDDIR/$ARCH/$RELEASEDIR/$AOSPZIP
      cp -f $AOSPSOURCESv31/priv-app/Contacts.tar.xz $BUILDDIR/$ARCH/$RELEASEDIR/$AOSPCORE
      cp -f $AOSPSOURCESv31/priv-app/Dialer.tar.xz $BUILDDIR/$ARCH/$RELEASEDIR/$AOSPCORE
      cp -f $AOSPSOURCESv31/priv-app/ManagedProvisioning.tar.xz $BUILDDIR/$ARCH/$RELEASEDIR/$AOSPCORE
      cp -f $AOSPSOURCESv31/priv-app/Provision.tar.xz $BUILDDIR/$ARCH/$RELEASEDIR/$AOSPCORE
      # Install SetupWizard packages
      cp -f $SETUPSOURCESv31/priv-app/AndroidMigratePrebuilt.tar.xz $BUILDDIR/$ARCH/$RELEASEDIR/$CORE
      cp -f $SETUPSOURCESv31/priv-app/SetupWizardPrebuilt.tar.xz $BUILDDIR/$ARCH/$RELEASEDIR/$CORE
      # Installer components
      cp -f $UPDATEBINARY $BUILDDIR/$ARCH/$RELEASEDIR/$METADIR/update-binary
      cp -f $UPDATERSCRIPT $BUILDDIR/$ARCH/$RELEASEDIR/$METADIR/updater-script
      cp -f $INSTALLER $BUILDDIR/$ARCH/$RELEASEDIR
      cp -f $LOGCATSCRIPT $BUILDDIR/$ARCH/$RELEASEDIR
      cp -f $BUSYBOX $BUILDDIR/$ARCH/$RELEASEDIR
      cp -f $AIK $BUILDDIR/$ARCH/$RELEASEDIR/$ZIP
      cp -f $API_31_KEYSTORE $BUILDDIR/$ARCH/$RELEASEDIR/$ZIP
      # Create utility script
      makeutilityscript
      replace_line $BUILDDIR/$ARCH/$RELEASEDIR/util_functions.sh REL="" REL="$GAPPS_RELEASE"
      replace_line $BUILDDIR/$ARCH/$RELEASEDIR/util_functions.sh ZIPTYPE="" ZIPTYPE="$ZIPTYPE"
      replace_line $BUILDDIR/$ARCH/$RELEASEDIR/util_functions.sh TARGET_GAPPS_RELEASE="" TARGET_GAPPS_RELEASE="$TARGET_GAPPS_RELEASE"
      replace_line $BUILDDIR/$ARCH/$RELEASEDIR/util_functions.sh TARGET_DIRTY_INSTALL="" TARGET_DIRTY_INSTALL="$TARGET_DIRTY_INSTALL"
      replace_line $BUILDDIR/$ARCH/$RELEASEDIR/util_functions.sh TARGET_ANDROID_SDK="" TARGET_ANDROID_SDK="$TARGET_ANDROID_SDK_V31"
      replace_line $BUILDDIR/$ARCH/$RELEASEDIR/util_functions.sh TARGET_ANDROID_ARCH="" TARGET_ANDROID_ARCH="$TARGET_ANDROID_ARCH_32"
      replace_line $BUILDDIR/$ARCH/$RELEASEDIR/util_functions.sh ARMEABI="" ARMEABI="$ARMEABI"
      replace_line $BUILDDIR/$ARCH/$RELEASEDIR/util_functions.sh AARCH64="" AARCH64="$AARCH64"
      replace_line $BUILDDIR/$ARCH/$RELEASEDIR/util_functions.sh TARGET_RELEASE_TAG="" TARGET_RELEASE_TAG="$TARGET_RELEASE_TAG"
      replace_line $BUILDDIR/$ARCH/$RELEASEDIR/util_functions.sh TARGET_CONFIG_VERSION="" TARGET_CONFIG_VERSION="$TARGET_CONFIG_VERSION"
      # Create build property file
      makegprop
      replace_line $BUILDDIR/$ARCH/$RELEASEDIR/g.prop CustomGAppsPackage= CustomGAppsPackage="$CustomGAppsPackage"
      replace_line $BUILDDIR/$ARCH/$RELEASEDIR/g.prop platform= platform="$platform_32"
      replace_line $BUILDDIR/$ARCH/$RELEASEDIR/g.prop sdk= sdk="$sdk_31"
      replace_line $BUILDDIR/$ARCH/$RELEASEDIR/g.prop version= version="$version_31"
      replace_line $BUILDDIR/$ARCH/$RELEASEDIR/g.prop BuildDate= BuildDate="$BuildDate"
      replace_line $BUILDDIR/$ARCH/$RELEASEDIR/g.prop BuildID= BuildID="$BuildID"
      replace_line $BUILDDIR/$ARCH/$RELEASEDIR/g.prop Developer= Developer="$Developer"
      # Add OTA script
      makeota
      # Create OTA property file
      makeotaprop
      # Create LICENSE
      makelicense
      # Create ZIP
      cd $BUILDDIR/$ARCH/$RELEASEDIR
      zip -qr9 ${RELEASEDIR}.zip *
      cd ../../..
      mv $BUILDDIR/$ARCH/$RELEASEDIR/${RELEASEDIR}.zip $OUTDIR/$ARCH/${RELEASEDIR}.zip
      # Sign ZIP
      java -jar $ZIPSIGNER $OUTDIR/$ARCH/${RELEASEDIR}.zip $OUTDIR/$ARCH/${RELEASEDIR}_signed.zip 2>/dev/null
      # Set build API in global environment
      [ "$(grep -w -o TARGET_API_31 $OUTDIR/ENV/env_api.sh 2>/dev/null)" ] || echo "TARGET_API_31" >> $OUTDIR/ENV/env_api.sh
      # List signed ZIP
      ls $OUTDIR/$ARCH/${RELEASEDIR}_signed.zip
      # Wipe unsigned ZIP
      rm -rf $OUTDIR/$ARCH/${RELEASEDIR}.zip
    fi
  fi
  # Platform ARM64
  if [ "$ARCH" == "arm64" ]; then
    # Install variable; Do not modify
    TARGET_ANDROID_ARCH_64='"ARM64"'
    ARMEABI='"false"'
    AARCH64='"true"'
    # Build property variable; Do not modify
    CustomGAppsPackage="BiTGApps"
    platform_64="arm64"
    # API 25
    if [ "$API" == "25" ]; then
      # Install variable; Do not modify
      TARGET_ANDROID_SDK_V25='"25"'
      # Build property variable; Do not modify
      sdk_25="25"
      version_25="7.1.1"
      echo "Generating BiTGApps package for $ARCH with API level $API"
      # Create release directory
      mkdir "$BUILDDIR/$ARCH/BiTGApps-${ARCH}-7.1.1-${COMMONGAPPSRELEASE}"
      RELEASEDIR="BiTGApps-${ARCH}-7.1.1-${COMMONGAPPSRELEASE}"
      # Create package components
      mkdir -p $BUILDDIR/$ARCH/$RELEASEDIR/$METADIR
      mkdir -p $BUILDDIR/$ARCH/$RELEASEDIR/$ZIP
      mkdir -p $BUILDDIR/$ARCH/$RELEASEDIR/$CORE
      mkdir -p $BUILDDIR/$ARCH/$RELEASEDIR/$SYS
      mkdir -p $BUILDDIR/$ARCH/$RELEASEDIR/$AOSPCORE
      mkdir -p $BUILDDIR/$ARCH/$RELEASEDIR/$AOSPSYS
      # Install app packages
      cp -f $SOURCESv25/$version_25/app/FaceLock.tar.xz $BUILDDIR/$ARCH/$RELEASEDIR/$SYS
      cp -f $SOURCESv25/$version_25/app/GoogleCalendarSyncAdapter.tar.xz $BUILDDIR/$ARCH/$RELEASEDIR/$SYS
      cp -f $SOURCESv25/$version_25/app/GoogleContactsSyncAdapter.tar.xz $BUILDDIR/$ARCH/$RELEASEDIR/$SYS
      cp -f $SOURCESv25/$version_25/app/GoogleExtShared.tar.xz $BUILDDIR/$ARCH/$RELEASEDIR/$SYS
      # Install etc packages
      cp -f $SOURCESv25/$version_25/etc/Default.tar.xz $BUILDDIR/$ARCH/$RELEASEDIR/$ZIP
      cp -f $SOURCESv25/$version_25/etc/Permissions.tar.xz $BUILDDIR/$ARCH/$RELEASEDIR/$ZIP
      cp -f $SOURCESv25/$version_25/etc/Preferred.tar.xz $BUILDDIR/$ARCH/$RELEASEDIR/$ZIP
      cp -f $SOURCESv25/$version_25/etc/Sysconfig.tar.xz $BUILDDIR/$ARCH/$RELEASEDIR/$ZIP
      # Install priv-app packages
      cp -f $SOURCESv25/$version_25/priv-app/ConfigUpdater.tar.xz $BUILDDIR/$ARCH/$RELEASEDIR/$CORE
      cp -f $SOURCESv25/$version_25/priv-app/GmsCoreSetupPrebuilt.tar.xz $BUILDDIR/$ARCH/$RELEASEDIR/$CORE
      cp -f $SOURCESv25/$version_25/priv-app/GoogleExtServices.tar.xz $BUILDDIR/$ARCH/$RELEASEDIR/$CORE
      cp -f $SOURCESv25/$version_25/priv-app/GoogleLoginService.tar.xz $BUILDDIR/$ARCH/$RELEASEDIR/$CORE
      cp -f $SOURCESv25/$version_25/priv-app/GoogleServicesFramework.tar.xz $BUILDDIR/$ARCH/$RELEASEDIR/$CORE
      cp -f $SOURCESv25/$version_25/priv-app/Phonesky.tar.xz $BUILDDIR/$ARCH/$RELEASEDIR/$CORE
      cp -f $SOURCESv25/$version_25/priv-app/PrebuiltGmsCore.tar.xz $BUILDDIR/$ARCH/$RELEASEDIR/$CORE
      # Install AOSP packages
      cp -f $AOSPSOURCESv25/$version_25/app/Messaging.tar.xz $BUILDDIR/$ARCH/$RELEASEDIR/$AOSPSYS
      cp -f $AOSPSOURCESv25/$version_25/etc/Permissions.tar.xz $BUILDDIR/$ARCH/$RELEASEDIR/$AOSPZIP
      cp -f $AOSPSOURCESv25/$version_25/priv-app/Contacts.tar.xz $BUILDDIR/$ARCH/$RELEASEDIR/$AOSPCORE
      cp -f $AOSPSOURCESv25/$version_25/priv-app/Dialer.tar.xz $BUILDDIR/$ARCH/$RELEASEDIR/$AOSPCORE
      cp -f $AOSPSOURCESv25/$version_25/priv-app/ManagedProvisioning.tar.xz $BUILDDIR/$ARCH/$RELEASEDIR/$AOSPCORE
      cp -f $AOSPSOURCESv25/$version_25/priv-app/Provision.tar.xz $BUILDDIR/$ARCH/$RELEASEDIR/$AOSPCORE
      # Install SetupWizard packages
      cp -f $SETUPSOURCESv25/$version_25/priv-app/GoogleBackupTransport.tar.xz $BUILDDIR/$ARCH/$RELEASEDIR/$CORE
      cp -f $SETUPSOURCESv25/$version_25/priv-app/SetupWizardPrebuilt.tar.xz $BUILDDIR/$ARCH/$RELEASEDIR/$CORE
      # Installer components
      cp -f $UPDATEBINARY $BUILDDIR/$ARCH/$RELEASEDIR/$METADIR/update-binary
      cp -f $UPDATERSCRIPT $BUILDDIR/$ARCH/$RELEASEDIR/$METADIR/updater-script
      cp -f $INSTALLER $BUILDDIR/$ARCH/$RELEASEDIR
      cp -f $LOGCATSCRIPT $BUILDDIR/$ARCH/$RELEASEDIR
      cp -f $BUSYBOX $BUILDDIR/$ARCH/$RELEASEDIR
      cp -f $AIK $BUILDDIR/$ARCH/$RELEASEDIR/$ZIP
      # Create utility script
      makeutilityscript
      replace_line $BUILDDIR/$ARCH/$RELEASEDIR/util_functions.sh REL="" REL="$GAPPS_RELEASE"
      replace_line $BUILDDIR/$ARCH/$RELEASEDIR/util_functions.sh ZIPTYPE="" ZIPTYPE="$ZIPTYPE"
      replace_line $BUILDDIR/$ARCH/$RELEASEDIR/util_functions.sh TARGET_GAPPS_RELEASE="" TARGET_GAPPS_RELEASE="$TARGET_GAPPS_RELEASE"
      replace_line $BUILDDIR/$ARCH/$RELEASEDIR/util_functions.sh TARGET_DIRTY_INSTALL="" TARGET_DIRTY_INSTALL="$TARGET_DIRTY_INSTALL"
      replace_line $BUILDDIR/$ARCH/$RELEASEDIR/util_functions.sh TARGET_ANDROID_SDK="" TARGET_ANDROID_SDK="$TARGET_ANDROID_SDK_V25"
      replace_line $BUILDDIR/$ARCH/$RELEASEDIR/util_functions.sh TARGET_ANDROID_ARCH="" TARGET_ANDROID_ARCH="$TARGET_ANDROID_ARCH_64"
      replace_line $BUILDDIR/$ARCH/$RELEASEDIR/util_functions.sh ARMEABI="" ARMEABI="$ARMEABI"
      replace_line $BUILDDIR/$ARCH/$RELEASEDIR/util_functions.sh AARCH64="" AARCH64="$AARCH64"
      replace_line $BUILDDIR/$ARCH/$RELEASEDIR/util_functions.sh TARGET_RELEASE_TAG="" TARGET_RELEASE_TAG="$TARGET_RELEASE_TAG"
      replace_line $BUILDDIR/$ARCH/$RELEASEDIR/util_functions.sh TARGET_CONFIG_VERSION="" TARGET_CONFIG_VERSION="$TARGET_CONFIG_VERSION"
      # Create build property file
      makegprop
      replace_line $BUILDDIR/$ARCH/$RELEASEDIR/g.prop CustomGAppsPackage= CustomGAppsPackage="$CustomGAppsPackage"
      replace_line $BUILDDIR/$ARCH/$RELEASEDIR/g.prop platform= platform="$platform_64"
      replace_line $BUILDDIR/$ARCH/$RELEASEDIR/g.prop sdk= sdk="$sdk_25"
      replace_line $BUILDDIR/$ARCH/$RELEASEDIR/g.prop version= version="$version_25"
      replace_line $BUILDDIR/$ARCH/$RELEASEDIR/g.prop BuildDate= BuildDate="$BuildDate"
      replace_line $BUILDDIR/$ARCH/$RELEASEDIR/g.prop BuildID= BuildID="$BuildID"
      replace_line $BUILDDIR/$ARCH/$RELEASEDIR/g.prop Developer= Developer="$Developer"
      # Add OTA script
      makeota
      # Create OTA property file
      makeotaprop
      # Create LICENSE
      makelicense
      # Create ZIP
      cd $BUILDDIR/$ARCH/$RELEASEDIR
      zip -qr9 ${RELEASEDIR}.zip *
      cd ../../..
      mv $BUILDDIR/$ARCH/$RELEASEDIR/${RELEASEDIR}.zip $OUTDIR/$ARCH/${RELEASEDIR}.zip
      # Sign ZIP
      java -jar $ZIPSIGNER $OUTDIR/$ARCH/${RELEASEDIR}.zip $OUTDIR/$ARCH/${RELEASEDIR}_signed.zip 2>/dev/null
      # Set build API in global environment
      [ "$(grep -w -o TARGET_API_25 $OUTDIR/ENV/env_api.sh 2>/dev/null)" ] || echo "TARGET_API_25" >> $OUTDIR/ENV/env_api.sh
      # List signed ZIP
      ls $OUTDIR/$ARCH/${RELEASEDIR}_signed.zip
      # Wipe unsigned ZIP
      rm -rf $OUTDIR/$ARCH/${RELEASEDIR}.zip
    fi
    # API 25
    if [ "$API" == "25" ]; then
      # Install variable; Do not modify
      TARGET_ANDROID_SDK_V25='"25"'
      # Build property variable; Do not modify
      sdk_25="25"
      version_25="7.1.2"
      echo "Generating BiTGApps package for $ARCH with API level $API"
      # Create release directory
      mkdir "$BUILDDIR/$ARCH/BiTGApps-${ARCH}-7.1.2-${COMMONGAPPSRELEASE}"
      RELEASEDIR="BiTGApps-${ARCH}-7.1.2-${COMMONGAPPSRELEASE}"
      # Create package components
      mkdir -p $BUILDDIR/$ARCH/$RELEASEDIR/$METADIR
      mkdir -p $BUILDDIR/$ARCH/$RELEASEDIR/$ZIP
      mkdir -p $BUILDDIR/$ARCH/$RELEASEDIR/$CORE
      mkdir -p $BUILDDIR/$ARCH/$RELEASEDIR/$SYS
      mkdir -p $BUILDDIR/$ARCH/$RELEASEDIR/$AOSPCORE
      mkdir -p $BUILDDIR/$ARCH/$RELEASEDIR/$AOSPSYS
      # Install app packages
      cp -f $SOURCESv25/$version_25/app/FaceLock.tar.xz $BUILDDIR/$ARCH/$RELEASEDIR/$SYS
      cp -f $SOURCESv25/$version_25/app/GoogleCalendarSyncAdapter.tar.xz $BUILDDIR/$ARCH/$RELEASEDIR/$SYS
      cp -f $SOURCESv25/$version_25/app/GoogleContactsSyncAdapter.tar.xz $BUILDDIR/$ARCH/$RELEASEDIR/$SYS
      cp -f $SOURCESv25/$version_25/app/GoogleExtShared.tar.xz $BUILDDIR/$ARCH/$RELEASEDIR/$SYS
      # Install etc packages
      cp -f $SOURCESv25/$version_25/etc/Default.tar.xz $BUILDDIR/$ARCH/$RELEASEDIR/$ZIP
      cp -f $SOURCESv25/$version_25/etc/Permissions.tar.xz $BUILDDIR/$ARCH/$RELEASEDIR/$ZIP
      cp -f $SOURCESv25/$version_25/etc/Preferred.tar.xz $BUILDDIR/$ARCH/$RELEASEDIR/$ZIP
      cp -f $SOURCESv25/$version_25/etc/Sysconfig.tar.xz $BUILDDIR/$ARCH/$RELEASEDIR/$ZIP
      # Install priv-app packages
      cp -f $SOURCESv25/$version_25/priv-app/ConfigUpdater.tar.xz $BUILDDIR/$ARCH/$RELEASEDIR/$CORE
      cp -f $SOURCESv25/$version_25/priv-app/GmsCoreSetupPrebuilt.tar.xz $BUILDDIR/$ARCH/$RELEASEDIR/$CORE
      cp -f $SOURCESv25/$version_25/priv-app/GoogleExtServices.tar.xz $BUILDDIR/$ARCH/$RELEASEDIR/$CORE
      cp -f $SOURCESv25/$version_25/priv-app/GoogleLoginService.tar.xz $BUILDDIR/$ARCH/$RELEASEDIR/$CORE
      cp -f $SOURCESv25/$version_25/priv-app/GoogleServicesFramework.tar.xz $BUILDDIR/$ARCH/$RELEASEDIR/$CORE
      cp -f $SOURCESv25/$version_25/priv-app/Phonesky.tar.xz $BUILDDIR/$ARCH/$RELEASEDIR/$CORE
      cp -f $SOURCESv25/$version_25/priv-app/PrebuiltGmsCore.tar.xz $BUILDDIR/$ARCH/$RELEASEDIR/$CORE
      # Install AOSP packages
      cp -f $AOSPSOURCESv25/$version_25/app/Messaging.tar.xz $BUILDDIR/$ARCH/$RELEASEDIR/$AOSPSYS
      cp -f $AOSPSOURCESv25/$version_25/etc/Permissions.tar.xz $BUILDDIR/$ARCH/$RELEASEDIR/$AOSPZIP
      cp -f $AOSPSOURCESv25/$version_25/priv-app/Contacts.tar.xz $BUILDDIR/$ARCH/$RELEASEDIR/$AOSPCORE
      cp -f $AOSPSOURCESv25/$version_25/priv-app/Dialer.tar.xz $BUILDDIR/$ARCH/$RELEASEDIR/$AOSPCORE
      cp -f $AOSPSOURCESv25/$version_25/priv-app/ManagedProvisioning.tar.xz $BUILDDIR/$ARCH/$RELEASEDIR/$AOSPCORE
      cp -f $AOSPSOURCESv25/$version_25/priv-app/Provision.tar.xz $BUILDDIR/$ARCH/$RELEASEDIR/$AOSPCORE
      # Install SetupWizard packages
      cp -f $SETUPSOURCESv25/$version_25/priv-app/GoogleBackupTransport.tar.xz $BUILDDIR/$ARCH/$RELEASEDIR/$CORE
      cp -f $SETUPSOURCESv25/$version_25/priv-app/SetupWizardPrebuilt.tar.xz $BUILDDIR/$ARCH/$RELEASEDIR/$CORE
      # Installer components
      cp -f $UPDATEBINARY $BUILDDIR/$ARCH/$RELEASEDIR/$METADIR/update-binary
      cp -f $UPDATERSCRIPT $BUILDDIR/$ARCH/$RELEASEDIR/$METADIR/updater-script
      cp -f $INSTALLER $BUILDDIR/$ARCH/$RELEASEDIR
      cp -f $LOGCATSCRIPT $BUILDDIR/$ARCH/$RELEASEDIR
      cp -f $BUSYBOX $BUILDDIR/$ARCH/$RELEASEDIR
      cp -f $AIK $BUILDDIR/$ARCH/$RELEASEDIR/$ZIP
      # Create utility script
      makeutilityscript
      replace_line $BUILDDIR/$ARCH/$RELEASEDIR/util_functions.sh REL="" REL="$GAPPS_RELEASE"
      replace_line $BUILDDIR/$ARCH/$RELEASEDIR/util_functions.sh ZIPTYPE="" ZIPTYPE="$ZIPTYPE"
      replace_line $BUILDDIR/$ARCH/$RELEASEDIR/util_functions.sh TARGET_GAPPS_RELEASE="" TARGET_GAPPS_RELEASE="$TARGET_GAPPS_RELEASE"
      replace_line $BUILDDIR/$ARCH/$RELEASEDIR/util_functions.sh TARGET_DIRTY_INSTALL="" TARGET_DIRTY_INSTALL="$TARGET_DIRTY_INSTALL"
      replace_line $BUILDDIR/$ARCH/$RELEASEDIR/util_functions.sh TARGET_ANDROID_SDK="" TARGET_ANDROID_SDK="$TARGET_ANDROID_SDK_V25"
      replace_line $BUILDDIR/$ARCH/$RELEASEDIR/util_functions.sh TARGET_ANDROID_ARCH="" TARGET_ANDROID_ARCH="$TARGET_ANDROID_ARCH_64"
      replace_line $BUILDDIR/$ARCH/$RELEASEDIR/util_functions.sh ARMEABI="" ARMEABI="$ARMEABI"
      replace_line $BUILDDIR/$ARCH/$RELEASEDIR/util_functions.sh AARCH64="" AARCH64="$AARCH64"
      replace_line $BUILDDIR/$ARCH/$RELEASEDIR/util_functions.sh TARGET_RELEASE_TAG="" TARGET_RELEASE_TAG="$TARGET_RELEASE_TAG"
      replace_line $BUILDDIR/$ARCH/$RELEASEDIR/util_functions.sh TARGET_CONFIG_VERSION="" TARGET_CONFIG_VERSION="$TARGET_CONFIG_VERSION"
      # Create build property file
      makegprop
      replace_line $BUILDDIR/$ARCH/$RELEASEDIR/g.prop CustomGAppsPackage= CustomGAppsPackage="$CustomGAppsPackage"
      replace_line $BUILDDIR/$ARCH/$RELEASEDIR/g.prop platform= platform="$platform_64"
      replace_line $BUILDDIR/$ARCH/$RELEASEDIR/g.prop sdk= sdk="$sdk_25"
      replace_line $BUILDDIR/$ARCH/$RELEASEDIR/g.prop version= version="$version_25"
      replace_line $BUILDDIR/$ARCH/$RELEASEDIR/g.prop BuildDate= BuildDate="$BuildDate"
      replace_line $BUILDDIR/$ARCH/$RELEASEDIR/g.prop BuildID= BuildID="$BuildID"
      replace_line $BUILDDIR/$ARCH/$RELEASEDIR/g.prop Developer= Developer="$Developer"
      # Add OTA script
      makeota
      # Create OTA property file
      makeotaprop
      # Create LICENSE
      makelicense
      # Create ZIP
      cd $BUILDDIR/$ARCH/$RELEASEDIR
      zip -qr9 ${RELEASEDIR}.zip *
      cd ../../..
      mv $BUILDDIR/$ARCH/$RELEASEDIR/${RELEASEDIR}.zip $OUTDIR/$ARCH/${RELEASEDIR}.zip
      # Sign ZIP
      java -jar $ZIPSIGNER $OUTDIR/$ARCH/${RELEASEDIR}.zip $OUTDIR/$ARCH/${RELEASEDIR}_signed.zip 2>/dev/null
      # Set build API in global environment
      [ "$(grep -w -o TARGET_API_25 $OUTDIR/ENV/env_api.sh 2>/dev/null)" ] || echo "TARGET_API_25" >> $OUTDIR/ENV/env_api.sh
      # List signed ZIP
      ls $OUTDIR/$ARCH/${RELEASEDIR}_signed.zip
      # Wipe unsigned ZIP
      rm -rf $OUTDIR/$ARCH/${RELEASEDIR}.zip
    fi
    # API 26
    if [ "$API" == "26" ]; then
      # Install variable; Do not modify
      TARGET_ANDROID_SDK_V26='"26"'
      # Build property variable; Do not modify
      sdk_26="26"
      version_26="8.0.0"
      echo "Generating BiTGApps package for $ARCH with API level $API"
      # Create release directory
      mkdir "$BUILDDIR/$ARCH/BiTGApps-${ARCH}-8.0.0-${COMMONGAPPSRELEASE}"
      RELEASEDIR="BiTGApps-${ARCH}-8.0.0-${COMMONGAPPSRELEASE}"
      # Create package components
      mkdir -p $BUILDDIR/$ARCH/$RELEASEDIR/$METADIR
      mkdir -p $BUILDDIR/$ARCH/$RELEASEDIR/$ZIP
      mkdir -p $BUILDDIR/$ARCH/$RELEASEDIR/$CORE
      mkdir -p $BUILDDIR/$ARCH/$RELEASEDIR/$SYS
      mkdir -p $BUILDDIR/$ARCH/$RELEASEDIR/$AOSPCORE
      mkdir -p $BUILDDIR/$ARCH/$RELEASEDIR/$AOSPSYS
      # Install app packages
      cp -f $SOURCESv26/app/FaceLock.tar.xz $BUILDDIR/$ARCH/$RELEASEDIR/$SYS
      cp -f $SOURCESv26/app/GoogleCalendarSyncAdapter.tar.xz $BUILDDIR/$ARCH/$RELEASEDIR/$SYS
      cp -f $SOURCESv26/app/GoogleContactsSyncAdapter.tar.xz $BUILDDIR/$ARCH/$RELEASEDIR/$SYS
      cp -f $SOURCESv26/app/GoogleExtShared.tar.xz $BUILDDIR/$ARCH/$RELEASEDIR/$SYS
      # Install etc packages
      cp -f $SOURCESv26/etc/Default.tar.xz $BUILDDIR/$ARCH/$RELEASEDIR/$ZIP
      cp -f $SOURCESv26/etc/Permissions.tar.xz $BUILDDIR/$ARCH/$RELEASEDIR/$ZIP
      cp -f $SOURCESv26/etc/Preferred.tar.xz $BUILDDIR/$ARCH/$RELEASEDIR/$ZIP
      cp -f $SOURCESv26/etc/Sysconfig.tar.xz $BUILDDIR/$ARCH/$RELEASEDIR/$ZIP
      # Install priv-app packages
      cp -f $SOURCESv26/priv-app/ConfigUpdater.tar.xz $BUILDDIR/$ARCH/$RELEASEDIR/$CORE
      cp -f $SOURCESv26/priv-app/GmsCoreSetupPrebuilt.tar.xz $BUILDDIR/$ARCH/$RELEASEDIR/$CORE
      cp -f $SOURCESv26/priv-app/GoogleExtServices.tar.xz $BUILDDIR/$ARCH/$RELEASEDIR/$CORE
      cp -f $SOURCESv26/priv-app/GoogleServicesFramework.tar.xz $BUILDDIR/$ARCH/$RELEASEDIR/$CORE
      cp -f $SOURCESv26/priv-app/Phonesky.tar.xz $BUILDDIR/$ARCH/$RELEASEDIR/$CORE
      cp -f $SOURCESv26/priv-app/PrebuiltGmsCorePix.tar.xz $BUILDDIR/$ARCH/$RELEASEDIR/$CORE
      # Install AOSP packages
      cp -f $AOSPSOURCESv26/app/Messaging.tar.xz $BUILDDIR/$ARCH/$RELEASEDIR/$AOSPSYS
      cp -f $AOSPSOURCESv26/etc/Permissions.tar.xz $BUILDDIR/$ARCH/$RELEASEDIR/$AOSPZIP
      cp -f $AOSPSOURCESv26/priv-app/Contacts.tar.xz $BUILDDIR/$ARCH/$RELEASEDIR/$AOSPCORE
      cp -f $AOSPSOURCESv26/priv-app/Dialer.tar.xz $BUILDDIR/$ARCH/$RELEASEDIR/$AOSPCORE
      cp -f $AOSPSOURCESv26/priv-app/ManagedProvisioning.tar.xz $BUILDDIR/$ARCH/$RELEASEDIR/$AOSPCORE
      cp -f $AOSPSOURCESv26/priv-app/Provision.tar.xz $BUILDDIR/$ARCH/$RELEASEDIR/$AOSPCORE
      # Install SetupWizard packages
      cp -f $SETUPSOURCESv26/priv-app/GoogleBackupTransport.tar.xz $BUILDDIR/$ARCH/$RELEASEDIR/$CORE
      cp -f $SETUPSOURCESv26/priv-app/SetupWizardPrebuilt.tar.xz $BUILDDIR/$ARCH/$RELEASEDIR/$CORE
      # Installer components
      cp -f $UPDATEBINARY $BUILDDIR/$ARCH/$RELEASEDIR/$METADIR/update-binary
      cp -f $UPDATERSCRIPT $BUILDDIR/$ARCH/$RELEASEDIR/$METADIR/updater-script
      cp -f $INSTALLER $BUILDDIR/$ARCH/$RELEASEDIR
      cp -f $LOGCATSCRIPT $BUILDDIR/$ARCH/$RELEASEDIR
      cp -f $BUSYBOX $BUILDDIR/$ARCH/$RELEASEDIR
      cp -f $AIK $BUILDDIR/$ARCH/$RELEASEDIR/$ZIP
      cp -f $API_26_KEYSTORE $BUILDDIR/$ARCH/$RELEASEDIR/$ZIP
      # Create utility script
      makeutilityscript
      replace_line $BUILDDIR/$ARCH/$RELEASEDIR/util_functions.sh REL="" REL="$GAPPS_RELEASE"
      replace_line $BUILDDIR/$ARCH/$RELEASEDIR/util_functions.sh ZIPTYPE="" ZIPTYPE="$ZIPTYPE"
      replace_line $BUILDDIR/$ARCH/$RELEASEDIR/util_functions.sh TARGET_GAPPS_RELEASE="" TARGET_GAPPS_RELEASE="$TARGET_GAPPS_RELEASE"
      replace_line $BUILDDIR/$ARCH/$RELEASEDIR/util_functions.sh TARGET_DIRTY_INSTALL="" TARGET_DIRTY_INSTALL="$TARGET_DIRTY_INSTALL"
      replace_line $BUILDDIR/$ARCH/$RELEASEDIR/util_functions.sh TARGET_ANDROID_SDK="" TARGET_ANDROID_SDK="$TARGET_ANDROID_SDK_V26"
      replace_line $BUILDDIR/$ARCH/$RELEASEDIR/util_functions.sh TARGET_ANDROID_ARCH="" TARGET_ANDROID_ARCH="$TARGET_ANDROID_ARCH_64"
      replace_line $BUILDDIR/$ARCH/$RELEASEDIR/util_functions.sh ARMEABI="" ARMEABI="$ARMEABI"
      replace_line $BUILDDIR/$ARCH/$RELEASEDIR/util_functions.sh AARCH64="" AARCH64="$AARCH64"
      replace_line $BUILDDIR/$ARCH/$RELEASEDIR/util_functions.sh TARGET_RELEASE_TAG="" TARGET_RELEASE_TAG="$TARGET_RELEASE_TAG"
      replace_line $BUILDDIR/$ARCH/$RELEASEDIR/util_functions.sh TARGET_CONFIG_VERSION="" TARGET_CONFIG_VERSION="$TARGET_CONFIG_VERSION"
      # Create build property file
      makegprop
      replace_line $BUILDDIR/$ARCH/$RELEASEDIR/g.prop CustomGAppsPackage= CustomGAppsPackage="$CustomGAppsPackage"
      replace_line $BUILDDIR/$ARCH/$RELEASEDIR/g.prop platform= platform="$platform_64"
      replace_line $BUILDDIR/$ARCH/$RELEASEDIR/g.prop sdk= sdk="$sdk_26"
      replace_line $BUILDDIR/$ARCH/$RELEASEDIR/g.prop version= version="$version_26"
      replace_line $BUILDDIR/$ARCH/$RELEASEDIR/g.prop BuildDate= BuildDate="$BuildDate"
      replace_line $BUILDDIR/$ARCH/$RELEASEDIR/g.prop BuildID= BuildID="$BuildID"
      replace_line $BUILDDIR/$ARCH/$RELEASEDIR/g.prop Developer= Developer="$Developer"
      # Add OTA script
      makeota
      # Create OTA property file
      makeotaprop
      # Create LICENSE
      makelicense
      # Create ZIP
      cd $BUILDDIR/$ARCH/$RELEASEDIR
      zip -qr9 ${RELEASEDIR}.zip *
      cd ../../..
      mv $BUILDDIR/$ARCH/$RELEASEDIR/${RELEASEDIR}.zip $OUTDIR/$ARCH/${RELEASEDIR}.zip
      # Sign ZIP
      java -jar $ZIPSIGNER $OUTDIR/$ARCH/${RELEASEDIR}.zip $OUTDIR/$ARCH/${RELEASEDIR}_signed.zip 2>/dev/null
      # Set build API in global environment
      [ "$(grep -w -o TARGET_API_26 $OUTDIR/ENV/env_api.sh 2>/dev/null)" ] || echo "TARGET_API_26" >> $OUTDIR/ENV/env_api.sh
      # List signed ZIP
      ls $OUTDIR/$ARCH/${RELEASEDIR}_signed.zip
      # Wipe unsigned ZIP
      rm -rf $OUTDIR/$ARCH/${RELEASEDIR}.zip
    fi
    # API 27
    if [ "$API" == "27" ]; then
      # Install variable; Do not modify
      TARGET_ANDROID_SDK_V27='"27"'
      # Build property variable; Do not modify
      sdk_27="27"
      version_27="8.1.0"
      echo "Generating BiTGApps package for $ARCH with API level $API"
      # Create release directory
      mkdir "$BUILDDIR/$ARCH/BiTGApps-${ARCH}-8.1.0-${COMMONGAPPSRELEASE}"
      RELEASEDIR="BiTGApps-${ARCH}-8.1.0-${COMMONGAPPSRELEASE}"
      # Create package components
      mkdir -p $BUILDDIR/$ARCH/$RELEASEDIR/$METADIR
      mkdir -p $BUILDDIR/$ARCH/$RELEASEDIR/$ZIP
      mkdir -p $BUILDDIR/$ARCH/$RELEASEDIR/$CORE
      mkdir -p $BUILDDIR/$ARCH/$RELEASEDIR/$SYS
      mkdir -p $BUILDDIR/$ARCH/$RELEASEDIR/$AOSPCORE
      mkdir -p $BUILDDIR/$ARCH/$RELEASEDIR/$AOSPSYS
      # Install app packages
      cp -f $SOURCESv27/app/FaceLock.tar.xz $BUILDDIR/$ARCH/$RELEASEDIR/$SYS
      cp -f $SOURCESv27/app/GoogleCalendarSyncAdapter.tar.xz $BUILDDIR/$ARCH/$RELEASEDIR/$SYS
      cp -f $SOURCESv27/app/GoogleContactsSyncAdapter.tar.xz $BUILDDIR/$ARCH/$RELEASEDIR/$SYS
      cp -f $SOURCESv27/app/GoogleExtShared.tar.xz $BUILDDIR/$ARCH/$RELEASEDIR/$SYS
      # Install etc packages
      cp -f $SOURCESv27/etc/Default.tar.xz $BUILDDIR/$ARCH/$RELEASEDIR/$ZIP
      cp -f $SOURCESv27/etc/Permissions.tar.xz $BUILDDIR/$ARCH/$RELEASEDIR/$ZIP
      cp -f $SOURCESv27/etc/Preferred.tar.xz $BUILDDIR/$ARCH/$RELEASEDIR/$ZIP
      cp -f $SOURCESv27/etc/Sysconfig.tar.xz $BUILDDIR/$ARCH/$RELEASEDIR/$ZIP
      # Install priv-app packages
      cp -f $SOURCESv27/priv-app/ConfigUpdater.tar.xz $BUILDDIR/$ARCH/$RELEASEDIR/$CORE
      cp -f $SOURCESv27/priv-app/GmsCoreSetupPrebuilt.tar.xz $BUILDDIR/$ARCH/$RELEASEDIR/$CORE
      cp -f $SOURCESv27/priv-app/GoogleExtServices.tar.xz $BUILDDIR/$ARCH/$RELEASEDIR/$CORE
      cp -f $SOURCESv27/priv-app/GoogleServicesFramework.tar.xz $BUILDDIR/$ARCH/$RELEASEDIR/$CORE
      cp -f $SOURCESv27/priv-app/Phonesky.tar.xz $BUILDDIR/$ARCH/$RELEASEDIR/$CORE
      cp -f $SOURCESv27/priv-app/PrebuiltGmsCorePix.tar.xz $BUILDDIR/$ARCH/$RELEASEDIR/$CORE
      # Install AOSP packages
      cp -f $AOSPSOURCESv27/app/Messaging.tar.xz $BUILDDIR/$ARCH/$RELEASEDIR/$AOSPSYS
      cp -f $AOSPSOURCESv27/etc/Permissions.tar.xz $BUILDDIR/$ARCH/$RELEASEDIR/$AOSPZIP
      cp -f $AOSPSOURCESv27/priv-app/Contacts.tar.xz $BUILDDIR/$ARCH/$RELEASEDIR/$AOSPCORE
      cp -f $AOSPSOURCESv27/priv-app/Dialer.tar.xz $BUILDDIR/$ARCH/$RELEASEDIR/$AOSPCORE
      cp -f $AOSPSOURCESv27/priv-app/ManagedProvisioning.tar.xz $BUILDDIR/$ARCH/$RELEASEDIR/$AOSPCORE
      cp -f $AOSPSOURCESv27/priv-app/Provision.tar.xz $BUILDDIR/$ARCH/$RELEASEDIR/$AOSPCORE
      # Install SetupWizard packages
      cp -f $SETUPSOURCESv27/priv-app/GoogleBackupTransport.tar.xz $BUILDDIR/$ARCH/$RELEASEDIR/$CORE
      cp -f $SETUPSOURCESv27/priv-app/SetupWizardPrebuilt.tar.xz $BUILDDIR/$ARCH/$RELEASEDIR/$CORE
      # Installer components
      cp -f $UPDATEBINARY $BUILDDIR/$ARCH/$RELEASEDIR/$METADIR/update-binary
      cp -f $UPDATERSCRIPT $BUILDDIR/$ARCH/$RELEASEDIR/$METADIR/updater-script
      cp -f $INSTALLER $BUILDDIR/$ARCH/$RELEASEDIR
      cp -f $LOGCATSCRIPT $BUILDDIR/$ARCH/$RELEASEDIR
      cp -f $BUSYBOX $BUILDDIR/$ARCH/$RELEASEDIR
      cp -f $AIK $BUILDDIR/$ARCH/$RELEASEDIR/$ZIP
      cp -f $API_27_KEYSTORE $BUILDDIR/$ARCH/$RELEASEDIR/$ZIP
      # Create utility script
      makeutilityscript
      replace_line $BUILDDIR/$ARCH/$RELEASEDIR/util_functions.sh REL="" REL="$GAPPS_RELEASE"
      replace_line $BUILDDIR/$ARCH/$RELEASEDIR/util_functions.sh ZIPTYPE="" ZIPTYPE="$ZIPTYPE"
      replace_line $BUILDDIR/$ARCH/$RELEASEDIR/util_functions.sh TARGET_GAPPS_RELEASE="" TARGET_GAPPS_RELEASE="$TARGET_GAPPS_RELEASE"
      replace_line $BUILDDIR/$ARCH/$RELEASEDIR/util_functions.sh TARGET_DIRTY_INSTALL="" TARGET_DIRTY_INSTALL="$TARGET_DIRTY_INSTALL"
      replace_line $BUILDDIR/$ARCH/$RELEASEDIR/util_functions.sh TARGET_ANDROID_SDK="" TARGET_ANDROID_SDK="$TARGET_ANDROID_SDK_V27"
      replace_line $BUILDDIR/$ARCH/$RELEASEDIR/util_functions.sh TARGET_ANDROID_ARCH="" TARGET_ANDROID_ARCH="$TARGET_ANDROID_ARCH_64"
      replace_line $BUILDDIR/$ARCH/$RELEASEDIR/util_functions.sh ARMEABI="" ARMEABI="$ARMEABI"
      replace_line $BUILDDIR/$ARCH/$RELEASEDIR/util_functions.sh AARCH64="" AARCH64="$AARCH64"
      replace_line $BUILDDIR/$ARCH/$RELEASEDIR/util_functions.sh TARGET_RELEASE_TAG="" TARGET_RELEASE_TAG="$TARGET_RELEASE_TAG"
      replace_line $BUILDDIR/$ARCH/$RELEASEDIR/util_functions.sh TARGET_CONFIG_VERSION="" TARGET_CONFIG_VERSION="$TARGET_CONFIG_VERSION"
      # Create build property file
      makegprop
      replace_line $BUILDDIR/$ARCH/$RELEASEDIR/g.prop CustomGAppsPackage= CustomGAppsPackage="$CustomGAppsPackage"
      replace_line $BUILDDIR/$ARCH/$RELEASEDIR/g.prop platform= platform="$platform_64"
      replace_line $BUILDDIR/$ARCH/$RELEASEDIR/g.prop sdk= sdk="$sdk_27"
      replace_line $BUILDDIR/$ARCH/$RELEASEDIR/g.prop version= version="$version_27"
      replace_line $BUILDDIR/$ARCH/$RELEASEDIR/g.prop BuildDate= BuildDate="$BuildDate"
      replace_line $BUILDDIR/$ARCH/$RELEASEDIR/g.prop BuildID= BuildID="$BuildID"
      replace_line $BUILDDIR/$ARCH/$RELEASEDIR/g.prop Developer= Developer="$Developer"
      # Add OTA script
      makeota
      # Create OTA property file
      makeotaprop
      # Create LICENSE
      makelicense
      # Create ZIP
      cd $BUILDDIR/$ARCH/$RELEASEDIR
      zip -qr9 ${RELEASEDIR}.zip *
      cd ../../..
      mv $BUILDDIR/$ARCH/$RELEASEDIR/${RELEASEDIR}.zip $OUTDIR/$ARCH/${RELEASEDIR}.zip
      # Sign ZIP
      java -jar $ZIPSIGNER $OUTDIR/$ARCH/${RELEASEDIR}.zip $OUTDIR/$ARCH/${RELEASEDIR}_signed.zip 2>/dev/null
      # Set build API in global environment
      [ "$(grep -w -o TARGET_API_27 $OUTDIR/ENV/env_api.sh 2>/dev/null)" ] || echo "TARGET_API_27" >> $OUTDIR/ENV/env_api.sh
      # List signed ZIP
      ls $OUTDIR/$ARCH/${RELEASEDIR}_signed.zip
      # Wipe unsigned ZIP
      rm -rf $OUTDIR/$ARCH/${RELEASEDIR}.zip
    fi
    # API 28
    if [ "$API" == "28" ]; then
      # Install variable; Do not modify
      TARGET_ANDROID_SDK_V28='"28"'
      # Build property variable; Do not modify
      sdk_28="28"
      version_28="9.0.0"
      echo "Generating BiTGApps package for $ARCH with API level $API"
      # Create release directory
      mkdir "$BUILDDIR/$ARCH/BiTGApps-${ARCH}-9.0.0-${COMMONGAPPSRELEASE}"
      RELEASEDIR="BiTGApps-${ARCH}-9.0.0-${COMMONGAPPSRELEASE}"
      # Create package components
      mkdir -p $BUILDDIR/$ARCH/$RELEASEDIR/$METADIR
      mkdir -p $BUILDDIR/$ARCH/$RELEASEDIR/$ZIP
      mkdir -p $BUILDDIR/$ARCH/$RELEASEDIR/$CORE
      mkdir -p $BUILDDIR/$ARCH/$RELEASEDIR/$SYS
      mkdir -p $BUILDDIR/$ARCH/$RELEASEDIR/$AOSPCORE
      mkdir -p $BUILDDIR/$ARCH/$RELEASEDIR/$AOSPSYS
      # Install app packages
      cp -f $SOURCESv28/app/FaceLock.tar.xz $BUILDDIR/$ARCH/$RELEASEDIR/$SYS
      cp -f $SOURCESv28/app/GoogleCalendarSyncAdapter.tar.xz $BUILDDIR/$ARCH/$RELEASEDIR/$SYS
      cp -f $SOURCESv28/app/GoogleContactsSyncAdapter.tar.xz $BUILDDIR/$ARCH/$RELEASEDIR/$SYS
      cp -f $SOURCESv28/app/GoogleExtShared.tar.xz $BUILDDIR/$ARCH/$RELEASEDIR/$SYS
      # Install etc packages
      cp -f $SOURCESv28/etc/Default.tar.xz $BUILDDIR/$ARCH/$RELEASEDIR/$ZIP
      cp -f $SOURCESv28/etc/Permissions.tar.xz $BUILDDIR/$ARCH/$RELEASEDIR/$ZIP
      cp -f $SOURCESv28/etc/Preferred.tar.xz $BUILDDIR/$ARCH/$RELEASEDIR/$ZIP
      cp -f $SOURCESv28/etc/Sysconfig.tar.xz $BUILDDIR/$ARCH/$RELEASEDIR/$ZIP
      # Install priv-app packages
      cp -f $SOURCESv28/priv-app/ConfigUpdater.tar.xz $BUILDDIR/$ARCH/$RELEASEDIR/$CORE
      cp -f $SOURCESv28/priv-app/GoogleExtServices.tar.xz $BUILDDIR/$ARCH/$RELEASEDIR/$CORE
      cp -f $SOURCESv28/priv-app/GoogleServicesFramework.tar.xz $BUILDDIR/$ARCH/$RELEASEDIR/$CORE
      cp -f $SOURCESv28/priv-app/Phonesky.tar.xz $BUILDDIR/$ARCH/$RELEASEDIR/$CORE
      cp -f $SOURCESv28/priv-app/PrebuiltGmsCorePi.tar.xz $BUILDDIR/$ARCH/$RELEASEDIR/$CORE
      # Install AOSP packages
      cp -f $AOSPSOURCESv28/app/Messaging.tar.xz $BUILDDIR/$ARCH/$RELEASEDIR/$AOSPSYS
      cp -f $AOSPSOURCESv28/etc/Permissions.tar.xz $BUILDDIR/$ARCH/$RELEASEDIR/$AOSPZIP
      cp -f $AOSPSOURCESv28/priv-app/Contacts.tar.xz $BUILDDIR/$ARCH/$RELEASEDIR/$AOSPCORE
      cp -f $AOSPSOURCESv28/priv-app/Dialer.tar.xz $BUILDDIR/$ARCH/$RELEASEDIR/$AOSPCORE
      cp -f $AOSPSOURCESv28/priv-app/ManagedProvisioning.tar.xz $BUILDDIR/$ARCH/$RELEASEDIR/$AOSPCORE
      cp -f $AOSPSOURCESv28/priv-app/Provision.tar.xz $BUILDDIR/$ARCH/$RELEASEDIR/$AOSPCORE
      # Install SetupWizard packages
      cp -f $SETUPSOURCESv28/priv-app/AndroidMigratePrebuilt.tar.xz $BUILDDIR/$ARCH/$RELEASEDIR/$CORE
      cp -f $SETUPSOURCESv28/priv-app/GoogleBackupTransport.tar.xz $BUILDDIR/$ARCH/$RELEASEDIR/$CORE
      cp -f $SETUPSOURCESv28/priv-app/SetupWizardPrebuilt.tar.xz $BUILDDIR/$ARCH/$RELEASEDIR/$CORE
      # Installer components
      cp -f $UPDATEBINARY $BUILDDIR/$ARCH/$RELEASEDIR/$METADIR/update-binary
      cp -f $UPDATERSCRIPT $BUILDDIR/$ARCH/$RELEASEDIR/$METADIR/updater-script
      cp -f $INSTALLER $BUILDDIR/$ARCH/$RELEASEDIR
      cp -f $LOGCATSCRIPT $BUILDDIR/$ARCH/$RELEASEDIR
      cp -f $BUSYBOX $BUILDDIR/$ARCH/$RELEASEDIR
      cp -f $AIK $BUILDDIR/$ARCH/$RELEASEDIR/$ZIP
      cp -f $API_28_KEYSTORE $BUILDDIR/$ARCH/$RELEASEDIR/$ZIP
      # Create utility script
      makeutilityscript
      replace_line $BUILDDIR/$ARCH/$RELEASEDIR/util_functions.sh REL="" REL="$GAPPS_RELEASE"
      replace_line $BUILDDIR/$ARCH/$RELEASEDIR/util_functions.sh ZIPTYPE="" ZIPTYPE="$ZIPTYPE"
      replace_line $BUILDDIR/$ARCH/$RELEASEDIR/util_functions.sh TARGET_GAPPS_RELEASE="" TARGET_GAPPS_RELEASE="$TARGET_GAPPS_RELEASE"
      replace_line $BUILDDIR/$ARCH/$RELEASEDIR/util_functions.sh TARGET_DIRTY_INSTALL="" TARGET_DIRTY_INSTALL="$TARGET_DIRTY_INSTALL"
      replace_line $BUILDDIR/$ARCH/$RELEASEDIR/util_functions.sh TARGET_ANDROID_SDK="" TARGET_ANDROID_SDK="$TARGET_ANDROID_SDK_V28"
      replace_line $BUILDDIR/$ARCH/$RELEASEDIR/util_functions.sh TARGET_ANDROID_ARCH="" TARGET_ANDROID_ARCH="$TARGET_ANDROID_ARCH_64"
      replace_line $BUILDDIR/$ARCH/$RELEASEDIR/util_functions.sh ARMEABI="" ARMEABI="$ARMEABI"
      replace_line $BUILDDIR/$ARCH/$RELEASEDIR/util_functions.sh AARCH64="" AARCH64="$AARCH64"
      replace_line $BUILDDIR/$ARCH/$RELEASEDIR/util_functions.sh TARGET_RELEASE_TAG="" TARGET_RELEASE_TAG="$TARGET_RELEASE_TAG"
      replace_line $BUILDDIR/$ARCH/$RELEASEDIR/util_functions.sh TARGET_CONFIG_VERSION="" TARGET_CONFIG_VERSION="$TARGET_CONFIG_VERSION"
      # Create build property file
      makegprop
      replace_line $BUILDDIR/$ARCH/$RELEASEDIR/g.prop CustomGAppsPackage= CustomGAppsPackage="$CustomGAppsPackage"
      replace_line $BUILDDIR/$ARCH/$RELEASEDIR/g.prop platform= platform="$platform_64"
      replace_line $BUILDDIR/$ARCH/$RELEASEDIR/g.prop sdk= sdk="$sdk_28"
      replace_line $BUILDDIR/$ARCH/$RELEASEDIR/g.prop version= version="$version_28"
      replace_line $BUILDDIR/$ARCH/$RELEASEDIR/g.prop BuildDate= BuildDate="$BuildDate"
      replace_line $BUILDDIR/$ARCH/$RELEASEDIR/g.prop BuildID= BuildID="$BuildID"
      replace_line $BUILDDIR/$ARCH/$RELEASEDIR/g.prop Developer= Developer="$Developer"
      # Add OTA script
      makeota
      # Create OTA property file
      makeotaprop
      # Create LICENSE
      makelicense
      # Create ZIP
      cd $BUILDDIR/$ARCH/$RELEASEDIR
      zip -qr9 ${RELEASEDIR}.zip *
      cd ../../..
      mv $BUILDDIR/$ARCH/$RELEASEDIR/${RELEASEDIR}.zip $OUTDIR/$ARCH/${RELEASEDIR}.zip
      # Sign ZIP
      java -jar $ZIPSIGNER $OUTDIR/$ARCH/${RELEASEDIR}.zip $OUTDIR/$ARCH/${RELEASEDIR}_signed.zip 2>/dev/null
      # Set build API in global environment
      [ "$(grep -w -o TARGET_API_28 $OUTDIR/ENV/env_api.sh 2>/dev/null)" ] || echo "TARGET_API_28" >> $OUTDIR/ENV/env_api.sh
      # List signed ZIP
      ls $OUTDIR/$ARCH/${RELEASEDIR}_signed.zip
      # Wipe unsigned ZIP
      rm -rf $OUTDIR/$ARCH/${RELEASEDIR}.zip
    fi
    # API 29
    if [ "$API" == "29" ]; then
      # Install variable; Do not modify
      TARGET_ANDROID_SDK_V29='"29"'
      # Build property variable; Do not modify
      sdk_29="29"
      version_29="10.0.0"
      echo "Generating BiTGApps package for $ARCH with API level $API"
      # Create release directory
      mkdir "$BUILDDIR/$ARCH/BiTGApps-${ARCH}-10.0.0-${COMMONGAPPSRELEASE}"
      RELEASEDIR="BiTGApps-${ARCH}-10.0.0-${COMMONGAPPSRELEASE}"
      # Create package components
      mkdir -p $BUILDDIR/$ARCH/$RELEASEDIR/$METADIR
      mkdir -p $BUILDDIR/$ARCH/$RELEASEDIR/$ZIP
      mkdir -p $BUILDDIR/$ARCH/$RELEASEDIR/$CORE
      mkdir -p $BUILDDIR/$ARCH/$RELEASEDIR/$SYS
      mkdir -p $BUILDDIR/$ARCH/$RELEASEDIR/$AOSPCORE
      mkdir -p $BUILDDIR/$ARCH/$RELEASEDIR/$AOSPSYS
      # Install app packages
      cp -f $SOURCESv29/app/GoogleCalendarSyncAdapter.tar.xz $BUILDDIR/$ARCH/$RELEASEDIR/$SYS
      cp -f $SOURCESv29/app/GoogleContactsSyncAdapter.tar.xz $BUILDDIR/$ARCH/$RELEASEDIR/$SYS
      cp -f $SOURCESv29/app/GoogleExtShared.tar.xz $BUILDDIR/$ARCH/$RELEASEDIR/$SYS
      # Install etc packages
      cp -f $SOURCESv29/etc/Default.tar.xz $BUILDDIR/$ARCH/$RELEASEDIR/$ZIP
      cp -f $SOURCESv29/etc/Permissions.tar.xz $BUILDDIR/$ARCH/$RELEASEDIR/$ZIP
      cp -f $SOURCESv29/etc/Preferred.tar.xz $BUILDDIR/$ARCH/$RELEASEDIR/$ZIP
      cp -f $SOURCESv29/etc/Sysconfig.tar.xz $BUILDDIR/$ARCH/$RELEASEDIR/$ZIP
      # Install priv-app packages
      cp -f $SOURCESv29/priv-app/ConfigUpdater.tar.xz $BUILDDIR/$ARCH/$RELEASEDIR/$CORE
      cp -f $SOURCESv29/priv-app/GoogleExtServices.tar.xz $BUILDDIR/$ARCH/$RELEASEDIR/$CORE
      cp -f $SOURCESv29/priv-app/GoogleServicesFramework.tar.xz $BUILDDIR/$ARCH/$RELEASEDIR/$CORE
      cp -f $SOURCESv29/priv-app/Phonesky.tar.xz $BUILDDIR/$ARCH/$RELEASEDIR/$CORE
      cp -f $SOURCESv29/priv-app/PrebuiltGmsCoreQt.tar.xz $BUILDDIR/$ARCH/$RELEASEDIR/$CORE
      # Install AOSP packages
      cp -f $AOSPSOURCESv29/app/Messaging.tar.xz $BUILDDIR/$ARCH/$RELEASEDIR/$AOSPSYS
      cp -f $AOSPSOURCESv29/etc/Permissions.tar.xz $BUILDDIR/$ARCH/$RELEASEDIR/$AOSPZIP
      cp -f $AOSPSOURCESv29/priv-app/Contacts.tar.xz $BUILDDIR/$ARCH/$RELEASEDIR/$AOSPCORE
      cp -f $AOSPSOURCESv29/priv-app/Dialer.tar.xz $BUILDDIR/$ARCH/$RELEASEDIR/$AOSPCORE
      cp -f $AOSPSOURCESv29/priv-app/ManagedProvisioning.tar.xz $BUILDDIR/$ARCH/$RELEASEDIR/$AOSPCORE
      cp -f $AOSPSOURCESv29/priv-app/Provision.tar.xz $BUILDDIR/$ARCH/$RELEASEDIR/$AOSPCORE
      # Install SetupWizard packages
      cp -f $SETUPSOURCESv29/priv-app/AndroidMigratePrebuilt.tar.xz $BUILDDIR/$ARCH/$RELEASEDIR/$CORE
      cp -f $SETUPSOURCESv29/priv-app/SetupWizardPrebuilt.tar.xz $BUILDDIR/$ARCH/$RELEASEDIR/$CORE
      # Installer components
      cp -f $UPDATEBINARY $BUILDDIR/$ARCH/$RELEASEDIR/$METADIR/update-binary
      cp -f $UPDATERSCRIPT $BUILDDIR/$ARCH/$RELEASEDIR/$METADIR/updater-script
      cp -f $INSTALLER $BUILDDIR/$ARCH/$RELEASEDIR
      cp -f $LOGCATSCRIPT $BUILDDIR/$ARCH/$RELEASEDIR
      cp -f $BUSYBOX $BUILDDIR/$ARCH/$RELEASEDIR
      cp -f $AIK $BUILDDIR/$ARCH/$RELEASEDIR/$ZIP
      cp -f $API_29_KEYSTORE $BUILDDIR/$ARCH/$RELEASEDIR/$ZIP
      # Create utility script
      makeutilityscript
      replace_line $BUILDDIR/$ARCH/$RELEASEDIR/util_functions.sh REL="" REL="$GAPPS_RELEASE"
      replace_line $BUILDDIR/$ARCH/$RELEASEDIR/util_functions.sh ZIPTYPE="" ZIPTYPE="$ZIPTYPE"
      replace_line $BUILDDIR/$ARCH/$RELEASEDIR/util_functions.sh TARGET_GAPPS_RELEASE="" TARGET_GAPPS_RELEASE="$TARGET_GAPPS_RELEASE"
      replace_line $BUILDDIR/$ARCH/$RELEASEDIR/util_functions.sh TARGET_DIRTY_INSTALL="" TARGET_DIRTY_INSTALL="$TARGET_DIRTY_INSTALL"
      replace_line $BUILDDIR/$ARCH/$RELEASEDIR/util_functions.sh TARGET_ANDROID_SDK="" TARGET_ANDROID_SDK="$TARGET_ANDROID_SDK_V29"
      replace_line $BUILDDIR/$ARCH/$RELEASEDIR/util_functions.sh TARGET_ANDROID_ARCH="" TARGET_ANDROID_ARCH="$TARGET_ANDROID_ARCH_64"
      replace_line $BUILDDIR/$ARCH/$RELEASEDIR/util_functions.sh ARMEABI="" ARMEABI="$ARMEABI"
      replace_line $BUILDDIR/$ARCH/$RELEASEDIR/util_functions.sh AARCH64="" AARCH64="$AARCH64"
      replace_line $BUILDDIR/$ARCH/$RELEASEDIR/util_functions.sh TARGET_RELEASE_TAG="" TARGET_RELEASE_TAG="$TARGET_RELEASE_TAG"
      replace_line $BUILDDIR/$ARCH/$RELEASEDIR/util_functions.sh TARGET_CONFIG_VERSION="" TARGET_CONFIG_VERSION="$TARGET_CONFIG_VERSION"
      # Create build property file
      makegprop
      replace_line $BUILDDIR/$ARCH/$RELEASEDIR/g.prop CustomGAppsPackage= CustomGAppsPackage="$CustomGAppsPackage"
      replace_line $BUILDDIR/$ARCH/$RELEASEDIR/g.prop platform= platform="$platform_64"
      replace_line $BUILDDIR/$ARCH/$RELEASEDIR/g.prop sdk= sdk="$sdk_29"
      replace_line $BUILDDIR/$ARCH/$RELEASEDIR/g.prop version= version="$version_29"
      replace_line $BUILDDIR/$ARCH/$RELEASEDIR/g.prop BuildDate= BuildDate="$BuildDate"
      replace_line $BUILDDIR/$ARCH/$RELEASEDIR/g.prop BuildID= BuildID="$BuildID"
      replace_line $BUILDDIR/$ARCH/$RELEASEDIR/g.prop Developer= Developer="$Developer"
      # Add OTA script
      makeota
      # Create OTA property file
      makeotaprop
      # Create LICENSE
      makelicense
      # Create ZIP
      cd $BUILDDIR/$ARCH/$RELEASEDIR
      zip -qr9 ${RELEASEDIR}.zip *
      cd ../../..
      mv $BUILDDIR/$ARCH/$RELEASEDIR/${RELEASEDIR}.zip $OUTDIR/$ARCH/${RELEASEDIR}.zip
      # Sign ZIP
      java -jar $ZIPSIGNER $OUTDIR/$ARCH/${RELEASEDIR}.zip $OUTDIR/$ARCH/${RELEASEDIR}_signed.zip 2>/dev/null
      # Set build API in global environment
      [ "$(grep -w -o TARGET_API_29 $OUTDIR/ENV/env_api.sh 2>/dev/null)" ] || echo "TARGET_API_29" >> $OUTDIR/ENV/env_api.sh
      # List signed ZIP
      ls $OUTDIR/$ARCH/${RELEASEDIR}_signed.zip
      # Wipe unsigned ZIP
      rm -rf $OUTDIR/$ARCH/${RELEASEDIR}.zip
    fi
    # API 30
    if [ "$API" == "30" ]; then
      # Install variable; Do not modify
      TARGET_ANDROID_SDK_V30='"30"'
      # Build property variable; Do not modify
      sdk_30="30"
      version_30="11.0.0"
      echo "Generating BiTGApps package for $ARCH with API level $API"
      # Create release directory
      mkdir "$BUILDDIR/$ARCH/BiTGApps-${ARCH}-11.0.0-${COMMONGAPPSRELEASE}"
      RELEASEDIR="BiTGApps-${ARCH}-11.0.0-${COMMONGAPPSRELEASE}"
      # Create package components
      mkdir -p $BUILDDIR/$ARCH/$RELEASEDIR/$METADIR
      mkdir -p $BUILDDIR/$ARCH/$RELEASEDIR/$ZIP
      mkdir -p $BUILDDIR/$ARCH/$RELEASEDIR/$CORE
      mkdir -p $BUILDDIR/$ARCH/$RELEASEDIR/$SYS
      mkdir -p $BUILDDIR/$ARCH/$RELEASEDIR/$AOSPCORE
      mkdir -p $BUILDDIR/$ARCH/$RELEASEDIR/$AOSPSYS
      mkdir -p $BUILDDIR/$ARCH/$RELEASEDIR/$OVERLAY
      # Install app packages
      cp -f $SOURCESv30/app/GoogleCalendarSyncAdapter.tar.xz $BUILDDIR/$ARCH/$RELEASEDIR/$SYS
      cp -f $SOURCESv30/app/GoogleContactsSyncAdapter.tar.xz $BUILDDIR/$ARCH/$RELEASEDIR/$SYS
      cp -f $SOURCESv30/app/GoogleExtShared.tar.xz $BUILDDIR/$ARCH/$RELEASEDIR/$SYS
      # Install etc packages
      cp -f $SOURCESv30/etc/Default.tar.xz $BUILDDIR/$ARCH/$RELEASEDIR/$ZIP
      cp -f $SOURCESv30/etc/Permissions.tar.xz $BUILDDIR/$ARCH/$RELEASEDIR/$ZIP
      cp -f $SOURCESv30/etc/Preferred.tar.xz $BUILDDIR/$ARCH/$RELEASEDIR/$ZIP
      cp -f $SOURCESv30/etc/Sysconfig.tar.xz $BUILDDIR/$ARCH/$RELEASEDIR/$ZIP
      # Install overlay package
      cp -f $SOURCESv30/overlay/PlayStoreOverlay.tar.xz $BUILDDIR/$ARCH/$RELEASEDIR/$OVERLAY
      # Install priv-app packages
      cp -f $SOURCESv30/priv-app/ConfigUpdater.tar.xz $BUILDDIR/$ARCH/$RELEASEDIR/$CORE
      cp -f $SOURCESv30/priv-app/GoogleExtServices.tar.xz $BUILDDIR/$ARCH/$RELEASEDIR/$CORE
      cp -f $SOURCESv30/priv-app/GoogleServicesFramework.tar.xz $BUILDDIR/$ARCH/$RELEASEDIR/$CORE
      cp -f $SOURCESv30/priv-app/Phonesky.tar.xz $BUILDDIR/$ARCH/$RELEASEDIR/$CORE
      cp -f $SOURCESv30/priv-app/PrebuiltGmsCoreRvc.tar.xz $BUILDDIR/$ARCH/$RELEASEDIR/$CORE
      # Install AOSP packages
      cp -f $AOSPSOURCESv30/app/Messaging.tar.xz $BUILDDIR/$ARCH/$RELEASEDIR/$AOSPSYS
      cp -f $AOSPSOURCESv30/etc/Permissions.tar.xz $BUILDDIR/$ARCH/$RELEASEDIR/$AOSPZIP
      cp -f $AOSPSOURCESv30/priv-app/Contacts.tar.xz $BUILDDIR/$ARCH/$RELEASEDIR/$AOSPCORE
      cp -f $AOSPSOURCESv30/priv-app/Dialer.tar.xz $BUILDDIR/$ARCH/$RELEASEDIR/$AOSPCORE
      cp -f $AOSPSOURCESv30/priv-app/ManagedProvisioning.tar.xz $BUILDDIR/$ARCH/$RELEASEDIR/$AOSPCORE
      cp -f $AOSPSOURCESv30/priv-app/Provision.tar.xz $BUILDDIR/$ARCH/$RELEASEDIR/$AOSPCORE
      # Install SetupWizard packages
      cp -f $SETUPSOURCESv30/priv-app/AndroidMigratePrebuilt.tar.xz $BUILDDIR/$ARCH/$RELEASEDIR/$CORE
      cp -f $SETUPSOURCESv30/priv-app/SetupWizardPrebuilt.tar.xz $BUILDDIR/$ARCH/$RELEASEDIR/$CORE
      # Installer components
      cp -f $UPDATEBINARY $BUILDDIR/$ARCH/$RELEASEDIR/$METADIR/update-binary
      cp -f $UPDATERSCRIPT $BUILDDIR/$ARCH/$RELEASEDIR/$METADIR/updater-script
      cp -f $INSTALLER $BUILDDIR/$ARCH/$RELEASEDIR
      cp -f $LOGCATSCRIPT $BUILDDIR/$ARCH/$RELEASEDIR
      cp -f $BUSYBOX $BUILDDIR/$ARCH/$RELEASEDIR
      cp -f $AIK $BUILDDIR/$ARCH/$RELEASEDIR/$ZIP
      cp -f $API_30_KEYSTORE $BUILDDIR/$ARCH/$RELEASEDIR/$ZIP
      # Create utility script
      makeutilityscript
      replace_line $BUILDDIR/$ARCH/$RELEASEDIR/util_functions.sh REL="" REL="$GAPPS_RELEASE"
      replace_line $BUILDDIR/$ARCH/$RELEASEDIR/util_functions.sh ZIPTYPE="" ZIPTYPE="$ZIPTYPE"
      replace_line $BUILDDIR/$ARCH/$RELEASEDIR/util_functions.sh TARGET_GAPPS_RELEASE="" TARGET_GAPPS_RELEASE="$TARGET_GAPPS_RELEASE"
      replace_line $BUILDDIR/$ARCH/$RELEASEDIR/util_functions.sh TARGET_DIRTY_INSTALL="" TARGET_DIRTY_INSTALL="$TARGET_DIRTY_INSTALL"
      replace_line $BUILDDIR/$ARCH/$RELEASEDIR/util_functions.sh TARGET_ANDROID_SDK="" TARGET_ANDROID_SDK="$TARGET_ANDROID_SDK_V30"
      replace_line $BUILDDIR/$ARCH/$RELEASEDIR/util_functions.sh TARGET_ANDROID_ARCH="" TARGET_ANDROID_ARCH="$TARGET_ANDROID_ARCH_64"
      replace_line $BUILDDIR/$ARCH/$RELEASEDIR/util_functions.sh ARMEABI="" ARMEABI="$ARMEABI"
      replace_line $BUILDDIR/$ARCH/$RELEASEDIR/util_functions.sh AARCH64="" AARCH64="$AARCH64"
      replace_line $BUILDDIR/$ARCH/$RELEASEDIR/util_functions.sh TARGET_RELEASE_TAG="" TARGET_RELEASE_TAG="$TARGET_RELEASE_TAG"
      replace_line $BUILDDIR/$ARCH/$RELEASEDIR/util_functions.sh TARGET_CONFIG_VERSION="" TARGET_CONFIG_VERSION="$TARGET_CONFIG_VERSION"
      # Create build property file
      makegprop
      replace_line $BUILDDIR/$ARCH/$RELEASEDIR/g.prop CustomGAppsPackage= CustomGAppsPackage="$CustomGAppsPackage"
      replace_line $BUILDDIR/$ARCH/$RELEASEDIR/g.prop platform= platform="$platform_64"
      replace_line $BUILDDIR/$ARCH/$RELEASEDIR/g.prop sdk= sdk="$sdk_30"
      replace_line $BUILDDIR/$ARCH/$RELEASEDIR/g.prop version= version="$version_30"
      replace_line $BUILDDIR/$ARCH/$RELEASEDIR/g.prop BuildDate= BuildDate="$BuildDate"
      replace_line $BUILDDIR/$ARCH/$RELEASEDIR/g.prop BuildID= BuildID="$BuildID"
      replace_line $BUILDDIR/$ARCH/$RELEASEDIR/g.prop Developer= Developer="$Developer"
      # Add OTA script
      makeota
      # Create OTA property file
      makeotaprop
      # Create LICENSE
      makelicense
      # Create ZIP
      cd $BUILDDIR/$ARCH/$RELEASEDIR
      zip -qr9 ${RELEASEDIR}.zip *
      cd ../../..
      mv $BUILDDIR/$ARCH/$RELEASEDIR/${RELEASEDIR}.zip $OUTDIR/$ARCH/${RELEASEDIR}.zip
      # Sign ZIP
      java -jar $ZIPSIGNER $OUTDIR/$ARCH/${RELEASEDIR}.zip $OUTDIR/$ARCH/${RELEASEDIR}_signed.zip 2>/dev/null
      # Set build API in global environment
      [ "$(grep -w -o TARGET_API_30 $OUTDIR/ENV/env_api.sh 2>/dev/null)" ] || echo "TARGET_API_30" >> $OUTDIR/ENV/env_api.sh
      # List signed ZIP
      ls $OUTDIR/$ARCH/${RELEASEDIR}_signed.zip
      # Wipe unsigned ZIP
      rm -rf $OUTDIR/$ARCH/${RELEASEDIR}.zip
    fi
    # API 31
    if [ "$API" == "31" ]; then
      # Install variable; Do not modify
      TARGET_ANDROID_SDK_V31='"31"'
      # Build property variable; Do not modify
      sdk_31="31"
      version_31="12.0.0"
      echo "Generating BiTGApps package for $ARCH with API level $API"
      # Create release directory
      mkdir "$BUILDDIR/$ARCH/BiTGApps-${ARCH}-12.0.0-${COMMONGAPPSRELEASE}"
      RELEASEDIR="BiTGApps-${ARCH}-12.0.0-${COMMONGAPPSRELEASE}"
      # Create package components
      mkdir -p $BUILDDIR/$ARCH/$RELEASEDIR/$METADIR
      mkdir -p $BUILDDIR/$ARCH/$RELEASEDIR/$ZIP
      mkdir -p $BUILDDIR/$ARCH/$RELEASEDIR/$CORE
      mkdir -p $BUILDDIR/$ARCH/$RELEASEDIR/$SYS
      mkdir -p $BUILDDIR/$ARCH/$RELEASEDIR/$AOSPCORE
      mkdir -p $BUILDDIR/$ARCH/$RELEASEDIR/$AOSPSYS
      mkdir -p $BUILDDIR/$ARCH/$RELEASEDIR/$OVERLAY
      # Install app packages
      cp -f $SOURCESv31/app/GoogleCalendarSyncAdapter.tar.xz $BUILDDIR/$ARCH/$RELEASEDIR/$SYS
      cp -f $SOURCESv31/app/GoogleContactsSyncAdapter.tar.xz $BUILDDIR/$ARCH/$RELEASEDIR/$SYS
      cp -f $SOURCESv31/app/GoogleExtShared.tar.xz $BUILDDIR/$ARCH/$RELEASEDIR/$SYS
      # Install etc packages
      cp -f $SOURCESv31/etc/Default.tar.xz $BUILDDIR/$ARCH/$RELEASEDIR/$ZIP
      cp -f $SOURCESv31/etc/Permissions.tar.xz $BUILDDIR/$ARCH/$RELEASEDIR/$ZIP
      cp -f $SOURCESv31/etc/Preferred.tar.xz $BUILDDIR/$ARCH/$RELEASEDIR/$ZIP
      cp -f $SOURCESv31/etc/Sysconfig.tar.xz $BUILDDIR/$ARCH/$RELEASEDIR/$ZIP
      # Install overlay package
      cp -f $SOURCESv31/overlay/PlayStoreOverlay.tar.xz $BUILDDIR/$ARCH/$RELEASEDIR/$OVERLAY
      # Install priv-app packages
      cp -f $SOURCESv31/priv-app/ConfigUpdater.tar.xz $BUILDDIR/$ARCH/$RELEASEDIR/$CORE
      cp -f $SOURCESv31/priv-app/GoogleExtServices.tar.xz $BUILDDIR/$ARCH/$RELEASEDIR/$CORE
      cp -f $SOURCESv31/priv-app/GoogleServicesFramework.tar.xz $BUILDDIR/$ARCH/$RELEASEDIR/$CORE
      cp -f $SOURCESv31/priv-app/Phonesky.tar.xz $BUILDDIR/$ARCH/$RELEASEDIR/$CORE
      cp -f $SOURCESv31/priv-app/PrebuiltGmsCoreSvc.tar.xz $BUILDDIR/$ARCH/$RELEASEDIR/$CORE
      # Install AOSP packages
      cp -f $AOSPSOURCESv31/app/Messaging.tar.xz $BUILDDIR/$ARCH/$RELEASEDIR/$AOSPSYS
      cp -f $AOSPSOURCESv31/etc/Permissions.tar.xz $BUILDDIR/$ARCH/$RELEASEDIR/$AOSPZIP
      cp -f $AOSPSOURCESv31/priv-app/Contacts.tar.xz $BUILDDIR/$ARCH/$RELEASEDIR/$AOSPCORE
      cp -f $AOSPSOURCESv31/priv-app/Dialer.tar.xz $BUILDDIR/$ARCH/$RELEASEDIR/$AOSPCORE
      cp -f $AOSPSOURCESv31/priv-app/ManagedProvisioning.tar.xz $BUILDDIR/$ARCH/$RELEASEDIR/$AOSPCORE
      cp -f $AOSPSOURCESv31/priv-app/Provision.tar.xz $BUILDDIR/$ARCH/$RELEASEDIR/$AOSPCORE
      # Install SetupWizard packages
      cp -f $SETUPSOURCESv31/priv-app/AndroidMigratePrebuilt.tar.xz $BUILDDIR/$ARCH/$RELEASEDIR/$CORE
      cp -f $SETUPSOURCESv31/priv-app/SetupWizardPrebuilt.tar.xz $BUILDDIR/$ARCH/$RELEASEDIR/$CORE
      # Installer components
      cp -f $UPDATEBINARY $BUILDDIR/$ARCH/$RELEASEDIR/$METADIR/update-binary
      cp -f $UPDATERSCRIPT $BUILDDIR/$ARCH/$RELEASEDIR/$METADIR/updater-script
      cp -f $INSTALLER $BUILDDIR/$ARCH/$RELEASEDIR
      cp -f $LOGCATSCRIPT $BUILDDIR/$ARCH/$RELEASEDIR
      cp -f $BUSYBOX $BUILDDIR/$ARCH/$RELEASEDIR
      cp -f $AIK $BUILDDIR/$ARCH/$RELEASEDIR/$ZIP
      cp -f $API_31_KEYSTORE $BUILDDIR/$ARCH/$RELEASEDIR/$ZIP
      # Create utility script
      makeutilityscript
      replace_line $BUILDDIR/$ARCH/$RELEASEDIR/util_functions.sh REL="" REL="$GAPPS_RELEASE"
      replace_line $BUILDDIR/$ARCH/$RELEASEDIR/util_functions.sh ZIPTYPE="" ZIPTYPE="$ZIPTYPE"
      replace_line $BUILDDIR/$ARCH/$RELEASEDIR/util_functions.sh TARGET_GAPPS_RELEASE="" TARGET_GAPPS_RELEASE="$TARGET_GAPPS_RELEASE"
      replace_line $BUILDDIR/$ARCH/$RELEASEDIR/util_functions.sh TARGET_DIRTY_INSTALL="" TARGET_DIRTY_INSTALL="$TARGET_DIRTY_INSTALL"
      replace_line $BUILDDIR/$ARCH/$RELEASEDIR/util_functions.sh TARGET_ANDROID_SDK="" TARGET_ANDROID_SDK="$TARGET_ANDROID_SDK_V31"
      replace_line $BUILDDIR/$ARCH/$RELEASEDIR/util_functions.sh TARGET_ANDROID_ARCH="" TARGET_ANDROID_ARCH="$TARGET_ANDROID_ARCH_64"
      replace_line $BUILDDIR/$ARCH/$RELEASEDIR/util_functions.sh ARMEABI="" ARMEABI="$ARMEABI"
      replace_line $BUILDDIR/$ARCH/$RELEASEDIR/util_functions.sh AARCH64="" AARCH64="$AARCH64"
      replace_line $BUILDDIR/$ARCH/$RELEASEDIR/util_functions.sh TARGET_RELEASE_TAG="" TARGET_RELEASE_TAG="$TARGET_RELEASE_TAG"
      replace_line $BUILDDIR/$ARCH/$RELEASEDIR/util_functions.sh TARGET_CONFIG_VERSION="" TARGET_CONFIG_VERSION="$TARGET_CONFIG_VERSION"
      # Create build property file
      makegprop
      replace_line $BUILDDIR/$ARCH/$RELEASEDIR/g.prop CustomGAppsPackage= CustomGAppsPackage="$CustomGAppsPackage"
      replace_line $BUILDDIR/$ARCH/$RELEASEDIR/g.prop platform= platform="$platform_64"
      replace_line $BUILDDIR/$ARCH/$RELEASEDIR/g.prop sdk= sdk="$sdk_31"
      replace_line $BUILDDIR/$ARCH/$RELEASEDIR/g.prop version= version="$version_31"
      replace_line $BUILDDIR/$ARCH/$RELEASEDIR/g.prop BuildDate= BuildDate="$BuildDate"
      replace_line $BUILDDIR/$ARCH/$RELEASEDIR/g.prop BuildID= BuildID="$BuildID"
      replace_line $BUILDDIR/$ARCH/$RELEASEDIR/g.prop Developer= Developer="$Developer"
      # Add OTA script
      makeota
      # Create OTA property file
      makeotaprop
      # Create LICENSE
      makelicense
      # Create ZIP
      cd $BUILDDIR/$ARCH/$RELEASEDIR
      zip -qr9 ${RELEASEDIR}.zip *
      cd ../../..
      mv $BUILDDIR/$ARCH/$RELEASEDIR/${RELEASEDIR}.zip $OUTDIR/$ARCH/${RELEASEDIR}.zip
      # Sign ZIP
      java -jar $ZIPSIGNER $OUTDIR/$ARCH/${RELEASEDIR}.zip $OUTDIR/$ARCH/${RELEASEDIR}_signed.zip 2>/dev/null
      # Set build API in global environment
      [ "$(grep -w -o TARGET_API_31 $OUTDIR/ENV/env_api.sh 2>/dev/null)" ] || echo "TARGET_API_31" >> $OUTDIR/ENV/env_api.sh
      # List signed ZIP
      ls $OUTDIR/$ARCH/${RELEASEDIR}_signed.zip
      # Wipe unsigned ZIP
      rm -rf $OUTDIR/$ARCH/${RELEASEDIR}.zip
    fi
  fi
}

# Build
makegapps
