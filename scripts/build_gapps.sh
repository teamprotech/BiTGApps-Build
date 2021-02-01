#!/bin/bash
#
##############################################################
# File name       : build_gapps.sh
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
if { [ "$1" != "arm" ] && [ "$1" != "arm64" ]; } || [ -z "$2" ]; then
  exit 1
fi

# Check API
case "$API" in
  25) PLATFORM="7.1" ;;
  26) PLATFORM="8.0" ;;
  27) PLATFORM="8.1" ;;
  28) PLATFORM="9.0" ;;
  29) PLATFORM="10.0" ;;
  30) PLATFORM="11.0" ;;
esac

# Set defaults
ARCH="$1"
API="$2"
COMMONRELEASE="$COMMONRELEASE"

# Version conflict
TARGET_VERSION_N1="7.1.1"
TARGET_VERSION_N2="7.1.2"

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

# Set AOSP package sources
AOSPSOURCESv25="sources/aosp-sources/$ARCH/25"
AOSPSOURCESv26="sources/aosp-sources/$ARCH/26"
AOSPSOURCESv27="sources/aosp-sources/$ARCH/27"
AOSPSOURCESv28="sources/aosp-sources/$ARCH/28"
AOSPSOURCESv29="sources/aosp-sources/$ARCH/29"
AOSPSOURCESv30="sources/aosp-sources/$ARCH/30"

# Set installer sources
UPDATEBINARY="BiTGApps/scripts/update-binary"
UPDATESCRIPT="BiTGApps/scripts/updater-script"
INSTALLER="BiTGApps/scripts/installer.sh"
CONFIG="BiTGApps/scripts/config.prop"
DATA="BiTGApps/scripts/data.prop"
BOOTLOG="BiTGApps/scripts/init.bootlog.rc"
PM="BiTGApps/scripts/pm.sh"
LICENSE="BiTGApps/scripts/LICENSE"
BUSYBOX="BiTGApps/tools/busybox-resources/busybox-arm"
SQLITE_ARMEABI="BiTGApps/tools/sqlite-resources/armeabi-v7a/sqlite-static"
SQLITE_AARCH64="BiTGApps/tools/sqlite-resources/arm64-v8a/sqlite-static"
ZIPALIGN_ARMEABI="BiTGApps/tools/zipalign-resources/armeabi-v7a/zipalign-static"
ZIPALIGN_AARCH64="BiTGApps/tools/zipalign-resources/arm64-v8a/zipalign-static"

# Set ZIP structure
METADIR="META-INF/com/google/android"
ZIP="zip"
CORE="$ZIP/core"
SYS="$ZIP/sys"
AOSPZIP="$ZIP/aosp"
AOSPCORE="$ZIP/aosp/core"
AOSPSYS="$ZIP/aosp/sys"

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
TARGET_GAPPS_RELEASE=""
TARGET_DIRTY_INSTALL=""
TARGET_ANDROID_SDK=""
TARGET_ANDROID_ARCH=""
ARMEABI=""
AARCH64=""
TARGET_RELEASE_TAG=""' >"$BUILDDIR/$ARCH/$RELEASEDIR/util_functions.sh"
}

# Set build property file
makegprop() {
echo 'CustomGAppsPackage=
platform=
sdk=
version=
BuildDate=
BuildID=
Developer=' >"$BUILDDIR/$ARCH/$RELEASEDIR/g.prop"
}

# Main
makegapps() {
  # Create build directory
  test -d $BUILDDIR || mkdir $BUILDDIR
  test -d $BUILDDIR/$ARCH || mkdir $BUILDDIR/$ARCH
  # Create out directory
  test -d $OUTDIR || mkdir $OUTDIR
  test -d $OUTDIR/$ARCH || mkdir $OUTDIR/$ARCH
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
      echo "Generating BiTGApps package for $ARCH with API level $API"
      if [ "$TARGET_VERSION_N1" == "7.1.1" ]; then
        # Build property variable; Do not modify
        version_N1="7.1.1"
        # Create release directory
        mkdir $BUILDDIR/$ARCH/BiTGApps-${ARCH}-7.1.1-${COMMONRELEASE}
        RELEASEDIR="BiTGApps-${ARCH}-7.1.1-${COMMONRELEASE}"
        # Create package components
        mkdir -p $BUILDDIR/$ARCH/$RELEASEDIR/$METADIR
        mkdir -p $BUILDDIR/$ARCH/$RELEASEDIR/$ZIP
        mkdir -p $BUILDDIR/$ARCH/$RELEASEDIR/$CORE
        mkdir -p $BUILDDIR/$ARCH/$RELEASEDIR/$SYS
        mkdir -p $BUILDDIR/$ARCH/$RELEASEDIR/$AOSPCORE
        mkdir -p $BUILDDIR/$ARCH/$RELEASEDIR/$AOSPSYS
        # Install app packages
        cp -f $SOURCESv25/app/FaceLock.tar.xz $BUILDDIR/$ARCH/$RELEASEDIR/$SYS
        cp -f $SOURCESv25/app/GoogleCalendarSyncAdapter.tar.xz $BUILDDIR/$ARCH/$RELEASEDIR/$SYS
        cp -f $SOURCESv25/app/GoogleContactsSyncAdapter.tar.xz $BUILDDIR/$ARCH/$RELEASEDIR/$SYS
        cp -f $SOURCESv25/app/GoogleExtShared.tar.xz $BUILDDIR/$ARCH/$RELEASEDIR/$SYS
        cp -f $AOSPSOURCESv25/app/Messaging.tar.xz $BUILDDIR/$ARCH/$RELEASEDIR/$AOSPSYS
        # Install etc packages
        cp -f $SOURCESv25/etc/Default.tar.xz $BUILDDIR/$ARCH/$RELEASEDIR/$ZIP
        cp -f $SOURCESv25/etc/Permissions.tar.xz $BUILDDIR/$ARCH/$RELEASEDIR/$ZIP
        cp -f $SOURCESv25/etc/Preferred.tar.xz $BUILDDIR/$ARCH/$RELEASEDIR/$ZIP
        cp -f $SOURCESv25/etc/Sysconfig.tar.xz $BUILDDIR/$ARCH/$RELEASEDIR/$ZIP
        cp -f $AOSPSOURCESv25/etc/Permissions.tar.xz $BUILDDIR/$ARCH/$RELEASEDIR/$AOSPZIP
        # Install framework package
        cp -f $SOURCESv25/framework/Framework.tar.xz $BUILDDIR/$ARCH/$RELEASEDIR/$ZIP
        # Install lib package
        cp -f $SOURCESv25/lib/facelock_lib32.tar.xz $BUILDDIR/$ARCH/$RELEASEDIR/$SYS
        # Install priv-app package
        cp -f $SOURCESv25/priv-app/ConfigUpdater.tar.xz $BUILDDIR/$ARCH/$RELEASEDIR/$CORE
        cp -f $SOURCESv25/priv-app/GoogleBackupTransport.tar.xz $BUILDDIR/$ARCH/$RELEASEDIR/$CORE
        cp -f $SOURCESv25/priv-app/GoogleOneTimeInitializer.tar.xz $BUILDDIR/$ARCH/$RELEASEDIR/$CORE
        cp -f $SOURCESv25/priv-app/GmsCoreSetupPrebuilt.tar.xz $BUILDDIR/$ARCH/$RELEASEDIR/$CORE
        cp -f $SOURCESv25/priv-app/GoogleExtServices.tar.xz $BUILDDIR/$ARCH/$RELEASEDIR/$CORE
        cp -f $SOURCESv25/priv-app/GoogleLoginService.tar.xz $BUILDDIR/$ARCH/$RELEASEDIR/$CORE
        cp -f $SOURCESv25/priv-app/GoogleServicesFramework.tar.xz $BUILDDIR/$ARCH/$RELEASEDIR/$CORE
        cp -f $SOURCESv25/priv-app/Phonesky.tar.xz $BUILDDIR/$ARCH/$RELEASEDIR/$CORE
        cp -f $SOURCESv25/priv-app/PrebuiltGmsCore.tar.xz $BUILDDIR/$ARCH/$RELEASEDIR/$CORE
        cp -f $SOURCESv25/priv-app/SetupWizardPrebuilt.tar.xz $BUILDDIR/$ARCH/$RELEASEDIR/$CORE
        cp -f $AOSPSOURCESv25/priv-app/Contacts.tar.xz $BUILDDIR/$ARCH/$RELEASEDIR/$AOSPCORE
        cp -f $AOSPSOURCESv25/priv-app/Dialer.tar.xz $BUILDDIR/$ARCH/$RELEASEDIR/$AOSPCORE
        cp -f $AOSPSOURCESv25/priv-app/ManagedProvisioning.tar.xz $BUILDDIR/$ARCH/$RELEASEDIR/$AOSPCORE
        cp -f $AOSPSOURCESv25/priv-app/Provision.tar.xz $BUILDDIR/$ARCH/$RELEASEDIR/$AOSPCORE
        # Installer components
        cp -f $UPDATEBINARY $BUILDDIR/$ARCH/$RELEASEDIR/$METADIR
        cp -f $UPDATESCRIPT $BUILDDIR/$ARCH/$RELEASEDIR/$METADIR
        cp -f $INSTALLER $BUILDDIR/$ARCH/$RELEASEDIR
        cp -f $CONFIG $BUILDDIR/$ARCH/$RELEASEDIR
        cp -f $DATA $BUILDDIR/$ARCH/$RELEASEDIR
        cp -f $BOOTLOG $BUILDDIR/$ARCH/$RELEASEDIR
        cp -f $LICENSE $BUILDDIR/$ARCH/$RELEASEDIR
        cp -f $BUSYBOX $BUILDDIR/$ARCH/$RELEASEDIR
        cp -f $SQLITE_ARMEABI $BUILDDIR/$ARCH/$RELEASEDIR/sqlite3
        cp -f $ZIPALIGN_ARMEABI $BUILDDIR/$ARCH/$RELEASEDIR/zipalign
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
        # Create build property file
        makegprop
        replace_line $BUILDDIR/$ARCH/$RELEASEDIR/g.prop CustomGAppsPackage= CustomGAppsPackage="$CustomGAppsPackage"
        replace_line $BUILDDIR/$ARCH/$RELEASEDIR/g.prop platform= platform="$platform_32"
        replace_line $BUILDDIR/$ARCH/$RELEASEDIR/g.prop sdk= sdk="$sdk_25"
        replace_line $BUILDDIR/$ARCH/$RELEASEDIR/g.prop version= version="$version_N1"
        replace_line $BUILDDIR/$ARCH/$RELEASEDIR/g.prop BuildDate= BuildDate="$BuildDate"
        replace_line $BUILDDIR/$ARCH/$RELEASEDIR/g.prop BuildID= BuildID="$BuildID"
        replace_line $BUILDDIR/$ARCH/$RELEASEDIR/g.prop Developer= Developer="$Developer"
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
      if [ "$TARGET_VERSION_N2" == "7.1.2" ]; then
        # Build property variable; Do not modify
        version_N2="7.1.2"
        # Create release directory
        mkdir $BUILDDIR/$ARCH/BiTGApps-${ARCH}-7.1.2-${COMMONRELEASE}
        RELEASEDIR="BiTGApps-${ARCH}-7.1.2-${COMMONRELEASE}"
        # Create package components
        mkdir -p $BUILDDIR/$ARCH/$RELEASEDIR/$METADIR
        mkdir -p $BUILDDIR/$ARCH/$RELEASEDIR/$ZIP
        mkdir -p $BUILDDIR/$ARCH/$RELEASEDIR/$CORE
        mkdir -p $BUILDDIR/$ARCH/$RELEASEDIR/$SYS
        mkdir -p $BUILDDIR/$ARCH/$RELEASEDIR/$AOSPCORE
        mkdir -p $BUILDDIR/$ARCH/$RELEASEDIR/$AOSPSYS
        # Install app packages
        cp -f $SOURCESv25/app/FaceLock.tar.xz $BUILDDIR/$ARCH/$RELEASEDIR/$SYS
        cp -f $SOURCESv25/app/GoogleCalendarSyncAdapter.tar.xz $BUILDDIR/$ARCH/$RELEASEDIR/$SYS
        cp -f $SOURCESv25/app/GoogleContactsSyncAdapter.tar.xz $BUILDDIR/$ARCH/$RELEASEDIR/$SYS
        cp -f $SOURCESv25/app/GoogleExtShared.tar.xz $BUILDDIR/$ARCH/$RELEASEDIR/$SYS
        cp -f $AOSPSOURCESv25/app/Messaging.tar.xz $BUILDDIR/$ARCH/$RELEASEDIR/$AOSPSYS
        # Install etc packages
        cp -f $SOURCESv25/etc/Default.tar.xz $BUILDDIR/$ARCH/$RELEASEDIR/$ZIP
        cp -f $SOURCESv25/etc/Permissions.tar.xz $BUILDDIR/$ARCH/$RELEASEDIR/$ZIP
        cp -f $SOURCESv25/etc/Preferred.tar.xz $BUILDDIR/$ARCH/$RELEASEDIR/$ZIP
        cp -f $SOURCESv25/etc/Sysconfig.tar.xz $BUILDDIR/$ARCH/$RELEASEDIR/$ZIP
        cp -f $AOSPSOURCESv25/etc/Permissions.tar.xz $BUILDDIR/$ARCH/$RELEASEDIR/$AOSPZIP
        # Install framework package
        cp -f $SOURCESv25/framework/Framework.tar.xz $BUILDDIR/$ARCH/$RELEASEDIR/$ZIP
        # Install lib package
        cp -f $SOURCESv25/lib/facelock_lib32.tar.xz $BUILDDIR/$ARCH/$RELEASEDIR/$SYS
        # Install priv-app package
        cp -f $SOURCESv25/priv-app/ConfigUpdater.tar.xz $BUILDDIR/$ARCH/$RELEASEDIR/$CORE
        cp -f $SOURCESv25/priv-app/GoogleBackupTransport.tar.xz $BUILDDIR/$ARCH/$RELEASEDIR/$CORE
        cp -f $SOURCESv25/priv-app/GoogleOneTimeInitializer.tar.xz $BUILDDIR/$ARCH/$RELEASEDIR/$CORE
        cp -f $SOURCESv25/priv-app/GmsCoreSetupPrebuilt.tar.xz $BUILDDIR/$ARCH/$RELEASEDIR/$CORE
        cp -f $SOURCESv25/priv-app/GoogleExtServices.tar.xz $BUILDDIR/$ARCH/$RELEASEDIR/$CORE
        cp -f $SOURCESv25/priv-app/GoogleLoginService.tar.xz $BUILDDIR/$ARCH/$RELEASEDIR/$CORE
        cp -f $SOURCESv25/priv-app/GoogleServicesFramework.tar.xz $BUILDDIR/$ARCH/$RELEASEDIR/$CORE
        cp -f $SOURCESv25/priv-app/Phonesky.tar.xz $BUILDDIR/$ARCH/$RELEASEDIR/$CORE
        cp -f $SOURCESv25/priv-app/PrebuiltGmsCore.tar.xz $BUILDDIR/$ARCH/$RELEASEDIR/$CORE
        cp -f $SOURCESv25/priv-app/SetupWizardPrebuilt.tar.xz $BUILDDIR/$ARCH/$RELEASEDIR/$CORE
        cp -f $AOSPSOURCESv25/priv-app/Contacts.tar.xz $BUILDDIR/$ARCH/$RELEASEDIR/$AOSPCORE
        cp -f $AOSPSOURCESv25/priv-app/Dialer.tar.xz $BUILDDIR/$ARCH/$RELEASEDIR/$AOSPCORE
        cp -f $AOSPSOURCESv25/priv-app/ManagedProvisioning.tar.xz $BUILDDIR/$ARCH/$RELEASEDIR/$AOSPCORE
        cp -f $AOSPSOURCESv25/priv-app/Provision.tar.xz $BUILDDIR/$ARCH/$RELEASEDIR/$AOSPCORE
        # Installer components
        cp -f $UPDATEBINARY $BUILDDIR/$ARCH/$RELEASEDIR/$METADIR
        cp -f $UPDATESCRIPT $BUILDDIR/$ARCH/$RELEASEDIR/$METADIR
        cp -f $INSTALLER $BUILDDIR/$ARCH/$RELEASEDIR
        cp -f $CONFIG $BUILDDIR/$ARCH/$RELEASEDIR
        cp -f $DATA $BUILDDIR/$ARCH/$RELEASEDIR
        cp -f $BOOTLOG $BUILDDIR/$ARCH/$RELEASEDIR
        cp -f $LICENSE $BUILDDIR/$ARCH/$RELEASEDIR
        cp -f $BUSYBOX $BUILDDIR/$ARCH/$RELEASEDIR
        cp -f $SQLITE_ARMEABI $BUILDDIR/$ARCH/$RELEASEDIR/sqlite3
        cp -f $ZIPALIGN_ARMEABI $BUILDDIR/$ARCH/$RELEASEDIR/zipalign
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
        # Create build property file
        makegprop
        replace_line $BUILDDIR/$ARCH/$RELEASEDIR/g.prop CustomGAppsPackage= CustomGAppsPackage="$CustomGAppsPackage"
        replace_line $BUILDDIR/$ARCH/$RELEASEDIR/g.prop platform= platform="$platform_32"
        replace_line $BUILDDIR/$ARCH/$RELEASEDIR/g.prop sdk= sdk="$sdk_25"
        replace_line $BUILDDIR/$ARCH/$RELEASEDIR/g.prop version= version="$version_N2"
        replace_line $BUILDDIR/$ARCH/$RELEASEDIR/g.prop BuildDate= BuildDate="$BuildDate"
        replace_line $BUILDDIR/$ARCH/$RELEASEDIR/g.prop BuildID= BuildID="$BuildID"
        replace_line $BUILDDIR/$ARCH/$RELEASEDIR/g.prop Developer= Developer="$Developer"
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
      mkdir $BUILDDIR/$ARCH/BiTGApps-${ARCH}-8.0.0-${COMMONRELEASE}
      RELEASEDIR="BiTGApps-${ARCH}-8.0.0-${COMMONRELEASE}"
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
      cp -f $AOSPSOURCESv26/app/Messaging.tar.xz $BUILDDIR/$ARCH/$RELEASEDIR/$AOSPSYS
      # Install etc packages
      cp -f $SOURCESv26/etc/Default.tar.xz $BUILDDIR/$ARCH/$RELEASEDIR/$ZIP
      cp -f $SOURCESv26/etc/Permissions.tar.xz $BUILDDIR/$ARCH/$RELEASEDIR/$ZIP
      cp -f $SOURCESv26/etc/Preferred.tar.xz $BUILDDIR/$ARCH/$RELEASEDIR/$ZIP
      cp -f $SOURCESv26/etc/Sysconfig.tar.xz $BUILDDIR/$ARCH/$RELEASEDIR/$ZIP
      cp -f $AOSPSOURCESv26/etc/Permissions.tar.xz $BUILDDIR/$ARCH/$RELEASEDIR/$AOSPZIP
      # Install framework package
      cp -f $SOURCESv26/framework/Framework.tar.xz $BUILDDIR/$ARCH/$RELEASEDIR/$ZIP
      # Install lib package
      cp -f $SOURCESv26/lib/facelock_lib32.tar.xz $BUILDDIR/$ARCH/$RELEASEDIR/$SYS
      # Install priv-app package
      cp -f $SOURCESv26/priv-app/ConfigUpdater.tar.xz $BUILDDIR/$ARCH/$RELEASEDIR/$CORE
      cp -f $SOURCESv26/priv-app/GoogleBackupTransport.tar.xz $BUILDDIR/$ARCH/$RELEASEDIR/$CORE
      cp -f $SOURCESv26/priv-app/GoogleOneTimeInitializer.tar.xz $BUILDDIR/$ARCH/$RELEASEDIR/$CORE
      cp -f $SOURCESv26/priv-app/GmsCoreSetupPrebuilt.tar.xz $BUILDDIR/$ARCH/$RELEASEDIR/$CORE
      cp -f $SOURCESv26/priv-app/GoogleExtServices.tar.xz $BUILDDIR/$ARCH/$RELEASEDIR/$CORE
      cp -f $SOURCESv26/priv-app/GoogleServicesFramework.tar.xz $BUILDDIR/$ARCH/$RELEASEDIR/$CORE
      cp -f $SOURCESv26/priv-app/Phonesky.tar.xz $BUILDDIR/$ARCH/$RELEASEDIR/$CORE
      cp -f $SOURCESv26/priv-app/PrebuiltGmsCorePix.tar.xz $BUILDDIR/$ARCH/$RELEASEDIR/$CORE
      cp -f $SOURCESv26/priv-app/SetupWizardPrebuilt.tar.xz $BUILDDIR/$ARCH/$RELEASEDIR/$CORE
      cp -f $AOSPSOURCESv26/priv-app/Contacts.tar.xz $BUILDDIR/$ARCH/$RELEASEDIR/$AOSPCORE
      cp -f $AOSPSOURCESv26/priv-app/Dialer.tar.xz $BUILDDIR/$ARCH/$RELEASEDIR/$AOSPCORE
      cp -f $AOSPSOURCESv26/priv-app/ManagedProvisioning.tar.xz $BUILDDIR/$ARCH/$RELEASEDIR/$AOSPCORE
      cp -f $AOSPSOURCESv26/priv-app/Provision.tar.xz $BUILDDIR/$ARCH/$RELEASEDIR/$AOSPCORE
      # Installer components
      cp -f $UPDATEBINARY $BUILDDIR/$ARCH/$RELEASEDIR/$METADIR
      cp -f $UPDATESCRIPT $BUILDDIR/$ARCH/$RELEASEDIR/$METADIR
      cp -f $INSTALLER $BUILDDIR/$ARCH/$RELEASEDIR
      cp -f $CONFIG $BUILDDIR/$ARCH/$RELEASEDIR
      cp -f $DATA $BUILDDIR/$ARCH/$RELEASEDIR
      cp -f $BOOTLOG $BUILDDIR/$ARCH/$RELEASEDIR
      cp -f $LICENSE $BUILDDIR/$ARCH/$RELEASEDIR
      cp -f $BUSYBOX $BUILDDIR/$ARCH/$RELEASEDIR
      cp -f $SQLITE_ARMEABI $BUILDDIR/$ARCH/$RELEASEDIR/sqlite3
      cp -f $ZIPALIGN_ARMEABI $BUILDDIR/$ARCH/$RELEASEDIR/zipalign
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
      # Create build property file
      makegprop
      replace_line $BUILDDIR/$ARCH/$RELEASEDIR/g.prop CustomGAppsPackage= CustomGAppsPackage="$CustomGAppsPackage"
      replace_line $BUILDDIR/$ARCH/$RELEASEDIR/g.prop platform= platform="$platform_32"
      replace_line $BUILDDIR/$ARCH/$RELEASEDIR/g.prop sdk= sdk="$sdk_26"
      replace_line $BUILDDIR/$ARCH/$RELEASEDIR/g.prop version= version="$version_26"
      replace_line $BUILDDIR/$ARCH/$RELEASEDIR/g.prop BuildDate= BuildDate="$BuildDate"
      replace_line $BUILDDIR/$ARCH/$RELEASEDIR/g.prop BuildID= BuildID="$BuildID"
      replace_line $BUILDDIR/$ARCH/$RELEASEDIR/g.prop Developer= Developer="$Developer"
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
    # API 27
    if [ "$API" == "27" ]; then
      # Install variable; Do not modify
      TARGET_ANDROID_SDK_V27='"27"'
      # Build property variable; Do not modify
      sdk_27="27"
      version_27="8.1.0"
      echo "Generating BiTGApps package for $ARCH with API level $API"
      # Create release directory
      mkdir $BUILDDIR/$ARCH/BiTGApps-${ARCH}-8.1.0-${COMMONRELEASE}
      RELEASEDIR="BiTGApps-${ARCH}-8.1.0-${COMMONRELEASE}"
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
      cp -f $AOSPSOURCESv27/app/Messaging.tar.xz $BUILDDIR/$ARCH/$RELEASEDIR/$AOSPSYS
      # Install etc packages
      cp -f $SOURCESv27/etc/Default.tar.xz $BUILDDIR/$ARCH/$RELEASEDIR/$ZIP
      cp -f $SOURCESv27/etc/Permissions.tar.xz $BUILDDIR/$ARCH/$RELEASEDIR/$ZIP
      cp -f $SOURCESv27/etc/Preferred.tar.xz $BUILDDIR/$ARCH/$RELEASEDIR/$ZIP
      cp -f $SOURCESv27/etc/Sysconfig.tar.xz $BUILDDIR/$ARCH/$RELEASEDIR/$ZIP
      cp -f $AOSPSOURCESv27/etc/Permissions.tar.xz $BUILDDIR/$ARCH/$RELEASEDIR/$AOSPZIP
      # Install framework package
      cp -f $SOURCESv27/framework/Framework.tar.xz $BUILDDIR/$ARCH/$RELEASEDIR/$ZIP
      # Install lib package
      cp -f $SOURCESv27/lib/facelock_lib32.tar.xz $BUILDDIR/$ARCH/$RELEASEDIR/$SYS
      # Install priv-app package
      cp -f $SOURCESv27/priv-app/ConfigUpdater.tar.xz $BUILDDIR/$ARCH/$RELEASEDIR/$CORE
      cp -f $SOURCESv27/priv-app/GoogleBackupTransport.tar.xz $BUILDDIR/$ARCH/$RELEASEDIR/$CORE
      cp -f $SOURCESv27/priv-app/GoogleOneTimeInitializer.tar.xz $BUILDDIR/$ARCH/$RELEASEDIR/$CORE
      cp -f $SOURCESv27/priv-app/GmsCoreSetupPrebuilt.tar.xz $BUILDDIR/$ARCH/$RELEASEDIR/$CORE
      cp -f $SOURCESv27/priv-app/GoogleExtServices.tar.xz $BUILDDIR/$ARCH/$RELEASEDIR/$CORE
      cp -f $SOURCESv27/priv-app/GoogleServicesFramework.tar.xz $BUILDDIR/$ARCH/$RELEASEDIR/$CORE
      cp -f $SOURCESv27/priv-app/Phonesky.tar.xz $BUILDDIR/$ARCH/$RELEASEDIR/$CORE
      cp -f $SOURCESv27/priv-app/PrebuiltGmsCorePix.tar.xz $BUILDDIR/$ARCH/$RELEASEDIR/$CORE
      cp -f $SOURCESv27/priv-app/SetupWizardPrebuilt.tar.xz $BUILDDIR/$ARCH/$RELEASEDIR/$CORE
      cp -f $AOSPSOURCESv27/priv-app/Contacts.tar.xz $BUILDDIR/$ARCH/$RELEASEDIR/$AOSPCORE
      cp -f $AOSPSOURCESv27/priv-app/Dialer.tar.xz $BUILDDIR/$ARCH/$RELEASEDIR/$AOSPCORE
      cp -f $AOSPSOURCESv27/priv-app/ManagedProvisioning.tar.xz $BUILDDIR/$ARCH/$RELEASEDIR/$AOSPCORE
      cp -f $AOSPSOURCESv27/priv-app/Provision.tar.xz $BUILDDIR/$ARCH/$RELEASEDIR/$AOSPCORE
      # Installer components
      cp -f $UPDATEBINARY $BUILDDIR/$ARCH/$RELEASEDIR/$METADIR
      cp -f $UPDATESCRIPT $BUILDDIR/$ARCH/$RELEASEDIR/$METADIR
      cp -f $INSTALLER $BUILDDIR/$ARCH/$RELEASEDIR
      cp -f $CONFIG $BUILDDIR/$ARCH/$RELEASEDIR
      cp -f $DATA $BUILDDIR/$ARCH/$RELEASEDIR
      cp -f $BOOTLOG $BUILDDIR/$ARCH/$RELEASEDIR
      cp -f $LICENSE $BUILDDIR/$ARCH/$RELEASEDIR
      cp -f $BUSYBOX $BUILDDIR/$ARCH/$RELEASEDIR
      cp -f $SQLITE_ARMEABI $BUILDDIR/$ARCH/$RELEASEDIR/sqlite3
      cp -f $ZIPALIGN_ARMEABI $BUILDDIR/$ARCH/$RELEASEDIR/zipalign
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
      # Create build property file
      makegprop
      replace_line $BUILDDIR/$ARCH/$RELEASEDIR/g.prop CustomGAppsPackage= CustomGAppsPackage="$CustomGAppsPackage"
      replace_line $BUILDDIR/$ARCH/$RELEASEDIR/g.prop platform= platform="$platform_32"
      replace_line $BUILDDIR/$ARCH/$RELEASEDIR/g.prop sdk= sdk="$sdk_27"
      replace_line $BUILDDIR/$ARCH/$RELEASEDIR/g.prop version= version="$version_27"
      replace_line $BUILDDIR/$ARCH/$RELEASEDIR/g.prop BuildDate= BuildDate="$BuildDate"
      replace_line $BUILDDIR/$ARCH/$RELEASEDIR/g.prop BuildID= BuildID="$BuildID"
      replace_line $BUILDDIR/$ARCH/$RELEASEDIR/g.prop Developer= Developer="$Developer"
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
    # API 28
    if [ "$API" == "28" ]; then
      # Install variable; Do not modify
      TARGET_ANDROID_SDK_V28='"28"'
      # Build property variable; Do not modify
      sdk_28="28"
      version_28="9.0.0"
      echo "Generating BiTGApps package for $ARCH with API level $API"
      # Create release directory
      mkdir $BUILDDIR/$ARCH/BiTGApps-${ARCH}-9.0.0-${COMMONRELEASE}
      RELEASEDIR="BiTGApps-${ARCH}-9.0.0-${COMMONRELEASE}"
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
      cp -f $AOSPSOURCESv28/app/Messaging.tar.xz $BUILDDIR/$ARCH/$RELEASEDIR/$AOSPSYS
      # Install etc packages
      cp -f $SOURCESv28/etc/Default.tar.xz $BUILDDIR/$ARCH/$RELEASEDIR/$ZIP
      cp -f $SOURCESv28/etc/Permissions.tar.xz $BUILDDIR/$ARCH/$RELEASEDIR/$ZIP
      cp -f $SOURCESv28/etc/Preferred.tar.xz $BUILDDIR/$ARCH/$RELEASEDIR/$ZIP
      cp -f $SOURCESv28/etc/Sysconfig.tar.xz $BUILDDIR/$ARCH/$RELEASEDIR/$ZIP
      cp -f $AOSPSOURCESv28/etc/Permissions.tar.xz $BUILDDIR/$ARCH/$RELEASEDIR/$AOSPZIP
      # Install framework package
      cp -f $SOURCESv28/framework/Framework.tar.xz $BUILDDIR/$ARCH/$RELEASEDIR/$ZIP
      # Install lib package
      cp -f $SOURCESv28/lib/facelock_lib32.tar.xz $BUILDDIR/$ARCH/$RELEASEDIR/$SYS
      # Install priv-app package
      cp -f $SOURCESv28/priv-app/ConfigUpdater.tar.xz $BUILDDIR/$ARCH/$RELEASEDIR/$CORE
      cp -f $SOURCESv28/priv-app/GoogleBackupTransport.tar.xz $BUILDDIR/$ARCH/$RELEASEDIR/$CORE
      cp -f $SOURCESv28/priv-app/GoogleExtServices.tar.xz $BUILDDIR/$ARCH/$RELEASEDIR/$CORE
      cp -f $SOURCESv28/priv-app/GoogleOneTimeInitializer.tar.xz $BUILDDIR/$ARCH/$RELEASEDIR/$CORE
      cp -f $SOURCESv28/priv-app/GoogleRestore.tar.xz $BUILDDIR/$ARCH/$RELEASEDIR/$CORE
      cp -f $SOURCESv28/priv-app/GoogleServicesFramework.tar.xz $BUILDDIR/$ARCH/$RELEASEDIR/$CORE
      cp -f $SOURCESv28/priv-app/Phonesky.tar.xz $BUILDDIR/$ARCH/$RELEASEDIR/$CORE
      cp -f $SOURCESv28/priv-app/PrebuiltGmsCorePi.tar.xz $BUILDDIR/$ARCH/$RELEASEDIR/$CORE
      cp -f $SOURCESv28/priv-app/SetupWizardPrebuilt.tar.xz $BUILDDIR/$ARCH/$RELEASEDIR/$CORE
      cp -f $AOSPSOURCESv28/priv-app/Contacts.tar.xz $BUILDDIR/$ARCH/$RELEASEDIR/$AOSPCORE
      cp -f $AOSPSOURCESv28/priv-app/Dialer.tar.xz $BUILDDIR/$ARCH/$RELEASEDIR/$AOSPCORE
      cp -f $AOSPSOURCESv28/priv-app/ManagedProvisioning.tar.xz $BUILDDIR/$ARCH/$RELEASEDIR/$AOSPCORE
      cp -f $AOSPSOURCESv28/priv-app/Provision.tar.xz $BUILDDIR/$ARCH/$RELEASEDIR/$AOSPCORE
      # Installer components
      cp -f $UPDATEBINARY $BUILDDIR/$ARCH/$RELEASEDIR/$METADIR
      cp -f $UPDATESCRIPT $BUILDDIR/$ARCH/$RELEASEDIR/$METADIR
      cp -f $INSTALLER $BUILDDIR/$ARCH/$RELEASEDIR
      cp -f $CONFIG $BUILDDIR/$ARCH/$RELEASEDIR
      cp -f $DATA $BUILDDIR/$ARCH/$RELEASEDIR
      cp -f $BOOTLOG $BUILDDIR/$ARCH/$RELEASEDIR
      cp -f $PM $BUILDDIR/$ARCH/$RELEASEDIR
      cp -f $LICENSE $BUILDDIR/$ARCH/$RELEASEDIR
      cp -f $BUSYBOX $BUILDDIR/$ARCH/$RELEASEDIR
      cp -f $SQLITE_ARMEABI $BUILDDIR/$ARCH/$RELEASEDIR/sqlite3
      cp -f $ZIPALIGN_ARMEABI $BUILDDIR/$ARCH/$RELEASEDIR/zipalign
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
      # Create build property file
      makegprop
      replace_line $BUILDDIR/$ARCH/$RELEASEDIR/g.prop CustomGAppsPackage= CustomGAppsPackage="$CustomGAppsPackage"
      replace_line $BUILDDIR/$ARCH/$RELEASEDIR/g.prop platform= platform="$platform_32"
      replace_line $BUILDDIR/$ARCH/$RELEASEDIR/g.prop sdk= sdk="$sdk_28"
      replace_line $BUILDDIR/$ARCH/$RELEASEDIR/g.prop version= version="$version_28"
      replace_line $BUILDDIR/$ARCH/$RELEASEDIR/g.prop BuildDate= BuildDate="$BuildDate"
      replace_line $BUILDDIR/$ARCH/$RELEASEDIR/g.prop BuildID= BuildID="$BuildID"
      replace_line $BUILDDIR/$ARCH/$RELEASEDIR/g.prop Developer= Developer="$Developer"
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
    # API 29
    if [ "$API" == "29" ]; then
      # Install variable; Do not modify
      TARGET_ANDROID_SDK_V29='"29"'
      # Build property variable; Do not modify
      sdk_29="29"
      version_29="10.0.0"
      echo "Generating BiTGApps package for $ARCH with API level $API"
      # Create release directory
      mkdir $BUILDDIR/$ARCH/BiTGApps-${ARCH}-10.0.0-${COMMONRELEASE}
      RELEASEDIR="BiTGApps-${ARCH}-10.0.0-${COMMONRELEASE}"
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
      cp -f $AOSPSOURCESv29/app/Messaging.tar.xz $BUILDDIR/$ARCH/$RELEASEDIR/$AOSPSYS
      # Install etc packages
      cp -f $SOURCESv29/etc/Default.tar.xz $BUILDDIR/$ARCH/$RELEASEDIR/$ZIP
      cp -f $SOURCESv29/etc/Permissions.tar.xz $BUILDDIR/$ARCH/$RELEASEDIR/$ZIP
      cp -f $SOURCESv29/etc/Preferred.tar.xz $BUILDDIR/$ARCH/$RELEASEDIR/$ZIP
      cp -f $SOURCESv29/etc/Sysconfig.tar.xz $BUILDDIR/$ARCH/$RELEASEDIR/$ZIP
      cp -f $AOSPSOURCESv29/etc/Permissions.tar.xz $BUILDDIR/$ARCH/$RELEASEDIR/$AOSPZIP
      # Install framework package
      cp -f $SOURCESv29/framework/Framework.tar.xz $BUILDDIR/$ARCH/$RELEASEDIR/$ZIP
      # Install priv-app package
      cp -f $SOURCESv29/priv-app/AndroidMigratePrebuilt.tar.xz $BUILDDIR/$ARCH/$RELEASEDIR/$CORE
      cp -f $SOURCESv29/priv-app/ConfigUpdater.tar.xz $BUILDDIR/$ARCH/$RELEASEDIR/$CORE
      cp -f $SOURCESv29/priv-app/GoogleBackupTransport.tar.xz $BUILDDIR/$ARCH/$RELEASEDIR/$CORE
      cp -f $SOURCESv29/priv-app/GoogleExtServices.tar.xz $BUILDDIR/$ARCH/$RELEASEDIR/$CORE
      cp -f $SOURCESv29/priv-app/GoogleOneTimeInitializer.tar.xz $BUILDDIR/$ARCH/$RELEASEDIR/$CORE
      cp -f $SOURCESv29/priv-app/GoogleRestore.tar.xz $BUILDDIR/$ARCH/$RELEASEDIR/$CORE
      cp -f $SOURCESv29/priv-app/GoogleServicesFramework.tar.xz $BUILDDIR/$ARCH/$RELEASEDIR/$CORE
      cp -f $SOURCESv29/priv-app/Phonesky.tar.xz $BUILDDIR/$ARCH/$RELEASEDIR/$CORE
      cp -f $SOURCESv29/priv-app/PrebuiltGmsCoreQt.tar.xz $BUILDDIR/$ARCH/$RELEASEDIR/$CORE
      cp -f $SOURCESv29/priv-app/SetupWizardPrebuilt.tar.xz $BUILDDIR/$ARCH/$RELEASEDIR/$CORE
      cp -f $AOSPSOURCESv29/priv-app/Contacts.tar.xz $BUILDDIR/$ARCH/$RELEASEDIR/$AOSPCORE
      cp -f $AOSPSOURCESv29/priv-app/Dialer.tar.xz $BUILDDIR/$ARCH/$RELEASEDIR/$AOSPCORE
      cp -f $AOSPSOURCESv29/priv-app/ManagedProvisioning.tar.xz $BUILDDIR/$ARCH/$RELEASEDIR/$AOSPCORE
      cp -f $AOSPSOURCESv29/priv-app/Provision.tar.xz $BUILDDIR/$ARCH/$RELEASEDIR/$AOSPCORE
      # Installer components
      cp -f $UPDATEBINARY $BUILDDIR/$ARCH/$RELEASEDIR/$METADIR
      cp -f $UPDATESCRIPT $BUILDDIR/$ARCH/$RELEASEDIR/$METADIR
      cp -f $INSTALLER $BUILDDIR/$ARCH/$RELEASEDIR
      cp -f $CONFIG $BUILDDIR/$ARCH/$RELEASEDIR
      cp -f $DATA $BUILDDIR/$ARCH/$RELEASEDIR
      cp -f $BOOTLOG $BUILDDIR/$ARCH/$RELEASEDIR
      cp -f $LICENSE $BUILDDIR/$ARCH/$RELEASEDIR
      cp -f $BUSYBOX $BUILDDIR/$ARCH/$RELEASEDIR
      cp -f $SQLITE_ARMEABI $BUILDDIR/$ARCH/$RELEASEDIR/sqlite3
      cp -f $ZIPALIGN_ARMEABI $BUILDDIR/$ARCH/$RELEASEDIR/zipalign
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
      # Create build property file
      makegprop
      replace_line $BUILDDIR/$ARCH/$RELEASEDIR/g.prop CustomGAppsPackage= CustomGAppsPackage="$CustomGAppsPackage"
      replace_line $BUILDDIR/$ARCH/$RELEASEDIR/g.prop platform= platform="$platform_32"
      replace_line $BUILDDIR/$ARCH/$RELEASEDIR/g.prop sdk= sdk="$sdk_29"
      replace_line $BUILDDIR/$ARCH/$RELEASEDIR/g.prop version= version="$version_29"
      replace_line $BUILDDIR/$ARCH/$RELEASEDIR/g.prop BuildDate= BuildDate="$BuildDate"
      replace_line $BUILDDIR/$ARCH/$RELEASEDIR/g.prop BuildID= BuildID="$BuildID"
      replace_line $BUILDDIR/$ARCH/$RELEASEDIR/g.prop Developer= Developer="$Developer"
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
    # API 30
    if [ "$API" == "30" ]; then
      # Install variable; Do not modify
      TARGET_ANDROID_SDK_V30='"30"'
      # Build property variable; Do not modify
      sdk_30="30"
      version_30="11.0.0"
      echo "Generating BiTGApps package for $ARCH with API level $API"
      # Create release directory
      mkdir $BUILDDIR/$ARCH/BiTGApps-${ARCH}-11.0.0-${COMMONRELEASE}
      RELEASEDIR="BiTGApps-${ARCH}-11.0.0-${COMMONRELEASE}"
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
      cp -f $AOSPSOURCESv30/app/Messaging.tar.xz $BUILDDIR/$ARCH/$RELEASEDIR/$AOSPSYS
      # Install etc packages
      cp -f $SOURCESv30/etc/Default.tar.xz $BUILDDIR/$ARCH/$RELEASEDIR/$ZIP
      cp -f $SOURCESv30/etc/Permissions.tar.xz $BUILDDIR/$ARCH/$RELEASEDIR/$ZIP
      cp -f $SOURCESv30/etc/Preferred.tar.xz $BUILDDIR/$ARCH/$RELEASEDIR/$ZIP
      cp -f $SOURCESv30/etc/Sysconfig.tar.xz $BUILDDIR/$ARCH/$RELEASEDIR/$ZIP
      cp -f $AOSPSOURCESv30/etc/Permissions.tar.xz $BUILDDIR/$ARCH/$RELEASEDIR/$AOSPZIP
      # Install framework package
      cp -f $SOURCESv30/framework/Framework.tar.xz $BUILDDIR/$ARCH/$RELEASEDIR/$ZIP
      # Install overlay package
      cp -f $SOURCESv30/overlay/PlayStoreOverlay.tar.xz $BUILDDIR/$ARCH/$RELEASEDIR/$OVERLAY
      # Install priv-app package
      cp -f $SOURCESv30/priv-app/AndroidMigratePrebuilt.tar.xz $BUILDDIR/$ARCH/$RELEASEDIR/$CORE
      cp -f $SOURCESv30/priv-app/ConfigUpdater.tar.xz $BUILDDIR/$ARCH/$RELEASEDIR/$CORE
      cp -f $SOURCESv30/priv-app/GoogleBackupTransport.tar.xz $BUILDDIR/$ARCH/$RELEASEDIR/$CORE
      cp -f $SOURCESv30/priv-app/GoogleOneTimeInitializer.tar.xz $BUILDDIR/$ARCH/$RELEASEDIR/$CORE
      cp -f $SOURCESv30/priv-app/GoogleRestore.tar.xz $BUILDDIR/$ARCH/$RELEASEDIR/$CORE
      cp -f $SOURCESv30/priv-app/GoogleServicesFramework.tar.xz $BUILDDIR/$ARCH/$RELEASEDIR/$CORE
      cp -f $SOURCESv30/priv-app/Phonesky.tar.xz $BUILDDIR/$ARCH/$RELEASEDIR/$CORE
      cp -f $SOURCESv30/priv-app/PrebuiltGmsCoreRvc.tar.xz $BUILDDIR/$ARCH/$RELEASEDIR/$CORE
      cp -f $SOURCESv30/priv-app/SetupWizardPrebuilt.tar.xz $BUILDDIR/$ARCH/$RELEASEDIR/$CORE
      cp -f $AOSPSOURCESv30/priv-app/Contacts.tar.xz $BUILDDIR/$ARCH/$RELEASEDIR/$AOSPCORE
      cp -f $AOSPSOURCESv30/priv-app/Dialer.tar.xz $BUILDDIR/$ARCH/$RELEASEDIR/$AOSPCORE
      cp -f $AOSPSOURCESv30/priv-app/ManagedProvisioning.tar.xz $BUILDDIR/$ARCH/$RELEASEDIR/$AOSPCORE
      cp -f $AOSPSOURCESv30/priv-app/Provision.tar.xz $BUILDDIR/$ARCH/$RELEASEDIR/$AOSPCORE
      # Installer components
      cp -f $UPDATEBINARY $BUILDDIR/$ARCH/$RELEASEDIR/$METADIR
      cp -f $UPDATESCRIPT $BUILDDIR/$ARCH/$RELEASEDIR/$METADIR
      cp -f $INSTALLER $BUILDDIR/$ARCH/$RELEASEDIR
      cp -f $CONFIG $BUILDDIR/$ARCH/$RELEASEDIR
      cp -f $DATA $BUILDDIR/$ARCH/$RELEASEDIR
      cp -f $BOOTLOG $BUILDDIR/$ARCH/$RELEASEDIR
      cp -f $LICENSE $BUILDDIR/$ARCH/$RELEASEDIR
      cp -f $BUSYBOX $BUILDDIR/$ARCH/$RELEASEDIR
      cp -f $SQLITE_ARMEABI $BUILDDIR/$ARCH/$RELEASEDIR/sqlite3
      cp -f $ZIPALIGN_ARMEABI $BUILDDIR/$ARCH/$RELEASEDIR/zipalign
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
      # Create build property file
      makegprop
      replace_line $BUILDDIR/$ARCH/$RELEASEDIR/g.prop CustomGAppsPackage= CustomGAppsPackage="$CustomGAppsPackage"
      replace_line $BUILDDIR/$ARCH/$RELEASEDIR/g.prop platform= platform="$platform_32"
      replace_line $BUILDDIR/$ARCH/$RELEASEDIR/g.prop sdk= sdk="$sdk_30"
      replace_line $BUILDDIR/$ARCH/$RELEASEDIR/g.prop version= version="$version_30"
      replace_line $BUILDDIR/$ARCH/$RELEASEDIR/g.prop BuildDate= BuildDate="$BuildDate"
      replace_line $BUILDDIR/$ARCH/$RELEASEDIR/g.prop BuildID= BuildID="$BuildID"
      replace_line $BUILDDIR/$ARCH/$RELEASEDIR/g.prop Developer= Developer="$Developer"
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
      echo "Generating BiTGApps package for $ARCH with API level $API"
      if [ "$TARGET_VERSION_N1" == "7.1.1" ]; then
        # Build property variable; Do not modify
        version_N1="7.1.1"
        # Create release directory
        mkdir $BUILDDIR/$ARCH/BiTGApps-${ARCH}-7.1.1-${COMMONRELEASE}
        RELEASEDIR="BiTGApps-${ARCH}-7.1.1-${COMMONRELEASE}"
        # Create package components
        mkdir -p $BUILDDIR/$ARCH/$RELEASEDIR/$METADIR
        mkdir -p $BUILDDIR/$ARCH/$RELEASEDIR/$ZIP
        mkdir -p $BUILDDIR/$ARCH/$RELEASEDIR/$CORE
        mkdir -p $BUILDDIR/$ARCH/$RELEASEDIR/$SYS
        mkdir -p $BUILDDIR/$ARCH/$RELEASEDIR/$AOSPCORE
        mkdir -p $BUILDDIR/$ARCH/$RELEASEDIR/$AOSPSYS
        # Install app packages
        cp -f $SOURCESv25/app/FaceLock.tar.xz $BUILDDIR/$ARCH/$RELEASEDIR/$SYS
        cp -f $SOURCESv25/app/GoogleCalendarSyncAdapter.tar.xz $BUILDDIR/$ARCH/$RELEASEDIR/$SYS
        cp -f $SOURCESv25/app/GoogleContactsSyncAdapter.tar.xz $BUILDDIR/$ARCH/$RELEASEDIR/$SYS
        cp -f $SOURCESv25/app/GoogleExtShared.tar.xz $BUILDDIR/$ARCH/$RELEASEDIR/$SYS
        cp -f $AOSPSOURCESv25/app/Messaging.tar.xz $BUILDDIR/$ARCH/$RELEASEDIR/$AOSPSYS
        # Install etc packages
        cp -f $SOURCESv25/etc/Default.tar.xz $BUILDDIR/$ARCH/$RELEASEDIR/$ZIP
        cp -f $SOURCESv25/etc/Permissions.tar.xz $BUILDDIR/$ARCH/$RELEASEDIR/$ZIP
        cp -f $SOURCESv25/etc/Preferred.tar.xz $BUILDDIR/$ARCH/$RELEASEDIR/$ZIP
        cp -f $SOURCESv25/etc/Sysconfig.tar.xz $BUILDDIR/$ARCH/$RELEASEDIR/$ZIP
        cp -f $AOSPSOURCESv25/etc/Permissions.tar.xz $BUILDDIR/$ARCH/$RELEASEDIR/$AOSPZIP
        # Install framework package
        cp -f $SOURCESv25/framework/Framework.tar.xz $BUILDDIR/$ARCH/$RELEASEDIR/$ZIP
        # Install lib package
        cp -f $SOURCESv25/lib/facelock_lib32.tar.xz $BUILDDIR/$ARCH/$RELEASEDIR/$SYS
        cp -f $SOURCESv25/lib64/facelock_lib64.tar.xz $BUILDDIR/$ARCH/$RELEASEDIR/$SYS
        # Install priv-app package
        cp -f $SOURCESv25/priv-app/ConfigUpdater.tar.xz $BUILDDIR/$ARCH/$RELEASEDIR/$CORE
        cp -f $SOURCESv25/priv-app/GoogleBackupTransport.tar.xz $BUILDDIR/$ARCH/$RELEASEDIR/$CORE
        cp -f $SOURCESv25/priv-app/GoogleOneTimeInitializer.tar.xz $BUILDDIR/$ARCH/$RELEASEDIR/$CORE
        cp -f $SOURCESv25/priv-app/GmsCoreSetupPrebuilt.tar.xz $BUILDDIR/$ARCH/$RELEASEDIR/$CORE
        cp -f $SOURCESv25/priv-app/GoogleExtServices.tar.xz $BUILDDIR/$ARCH/$RELEASEDIR/$CORE
        cp -f $SOURCESv25/priv-app/GoogleLoginService.tar.xz $BUILDDIR/$ARCH/$RELEASEDIR/$CORE
        cp -f $SOURCESv25/priv-app/GoogleServicesFramework.tar.xz $BUILDDIR/$ARCH/$RELEASEDIR/$CORE
        cp -f $SOURCESv25/priv-app/Phonesky.tar.xz $BUILDDIR/$ARCH/$RELEASEDIR/$CORE
        cp -f $SOURCESv25/priv-app/PrebuiltGmsCore.tar.xz $BUILDDIR/$ARCH/$RELEASEDIR/$CORE
        cp -f $SOURCESv25/priv-app/SetupWizardPrebuilt.tar.xz $BUILDDIR/$ARCH/$RELEASEDIR/$CORE
        cp -f $AOSPSOURCESv25/priv-app/Contacts.tar.xz $BUILDDIR/$ARCH/$RELEASEDIR/$AOSPCORE
        cp -f $AOSPSOURCESv25/priv-app/Dialer.tar.xz $BUILDDIR/$ARCH/$RELEASEDIR/$AOSPCORE
        cp -f $AOSPSOURCESv25/priv-app/ManagedProvisioning.tar.xz $BUILDDIR/$ARCH/$RELEASEDIR/$AOSPCORE
        cp -f $AOSPSOURCESv25/priv-app/Provision.tar.xz $BUILDDIR/$ARCH/$RELEASEDIR/$AOSPCORE
        # Installer components
        cp -f $UPDATEBINARY $BUILDDIR/$ARCH/$RELEASEDIR/$METADIR
        cp -f $UPDATESCRIPT $BUILDDIR/$ARCH/$RELEASEDIR/$METADIR
        cp -f $INSTALLER $BUILDDIR/$ARCH/$RELEASEDIR
        cp -f $CONFIG $BUILDDIR/$ARCH/$RELEASEDIR
        cp -f $DATA $BUILDDIR/$ARCH/$RELEASEDIR
        cp -f $BOOTLOG $BUILDDIR/$ARCH/$RELEASEDIR
        cp -f $LICENSE $BUILDDIR/$ARCH/$RELEASEDIR
        cp -f $BUSYBOX $BUILDDIR/$ARCH/$RELEASEDIR
        cp -f $SQLITE_AARCH64 $BUILDDIR/$ARCH/$RELEASEDIR/sqlite3
        cp -f $ZIPALIGN_AARCH64 $BUILDDIR/$ARCH/$RELEASEDIR/zipalign
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
        # Create build property file
        makegprop
        replace_line $BUILDDIR/$ARCH/$RELEASEDIR/g.prop CustomGAppsPackage= CustomGAppsPackage="$CustomGAppsPackage"
        replace_line $BUILDDIR/$ARCH/$RELEASEDIR/g.prop platform= platform="$platform_64"
        replace_line $BUILDDIR/$ARCH/$RELEASEDIR/g.prop sdk= sdk="$sdk_25"
        replace_line $BUILDDIR/$ARCH/$RELEASEDIR/g.prop version= version="$version_N1"
        replace_line $BUILDDIR/$ARCH/$RELEASEDIR/g.prop BuildDate= BuildDate="$BuildDate"
        replace_line $BUILDDIR/$ARCH/$RELEASEDIR/g.prop BuildID= BuildID="$BuildID"
        replace_line $BUILDDIR/$ARCH/$RELEASEDIR/g.prop Developer= Developer="$Developer"
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
      if [ "$TARGET_VERSION_N2" == "7.1.2" ]; then
        # Build property variable; Do not modify
        version_N2="7.1.2"
        # Create release directory
        mkdir $BUILDDIR/$ARCH/BiTGApps-${ARCH}-7.1.2-${COMMONRELEASE}
        RELEASEDIR="BiTGApps-${ARCH}-7.1.2-${COMMONRELEASE}"
        # Create package components
        mkdir -p $BUILDDIR/$ARCH/$RELEASEDIR/$METADIR
        mkdir -p $BUILDDIR/$ARCH/$RELEASEDIR/$ZIP
        mkdir -p $BUILDDIR/$ARCH/$RELEASEDIR/$CORE
        mkdir -p $BUILDDIR/$ARCH/$RELEASEDIR/$SYS
        mkdir -p $BUILDDIR/$ARCH/$RELEASEDIR/$AOSPCORE
        mkdir -p $BUILDDIR/$ARCH/$RELEASEDIR/$AOSPSYS
        # Install app packages
        cp -f $SOURCESv25/app/FaceLock.tar.xz $BUILDDIR/$ARCH/$RELEASEDIR/$SYS
        cp -f $SOURCESv25/app/GoogleCalendarSyncAdapter.tar.xz $BUILDDIR/$ARCH/$RELEASEDIR/$SYS
        cp -f $SOURCESv25/app/GoogleContactsSyncAdapter.tar.xz $BUILDDIR/$ARCH/$RELEASEDIR/$SYS
        cp -f $SOURCESv25/app/GoogleExtShared.tar.xz $BUILDDIR/$ARCH/$RELEASEDIR/$SYS
        cp -f $AOSPSOURCESv25/app/Messaging.tar.xz $BUILDDIR/$ARCH/$RELEASEDIR/$AOSPSYS
        # Install etc packages
        cp -f $SOURCESv25/etc/Default.tar.xz $BUILDDIR/$ARCH/$RELEASEDIR/$ZIP
        cp -f $SOURCESv25/etc/Permissions.tar.xz $BUILDDIR/$ARCH/$RELEASEDIR/$ZIP
        cp -f $SOURCESv25/etc/Preferred.tar.xz $BUILDDIR/$ARCH/$RELEASEDIR/$ZIP
        cp -f $SOURCESv25/etc/Sysconfig.tar.xz $BUILDDIR/$ARCH/$RELEASEDIR/$ZIP
        cp -f $AOSPSOURCESv25/etc/Permissions.tar.xz $BUILDDIR/$ARCH/$RELEASEDIR/$AOSPZIP
        # Install framework package
        cp -f $SOURCESv25/framework/Framework.tar.xz $BUILDDIR/$ARCH/$RELEASEDIR/$ZIP
        # Install lib package
        cp -f $SOURCESv25/lib/facelock_lib32.tar.xz $BUILDDIR/$ARCH/$RELEASEDIR/$SYS
        cp -f $SOURCESv25/lib64/facelock_lib64.tar.xz $BUILDDIR/$ARCH/$RELEASEDIR/$SYS
        # Install priv-app package
        cp -f $SOURCESv25/priv-app/ConfigUpdater.tar.xz $BUILDDIR/$ARCH/$RELEASEDIR/$CORE
        cp -f $SOURCESv25/priv-app/GoogleBackupTransport.tar.xz $BUILDDIR/$ARCH/$RELEASEDIR/$CORE
        cp -f $SOURCESv25/priv-app/GoogleOneTimeInitializer.tar.xz $BUILDDIR/$ARCH/$RELEASEDIR/$CORE
        cp -f $SOURCESv25/priv-app/GmsCoreSetupPrebuilt.tar.xz $BUILDDIR/$ARCH/$RELEASEDIR/$CORE
        cp -f $SOURCESv25/priv-app/GoogleExtServices.tar.xz $BUILDDIR/$ARCH/$RELEASEDIR/$CORE
        cp -f $SOURCESv25/priv-app/GoogleLoginService.tar.xz $BUILDDIR/$ARCH/$RELEASEDIR/$CORE
        cp -f $SOURCESv25/priv-app/GoogleServicesFramework.tar.xz $BUILDDIR/$ARCH/$RELEASEDIR/$CORE
        cp -f $SOURCESv25/priv-app/Phonesky.tar.xz $BUILDDIR/$ARCH/$RELEASEDIR/$CORE
        cp -f $SOURCESv25/priv-app/PrebuiltGmsCore.tar.xz $BUILDDIR/$ARCH/$RELEASEDIR/$CORE
        cp -f $SOURCESv25/priv-app/SetupWizardPrebuilt.tar.xz $BUILDDIR/$ARCH/$RELEASEDIR/$CORE
        cp -f $AOSPSOURCESv25/priv-app/Contacts.tar.xz $BUILDDIR/$ARCH/$RELEASEDIR/$AOSPCORE
        cp -f $AOSPSOURCESv25/priv-app/Dialer.tar.xz $BUILDDIR/$ARCH/$RELEASEDIR/$AOSPCORE
        cp -f $AOSPSOURCESv25/priv-app/ManagedProvisioning.tar.xz $BUILDDIR/$ARCH/$RELEASEDIR/$AOSPCORE
        cp -f $AOSPSOURCESv25/priv-app/Provision.tar.xz $BUILDDIR/$ARCH/$RELEASEDIR/$AOSPCORE
        # Installer components
        cp -f $UPDATEBINARY $BUILDDIR/$ARCH/$RELEASEDIR/$METADIR
        cp -f $UPDATESCRIPT $BUILDDIR/$ARCH/$RELEASEDIR/$METADIR
        cp -f $INSTALLER $BUILDDIR/$ARCH/$RELEASEDIR
        cp -f $CONFIG $BUILDDIR/$ARCH/$RELEASEDIR
        cp -f $DATA $BUILDDIR/$ARCH/$RELEASEDIR
        cp -f $BOOTLOG $BUILDDIR/$ARCH/$RELEASEDIR
        cp -f $LICENSE $BUILDDIR/$ARCH/$RELEASEDIR
        cp -f $BUSYBOX $BUILDDIR/$ARCH/$RELEASEDIR
        cp -f $SQLITE_AARCH64 $BUILDDIR/$ARCH/$RELEASEDIR/sqlite3
        cp -f $ZIPALIGN_AARCH64 $BUILDDIR/$ARCH/$RELEASEDIR/zipalign
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
        # Create build property file
        makegprop
        replace_line $BUILDDIR/$ARCH/$RELEASEDIR/g.prop CustomGAppsPackage= CustomGAppsPackage="$CustomGAppsPackage"
        replace_line $BUILDDIR/$ARCH/$RELEASEDIR/g.prop platform= platform="$platform_64"
        replace_line $BUILDDIR/$ARCH/$RELEASEDIR/g.prop sdk= sdk="$sdk_25"
        replace_line $BUILDDIR/$ARCH/$RELEASEDIR/g.prop version= version="$version_N2"
        replace_line $BUILDDIR/$ARCH/$RELEASEDIR/g.prop BuildDate= BuildDate="$BuildDate"
        replace_line $BUILDDIR/$ARCH/$RELEASEDIR/g.prop BuildID= BuildID="$BuildID"
        replace_line $BUILDDIR/$ARCH/$RELEASEDIR/g.prop Developer= Developer="$Developer"
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
      mkdir $BUILDDIR/$ARCH/BiTGApps-${ARCH}-8.0.0-${COMMONRELEASE}
      RELEASEDIR="BiTGApps-${ARCH}-8.0.0-${COMMONRELEASE}"
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
      cp -f $AOSPSOURCESv26/app/Messaging.tar.xz $BUILDDIR/$ARCH/$RELEASEDIR/$AOSPSYS
      # Install etc packages
      cp -f $SOURCESv26/etc/Default.tar.xz $BUILDDIR/$ARCH/$RELEASEDIR/$ZIP
      cp -f $SOURCESv26/etc/Permissions.tar.xz $BUILDDIR/$ARCH/$RELEASEDIR/$ZIP
      cp -f $SOURCESv26/etc/Preferred.tar.xz $BUILDDIR/$ARCH/$RELEASEDIR/$ZIP
      cp -f $SOURCESv26/etc/Sysconfig.tar.xz $BUILDDIR/$ARCH/$RELEASEDIR/$ZIP
      cp -f $AOSPSOURCESv26/etc/Permissions.tar.xz $BUILDDIR/$ARCH/$RELEASEDIR/$AOSPZIP
      # Install framework package
      cp -f $SOURCESv26/framework/Framework.tar.xz $BUILDDIR/$ARCH/$RELEASEDIR/$ZIP
      # Install lib package
      cp -f $SOURCESv26/lib/facelock_lib32.tar.xz $BUILDDIR/$ARCH/$RELEASEDIR/$SYS
      cp -f $SOURCESv26/lib64/facelock_lib64.tar.xz $BUILDDIR/$ARCH/$RELEASEDIR/$SYS
      # Install priv-app package
      cp -f $SOURCESv26/priv-app/ConfigUpdater.tar.xz $BUILDDIR/$ARCH/$RELEASEDIR/$CORE
      cp -f $SOURCESv26/priv-app/GoogleBackupTransport.tar.xz $BUILDDIR/$ARCH/$RELEASEDIR/$CORE
      cp -f $SOURCESv26/priv-app/GoogleOneTimeInitializer.tar.xz $BUILDDIR/$ARCH/$RELEASEDIR/$CORE
      cp -f $SOURCESv26/priv-app/GmsCoreSetupPrebuilt.tar.xz $BUILDDIR/$ARCH/$RELEASEDIR/$CORE
      cp -f $SOURCESv26/priv-app/GoogleExtServices.tar.xz $BUILDDIR/$ARCH/$RELEASEDIR/$CORE
      cp -f $SOURCESv26/priv-app/GoogleServicesFramework.tar.xz $BUILDDIR/$ARCH/$RELEASEDIR/$CORE
      cp -f $SOURCESv26/priv-app/Phonesky.tar.xz $BUILDDIR/$ARCH/$RELEASEDIR/$CORE
      cp -f $SOURCESv26/priv-app/PrebuiltGmsCorePix.tar.xz $BUILDDIR/$ARCH/$RELEASEDIR/$CORE
      cp -f $SOURCESv26/priv-app/SetupWizardPrebuilt.tar.xz $BUILDDIR/$ARCH/$RELEASEDIR/$CORE
      cp -f $AOSPSOURCESv26/priv-app/Contacts.tar.xz $BUILDDIR/$ARCH/$RELEASEDIR/$AOSPCORE
      cp -f $AOSPSOURCESv26/priv-app/Dialer.tar.xz $BUILDDIR/$ARCH/$RELEASEDIR/$AOSPCORE
      cp -f $AOSPSOURCESv26/priv-app/ManagedProvisioning.tar.xz $BUILDDIR/$ARCH/$RELEASEDIR/$AOSPCORE
      cp -f $AOSPSOURCESv26/priv-app/Provision.tar.xz $BUILDDIR/$ARCH/$RELEASEDIR/$AOSPCORE
      # Installer components
      cp -f $UPDATEBINARY $BUILDDIR/$ARCH/$RELEASEDIR/$METADIR
      cp -f $UPDATESCRIPT $BUILDDIR/$ARCH/$RELEASEDIR/$METADIR
      cp -f $INSTALLER $BUILDDIR/$ARCH/$RELEASEDIR
      cp -f $CONFIG $BUILDDIR/$ARCH/$RELEASEDIR
      cp -f $DATA $BUILDDIR/$ARCH/$RELEASEDIR
      cp -f $BOOTLOG $BUILDDIR/$ARCH/$RELEASEDIR
      cp -f $LICENSE $BUILDDIR/$ARCH/$RELEASEDIR
      cp -f $BUSYBOX $BUILDDIR/$ARCH/$RELEASEDIR
      cp -f $SQLITE_AARCH64 $BUILDDIR/$ARCH/$RELEASEDIR/sqlite3
      cp -f $ZIPALIGN_AARCH64 $BUILDDIR/$ARCH/$RELEASEDIR/zipalign
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
      # Create build property file
      makegprop
      replace_line $BUILDDIR/$ARCH/$RELEASEDIR/g.prop CustomGAppsPackage= CustomGAppsPackage="$CustomGAppsPackage"
      replace_line $BUILDDIR/$ARCH/$RELEASEDIR/g.prop platform= platform="$platform_64"
      replace_line $BUILDDIR/$ARCH/$RELEASEDIR/g.prop sdk= sdk="$sdk_26"
      replace_line $BUILDDIR/$ARCH/$RELEASEDIR/g.prop version= version="$version_26"
      replace_line $BUILDDIR/$ARCH/$RELEASEDIR/g.prop BuildDate= BuildDate="$BuildDate"
      replace_line $BUILDDIR/$ARCH/$RELEASEDIR/g.prop BuildID= BuildID="$BuildID"
      replace_line $BUILDDIR/$ARCH/$RELEASEDIR/g.prop Developer= Developer="$Developer"
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
    # API 27
    if [ "$API" == "27" ]; then
      # Install variable; Do not modify
      TARGET_ANDROID_SDK_V27='"27"'
      # Build property variable; Do not modify
      sdk_27="27"
      version_27="8.1.0"
      echo "Generating BiTGApps package for $ARCH with API level $API"
      # Create release directory
      mkdir $BUILDDIR/$ARCH/BiTGApps-${ARCH}-8.1.0-${COMMONRELEASE}
      RELEASEDIR="BiTGApps-${ARCH}-8.1.0-${COMMONRELEASE}"
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
      cp -f $AOSPSOURCESv27/app/Messaging.tar.xz $BUILDDIR/$ARCH/$RELEASEDIR/$AOSPSYS
      # Install etc packages
      cp -f $SOURCESv27/etc/Default.tar.xz $BUILDDIR/$ARCH/$RELEASEDIR/$ZIP
      cp -f $SOURCESv27/etc/Permissions.tar.xz $BUILDDIR/$ARCH/$RELEASEDIR/$ZIP
      cp -f $SOURCESv27/etc/Preferred.tar.xz $BUILDDIR/$ARCH/$RELEASEDIR/$ZIP
      cp -f $SOURCESv27/etc/Sysconfig.tar.xz $BUILDDIR/$ARCH/$RELEASEDIR/$ZIP
      cp -f $AOSPSOURCESv27/etc/Permissions.tar.xz $BUILDDIR/$ARCH/$RELEASEDIR/$AOSPZIP
      # Install framework package
      cp -f $SOURCESv27/framework/Framework.tar.xz $BUILDDIR/$ARCH/$RELEASEDIR/$ZIP
      # Install lib package
      cp -f $SOURCESv27/lib/facelock_lib32.tar.xz $BUILDDIR/$ARCH/$RELEASEDIR/$SYS
      cp -f $SOURCESv27/lib64/facelock_lib64.tar.xz $BUILDDIR/$ARCH/$RELEASEDIR/$SYS
      # Install priv-app package
      cp -f $SOURCESv27/priv-app/ConfigUpdater.tar.xz $BUILDDIR/$ARCH/$RELEASEDIR/$CORE
      cp -f $SOURCESv27/priv-app/GoogleBackupTransport.tar.xz $BUILDDIR/$ARCH/$RELEASEDIR/$CORE
      cp -f $SOURCESv27/priv-app/GoogleOneTimeInitializer.tar.xz $BUILDDIR/$ARCH/$RELEASEDIR/$CORE
      cp -f $SOURCESv27/priv-app/GmsCoreSetupPrebuilt.tar.xz $BUILDDIR/$ARCH/$RELEASEDIR/$CORE
      cp -f $SOURCESv27/priv-app/GoogleExtServices.tar.xz $BUILDDIR/$ARCH/$RELEASEDIR/$CORE
      cp -f $SOURCESv27/priv-app/GoogleServicesFramework.tar.xz $BUILDDIR/$ARCH/$RELEASEDIR/$CORE
      cp -f $SOURCESv27/priv-app/Phonesky.tar.xz $BUILDDIR/$ARCH/$RELEASEDIR/$CORE
      cp -f $SOURCESv27/priv-app/PrebuiltGmsCorePix.tar.xz $BUILDDIR/$ARCH/$RELEASEDIR/$CORE
      cp -f $SOURCESv27/priv-app/SetupWizardPrebuilt.tar.xz $BUILDDIR/$ARCH/$RELEASEDIR/$CORE
      cp -f $AOSPSOURCESv27/priv-app/Contacts.tar.xz $BUILDDIR/$ARCH/$RELEASEDIR/$AOSPCORE
      cp -f $AOSPSOURCESv27/priv-app/Dialer.tar.xz $BUILDDIR/$ARCH/$RELEASEDIR/$AOSPCORE
      cp -f $AOSPSOURCESv27/priv-app/ManagedProvisioning.tar.xz $BUILDDIR/$ARCH/$RELEASEDIR/$AOSPCORE
      cp -f $AOSPSOURCESv27/priv-app/Provision.tar.xz $BUILDDIR/$ARCH/$RELEASEDIR/$AOSPCORE
      # Installer components
      cp -f $UPDATEBINARY $BUILDDIR/$ARCH/$RELEASEDIR/$METADIR
      cp -f $UPDATESCRIPT $BUILDDIR/$ARCH/$RELEASEDIR/$METADIR
      cp -f $INSTALLER $BUILDDIR/$ARCH/$RELEASEDIR
      cp -f $CONFIG $BUILDDIR/$ARCH/$RELEASEDIR
      cp -f $DATA $BUILDDIR/$ARCH/$RELEASEDIR
      cp -f $BOOTLOG $BUILDDIR/$ARCH/$RELEASEDIR
      cp -f $LICENSE $BUILDDIR/$ARCH/$RELEASEDIR
      cp -f $BUSYBOX $BUILDDIR/$ARCH/$RELEASEDIR
      cp -f $SQLITE_AARCH64 $BUILDDIR/$ARCH/$RELEASEDIR/sqlite3
      cp -f $ZIPALIGN_AARCH64 $BUILDDIR/$ARCH/$RELEASEDIR/zipalign
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
      # Create build property file
      makegprop
      replace_line $BUILDDIR/$ARCH/$RELEASEDIR/g.prop CustomGAppsPackage= CustomGAppsPackage="$CustomGAppsPackage"
      replace_line $BUILDDIR/$ARCH/$RELEASEDIR/g.prop platform= platform="$platform_64"
      replace_line $BUILDDIR/$ARCH/$RELEASEDIR/g.prop sdk= sdk="$sdk_27"
      replace_line $BUILDDIR/$ARCH/$RELEASEDIR/g.prop version= version="$version_27"
      replace_line $BUILDDIR/$ARCH/$RELEASEDIR/g.prop BuildDate= BuildDate="$BuildDate"
      replace_line $BUILDDIR/$ARCH/$RELEASEDIR/g.prop BuildID= BuildID="$BuildID"
      replace_line $BUILDDIR/$ARCH/$RELEASEDIR/g.prop Developer= Developer="$Developer"
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
    # API 28
    if [ "$API" == "28" ]; then
      # Install variable; Do not modify
      TARGET_ANDROID_SDK_V28='"28"'
      # Build property variable; Do not modify
      sdk_28="28"
      version_28="9.0.0"
      echo "Generating BiTGApps package for $ARCH with API level $API"
      # Create release directory
      mkdir $BUILDDIR/$ARCH/BiTGApps-${ARCH}-9.0.0-${COMMONRELEASE}
      RELEASEDIR="BiTGApps-${ARCH}-9.0.0-${COMMONRELEASE}"
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
      cp -f $AOSPSOURCESv28/app/Messaging.tar.xz $BUILDDIR/$ARCH/$RELEASEDIR/$AOSPSYS
      # Install etc packages
      cp -f $SOURCESv28/etc/Default.tar.xz $BUILDDIR/$ARCH/$RELEASEDIR/$ZIP
      cp -f $SOURCESv28/etc/Permissions.tar.xz $BUILDDIR/$ARCH/$RELEASEDIR/$ZIP
      cp -f $SOURCESv28/etc/Preferred.tar.xz $BUILDDIR/$ARCH/$RELEASEDIR/$ZIP
      cp -f $SOURCESv28/etc/Sysconfig.tar.xz $BUILDDIR/$ARCH/$RELEASEDIR/$ZIP
      cp -f $AOSPSOURCESv28/etc/Permissions.tar.xz $BUILDDIR/$ARCH/$RELEASEDIR/$AOSPZIP
      # Install framework package
      cp -f $SOURCESv28/framework/Framework.tar.xz $BUILDDIR/$ARCH/$RELEASEDIR/$ZIP
      # Install lib package
      cp -f $SOURCESv28/lib/facelock_lib32.tar.xz $BUILDDIR/$ARCH/$RELEASEDIR/$SYS
      cp -f $SOURCESv28/lib64/facelock_lib64.tar.xz $BUILDDIR/$ARCH/$RELEASEDIR/$SYS
      cp -f $SOURCESv28/lib64/setupwizardprebuilt_lib64.tar.xz $BUILDDIR/$ARCH/$RELEASEDIR/$CORE
      # Install priv-app package
      cp -f $SOURCESv28/priv-app/ConfigUpdater.tar.xz $BUILDDIR/$ARCH/$RELEASEDIR/$CORE
      cp -f $SOURCESv28/priv-app/GoogleBackupTransport.tar.xz $BUILDDIR/$ARCH/$RELEASEDIR/$CORE
      cp -f $SOURCESv28/priv-app/GoogleExtServices.tar.xz $BUILDDIR/$ARCH/$RELEASEDIR/$CORE
      cp -f $SOURCESv28/priv-app/GoogleOneTimeInitializer.tar.xz $BUILDDIR/$ARCH/$RELEASEDIR/$CORE
      cp -f $SOURCESv28/priv-app/GoogleRestore.tar.xz $BUILDDIR/$ARCH/$RELEASEDIR/$CORE
      cp -f $SOURCESv28/priv-app/GoogleServicesFramework.tar.xz $BUILDDIR/$ARCH/$RELEASEDIR/$CORE
      cp -f $SOURCESv28/priv-app/Phonesky.tar.xz $BUILDDIR/$ARCH/$RELEASEDIR/$CORE
      cp -f $SOURCESv28/priv-app/PrebuiltGmsCorePi.tar.xz $BUILDDIR/$ARCH/$RELEASEDIR/$CORE
      cp -f $SOURCESv28/priv-app/SetupWizardPrebuilt.tar.xz $BUILDDIR/$ARCH/$RELEASEDIR/$CORE
      cp -f $AOSPSOURCESv28/priv-app/Contacts.tar.xz $BUILDDIR/$ARCH/$RELEASEDIR/$AOSPCORE
      cp -f $AOSPSOURCESv28/priv-app/Dialer.tar.xz $BUILDDIR/$ARCH/$RELEASEDIR/$AOSPCORE
      cp -f $AOSPSOURCESv28/priv-app/ManagedProvisioning.tar.xz $BUILDDIR/$ARCH/$RELEASEDIR/$AOSPCORE
      cp -f $AOSPSOURCESv28/priv-app/Provision.tar.xz $BUILDDIR/$ARCH/$RELEASEDIR/$AOSPCORE
      # Installer components
      cp -f $UPDATEBINARY $BUILDDIR/$ARCH/$RELEASEDIR/$METADIR
      cp -f $UPDATESCRIPT $BUILDDIR/$ARCH/$RELEASEDIR/$METADIR
      cp -f $INSTALLER $BUILDDIR/$ARCH/$RELEASEDIR
      cp -f $CONFIG $BUILDDIR/$ARCH/$RELEASEDIR
      cp -f $DATA $BUILDDIR/$ARCH/$RELEASEDIR
      cp -f $BOOTLOG $BUILDDIR/$ARCH/$RELEASEDIR
      cp -f $PM $BUILDDIR/$ARCH/$RELEASEDIR
      cp -f $LICENSE $BUILDDIR/$ARCH/$RELEASEDIR
      cp -f $BUSYBOX $BUILDDIR/$ARCH/$RELEASEDIR
      cp -f $SQLITE_AARCH64 $BUILDDIR/$ARCH/$RELEASEDIR/sqlite3
      cp -f $ZIPALIGN_AARCH64 $BUILDDIR/$ARCH/$RELEASEDIR/zipalign
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
      # Create build property file
      makegprop
      replace_line $BUILDDIR/$ARCH/$RELEASEDIR/g.prop CustomGAppsPackage= CustomGAppsPackage="$CustomGAppsPackage"
      replace_line $BUILDDIR/$ARCH/$RELEASEDIR/g.prop platform= platform="$platform_64"
      replace_line $BUILDDIR/$ARCH/$RELEASEDIR/g.prop sdk= sdk="$sdk_28"
      replace_line $BUILDDIR/$ARCH/$RELEASEDIR/g.prop version= version="$version_28"
      replace_line $BUILDDIR/$ARCH/$RELEASEDIR/g.prop BuildDate= BuildDate="$BuildDate"
      replace_line $BUILDDIR/$ARCH/$RELEASEDIR/g.prop BuildID= BuildID="$BuildID"
      replace_line $BUILDDIR/$ARCH/$RELEASEDIR/g.prop Developer= Developer="$Developer"
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
    # API 29
    if [ "$API" == "29" ]; then
      # Install variable; Do not modify
      TARGET_ANDROID_SDK_V29='"29"'
      # Build property variable; Do not modify
      sdk_29="29"
      version_29="10.0.0"
      echo "Generating BiTGApps package for $ARCH with API level $API"
      # Create release directory
      mkdir $BUILDDIR/$ARCH/BiTGApps-${ARCH}-10.0.0-${COMMONRELEASE}
      RELEASEDIR="BiTGApps-${ARCH}-10.0.0-${COMMONRELEASE}"
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
      cp -f $AOSPSOURCESv29/app/Messaging.tar.xz $BUILDDIR/$ARCH/$RELEASEDIR/$AOSPSYS
      # Install etc packages
      cp -f $SOURCESv29/etc/Default.tar.xz $BUILDDIR/$ARCH/$RELEASEDIR/$ZIP
      cp -f $SOURCESv29/etc/Permissions.tar.xz $BUILDDIR/$ARCH/$RELEASEDIR/$ZIP
      cp -f $SOURCESv29/etc/Preferred.tar.xz $BUILDDIR/$ARCH/$RELEASEDIR/$ZIP
      cp -f $SOURCESv29/etc/Sysconfig.tar.xz $BUILDDIR/$ARCH/$RELEASEDIR/$ZIP
      cp -f $AOSPSOURCESv29/etc/Permissions.tar.xz $BUILDDIR/$ARCH/$RELEASEDIR/$AOSPZIP
      # Install framework package
      cp -f $SOURCESv29/framework/Framework.tar.xz $BUILDDIR/$ARCH/$RELEASEDIR/$ZIP
      # Install priv-app package
      cp -f $SOURCESv29/priv-app/AndroidMigratePrebuilt.tar.xz $BUILDDIR/$ARCH/$RELEASEDIR/$CORE
      cp -f $SOURCESv29/priv-app/ConfigUpdater.tar.xz $BUILDDIR/$ARCH/$RELEASEDIR/$CORE
      cp -f $SOURCESv29/priv-app/GoogleBackupTransport.tar.xz $BUILDDIR/$ARCH/$RELEASEDIR/$CORE
      cp -f $SOURCESv29/priv-app/GoogleExtServices.tar.xz $BUILDDIR/$ARCH/$RELEASEDIR/$CORE
      cp -f $SOURCESv29/priv-app/GoogleOneTimeInitializer.tar.xz $BUILDDIR/$ARCH/$RELEASEDIR/$CORE
      cp -f $SOURCESv29/priv-app/GoogleRestore.tar.xz $BUILDDIR/$ARCH/$RELEASEDIR/$CORE
      cp -f $SOURCESv29/priv-app/GoogleServicesFramework.tar.xz $BUILDDIR/$ARCH/$RELEASEDIR/$CORE
      cp -f $SOURCESv29/priv-app/Phonesky.tar.xz $BUILDDIR/$ARCH/$RELEASEDIR/$CORE
      cp -f $SOURCESv29/priv-app/PrebuiltGmsCoreQt.tar.xz $BUILDDIR/$ARCH/$RELEASEDIR/$CORE
      cp -f $SOURCESv29/priv-app/SetupWizardPrebuilt.tar.xz $BUILDDIR/$ARCH/$RELEASEDIR/$CORE
      cp -f $AOSPSOURCESv29/priv-app/Contacts.tar.xz $BUILDDIR/$ARCH/$RELEASEDIR/$AOSPCORE
      cp -f $AOSPSOURCESv29/priv-app/Dialer.tar.xz $BUILDDIR/$ARCH/$RELEASEDIR/$AOSPCORE
      cp -f $AOSPSOURCESv29/priv-app/ManagedProvisioning.tar.xz $BUILDDIR/$ARCH/$RELEASEDIR/$AOSPCORE
      cp -f $AOSPSOURCESv29/priv-app/Provision.tar.xz $BUILDDIR/$ARCH/$RELEASEDIR/$AOSPCORE
      # Installer components
      cp -f $UPDATEBINARY $BUILDDIR/$ARCH/$RELEASEDIR/$METADIR
      cp -f $UPDATESCRIPT $BUILDDIR/$ARCH/$RELEASEDIR/$METADIR
      cp -f $INSTALLER $BUILDDIR/$ARCH/$RELEASEDIR
      cp -f $CONFIG $BUILDDIR/$ARCH/$RELEASEDIR
      cp -f $DATA $BUILDDIR/$ARCH/$RELEASEDIR
      cp -f $BOOTLOG $BUILDDIR/$ARCH/$RELEASEDIR
      cp -f $LICENSE $BUILDDIR/$ARCH/$RELEASEDIR
      cp -f $BUSYBOX $BUILDDIR/$ARCH/$RELEASEDIR
      cp -f $SQLITE_AARCH64 $BUILDDIR/$ARCH/$RELEASEDIR/sqlite3
      cp -f $ZIPALIGN_AARCH64 $BUILDDIR/$ARCH/$RELEASEDIR/zipalign
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
      # Create build property file
      makegprop
      replace_line $BUILDDIR/$ARCH/$RELEASEDIR/g.prop CustomGAppsPackage= CustomGAppsPackage="$CustomGAppsPackage"
      replace_line $BUILDDIR/$ARCH/$RELEASEDIR/g.prop platform= platform="$platform_64"
      replace_line $BUILDDIR/$ARCH/$RELEASEDIR/g.prop sdk= sdk="$sdk_29"
      replace_line $BUILDDIR/$ARCH/$RELEASEDIR/g.prop version= version="$version_29"
      replace_line $BUILDDIR/$ARCH/$RELEASEDIR/g.prop BuildDate= BuildDate="$BuildDate"
      replace_line $BUILDDIR/$ARCH/$RELEASEDIR/g.prop BuildID= BuildID="$BuildID"
      replace_line $BUILDDIR/$ARCH/$RELEASEDIR/g.prop Developer= Developer="$Developer"
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
    # API 30
    if [ "$API" == "30" ]; then
      # Install variable; Do not modify
      TARGET_ANDROID_SDK_V30='"30"'
      # Build property variable; Do not modify
      sdk_30="30"
      version_30="11.0.0"
      echo "Generating BiTGApps package for $ARCH with API level $API"
      # Create release directory
      mkdir $BUILDDIR/$ARCH/BiTGApps-${ARCH}-11.0.0-${COMMONRELEASE}
      RELEASEDIR="BiTGApps-${ARCH}-11.0.0-${COMMONRELEASE}"
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
      cp -f $AOSPSOURCESv30/app/Messaging.tar.xz $BUILDDIR/$ARCH/$RELEASEDIR/$AOSPSYS
      # Install etc packages
      cp -f $SOURCESv30/etc/Default.tar.xz $BUILDDIR/$ARCH/$RELEASEDIR/$ZIP
      cp -f $SOURCESv30/etc/Permissions.tar.xz $BUILDDIR/$ARCH/$RELEASEDIR/$ZIP
      cp -f $SOURCESv30/etc/Preferred.tar.xz $BUILDDIR/$ARCH/$RELEASEDIR/$ZIP
      cp -f $SOURCESv30/etc/Sysconfig.tar.xz $BUILDDIR/$ARCH/$RELEASEDIR/$ZIP
      cp -f $AOSPSOURCESv30/etc/Permissions.tar.xz $BUILDDIR/$ARCH/$RELEASEDIR/$AOSPZIP
      # Install framework package
      cp -f $SOURCESv30/framework/Framework.tar.xz $BUILDDIR/$ARCH/$RELEASEDIR/$ZIP
      # Install overlay package
      cp -f $SOURCESv30/overlay/PlayStoreOverlay.tar.xz $BUILDDIR/$ARCH/$RELEASEDIR/$OVERLAY
      # Install priv-app package
      cp -f $SOURCESv30/priv-app/AndroidMigratePrebuilt.tar.xz $BUILDDIR/$ARCH/$RELEASEDIR/$CORE
      cp -f $SOURCESv30/priv-app/ConfigUpdater.tar.xz $BUILDDIR/$ARCH/$RELEASEDIR/$CORE
      cp -f $SOURCESv30/priv-app/GoogleBackupTransport.tar.xz $BUILDDIR/$ARCH/$RELEASEDIR/$CORE
      cp -f $SOURCESv30/priv-app/GoogleOneTimeInitializer.tar.xz $BUILDDIR/$ARCH/$RELEASEDIR/$CORE
      cp -f $SOURCESv30/priv-app/GoogleRestore.tar.xz $BUILDDIR/$ARCH/$RELEASEDIR/$CORE
      cp -f $SOURCESv30/priv-app/GoogleServicesFramework.tar.xz $BUILDDIR/$ARCH/$RELEASEDIR/$CORE
      cp -f $SOURCESv30/priv-app/Phonesky.tar.xz $BUILDDIR/$ARCH/$RELEASEDIR/$CORE
      cp -f $SOURCESv30/priv-app/PrebuiltGmsCoreRvc.tar.xz $BUILDDIR/$ARCH/$RELEASEDIR/$CORE
      cp -f $SOURCESv30/priv-app/SetupWizardPrebuilt.tar.xz $BUILDDIR/$ARCH/$RELEASEDIR/$CORE
      cp -f $AOSPSOURCESv30/priv-app/Contacts.tar.xz $BUILDDIR/$ARCH/$RELEASEDIR/$AOSPCORE
      cp -f $AOSPSOURCESv30/priv-app/Dialer.tar.xz $BUILDDIR/$ARCH/$RELEASEDIR/$AOSPCORE
      cp -f $AOSPSOURCESv30/priv-app/ManagedProvisioning.tar.xz $BUILDDIR/$ARCH/$RELEASEDIR/$AOSPCORE
      cp -f $AOSPSOURCESv30/priv-app/Provision.tar.xz $BUILDDIR/$ARCH/$RELEASEDIR/$AOSPCORE
      # Installer components
      cp -f $UPDATEBINARY $BUILDDIR/$ARCH/$RELEASEDIR/$METADIR
      cp -f $UPDATESCRIPT $BUILDDIR/$ARCH/$RELEASEDIR/$METADIR
      cp -f $INSTALLER $BUILDDIR/$ARCH/$RELEASEDIR
      cp -f $CONFIG $BUILDDIR/$ARCH/$RELEASEDIR
      cp -f $DATA $BUILDDIR/$ARCH/$RELEASEDIR
      cp -f $BOOTLOG $BUILDDIR/$ARCH/$RELEASEDIR
      cp -f $LICENSE $BUILDDIR/$ARCH/$RELEASEDIR
      cp -f $BUSYBOX $BUILDDIR/$ARCH/$RELEASEDIR
      cp -f $SQLITE_AARCH64 $BUILDDIR/$ARCH/$RELEASEDIR/sqlite3
      cp -f $ZIPALIGN_AARCH64 $BUILDDIR/$ARCH/$RELEASEDIR/zipalign
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
      # Create build property file
      makegprop
      replace_line $BUILDDIR/$ARCH/$RELEASEDIR/g.prop CustomGAppsPackage= CustomGAppsPackage="$CustomGAppsPackage"
      replace_line $BUILDDIR/$ARCH/$RELEASEDIR/g.prop platform= platform="$platform_64"
      replace_line $BUILDDIR/$ARCH/$RELEASEDIR/g.prop sdk= sdk="$sdk_30"
      replace_line $BUILDDIR/$ARCH/$RELEASEDIR/g.prop version= version="$version_30"
      replace_line $BUILDDIR/$ARCH/$RELEASEDIR/g.prop BuildDate= BuildDate="$BuildDate"
      replace_line $BUILDDIR/$ARCH/$RELEASEDIR/g.prop BuildID= BuildID="$BuildID"
      replace_line $BUILDDIR/$ARCH/$RELEASEDIR/g.prop Developer= Developer="$Developer"
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
  fi
}

# Build
makegapps
