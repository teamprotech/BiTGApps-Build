#!/bin/bash
#
##############################################################
# File name       : upload_sources.sh
#
# Description     : Upload pre-built packages
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

# Set environmental variables (Auto-generated)
. ENV/api.sh      # For GApps release
. ENV/platform.sh # For Platform based Addon release
. ENV/variant.sh  # For Variant based Addon release

# Check availability of environmental variables
if { [ ! -n "$SERVER" ] ||
     [ ! -n "$TESTRELEASE" ]; }; then
     echo "! Environmental variables not set. Aborting..."
  exit 1
fi

# Set defaults
export CREDENTIALS="$1"
export ARMEABI="$1"
export AARCH64="$1"
export COMMON="$1"
export CONFIG="$1"
export APK="$1"

# Server credentials
set_credentials() {
  if [ "$CREDENTIALS" == "creds" ]; then
    if [ "$SERVER" == "ga" ] || [ "$SERVER" == "dh" ]; then
      read -p "Enter user: " user
      read -p "Enter pass: " pass
      read -p "Enter host: " host
    fi
  fi
  # Export credentials in the global environment
  export user="$user"
  export pass="$pass"
  export host="$host"
}

check_credentials() {
  if { [ ! -n "$user" ] &&
       [ ! -n "$pass" ] &&
       [ ! -n "$host" ]; }; then
    echo "! No credentials found. Aborting..."
    exit 1
  fi
}

# ARMEABI Sources
arm_sources() {
  if [ "$ARMEABI" == "arm" ]; then
    if [ ! -n "$TESTRELEASE" ]; then
      if [ "$SERVER" == "ga" ]; then
        if [ -n "$COMMONGAPPSRELEASE" ]; then
          $TARGET_API_31 && curl -T out/arm/BiTGApps-arm-12.0.0-${COMMONGAPPSRELEASE}_signed.zip "ftp://${user}:${pass}@${host}/arm/S/BiTGApps-arm-12.0.0-${COMMONGAPPSRELEASE}_signed.zip"
          $TARGET_API_30 && curl -T out/arm/BiTGApps-arm-11.0.0-${COMMONGAPPSRELEASE}_signed.zip "ftp://${user}:${pass}@${host}/arm/R/BiTGApps-arm-11.0.0-${COMMONGAPPSRELEASE}_signed.zip"
          $TARGET_API_29 && curl -T out/arm/BiTGApps-arm-10.0.0-${COMMONGAPPSRELEASE}_signed.zip "ftp://${user}:${pass}@${host}/arm/Q/BiTGApps-arm-10.0.0-${COMMONGAPPSRELEASE}_signed.zip"
          $TARGET_API_28 && curl -T out/arm/BiTGApps-arm-9.0.0-${COMMONGAPPSRELEASE}_signed.zip "ftp://${user}:${pass}@${host}/arm/Pie/BiTGApps-arm-9.0.0-${COMMONGAPPSRELEASE}_signed.zip"
          $TARGET_API_27 && curl -T out/arm/BiTGApps-arm-8.1.0-${COMMONGAPPSRELEASE}_signed.zip "ftp://${user}:${pass}@${host}/arm/Oreo/BiTGApps-arm-8.1.0-${COMMONGAPPSRELEASE}_signed.zip"
          $TARGET_API_26 && curl -T out/arm/BiTGApps-arm-8.0.0-${COMMONGAPPSRELEASE}_signed.zip "ftp://${user}:${pass}@${host}/arm/Oreo/BiTGApps-arm-8.0.0-${COMMONGAPPSRELEASE}_signed.zip"
          $TARGET_API_25 && curl -T out/arm/BiTGApps-arm-7.1.x-${COMMONGAPPSRELEASE}_signed.zip "ftp://${user}:${pass}@${host}/arm/Nougat/BiTGApps-arm-7.1.x-${COMMONGAPPSRELEASE}_signed.zip"
        fi
        if [ -n "$COMMONADDONRELEASE" ]; then
          $TARGET_PLATFORM_ARM && curl -T out/arm/BiTGApps-addon-arm-${COMMONADDONRELEASE}_signed.zip "ftp://${user}:${pass}@${host}/addon/config/arm/BiTGApps-addon-arm-${COMMONADDONRELEASE}_signed.zip"
        fi
      fi
      if [ "$SERVER" == "dh" ]; then
        if [ -n "$COMMONGAPPSRELEASE" ]; then
          $TARGET_API_31 && curl -T out/arm/BiTGApps-arm-12.0.0-${COMMONGAPPSRELEASE}_signed.zip "ftp://${user}:${pass}@${host}/bitgapps.com/downloads/arm/S/BiTGApps-arm-12.0.0-${COMMONGAPPSRELEASE}_signed.zip"
          $TARGET_API_30 && curl -T out/arm/BiTGApps-arm-11.0.0-${COMMONGAPPSRELEASE}_signed.zip "ftp://${user}:${pass}@${host}/bitgapps.com/downloads/arm/R/BiTGApps-arm-11.0.0-${COMMONGAPPSRELEASE}_signed.zip"
          $TARGET_API_29 && curl -T out/arm/BiTGApps-arm-10.0.0-${COMMONGAPPSRELEASE}_signed.zip "ftp://${user}:${pass}@${host}/bitgapps.com/downloads/arm/Q/BiTGApps-arm-10.0.0-${COMMONGAPPSRELEASE}_signed.zip"
          $TARGET_API_28 && curl -T out/arm/BiTGApps-arm-9.0.0-${COMMONGAPPSRELEASE}_signed.zip "ftp://${user}:${pass}@${host}/bitgapps.com/downloads/arm/Pie/BiTGApps-arm-9.0.0-${COMMONGAPPSRELEASE}_signed.zip"
          $TARGET_API_27 && curl -T out/arm/BiTGApps-arm-8.1.0-${COMMONGAPPSRELEASE}_signed.zip "ftp://${user}:${pass}@${host}/bitgapps.com/downloads/arm/Oreo/BiTGApps-arm-8.1.0-${COMMONGAPPSRELEASE}_signed.zip"
          $TARGET_API_26 && curl -T out/arm/BiTGApps-arm-8.0.0-${COMMONGAPPSRELEASE}_signed.zip "ftp://${user}:${pass}@${host}/bitgapps.com/downloads/arm/Oreo/BiTGApps-arm-8.0.0-${COMMONGAPPSRELEASE}_signed.zip"
          $TARGET_API_25 && curl -T out/arm/BiTGApps-arm-7.1.x-${COMMONGAPPSRELEASE}_signed.zip "ftp://${user}:${pass}@${host}/bitgapps.com/downloads/arm/Nougat/BiTGApps-arm-7.1.x-${COMMONGAPPSRELEASE}_signed.zip"
        fi
        if [ -n "$COMMONADDONRELEASE" ]; then
          $TARGET_PLATFORM_ARM && curl -T out/arm/BiTGApps-addon-arm-${COMMONADDONRELEASE}_signed.zip "ftp://${user}:${pass}@${host}/bitgapps.com/downloads/addon/config/arm/BiTGApps-addon-arm-${COMMONADDONRELEASE}_signed.zip"
        fi
      fi
    fi
    if [ -n "$TESTRELEASE" ]; then
      if [ "$SERVER" == "dh" ]; then
        if [ -n "$COMMONGAPPSRELEASE" ]; then
          $TARGET_API_31 && curl -T out/arm/BiTGApps-arm-12.0.0-${COMMONGAPPSRELEASE}_signed-${TOKEN}.zip "ftp://${user}:${pass}@${host}/bitgapps.com/release/Test/arm/S/BiTGApps-arm-12.0.0-${COMMONGAPPSRELEASE}_signed-${TOKEN}.zip"
          $TARGET_API_30 && curl -T out/arm/BiTGApps-arm-11.0.0-${COMMONGAPPSRELEASE}_signed-${TOKEN}.zip "ftp://${user}:${pass}@${host}/bitgapps.com/release/Test/arm/R/BiTGApps-arm-11.0.0-${COMMONGAPPSRELEASE}_signed-${TOKEN}.zip"
          $TARGET_API_29 && curl -T out/arm/BiTGApps-arm-10.0.0-${COMMONGAPPSRELEASE}_signed-${TOKEN}.zip "ftp://${user}:${pass}@${host}/bitgapps.com/release/Test/arm/Q/BiTGApps-arm-10.0.0-${COMMONGAPPSRELEASE}_signed-${TOKEN}.zip"
          $TARGET_API_28 && curl -T out/arm/BiTGApps-arm-9.0.0-${COMMONGAPPSRELEASE}_signed-${TOKEN}.zip "ftp://${user}:${pass}@${host}/bitgapps.com/release/Test/arm/Pie/BiTGApps-arm-9.0.0-${COMMONGAPPSRELEASE}_signed-${TOKEN}.zip"
          $TARGET_API_27 && curl -T out/arm/BiTGApps-arm-8.1.0-${COMMONGAPPSRELEASE}_signed-${TOKEN}.zip "ftp://${user}:${pass}@${host}/bitgapps.com/release/Test/arm/Oreo/BiTGApps-arm-8.1.0-${COMMONGAPPSRELEASE}_signed-${TOKEN}.zip"
          $TARGET_API_26 && curl -T out/arm/BiTGApps-arm-8.0.0-${COMMONGAPPSRELEASE}_signed-${TOKEN}.zip "ftp://${user}:${pass}@${host}/bitgapps.com/release/Test/arm/Oreo/BiTGApps-arm-8.0.0-${COMMONGAPPSRELEASE}_signed-${TOKEN}.zip"
          $TARGET_API_25 && curl -T out/arm/BiTGApps-arm-7.1.x-${COMMONGAPPSRELEASE}_signed-${TOKEN}.zip "ftp://${user}:${pass}@${host}/bitgapps.com/release/Test/arm/Nougat/BiTGApps-arm-7.1.x-${COMMONGAPPSRELEASE}_signed-${TOKEN}.zip"
        fi
        if [ -n "$COMMONADDONRELEASE" ]; then
          $TARGET_PLATFORM_ARM && curl -T out/arm/BiTGApps-addon-arm-${COMMONADDONRELEASE}_signed-${TOKEN}.zip "ftp://${user}:${pass}@${host}/bitgapps.com/release/Test/addon/config/arm/BiTGApps-addon-arm-${COMMONADDONRELEASE}_signed-${TOKEN}.zip"
        fi
      fi
    fi
  fi
}

# AARCH64 Sources
arm64_sources() {
  if [ "$AARCH64" == "arm64" ]; then
    if [ ! -n "$TESTRELEASE" ]; then
      if [ "$SERVER" == "ga" ]; then
        if [ -n "$COMMONGAPPSRELEASE" ]; then
          $TARGET_API_31 && curl -T out/arm64/BiTGApps-arm64-12.0.0-${COMMONGAPPSRELEASE}_signed.zip "ftp://${user}:${pass}@${host}/arm64/S/BiTGApps-arm64-12.0.0-${COMMONGAPPSRELEASE}_signed.zip"
          $TARGET_API_30 && curl -T out/arm64/BiTGApps-arm64-11.0.0-${COMMONGAPPSRELEASE}_signed.zip "ftp://${user}:${pass}@${host}/arm64/R/BiTGApps-arm64-11.0.0-${COMMONGAPPSRELEASE}_signed.zip"
          $TARGET_API_29 && curl -T out/arm64/BiTGApps-arm64-10.0.0-${COMMONGAPPSRELEASE}_signed.zip "ftp://${user}:${pass}@${host}/arm64/Q/BiTGApps-arm64-10.0.0-${COMMONGAPPSRELEASE}_signed.zip"
          $TARGET_API_28 && curl -T out/arm64/BiTGApps-arm64-9.0.0-${COMMONGAPPSRELEASE}_signed.zip "ftp://${user}:${pass}@${host}/arm64/Pie/BiTGApps-arm64-9.0.0-${COMMONGAPPSRELEASE}_signed.zip"
          $TARGET_API_27 && curl -T out/arm64/BiTGApps-arm64-8.1.0-${COMMONGAPPSRELEASE}_signed.zip "ftp://${user}:${pass}@${host}/arm64/Oreo/BiTGApps-arm64-8.1.0-${COMMONGAPPSRELEASE}_signed.zip"
          $TARGET_API_26 && curl -T out/arm64/BiTGApps-arm64-8.0.0-${COMMONGAPPSRELEASE}_signed.zip "ftp://${user}:${pass}@${host}/arm64/Oreo/BiTGApps-arm64-8.0.0-${COMMONGAPPSRELEASE}_signed.zip"
          $TARGET_API_25 && curl -T out/arm64/BiTGApps-arm64-7.1.x-${COMMONGAPPSRELEASE}_signed.zip "ftp://${user}:${pass}@${host}/arm64/Nougat/BiTGApps-arm64-7.1.x-${COMMONGAPPSRELEASE}_signed.zip"
        fi
        if [ -n "$COMMONADDONRELEASE" ]; then
          $TARGET_PLATFORM_ARM64 && curl -T out/arm64/BiTGApps-addon-arm64-${COMMONADDONRELEASE}_signed.zip "ftp://${user}:${pass}@${host}/addon/config/arm64/BiTGApps-addon-arm64-${COMMONADDONRELEASE}_signed.zip"
        fi
      fi
      if [ "$SERVER" == "dh" ]; then
        if [ -n "$COMMONGAPPSRELEASE" ]; then
          $TARGET_API_31 && curl -T out/arm64/BiTGApps-arm64-12.0.0-${COMMONGAPPSRELEASE}_signed.zip "ftp://${user}:${pass}@${host}/bitgapps.com/downloads/arm64/S/BiTGApps-arm64-12.0.0-${COMMONGAPPSRELEASE}_signed.zip"
          $TARGET_API_30 && curl -T out/arm64/BiTGApps-arm64-11.0.0-${COMMONGAPPSRELEASE}_signed.zip "ftp://${user}:${pass}@${host}/bitgapps.com/downloads/arm64/R/BiTGApps-arm64-11.0.0-${COMMONGAPPSRELEASE}_signed.zip"
          $TARGET_API_29 && curl -T out/arm64/BiTGApps-arm64-10.0.0-${COMMONGAPPSRELEASE}_signed.zip "ftp://${user}:${pass}@${host}/bitgapps.com/downloads/arm64/Q/BiTGApps-arm64-10.0.0-${COMMONGAPPSRELEASE}_signed.zip"
          $TARGET_API_28 && curl -T out/arm64/BiTGApps-arm64-9.0.0-${COMMONGAPPSRELEASE}_signed.zip "ftp://${user}:${pass}@${host}/bitgapps.com/downloads/arm64/Pie/BiTGApps-arm64-9.0.0-${COMMONGAPPSRELEASE}_signed.zip"
          $TARGET_API_27 && curl -T out/arm64/BiTGApps-arm64-8.1.0-${COMMONGAPPSRELEASE}_signed.zip "ftp://${user}:${pass}@${host}/bitgapps.com/downloads/arm64/Oreo/BiTGApps-arm64-8.1.0-${COMMONGAPPSRELEASE}_signed.zip"
          $TARGET_API_26 && curl -T out/arm64/BiTGApps-arm64-8.0.0-${COMMONGAPPSRELEASE}_signed.zip "ftp://${user}:${pass}@${host}/bitgapps.com/downloads/arm64/Oreo/BiTGApps-arm64-8.0.0-${COMMONGAPPSRELEASE}_signed.zip"
          $TARGET_API_25 && curl -T out/arm64/BiTGApps-arm64-7.1.x-${COMMONGAPPSRELEASE}_signed.zip "ftp://${user}:${pass}@${host}/bitgapps.com/downloads/arm64/Nougat/BiTGApps-arm64-7.1.x-${COMMONGAPPSRELEASE}_signed.zip"
        fi
        if [ -n "$COMMONADDONRELEASE" ]; then
          $TARGET_PLATFORM_ARM64 && curl -T out/arm64/BiTGApps-addon-arm64-${COMMONADDONRELEASE}_signed.zip "ftp://${user}:${pass}@${host}/bitgapps.com/downloads/addon/config/arm64/BiTGApps-addon-arm64-${COMMONADDONRELEASE}_signed.zip"
        fi
      fi
    fi
    if [ -n "$TESTRELEASE" ]; then
      if [ "$SERVER" == "dh" ]; then
        if [ -n "$COMMONGAPPSRELEASE" ]; then
          $TARGET_API_31 && curl -T out/arm64/BiTGApps-arm64-12.0.0-${COMMONGAPPSRELEASE}_signed-${TOKEN}.zip "ftp://${user}:${pass}@${host}/bitgapps.com/release/Test/arm64/S/BiTGApps-arm64-12.0.0-${COMMONGAPPSRELEASE}_signed-${TOKEN}.zip"
          $TARGET_API_30 && curl -T out/arm64/BiTGApps-arm64-11.0.0-${COMMONGAPPSRELEASE}_signed-${TOKEN}.zip "ftp://${user}:${pass}@${host}/bitgapps.com/release/Test/arm64/R/BiTGApps-arm64-11.0.0-${COMMONGAPPSRELEASE}_signed-${TOKEN}.zip"
          $TARGET_API_29 && curl -T out/arm64/BiTGApps-arm64-10.0.0-${COMMONGAPPSRELEASE}_signed-${TOKEN}.zip "ftp://${user}:${pass}@${host}/bitgapps.com/release/Test/arm64/Q/BiTGApps-arm64-10.0.0-${COMMONGAPPSRELEASE}_signed-${TOKEN}.zip"
          $TARGET_API_28 && curl -T out/arm64/BiTGApps-arm64-9.0.0-${COMMONGAPPSRELEASE}_signed-${TOKEN}.zip "ftp://${user}:${pass}@${host}/bitgapps.com/release/Test/arm64/Pie/BiTGApps-arm64-9.0.0-${COMMONGAPPSRELEASE}_signed-${TOKEN}.zip"
          $TARGET_API_27 && curl -T out/arm64/BiTGApps-arm64-8.1.0-${COMMONGAPPSRELEASE}_signed-${TOKEN}.zip "ftp://${user}:${pass}@${host}/bitgapps.com/release/Test/arm64/Oreo/BiTGApps-arm64-8.1.0-${COMMONGAPPSRELEASE}_signed-${TOKEN}.zip"
          $TARGET_API_26 && curl -T out/arm64/BiTGApps-arm64-8.0.0-${COMMONGAPPSRELEASE}_signed-${TOKEN}.zip "ftp://${user}:${pass}@${host}/bitgapps.com/release/Test/arm64/Oreo/BiTGApps-arm64-8.0.0-${COMMONGAPPSRELEASE}_signed-${TOKEN}.zip"
          $TARGET_API_25 && curl -T out/arm64/BiTGApps-arm64-7.1.x-${COMMONGAPPSRELEASE}_signed-${TOKEN}.zip "ftp://${user}:${pass}@${host}/bitgapps.com/release/Test/arm64/Nougat/BiTGApps-arm64-7.1.x-${COMMONGAPPSRELEASE}_signed-${TOKEN}.zip"
        fi
        if [ -n "$COMMONADDONRELEASE" ]; then
          $TARGET_PLATFORM_ARM64 && curl -T out/arm64/BiTGApps-addon-arm64-${COMMONADDONRELEASE}_signed-${TOKEN}.zip "ftp://${user}:${pass}@${host}/bitgapps.com/release/Test/addon/config/arm64/BiTGApps-addon-arm64-${COMMONADDONRELEASE}_signed-${TOKEN}.zip"
        fi
      fi
    fi
  fi
}

# COMMON Sources; Contains both ARMEABI & AARCH64 packages
common_sources() {
  if [ "$COMMON" == "common" ]; then
    if [ ! -n "$TESTRELEASE" ]; then
      if [ "$SERVER" == "ga" ]; then
        if [ -n "$COMMONADDONRELEASE" ]; then
          $TARGET_VARIANT_ASSISTANT && curl -T out/common/BiTGApps-addon-assistant-${COMMONADDONRELEASE}_signed.zip "ftp://${user}:${pass}@${host}/addon/non-config/BiTGApps-addon-assistant-${COMMONADDONRELEASE}_signed.zip"
          $TARGET_VARIANT_CALCULATOR && curl -T out/common/BiTGApps-addon-calculator-${COMMONADDONRELEASE}_signed.zip "ftp://${user}:${pass}@${host}/addon/non-config/BiTGApps-addon-calculator-${COMMONADDONRELEASE}_signed.zip"
          $TARGET_VARIANT_CALENDAR && curl -T out/common/BiTGApps-addon-calendar-${COMMONADDONRELEASE}_signed.zip "ftp://${user}:${pass}@${host}/addon/non-config/BiTGApps-addon-calendar-${COMMONADDONRELEASE}_signed.zip"
          $TARGET_VARIANT_CONTACTS && curl -T out/common/BiTGApps-addon-contacts-${COMMONADDONRELEASE}_signed.zip "ftp://${user}:${pass}@${host}/addon/non-config/BiTGApps-addon-contacts-${COMMONADDONRELEASE}_signed.zip"
          $TARGET_VARIANT_DESKCLOCK && curl -T out/common/BiTGApps-addon-deskclock-${COMMONADDONRELEASE}_signed.zip "ftp://${user}:${pass}@${host}/addon/non-config/BiTGApps-addon-deskclock-${COMMONADDONRELEASE}_signed.zip"
          $TARGET_VARIANT_DIALER && curl -T out/common/BiTGApps-addon-dialer-${COMMONADDONRELEASE}_signed.zip "ftp://${user}:${pass}@${host}/addon/non-config/BiTGApps-addon-dialer-${COMMONADDONRELEASE}_signed.zip"
          $TARGET_VARIANT_GBOARD && curl -T out/common/BiTGApps-addon-gboard-${COMMONADDONRELEASE}_signed.zip "ftp://${user}:${pass}@${host}/addon/non-config/BiTGApps-addon-gboard-${COMMONADDONRELEASE}_signed.zip"
          $TARGET_VARIANT_MARKUP && curl -T out/common/BiTGApps-addon-markup-${COMMONADDONRELEASE}_signed.zip "ftp://${user}:${pass}@${host}/addon/non-config/BiTGApps-addon-markup-${COMMONADDONRELEASE}_signed.zip"
          $TARGET_VARIANT_MESSAGES && curl -T out/common/BiTGApps-addon-messages-${COMMONADDONRELEASE}_signed.zip "ftp://${user}:${pass}@${host}/addon/non-config/BiTGApps-addon-messages-${COMMONADDONRELEASE}_signed.zip"
          $TARGET_VARIANT_PHOTOS && curl -T out/common/BiTGApps-addon-photos-${COMMONADDONRELEASE}_signed.zip "ftp://${user}:${pass}@${host}/addon/non-config/BiTGApps-addon-photos-${COMMONADDONRELEASE}_signed.zip"
          $TARGET_VARIANT_SOUNDPICKER && curl -T out/common/BiTGApps-addon-soundpicker-${COMMONADDONRELEASE}_signed.zip "ftp://${user}:${pass}@${host}/addon/non-config/BiTGApps-addon-soundpicker-${COMMONADDONRELEASE}_signed.zip"
          $TARGET_VARIANT_VANCED && curl -T out/common/BiTGApps-addon-vanced-${COMMONADDONRELEASE}_signed.zip "ftp://${user}:${pass}@${host}/addon/non-config/BiTGApps-addon-vanced-${COMMONADDONRELEASE}_signed.zip"
          $TARGET_VARIANT_WELLBEING && curl -T out/common/BiTGApps-addon-wellbeing-${COMMONADDONRELEASE}_signed.zip "ftp://${user}:${pass}@${host}/addon/non-config/BiTGApps-addon-wellbeing-${COMMONADDONRELEASE}_signed.zip"
        fi
      fi
      if [ "$SERVER" == "dh" ]; then
        if [ -n "$COMMONADDONRELEASE" ]; then
          $TARGET_VARIANT_ASSISTANT && curl -T out/common/BiTGApps-addon-assistant-${COMMONADDONRELEASE}_signed.zip "ftp://${user}:${pass}@${host}/bitgapps.com/downloads/addon/non-config/BiTGApps-addon-assistant-${COMMONADDONRELEASE}_signed.zip"
          $TARGET_VARIANT_CALCULATOR && curl -T out/common/BiTGApps-addon-calculator-${COMMONADDONRELEASE}_signed.zip "ftp://${user}:${pass}@${host}/bitgapps.com/downloads/addon/non-config/BiTGApps-addon-calculator-${COMMONADDONRELEASE}_signed.zip"
          $TARGET_VARIANT_CALENDAR && curl -T out/common/BiTGApps-addon-calendar-${COMMONADDONRELEASE}_signed.zip "ftp://${user}:${pass}@${host}/bitgapps.com/downloads/addon/non-config/BiTGApps-addon-calendar-${COMMONADDONRELEASE}_signed.zip"
          $TARGET_VARIANT_CONTACTS && curl -T out/common/BiTGApps-addon-contacts-${COMMONADDONRELEASE}_signed.zip "ftp://${user}:${pass}@${host}/bitgapps.com/downloads/addon/non-config/BiTGApps-addon-contacts-${COMMONADDONRELEASE}_signed.zip"
          $TARGET_VARIANT_DESKCLOCK && curl -T out/common/BiTGApps-addon-deskclock-${COMMONADDONRELEASE}_signed.zip "ftp://${user}:${pass}@${host}/bitgapps.com/downloads/addon/non-config/BiTGApps-addon-deskclock-${COMMONADDONRELEASE}_signed.zip"
          $TARGET_VARIANT_DIALER && curl -T out/common/BiTGApps-addon-dialer-${COMMONADDONRELEASE}_signed.zip "ftp://${user}:${pass}@${host}/bitgapps.com/downloads/addon/non-config/BiTGApps-addon-dialer-${COMMONADDONRELEASE}_signed.zip"
          $TARGET_VARIANT_GBOARD && curl -T out/common/BiTGApps-addon-gboard-${COMMONADDONRELEASE}_signed.zip "ftp://${user}:${pass}@${host}/bitgapps.com/downloads/addon/non-config/BiTGApps-addon-gboard-${COMMONADDONRELEASE}_signed.zip"
          $TARGET_VARIANT_MARKUP && curl -T out/common/BiTGApps-addon-markup-${COMMONADDONRELEASE}_signed.zip "ftp://${user}:${pass}@${host}/bitgapps.com/downloads/addon/non-config/BiTGApps-addon-markup-${COMMONADDONRELEASE}_signed.zip"
          $TARGET_VARIANT_MESSAGES && curl -T out/common/BiTGApps-addon-messages-${COMMONADDONRELEASE}_signed.zip "ftp://${user}:${pass}@${host}/bitgapps.com/downloads/addon/non-config/BiTGApps-addon-messages-${COMMONADDONRELEASE}_signed.zip"
          $TARGET_VARIANT_PHOTOS && curl -T out/common/BiTGApps-addon-photos-${COMMONADDONRELEASE}_signed.zip "ftp://${user}:${pass}@${host}/bitgapps.com/downloads/addon/non-config/BiTGApps-addon-photos-${COMMONADDONRELEASE}_signed.zip"
          $TARGET_VARIANT_SOUNDPICKER && curl -T out/common/BiTGApps-addon-soundpicker-${COMMONADDONRELEASE}_signed.zip "ftp://${user}:${pass}@${host}/bitgapps.com/downloads/addon/non-config/BiTGApps-addon-soundpicker-${COMMONADDONRELEASE}_signed.zip"
          $TARGET_VARIANT_VANCED && curl -T out/common/BiTGApps-addon-vanced-${COMMONADDONRELEASE}_signed.zip "ftp://${user}:${pass}@${host}/bitgapps.com/downloads/addon/non-config/BiTGApps-addon-vanced-${COMMONADDONRELEASE}_signed.zip"
          $TARGET_VARIANT_WELLBEING && curl -T out/common/BiTGApps-addon-wellbeing-${COMMONADDONRELEASE}_signed.zip "ftp://${user}:${pass}@${host}/bitgapps.com/downloads/addon/non-config/BiTGApps-addon-wellbeing-${COMMONADDONRELEASE}_signed.zip"
        fi
      fi
    fi
    if [ -n "$TESTRELEASE" ]; then
      if [ "$SERVER" == "dh" ]; then
        if [ -n "$COMMONADDONRELEASE" ]; then
          $TARGET_VARIANT_ASSISTANT && curl -T out/common/BiTGApps-addon-assistant-${COMMONADDONRELEASE}_signed-${TOKEN}.zip "ftp://${user}:${pass}@${host}/bitgapps.com/release/Test/addon/non-config/BiTGApps-addon-assistant-${COMMONADDONRELEASE}_signed-${TOKEN}.zip"
          $TARGET_VARIANT_CALCULATOR && curl -T out/common/BiTGApps-addon-calculator-${COMMONADDONRELEASE}_signed-${TOKEN}.zip "ftp://${user}:${pass}@${host}/bitgapps.com/release/Test/addon/non-config/BiTGApps-addon-calculator-${COMMONADDONRELEASE}_signed-${TOKEN}.zip"
          $TARGET_VARIANT_CALENDAR && curl -T out/common/BiTGApps-addon-calendar-${COMMONADDONRELEASE}_signed-${TOKEN}.zip "ftp://${user}:${pass}@${host}/bitgapps.com/release/Test/addon/non-config/BiTGApps-addon-calendar-${COMMONADDONRELEASE}_signed-${TOKEN}.zip"
          $TARGET_VARIANT_CONTACTS && curl -T out/common/BiTGApps-addon-contacts-${COMMONADDONRELEASE}_signed-${TOKEN}.zip "ftp://${user}:${pass}@${host}/bitgapps.com/release/Test/addon/non-config/BiTGApps-addon-contacts-${COMMONADDONRELEASE}_signed-${TOKEN}.zip"
          $TARGET_VARIANT_DESKCLOCK && curl -T out/common/BiTGApps-addon-deskclock-${COMMONADDONRELEASE}_signed-${TOKEN}.zip "ftp://${user}:${pass}@${host}/bitgapps.com/release/Test/addon/non-config/BiTGApps-addon-deskclock-${COMMONADDONRELEASE}_signed-${TOKEN}.zip"
          $TARGET_VARIANT_DIALER && curl -T out/common/BiTGApps-addon-dialer-${COMMONADDONRELEASE}_signed-${TOKEN}.zip "ftp://${user}:${pass}@${host}/bitgapps.com/release/Test/addon/non-config/BiTGApps-addon-dialer-${COMMONADDONRELEASE}_signed-${TOKEN}.zip"
          $TARGET_VARIANT_GBOARD && curl -T out/common/BiTGApps-addon-gboard-${COMMONADDONRELEASE}_signed-${TOKEN}.zip "ftp://${user}:${pass}@${host}/bitgapps.com/release/Test/addon/non-config/BiTGApps-addon-gboard-${COMMONADDONRELEASE}_signed-${TOKEN}.zip"
          $TARGET_VARIANT_MARKUP && curl -T out/common/BiTGApps-addon-markup-${COMMONADDONRELEASE}_signed-${TOKEN}.zip "ftp://${user}:${pass}@${host}/bitgapps.com/release/Test/addon/non-config/BiTGApps-addon-markup-${COMMONADDONRELEASE}_signed-${TOKEN}.zip"
          $TARGET_VARIANT_MESSAGES && curl -T out/common/BiTGApps-addon-messages-${COMMONADDONRELEASE}_signed-${TOKEN}.zip "ftp://${user}:${pass}@${host}/bitgapps.com/release/Test/addon/non-config/BiTGApps-addon-messages-${COMMONADDONRELEASE}_signed-${TOKEN}.zip"
          $TARGET_VARIANT_PHOTOS && curl -T out/common/BiTGApps-addon-photos-${COMMONADDONRELEASE}_signed-${TOKEN}.zip "ftp://${user}:${pass}@${host}/bitgapps.com/release/Test/addon/non-config/BiTGApps-addon-photos-${COMMONADDONRELEASE}_signed-${TOKEN}.zip"
          $TARGET_VARIANT_SOUNDPICKER && curl -T out/common/BiTGApps-addon-soundpicker-${COMMONADDONRELEASE}_signed-${TOKEN}.zip "ftp://${user}:${pass}@${host}/bitgapps.com/release/Test/addon/non-config/BiTGApps-addon-soundpicker-${COMMONADDONRELEASE}_signed-${TOKEN}.zip"
          $TARGET_VARIANT_VANCED && curl -T out/common/BiTGApps-addon-vanced-${COMMONADDONRELEASE}_signed-${TOKEN}.zip "ftp://${user}:${pass}@${host}/bitgapps.com/release/Test/addon/non-config/BiTGApps-addon-vanced-${COMMONADDONRELEASE}_signed-${TOKEN}.zip"
          $TARGET_VARIANT_WELLBEING && curl -T out/common/BiTGApps-addon-wellbeing-${COMMONADDONRELEASE}_signed-${TOKEN}.zip "ftp://${user}:${pass}@${host}/bitgapps.com/release/Test/addon/non-config/BiTGApps-addon-wellbeing-${COMMONADDONRELEASE}_signed-${TOKEN}.zip"
        fi
      fi
    fi
  fi
}

# CONFIG sources
config_sources() {
  if [ "$CONFIG" == "config" ]; then
    if [ ! -n "$TESTRELEASE" ]; then
      if [ "$SERVER" == "ga" ]; then
        $TARGET_CONFIG_ADDON && curl -T BiTGApps/configs/addon-config.prop "ftp://${user}:${pass}@${host}/config/Addon/addon-config.prop"
        $TARGET_CONFIG_BOOT && curl -T BiTGApps/configs/boot-config.prop "ftp://${user}:${pass}@${host}/config/Bootlog/boot-config.prop"
        $TARGET_CONFIG_CTS && curl -T BiTGApps/configs/cts-config.prop "ftp://${user}:${pass}@${host}/config/Safetynet/cts-config.prop"
        $TARGET_CONFIG_SETUP && curl -T BiTGApps/configs/setup-config.prop "ftp://${user}:${pass}@${host}/config/SetupWizard/setup-config.prop"
      fi
      if [ "$SERVER" == "dh" ]; then
        $TARGET_CONFIG_ADDON && curl -T BiTGApps/configs/addon-config.prop "ftp://${user}:${pass}@${host}/bitgapps.com/downloads/config/Addon/addon-config.prop"
        $TARGET_CONFIG_BOOT && curl -T BiTGApps/configs/boot-config.prop "ftp://${user}:${pass}@${host}/bitgapps.com/downloads/config/Bootlog/boot-config.prop"
        $TARGET_CONFIG_CTS && curl -T BiTGApps/configs/cts-config.prop "ftp://${user}:${pass}@${host}/bitgapps.com/downloads/config/Safetynet/cts-config.prop"
        $TARGET_CONFIG_SETUP && curl -T BiTGApps/configs/setup-config.prop "ftp://${user}:${pass}@${host}/bitgapps.com/downloads/config/SetupWizard/setup-config.prop"
      fi
    fi
    if [ -n "$TESTRELEASE" ]; then
      if [ "$SERVER" == "dh" ]; then
        $TARGET_CONFIG_ADDON && curl -T BiTGApps/configs/addon-config.prop "ftp://${user}:${pass}@${host}/bitgapps.com/release/Test/config/Addon/addon-config.prop"
        $TARGET_CONFIG_BOOT && curl -T BiTGApps/configs/boot-config.prop "ftp://${user}:${pass}@${host}/bitgapps.com/release/Test/config/Bootlog/boot-config.prop"
        $TARGET_CONFIG_CTS && curl -T BiTGApps/configs/cts-config.prop "ftp://${user}:${pass}@${host}/bitgapps.com/release/Test/config/Safetynet/cts-config.prop"
        $TARGET_CONFIG_SETUP && curl -T BiTGApps/configs/setup-config.prop "ftp://${user}:${pass}@${host}/bitgapps.com/release/Test/config/SetupWizard/setup-config.prop"
      fi
    fi
  fi
}

# APK sources
apk_sources() {
  if [ "$APK" == "apk" ]; then
    if [ ! -n "$TESTRELEASE" ]; then
      if [ "$SERVER" == "ga" ]; then
        if [ -n "$APKRELEASE" ]; then
          curl -T BiTGApps-v${APKRELEASE}.apk "ftp://${user}:${pass}@${host}/APK/BiTGApps-v${APKRELEASE}.apk"
        else
          echo "! APKRELEASE environmental variable not set. Aborting..."
        fi
      fi
      if [ "$SERVER" == "dh" ]; then
        if [ -n "$APKRELEASE" ]; then
          curl -T BiTGApps-v${APKRELEASE}.apk "ftp://${user}:${pass}@${host}/bitgapps.com/downloads/APK/BiTGApps-v${APKRELEASE}.apk"
        else
          echo "! APKRELEASE environmental variable not set. Aborting..."
        fi
      fi
    fi
    if [ -n "$TESTRELEASE" ]; then
      if [ "$SERVER" == "dh" ]; then
        if [ -n "$APKRELEASE" ]; then
          curl -T BiTGApps-v${APKRELEASE}.apk "ftp://${user}:${pass}@${host}/bitgapps.com/release/Test/APK/BiTGApps-v${APKRELEASE}.apk"
        else
          echo "! APKRELEASE environmental variable not set. Aborting..."
        fi
      fi
    fi
  fi
}

# Execute functions
set_credentials
check_credentials
arm_sources
arm64_sources
common_sources
config_sources
apk_sources
