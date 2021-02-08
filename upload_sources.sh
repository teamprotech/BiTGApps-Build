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

# Check availability of environmental variables
if { [ ! -n "$SERVER" ] ||
     [ ! -n "$TESTRELEASE" ]; }; then
     echo "! Environmental variables not set. Aborting..."
  exit 1
fi

# Set defaults
export ARMEABI="$1"
export AARCH64="$1"
export COMMON="$1"
export CONFIG="$1"
export APK="$1"

# Server credentials
set_credentials() {
  if [ "$SERVER" == "ga" ]; then
    read -p "Enter user: " user
    read -p "Enter pass: " pass
    read -p "Enter host: " host
  fi
  if [ "$SERVER" == "dh" ]; then
    read -p "Enter user: " user
    read -p "Enter host: " host
  fi
  if [ "$SERVER" == "sf" ]; then
    read -p "Enter user: " user
  fi
}

check_credentials() {
  if [ ! -n "$user" ]; then
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
          $TARGET_API_30 && curl -T out/arm/BiTGApps-arm-11.0.0-${COMMONGAPPSRELEASE}_signed.zip "ftp://${user}:${password}@${host}/arm/R/BiTGApps-arm-11.0.0-${COMMONGAPPSRELEASE}_signed.zip"
          $TARGET_API_29 && curl -T out/arm/BiTGApps-arm-10.0.0-${COMMONGAPPSRELEASE}_signed.zip "ftp://${user}:${password}@${host}/arm/Q/BiTGApps-arm-10.0.0-${COMMONGAPPSRELEASE}_signed.zip"
          $TARGET_API_28 && curl -T out/arm/BiTGApps-arm-9.0.0-${COMMONGAPPSRELEASE}_signed.zip "ftp://${user}:${password}@${host}/arm/Pie/BiTGApps-arm-9.0.0-${COMMONGAPPSRELEASE}_signed.zip"
          $TARGET_API_27 && curl -T out/arm/BiTGApps-arm-8.1.0-${COMMONGAPPSRELEASE}_signed.zip "ftp://${user}:${password}@${host}/arm/Oreo/BiTGApps-arm-8.1.0-${COMMONGAPPSRELEASE}_signed.zip"
          $TARGET_API_26 && curl -T out/arm/BiTGApps-arm-8.0.0-${COMMONGAPPSRELEASE}_signed.zip "ftp://${user}:${password}@${host}/arm/Oreo/BiTGApps-arm-8.0.0-${COMMONGAPPSRELEASE}_signed.zip"
          $TARGET_API_25 && curl -T out/arm/BiTGApps-arm-7.1.2-${COMMONGAPPSRELEASE}_signed.zip "ftp://${user}:${password}@${host}/arm/Nougat/BiTGApps-arm-7.1.2-${COMMONGAPPSRELEASE}_signed.zip"
          $TARGET_API_25 && curl -T out/arm/BiTGApps-arm-7.1.1-${COMMONGAPPSRELEASE}_signed.zip "ftp://${user}:${password}@${host}/arm/Nougat/BiTGApps-arm-7.1.1-${COMMONGAPPSRELEASE}_signed.zip"
        fi
        if [ -n "$COMMONADDONRELEASE" ]; then
          $TARGET_PLATFOMR_ARM && curl -T out/arm/BiTGApps-addon-arm-${COMMONADDONRELEASE}_signed.zip "ftp://${user}:${password}@${host}/addon/config/arm/BiTGApps-addon-arm-${COMMONADDONRELEASE}_signed.zip"
        fi
      fi
      if [ "$SERVER" == "dh" ]; then
        if [ -n "$COMMONGAPPSRELEASE" ]; then
          $TARGET_API_30 && scp out/arm/BiTGApps-arm-11.0.0-${COMMONGAPPSRELEASE}_signed.zip ${user}@${host}:/home/dh_ddbfeb/bitgapps.com/downloads/arm/R
          $TARGET_API_29 && scp out/arm/BiTGApps-arm-10.0.0-${COMMONGAPPSRELEASE}_signed.zip ${user}@${host}:/home/dh_ddbfeb/bitgapps.com/downloads/arm/Q
          $TARGET_API_28 && scp out/arm/BiTGApps-arm-9.0.0-${COMMONGAPPSRELEASE}_signed.zip ${user}@${host}:/home/dh_ddbfeb/bitgapps.com/downloads/arm/Pie
          $TARGET_API_27 && scp out/arm/BiTGApps-arm-8.1.0-${COMMONGAPPSRELEASE}_signed.zip ${user}@${host}:/home/dh_ddbfeb/bitgapps.com/downloads/arm/Oreo
          $TARGET_API_26 && scp out/arm/BiTGApps-arm-8.0.0-${COMMONGAPPSRELEASE}_signed.zip ${user}@${host}:/home/dh_ddbfeb/bitgapps.com/downloads/arm/Oreo
          $TARGET_API_25 && scp out/arm/BiTGApps-arm-7.1.2-${COMMONGAPPSRELEASE}_signed.zip ${user}@${host}:/home/dh_ddbfeb/bitgapps.com/downloads/arm/Nougat
          $TARGET_API_25 && scp out/arm/BiTGApps-arm-7.1.1-${COMMONGAPPSRELEASE}_signed.zip ${user}@${host}:/home/dh_ddbfeb/bitgapps.com/downloads/arm/Nougat
        fi
        if [ -n "$COMMONADDONRELEASE" ]; then
          $TARGET_PLATFOMR_ARM && scp out/arm/BiTGApps-addon-arm-${COMMONADDONRELEASE}_signed.zip ${user}@${host}:/home/dh_ddbfeb/bitgapps.com/downloads/addon/config/arm
        fi
      fi
    fi
    if [ -n "$TESTRELEASE" ]; then
      if [ "$SERVER" == "sf" ]; then
        if [ -n "$COMMONGAPPSRELEASE" ]; then
          $TARGET_API_30 && scp out/arm/BiTGApps-arm-11.0.0-${COMMONGAPPSRELEASE}_signed.zip ${user}@frs.sourceforge.net:/home/frs/project/bitgapps/arm/30
          $TARGET_API_29 && scp out/arm/BiTGApps-arm-10.0.0-${COMMONGAPPSRELEASE}_signed.zip ${user}@frs.sourceforge.net:/home/frs/project/bitgapps/arm/29
          $TARGET_API_28 && scp out/arm/BiTGApps-arm-9.0.0-${COMMONGAPPSRELEASE}_signed.zip ${user}@frs.sourceforge.net:/home/frs/project/bitgapps/arm/28
          $TARGET_API_27 && scp out/arm/BiTGApps-arm-8.1.0-${COMMONGAPPSRELEASE}_signed.zip ${user}@frs.sourceforge.net:/home/frs/project/bitgapps/arm/27
          $TARGET_API_26 && scp out/arm/BiTGApps-arm-8.0.0-${COMMONGAPPSRELEASE}_signed.zip ${user}@frs.sourceforge.net:/home/frs/project/bitgapps/arm/26
          $TARGET_API_25 && scp out/arm/BiTGApps-arm-7.1.2-${COMMONGAPPSRELEASE}_signed.zip ${user}@frs.sourceforge.net:/home/frs/project/bitgapps/arm/25
          $TARGET_API_25 && scp out/arm/BiTGApps-arm-7.1.1-${COMMONGAPPSRELEASE}_signed.zip ${user}@frs.sourceforge.net:/home/frs/project/bitgapps/arm/25
        fi
        if [ -n "$COMMONADDONRELEASE" ]; then
          $TARGET_PLATFOMR_ARM && scp out/arm/BiTGApps-addon-arm-${COMMONADDONRELEASE}_signed.zip ${user}@frs.sourceforge.net:/home/frs/project/bitgapps/addon/config/arm
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
          $TARGET_API_30 && curl -T out/arm64/BiTGApps-arm64-11.0.0-${COMMONGAPPSRELEASE}_signed.zip "ftp://${user}:${password}@${host}/arm64/R/BiTGApps-arm64-11.0.0-${COMMONGAPPSRELEASE}_signed.zip"
          $TARGET_API_29 && curl -T out/arm64/BiTGApps-arm64-10.0.0-${COMMONGAPPSRELEASE}_signed.zip "ftp://${user}:${password}@${host}/arm64/Q/BiTGApps-arm64-10.0.0-${COMMONGAPPSRELEASE}_signed.zip"
          $TARGET_API_28 && curl -T out/arm64/BiTGApps-arm64-9.0.0-${COMMONGAPPSRELEASE}_signed.zip "ftp://${user}:${password}@${host}/arm64/Pie/BiTGApps-arm64-9.0.0-${COMMONGAPPSRELEASE}_signed.zip"
          $TARGET_API_27 && curl -T out/arm64/BiTGApps-arm64-8.1.0-${COMMONGAPPSRELEASE}_signed.zip "ftp://${user}:${password}@${host}/arm64/Oreo/BiTGApps-arm64-8.1.0-${COMMONGAPPSRELEASE}_signed.zip"
          $TARGET_API_26 && curl -T out/arm64/BiTGApps-arm64-8.0.0-${COMMONGAPPSRELEASE}_signed.zip "ftp://${user}:${password}@${host}/arm64/Oreo/BiTGApps-arm64-8.0.0-${COMMONGAPPSRELEASE}_signed.zip"
          $TARGET_API_25 && curl -T out/arm64/BiTGApps-arm64-7.1.2-${COMMONGAPPSRELEASE}_signed.zip "ftp://${user}:${password}@${host}/arm64/Nougat/BiTGApps-arm64-7.1.2-${COMMONGAPPSRELEASE}_signed.zip"
          $TARGET_API_25 && curl -T out/arm64/BiTGApps-arm64-7.1.1-${COMMONGAPPSRELEASE}_signed.zip "ftp://${user}:${password}@${host}/arm64/Nougat/BiTGApps-arm64-7.1.1-${COMMONGAPPSRELEASE}_signed.zip"
        fi
        if [ -n "$COMMONADDONRELEASE" ]; then
          $TARGET_PLATFOMR_ARM64 && curl -T out/arm64/BiTGApps-addon-arm64-${COMMONADDONRELEASE}_signed.zip "ftp://${user}:${password}@${host}/addon/config/arm64/BiTGApps-addon-arm64-${COMMONADDONRELEASE}_signed.zip"
        fi
      fi
      if [ "$SERVER" == "dh" ]; then
        if [ -n "$COMMONGAPPSRELEASE" ]; then
          $TARGET_API_30 && scp out/arm64/BiTGApps-arm64-11.0.0-${COMMONGAPPSRELEASE}_signed.zip ${user}@${host}:/home/dh_ddbfeb/bitgapps.com/downloads/arm64/R
          $TARGET_API_29 && scp out/arm64/BiTGApps-arm64-10.0.0-${COMMONGAPPSRELEASE}_signed.zip ${user}@${host}:/home/dh_ddbfeb/bitgapps.com/downloads/arm64/Q
          $TARGET_API_28 && scp out/arm64/BiTGApps-arm64-9.0.0-${COMMONGAPPSRELEASE}_signed.zip ${user}@${host}:/home/dh_ddbfeb/bitgapps.com/downloads/arm64/Pie
          $TARGET_API_27 && scp out/arm64/BiTGApps-arm64-8.1.0-${COMMONGAPPSRELEASE}_signed.zip ${user}@${host}:/home/dh_ddbfeb/bitgapps.com/downloads/arm64/Oreo
          $TARGET_API_26 && scp out/arm64/BiTGApps-arm64-8.0.0-${COMMONGAPPSRELEASE}_signed.zip ${user}@${host}:/home/dh_ddbfeb/bitgapps.com/downloads/arm64/Oreo
          $TARGET_API_25 && scp out/arm64/BiTGApps-arm64-7.1.2-${COMMONGAPPSRELEASE}_signed.zip ${user}@${host}:/home/dh_ddbfeb/bitgapps.com/downloads/arm64/Nougat
          $TARGET_API_25 && scp out/arm64/BiTGApps-arm64-7.1.1-${COMMONGAPPSRELEASE}_signed.zip ${user}@${host}:/home/dh_ddbfeb/bitgapps.com/downloads/arm64/Nougat
        fi
        if [ -n "$COMMONADDONRELEASE" ]; then
          $TARGET_PLATFOMR_ARM64 && scp out/arm64/BiTGApps-addon-arm64-${COMMONADDONRELEASE}_signed.zip ${user}@${host}:/home/dh_ddbfeb/bitgapps.com/downloads/addon/config/arm64
        fi
      fi
    fi
    if [ -n "$TESTRELEASE" ]; then
      if [ "$SERVER" == "sf" ]; then
        if [ -n "$COMMONGAPPSRELEASE" ]; then
          $TARGET_API_30 && scp out/arm64/BiTGApps-arm64-11.0.0-${COMMONGAPPSRELEASE}_signed.zip ${user}@frs.sourceforge.net:/home/frs/project/bitgapps/arm64/30
          $TARGET_API_29 && scp out/arm64/BiTGApps-arm64-10.0.0-${COMMONGAPPSRELEASE}_signed.zip ${user}@frs.sourceforge.net:/home/frs/project/bitgapps/arm64/29
          $TARGET_API_28 && scp out/arm64/BiTGApps-arm64-9.0.0-${COMMONGAPPSRELEASE}_signed.zip ${user}@frs.sourceforge.net:/home/frs/project/bitgapps/arm64/28
          $TARGET_API_27 && scp out/arm64/BiTGApps-arm64-8.1.0-${COMMONGAPPSRELEASE}_signed.zip ${user}@frs.sourceforge.net:/home/frs/project/bitgapps/arm64/27
          $TARGET_API_26 && scp out/arm64/BiTGApps-arm64-8.0.0-${COMMONGAPPSRELEASE}_signed.zip ${user}@frs.sourceforge.net:/home/frs/project/bitgapps/arm64/26
          $TARGET_API_25 && scp out/arm64/BiTGApps-arm64-7.1.2-${COMMONGAPPSRELEASE}_signed.zip ${user}@frs.sourceforge.net:/home/frs/project/bitgapps/arm64/25
          $TARGET_API_25 && scp out/arm64/BiTGApps-arm64-7.1.1-${COMMONGAPPSRELEASE}_signed.zip ${user}@frs.sourceforge.net:/home/frs/project/bitgapps/arm64/25
        fi
        if [ -n "$COMMONADDONRELEASE" ]; then
          $TARGET_PLATFOMR_ARM64 && scp out/arm64/BiTGApps-addon-arm64-${COMMONADDONRELEASE}_signed.zip ${user}@frs.sourceforge.net:/home/frs/project/bitgapps/addon/config/arm64
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
          $TARGET_VARIANT_ASSISTANT && curl -T out/common/BiTGApps-addon-assistant-${COMMONADDONRELEASE}_signed.zip "ftp://${user}:${password}@${host}/addon/non-config/BiTGApps-addon-assistant-${COMMONADDONRELEASE}_signed.zip"
          $TARGET_VARIANT_CALCULATOR && curl -T out/common/BiTGApps-addon-calculator-${COMMONADDONRELEASE}_signed.zip "ftp://${user}:${password}@${host}/addon/non-config/BiTGApps-addon-calculator-${COMMONADDONRELEASE}_signed.zip"
          $TARGET_VARIANT_CALENDAR && curl -T out/common/BiTGApps-addon-calendar-${COMMONADDONRELEASE}_signed.zip "ftp://${user}:${password}@${host}/addon/non-config/BiTGApps-addon-calendar-${COMMONADDONRELEASE}_signed.zip"
          $TARGET_VARIANT_CONTACTS && curl -T out/common/BiTGApps-addon-contacts-${COMMONADDONRELEASE}_signed.zip "ftp://${user}:${password}@${host}/addon/non-config/BiTGApps-addon-contacts-${COMMONADDONRELEASE}_signed.zip"
          $TARGET_VARIANT_DESKCLOCK && curl -T out/common/BiTGApps-addon-deskclock-${COMMONADDONRELEASE}_signed.zip "ftp://${user}:${password}@${host}/addon/non-config/BiTGApps-addon-deskclock-${COMMONADDONRELEASE}_signed.zip"
          $TARGET_VARIANT_DIALER && curl -T out/common/BiTGApps-addon-dialer-${COMMONADDONRELEASE}_signed.zip "ftp://${user}:${password}@${host}/addon/non-config/BiTGApps-addon-dialer-${COMMONADDONRELEASE}_signed.zip"
          $TARGET_VARIANT_GBOARD && curl -T out/common/BiTGApps-addon-gboard-${COMMONADDONRELEASE}_signed.zip "ftp://${user}:${password}@${host}/addon/non-config/BiTGApps-addon-gboard-${COMMONADDONRELEASE}_signed.zip"
          $TARGET_VARIANT_MARKUP && curl -T out/common/BiTGApps-addon-markup-${COMMONADDONRELEASE}_signed.zip "ftp://${user}:${password}@${host}/addon/non-config/BiTGApps-addon-markup-${COMMONADDONRELEASE}_signed.zip"
          $TARGET_VARIANT_MESSAGES && curl -T out/common/BiTGApps-addon-messages-${COMMONADDONRELEASE}_signed.zip "ftp://${user}:${password}@${host}/addon/non-config/BiTGApps-addon-messages-${COMMONADDONRELEASE}_signed.zip"
          $TARGET_VARIANT_PHOTOS && curl -T out/common/BiTGApps-addon-photos-${COMMONADDONRELEASE}_signed.zip "ftp://${user}:${password}@${host}/addon/non-config/BiTGApps-addon-photos-${COMMONADDONRELEASE}_signed.zip"
          $TARGET_VARIANT_SOUNDPICKER && curl -T out/common/BiTGApps-addon-soundpicker-${COMMONADDONRELEASE}_signed.zip "ftp://${user}:${password}@${host}/addon/non-config/BiTGApps-addon-soundpicker-${COMMONADDONRELEASE}_signed.zip"
          $TARGET_VARIANT_VANCED && curl -T out/common/BiTGApps-addon-vanced-${COMMONADDONRELEASE}_signed.zip "ftp://${user}:${password}@${host}/addon/non-config/BiTGApps-addon-vanced-${COMMONADDONRELEASE}_signed.zip"
          $TARGET_VARIANT_WELLBEING && curl -T out/common/BiTGApps-addon-wellbeing-${COMMONADDONRELEASE}_signed.zip "ftp://${user}:${password}@${host}/addon/non-config/BiTGApps-addon-wellbeing-${COMMONADDONRELEASE}_signed.zip"
        fi
      fi
      if [ "$SERVER" == "dh" ]; then
        if [ -n "$COMMONADDONRELEASE" ]; then
          $TARGET_VARIANT_ASSISTANT && scp out/common/BiTGApps-addon-assistant-${COMMONADDONRELEASE}_signed.zip ${user}@${host}:/home/dh_ddbfeb/bitgapps.com/downloads/addon/non-config
          $TARGET_VARIANT_CALCULATOR && scp out/common/BiTGApps-addon-calculator-${COMMONADDONRELEASE}_signed.zip ${user}@${host}:/home/dh_ddbfeb/bitgapps.com/downloads/addon/non-config
          $TARGET_VARIANT_CALENDAR && scp out/common/BiTGApps-addon-calendar-${COMMONADDONRELEASE}_signed.zip ${user}@${host}:/home/dh_ddbfeb/bitgapps.com/downloads/addon/non-config
          $TARGET_VARIANT_CONTACTS && scp out/common/BiTGApps-addon-contacts-${COMMONADDONRELEASE}_signed.zip ${user}@${host}:/home/dh_ddbfeb/bitgapps.com/downloads/addon/non-config
          $TARGET_VARIANT_DESKCLOCK && scp out/common/BiTGApps-addon-deskclock-${COMMONADDONRELEASE}_signed.zip ${user}@${host}:/home/dh_ddbfeb/bitgapps.com/downloads/addon/non-config
          $TARGET_VARIANT_DIALER && scp out/common/BiTGApps-addon-dialer-${COMMONADDONRELEASE}_signed.zip ${user}@${host}:/home/dh_ddbfeb/bitgapps.com/downloads/addon/non-config
          $TARGET_VARIANT_GBOARD && scp out/common/BiTGApps-addon-gboard-${COMMONADDONRELEASE}_signed.zip ${user}@${host}:/home/dh_ddbfeb/bitgapps.com/downloads/addon/non-config
          $TARGET_VARIANT_MARKUP && scp out/common/BiTGApps-addon-markup-${COMMONADDONRELEASE}_signed.zip ${user}@${host}:/home/dh_ddbfeb/bitgapps.com/downloads/addon/non-config
          $TARGET_VARIANT_MESSAGES && scp out/common/BiTGApps-addon-messages-${COMMONADDONRELEASE}_signed.zip ${user}@${host}:/home/dh_ddbfeb/bitgapps.com/downloads/addon/non-config
          $TARGET_VARIANT_PHOTOS && scp out/common/BiTGApps-addon-photos-${COMMONADDONRELEASE}_signed.zip ${user}@${host}:/home/dh_ddbfeb/bitgapps.com/downloads/addon/non-config
          $TARGET_VARIANT_SOUNDPICKER && scp out/common/BiTGApps-addon-soundpicker-${COMMONADDONRELEASE}_signed.zip ${user}@${host}:/home/dh_ddbfeb/bitgapps.com/downloads/addon/non-config
          $TARGET_VARIANT_VANCED && scp out/common/BiTGApps-addon-vanced-${COMMONADDONRELEASE}_signed.zip ${user}@${host}:/home/dh_ddbfeb/bitgapps.com/downloads/addon/non-config
          $TARGET_VARIANT_WELLBEING && scp out/common/BiTGApps-addon-wellbeing-${COMMONADDONRELEASE}_signed.zip ${user}@${host}:/home/dh_ddbfeb/bitgapps.com/downloads/addon/non-config
        fi
      fi
    fi
    if [ -n "$TESTRELEASE" ]; then
      if [ "$SERVER" == "sf" ]; then
        if [ -n "$COMMONADDONRELEASE" ]; then
          $TARGET_PLATFORM_ARM && scp out/arm/BiTGApps-addon-arm-${COMMONADDONRELEASE}_signed.zip ${user}@frs.sourceforge.net:/home/frs/project/bitgapps/addon/config/arm
          $TARGET_PLATFORM_ARM64 && scp out/arm64/BiTGApps-addon-arm64-${COMMONADDONRELEASE}_signed.zip ${user}@frs.sourceforge.net:/home/frs/project/bitgapps/addon/config/arm64
          $TARGET_VARIANT_ASSISTANT && scp out/common/BiTGApps-addon-assistant-${COMMONADDONRELEASE}_signed.zip ${user}@frs.sourceforge.net:/home/frs/project/bitgapps/addon/non-config
          $TARGET_VARIANT_CALCULATOR && scp out/common/BiTGApps-addon-calculator-${COMMONADDONRELEASE}_signed.zip ${user}@frs.sourceforge.net:/home/frs/project/bitgapps/addon/non-config
          $TARGET_VARIANT_CALENDAR && scp out/common/BiTGApps-addon-calendar-${COMMONADDONRELEASE}_signed.zip ${user}@frs.sourceforge.net:/home/frs/project/bitgapps/addon/non-config
          $TARGET_VARIANT_CONTACTS && scp out/common/BiTGApps-addon-contacts-${COMMONADDONRELEASE}_signed.zip ${user}@frs.sourceforge.net:/home/frs/project/bitgapps/addon/non-config
          $TARGET_VARIANT_DESKCLOCK && scp out/common/BiTGApps-addon-deskclock-${COMMONADDONRELEASE}_signed.zip ${user}@frs.sourceforge.net:/home/frs/project/bitgapps/addon/non-config
          $TARGET_VARIANT_DIALER && scp out/common/BiTGApps-addon-dialer-${COMMONADDONRELEASE}_signed.zip ${user}@frs.sourceforge.net:/home/frs/project/bitgapps/addon/non-config
          $TARGET_VARIANT_GBOARD && scp out/common/BiTGApps-addon-gboard-${COMMONADDONRELEASE}_signed.zip ${user}@frs.sourceforge.net:/home/frs/project/bitgapps/addon/non-config
          $TARGET_VARIANT_MARKUP && scp out/common/BiTGApps-addon-markup-${COMMONADDONRELEASE}_signed.zip ${user}@frs.sourceforge.net:/home/frs/project/bitgapps/addon/non-config
          $TARGET_VARIANT_MESSAGES && scp out/common/BiTGApps-addon-messages-${COMMONADDONRELEASE}_signed.zip ${user}@frs.sourceforge.net:/home/frs/project/bitgapps/addon/non-config
          $TARGET_VARIANT_PHOTOS && scp out/common/BiTGApps-addon-photos-${COMMONADDONRELEASE}_signed.zip ${user}@frs.sourceforge.net:/home/frs/project/bitgapps/addon/non-config
          $TARGET_VARIANT_SOUNDPICKER && scp out/common/BiTGApps-addon-soundpicker-${COMMONADDONRELEASE}_signed.zip ${user}@frs.sourceforge.net:/home/frs/project/bitgapps/addon/non-config
          $TARGET_VARIANT_VANCED && scp out/common/BiTGApps-addon-vanced-${COMMONADDONRELEASE}_signed.zip ${user}@frs.sourceforge.net:/home/frs/project/bitgapps/addon/non-config
          $TARGET_VARIANT_WELLBEING && scp out/common/BiTGApps-addon-wellbeing-${COMMONADDONRELEASE}_signed.zip ${user}@frs.sourceforge.net:/home/frs/project/bitgapps/addon/non-config
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
        $TARGET_CONFIG_ADDON && curl -T BiTGApps/configs/addon-config.prop "ftp://${user}:${password}@${host}/config/Addon/addon-config.prop"
        $TARGET_CONFIG_BOOT && curl -T BiTGApps/configs/boot-config.prop "ftp://${user}:${password}@${host}/config/Bootlog/boot-config.prop"
        $TARGET_CONFIG_CTS && curl -T BiTGApps/configs/cts-config.prop "ftp://${user}:${password}@${host}/config/Safetynet/cts-config.prop"
        $TARGET_CONFIG_SETUP && curl -T BiTGApps/configs/setup-config.prop "ftp://${user}:${password}@${host}/config/SetupWizard/setup-config.prop"
      fi
      if [ "$SERVER" == "dh" ]; then
        $TARGET_CONFIG_ADDON && scp BiTGApps/configs/addon-config.prop ${user}@${host}:/home/dh_ddbfeb/bitgapps.com/downloads/config/Addon
        $TARGET_CONFIG_BOOT && scp BiTGApps/configs/boot-config.prop ${user}@${host}:/home/dh_ddbfeb/bitgapps.com/downloads/config/Bootlog
        $TARGET_CONFIG_CTS && scp BiTGApps/configs/cts-config.prop ${user}@${host}:/home/dh_ddbfeb/bitgapps.com/downloads/config/Safetynet
        $TARGET_CONFIG_SETUP && scp BiTGApps/configs/setup-config.prop ${user}@${host}:/home/dh_ddbfeb/bitgapps.com/downloads/config/SetupWizard
      fi
    fi
    if [ -n "$TESTRELEASE" ]; then
      if [ "$SERVER" == "sf" ]; then
        $TARGET_CONFIG_ADDON && scp BiTGApps/configs/addon-config.prop ${user}@frs.sourceforge.net:/home/frs/project/bitgapps/config/Addon
        $TARGET_CONFIG_BOOT && scp BiTGApps/configs/boot-config.prop ${user}@frs.sourceforge.net:/home/frs/project/bitgapps/config/Bootlog
        $TARGET_CONFIG_CTS && scp BiTGApps/configs/cts-config.prop ${user}@frs.sourceforge.net:/home/frs/project/bitgapps/config/Safetynet
        $TARGET_CONFIG_SETUP && scp BiTGApps/configs/setup-config.prop ${user}@frs.sourceforge.net:/home/frs/project/bitgapps/config/SetupWizard
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
          curl -T BiTGApps-v${APKRELEASE}.apk "ftp://${user}:${password}@${host}/APK/BiTGApps-v${APKRELEASE}.apk"
        else
          echo "! APKRELEASE environmental variable not set. Aborting..."
        fi
      fi
      if [ "$SERVER" == "dh" ]; then
        if [ -n "$APKRELEASE" ]; then
          scp BiTGApps-v${APKRELEASE}.apk ${user}@${host}:/home/dh_ddbfeb/bitgapps.com/downloads/APK
        else
          echo "! APKRELEASE environmental variable not set. Aborting..."
        fi
      fi
    fi
    if [ -n "$TESTRELEASE" ]; then
      if [ "$SERVER" == "sf" ]; then
        if [ -n "$APKRELEASE" ]; then
          scp BiTGApps-v${APKRELEASE}.apk ${user}@frs.sourceforge.net:/home/frs/project/bitgapps/apk
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
