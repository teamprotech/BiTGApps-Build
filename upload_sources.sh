#!/bin/bash
#
##############################################################
# File name       : upload_sources.sh
#
# Description     : Upload pre-built packages
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

# Set environmental variables (Auto-generated)
. ENV/api.sh      # For GApps release
. ENV/microg.sh   # For MicroG release
. ENV/platform.sh # For Platform based Addon release
. ENV/variant.sh  # For Variant based Addon release

# Check availability of environmental variable
if [ ! -n "$SERVER" ]; then
  echo "! Environmental variable not set. Aborting..."
  exit 1
fi

# Set defaults
export CREDENTIALS="$1"
export ARMEABI="$1"
export AARCH64="$1"
export COMMON="$1"

# Server credentials
set_credentials() {
  if [ "$CREDENTIALS" == "creds" ]; then
    if [ "$SERVER" == "ga" ]; then
      read -p "Enter user: " user
      read -p "Enter pass: " pass
      read -p "Enter host: " host
    fi
    if [ "$SERVER" == "dh" ] || [ "$SERVER" == "sps" ] || [ "$SERVER" == "alpha" ] || [ "$SERVER" == "backup" ]; then
      read -p "Enter user: " user
      read -p "Enter host: " host
    fi
  fi
  # Export credentials in the global environment
  if [ "$SERVER" == "ga" ]; then export user="$user"; export pass="$pass"; export host="$host"; fi
  if [ "$SERVER" == "dh" ] || [ "$SERVER" == "sps" ] || [ "$SERVER" == "alpha" ] || [ "$SERVER" == "backup" ]; then export user="$user"; export host="$host"; fi
}

check_credentials() {
  if [ "$SERVER" == "ga" ]; then
    if { [ ! -n "$user" ] &&
         [ ! -n "$pass" ] &&
         [ ! -n "$host" ]; }; then
      echo "! No credentials found. Aborting..."
      exit 1
    fi
  fi
  if [ "$SERVER" == "dh" ] || [ "$SERVER" == "sps" ] || [ "$SERVER" == "alpha" ] || [ "$SERVER" == "backup" ]; then
    if { [ ! -n "$user" ] &&
         [ ! -n "$host" ]; }; then
      echo "! No credentials found. Aborting..."
      exit 1
    fi
  fi
}

# Set alpha/backup revision
set_revision() { if [ "$SERVER" == "alpha" ] || [ "$SERVER" == "backup" ]; then read -p "Enter revision: " REVISION; export REVISION="$REVISION"; fi; }

# ARMEABI Sources
arm_sources() {
  if [ "$ARMEABI" == "arm" ]; then
    if [ "$SERVER" == "ga" ]; then
      if [ -n "$COMMONGAPPSRELEASE" ]; then
        $TARGET_API_31 && curl -T out/arm/BiTGApps-arm-12.0.0-${COMMONGAPPSRELEASE}_signed.zip "ftp://${user}:${pass}@${host}/GApps/arm/S/BiTGApps-arm-12.0.0-${COMMONGAPPSRELEASE}_signed.zip"
        $TARGET_API_30 && curl -T out/arm/BiTGApps-arm-11.0.0-${COMMONGAPPSRELEASE}_signed.zip "ftp://${user}:${pass}@${host}/GApps/arm/R/BiTGApps-arm-11.0.0-${COMMONGAPPSRELEASE}_signed.zip"
        $TARGET_API_29 && curl -T out/arm/BiTGApps-arm-10.0.0-${COMMONGAPPSRELEASE}_signed.zip "ftp://${user}:${pass}@${host}/GApps/arm/Q/BiTGApps-arm-10.0.0-${COMMONGAPPSRELEASE}_signed.zip"
        $TARGET_API_28 && curl -T out/arm/BiTGApps-arm-9.0.0-${COMMONGAPPSRELEASE}_signed.zip "ftp://${user}:${pass}@${host}/GApps/arm/Pie/BiTGApps-arm-9.0.0-${COMMONGAPPSRELEASE}_signed.zip"
        $TARGET_API_27 && curl -T out/arm/BiTGApps-arm-8.1.0-${COMMONGAPPSRELEASE}_signed.zip "ftp://${user}:${pass}@${host}/GApps/arm/Oreo/BiTGApps-arm-8.1.0-${COMMONGAPPSRELEASE}_signed.zip"
        $TARGET_API_26 && curl -T out/arm/BiTGApps-arm-8.0.0-${COMMONGAPPSRELEASE}_signed.zip "ftp://${user}:${pass}@${host}/GApps/arm/Oreo/BiTGApps-arm-8.0.0-${COMMONGAPPSRELEASE}_signed.zip"
        $TARGET_API_25 && curl -T out/arm/BiTGApps-arm-7.1.2-${COMMONGAPPSRELEASE}_signed.zip "ftp://${user}:${pass}@${host}/GApps/arm/Nougat/BiTGApps-arm-7.1.2-${COMMONGAPPSRELEASE}_signed.zip"
        $TARGET_API_25 && curl -T out/arm/BiTGApps-arm-7.1.1-${COMMONGAPPSRELEASE}_signed.zip "ftp://${user}:${pass}@${host}/GApps/arm/Nougat/BiTGApps-arm-7.1.1-${COMMONGAPPSRELEASE}_signed.zip"
      fi
      if [ -n "$COMMONGAPPSRELEASE" ]; then
        $MICROG_API_31 && curl -T out/arm/MicroG-arm-12.0.0-${COMMONGAPPSRELEASE}_signed.zip "ftp://${user}:${pass}@${host}/MicroG/arm/S/MicroG-arm-12.0.0-${COMMONGAPPSRELEASE}_signed.zip"
        $MICROG_API_30 && curl -T out/arm/MicroG-arm-11.0.0-${COMMONGAPPSRELEASE}_signed.zip "ftp://${user}:${pass}@${host}/MicroG/arm/R/MicroG-arm-11.0.0-${COMMONGAPPSRELEASE}_signed.zip"
        $MICROG_API_29 && curl -T out/arm/MicroG-arm-10.0.0-${COMMONGAPPSRELEASE}_signed.zip "ftp://${user}:${pass}@${host}/MicroG/arm/Q/MicroG-arm-10.0.0-${COMMONGAPPSRELEASE}_signed.zip"
        $MICROG_API_28 && curl -T out/arm/MicroG-arm-9.0.0-${COMMONGAPPSRELEASE}_signed.zip "ftp://${user}:${pass}@${host}/MicroG/arm/Pie/MicroG-arm-9.0.0-${COMMONGAPPSRELEASE}_signed.zip"
        $MICROG_API_27 && curl -T out/arm/MicroG-arm-8.1.0-${COMMONGAPPSRELEASE}_signed.zip "ftp://${user}:${pass}@${host}/MicroG/arm/Oreo/MicroG-arm-8.1.0-${COMMONGAPPSRELEASE}_signed.zip"
        $MICROG_API_26 && curl -T out/arm/MicroG-arm-8.0.0-${COMMONGAPPSRELEASE}_signed.zip "ftp://${user}:${pass}@${host}/MicroG/arm/Oreo/MicroG-arm-8.0.0-${COMMONGAPPSRELEASE}_signed.zip"
        $MICROG_API_25 && curl -T out/arm/MicroG-arm-7.1.2-${COMMONGAPPSRELEASE}_signed.zip "ftp://${user}:${pass}@${host}/MicroG/arm/Nougat/MicroG-arm-7.1.2-${COMMONGAPPSRELEASE}_signed.zip"
        $MICROG_API_25 && curl -T out/arm/MicroG-arm-7.1.1-${COMMONGAPPSRELEASE}_signed.zip "ftp://${user}:${pass}@${host}/MicroG/arm/Nougat/MicroG-arm-7.1.1-${COMMONGAPPSRELEASE}_signed.zip"
      fi
      if [ -n "$COMMONADDONRELEASE" ]; then
        $TARGET_PLATFORM_ARM && curl -T out/arm/BiTGApps-addon-arm-${COMMONADDONRELEASE}_signed.zip "ftp://${user}:${pass}@${host}/Addon/config/arm/BiTGApps-addon-arm-${COMMONADDONRELEASE}_signed.zip"
      fi
    fi
    if [ "$SERVER" == "dh" ]; then
      if [ -n "$COMMONGAPPSRELEASE" ]; then
        $TARGET_API_31 && rsync -a -v out/arm/BiTGApps-arm-12.0.0-${COMMONGAPPSRELEASE}_signed.zip "${user}@${host}:/home/bitgapps/bitgapps.com/downloads/GApps/arm/S/BiTGApps-arm-12.0.0-${COMMONGAPPSRELEASE}_signed.zip"
        $TARGET_API_30 && rsync -a -v out/arm/BiTGApps-arm-11.0.0-${COMMONGAPPSRELEASE}_signed.zip "${user}@${host}:/home/bitgapps/bitgapps.com/downloads/GApps/arm/R/BiTGApps-arm-11.0.0-${COMMONGAPPSRELEASE}_signed.zip"
        $TARGET_API_29 && rsync -a -v out/arm/BiTGApps-arm-10.0.0-${COMMONGAPPSRELEASE}_signed.zip "${user}@${host}:/home/bitgapps/bitgapps.com/downloads/GApps/arm/Q/BiTGApps-arm-10.0.0-${COMMONGAPPSRELEASE}_signed.zip"
        $TARGET_API_28 && rsync -a -v out/arm/BiTGApps-arm-9.0.0-${COMMONGAPPSRELEASE}_signed.zip "${user}@${host}:/home/bitgapps/bitgapps.com/downloads/GApps/arm/Pie/BiTGApps-arm-9.0.0-${COMMONGAPPSRELEASE}_signed.zip"
        $TARGET_API_27 && rsync -a -v out/arm/BiTGApps-arm-8.1.0-${COMMONGAPPSRELEASE}_signed.zip "${user}@${host}:/home/bitgapps/bitgapps.com/downloads/GApps/arm/Oreo/BiTGApps-arm-8.1.0-${COMMONGAPPSRELEASE}_signed.zip"
        $TARGET_API_26 && rsync -a -v out/arm/BiTGApps-arm-8.0.0-${COMMONGAPPSRELEASE}_signed.zip "${user}@${host}:/home/bitgapps/bitgapps.com/downloads/GApps/arm/Oreo/BiTGApps-arm-8.0.0-${COMMONGAPPSRELEASE}_signed.zip"
        $TARGET_API_25 && rsync -a -v out/arm/BiTGApps-arm-7.1.2-${COMMONGAPPSRELEASE}_signed.zip "${user}@${host}:/home/bitgapps/bitgapps.com/downloads/GApps/arm/Nougat/BiTGApps-arm-7.1.2-${COMMONGAPPSRELEASE}_signed.zip"
        $TARGET_API_25 && rsync -a -v out/arm/BiTGApps-arm-7.1.1-${COMMONGAPPSRELEASE}_signed.zip "${user}@${host}:/home/bitgapps/bitgapps.com/downloads/GApps/arm/Nougat/BiTGApps-arm-7.1.1-${COMMONGAPPSRELEASE}_signed.zip"
      fi
      if [ -n "$COMMONGAPPSRELEASE" ]; then
        $MICROG_API_31 && rsync -a -v out/arm/MicroG-arm-12.0.0-${COMMONGAPPSRELEASE}_signed.zip "${user}@${host}:/home/bitgapps/bitgapps.com/downloads/MicroG/arm/S/MicroG-arm-12.0.0-${COMMONGAPPSRELEASE}_signed.zip"
        $MICROG_API_30 && rsync -a -v out/arm/MicroG-arm-11.0.0-${COMMONGAPPSRELEASE}_signed.zip "${user}@${host}:/home/bitgapps/bitgapps.com/downloads/MicroG/arm/R/MicroG-arm-11.0.0-${COMMONGAPPSRELEASE}_signed.zip"
        $MICROG_API_29 && rsync -a -v out/arm/MicroG-arm-10.0.0-${COMMONGAPPSRELEASE}_signed.zip "${user}@${host}:/home/bitgapps/bitgapps.com/downloads/MicroG/arm/Q/MicroG-arm-10.0.0-${COMMONGAPPSRELEASE}_signed.zip"
        $MICROG_API_28 && rsync -a -v out/arm/MicroG-arm-9.0.0-${COMMONGAPPSRELEASE}_signed.zip "${user}@${host}:/home/bitgapps/bitgapps.com/downloads/MicroG/arm/Pie/MicroG-arm-9.0.0-${COMMONGAPPSRELEASE}_signed.zip"
        $MICROG_API_27 && rsync -a -v out/arm/MicroG-arm-8.1.0-${COMMONGAPPSRELEASE}_signed.zip "${user}@${host}:/home/bitgapps/bitgapps.com/downloads/MicroG/arm/Oreo/MicroG-arm-8.1.0-${COMMONGAPPSRELEASE}_signed.zip"
        $MICROG_API_26 && rsync -a -v out/arm/MicroG-arm-8.0.0-${COMMONGAPPSRELEASE}_signed.zip "${user}@${host}:/home/bitgapps/bitgapps.com/downloads/MicroG/arm/Oreo/MicroG-arm-8.0.0-${COMMONGAPPSRELEASE}_signed.zip"
        $MICROG_API_25 && rsync -a -v out/arm/MicroG-arm-7.1.2-${COMMONGAPPSRELEASE}_signed.zip "${user}@${host}:/home/bitgapps/bitgapps.com/downloads/MicroG/arm/Nougat/MicroG-arm-7.1.2-${COMMONGAPPSRELEASE}_signed.zip"
        $MICROG_API_25 && rsync -a -v out/arm/MicroG-arm-7.1.1-${COMMONGAPPSRELEASE}_signed.zip "${user}@${host}:/home/bitgapps/bitgapps.com/downloads/MicroG/arm/Nougat/MicroG-arm-7.1.1-${COMMONGAPPSRELEASE}_signed.zip"
      fi
      if [ -n "$COMMONADDONRELEASE" ]; then
        $TARGET_PLATFORM_ARM && rsync -a -v out/arm/BiTGApps-addon-arm-${COMMONADDONRELEASE}_signed.zip "${user}@${host}:/home/bitgapps/bitgapps.com/downloads/Addon/config/arm/BiTGApps-addon-arm-${COMMONADDONRELEASE}_signed.zip"
      fi
    fi
    if [ "$SERVER" == "sps" ]; then
      if [ -n "$COMMONGAPPSRELEASE" ]; then
        $TARGET_API_31 && rsync -a -v out/arm/BiTGApps-arm-12.0.0-${COMMONGAPPSRELEASE}_signed.zip "${user}@${host}:/home/hitman/sites/downloads/GApps/arm/S/BiTGApps-arm-12.0.0-${COMMONGAPPSRELEASE}_signed.zip"
        $TARGET_API_30 && rsync -a -v out/arm/BiTGApps-arm-11.0.0-${COMMONGAPPSRELEASE}_signed.zip "${user}@${host}:/home/hitman/sites/downloads/GApps/arm/R/BiTGApps-arm-11.0.0-${COMMONGAPPSRELEASE}_signed.zip"
        $TARGET_API_29 && rsync -a -v out/arm/BiTGApps-arm-10.0.0-${COMMONGAPPSRELEASE}_signed.zip "${user}@${host}:/home/hitman/sites/downloads/GApps/arm/Q/BiTGApps-arm-10.0.0-${COMMONGAPPSRELEASE}_signed.zip"
        $TARGET_API_28 && rsync -a -v out/arm/BiTGApps-arm-9.0.0-${COMMONGAPPSRELEASE}_signed.zip "${user}@${host}:/home/hitman/sites/downloads/GApps/arm/Pie/BiTGApps-arm-9.0.0-${COMMONGAPPSRELEASE}_signed.zip"
        $TARGET_API_27 && rsync -a -v out/arm/BiTGApps-arm-8.1.0-${COMMONGAPPSRELEASE}_signed.zip "${user}@${host}:/home/hitman/sites/downloads/GApps/arm/Oreo/BiTGApps-arm-8.1.0-${COMMONGAPPSRELEASE}_signed.zip"
        $TARGET_API_26 && rsync -a -v out/arm/BiTGApps-arm-8.0.0-${COMMONGAPPSRELEASE}_signed.zip "${user}@${host}:/home/hitman/sites/downloads/GApps/arm/Oreo/BiTGApps-arm-8.0.0-${COMMONGAPPSRELEASE}_signed.zip"
        $TARGET_API_25 && rsync -a -v out/arm/BiTGApps-arm-7.1.2-${COMMONGAPPSRELEASE}_signed.zip "${user}@${host}:/home/hitman/sites/downloads/GApps/arm/Nougat/BiTGApps-arm-7.1.2-${COMMONGAPPSRELEASE}_signed.zip"
        $TARGET_API_25 && rsync -a -v out/arm/BiTGApps-arm-7.1.1-${COMMONGAPPSRELEASE}_signed.zip "${user}@${host}:/home/hitman/sites/downloads/GApps/arm/Nougat/BiTGApps-arm-7.1.1-${COMMONGAPPSRELEASE}_signed.zip"
      fi
      if [ -n "$COMMONGAPPSRELEASE" ]; then
        $MICROG_API_31 && rsync -a -v out/arm/MicroG-arm-12.0.0-${COMMONGAPPSRELEASE}_signed.zip "${user}@${host}:/home/hitman/sites/downloads/MicroG/arm/S/MicroG-arm-12.0.0-${COMMONGAPPSRELEASE}_signed.zip"
        $MICROG_API_30 && rsync -a -v out/arm/MicroG-arm-11.0.0-${COMMONGAPPSRELEASE}_signed.zip "${user}@${host}:/home/hitman/sites/downloads/MicroG/arm/R/MicroG-arm-11.0.0-${COMMONGAPPSRELEASE}_signed.zip"
        $MICROG_API_29 && rsync -a -v out/arm/MicroG-arm-10.0.0-${COMMONGAPPSRELEASE}_signed.zip "${user}@${host}:/home/hitman/sites/downloads/MicroG/arm/Q/MicroG-arm-10.0.0-${COMMONGAPPSRELEASE}_signed.zip"
        $MICROG_API_28 && rsync -a -v out/arm/MicroG-arm-9.0.0-${COMMONGAPPSRELEASE}_signed.zip "${user}@${host}:/home/hitman/sites/downloads/MicroG/arm/Pie/MicroG-arm-9.0.0-${COMMONGAPPSRELEASE}_signed.zip"
        $MICROG_API_27 && rsync -a -v out/arm/MicroG-arm-8.1.0-${COMMONGAPPSRELEASE}_signed.zip "${user}@${host}:/home/hitman/sites/downloads/MicroG/arm/Oreo/MicroG-arm-8.1.0-${COMMONGAPPSRELEASE}_signed.zip"
        $MICROG_API_26 && rsync -a -v out/arm/MicroG-arm-8.0.0-${COMMONGAPPSRELEASE}_signed.zip "${user}@${host}:/home/hitman/sites/downloads/MicroG/arm/Oreo/MicroG-arm-8.0.0-${COMMONGAPPSRELEASE}_signed.zip"
        $MICROG_API_25 && rsync -a -v out/arm/MicroG-arm-7.1.2-${COMMONGAPPSRELEASE}_signed.zip "${user}@${host}:/home/hitman/sites/downloads/MicroG/arm/Nougat/MicroG-arm-7.1.2-${COMMONGAPPSRELEASE}_signed.zip"
        $MICROG_API_25 && rsync -a -v out/arm/MicroG-arm-7.1.1-${COMMONGAPPSRELEASE}_signed.zip "${user}@${host}:/home/hitman/sites/downloads/MicroG/arm/Nougat/MicroG-arm-7.1.1-${COMMONGAPPSRELEASE}_signed.zip"
      fi
      if [ -n "$COMMONADDONRELEASE" ]; then
        $TARGET_PLATFORM_ARM && rsync -a -v out/arm/BiTGApps-addon-arm-${COMMONADDONRELEASE}_signed.zip "${user}@${host}:/home/hitman/sites/downloads/Addon/config/arm/BiTGApps-addon-arm-${COMMONADDONRELEASE}_signed.zip"
      fi
    fi
    if [ "$SERVER" == "alpha" ]; then
      if [ -n "$COMMONGAPPSRELEASE" ]; then
        $TARGET_API_31 && rsync -a -v out/arm/BiTGApps-arm-12.0.0-${COMMONGAPPSRELEASE}_signed.zip "${user}@${host}:/home/hitman/sites/alpha/${REVISION}/GApps/arm/S/BiTGApps-arm-12.0.0-${COMMONGAPPSRELEASE}_signed.zip"
        $TARGET_API_30 && rsync -a -v out/arm/BiTGApps-arm-11.0.0-${COMMONGAPPSRELEASE}_signed.zip "${user}@${host}:/home/hitman/sites/alpha/${REVISION}/GApps/arm/R/BiTGApps-arm-11.0.0-${COMMONGAPPSRELEASE}_signed.zip"
        $TARGET_API_29 && rsync -a -v out/arm/BiTGApps-arm-10.0.0-${COMMONGAPPSRELEASE}_signed.zip "${user}@${host}:/home/hitman/sites/alpha/${REVISION}/GApps/arm/Q/BiTGApps-arm-10.0.0-${COMMONGAPPSRELEASE}_signed.zip"
        $TARGET_API_28 && rsync -a -v out/arm/BiTGApps-arm-9.0.0-${COMMONGAPPSRELEASE}_signed.zip "${user}@${host}:/home/hitman/sites/alpha/${REVISION}/GApps/arm/Pie/BiTGApps-arm-9.0.0-${COMMONGAPPSRELEASE}_signed.zip"
        $TARGET_API_27 && rsync -a -v out/arm/BiTGApps-arm-8.1.0-${COMMONGAPPSRELEASE}_signed.zip "${user}@${host}:/home/hitman/sites/alpha/${REVISION}/GApps/arm/Oreo/BiTGApps-arm-8.1.0-${COMMONGAPPSRELEASE}_signed.zip"
        $TARGET_API_26 && rsync -a -v out/arm/BiTGApps-arm-8.0.0-${COMMONGAPPSRELEASE}_signed.zip "${user}@${host}:/home/hitman/sites/alpha/${REVISION}/GApps/arm/Oreo/BiTGApps-arm-8.0.0-${COMMONGAPPSRELEASE}_signed.zip"
        $TARGET_API_25 && rsync -a -v out/arm/BiTGApps-arm-7.1.2-${COMMONGAPPSRELEASE}_signed.zip "${user}@${host}:/home/hitman/sites/alpha/${REVISION}/GApps/arm/Nougat/BiTGApps-arm-7.1.2-${COMMONGAPPSRELEASE}_signed.zip"
        $TARGET_API_25 && rsync -a -v out/arm/BiTGApps-arm-7.1.1-${COMMONGAPPSRELEASE}_signed.zip "${user}@${host}:/home/hitman/sites/alpha/${REVISION}/GApps/arm/Nougat/BiTGApps-arm-7.1.1-${COMMONGAPPSRELEASE}_signed.zip"
      fi
      if [ -n "$COMMONGAPPSRELEASE" ]; then
        $MICROG_API_31 && rsync -a -v out/arm/MicroG-arm-12.0.0-${COMMONGAPPSRELEASE}_signed.zip "${user}@${host}:/home/hitman/sites/alpha/${REVISION}/MicroG/arm/S/MicroG-arm-12.0.0-${COMMONGAPPSRELEASE}_signed.zip"
        $MICROG_API_30 && rsync -a -v out/arm/MicroG-arm-11.0.0-${COMMONGAPPSRELEASE}_signed.zip "${user}@${host}:/home/hitman/sites/alpha/${REVISION}/MicroG/arm/R/MicroG-arm-11.0.0-${COMMONGAPPSRELEASE}_signed.zip"
        $MICROG_API_29 && rsync -a -v out/arm/MicroG-arm-10.0.0-${COMMONGAPPSRELEASE}_signed.zip "${user}@${host}:/home/hitman/sites/alpha/${REVISION}/MicroG/arm/Q/MicroG-arm-10.0.0-${COMMONGAPPSRELEASE}_signed.zip"
        $MICROG_API_28 && rsync -a -v out/arm/MicroG-arm-9.0.0-${COMMONGAPPSRELEASE}_signed.zip "${user}@${host}:/home/hitman/sites/alpha/${REVISION}/MicroG/arm/Pie/MicroG-arm-9.0.0-${COMMONGAPPSRELEASE}_signed.zip"
        $MICROG_API_27 && rsync -a -v out/arm/MicroG-arm-8.1.0-${COMMONGAPPSRELEASE}_signed.zip "${user}@${host}:/home/hitman/sites/alpha/${REVISION}/MicroG/arm/Oreo/MicroG-arm-8.1.0-${COMMONGAPPSRELEASE}_signed.zip"
        $MICROG_API_26 && rsync -a -v out/arm/MicroG-arm-8.0.0-${COMMONGAPPSRELEASE}_signed.zip "${user}@${host}:/home/hitman/sites/alpha/${REVISION}/MicroG/arm/Oreo/MicroG-arm-8.0.0-${COMMONGAPPSRELEASE}_signed.zip"
        $MICROG_API_25 && rsync -a -v out/arm/MicroG-arm-7.1.2-${COMMONGAPPSRELEASE}_signed.zip "${user}@${host}:/home/hitman/sites/alpha/${REVISION}/MicroG/arm/Nougat/MicroG-arm-7.1.2-${COMMONGAPPSRELEASE}_signed.zip"
        $MICROG_API_25 && rsync -a -v out/arm/MicroG-arm-7.1.1-${COMMONGAPPSRELEASE}_signed.zip "${user}@${host}:/home/hitman/sites/alpha/${REVISION}/MicroG/arm/Nougat/MicroG-arm-7.1.1-${COMMONGAPPSRELEASE}_signed.zip"
      fi
      if [ -n "$COMMONADDONRELEASE" ]; then
        $TARGET_PLATFORM_ARM && rsync -a -v out/arm/BiTGApps-addon-arm-${COMMONADDONRELEASE}_signed.zip "${user}@${host}:/home/hitman/sites/alpha/${REVISION}/Addon/config/arm/BiTGApps-addon-arm-${COMMONADDONRELEASE}_signed.zip"
      fi
    fi
    if [ "$SERVER" == "backup" ]; then
      if [ -n "$COMMONGAPPSRELEASE" ]; then
        $TARGET_API_31 && rsync -a -v out/arm/BiTGApps-arm-12.0.0-${COMMONGAPPSRELEASE}_signed.zip "${user}@${host}:/home/hitman/sites/backup/${REVISION}/GApps/arm/S/BiTGApps-arm-12.0.0-${COMMONGAPPSRELEASE}_signed.zip"
        $TARGET_API_30 && rsync -a -v out/arm/BiTGApps-arm-11.0.0-${COMMONGAPPSRELEASE}_signed.zip "${user}@${host}:/home/hitman/sites/backup/${REVISION}/GApps/arm/R/BiTGApps-arm-11.0.0-${COMMONGAPPSRELEASE}_signed.zip"
        $TARGET_API_29 && rsync -a -v out/arm/BiTGApps-arm-10.0.0-${COMMONGAPPSRELEASE}_signed.zip "${user}@${host}:/home/hitman/sites/backup/${REVISION}/GApps/arm/Q/BiTGApps-arm-10.0.0-${COMMONGAPPSRELEASE}_signed.zip"
        $TARGET_API_28 && rsync -a -v out/arm/BiTGApps-arm-9.0.0-${COMMONGAPPSRELEASE}_signed.zip "${user}@${host}:/home/hitman/sites/backup/${REVISION}/GApps/arm/Pie/BiTGApps-arm-9.0.0-${COMMONGAPPSRELEASE}_signed.zip"
        $TARGET_API_27 && rsync -a -v out/arm/BiTGApps-arm-8.1.0-${COMMONGAPPSRELEASE}_signed.zip "${user}@${host}:/home/hitman/sites/backup/${REVISION}/GApps/arm/Oreo/BiTGApps-arm-8.1.0-${COMMONGAPPSRELEASE}_signed.zip"
        $TARGET_API_26 && rsync -a -v out/arm/BiTGApps-arm-8.0.0-${COMMONGAPPSRELEASE}_signed.zip "${user}@${host}:/home/hitman/sites/backup/${REVISION}/GApps/arm/Oreo/BiTGApps-arm-8.0.0-${COMMONGAPPSRELEASE}_signed.zip"
        $TARGET_API_25 && rsync -a -v out/arm/BiTGApps-arm-7.1.2-${COMMONGAPPSRELEASE}_signed.zip "${user}@${host}:/home/hitman/sites/backup/${REVISION}/GApps/arm/Nougat/BiTGApps-arm-7.1.2-${COMMONGAPPSRELEASE}_signed.zip"
        $TARGET_API_25 && rsync -a -v out/arm/BiTGApps-arm-7.1.1-${COMMONGAPPSRELEASE}_signed.zip "${user}@${host}:/home/hitman/sites/backup/${REVISION}/GApps/arm/Nougat/BiTGApps-arm-7.1.1-${COMMONGAPPSRELEASE}_signed.zip"
      fi
      if [ -n "$COMMONGAPPSRELEASE" ]; then
        $MICROG_API_31 && rsync -a -v out/arm/MicroG-arm-12.0.0-${COMMONGAPPSRELEASE}_signed.zip "${user}@${host}:/home/hitman/sites/backup/${REVISION}/MicroG/arm/S/MicroG-arm-12.0.0-${COMMONGAPPSRELEASE}_signed.zip"
        $MICROG_API_30 && rsync -a -v out/arm/MicroG-arm-11.0.0-${COMMONGAPPSRELEASE}_signed.zip "${user}@${host}:/home/hitman/sites/backup/${REVISION}/MicroG/arm/R/MicroG-arm-11.0.0-${COMMONGAPPSRELEASE}_signed.zip"
        $MICROG_API_29 && rsync -a -v out/arm/MicroG-arm-10.0.0-${COMMONGAPPSRELEASE}_signed.zip "${user}@${host}:/home/hitman/sites/backup/${REVISION}/MicroG/arm/Q/MicroG-arm-10.0.0-${COMMONGAPPSRELEASE}_signed.zip"
        $MICROG_API_28 && rsync -a -v out/arm/MicroG-arm-9.0.0-${COMMONGAPPSRELEASE}_signed.zip "${user}@${host}:/home/hitman/sites/backup/${REVISION}/MicroG/arm/Pie/MicroG-arm-9.0.0-${COMMONGAPPSRELEASE}_signed.zip"
        $MICROG_API_27 && rsync -a -v out/arm/MicroG-arm-8.1.0-${COMMONGAPPSRELEASE}_signed.zip "${user}@${host}:/home/hitman/sites/backup/${REVISION}/MicroG/arm/Oreo/MicroG-arm-8.1.0-${COMMONGAPPSRELEASE}_signed.zip"
        $MICROG_API_26 && rsync -a -v out/arm/MicroG-arm-8.0.0-${COMMONGAPPSRELEASE}_signed.zip "${user}@${host}:/home/hitman/sites/backup/${REVISION}/MicroG/arm/Oreo/MicroG-arm-8.0.0-${COMMONGAPPSRELEASE}_signed.zip"
        $MICROG_API_25 && rsync -a -v out/arm/MicroG-arm-7.1.2-${COMMONGAPPSRELEASE}_signed.zip "${user}@${host}:/home/hitman/sites/backup/${REVISION}/MicroG/arm/Nougat/MicroG-arm-7.1.2-${COMMONGAPPSRELEASE}_signed.zip"
        $MICROG_API_25 && rsync -a -v out/arm/MicroG-arm-7.1.1-${COMMONGAPPSRELEASE}_signed.zip "${user}@${host}:/home/hitman/sites/backup/${REVISION}/MicroG/arm/Nougat/MicroG-arm-7.1.1-${COMMONGAPPSRELEASE}_signed.zip"
      fi
      if [ -n "$COMMONADDONRELEASE" ]; then
        $TARGET_PLATFORM_ARM && rsync -a -v out/arm/BiTGApps-addon-arm-${COMMONADDONRELEASE}_signed.zip "${user}@${host}:/home/hitman/sites/backup/${REVISION}/Addon/config/arm/BiTGApps-addon-arm-${COMMONADDONRELEASE}_signed.zip"
      fi
    fi
  fi
}

# AARCH64 Sources
arm64_sources() {
  if [ "$AARCH64" == "arm64" ]; then
    if [ "$SERVER" == "ga" ]; then
      if [ -n "$COMMONGAPPSRELEASE" ]; then
        $TARGET_API_31 && curl -T out/arm64/BiTGApps-arm64-12.0.0-${COMMONGAPPSRELEASE}_signed.zip "ftp://${user}:${pass}@${host}/GApps/arm64/S/BiTGApps-arm64-12.0.0-${COMMONGAPPSRELEASE}_signed.zip"
        $TARGET_API_30 && curl -T out/arm64/BiTGApps-arm64-11.0.0-${COMMONGAPPSRELEASE}_signed.zip "ftp://${user}:${pass}@${host}/GApps/arm64/R/BiTGApps-arm64-11.0.0-${COMMONGAPPSRELEASE}_signed.zip"
        $TARGET_API_29 && curl -T out/arm64/BiTGApps-arm64-10.0.0-${COMMONGAPPSRELEASE}_signed.zip "ftp://${user}:${pass}@${host}/GApps/arm64/Q/BiTGApps-arm64-10.0.0-${COMMONGAPPSRELEASE}_signed.zip"
        $TARGET_API_28 && curl -T out/arm64/BiTGApps-arm64-9.0.0-${COMMONGAPPSRELEASE}_signed.zip "ftp://${user}:${pass}@${host}/GApps/arm64/Pie/BiTGApps-arm64-9.0.0-${COMMONGAPPSRELEASE}_signed.zip"
        $TARGET_API_27 && curl -T out/arm64/BiTGApps-arm64-8.1.0-${COMMONGAPPSRELEASE}_signed.zip "ftp://${user}:${pass}@${host}/GApps/arm64/Oreo/BiTGApps-arm64-8.1.0-${COMMONGAPPSRELEASE}_signed.zip"
        $TARGET_API_26 && curl -T out/arm64/BiTGApps-arm64-8.0.0-${COMMONGAPPSRELEASE}_signed.zip "ftp://${user}:${pass}@${host}/GApps/arm64/Oreo/BiTGApps-arm64-8.0.0-${COMMONGAPPSRELEASE}_signed.zip"
        $TARGET_API_25 && curl -T out/arm64/BiTGApps-arm64-7.1.2-${COMMONGAPPSRELEASE}_signed.zip "ftp://${user}:${pass}@${host}/GApps/arm64/Nougat/BiTGApps-arm64-7.1.2-${COMMONGAPPSRELEASE}_signed.zip"
        $TARGET_API_25 && curl -T out/arm64/BiTGApps-arm64-7.1.1-${COMMONGAPPSRELEASE}_signed.zip "ftp://${user}:${pass}@${host}/GApps/arm64/Nougat/BiTGApps-arm64-7.1.1-${COMMONGAPPSRELEASE}_signed.zip"
      fi
      if [ -n "$COMMONGAPPSRELEASE" ]; then
        $MICROG_API_31 && curl -T out/arm64/MicroG-arm64-12.0.0-${COMMONGAPPSRELEASE}_signed.zip "ftp://${user}:${pass}@${host}/MicroG/arm64/S/MicroG-arm64-12.0.0-${COMMONGAPPSRELEASE}_signed.zip"
        $MICROG_API_30 && curl -T out/arm64/MicroG-arm64-11.0.0-${COMMONGAPPSRELEASE}_signed.zip "ftp://${user}:${pass}@${host}/MicroG/arm64/R/MicroG-arm64-11.0.0-${COMMONGAPPSRELEASE}_signed.zip"
        $MICROG_API_29 && curl -T out/arm64/MicroG-arm64-10.0.0-${COMMONGAPPSRELEASE}_signed.zip "ftp://${user}:${pass}@${host}/MicroG/arm64/Q/MicroG-arm64-10.0.0-${COMMONGAPPSRELEASE}_signed.zip"
        $MICROG_API_28 && curl -T out/arm64/MicroG-arm64-9.0.0-${COMMONGAPPSRELEASE}_signed.zip "ftp://${user}:${pass}@${host}/MicroG/arm64/Pie/MicroG-arm64-9.0.0-${COMMONGAPPSRELEASE}_signed.zip"
        $MICROG_API_27 && curl -T out/arm64/MicroG-arm64-8.1.0-${COMMONGAPPSRELEASE}_signed.zip "ftp://${user}:${pass}@${host}/MicroG/arm64/Oreo/MicroG-arm64-8.1.0-${COMMONGAPPSRELEASE}_signed.zip"
        $MICROG_API_26 && curl -T out/arm64/MicroG-arm64-8.0.0-${COMMONGAPPSRELEASE}_signed.zip "ftp://${user}:${pass}@${host}/MicroG/arm64/Oreo/MicroG-arm64-8.0.0-${COMMONGAPPSRELEASE}_signed.zip"
        $MICROG_API_25 && curl -T out/arm64/MicroG-arm64-7.1.2-${COMMONGAPPSRELEASE}_signed.zip "ftp://${user}:${pass}@${host}/MicroG/arm64/Nougat/MicroG-arm64-7.1.2-${COMMONGAPPSRELEASE}_signed.zip"
        $MICROG_API_25 && curl -T out/arm64/MicroG-arm64-7.1.1-${COMMONGAPPSRELEASE}_signed.zip "ftp://${user}:${pass}@${host}/MicroG/arm64/Nougat/MicroG-arm64-7.1.1-${COMMONGAPPSRELEASE}_signed.zip"
      fi
      if [ -n "$COMMONADDONRELEASE" ]; then
        $TARGET_PLATFORM_ARM64 && curl -T out/arm64/BiTGApps-addon-arm64-${COMMONADDONRELEASE}_signed.zip "ftp://${user}:${pass}@${host}/Addon/config/arm64/BiTGApps-addon-arm64-${COMMONADDONRELEASE}_signed.zip"
      fi
    fi
    if [ "$SERVER" == "dh" ]; then
      if [ -n "$COMMONGAPPSRELEASE" ]; then
        $TARGET_API_31 && rsync -a -v out/arm64/BiTGApps-arm64-12.0.0-${COMMONGAPPSRELEASE}_signed.zip "${user}@${host}:/home/bitgapps/bitgapps.com/downloads/GApps/arm64/S/BiTGApps-arm64-12.0.0-${COMMONGAPPSRELEASE}_signed.zip"
        $TARGET_API_30 && rsync -a -v out/arm64/BiTGApps-arm64-11.0.0-${COMMONGAPPSRELEASE}_signed.zip "${user}@${host}:/home/bitgapps/bitgapps.com/downloads/GApps/arm64/R/BiTGApps-arm64-11.0.0-${COMMONGAPPSRELEASE}_signed.zip"
        $TARGET_API_29 && rsync -a -v out/arm64/BiTGApps-arm64-10.0.0-${COMMONGAPPSRELEASE}_signed.zip "${user}@${host}:/home/bitgapps/bitgapps.com/downloads/GApps/arm64/Q/BiTGApps-arm64-10.0.0-${COMMONGAPPSRELEASE}_signed.zip"
        $TARGET_API_28 && rsync -a -v out/arm64/BiTGApps-arm64-9.0.0-${COMMONGAPPSRELEASE}_signed.zip "${user}@${host}:/home/bitgapps/bitgapps.com/downloads/GApps/arm64/Pie/BiTGApps-arm64-9.0.0-${COMMONGAPPSRELEASE}_signed.zip"
        $TARGET_API_27 && rsync -a -v out/arm64/BiTGApps-arm64-8.1.0-${COMMONGAPPSRELEASE}_signed.zip "${user}@${host}:/home/bitgapps/bitgapps.com/downloads/GApps/arm64/Oreo/BiTGApps-arm64-8.1.0-${COMMONGAPPSRELEASE}_signed.zip"
        $TARGET_API_26 && rsync -a -v out/arm64/BiTGApps-arm64-8.0.0-${COMMONGAPPSRELEASE}_signed.zip "${user}@${host}:/home/bitgapps/bitgapps.com/downloads/GApps/arm64/Oreo/BiTGApps-arm64-8.0.0-${COMMONGAPPSRELEASE}_signed.zip"
        $TARGET_API_25 && rsync -a -v out/arm64/BiTGApps-arm64-7.1.2-${COMMONGAPPSRELEASE}_signed.zip "${user}@${host}:/home/bitgapps/bitgapps.com/downloads/GApps/arm64/Nougat/BiTGApps-arm64-7.1.2-${COMMONGAPPSRELEASE}_signed.zip"
        $TARGET_API_25 && rsync -a -v out/arm64/BiTGApps-arm64-7.1.1-${COMMONGAPPSRELEASE}_signed.zip "${user}@${host}:/home/bitgapps/bitgapps.com/downloads/GApps/arm64/Nougat/BiTGApps-arm64-7.1.1-${COMMONGAPPSRELEASE}_signed.zip"
      fi
      if [ -n "$COMMONGAPPSRELEASE" ]; then
        $MICROG_API_31 && rsync -a -v out/arm64/MicroG-arm64-12.0.0-${COMMONGAPPSRELEASE}_signed.zip "${user}@${host}:/home/bitgapps/bitgapps.com/downloads/MicroG/arm64/S/MicroG-arm64-12.0.0-${COMMONGAPPSRELEASE}_signed.zip"
        $MICROG_API_30 && rsync -a -v out/arm64/MicroG-arm64-11.0.0-${COMMONGAPPSRELEASE}_signed.zip "${user}@${host}:/home/bitgapps/bitgapps.com/downloads/MicroG/arm64/R/MicroG-arm64-11.0.0-${COMMONGAPPSRELEASE}_signed.zip"
        $MICROG_API_29 && rsync -a -v out/arm64/MicroG-arm64-10.0.0-${COMMONGAPPSRELEASE}_signed.zip "${user}@${host}:/home/bitgapps/bitgapps.com/downloads/MicroG/arm64/Q/MicroG-arm64-10.0.0-${COMMONGAPPSRELEASE}_signed.zip"
        $MICROG_API_28 && rsync -a -v out/arm64/MicroG-arm64-9.0.0-${COMMONGAPPSRELEASE}_signed.zip "${user}@${host}:/home/bitgapps/bitgapps.com/downloads/MicroG/arm64/Pie/MicroG-arm64-9.0.0-${COMMONGAPPSRELEASE}_signed.zip"
        $MICROG_API_27 && rsync -a -v out/arm64/MicroG-arm64-8.1.0-${COMMONGAPPSRELEASE}_signed.zip "${user}@${host}:/home/bitgapps/bitgapps.com/downloads/MicroG/arm64/Oreo/MicroG-arm64-8.1.0-${COMMONGAPPSRELEASE}_signed.zip"
        $MICROG_API_26 && rsync -a -v out/arm64/MicroG-arm64-8.0.0-${COMMONGAPPSRELEASE}_signed.zip "${user}@${host}:/home/bitgapps/bitgapps.com/downloads/MicroG/arm64/Oreo/MicroG-arm64-8.0.0-${COMMONGAPPSRELEASE}_signed.zip"
        $MICROG_API_25 && rsync -a -v out/arm64/MicroG-arm64-7.1.2-${COMMONGAPPSRELEASE}_signed.zip "${user}@${host}:/home/bitgapps/bitgapps.com/downloads/MicroG/arm64/Nougat/MicroG-arm64-7.1.2-${COMMONGAPPSRELEASE}_signed.zip"
        $MICROG_API_25 && rsync -a -v out/arm64/MicroG-arm64-7.1.1-${COMMONGAPPSRELEASE}_signed.zip "${user}@${host}:/home/bitgapps/bitgapps.com/downloads/MicroG/arm64/Nougat/MicroG-arm64-7.1.1-${COMMONGAPPSRELEASE}_signed.zip"
      fi
      if [ -n "$COMMONADDONRELEASE" ]; then
        $TARGET_PLATFORM_ARM64 && rsync -a -v out/arm64/BiTGApps-addon-arm64-${COMMONADDONRELEASE}_signed.zip "${user}@${host}:/home/bitgapps/bitgapps.com/downloads/Addon/config/arm64/BiTGApps-addon-arm64-${COMMONADDONRELEASE}_signed.zip"
      fi
    fi
    if [ "$SERVER" == "sps" ]; then
      if [ -n "$COMMONGAPPSRELEASE" ]; then
        $TARGET_API_31 && rsync -a -v out/arm64/BiTGApps-arm64-12.0.0-${COMMONGAPPSRELEASE}_signed.zip "${user}@${host}:/home/hitman/sites/downloads/GApps/arm64/S/BiTGApps-arm64-12.0.0-${COMMONGAPPSRELEASE}_signed.zip"
        $TARGET_API_30 && rsync -a -v out/arm64/BiTGApps-arm64-11.0.0-${COMMONGAPPSRELEASE}_signed.zip "${user}@${host}:/home/hitman/sites/downloads/GApps/arm64/R/BiTGApps-arm64-11.0.0-${COMMONGAPPSRELEASE}_signed.zip"
        $TARGET_API_29 && rsync -a -v out/arm64/BiTGApps-arm64-10.0.0-${COMMONGAPPSRELEASE}_signed.zip "${user}@${host}:/home/hitman/sites/downloads/GApps/arm64/Q/BiTGApps-arm64-10.0.0-${COMMONGAPPSRELEASE}_signed.zip"
        $TARGET_API_28 && rsync -a -v out/arm64/BiTGApps-arm64-9.0.0-${COMMONGAPPSRELEASE}_signed.zip "${user}@${host}:/home/hitman/sites/downloads/GApps/arm64/Pie/BiTGApps-arm64-9.0.0-${COMMONGAPPSRELEASE}_signed.zip"
        $TARGET_API_27 && rsync -a -v out/arm64/BiTGApps-arm64-8.1.0-${COMMONGAPPSRELEASE}_signed.zip "${user}@${host}:/home/hitman/sites/downloads/GApps/arm64/Oreo/BiTGApps-arm64-8.1.0-${COMMONGAPPSRELEASE}_signed.zip"
        $TARGET_API_26 && rsync -a -v out/arm64/BiTGApps-arm64-8.0.0-${COMMONGAPPSRELEASE}_signed.zip "${user}@${host}:/home/hitman/sites/downloads/GApps/arm64/Oreo/BiTGApps-arm64-8.0.0-${COMMONGAPPSRELEASE}_signed.zip"
        $TARGET_API_25 && rsync -a -v out/arm64/BiTGApps-arm64-7.1.2-${COMMONGAPPSRELEASE}_signed.zip "${user}@${host}:/home/hitman/sites/downloads/GApps/arm64/Nougat/BiTGApps-arm64-7.1.2-${COMMONGAPPSRELEASE}_signed.zip"
        $TARGET_API_25 && rsync -a -v out/arm64/BiTGApps-arm64-7.1.1-${COMMONGAPPSRELEASE}_signed.zip "${user}@${host}:/home/hitman/sites/downloads/GApps/arm64/Nougat/BiTGApps-arm64-7.1.1-${COMMONGAPPSRELEASE}_signed.zip"
      fi
      if [ -n "$COMMONGAPPSRELEASE" ]; then
        $MICROG_API_31 && rsync -a -v out/arm64/MicroG-arm64-12.0.0-${COMMONGAPPSRELEASE}_signed.zip "${user}@${host}:/home/hitman/sites/downloads/MicroG/arm64/S/MicroG-arm64-12.0.0-${COMMONGAPPSRELEASE}_signed.zip"
        $MICROG_API_30 && rsync -a -v out/arm64/MicroG-arm64-11.0.0-${COMMONGAPPSRELEASE}_signed.zip "${user}@${host}:/home/hitman/sites/downloads/MicroG/arm64/R/MicroG-arm64-11.0.0-${COMMONGAPPSRELEASE}_signed.zip"
        $MICROG_API_29 && rsync -a -v out/arm64/MicroG-arm64-10.0.0-${COMMONGAPPSRELEASE}_signed.zip "${user}@${host}:/home/hitman/sites/downloads/MicroG/arm64/Q/MicroG-arm64-10.0.0-${COMMONGAPPSRELEASE}_signed.zip"
        $MICROG_API_28 && rsync -a -v out/arm64/MicroG-arm64-9.0.0-${COMMONGAPPSRELEASE}_signed.zip "${user}@${host}:/home/hitman/sites/downloads/MicroG/arm64/Pie/MicroG-arm64-9.0.0-${COMMONGAPPSRELEASE}_signed.zip"
        $MICROG_API_27 && rsync -a -v out/arm64/MicroG-arm64-8.1.0-${COMMONGAPPSRELEASE}_signed.zip "${user}@${host}:/home/hitman/sites/downloads/MicroG/arm64/Oreo/MicroG-arm64-8.1.0-${COMMONGAPPSRELEASE}_signed.zip"
        $MICROG_API_26 && rsync -a -v out/arm64/MicroG-arm64-8.0.0-${COMMONGAPPSRELEASE}_signed.zip "${user}@${host}:/home/hitman/sites/downloads/MicroG/arm64/Oreo/MicroG-arm64-8.0.0-${COMMONGAPPSRELEASE}_signed.zip"
        $MICROG_API_25 && rsync -a -v out/arm64/MicroG-arm64-7.1.2-${COMMONGAPPSRELEASE}_signed.zip "${user}@${host}:/home/hitman/sites/downloads/MicroG/arm64/Nougat/MicroG-arm64-7.1.2-${COMMONGAPPSRELEASE}_signed.zip"
        $MICROG_API_25 && rsync -a -v out/arm64/MicroG-arm64-7.1.1-${COMMONGAPPSRELEASE}_signed.zip "${user}@${host}:/home/hitman/sites/downloads/MicroG/arm64/Nougat/MicroG-arm64-7.1.1-${COMMONGAPPSRELEASE}_signed.zip"
      fi
      if [ -n "$COMMONADDONRELEASE" ]; then
        $TARGET_PLATFORM_ARM64 && rsync -a -v out/arm64/BiTGApps-addon-arm64-${COMMONADDONRELEASE}_signed.zip "${user}@${host}:/home/hitman/sites/downloads/Addon/config/arm64/BiTGApps-addon-arm64-${COMMONADDONRELEASE}_signed.zip"
      fi
    fi
    if [ "$SERVER" == "alpha" ]; then
      if [ -n "$COMMONGAPPSRELEASE" ]; then
        $TARGET_API_31 && rsync -a -v out/arm64/BiTGApps-arm64-12.0.0-${COMMONGAPPSRELEASE}_signed.zip "${user}@${host}:/home/hitman/sites/alpha/${REVISION}/GApps/arm64/S/BiTGApps-arm64-12.0.0-${COMMONGAPPSRELEASE}_signed.zip"
        $TARGET_API_30 && rsync -a -v out/arm64/BiTGApps-arm64-11.0.0-${COMMONGAPPSRELEASE}_signed.zip "${user}@${host}:/home/hitman/sites/alpha/${REVISION}/GApps/arm64/R/BiTGApps-arm64-11.0.0-${COMMONGAPPSRELEASE}_signed.zip"
        $TARGET_API_29 && rsync -a -v out/arm64/BiTGApps-arm64-10.0.0-${COMMONGAPPSRELEASE}_signed.zip "${user}@${host}:/home/hitman/sites/alpha/${REVISION}/GApps/arm64/Q/BiTGApps-arm64-10.0.0-${COMMONGAPPSRELEASE}_signed.zip"
        $TARGET_API_28 && rsync -a -v out/arm64/BiTGApps-arm64-9.0.0-${COMMONGAPPSRELEASE}_signed.zip "${user}@${host}:/home/hitman/sites/alpha/${REVISION}/GApps/arm64/Pie/BiTGApps-arm64-9.0.0-${COMMONGAPPSRELEASE}_signed.zip"
        $TARGET_API_27 && rsync -a -v out/arm64/BiTGApps-arm64-8.1.0-${COMMONGAPPSRELEASE}_signed.zip "${user}@${host}:/home/hitman/sites/alpha/${REVISION}/GApps/arm64/Oreo/BiTGApps-arm64-8.1.0-${COMMONGAPPSRELEASE}_signed.zip"
        $TARGET_API_26 && rsync -a -v out/arm64/BiTGApps-arm64-8.0.0-${COMMONGAPPSRELEASE}_signed.zip "${user}@${host}:/home/hitman/sites/alpha/${REVISION}/GApps/arm64/Oreo/BiTGApps-arm64-8.0.0-${COMMONGAPPSRELEASE}_signed.zip"
        $TARGET_API_25 && rsync -a -v out/arm64/BiTGApps-arm64-7.1.2-${COMMONGAPPSRELEASE}_signed.zip "${user}@${host}:/home/hitman/sites/alpha/${REVISION}/GApps/arm64/Nougat/BiTGApps-arm64-7.1.2-${COMMONGAPPSRELEASE}_signed.zip"
        $TARGET_API_25 && rsync -a -v out/arm64/BiTGApps-arm64-7.1.1-${COMMONGAPPSRELEASE}_signed.zip "${user}@${host}:/home/hitman/sites/alpha/${REVISION}/GApps/arm64/Nougat/BiTGApps-arm64-7.1.1-${COMMONGAPPSRELEASE}_signed.zip"
      fi
      if [ -n "$COMMONGAPPSRELEASE" ]; then
        $MICROG_API_31 && rsync -a -v out/arm64/MicroG-arm64-12.0.0-${COMMONGAPPSRELEASE}_signed.zip "${user}@${host}:/home/hitman/sites/alpha/${REVISION}/MicroG/arm64/S/MicroG-arm64-12.0.0-${COMMONGAPPSRELEASE}_signed.zip"
        $MICROG_API_30 && rsync -a -v out/arm64/MicroG-arm64-11.0.0-${COMMONGAPPSRELEASE}_signed.zip "${user}@${host}:/home/hitman/sites/alpha/${REVISION}/MicroG/arm64/R/MicroG-arm64-11.0.0-${COMMONGAPPSRELEASE}_signed.zip"
        $MICROG_API_29 && rsync -a -v out/arm64/MicroG-arm64-10.0.0-${COMMONGAPPSRELEASE}_signed.zip "${user}@${host}:/home/hitman/sites/alpha/${REVISION}/MicroG/arm64/Q/MicroG-arm64-10.0.0-${COMMONGAPPSRELEASE}_signed.zip"
        $MICROG_API_28 && rsync -a -v out/arm64/MicroG-arm64-9.0.0-${COMMONGAPPSRELEASE}_signed.zip "${user}@${host}:/home/hitman/sites/alpha/${REVISION}/MicroG/arm64/Pie/MicroG-arm64-9.0.0-${COMMONGAPPSRELEASE}_signed.zip"
        $MICROG_API_27 && rsync -a -v out/arm64/MicroG-arm64-8.1.0-${COMMONGAPPSRELEASE}_signed.zip "${user}@${host}:/home/hitman/sites/alpha/${REVISION}/MicroG/arm64/Oreo/MicroG-arm64-8.1.0-${COMMONGAPPSRELEASE}_signed.zip"
        $MICROG_API_26 && rsync -a -v out/arm64/MicroG-arm64-8.0.0-${COMMONGAPPSRELEASE}_signed.zip "${user}@${host}:/home/hitman/sites/alpha/${REVISION}/MicroG/arm64/Oreo/MicroG-arm64-8.0.0-${COMMONGAPPSRELEASE}_signed.zip"
        $MICROG_API_25 && rsync -a -v out/arm64/MicroG-arm64-7.1.2-${COMMONGAPPSRELEASE}_signed.zip "${user}@${host}:/home/hitman/sites/alpha/${REVISION}/MicroG/arm64/Nougat/MicroG-arm64-7.1.2-${COMMONGAPPSRELEASE}_signed.zip"
        $MICROG_API_25 && rsync -a -v out/arm64/MicroG-arm64-7.1.1-${COMMONGAPPSRELEASE}_signed.zip "${user}@${host}:/home/hitman/sites/alpha/${REVISION}/MicroG/arm64/Nougat/MicroG-arm64-7.1.1-${COMMONGAPPSRELEASE}_signed.zip"
      fi
      if [ -n "$COMMONADDONRELEASE" ]; then
        $TARGET_PLATFORM_ARM64 && rsync -a -v out/arm64/BiTGApps-addon-arm64-${COMMONADDONRELEASE}_signed.zip "${user}@${host}:/home/hitman/sites/alpha/${REVISION}/Addon/config/arm64/BiTGApps-addon-arm64-${COMMONADDONRELEASE}_signed.zip"
      fi
    fi
    if [ "$SERVER" == "backup" ]; then
      if [ -n "$COMMONGAPPSRELEASE" ]; then
        $TARGET_API_31 && rsync -a -v out/arm64/BiTGApps-arm64-12.0.0-${COMMONGAPPSRELEASE}_signed.zip "${user}@${host}:/home/hitman/sites/backup/${REVISION}/GApps/arm64/S/BiTGApps-arm64-12.0.0-${COMMONGAPPSRELEASE}_signed.zip"
        $TARGET_API_30 && rsync -a -v out/arm64/BiTGApps-arm64-11.0.0-${COMMONGAPPSRELEASE}_signed.zip "${user}@${host}:/home/hitman/sites/backup/${REVISION}/GApps/arm64/R/BiTGApps-arm64-11.0.0-${COMMONGAPPSRELEASE}_signed.zip"
        $TARGET_API_29 && rsync -a -v out/arm64/BiTGApps-arm64-10.0.0-${COMMONGAPPSRELEASE}_signed.zip "${user}@${host}:/home/hitman/sites/backup/${REVISION}/GApps/arm64/Q/BiTGApps-arm64-10.0.0-${COMMONGAPPSRELEASE}_signed.zip"
        $TARGET_API_28 && rsync -a -v out/arm64/BiTGApps-arm64-9.0.0-${COMMONGAPPSRELEASE}_signed.zip "${user}@${host}:/home/hitman/sites/backup/${REVISION}/GApps/arm64/Pie/BiTGApps-arm64-9.0.0-${COMMONGAPPSRELEASE}_signed.zip"
        $TARGET_API_27 && rsync -a -v out/arm64/BiTGApps-arm64-8.1.0-${COMMONGAPPSRELEASE}_signed.zip "${user}@${host}:/home/hitman/sites/backup/${REVISION}/GApps/arm64/Oreo/BiTGApps-arm64-8.1.0-${COMMONGAPPSRELEASE}_signed.zip"
        $TARGET_API_26 && rsync -a -v out/arm64/BiTGApps-arm64-8.0.0-${COMMONGAPPSRELEASE}_signed.zip "${user}@${host}:/home/hitman/sites/backup/${REVISION}/GApps/arm64/Oreo/BiTGApps-arm64-8.0.0-${COMMONGAPPSRELEASE}_signed.zip"
        $TARGET_API_25 && rsync -a -v out/arm64/BiTGApps-arm64-7.1.2-${COMMONGAPPSRELEASE}_signed.zip "${user}@${host}:/home/hitman/sites/backup/${REVISION}/GApps/arm64/Nougat/BiTGApps-arm64-7.1.2-${COMMONGAPPSRELEASE}_signed.zip"
        $TARGET_API_25 && rsync -a -v out/arm64/BiTGApps-arm64-7.1.1-${COMMONGAPPSRELEASE}_signed.zip "${user}@${host}:/home/hitman/sites/backup/${REVISION}/GApps/arm64/Nougat/BiTGApps-arm64-7.1.1-${COMMONGAPPSRELEASE}_signed.zip"
      fi
      if [ -n "$COMMONGAPPSRELEASE" ]; then
        $MICROG_API_31 && rsync -a -v out/arm64/MicroG-arm64-12.0.0-${COMMONGAPPSRELEASE}_signed.zip "${user}@${host}:/home/hitman/sites/backup/${REVISION}/MicroG/arm64/S/MicroG-arm64-12.0.0-${COMMONGAPPSRELEASE}_signed.zip"
        $MICROG_API_30 && rsync -a -v out/arm64/MicroG-arm64-11.0.0-${COMMONGAPPSRELEASE}_signed.zip "${user}@${host}:/home/hitman/sites/backup/${REVISION}/MicroG/arm64/R/MicroG-arm64-11.0.0-${COMMONGAPPSRELEASE}_signed.zip"
        $MICROG_API_29 && rsync -a -v out/arm64/MicroG-arm64-10.0.0-${COMMONGAPPSRELEASE}_signed.zip "${user}@${host}:/home/hitman/sites/backup/${REVISION}/MicroG/arm64/Q/MicroG-arm64-10.0.0-${COMMONGAPPSRELEASE}_signed.zip"
        $MICROG_API_28 && rsync -a -v out/arm64/MicroG-arm64-9.0.0-${COMMONGAPPSRELEASE}_signed.zip "${user}@${host}:/home/hitman/sites/backup/${REVISION}/MicroG/arm64/Pie/MicroG-arm64-9.0.0-${COMMONGAPPSRELEASE}_signed.zip"
        $MICROG_API_27 && rsync -a -v out/arm64/MicroG-arm64-8.1.0-${COMMONGAPPSRELEASE}_signed.zip "${user}@${host}:/home/hitman/sites/backup/${REVISION}/MicroG/arm64/Oreo/MicroG-arm64-8.1.0-${COMMONGAPPSRELEASE}_signed.zip"
        $MICROG_API_26 && rsync -a -v out/arm64/MicroG-arm64-8.0.0-${COMMONGAPPSRELEASE}_signed.zip "${user}@${host}:/home/hitman/sites/backup/${REVISION}/MicroG/arm64/Oreo/MicroG-arm64-8.0.0-${COMMONGAPPSRELEASE}_signed.zip"
        $MICROG_API_25 && rsync -a -v out/arm64/MicroG-arm64-7.1.2-${COMMONGAPPSRELEASE}_signed.zip "${user}@${host}:/home/hitman/sites/backup/${REVISION}/MicroG/arm64/Nougat/MicroG-arm64-7.1.2-${COMMONGAPPSRELEASE}_signed.zip"
        $MICROG_API_25 && rsync -a -v out/arm64/MicroG-arm64-7.1.1-${COMMONGAPPSRELEASE}_signed.zip "${user}@${host}:/home/hitman/sites/backup/${REVISION}/MicroG/arm64/Nougat/MicroG-arm64-7.1.1-${COMMONGAPPSRELEASE}_signed.zip"
      fi
      if [ -n "$COMMONADDONRELEASE" ]; then
        $TARGET_PLATFORM_ARM64 && rsync -a -v out/arm64/BiTGApps-addon-arm64-${COMMONADDONRELEASE}_signed.zip "${user}@${host}:/home/hitman/sites/backup/${REVISION}/Addon/config/arm64/BiTGApps-addon-arm64-${COMMONADDONRELEASE}_signed.zip"
      fi
    fi
  fi
}

# COMMON Sources; Contains both ARMEABI & AARCH64 packages
common_sources() {
  if [ "$COMMON" == "common" ]; then
    if [ "$SERVER" == "ga" ]; then
      if [ -n "$COMMONADDONRELEASE" ]; then
        $TARGET_VARIANT_ASSISTANT && curl -T out/common/BiTGApps-addon-assistant-${COMMONADDONRELEASE}_signed.zip "ftp://${user}:${pass}@${host}/Addon/non-config/BiTGApps-addon-assistant-${COMMONADDONRELEASE}_signed.zip"
        $TARGET_VARIANT_BROMITE && curl -T out/common/BiTGApps-addon-bromite-${COMMONADDONRELEASE}_signed.zip "ftp://${user}:${pass}@${host}/Addon/non-config/BiTGApps-addon-bromite-${COMMONADDONRELEASE}_signed.zip"
        $TARGET_VARIANT_CALCULATOR && curl -T out/common/BiTGApps-addon-calculator-${COMMONADDONRELEASE}_signed.zip "ftp://${user}:${pass}@${host}/Addon/non-config/BiTGApps-addon-calculator-${COMMONADDONRELEASE}_signed.zip"
        $TARGET_VARIANT_CALENDAR && curl -T out/common/BiTGApps-addon-calendar-${COMMONADDONRELEASE}_signed.zip "ftp://${user}:${pass}@${host}/Addon/non-config/BiTGApps-addon-calendar-${COMMONADDONRELEASE}_signed.zip"
        $TARGET_VARIANT_CHROME && curl -T out/common/BiTGApps-addon-chrome-${COMMONADDONRELEASE}_signed.zip "ftp://${user}:${pass}@${host}/Addon/non-config/BiTGApps-addon-chrome-${COMMONADDONRELEASE}_signed.zip"
        $TARGET_VARIANT_CONTACTS && curl -T out/common/BiTGApps-addon-contacts-${COMMONADDONRELEASE}_signed.zip "ftp://${user}:${pass}@${host}/Addon/non-config/BiTGApps-addon-contacts-${COMMONADDONRELEASE}_signed.zip"
        $TARGET_VARIANT_DESKCLOCK && curl -T out/common/BiTGApps-addon-deskclock-${COMMONADDONRELEASE}_signed.zip "ftp://${user}:${pass}@${host}/Addon/non-config/BiTGApps-addon-deskclock-${COMMONADDONRELEASE}_signed.zip"
        $TARGET_VARIANT_DIALER && curl -T out/common/BiTGApps-addon-dialer-${COMMONADDONRELEASE}_signed.zip "ftp://${user}:${pass}@${host}/Addon/non-config/BiTGApps-addon-dialer-${COMMONADDONRELEASE}_signed.zip"
        $TARGET_VARIANT_DPS && curl -T out/common/BiTGApps-addon-dps-${COMMONADDONRELEASE}_signed.zip "ftp://${user}:${pass}@${host}/Addon/non-config/BiTGApps-addon-dps-${COMMONADDONRELEASE}_signed.zip"
        $TARGET_VARIANT_GBOARD && curl -T out/common/BiTGApps-addon-gboard-${COMMONADDONRELEASE}_signed.zip "ftp://${user}:${pass}@${host}/Addon/non-config/BiTGApps-addon-gboard-${COMMONADDONRELEASE}_signed.zip"
        $TARGET_VARIANT_GEARHEAD && curl -T out/common/BiTGApps-addon-gearhead-${COMMONADDONRELEASE}_signed.zip "ftp://${user}:${pass}@${host}/Addon/non-config/BiTGApps-addon-gearhead-${COMMONADDONRELEASE}_signed.zip"
        $TARGET_VARIANT_LAUNCHER && curl -T out/common/BiTGApps-addon-launcher-${COMMONADDONRELEASE}_signed.zip "ftp://${user}:${pass}@${host}/Addon/non-config/BiTGApps-addon-launcher-${COMMONADDONRELEASE}_signed.zip"
        $TARGET_VARIANT_MAPS && curl -T out/common/BiTGApps-addon-maps-${COMMONADDONRELEASE}_signed.zip "ftp://${user}:${pass}@${host}/Addon/non-config/BiTGApps-addon-maps-${COMMONADDONRELEASE}_signed.zip"
        $TARGET_VARIANT_MARKUP && curl -T out/common/BiTGApps-addon-markup-${COMMONADDONRELEASE}_signed.zip "ftp://${user}:${pass}@${host}/Addon/non-config/BiTGApps-addon-markup-${COMMONADDONRELEASE}_signed.zip"
        $TARGET_VARIANT_MESSAGES && curl -T out/common/BiTGApps-addon-messages-${COMMONADDONRELEASE}_signed.zip "ftp://${user}:${pass}@${host}/Addon/non-config/BiTGApps-addon-messages-${COMMONADDONRELEASE}_signed.zip"
        $TARGET_VARIANT_PHOTOS && curl -T out/common/BiTGApps-addon-photos-${COMMONADDONRELEASE}_signed.zip "ftp://${user}:${pass}@${host}/Addon/non-config/BiTGApps-addon-photos-${COMMONADDONRELEASE}_signed.zip"
        $TARGET_VARIANT_SOUNDPICKER && curl -T out/common/BiTGApps-addon-soundpicker-${COMMONADDONRELEASE}_signed.zip "ftp://${user}:${pass}@${host}/Addon/non-config/BiTGApps-addon-soundpicker-${COMMONADDONRELEASE}_signed.zip"
        $TARGET_VARIANT_TTS && curl -T out/common/BiTGApps-addon-tts-${COMMONADDONRELEASE}_signed.zip "ftp://${user}:${pass}@${host}/Addon/non-config/BiTGApps-addon-tts-${COMMONADDONRELEASE}_signed.zip"
        $TARGET_VARIANT_VANCED_MICROG && curl -T out/common/BiTGApps-addon-vanced-microg-${COMMONADDONRELEASE}_signed.zip "ftp://${user}:${pass}@${host}/Addon/non-config/BiTGApps-addon-vanced-microg-${COMMONADDONRELEASE}_signed.zip"
        $TARGET_VARIANT_VANCED_ROOT && curl -T out/common/BiTGApps-addon-vanced-root-${COMMONADDONRELEASE}_signed.zip "ftp://${user}:${pass}@${host}/Addon/non-config/BiTGApps-addon-vanced-root-${COMMONADDONRELEASE}_signed.zip"
        $TARGET_VARIANT_VANCED_NONROOT && curl -T out/common/BiTGApps-addon-vanced-nonroot-${COMMONADDONRELEASE}_signed.zip "ftp://${user}:${pass}@${host}/Addon/non-config/BiTGApps-addon-vanced-nonroot-${COMMONADDONRELEASE}_signed.zip"
        $TARGET_VARIANT_WELLBEING && curl -T out/common/BiTGApps-addon-wellbeing-${COMMONADDONRELEASE}_signed.zip "ftp://${user}:${pass}@${host}/Addon/non-config/BiTGApps-addon-wellbeing-${COMMONADDONRELEASE}_signed.zip"
      fi
    fi
    if [ "$SERVER" == "dh" ]; then
      if [ -n "$COMMONADDONRELEASE" ]; then
        $TARGET_VARIANT_ASSISTANT && rsync -a -v out/common/BiTGApps-addon-assistant-${COMMONADDONRELEASE}_signed.zip "${user}@${host}:/home/bitgapps/bitgapps.com/downloads/Addon/non-config/BiTGApps-addon-assistant-${COMMONADDONRELEASE}_signed.zip"
        $TARGET_VARIANT_BROMITE && rsync -a -v out/common/BiTGApps-addon-bromite-${COMMONADDONRELEASE}_signed.zip "${user}@${host}:/home/bitgapps/bitgapps.com/downloads/Addon/non-config/BiTGApps-addon-bromite-${COMMONADDONRELEASE}_signed.zip"
        $TARGET_VARIANT_CALCULATOR && rsync -a -v out/common/BiTGApps-addon-calculator-${COMMONADDONRELEASE}_signed.zip "${user}@${host}:/home/bitgapps/bitgapps.com/downloads/Addon/non-config/BiTGApps-addon-calculator-${COMMONADDONRELEASE}_signed.zip"
        $TARGET_VARIANT_CALENDAR && rsync -a -v out/common/BiTGApps-addon-calendar-${COMMONADDONRELEASE}_signed.zip "${user}@${host}:/home/bitgapps/bitgapps.com/downloads/Addon/non-config/BiTGApps-addon-calendar-${COMMONADDONRELEASE}_signed.zip"
        $TARGET_VARIANT_CHROME && rsync -a -v out/common/BiTGApps-addon-chrome-${COMMONADDONRELEASE}_signed.zip "${user}@${host}:/home/bitgapps/bitgapps.com/downloads/Addon/non-config/BiTGApps-addon-chrome-${COMMONADDONRELEASE}_signed.zip"
        $TARGET_VARIANT_CONTACTS && rsync -a -v out/common/BiTGApps-addon-contacts-${COMMONADDONRELEASE}_signed.zip "${user}@${host}:/home/bitgapps/bitgapps.com/downloads/Addon/non-config/BiTGApps-addon-contacts-${COMMONADDONRELEASE}_signed.zip"
        $TARGET_VARIANT_DESKCLOCK && rsync -a -v out/common/BiTGApps-addon-deskclock-${COMMONADDONRELEASE}_signed.zip "${user}@${host}:/home/bitgapps/bitgapps.com/downloads/Addon/non-config/BiTGApps-addon-deskclock-${COMMONADDONRELEASE}_signed.zip"
        $TARGET_VARIANT_DIALER && rsync -a -v out/common/BiTGApps-addon-dialer-${COMMONADDONRELEASE}_signed.zip "${user}@${host}:/home/bitgapps/bitgapps.com/downloads/Addon/non-config/BiTGApps-addon-dialer-${COMMONADDONRELEASE}_signed.zip"
        $TARGET_VARIANT_DPS && rsync -a -v out/common/BiTGApps-addon-dps-${COMMONADDONRELEASE}_signed.zip "${user}@${host}:/home/bitgapps/bitgapps.com/downloads/Addon/non-config/BiTGApps-addon-dps-${COMMONADDONRELEASE}_signed.zip"
        $TARGET_VARIANT_GBOARD && rsync -a -v out/common/BiTGApps-addon-gboard-${COMMONADDONRELEASE}_signed.zip "${user}@${host}:/home/bitgapps/bitgapps.com/downloads/Addon/non-config/BiTGApps-addon-gboard-${COMMONADDONRELEASE}_signed.zip"
        $TARGET_VARIANT_GEARHEAD && rsync -a -v out/common/BiTGApps-addon-gearhead-${COMMONADDONRELEASE}_signed.zip "${user}@${host}:/home/bitgapps/bitgapps.com/downloads/Addon/non-config/BiTGApps-addon-gearhead-${COMMONADDONRELEASE}_signed.zip"
        $TARGET_VARIANT_LAUNCHER && rsync -a -v out/common/BiTGApps-addon-launcher-${COMMONADDONRELEASE}_signed.zip "${user}@${host}:/home/bitgapps/bitgapps.com/downloads/Addon/non-config/BiTGApps-addon-launcher-${COMMONADDONRELEASE}_signed.zip"
        $TARGET_VARIANT_MAPS && rsync -a -v out/common/BiTGApps-addon-maps-${COMMONADDONRELEASE}_signed.zip "${user}@${host}:/home/bitgapps/bitgapps.com/downloads/Addon/non-config/BiTGApps-addon-maps-${COMMONADDONRELEASE}_signed.zip"
        $TARGET_VARIANT_MARKUP && rsync -a -v out/common/BiTGApps-addon-markup-${COMMONADDONRELEASE}_signed.zip "${user}@${host}:/home/bitgapps/bitgapps.com/downloads/Addon/non-config/BiTGApps-addon-markup-${COMMONADDONRELEASE}_signed.zip"
        $TARGET_VARIANT_MESSAGES && rsync -a -v out/common/BiTGApps-addon-messages-${COMMONADDONRELEASE}_signed.zip "${user}@${host}:/home/bitgapps/bitgapps.com/downloads/Addon/non-config/BiTGApps-addon-messages-${COMMONADDONRELEASE}_signed.zip"
        $TARGET_VARIANT_PHOTOS && rsync -a -v out/common/BiTGApps-addon-photos-${COMMONADDONRELEASE}_signed.zip "${user}@${host}:/home/bitgapps/bitgapps.com/downloads/Addon/non-config/BiTGApps-addon-photos-${COMMONADDONRELEASE}_signed.zip"
        $TARGET_VARIANT_SOUNDPICKER && rsync -a -v out/common/BiTGApps-addon-soundpicker-${COMMONADDONRELEASE}_signed.zip "${user}@${host}:/home/bitgapps/bitgapps.com/downloads/Addon/non-config/BiTGApps-addon-soundpicker-${COMMONADDONRELEASE}_signed.zip"
        $TARGET_VARIANT_TTS && rsync -a -v out/common/BiTGApps-addon-tts-${COMMONADDONRELEASE}_signed.zip "${user}@${host}:/home/bitgapps/bitgapps.com/downloads/Addon/non-config/BiTGApps-addon-tts-${COMMONADDONRELEASE}_signed.zip"
        $TARGET_VARIANT_VANCED_MICROG && rsync -a -v out/common/BiTGApps-addon-vanced-microg-${COMMONADDONRELEASE}_signed.zip "${user}@${host}:/home/bitgapps/bitgapps.com/downloads/Addon/non-config/BiTGApps-addon-vanced-microg-${COMMONADDONRELEASE}_signed.zip"
        $TARGET_VARIANT_VANCED_ROOT && rsync -a -v out/common/BiTGApps-addon-vanced-root-${COMMONADDONRELEASE}_signed.zip "${user}@${host}:/home/bitgapps/bitgapps.com/downloads/Addon/non-config/BiTGApps-addon-vanced-root-${COMMONADDONRELEASE}_signed.zip"
        $TARGET_VARIANT_VANCED_NONROOT && rsync -a -v out/common/BiTGApps-addon-vanced-nonroot-${COMMONADDONRELEASE}_signed.zip "${user}@${host}:/home/bitgapps/bitgapps.com/downloads/Addon/non-config/BiTGApps-addon-vanced-nonroot-${COMMONADDONRELEASE}_signed.zip"
        $TARGET_VARIANT_WELLBEING && rsync -a -v out/common/BiTGApps-addon-wellbeing-${COMMONADDONRELEASE}_signed.zip "${user}@${host}:/home/bitgapps/bitgapps.com/downloads/Addon/non-config/BiTGApps-addon-wellbeing-${COMMONADDONRELEASE}_signed.zip"
      fi
    fi
    if [ "$SERVER" == "sps" ]; then
      if [ -n "$COMMONADDONRELEASE" ]; then
        $TARGET_VARIANT_ASSISTANT && rsync -a -v out/common/BiTGApps-addon-assistant-${COMMONADDONRELEASE}_signed.zip "${user}@${host}:/home/hitman/sites/downloads/Addon/non-config/BiTGApps-addon-assistant-${COMMONADDONRELEASE}_signed.zip"
        $TARGET_VARIANT_BROMITE && rsync -a -v out/common/BiTGApps-addon-bromite-${COMMONADDONRELEASE}_signed.zip "${user}@${host}:/home/hitman/sites/downloads/Addon/non-config/BiTGApps-addon-bromite-${COMMONADDONRELEASE}_signed.zip"
        $TARGET_VARIANT_CALCULATOR && rsync -a -v out/common/BiTGApps-addon-calculator-${COMMONADDONRELEASE}_signed.zip "${user}@${host}:/home/hitman/sites/downloads/Addon/non-config/BiTGApps-addon-calculator-${COMMONADDONRELEASE}_signed.zip"
        $TARGET_VARIANT_CALENDAR && rsync -a -v out/common/BiTGApps-addon-calendar-${COMMONADDONRELEASE}_signed.zip "${user}@${host}:/home/hitman/sites/downloads/Addon/non-config/BiTGApps-addon-calendar-${COMMONADDONRELEASE}_signed.zip"
        $TARGET_VARIANT_CHROME && rsync -a -v out/common/BiTGApps-addon-chrome-${COMMONADDONRELEASE}_signed.zip "${user}@${host}:/home/hitman/sites/downloads/Addon/non-config/BiTGApps-addon-chrome-${COMMONADDONRELEASE}_signed.zip"
        $TARGET_VARIANT_CONTACTS && rsync -a -v out/common/BiTGApps-addon-contacts-${COMMONADDONRELEASE}_signed.zip "${user}@${host}:/home/hitman/sites/downloads/Addon/non-config/BiTGApps-addon-contacts-${COMMONADDONRELEASE}_signed.zip"
        $TARGET_VARIANT_DESKCLOCK && rsync -a -v out/common/BiTGApps-addon-deskclock-${COMMONADDONRELEASE}_signed.zip "${user}@${host}:/home/hitman/sites/downloads/Addon/non-config/BiTGApps-addon-deskclock-${COMMONADDONRELEASE}_signed.zip"
        $TARGET_VARIANT_DIALER && rsync -a -v out/common/BiTGApps-addon-dialer-${COMMONADDONRELEASE}_signed.zip "${user}@${host}:/home/hitman/sites/downloads/Addon/non-config/BiTGApps-addon-dialer-${COMMONADDONRELEASE}_signed.zip"
        $TARGET_VARIANT_DPS && rsync -a -v out/common/BiTGApps-addon-dps-${COMMONADDONRELEASE}_signed.zip "${user}@${host}:/home/hitman/sites/downloads/Addon/non-config/BiTGApps-addon-dps-${COMMONADDONRELEASE}_signed.zip"
        $TARGET_VARIANT_GBOARD && rsync -a -v out/common/BiTGApps-addon-gboard-${COMMONADDONRELEASE}_signed.zip "${user}@${host}:/home/hitman/sites/downloads/Addon/non-config/BiTGApps-addon-gboard-${COMMONADDONRELEASE}_signed.zip"
        $TARGET_VARIANT_GEARHEAD && rsync -a -v out/common/BiTGApps-addon-gearhead-${COMMONADDONRELEASE}_signed.zip "${user}@${host}:/home/hitman/sites/downloads/Addon/non-config/BiTGApps-addon-gearhead-${COMMONADDONRELEASE}_signed.zip"
        $TARGET_VARIANT_LAUNCHER && rsync -a -v out/common/BiTGApps-addon-launcher-${COMMONADDONRELEASE}_signed.zip "${user}@${host}:/home/hitman/sites/downloads/Addon/non-config/BiTGApps-addon-launcher-${COMMONADDONRELEASE}_signed.zip"
        $TARGET_VARIANT_MAPS && rsync -a -v out/common/BiTGApps-addon-maps-${COMMONADDONRELEASE}_signed.zip "${user}@${host}:/home/hitman/sites/downloads/Addon/non-config/BiTGApps-addon-maps-${COMMONADDONRELEASE}_signed.zip"
        $TARGET_VARIANT_MARKUP && rsync -a -v out/common/BiTGApps-addon-markup-${COMMONADDONRELEASE}_signed.zip "${user}@${host}:/home/hitman/sites/downloads/Addon/non-config/BiTGApps-addon-markup-${COMMONADDONRELEASE}_signed.zip"
        $TARGET_VARIANT_MESSAGES && rsync -a -v out/common/BiTGApps-addon-messages-${COMMONADDONRELEASE}_signed.zip "${user}@${host}:/home/hitman/sites/downloads/Addon/non-config/BiTGApps-addon-messages-${COMMONADDONRELEASE}_signed.zip"
        $TARGET_VARIANT_PHOTOS && rsync -a -v out/common/BiTGApps-addon-photos-${COMMONADDONRELEASE}_signed.zip "${user}@${host}:/home/hitman/sites/downloads/Addon/non-config/BiTGApps-addon-photos-${COMMONADDONRELEASE}_signed.zip"
        $TARGET_VARIANT_SOUNDPICKER && rsync -a -v out/common/BiTGApps-addon-soundpicker-${COMMONADDONRELEASE}_signed.zip "${user}@${host}:/home/hitman/sites/downloads/Addon/non-config/BiTGApps-addon-soundpicker-${COMMONADDONRELEASE}_signed.zip"
        $TARGET_VARIANT_TTS && rsync -a -v out/common/BiTGApps-addon-tts-${COMMONADDONRELEASE}_signed.zip "${user}@${host}:/home/hitman/sites/downloads/Addon/non-config/BiTGApps-addon-tts-${COMMONADDONRELEASE}_signed.zip"
        $TARGET_VARIANT_VANCED_MICROG && rsync -a -v out/common/BiTGApps-addon-vanced-microg-${COMMONADDONRELEASE}_signed.zip "${user}@${host}:/home/hitman/sites/downloads/Addon/non-config/BiTGApps-addon-vanced-microg-${COMMONADDONRELEASE}_signed.zip"
        $TARGET_VARIANT_VANCED_ROOT && rsync -a -v out/common/BiTGApps-addon-vanced-root-${COMMONADDONRELEASE}_signed.zip "${user}@${host}:/home/hitman/sites/downloads/Addon/non-config/BiTGApps-addon-vanced-root-${COMMONADDONRELEASE}_signed.zip"
        $TARGET_VARIANT_VANCED_NONROOT && rsync -a -v out/common/BiTGApps-addon-vanced-nonroot-${COMMONADDONRELEASE}_signed.zip "${user}@${host}:/home/hitman/sites/downloads/Addon/non-config/BiTGApps-addon-vanced-nonroot-${COMMONADDONRELEASE}_signed.zip"
        $TARGET_VARIANT_WELLBEING && rsync -a -v out/common/BiTGApps-addon-wellbeing-${COMMONADDONRELEASE}_signed.zip "${user}@${host}:/home/hitman/sites/downloads/Addon/non-config/BiTGApps-addon-wellbeing-${COMMONADDONRELEASE}_signed.zip"
      fi
    fi
    if [ "$SERVER" == "alpha" ]; then
      if [ -n "$COMMONADDONRELEASE" ]; then
        $TARGET_VARIANT_ASSISTANT && rsync -a -v out/common/BiTGApps-addon-assistant-${COMMONADDONRELEASE}_signed.zip "${user}@${host}:/home/hitman/sites/alpha/${REVISION}/Addon/non-config/BiTGApps-addon-assistant-${COMMONADDONRELEASE}_signed.zip"
        $TARGET_VARIANT_BROMITE && rsync -a -v out/common/BiTGApps-addon-bromite-${COMMONADDONRELEASE}_signed.zip "${user}@${host}:/home/hitman/sites/alpha/${REVISION}/Addon/non-config/BiTGApps-addon-bromite-${COMMONADDONRELEASE}_signed.zip"
        $TARGET_VARIANT_CALCULATOR && rsync -a -v out/common/BiTGApps-addon-calculator-${COMMONADDONRELEASE}_signed.zip "${user}@${host}:/home/hitman/sites/alpha/${REVISION}/Addon/non-config/BiTGApps-addon-calculator-${COMMONADDONRELEASE}_signed.zip"
        $TARGET_VARIANT_CALENDAR && rsync -a -v out/common/BiTGApps-addon-calendar-${COMMONADDONRELEASE}_signed.zip "${user}@${host}:/home/hitman/sites/alpha/${REVISION}/Addon/non-config/BiTGApps-addon-calendar-${COMMONADDONRELEASE}_signed.zip"
        $TARGET_VARIANT_CHROME && rsync -a -v out/common/BiTGApps-addon-chrome-${COMMONADDONRELEASE}_signed.zip "${user}@${host}:/home/hitman/sites/alpha/${REVISION}/Addon/non-config/BiTGApps-addon-chrome-${COMMONADDONRELEASE}_signed.zip"
        $TARGET_VARIANT_CONTACTS && rsync -a -v out/common/BiTGApps-addon-contacts-${COMMONADDONRELEASE}_signed.zip "${user}@${host}:/home/hitman/sites/alpha/${REVISION}/Addon/non-config/BiTGApps-addon-contacts-${COMMONADDONRELEASE}_signed.zip"
        $TARGET_VARIANT_DESKCLOCK && rsync -a -v out/common/BiTGApps-addon-deskclock-${COMMONADDONRELEASE}_signed.zip "${user}@${host}:/home/hitman/sites/alpha/${REVISION}/Addon/non-config/BiTGApps-addon-deskclock-${COMMONADDONRELEASE}_signed.zip"
        $TARGET_VARIANT_DIALER && rsync -a -v out/common/BiTGApps-addon-dialer-${COMMONADDONRELEASE}_signed.zip "${user}@${host}:/home/hitman/sites/alpha/${REVISION}/Addon/non-config/BiTGApps-addon-dialer-${COMMONADDONRELEASE}_signed.zip"
        $TARGET_VARIANT_DPS && rsync -a -v out/common/BiTGApps-addon-dps-${COMMONADDONRELEASE}_signed.zip "${user}@${host}:/home/hitman/sites/alpha/${REVISION}/Addon/non-config/BiTGApps-addon-dps-${COMMONADDONRELEASE}_signed.zip"
        $TARGET_VARIANT_GBOARD && rsync -a -v out/common/BiTGApps-addon-gboard-${COMMONADDONRELEASE}_signed.zip "${user}@${host}:/home/hitman/sites/alpha/${REVISION}/Addon/non-config/BiTGApps-addon-gboard-${COMMONADDONRELEASE}_signed.zip"
        $TARGET_VARIANT_GEARHEAD && rsync -a -v out/common/BiTGApps-addon-gearhead-${COMMONADDONRELEASE}_signed.zip "${user}@${host}:/home/hitman/sites/alpha/${REVISION}/Addon/non-config/BiTGApps-addon-gearhead-${COMMONADDONRELEASE}_signed.zip"
        $TARGET_VARIANT_LAUNCHER && rsync -a -v out/common/BiTGApps-addon-launcher-${COMMONADDONRELEASE}_signed.zip "${user}@${host}:/home/hitman/sites/alpha/${REVISION}/Addon/non-config/BiTGApps-addon-launcher-${COMMONADDONRELEASE}_signed.zip"
        $TARGET_VARIANT_MAPS && rsync -a -v out/common/BiTGApps-addon-maps-${COMMONADDONRELEASE}_signed.zip "${user}@${host}:/home/hitman/sites/alpha/${REVISION}/Addon/non-config/BiTGApps-addon-maps-${COMMONADDONRELEASE}_signed.zip"
        $TARGET_VARIANT_MARKUP && rsync -a -v out/common/BiTGApps-addon-markup-${COMMONADDONRELEASE}_signed.zip "${user}@${host}:/home/hitman/sites/alpha/${REVISION}/Addon/non-config/BiTGApps-addon-markup-${COMMONADDONRELEASE}_signed.zip"
        $TARGET_VARIANT_MESSAGES && rsync -a -v out/common/BiTGApps-addon-messages-${COMMONADDONRELEASE}_signed.zip "${user}@${host}:/home/hitman/sites/alpha/${REVISION}/Addon/non-config/BiTGApps-addon-messages-${COMMONADDONRELEASE}_signed.zip"
        $TARGET_VARIANT_PHOTOS && rsync -a -v out/common/BiTGApps-addon-photos-${COMMONADDONRELEASE}_signed.zip "${user}@${host}:/home/hitman/sites/alpha/${REVISION}/Addon/non-config/BiTGApps-addon-photos-${COMMONADDONRELEASE}_signed.zip"
        $TARGET_VARIANT_SOUNDPICKER && rsync -a -v out/common/BiTGApps-addon-soundpicker-${COMMONADDONRELEASE}_signed.zip "${user}@${host}:/home/hitman/sites/alpha/${REVISION}/Addon/non-config/BiTGApps-addon-soundpicker-${COMMONADDONRELEASE}_signed.zip"
        $TARGET_VARIANT_TTS && rsync -a -v out/common/BiTGApps-addon-tts-${COMMONADDONRELEASE}_signed.zip "${user}@${host}:/home/hitman/sites/alpha/${REVISION}/Addon/non-config/BiTGApps-addon-tts-${COMMONADDONRELEASE}_signed.zip"
        $TARGET_VARIANT_VANCED_MICROG && rsync -a -v out/common/BiTGApps-addon-vanced-microg-${COMMONADDONRELEASE}_signed.zip "${user}@${host}:/home/hitman/sites/alpha/${REVISION}/Addon/non-config/BiTGApps-addon-vanced-microg-${COMMONADDONRELEASE}_signed.zip"
        $TARGET_VARIANT_VANCED_ROOT && rsync -a -v out/common/BiTGApps-addon-vanced-root-${COMMONADDONRELEASE}_signed.zip "${user}@${host}:/home/hitman/sites/alpha/${REVISION}/Addon/non-config/BiTGApps-addon-vanced-root-${COMMONADDONRELEASE}_signed.zip"
        $TARGET_VARIANT_VANCED_NONROOT && rsync -a -v out/common/BiTGApps-addon-vanced-nonroot-${COMMONADDONRELEASE}_signed.zip "${user}@${host}:/home/hitman/sites/alpha/${REVISION}/Addon/non-config/BiTGApps-addon-vanced-nonroot-${COMMONADDONRELEASE}_signed.zip"
        $TARGET_VARIANT_WELLBEING && rsync -a -v out/common/BiTGApps-addon-wellbeing-${COMMONADDONRELEASE}_signed.zip "${user}@${host}:/home/hitman/sites/alpha/${REVISION}/Addon/non-config/BiTGApps-addon-wellbeing-${COMMONADDONRELEASE}_signed.zip"
      fi
    fi
    if [ "$SERVER" == "backup" ]; then
      if [ -n "$COMMONADDONRELEASE" ]; then
        $TARGET_VARIANT_ASSISTANT && rsync -a -v out/common/BiTGApps-addon-assistant-${COMMONADDONRELEASE}_signed.zip "${user}@${host}:/home/hitman/sites/backup/${REVISION}/Addon/non-config/BiTGApps-addon-assistant-${COMMONADDONRELEASE}_signed.zip"
        $TARGET_VARIANT_BROMITE && rsync -a -v out/common/BiTGApps-addon-bromite-${COMMONADDONRELEASE}_signed.zip "${user}@${host}:/home/hitman/sites/backup/${REVISION}/Addon/non-config/BiTGApps-addon-bromite-${COMMONADDONRELEASE}_signed.zip"
        $TARGET_VARIANT_CALCULATOR && rsync -a -v out/common/BiTGApps-addon-calculator-${COMMONADDONRELEASE}_signed.zip "${user}@${host}:/home/hitman/sites/backup/${REVISION}/Addon/non-config/BiTGApps-addon-calculator-${COMMONADDONRELEASE}_signed.zip"
        $TARGET_VARIANT_CALENDAR && rsync -a -v out/common/BiTGApps-addon-calendar-${COMMONADDONRELEASE}_signed.zip "${user}@${host}:/home/hitman/sites/backup/${REVISION}/Addon/non-config/BiTGApps-addon-calendar-${COMMONADDONRELEASE}_signed.zip"
        $TARGET_VARIANT_CHROME && rsync -a -v out/common/BiTGApps-addon-chrome-${COMMONADDONRELEASE}_signed.zip "${user}@${host}:/home/hitman/sites/backup/${REVISION}/Addon/non-config/BiTGApps-addon-chrome-${COMMONADDONRELEASE}_signed.zip"
        $TARGET_VARIANT_CONTACTS && rsync -a -v out/common/BiTGApps-addon-contacts-${COMMONADDONRELEASE}_signed.zip "${user}@${host}:/home/hitman/sites/backup/${REVISION}/Addon/non-config/BiTGApps-addon-contacts-${COMMONADDONRELEASE}_signed.zip"
        $TARGET_VARIANT_DESKCLOCK && rsync -a -v out/common/BiTGApps-addon-deskclock-${COMMONADDONRELEASE}_signed.zip "${user}@${host}:/home/hitman/sites/backup/${REVISION}/Addon/non-config/BiTGApps-addon-deskclock-${COMMONADDONRELEASE}_signed.zip"
        $TARGET_VARIANT_DIALER && rsync -a -v out/common/BiTGApps-addon-dialer-${COMMONADDONRELEASE}_signed.zip "${user}@${host}:/home/hitman/sites/backup/${REVISION}/Addon/non-config/BiTGApps-addon-dialer-${COMMONADDONRELEASE}_signed.zip"
        $TARGET_VARIANT_DPS && rsync -a -v out/common/BiTGApps-addon-dps-${COMMONADDONRELEASE}_signed.zip "${user}@${host}:/home/hitman/sites/backup/${REVISION}/Addon/non-config/BiTGApps-addon-dps-${COMMONADDONRELEASE}_signed.zip"
        $TARGET_VARIANT_GBOARD && rsync -a -v out/common/BiTGApps-addon-gboard-${COMMONADDONRELEASE}_signed.zip "${user}@${host}:/home/hitman/sites/backup/${REVISION}/Addon/non-config/BiTGApps-addon-gboard-${COMMONADDONRELEASE}_signed.zip"
        $TARGET_VARIANT_GEARHEAD && rsync -a -v out/common/BiTGApps-addon-gearhead-${COMMONADDONRELEASE}_signed.zip "${user}@${host}:/home/hitman/sites/backup/${REVISION}/Addon/non-config/BiTGApps-addon-gearhead-${COMMONADDONRELEASE}_signed.zip"
        $TARGET_VARIANT_LAUNCHER && rsync -a -v out/common/BiTGApps-addon-launcher-${COMMONADDONRELEASE}_signed.zip "${user}@${host}:/home/hitman/sites/backup/${REVISION}/Addon/non-config/BiTGApps-addon-launcher-${COMMONADDONRELEASE}_signed.zip"
        $TARGET_VARIANT_MAPS && rsync -a -v out/common/BiTGApps-addon-maps-${COMMONADDONRELEASE}_signed.zip "${user}@${host}:/home/hitman/sites/backup/${REVISION}/Addon/non-config/BiTGApps-addon-maps-${COMMONADDONRELEASE}_signed.zip"
        $TARGET_VARIANT_MARKUP && rsync -a -v out/common/BiTGApps-addon-markup-${COMMONADDONRELEASE}_signed.zip "${user}@${host}:/home/hitman/sites/backup/${REVISION}/Addon/non-config/BiTGApps-addon-markup-${COMMONADDONRELEASE}_signed.zip"
        $TARGET_VARIANT_MESSAGES && rsync -a -v out/common/BiTGApps-addon-messages-${COMMONADDONRELEASE}_signed.zip "${user}@${host}:/home/hitman/sites/backup/${REVISION}/Addon/non-config/BiTGApps-addon-messages-${COMMONADDONRELEASE}_signed.zip"
        $TARGET_VARIANT_PHOTOS && rsync -a -v out/common/BiTGApps-addon-photos-${COMMONADDONRELEASE}_signed.zip "${user}@${host}:/home/hitman/sites/backup/${REVISION}/Addon/non-config/BiTGApps-addon-photos-${COMMONADDONRELEASE}_signed.zip"
        $TARGET_VARIANT_SOUNDPICKER && rsync -a -v out/common/BiTGApps-addon-soundpicker-${COMMONADDONRELEASE}_signed.zip "${user}@${host}:/home/hitman/sites/backup/${REVISION}/Addon/non-config/BiTGApps-addon-soundpicker-${COMMONADDONRELEASE}_signed.zip"
        $TARGET_VARIANT_TTS && rsync -a -v out/common/BiTGApps-addon-tts-${COMMONADDONRELEASE}_signed.zip "${user}@${host}:/home/hitman/sites/backup/${REVISION}/Addon/non-config/BiTGApps-addon-tts-${COMMONADDONRELEASE}_signed.zip"
        $TARGET_VARIANT_VANCED_MICROG && rsync -a -v out/common/BiTGApps-addon-vanced-microg-${COMMONADDONRELEASE}_signed.zip "${user}@${host}:/home/hitman/sites/backup/${REVISION}/Addon/non-config/BiTGApps-addon-vanced-microg-${COMMONADDONRELEASE}_signed.zip"
        $TARGET_VARIANT_VANCED_ROOT && rsync -a -v out/common/BiTGApps-addon-vanced-root-${COMMONADDONRELEASE}_signed.zip "${user}@${host}:/home/hitman/sites/backup/${REVISION}/Addon/non-config/BiTGApps-addon-vanced-root-${COMMONADDONRELEASE}_signed.zip"
        $TARGET_VARIANT_VANCED_NONROOT && rsync -a -v out/common/BiTGApps-addon-vanced-nonroot-${COMMONADDONRELEASE}_signed.zip "${user}@${host}:/home/hitman/sites/backup/${REVISION}/Addon/non-config/BiTGApps-addon-vanced-nonroot-${COMMONADDONRELEASE}_signed.zip"
        $TARGET_VARIANT_WELLBEING && rsync -a -v out/common/BiTGApps-addon-wellbeing-${COMMONADDONRELEASE}_signed.zip "${user}@${host}:/home/hitman/sites/backup/${REVISION}/Addon/non-config/BiTGApps-addon-wellbeing-${COMMONADDONRELEASE}_signed.zip"
      fi
    fi
  fi
}

# Execute functions
set_credentials
check_credentials
set_revision
arm_sources
arm64_sources
common_sources
