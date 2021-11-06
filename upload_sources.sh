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
export ALL="$1"

# Server credentials
set_credentials() {
  if [ "$CREDENTIALS" == "creds" ]; then
    if [ "$SERVER" == "ga" ]; then
      read -p "Enter user: " user
      read -p "Enter pass: " pass
      read -p "Enter host: " host
    else
      read -p "Enter user: " user
      read -p "Enter host: " host
      read -p "Enter revs: " revs
    fi
  fi
  # Export credentials in the global environment
  if [ "$SERVER" == "ga" ]; then
    export user="$user"; export pass="$pass"; export host="$host"
  else
    export user="$user"; export host="$host"; export revs="$revs";
  fi
}

check_credentials() {
  if [ "$SERVER" == "ga" ]; then
    if { [ ! -n "$user" ] && [ ! -n "$pass" ] && [ ! -n "$host" ]; }; then
      echo "! No credentials found. Aborting..."
      exit 1
    fi
  else
    if { [ ! -n "$user" ] && [ ! -n "$host" ]; }; then
      echo "! No credentials found. Aborting..."
      exit 1
    fi
  fi
  if [ "$SERVER" == "alpha" ] || [ "$SERVER" == "backup" ]; then
    if [ ! -n "$revs" ]; then echo "! No revision found. Aborting..."; exit 1; fi
  fi
}

# ARMEABI Sources
arm_sources() {
  if [ "$ARMEABI" == "arm" ] || [ "$ALL" == "all" ]; then
    if [ "$SERVER" == "ga" ]; then
      if [ -n "$COMMONGAPPSRELEASE" ]; then
        $TARGET_API_31 && curl -T out/GApps/arm/BiTGApps-arm-12.0.0-${COMMONGAPPSRELEASE}_signed.zip "ftp://${user}:${pass}@${host}/GApps/arm/S/BiTGApps-arm-12.0.0-${COMMONGAPPSRELEASE}_signed.zip"
        $TARGET_API_30 && curl -T out/GApps/arm/BiTGApps-arm-11.0.0-${COMMONGAPPSRELEASE}_signed.zip "ftp://${user}:${pass}@${host}/GApps/arm/R/BiTGApps-arm-11.0.0-${COMMONGAPPSRELEASE}_signed.zip"
        $TARGET_API_29 && curl -T out/GApps/arm/BiTGApps-arm-10.0.0-${COMMONGAPPSRELEASE}_signed.zip "ftp://${user}:${pass}@${host}/GApps/arm/Q/BiTGApps-arm-10.0.0-${COMMONGAPPSRELEASE}_signed.zip"
        $TARGET_API_28 && curl -T out/GApps/arm/BiTGApps-arm-9.0.0-${COMMONGAPPSRELEASE}_signed.zip "ftp://${user}:${pass}@${host}/GApps/arm/Pie/BiTGApps-arm-9.0.0-${COMMONGAPPSRELEASE}_signed.zip"
        $TARGET_API_27 && curl -T out/GApps/arm/BiTGApps-arm-8.1.0-${COMMONGAPPSRELEASE}_signed.zip "ftp://${user}:${pass}@${host}/GApps/arm/Oreo/BiTGApps-arm-8.1.0-${COMMONGAPPSRELEASE}_signed.zip"
        $TARGET_API_26 && curl -T out/GApps/arm/BiTGApps-arm-8.0.0-${COMMONGAPPSRELEASE}_signed.zip "ftp://${user}:${pass}@${host}/GApps/arm/Oreo/BiTGApps-arm-8.0.0-${COMMONGAPPSRELEASE}_signed.zip"
        $TARGET_API_25 && curl -T out/GApps/arm/BiTGApps-arm-7.1.2-${COMMONGAPPSRELEASE}_signed.zip "ftp://${user}:${pass}@${host}/GApps/arm/Nougat/BiTGApps-arm-7.1.2-${COMMONGAPPSRELEASE}_signed.zip"
        $TARGET_API_25 && curl -T out/GApps/arm/BiTGApps-arm-7.1.1-${COMMONGAPPSRELEASE}_signed.zip "ftp://${user}:${pass}@${host}/GApps/arm/Nougat/BiTGApps-arm-7.1.1-${COMMONGAPPSRELEASE}_signed.zip"
      fi
      if [ -n "$COMMONGAPPSRELEASE" ]; then
        $MICROG_API_31 && curl -T out/MicroG/arm/MicroG-arm-12.0.0-${COMMONGAPPSRELEASE}_signed.zip "ftp://${user}:${pass}@${host}/MicroG/arm/S/MicroG-arm-12.0.0-${COMMONGAPPSRELEASE}_signed.zip"
        $MICROG_API_30 && curl -T out/MicroG/arm/MicroG-arm-11.0.0-${COMMONGAPPSRELEASE}_signed.zip "ftp://${user}:${pass}@${host}/MicroG/arm/R/MicroG-arm-11.0.0-${COMMONGAPPSRELEASE}_signed.zip"
        $MICROG_API_29 && curl -T out/MicroG/arm/MicroG-arm-10.0.0-${COMMONGAPPSRELEASE}_signed.zip "ftp://${user}:${pass}@${host}/MicroG/arm/Q/MicroG-arm-10.0.0-${COMMONGAPPSRELEASE}_signed.zip"
        $MICROG_API_28 && curl -T out/MicroG/arm/MicroG-arm-9.0.0-${COMMONGAPPSRELEASE}_signed.zip "ftp://${user}:${pass}@${host}/MicroG/arm/Pie/MicroG-arm-9.0.0-${COMMONGAPPSRELEASE}_signed.zip"
        $MICROG_API_27 && curl -T out/MicroG/arm/MicroG-arm-8.1.0-${COMMONGAPPSRELEASE}_signed.zip "ftp://${user}:${pass}@${host}/MicroG/arm/Oreo/MicroG-arm-8.1.0-${COMMONGAPPSRELEASE}_signed.zip"
        $MICROG_API_26 && curl -T out/MicroG/arm/MicroG-arm-8.0.0-${COMMONGAPPSRELEASE}_signed.zip "ftp://${user}:${pass}@${host}/MicroG/arm/Oreo/MicroG-arm-8.0.0-${COMMONGAPPSRELEASE}_signed.zip"
        $MICROG_API_25 && curl -T out/MicroG/arm/MicroG-arm-7.1.2-${COMMONGAPPSRELEASE}_signed.zip "ftp://${user}:${pass}@${host}/MicroG/arm/Nougat/MicroG-arm-7.1.2-${COMMONGAPPSRELEASE}_signed.zip"
        $MICROG_API_25 && curl -T out/MicroG/arm/MicroG-arm-7.1.1-${COMMONGAPPSRELEASE}_signed.zip "ftp://${user}:${pass}@${host}/MicroG/arm/Nougat/MicroG-arm-7.1.1-${COMMONGAPPSRELEASE}_signed.zip"
      fi
      if [ -n "$COMMONADDONRELEASE" ]; then
        $TARGET_PLATFORM_ARM && curl -T out/Addon/arm/BiTGApps-addon-arm-${COMMONADDONRELEASE}_signed.zip "ftp://${user}:${pass}@${host}/Addon/config/arm/BiTGApps-addon-arm-${COMMONADDONRELEASE}_signed.zip"
      fi
    fi
    if [ "$SERVER" == "dh" ]; then
      if [ -n "$COMMONGAPPSRELEASE" ]; then
        $TARGET_API_31 && rsync -a -v out/GApps/arm/BiTGApps-arm-12.0.0-${COMMONGAPPSRELEASE}_signed.zip "${user}@${host}:/home/bitgapps/bitgapps.com/downloads/GApps/arm/S/BiTGApps-arm-12.0.0-${COMMONGAPPSRELEASE}_signed.zip"
        $TARGET_API_30 && rsync -a -v out/GApps/arm/BiTGApps-arm-11.0.0-${COMMONGAPPSRELEASE}_signed.zip "${user}@${host}:/home/bitgapps/bitgapps.com/downloads/GApps/arm/R/BiTGApps-arm-11.0.0-${COMMONGAPPSRELEASE}_signed.zip"
        $TARGET_API_29 && rsync -a -v out/GApps/arm/BiTGApps-arm-10.0.0-${COMMONGAPPSRELEASE}_signed.zip "${user}@${host}:/home/bitgapps/bitgapps.com/downloads/GApps/arm/Q/BiTGApps-arm-10.0.0-${COMMONGAPPSRELEASE}_signed.zip"
        $TARGET_API_28 && rsync -a -v out/GApps/arm/BiTGApps-arm-9.0.0-${COMMONGAPPSRELEASE}_signed.zip "${user}@${host}:/home/bitgapps/bitgapps.com/downloads/GApps/arm/Pie/BiTGApps-arm-9.0.0-${COMMONGAPPSRELEASE}_signed.zip"
        $TARGET_API_27 && rsync -a -v out/GApps/arm/BiTGApps-arm-8.1.0-${COMMONGAPPSRELEASE}_signed.zip "${user}@${host}:/home/bitgapps/bitgapps.com/downloads/GApps/arm/Oreo/BiTGApps-arm-8.1.0-${COMMONGAPPSRELEASE}_signed.zip"
        $TARGET_API_26 && rsync -a -v out/GApps/arm/BiTGApps-arm-8.0.0-${COMMONGAPPSRELEASE}_signed.zip "${user}@${host}:/home/bitgapps/bitgapps.com/downloads/GApps/arm/Oreo/BiTGApps-arm-8.0.0-${COMMONGAPPSRELEASE}_signed.zip"
        $TARGET_API_25 && rsync -a -v out/GApps/arm/BiTGApps-arm-7.1.2-${COMMONGAPPSRELEASE}_signed.zip "${user}@${host}:/home/bitgapps/bitgapps.com/downloads/GApps/arm/Nougat/BiTGApps-arm-7.1.2-${COMMONGAPPSRELEASE}_signed.zip"
        $TARGET_API_25 && rsync -a -v out/GApps/arm/BiTGApps-arm-7.1.1-${COMMONGAPPSRELEASE}_signed.zip "${user}@${host}:/home/bitgapps/bitgapps.com/downloads/GApps/arm/Nougat/BiTGApps-arm-7.1.1-${COMMONGAPPSRELEASE}_signed.zip"
      fi
      if [ -n "$COMMONGAPPSRELEASE" ]; then
        $MICROG_API_31 && rsync -a -v out/MicroG/arm/MicroG-arm-12.0.0-${COMMONGAPPSRELEASE}_signed.zip "${user}@${host}:/home/bitgapps/bitgapps.com/downloads/MicroG/arm/S/MicroG-arm-12.0.0-${COMMONGAPPSRELEASE}_signed.zip"
        $MICROG_API_30 && rsync -a -v out/MicroG/arm/MicroG-arm-11.0.0-${COMMONGAPPSRELEASE}_signed.zip "${user}@${host}:/home/bitgapps/bitgapps.com/downloads/MicroG/arm/R/MicroG-arm-11.0.0-${COMMONGAPPSRELEASE}_signed.zip"
        $MICROG_API_29 && rsync -a -v out/MicroG/arm/MicroG-arm-10.0.0-${COMMONGAPPSRELEASE}_signed.zip "${user}@${host}:/home/bitgapps/bitgapps.com/downloads/MicroG/arm/Q/MicroG-arm-10.0.0-${COMMONGAPPSRELEASE}_signed.zip"
        $MICROG_API_28 && rsync -a -v out/MicroG/arm/MicroG-arm-9.0.0-${COMMONGAPPSRELEASE}_signed.zip "${user}@${host}:/home/bitgapps/bitgapps.com/downloads/MicroG/arm/Pie/MicroG-arm-9.0.0-${COMMONGAPPSRELEASE}_signed.zip"
        $MICROG_API_27 && rsync -a -v out/MicroG/arm/MicroG-arm-8.1.0-${COMMONGAPPSRELEASE}_signed.zip "${user}@${host}:/home/bitgapps/bitgapps.com/downloads/MicroG/arm/Oreo/MicroG-arm-8.1.0-${COMMONGAPPSRELEASE}_signed.zip"
        $MICROG_API_26 && rsync -a -v out/MicroG/arm/MicroG-arm-8.0.0-${COMMONGAPPSRELEASE}_signed.zip "${user}@${host}:/home/bitgapps/bitgapps.com/downloads/MicroG/arm/Oreo/MicroG-arm-8.0.0-${COMMONGAPPSRELEASE}_signed.zip"
        $MICROG_API_25 && rsync -a -v out/MicroG/arm/MicroG-arm-7.1.2-${COMMONGAPPSRELEASE}_signed.zip "${user}@${host}:/home/bitgapps/bitgapps.com/downloads/MicroG/arm/Nougat/MicroG-arm-7.1.2-${COMMONGAPPSRELEASE}_signed.zip"
        $MICROG_API_25 && rsync -a -v out/MicroG/arm/MicroG-arm-7.1.1-${COMMONGAPPSRELEASE}_signed.zip "${user}@${host}:/home/bitgapps/bitgapps.com/downloads/MicroG/arm/Nougat/MicroG-arm-7.1.1-${COMMONGAPPSRELEASE}_signed.zip"
      fi
      if [ -n "$COMMONADDONRELEASE" ]; then
        $TARGET_PLATFORM_ARM && rsync -a -v out/Addon/arm/BiTGApps-addon-arm-${COMMONADDONRELEASE}_signed.zip "${user}@${host}:/home/bitgapps/bitgapps.com/downloads/Addon/config/arm/BiTGApps-addon-arm-${COMMONADDONRELEASE}_signed.zip"
      fi
    fi
    if [ "$SERVER" == "sps" ]; then
      if [ -n "$COMMONGAPPSRELEASE" ]; then
        $TARGET_API_31 && rsync -a -v out/GApps/arm/BiTGApps-arm-12.0.0-${COMMONGAPPSRELEASE}_signed.zip "${user}@${host}:/home/hitman/sites/downloads/GApps/arm/S/BiTGApps-arm-12.0.0-${COMMONGAPPSRELEASE}_signed.zip"
        $TARGET_API_30 && rsync -a -v out/GApps/arm/BiTGApps-arm-11.0.0-${COMMONGAPPSRELEASE}_signed.zip "${user}@${host}:/home/hitman/sites/downloads/GApps/arm/R/BiTGApps-arm-11.0.0-${COMMONGAPPSRELEASE}_signed.zip"
        $TARGET_API_29 && rsync -a -v out/GApps/arm/BiTGApps-arm-10.0.0-${COMMONGAPPSRELEASE}_signed.zip "${user}@${host}:/home/hitman/sites/downloads/GApps/arm/Q/BiTGApps-arm-10.0.0-${COMMONGAPPSRELEASE}_signed.zip"
        $TARGET_API_28 && rsync -a -v out/GApps/arm/BiTGApps-arm-9.0.0-${COMMONGAPPSRELEASE}_signed.zip "${user}@${host}:/home/hitman/sites/downloads/GApps/arm/Pie/BiTGApps-arm-9.0.0-${COMMONGAPPSRELEASE}_signed.zip"
        $TARGET_API_27 && rsync -a -v out/GApps/arm/BiTGApps-arm-8.1.0-${COMMONGAPPSRELEASE}_signed.zip "${user}@${host}:/home/hitman/sites/downloads/GApps/arm/Oreo/BiTGApps-arm-8.1.0-${COMMONGAPPSRELEASE}_signed.zip"
        $TARGET_API_26 && rsync -a -v out/GApps/arm/BiTGApps-arm-8.0.0-${COMMONGAPPSRELEASE}_signed.zip "${user}@${host}:/home/hitman/sites/downloads/GApps/arm/Oreo/BiTGApps-arm-8.0.0-${COMMONGAPPSRELEASE}_signed.zip"
        $TARGET_API_25 && rsync -a -v out/GApps/arm/BiTGApps-arm-7.1.2-${COMMONGAPPSRELEASE}_signed.zip "${user}@${host}:/home/hitman/sites/downloads/GApps/arm/Nougat/BiTGApps-arm-7.1.2-${COMMONGAPPSRELEASE}_signed.zip"
        $TARGET_API_25 && rsync -a -v out/GApps/arm/BiTGApps-arm-7.1.1-${COMMONGAPPSRELEASE}_signed.zip "${user}@${host}:/home/hitman/sites/downloads/GApps/arm/Nougat/BiTGApps-arm-7.1.1-${COMMONGAPPSRELEASE}_signed.zip"
      fi
      if [ -n "$COMMONGAPPSRELEASE" ]; then
        $MICROG_API_31 && rsync -a -v out/MicroG/arm/MicroG-arm-12.0.0-${COMMONGAPPSRELEASE}_signed.zip "${user}@${host}:/home/hitman/sites/downloads/MicroG/arm/S/MicroG-arm-12.0.0-${COMMONGAPPSRELEASE}_signed.zip"
        $MICROG_API_30 && rsync -a -v out/MicroG/arm/MicroG-arm-11.0.0-${COMMONGAPPSRELEASE}_signed.zip "${user}@${host}:/home/hitman/sites/downloads/MicroG/arm/R/MicroG-arm-11.0.0-${COMMONGAPPSRELEASE}_signed.zip"
        $MICROG_API_29 && rsync -a -v out/MicroG/arm/MicroG-arm-10.0.0-${COMMONGAPPSRELEASE}_signed.zip "${user}@${host}:/home/hitman/sites/downloads/MicroG/arm/Q/MicroG-arm-10.0.0-${COMMONGAPPSRELEASE}_signed.zip"
        $MICROG_API_28 && rsync -a -v out/MicroG/arm/MicroG-arm-9.0.0-${COMMONGAPPSRELEASE}_signed.zip "${user}@${host}:/home/hitman/sites/downloads/MicroG/arm/Pie/MicroG-arm-9.0.0-${COMMONGAPPSRELEASE}_signed.zip"
        $MICROG_API_27 && rsync -a -v out/MicroG/arm/MicroG-arm-8.1.0-${COMMONGAPPSRELEASE}_signed.zip "${user}@${host}:/home/hitman/sites/downloads/MicroG/arm/Oreo/MicroG-arm-8.1.0-${COMMONGAPPSRELEASE}_signed.zip"
        $MICROG_API_26 && rsync -a -v out/MicroG/arm/MicroG-arm-8.0.0-${COMMONGAPPSRELEASE}_signed.zip "${user}@${host}:/home/hitman/sites/downloads/MicroG/arm/Oreo/MicroG-arm-8.0.0-${COMMONGAPPSRELEASE}_signed.zip"
        $MICROG_API_25 && rsync -a -v out/MicroG/arm/MicroG-arm-7.1.2-${COMMONGAPPSRELEASE}_signed.zip "${user}@${host}:/home/hitman/sites/downloads/MicroG/arm/Nougat/MicroG-arm-7.1.2-${COMMONGAPPSRELEASE}_signed.zip"
        $MICROG_API_25 && rsync -a -v out/MicroG/arm/MicroG-arm-7.1.1-${COMMONGAPPSRELEASE}_signed.zip "${user}@${host}:/home/hitman/sites/downloads/MicroG/arm/Nougat/MicroG-arm-7.1.1-${COMMONGAPPSRELEASE}_signed.zip"
      fi
      if [ -n "$COMMONADDONRELEASE" ]; then
        $TARGET_PLATFORM_ARM && rsync -a -v out/Addon/arm/BiTGApps-addon-arm-${COMMONADDONRELEASE}_signed.zip "${user}@${host}:/home/hitman/sites/downloads/Addon/config/arm/BiTGApps-addon-arm-${COMMONADDONRELEASE}_signed.zip"
      fi
    fi
    if [ "$SERVER" == "alpha" ]; then
      if [ -n "$COMMONGAPPSRELEASE" ]; then
        $TARGET_API_31 && rsync -a -v out/GApps/arm/BiTGApps-arm-12.0.0-${COMMONGAPPSRELEASE}_signed.zip "${user}@${host}:/home/hitman/sites/alpha/${revs}/GApps/arm/S/BiTGApps-arm-12.0.0-${COMMONGAPPSRELEASE}_signed.zip"
        $TARGET_API_30 && rsync -a -v out/GApps/arm/BiTGApps-arm-11.0.0-${COMMONGAPPSRELEASE}_signed.zip "${user}@${host}:/home/hitman/sites/alpha/${revs}/GApps/arm/R/BiTGApps-arm-11.0.0-${COMMONGAPPSRELEASE}_signed.zip"
        $TARGET_API_29 && rsync -a -v out/GApps/arm/BiTGApps-arm-10.0.0-${COMMONGAPPSRELEASE}_signed.zip "${user}@${host}:/home/hitman/sites/alpha/${revs}/GApps/arm/Q/BiTGApps-arm-10.0.0-${COMMONGAPPSRELEASE}_signed.zip"
        $TARGET_API_28 && rsync -a -v out/GApps/arm/BiTGApps-arm-9.0.0-${COMMONGAPPSRELEASE}_signed.zip "${user}@${host}:/home/hitman/sites/alpha/${revs}/GApps/arm/Pie/BiTGApps-arm-9.0.0-${COMMONGAPPSRELEASE}_signed.zip"
        $TARGET_API_27 && rsync -a -v out/GApps/arm/BiTGApps-arm-8.1.0-${COMMONGAPPSRELEASE}_signed.zip "${user}@${host}:/home/hitman/sites/alpha/${revs}/GApps/arm/Oreo/BiTGApps-arm-8.1.0-${COMMONGAPPSRELEASE}_signed.zip"
        $TARGET_API_26 && rsync -a -v out/GApps/arm/BiTGApps-arm-8.0.0-${COMMONGAPPSRELEASE}_signed.zip "${user}@${host}:/home/hitman/sites/alpha/${revs}/GApps/arm/Oreo/BiTGApps-arm-8.0.0-${COMMONGAPPSRELEASE}_signed.zip"
        $TARGET_API_25 && rsync -a -v out/GApps/arm/BiTGApps-arm-7.1.2-${COMMONGAPPSRELEASE}_signed.zip "${user}@${host}:/home/hitman/sites/alpha/${revs}/GApps/arm/Nougat/BiTGApps-arm-7.1.2-${COMMONGAPPSRELEASE}_signed.zip"
        $TARGET_API_25 && rsync -a -v out/GApps/arm/BiTGApps-arm-7.1.1-${COMMONGAPPSRELEASE}_signed.zip "${user}@${host}:/home/hitman/sites/alpha/${revs}/GApps/arm/Nougat/BiTGApps-arm-7.1.1-${COMMONGAPPSRELEASE}_signed.zip"
      fi
      if [ -n "$COMMONGAPPSRELEASE" ]; then
        $MICROG_API_31 && rsync -a -v out/MicroG/arm/MicroG-arm-12.0.0-${COMMONGAPPSRELEASE}_signed.zip "${user}@${host}:/home/hitman/sites/alpha/${revs}/MicroG/arm/S/MicroG-arm-12.0.0-${COMMONGAPPSRELEASE}_signed.zip"
        $MICROG_API_30 && rsync -a -v out/MicroG/arm/MicroG-arm-11.0.0-${COMMONGAPPSRELEASE}_signed.zip "${user}@${host}:/home/hitman/sites/alpha/${revs}/MicroG/arm/R/MicroG-arm-11.0.0-${COMMONGAPPSRELEASE}_signed.zip"
        $MICROG_API_29 && rsync -a -v out/MicroG/arm/MicroG-arm-10.0.0-${COMMONGAPPSRELEASE}_signed.zip "${user}@${host}:/home/hitman/sites/alpha/${revs}/MicroG/arm/Q/MicroG-arm-10.0.0-${COMMONGAPPSRELEASE}_signed.zip"
        $MICROG_API_28 && rsync -a -v out/MicroG/arm/MicroG-arm-9.0.0-${COMMONGAPPSRELEASE}_signed.zip "${user}@${host}:/home/hitman/sites/alpha/${revs}/MicroG/arm/Pie/MicroG-arm-9.0.0-${COMMONGAPPSRELEASE}_signed.zip"
        $MICROG_API_27 && rsync -a -v out/MicroG/arm/MicroG-arm-8.1.0-${COMMONGAPPSRELEASE}_signed.zip "${user}@${host}:/home/hitman/sites/alpha/${revs}/MicroG/arm/Oreo/MicroG-arm-8.1.0-${COMMONGAPPSRELEASE}_signed.zip"
        $MICROG_API_26 && rsync -a -v out/MicroG/arm/MicroG-arm-8.0.0-${COMMONGAPPSRELEASE}_signed.zip "${user}@${host}:/home/hitman/sites/alpha/${revs}/MicroG/arm/Oreo/MicroG-arm-8.0.0-${COMMONGAPPSRELEASE}_signed.zip"
        $MICROG_API_25 && rsync -a -v out/MicroG/arm/MicroG-arm-7.1.2-${COMMONGAPPSRELEASE}_signed.zip "${user}@${host}:/home/hitman/sites/alpha/${revs}/MicroG/arm/Nougat/MicroG-arm-7.1.2-${COMMONGAPPSRELEASE}_signed.zip"
        $MICROG_API_25 && rsync -a -v out/MicroG/arm/MicroG-arm-7.1.1-${COMMONGAPPSRELEASE}_signed.zip "${user}@${host}:/home/hitman/sites/alpha/${revs}/MicroG/arm/Nougat/MicroG-arm-7.1.1-${COMMONGAPPSRELEASE}_signed.zip"
      fi
      if [ -n "$COMMONADDONRELEASE" ]; then
        $TARGET_PLATFORM_ARM && rsync -a -v out/Addon/arm/BiTGApps-addon-arm-${COMMONADDONRELEASE}_signed.zip "${user}@${host}:/home/hitman/sites/alpha/${revs}/Addon/config/arm/BiTGApps-addon-arm-${COMMONADDONRELEASE}_signed.zip"
      fi
    fi
    if [ "$SERVER" == "backup" ]; then
      if [ -n "$COMMONGAPPSRELEASE" ]; then
        $TARGET_API_31 && rsync -a -v out/GApps/arm/BiTGApps-arm-12.0.0-${COMMONGAPPSRELEASE}_signed.zip "${user}@${host}:/home/hitman/sites/backup/${revs}/GApps/arm/S/BiTGApps-arm-12.0.0-${COMMONGAPPSRELEASE}_signed.zip"
        $TARGET_API_30 && rsync -a -v out/GApps/arm/BiTGApps-arm-11.0.0-${COMMONGAPPSRELEASE}_signed.zip "${user}@${host}:/home/hitman/sites/backup/${revs}/GApps/arm/R/BiTGApps-arm-11.0.0-${COMMONGAPPSRELEASE}_signed.zip"
        $TARGET_API_29 && rsync -a -v out/GApps/arm/BiTGApps-arm-10.0.0-${COMMONGAPPSRELEASE}_signed.zip "${user}@${host}:/home/hitman/sites/backup/${revs}/GApps/arm/Q/BiTGApps-arm-10.0.0-${COMMONGAPPSRELEASE}_signed.zip"
        $TARGET_API_28 && rsync -a -v out/GApps/arm/BiTGApps-arm-9.0.0-${COMMONGAPPSRELEASE}_signed.zip "${user}@${host}:/home/hitman/sites/backup/${revs}/GApps/arm/Pie/BiTGApps-arm-9.0.0-${COMMONGAPPSRELEASE}_signed.zip"
        $TARGET_API_27 && rsync -a -v out/GApps/arm/BiTGApps-arm-8.1.0-${COMMONGAPPSRELEASE}_signed.zip "${user}@${host}:/home/hitman/sites/backup/${revs}/GApps/arm/Oreo/BiTGApps-arm-8.1.0-${COMMONGAPPSRELEASE}_signed.zip"
        $TARGET_API_26 && rsync -a -v out/GApps/arm/BiTGApps-arm-8.0.0-${COMMONGAPPSRELEASE}_signed.zip "${user}@${host}:/home/hitman/sites/backup/${revs}/GApps/arm/Oreo/BiTGApps-arm-8.0.0-${COMMONGAPPSRELEASE}_signed.zip"
        $TARGET_API_25 && rsync -a -v out/GApps/arm/BiTGApps-arm-7.1.2-${COMMONGAPPSRELEASE}_signed.zip "${user}@${host}:/home/hitman/sites/backup/${revs}/GApps/arm/Nougat/BiTGApps-arm-7.1.2-${COMMONGAPPSRELEASE}_signed.zip"
        $TARGET_API_25 && rsync -a -v out/GApps/arm/BiTGApps-arm-7.1.1-${COMMONGAPPSRELEASE}_signed.zip "${user}@${host}:/home/hitman/sites/backup/${revs}/GApps/arm/Nougat/BiTGApps-arm-7.1.1-${COMMONGAPPSRELEASE}_signed.zip"
      fi
      if [ -n "$COMMONGAPPSRELEASE" ]; then
        $MICROG_API_31 && rsync -a -v out/MicroG/arm/MicroG-arm-12.0.0-${COMMONGAPPSRELEASE}_signed.zip "${user}@${host}:/home/hitman/sites/backup/${revs}/MicroG/arm/S/MicroG-arm-12.0.0-${COMMONGAPPSRELEASE}_signed.zip"
        $MICROG_API_30 && rsync -a -v out/MicroG/arm/MicroG-arm-11.0.0-${COMMONGAPPSRELEASE}_signed.zip "${user}@${host}:/home/hitman/sites/backup/${revs}/MicroG/arm/R/MicroG-arm-11.0.0-${COMMONGAPPSRELEASE}_signed.zip"
        $MICROG_API_29 && rsync -a -v out/MicroG/arm/MicroG-arm-10.0.0-${COMMONGAPPSRELEASE}_signed.zip "${user}@${host}:/home/hitman/sites/backup/${revs}/MicroG/arm/Q/MicroG-arm-10.0.0-${COMMONGAPPSRELEASE}_signed.zip"
        $MICROG_API_28 && rsync -a -v out/MicroG/arm/MicroG-arm-9.0.0-${COMMONGAPPSRELEASE}_signed.zip "${user}@${host}:/home/hitman/sites/backup/${revs}/MicroG/arm/Pie/MicroG-arm-9.0.0-${COMMONGAPPSRELEASE}_signed.zip"
        $MICROG_API_27 && rsync -a -v out/MicroG/arm/MicroG-arm-8.1.0-${COMMONGAPPSRELEASE}_signed.zip "${user}@${host}:/home/hitman/sites/backup/${revs}/MicroG/arm/Oreo/MicroG-arm-8.1.0-${COMMONGAPPSRELEASE}_signed.zip"
        $MICROG_API_26 && rsync -a -v out/MicroG/arm/MicroG-arm-8.0.0-${COMMONGAPPSRELEASE}_signed.zip "${user}@${host}:/home/hitman/sites/backup/${revs}/MicroG/arm/Oreo/MicroG-arm-8.0.0-${COMMONGAPPSRELEASE}_signed.zip"
        $MICROG_API_25 && rsync -a -v out/MicroG/arm/MicroG-arm-7.1.2-${COMMONGAPPSRELEASE}_signed.zip "${user}@${host}:/home/hitman/sites/backup/${revs}/MicroG/arm/Nougat/MicroG-arm-7.1.2-${COMMONGAPPSRELEASE}_signed.zip"
        $MICROG_API_25 && rsync -a -v out/MicroG/arm/MicroG-arm-7.1.1-${COMMONGAPPSRELEASE}_signed.zip "${user}@${host}:/home/hitman/sites/backup/${revs}/MicroG/arm/Nougat/MicroG-arm-7.1.1-${COMMONGAPPSRELEASE}_signed.zip"
      fi
      if [ -n "$COMMONADDONRELEASE" ]; then
        $TARGET_PLATFORM_ARM && rsync -a -v out/Addon/arm/BiTGApps-addon-arm-${COMMONADDONRELEASE}_signed.zip "${user}@${host}:/home/hitman/sites/backup/${revs}/Addon/config/arm/BiTGApps-addon-arm-${COMMONADDONRELEASE}_signed.zip"
      fi
    fi
  fi
}

# AARCH64 Sources
arm64_sources() {
  if [ "$AARCH64" == "arm64" ] || [ "$ALL" == "all" ]; then
    if [ "$SERVER" == "ga" ]; then
      if [ -n "$COMMONGAPPSRELEASE" ]; then
        $TARGET_API_31 && curl -T out/GApps/arm64/BiTGApps-arm64-12.0.0-${COMMONGAPPSRELEASE}_signed.zip "ftp://${user}:${pass}@${host}/GApps/arm64/S/BiTGApps-arm64-12.0.0-${COMMONGAPPSRELEASE}_signed.zip"
        $TARGET_API_30 && curl -T out/GApps/arm64/BiTGApps-arm64-11.0.0-${COMMONGAPPSRELEASE}_signed.zip "ftp://${user}:${pass}@${host}/GApps/arm64/R/BiTGApps-arm64-11.0.0-${COMMONGAPPSRELEASE}_signed.zip"
        $TARGET_API_29 && curl -T out/GApps/arm64/BiTGApps-arm64-10.0.0-${COMMONGAPPSRELEASE}_signed.zip "ftp://${user}:${pass}@${host}/GApps/arm64/Q/BiTGApps-arm64-10.0.0-${COMMONGAPPSRELEASE}_signed.zip"
        $TARGET_API_28 && curl -T out/GApps/arm64/BiTGApps-arm64-9.0.0-${COMMONGAPPSRELEASE}_signed.zip "ftp://${user}:${pass}@${host}/GApps/arm64/Pie/BiTGApps-arm64-9.0.0-${COMMONGAPPSRELEASE}_signed.zip"
        $TARGET_API_27 && curl -T out/GApps/arm64/BiTGApps-arm64-8.1.0-${COMMONGAPPSRELEASE}_signed.zip "ftp://${user}:${pass}@${host}/GApps/arm64/Oreo/BiTGApps-arm64-8.1.0-${COMMONGAPPSRELEASE}_signed.zip"
        $TARGET_API_26 && curl -T out/GApps/arm64/BiTGApps-arm64-8.0.0-${COMMONGAPPSRELEASE}_signed.zip "ftp://${user}:${pass}@${host}/GApps/arm64/Oreo/BiTGApps-arm64-8.0.0-${COMMONGAPPSRELEASE}_signed.zip"
        $TARGET_API_25 && curl -T out/GApps/arm64/BiTGApps-arm64-7.1.2-${COMMONGAPPSRELEASE}_signed.zip "ftp://${user}:${pass}@${host}/GApps/arm64/Nougat/BiTGApps-arm64-7.1.2-${COMMONGAPPSRELEASE}_signed.zip"
        $TARGET_API_25 && curl -T out/GApps/arm64/BiTGApps-arm64-7.1.1-${COMMONGAPPSRELEASE}_signed.zip "ftp://${user}:${pass}@${host}/GApps/arm64/Nougat/BiTGApps-arm64-7.1.1-${COMMONGAPPSRELEASE}_signed.zip"
      fi
      if [ -n "$COMMONGAPPSRELEASE" ]; then
        $MICROG_API_31 && curl -T out/MicroG/arm64/MicroG-arm64-12.0.0-${COMMONGAPPSRELEASE}_signed.zip "ftp://${user}:${pass}@${host}/MicroG/arm64/S/MicroG-arm64-12.0.0-${COMMONGAPPSRELEASE}_signed.zip"
        $MICROG_API_30 && curl -T out/MicroG/arm64/MicroG-arm64-11.0.0-${COMMONGAPPSRELEASE}_signed.zip "ftp://${user}:${pass}@${host}/MicroG/arm64/R/MicroG-arm64-11.0.0-${COMMONGAPPSRELEASE}_signed.zip"
        $MICROG_API_29 && curl -T out/MicroG/arm64/MicroG-arm64-10.0.0-${COMMONGAPPSRELEASE}_signed.zip "ftp://${user}:${pass}@${host}/MicroG/arm64/Q/MicroG-arm64-10.0.0-${COMMONGAPPSRELEASE}_signed.zip"
        $MICROG_API_28 && curl -T out/MicroG/arm64/MicroG-arm64-9.0.0-${COMMONGAPPSRELEASE}_signed.zip "ftp://${user}:${pass}@${host}/MicroG/arm64/Pie/MicroG-arm64-9.0.0-${COMMONGAPPSRELEASE}_signed.zip"
        $MICROG_API_27 && curl -T out/MicroG/arm64/MicroG-arm64-8.1.0-${COMMONGAPPSRELEASE}_signed.zip "ftp://${user}:${pass}@${host}/MicroG/arm64/Oreo/MicroG-arm64-8.1.0-${COMMONGAPPSRELEASE}_signed.zip"
        $MICROG_API_26 && curl -T out/MicroG/arm64/MicroG-arm64-8.0.0-${COMMONGAPPSRELEASE}_signed.zip "ftp://${user}:${pass}@${host}/MicroG/arm64/Oreo/MicroG-arm64-8.0.0-${COMMONGAPPSRELEASE}_signed.zip"
        $MICROG_API_25 && curl -T out/MicroG/arm64/MicroG-arm64-7.1.2-${COMMONGAPPSRELEASE}_signed.zip "ftp://${user}:${pass}@${host}/MicroG/arm64/Nougat/MicroG-arm64-7.1.2-${COMMONGAPPSRELEASE}_signed.zip"
        $MICROG_API_25 && curl -T out/MicroG/arm64/MicroG-arm64-7.1.1-${COMMONGAPPSRELEASE}_signed.zip "ftp://${user}:${pass}@${host}/MicroG/arm64/Nougat/MicroG-arm64-7.1.1-${COMMONGAPPSRELEASE}_signed.zip"
      fi
      if [ -n "$COMMONADDONRELEASE" ]; then
        $TARGET_PLATFORM_ARM64 && curl -T out/Addon/arm64/BiTGApps-addon-arm64-${COMMONADDONRELEASE}_signed.zip "ftp://${user}:${pass}@${host}/Addon/config/arm64/BiTGApps-addon-arm64-${COMMONADDONRELEASE}_signed.zip"
      fi
    fi
    if [ "$SERVER" == "dh" ]; then
      if [ -n "$COMMONGAPPSRELEASE" ]; then
        $TARGET_API_31 && rsync -a -v out/GApps/arm64/BiTGApps-arm64-12.0.0-${COMMONGAPPSRELEASE}_signed.zip "${user}@${host}:/home/bitgapps/bitgapps.com/downloads/GApps/arm64/S/BiTGApps-arm64-12.0.0-${COMMONGAPPSRELEASE}_signed.zip"
        $TARGET_API_30 && rsync -a -v out/GApps/arm64/BiTGApps-arm64-11.0.0-${COMMONGAPPSRELEASE}_signed.zip "${user}@${host}:/home/bitgapps/bitgapps.com/downloads/GApps/arm64/R/BiTGApps-arm64-11.0.0-${COMMONGAPPSRELEASE}_signed.zip"
        $TARGET_API_29 && rsync -a -v out/GApps/arm64/BiTGApps-arm64-10.0.0-${COMMONGAPPSRELEASE}_signed.zip "${user}@${host}:/home/bitgapps/bitgapps.com/downloads/GApps/arm64/Q/BiTGApps-arm64-10.0.0-${COMMONGAPPSRELEASE}_signed.zip"
        $TARGET_API_28 && rsync -a -v out/GApps/arm64/BiTGApps-arm64-9.0.0-${COMMONGAPPSRELEASE}_signed.zip "${user}@${host}:/home/bitgapps/bitgapps.com/downloads/GApps/arm64/Pie/BiTGApps-arm64-9.0.0-${COMMONGAPPSRELEASE}_signed.zip"
        $TARGET_API_27 && rsync -a -v out/GApps/arm64/BiTGApps-arm64-8.1.0-${COMMONGAPPSRELEASE}_signed.zip "${user}@${host}:/home/bitgapps/bitgapps.com/downloads/GApps/arm64/Oreo/BiTGApps-arm64-8.1.0-${COMMONGAPPSRELEASE}_signed.zip"
        $TARGET_API_26 && rsync -a -v out/GApps/arm64/BiTGApps-arm64-8.0.0-${COMMONGAPPSRELEASE}_signed.zip "${user}@${host}:/home/bitgapps/bitgapps.com/downloads/GApps/arm64/Oreo/BiTGApps-arm64-8.0.0-${COMMONGAPPSRELEASE}_signed.zip"
        $TARGET_API_25 && rsync -a -v out/GApps/arm64/BiTGApps-arm64-7.1.2-${COMMONGAPPSRELEASE}_signed.zip "${user}@${host}:/home/bitgapps/bitgapps.com/downloads/GApps/arm64/Nougat/BiTGApps-arm64-7.1.2-${COMMONGAPPSRELEASE}_signed.zip"
        $TARGET_API_25 && rsync -a -v out/GApps/arm64/BiTGApps-arm64-7.1.1-${COMMONGAPPSRELEASE}_signed.zip "${user}@${host}:/home/bitgapps/bitgapps.com/downloads/GApps/arm64/Nougat/BiTGApps-arm64-7.1.1-${COMMONGAPPSRELEASE}_signed.zip"
      fi
      if [ -n "$COMMONGAPPSRELEASE" ]; then
        $MICROG_API_31 && rsync -a -v out/MicroG/arm64/MicroG-arm64-12.0.0-${COMMONGAPPSRELEASE}_signed.zip "${user}@${host}:/home/bitgapps/bitgapps.com/downloads/MicroG/arm64/S/MicroG-arm64-12.0.0-${COMMONGAPPSRELEASE}_signed.zip"
        $MICROG_API_30 && rsync -a -v out/MicroG/arm64/MicroG-arm64-11.0.0-${COMMONGAPPSRELEASE}_signed.zip "${user}@${host}:/home/bitgapps/bitgapps.com/downloads/MicroG/arm64/R/MicroG-arm64-11.0.0-${COMMONGAPPSRELEASE}_signed.zip"
        $MICROG_API_29 && rsync -a -v out/MicroG/arm64/MicroG-arm64-10.0.0-${COMMONGAPPSRELEASE}_signed.zip "${user}@${host}:/home/bitgapps/bitgapps.com/downloads/MicroG/arm64/Q/MicroG-arm64-10.0.0-${COMMONGAPPSRELEASE}_signed.zip"
        $MICROG_API_28 && rsync -a -v out/MicroG/arm64/MicroG-arm64-9.0.0-${COMMONGAPPSRELEASE}_signed.zip "${user}@${host}:/home/bitgapps/bitgapps.com/downloads/MicroG/arm64/Pie/MicroG-arm64-9.0.0-${COMMONGAPPSRELEASE}_signed.zip"
        $MICROG_API_27 && rsync -a -v out/MicroG/arm64/MicroG-arm64-8.1.0-${COMMONGAPPSRELEASE}_signed.zip "${user}@${host}:/home/bitgapps/bitgapps.com/downloads/MicroG/arm64/Oreo/MicroG-arm64-8.1.0-${COMMONGAPPSRELEASE}_signed.zip"
        $MICROG_API_26 && rsync -a -v out/MicroG/arm64/MicroG-arm64-8.0.0-${COMMONGAPPSRELEASE}_signed.zip "${user}@${host}:/home/bitgapps/bitgapps.com/downloads/MicroG/arm64/Oreo/MicroG-arm64-8.0.0-${COMMONGAPPSRELEASE}_signed.zip"
        $MICROG_API_25 && rsync -a -v out/MicroG/arm64/MicroG-arm64-7.1.2-${COMMONGAPPSRELEASE}_signed.zip "${user}@${host}:/home/bitgapps/bitgapps.com/downloads/MicroG/arm64/Nougat/MicroG-arm64-7.1.2-${COMMONGAPPSRELEASE}_signed.zip"
        $MICROG_API_25 && rsync -a -v out/MicroG/arm64/MicroG-arm64-7.1.1-${COMMONGAPPSRELEASE}_signed.zip "${user}@${host}:/home/bitgapps/bitgapps.com/downloads/MicroG/arm64/Nougat/MicroG-arm64-7.1.1-${COMMONGAPPSRELEASE}_signed.zip"
      fi
      if [ -n "$COMMONADDONRELEASE" ]; then
        $TARGET_PLATFORM_ARM64 && rsync -a -v out/Addon/arm64/BiTGApps-addon-arm64-${COMMONADDONRELEASE}_signed.zip "${user}@${host}:/home/bitgapps/bitgapps.com/downloads/Addon/config/arm64/BiTGApps-addon-arm64-${COMMONADDONRELEASE}_signed.zip"
      fi
    fi
    if [ "$SERVER" == "sps" ]; then
      if [ -n "$COMMONGAPPSRELEASE" ]; then
        $TARGET_API_31 && rsync -a -v out/GApps/arm64/BiTGApps-arm64-12.0.0-${COMMONGAPPSRELEASE}_signed.zip "${user}@${host}:/home/hitman/sites/downloads/GApps/arm64/S/BiTGApps-arm64-12.0.0-${COMMONGAPPSRELEASE}_signed.zip"
        $TARGET_API_30 && rsync -a -v out/GApps/arm64/BiTGApps-arm64-11.0.0-${COMMONGAPPSRELEASE}_signed.zip "${user}@${host}:/home/hitman/sites/downloads/GApps/arm64/R/BiTGApps-arm64-11.0.0-${COMMONGAPPSRELEASE}_signed.zip"
        $TARGET_API_29 && rsync -a -v out/GApps/arm64/BiTGApps-arm64-10.0.0-${COMMONGAPPSRELEASE}_signed.zip "${user}@${host}:/home/hitman/sites/downloads/GApps/arm64/Q/BiTGApps-arm64-10.0.0-${COMMONGAPPSRELEASE}_signed.zip"
        $TARGET_API_28 && rsync -a -v out/GApps/arm64/BiTGApps-arm64-9.0.0-${COMMONGAPPSRELEASE}_signed.zip "${user}@${host}:/home/hitman/sites/downloads/GApps/arm64/Pie/BiTGApps-arm64-9.0.0-${COMMONGAPPSRELEASE}_signed.zip"
        $TARGET_API_27 && rsync -a -v out/GApps/arm64/BiTGApps-arm64-8.1.0-${COMMONGAPPSRELEASE}_signed.zip "${user}@${host}:/home/hitman/sites/downloads/GApps/arm64/Oreo/BiTGApps-arm64-8.1.0-${COMMONGAPPSRELEASE}_signed.zip"
        $TARGET_API_26 && rsync -a -v out/GApps/arm64/BiTGApps-arm64-8.0.0-${COMMONGAPPSRELEASE}_signed.zip "${user}@${host}:/home/hitman/sites/downloads/GApps/arm64/Oreo/BiTGApps-arm64-8.0.0-${COMMONGAPPSRELEASE}_signed.zip"
        $TARGET_API_25 && rsync -a -v out/GApps/arm64/BiTGApps-arm64-7.1.2-${COMMONGAPPSRELEASE}_signed.zip "${user}@${host}:/home/hitman/sites/downloads/GApps/arm64/Nougat/BiTGApps-arm64-7.1.2-${COMMONGAPPSRELEASE}_signed.zip"
        $TARGET_API_25 && rsync -a -v out/GApps/arm64/BiTGApps-arm64-7.1.1-${COMMONGAPPSRELEASE}_signed.zip "${user}@${host}:/home/hitman/sites/downloads/GApps/arm64/Nougat/BiTGApps-arm64-7.1.1-${COMMONGAPPSRELEASE}_signed.zip"
      fi
      if [ -n "$COMMONGAPPSRELEASE" ]; then
        $MICROG_API_31 && rsync -a -v out/MicroG/arm64/MicroG-arm64-12.0.0-${COMMONGAPPSRELEASE}_signed.zip "${user}@${host}:/home/hitman/sites/downloads/MicroG/arm64/S/MicroG-arm64-12.0.0-${COMMONGAPPSRELEASE}_signed.zip"
        $MICROG_API_30 && rsync -a -v out/MicroG/arm64/MicroG-arm64-11.0.0-${COMMONGAPPSRELEASE}_signed.zip "${user}@${host}:/home/hitman/sites/downloads/MicroG/arm64/R/MicroG-arm64-11.0.0-${COMMONGAPPSRELEASE}_signed.zip"
        $MICROG_API_29 && rsync -a -v out/MicroG/arm64/MicroG-arm64-10.0.0-${COMMONGAPPSRELEASE}_signed.zip "${user}@${host}:/home/hitman/sites/downloads/MicroG/arm64/Q/MicroG-arm64-10.0.0-${COMMONGAPPSRELEASE}_signed.zip"
        $MICROG_API_28 && rsync -a -v out/MicroG/arm64/MicroG-arm64-9.0.0-${COMMONGAPPSRELEASE}_signed.zip "${user}@${host}:/home/hitman/sites/downloads/MicroG/arm64/Pie/MicroG-arm64-9.0.0-${COMMONGAPPSRELEASE}_signed.zip"
        $MICROG_API_27 && rsync -a -v out/MicroG/arm64/MicroG-arm64-8.1.0-${COMMONGAPPSRELEASE}_signed.zip "${user}@${host}:/home/hitman/sites/downloads/MicroG/arm64/Oreo/MicroG-arm64-8.1.0-${COMMONGAPPSRELEASE}_signed.zip"
        $MICROG_API_26 && rsync -a -v out/MicroG/arm64/MicroG-arm64-8.0.0-${COMMONGAPPSRELEASE}_signed.zip "${user}@${host}:/home/hitman/sites/downloads/MicroG/arm64/Oreo/MicroG-arm64-8.0.0-${COMMONGAPPSRELEASE}_signed.zip"
        $MICROG_API_25 && rsync -a -v out/MicroG/arm64/MicroG-arm64-7.1.2-${COMMONGAPPSRELEASE}_signed.zip "${user}@${host}:/home/hitman/sites/downloads/MicroG/arm64/Nougat/MicroG-arm64-7.1.2-${COMMONGAPPSRELEASE}_signed.zip"
        $MICROG_API_25 && rsync -a -v out/MicroG/arm64/MicroG-arm64-7.1.1-${COMMONGAPPSRELEASE}_signed.zip "${user}@${host}:/home/hitman/sites/downloads/MicroG/arm64/Nougat/MicroG-arm64-7.1.1-${COMMONGAPPSRELEASE}_signed.zip"
      fi
      if [ -n "$COMMONADDONRELEASE" ]; then
        $TARGET_PLATFORM_ARM64 && rsync -a -v out/Addon/arm64/BiTGApps-addon-arm64-${COMMONADDONRELEASE}_signed.zip "${user}@${host}:/home/hitman/sites/downloads/Addon/config/arm64/BiTGApps-addon-arm64-${COMMONADDONRELEASE}_signed.zip"
      fi
    fi
    if [ "$SERVER" == "alpha" ]; then
      if [ -n "$COMMONGAPPSRELEASE" ]; then
        $TARGET_API_31 && rsync -a -v out/GApps/arm64/BiTGApps-arm64-12.0.0-${COMMONGAPPSRELEASE}_signed.zip "${user}@${host}:/home/hitman/sites/alpha/${revs}/GApps/arm64/S/BiTGApps-arm64-12.0.0-${COMMONGAPPSRELEASE}_signed.zip"
        $TARGET_API_30 && rsync -a -v out/GApps/arm64/BiTGApps-arm64-11.0.0-${COMMONGAPPSRELEASE}_signed.zip "${user}@${host}:/home/hitman/sites/alpha/${revs}/GApps/arm64/R/BiTGApps-arm64-11.0.0-${COMMONGAPPSRELEASE}_signed.zip"
        $TARGET_API_29 && rsync -a -v out/GApps/arm64/BiTGApps-arm64-10.0.0-${COMMONGAPPSRELEASE}_signed.zip "${user}@${host}:/home/hitman/sites/alpha/${revs}/GApps/arm64/Q/BiTGApps-arm64-10.0.0-${COMMONGAPPSRELEASE}_signed.zip"
        $TARGET_API_28 && rsync -a -v out/GApps/arm64/BiTGApps-arm64-9.0.0-${COMMONGAPPSRELEASE}_signed.zip "${user}@${host}:/home/hitman/sites/alpha/${revs}/GApps/arm64/Pie/BiTGApps-arm64-9.0.0-${COMMONGAPPSRELEASE}_signed.zip"
        $TARGET_API_27 && rsync -a -v out/GApps/arm64/BiTGApps-arm64-8.1.0-${COMMONGAPPSRELEASE}_signed.zip "${user}@${host}:/home/hitman/sites/alpha/${revs}/GApps/arm64/Oreo/BiTGApps-arm64-8.1.0-${COMMONGAPPSRELEASE}_signed.zip"
        $TARGET_API_26 && rsync -a -v out/GApps/arm64/BiTGApps-arm64-8.0.0-${COMMONGAPPSRELEASE}_signed.zip "${user}@${host}:/home/hitman/sites/alpha/${revs}/GApps/arm64/Oreo/BiTGApps-arm64-8.0.0-${COMMONGAPPSRELEASE}_signed.zip"
        $TARGET_API_25 && rsync -a -v out/GApps/arm64/BiTGApps-arm64-7.1.2-${COMMONGAPPSRELEASE}_signed.zip "${user}@${host}:/home/hitman/sites/alpha/${revs}/GApps/arm64/Nougat/BiTGApps-arm64-7.1.2-${COMMONGAPPSRELEASE}_signed.zip"
        $TARGET_API_25 && rsync -a -v out/GApps/arm64/BiTGApps-arm64-7.1.1-${COMMONGAPPSRELEASE}_signed.zip "${user}@${host}:/home/hitman/sites/alpha/${revs}/GApps/arm64/Nougat/BiTGApps-arm64-7.1.1-${COMMONGAPPSRELEASE}_signed.zip"
      fi
      if [ -n "$COMMONGAPPSRELEASE" ]; then
        $MICROG_API_31 && rsync -a -v out/MicroG/arm64/MicroG-arm64-12.0.0-${COMMONGAPPSRELEASE}_signed.zip "${user}@${host}:/home/hitman/sites/alpha/${revs}/MicroG/arm64/S/MicroG-arm64-12.0.0-${COMMONGAPPSRELEASE}_signed.zip"
        $MICROG_API_30 && rsync -a -v out/MicroG/arm64/MicroG-arm64-11.0.0-${COMMONGAPPSRELEASE}_signed.zip "${user}@${host}:/home/hitman/sites/alpha/${revs}/MicroG/arm64/R/MicroG-arm64-11.0.0-${COMMONGAPPSRELEASE}_signed.zip"
        $MICROG_API_29 && rsync -a -v out/MicroG/arm64/MicroG-arm64-10.0.0-${COMMONGAPPSRELEASE}_signed.zip "${user}@${host}:/home/hitman/sites/alpha/${revs}/MicroG/arm64/Q/MicroG-arm64-10.0.0-${COMMONGAPPSRELEASE}_signed.zip"
        $MICROG_API_28 && rsync -a -v out/MicroG/arm64/MicroG-arm64-9.0.0-${COMMONGAPPSRELEASE}_signed.zip "${user}@${host}:/home/hitman/sites/alpha/${revs}/MicroG/arm64/Pie/MicroG-arm64-9.0.0-${COMMONGAPPSRELEASE}_signed.zip"
        $MICROG_API_27 && rsync -a -v out/MicroG/arm64/MicroG-arm64-8.1.0-${COMMONGAPPSRELEASE}_signed.zip "${user}@${host}:/home/hitman/sites/alpha/${revs}/MicroG/arm64/Oreo/MicroG-arm64-8.1.0-${COMMONGAPPSRELEASE}_signed.zip"
        $MICROG_API_26 && rsync -a -v out/MicroG/arm64/MicroG-arm64-8.0.0-${COMMONGAPPSRELEASE}_signed.zip "${user}@${host}:/home/hitman/sites/alpha/${revs}/MicroG/arm64/Oreo/MicroG-arm64-8.0.0-${COMMONGAPPSRELEASE}_signed.zip"
        $MICROG_API_25 && rsync -a -v out/MicroG/arm64/MicroG-arm64-7.1.2-${COMMONGAPPSRELEASE}_signed.zip "${user}@${host}:/home/hitman/sites/alpha/${revs}/MicroG/arm64/Nougat/MicroG-arm64-7.1.2-${COMMONGAPPSRELEASE}_signed.zip"
        $MICROG_API_25 && rsync -a -v out/MicroG/arm64/MicroG-arm64-7.1.1-${COMMONGAPPSRELEASE}_signed.zip "${user}@${host}:/home/hitman/sites/alpha/${revs}/MicroG/arm64/Nougat/MicroG-arm64-7.1.1-${COMMONGAPPSRELEASE}_signed.zip"
      fi
      if [ -n "$COMMONADDONRELEASE" ]; then
        $TARGET_PLATFORM_ARM64 && rsync -a -v out/Addon/arm64/BiTGApps-addon-arm64-${COMMONADDONRELEASE}_signed.zip "${user}@${host}:/home/hitman/sites/alpha/${revs}/Addon/config/arm64/BiTGApps-addon-arm64-${COMMONADDONRELEASE}_signed.zip"
      fi
    fi
    if [ "$SERVER" == "backup" ]; then
      if [ -n "$COMMONGAPPSRELEASE" ]; then
        $TARGET_API_31 && rsync -a -v out/GApps/arm64/BiTGApps-arm64-12.0.0-${COMMONGAPPSRELEASE}_signed.zip "${user}@${host}:/home/hitman/sites/backup/${revs}/GApps/arm64/S/BiTGApps-arm64-12.0.0-${COMMONGAPPSRELEASE}_signed.zip"
        $TARGET_API_30 && rsync -a -v out/GApps/arm64/BiTGApps-arm64-11.0.0-${COMMONGAPPSRELEASE}_signed.zip "${user}@${host}:/home/hitman/sites/backup/${revs}/GApps/arm64/R/BiTGApps-arm64-11.0.0-${COMMONGAPPSRELEASE}_signed.zip"
        $TARGET_API_29 && rsync -a -v out/GApps/arm64/BiTGApps-arm64-10.0.0-${COMMONGAPPSRELEASE}_signed.zip "${user}@${host}:/home/hitman/sites/backup/${revs}/GApps/arm64/Q/BiTGApps-arm64-10.0.0-${COMMONGAPPSRELEASE}_signed.zip"
        $TARGET_API_28 && rsync -a -v out/GApps/arm64/BiTGApps-arm64-9.0.0-${COMMONGAPPSRELEASE}_signed.zip "${user}@${host}:/home/hitman/sites/backup/${revs}/GApps/arm64/Pie/BiTGApps-arm64-9.0.0-${COMMONGAPPSRELEASE}_signed.zip"
        $TARGET_API_27 && rsync -a -v out/GApps/arm64/BiTGApps-arm64-8.1.0-${COMMONGAPPSRELEASE}_signed.zip "${user}@${host}:/home/hitman/sites/backup/${revs}/GApps/arm64/Oreo/BiTGApps-arm64-8.1.0-${COMMONGAPPSRELEASE}_signed.zip"
        $TARGET_API_26 && rsync -a -v out/GApps/arm64/BiTGApps-arm64-8.0.0-${COMMONGAPPSRELEASE}_signed.zip "${user}@${host}:/home/hitman/sites/backup/${revs}/GApps/arm64/Oreo/BiTGApps-arm64-8.0.0-${COMMONGAPPSRELEASE}_signed.zip"
        $TARGET_API_25 && rsync -a -v out/GApps/arm64/BiTGApps-arm64-7.1.2-${COMMONGAPPSRELEASE}_signed.zip "${user}@${host}:/home/hitman/sites/backup/${revs}/GApps/arm64/Nougat/BiTGApps-arm64-7.1.2-${COMMONGAPPSRELEASE}_signed.zip"
        $TARGET_API_25 && rsync -a -v out/GApps/arm64/BiTGApps-arm64-7.1.1-${COMMONGAPPSRELEASE}_signed.zip "${user}@${host}:/home/hitman/sites/backup/${revs}/GApps/arm64/Nougat/BiTGApps-arm64-7.1.1-${COMMONGAPPSRELEASE}_signed.zip"
      fi
      if [ -n "$COMMONGAPPSRELEASE" ]; then
        $MICROG_API_31 && rsync -a -v out/MicroG/arm64/MicroG-arm64-12.0.0-${COMMONGAPPSRELEASE}_signed.zip "${user}@${host}:/home/hitman/sites/backup/${revs}/MicroG/arm64/S/MicroG-arm64-12.0.0-${COMMONGAPPSRELEASE}_signed.zip"
        $MICROG_API_30 && rsync -a -v out/MicroG/arm64/MicroG-arm64-11.0.0-${COMMONGAPPSRELEASE}_signed.zip "${user}@${host}:/home/hitman/sites/backup/${revs}/MicroG/arm64/R/MicroG-arm64-11.0.0-${COMMONGAPPSRELEASE}_signed.zip"
        $MICROG_API_29 && rsync -a -v out/MicroG/arm64/MicroG-arm64-10.0.0-${COMMONGAPPSRELEASE}_signed.zip "${user}@${host}:/home/hitman/sites/backup/${revs}/MicroG/arm64/Q/MicroG-arm64-10.0.0-${COMMONGAPPSRELEASE}_signed.zip"
        $MICROG_API_28 && rsync -a -v out/MicroG/arm64/MicroG-arm64-9.0.0-${COMMONGAPPSRELEASE}_signed.zip "${user}@${host}:/home/hitman/sites/backup/${revs}/MicroG/arm64/Pie/MicroG-arm64-9.0.0-${COMMONGAPPSRELEASE}_signed.zip"
        $MICROG_API_27 && rsync -a -v out/MicroG/arm64/MicroG-arm64-8.1.0-${COMMONGAPPSRELEASE}_signed.zip "${user}@${host}:/home/hitman/sites/backup/${revs}/MicroG/arm64/Oreo/MicroG-arm64-8.1.0-${COMMONGAPPSRELEASE}_signed.zip"
        $MICROG_API_26 && rsync -a -v out/MicroG/arm64/MicroG-arm64-8.0.0-${COMMONGAPPSRELEASE}_signed.zip "${user}@${host}:/home/hitman/sites/backup/${revs}/MicroG/arm64/Oreo/MicroG-arm64-8.0.0-${COMMONGAPPSRELEASE}_signed.zip"
        $MICROG_API_25 && rsync -a -v out/MicroG/arm64/MicroG-arm64-7.1.2-${COMMONGAPPSRELEASE}_signed.zip "${user}@${host}:/home/hitman/sites/backup/${revs}/MicroG/arm64/Nougat/MicroG-arm64-7.1.2-${COMMONGAPPSRELEASE}_signed.zip"
        $MICROG_API_25 && rsync -a -v out/MicroG/arm64/MicroG-arm64-7.1.1-${COMMONGAPPSRELEASE}_signed.zip "${user}@${host}:/home/hitman/sites/backup/${revs}/MicroG/arm64/Nougat/MicroG-arm64-7.1.1-${COMMONGAPPSRELEASE}_signed.zip"
      fi
      if [ -n "$COMMONADDONRELEASE" ]; then
        $TARGET_PLATFORM_ARM64 && rsync -a -v out/Addon/arm64/BiTGApps-addon-arm64-${COMMONADDONRELEASE}_signed.zip "${user}@${host}:/home/hitman/sites/backup/${revs}/Addon/config/arm64/BiTGApps-addon-arm64-${COMMONADDONRELEASE}_signed.zip"
      fi
    fi
  fi
}

# COMMON Sources; Contains both ARMEABI & AARCH64 Packages
common_sources() {
  if [ "$COMMON" == "common" ] || [ "$ALL" == "all" ]; then
    if [ "$SERVER" == "ga" ]; then
      if [ -n "$COMMONADDONRELEASE" ]; then
        # ARMEABI Packages
        $TARGET_VARIANT_ASSISTANT && curl -T out/Addon/arm/BiTGApps-addon-assistant-${COMMONADDONRELEASE}_signed.zip "ftp://${user}:${pass}@${host}/Addon/non-config/arm/BiTGApps-addon-assistant-${COMMONADDONRELEASE}_signed.zip"
        $TARGET_VARIANT_BROMITE && curl -T out/Addon/arm/BiTGApps-addon-bromite-${COMMONADDONRELEASE}_signed.zip "ftp://${user}:${pass}@${host}/Addon/non-config/arm/BiTGApps-addon-bromite-${COMMONADDONRELEASE}_signed.zip"
        $TARGET_VARIANT_DIALER && curl -T out/Addon/arm/BiTGApps-addon-dialer-${COMMONADDONRELEASE}_signed.zip "ftp://${user}:${pass}@${host}/Addon/non-config/arm/BiTGApps-addon-dialer-${COMMONADDONRELEASE}_signed.zip"
        $TARGET_VARIANT_DPS && curl -T out/Addon/arm/BiTGApps-addon-dps-${COMMONADDONRELEASE}_signed.zip "ftp://${user}:${pass}@${host}/Addon/non-config/arm/BiTGApps-addon-dps-${COMMONADDONRELEASE}_signed.zip"
        $TARGET_VARIANT_GBOARD && curl -T out/Addon/arm/BiTGApps-addon-gboard-${COMMONADDONRELEASE}_signed.zip "ftp://${user}:${pass}@${host}/Addon/non-config/arm/BiTGApps-addon-gboard-${COMMONADDONRELEASE}_signed.zip"
        $TARGET_VARIANT_GEARHEAD && curl -T out/Addon/arm/BiTGApps-addon-gearhead-${COMMONADDONRELEASE}_signed.zip "ftp://${user}:${pass}@${host}/Addon/non-config/arm/BiTGApps-addon-gearhead-${COMMONADDONRELEASE}_signed.zip"
        $TARGET_VARIANT_MAPS && curl -T out/Addon/arm/BiTGApps-addon-maps-${COMMONADDONRELEASE}_signed.zip "ftp://${user}:${pass}@${host}/Addon/non-config/arm/BiTGApps-addon-maps-${COMMONADDONRELEASE}_signed.zip"
        $TARGET_VARIANT_MARKUP && curl -T out/Addon/arm/BiTGApps-addon-markup-${COMMONADDONRELEASE}_signed.zip "ftp://${user}:${pass}@${host}/Addon/non-config/arm/BiTGApps-addon-markup-${COMMONADDONRELEASE}_signed.zip"
        $TARGET_VARIANT_PHOTOS && curl -T out/Addon/arm/BiTGApps-addon-photos-${COMMONADDONRELEASE}_signed.zip "ftp://${user}:${pass}@${host}/Addon/non-config/arm/BiTGApps-addon-photos-${COMMONADDONRELEASE}_signed.zip"
        $TARGET_VARIANT_TTS && curl -T out/Addon/arm/BiTGApps-addon-tts-${COMMONADDONRELEASE}_signed.zip "ftp://${user}:${pass}@${host}/Addon/non-config/arm/BiTGApps-addon-tts-${COMMONADDONRELEASE}_signed.zip"
        $TARGET_VARIANT_VANCED_MICROG && curl -T out/Addon/arm/BiTGApps-addon-vanced-microg-${COMMONADDONRELEASE}_signed.zip "ftp://${user}:${pass}@${host}/Addon/non-config/arm/BiTGApps-addon-vanced-microg-${COMMONADDONRELEASE}_signed.zip"
        # AARCH64 Packages
        $TARGET_VARIANT_ASSISTANT && curl -T out/Addon/arm64/BiTGApps-addon-assistant-${COMMONADDONRELEASE}_signed.zip "ftp://${user}:${pass}@${host}/Addon/non-config/arm64/BiTGApps-addon-assistant-${COMMONADDONRELEASE}_signed.zip"
        $TARGET_VARIANT_BROMITE && curl -T out/Addon/arm64/BiTGApps-addon-bromite-${COMMONADDONRELEASE}_signed.zip "ftp://${user}:${pass}@${host}/Addon/non-config/arm64/BiTGApps-addon-bromite-${COMMONADDONRELEASE}_signed.zip"
        $TARGET_VARIANT_DIALER && curl -T out/Addon/arm64/BiTGApps-addon-dialer-${COMMONADDONRELEASE}_signed.zip "ftp://${user}:${pass}@${host}/Addon/non-config/arm64/BiTGApps-addon-dialer-${COMMONADDONRELEASE}_signed.zip"
        $TARGET_VARIANT_DPS && curl -T out/Addon/arm64/BiTGApps-addon-dps-${COMMONADDONRELEASE}_signed.zip "ftp://${user}:${pass}@${host}/Addon/non-config/arm64/BiTGApps-addon-dps-${COMMONADDONRELEASE}_signed.zip"
        $TARGET_VARIANT_GBOARD && curl -T out/Addon/arm64/BiTGApps-addon-gboard-${COMMONADDONRELEASE}_signed.zip "ftp://${user}:${pass}@${host}/Addon/non-config/arm64/BiTGApps-addon-gboard-${COMMONADDONRELEASE}_signed.zip"
        $TARGET_VARIANT_GEARHEAD && curl -T out/Addon/arm64/BiTGApps-addon-gearhead-${COMMONADDONRELEASE}_signed.zip "ftp://${user}:${pass}@${host}/Addon/non-config/arm64/BiTGApps-addon-gearhead-${COMMONADDONRELEASE}_signed.zip"
        $TARGET_VARIANT_MAPS && curl -T out/Addon/arm64/BiTGApps-addon-maps-${COMMONADDONRELEASE}_signed.zip "ftp://${user}:${pass}@${host}/Addon/non-config/arm64/BiTGApps-addon-maps-${COMMONADDONRELEASE}_signed.zip"
        $TARGET_VARIANT_MARKUP && curl -T out/Addon/arm64/BiTGApps-addon-markup-${COMMONADDONRELEASE}_signed.zip "ftp://${user}:${pass}@${host}/Addon/non-config/arm64/BiTGApps-addon-markup-${COMMONADDONRELEASE}_signed.zip"
        $TARGET_VARIANT_PHOTOS && curl -T out/Addon/arm64/BiTGApps-addon-photos-${COMMONADDONRELEASE}_signed.zip "ftp://${user}:${pass}@${host}/Addon/non-config/arm64/BiTGApps-addon-photos-${COMMONADDONRELEASE}_signed.zip"
        $TARGET_VARIANT_TTS && curl -T out/Addon/arm64/BiTGApps-addon-tts-${COMMONADDONRELEASE}_signed.zip "ftp://${user}:${pass}@${host}/Addon/non-config/arm64/BiTGApps-addon-tts-${COMMONADDONRELEASE}_signed.zip"
        $TARGET_VARIANT_VANCED_MICROG && curl -T out/Addon/arm64/BiTGApps-addon-vanced-microg-${COMMONADDONRELEASE}_signed.zip "ftp://${user}:${pass}@${host}/Addon/non-config/arm64/BiTGApps-addon-vanced-microg-${COMMONADDONRELEASE}_signed.zip"
        # Common Packages
        $TARGET_VARIANT_CALCULATOR && curl -T out/Addon/common/BiTGApps-addon-calculator-${COMMONADDONRELEASE}_signed.zip "ftp://${user}:${pass}@${host}/Addon/non-config/all/BiTGApps-addon-calculator-${COMMONADDONRELEASE}_signed.zip"
        $TARGET_VARIANT_CALENDAR && curl -T out/Addon/common/BiTGApps-addon-calendar-${COMMONADDONRELEASE}_signed.zip "ftp://${user}:${pass}@${host}/Addon/non-config/all/BiTGApps-addon-calendar-${COMMONADDONRELEASE}_signed.zip"
        $TARGET_VARIANT_CHROME && curl -T out/Addon/common/BiTGApps-addon-chrome-${COMMONADDONRELEASE}_signed.zip "ftp://${user}:${pass}@${host}/Addon/non-config/all/BiTGApps-addon-chrome-${COMMONADDONRELEASE}_signed.zip"
        $TARGET_VARIANT_CONTACTS && curl -T out/Addon/common/BiTGApps-addon-contacts-${COMMONADDONRELEASE}_signed.zip "ftp://${user}:${pass}@${host}/Addon/non-config/all/BiTGApps-addon-contacts-${COMMONADDONRELEASE}_signed.zip"
        $TARGET_VARIANT_DESKCLOCK && curl -T out/Addon/common/BiTGApps-addon-deskclock-${COMMONADDONRELEASE}_signed.zip "ftp://${user}:${pass}@${host}/Addon/non-config/all/BiTGApps-addon-deskclock-${COMMONADDONRELEASE}_signed.zip"
        $TARGET_VARIANT_LAUNCHER && curl -T out/Addon/common/BiTGApps-addon-launcher-${COMMONADDONRELEASE}_signed.zip "ftp://${user}:${pass}@${host}/Addon/non-config/all/BiTGApps-addon-launcher-${COMMONADDONRELEASE}_signed.zip"
        $TARGET_VARIANT_MESSAGES && curl -T out/Addon/common/BiTGApps-addon-messages-${COMMONADDONRELEASE}_signed.zip "ftp://${user}:${pass}@${host}/Addon/non-config/all/BiTGApps-addon-messages-${COMMONADDONRELEASE}_signed.zip"
        $TARGET_VARIANT_SOUNDPICKER && curl -T out/Addon/common/BiTGApps-addon-soundpicker-${COMMONADDONRELEASE}_signed.zip "ftp://${user}:${pass}@${host}/Addon/non-config/all/BiTGApps-addon-soundpicker-${COMMONADDONRELEASE}_signed.zip"
        $TARGET_VARIANT_VANCED_ROOT && curl -T out/Addon/common/BiTGApps-addon-vanced-root-${COMMONADDONRELEASE}_signed.zip "ftp://${user}:${pass}@${host}/Addon/non-config/all/BiTGApps-addon-vanced-root-${COMMONADDONRELEASE}_signed.zip"
        $TARGET_VARIANT_VANCED_NONROOT && curl -T out/Addon/common/BiTGApps-addon-vanced-nonroot-${COMMONADDONRELEASE}_signed.zip "ftp://${user}:${pass}@${host}/Addon/non-config/all/BiTGApps-addon-vanced-nonroot-${COMMONADDONRELEASE}_signed.zip"
        $TARGET_VARIANT_WELLBEING && curl -T out/Addon/common/BiTGApps-addon-wellbeing-${COMMONADDONRELEASE}_signed.zip "ftp://${user}:${pass}@${host}/Addon/non-config/all/BiTGApps-addon-wellbeing-${COMMONADDONRELEASE}_signed.zip"
      fi
    fi
    if [ "$SERVER" == "dh" ]; then
      if [ -n "$COMMONADDONRELEASE" ]; then
        # ARMEABI Packages
        $TARGET_VARIANT_ASSISTANT && rsync -a -v out/Addon/arm/BiTGApps-addon-assistant-${COMMONADDONRELEASE}_signed.zip "${user}@${host}:/home/bitgapps/bitgapps.com/downloads/Addon/non-config/arm/BiTGApps-addon-assistant-${COMMONADDONRELEASE}_signed.zip"
        $TARGET_VARIANT_BROMITE && rsync -a -v out/Addon/arm/BiTGApps-addon-bromite-${COMMONADDONRELEASE}_signed.zip "${user}@${host}:/home/bitgapps/bitgapps.com/downloads/Addon/non-config/arm/BiTGApps-addon-bromite-${COMMONADDONRELEASE}_signed.zip"
        $TARGET_VARIANT_DIALER && rsync -a -v out/Addon/arm/BiTGApps-addon-dialer-${COMMONADDONRELEASE}_signed.zip "${user}@${host}:/home/bitgapps/bitgapps.com/downloads/Addon/non-config/arm/BiTGApps-addon-dialer-${COMMONADDONRELEASE}_signed.zip"
        $TARGET_VARIANT_DPS && rsync -a -v out/Addon/arm/BiTGApps-addon-dps-${COMMONADDONRELEASE}_signed.zip "${user}@${host}:/home/bitgapps/bitgapps.com/downloads/Addon/non-config/arm/BiTGApps-addon-dps-${COMMONADDONRELEASE}_signed.zip"
        $TARGET_VARIANT_GBOARD && rsync -a -v out/Addon/arm/BiTGApps-addon-gboard-${COMMONADDONRELEASE}_signed.zip "${user}@${host}:/home/bitgapps/bitgapps.com/downloads/Addon/non-config/arm/BiTGApps-addon-gboard-${COMMONADDONRELEASE}_signed.zip"
        $TARGET_VARIANT_GEARHEAD && rsync -a -v out/Addon/arm/BiTGApps-addon-gearhead-${COMMONADDONRELEASE}_signed.zip "${user}@${host}:/home/bitgapps/bitgapps.com/downloads/Addon/non-config/arm/BiTGApps-addon-gearhead-${COMMONADDONRELEASE}_signed.zip"
        $TARGET_VARIANT_MAPS && rsync -a -v out/Addon/arm/BiTGApps-addon-maps-${COMMONADDONRELEASE}_signed.zip "${user}@${host}:/home/bitgapps/bitgapps.com/downloads/Addon/non-config/arm/BiTGApps-addon-maps-${COMMONADDONRELEASE}_signed.zip"
        $TARGET_VARIANT_MARKUP && rsync -a -v out/Addon/arm/BiTGApps-addon-markup-${COMMONADDONRELEASE}_signed.zip "${user}@${host}:/home/bitgapps/bitgapps.com/downloads/Addon/non-config/arm/BiTGApps-addon-markup-${COMMONADDONRELEASE}_signed.zip"
        $TARGET_VARIANT_PHOTOS && rsync -a -v out/Addon/arm/BiTGApps-addon-photos-${COMMONADDONRELEASE}_signed.zip "${user}@${host}:/home/bitgapps/bitgapps.com/downloads/Addon/non-config/arm/BiTGApps-addon-photos-${COMMONADDONRELEASE}_signed.zip"
        $TARGET_VARIANT_TTS && rsync -a -v out/Addon/arm/BiTGApps-addon-tts-${COMMONADDONRELEASE}_signed.zip "${user}@${host}:/home/bitgapps/bitgapps.com/downloads/Addon/non-config/arm/BiTGApps-addon-tts-${COMMONADDONRELEASE}_signed.zip"
        $TARGET_VARIANT_VANCED_MICROG && rsync -a -v out/Addon/arm/BiTGApps-addon-vanced-microg-${COMMONADDONRELEASE}_signed.zip "${user}@${host}:/home/bitgapps/bitgapps.com/downloads/Addon/non-config/arm/BiTGApps-addon-vanced-microg-${COMMONADDONRELEASE}_signed.zip"
        # AARCH64 Packages
        $TARGET_VARIANT_ASSISTANT && rsync -a -v out/Addon/arm64/BiTGApps-addon-assistant-${COMMONADDONRELEASE}_signed.zip "${user}@${host}:/home/bitgapps/bitgapps.com/downloads/Addon/non-config/arm64/BiTGApps-addon-assistant-${COMMONADDONRELEASE}_signed.zip"
        $TARGET_VARIANT_BROMITE && rsync -a -v out/Addon/arm64/BiTGApps-addon-bromite-${COMMONADDONRELEASE}_signed.zip "${user}@${host}:/home/bitgapps/bitgapps.com/downloads/Addon/non-config/arm64/BiTGApps-addon-bromite-${COMMONADDONRELEASE}_signed.zip"
        $TARGET_VARIANT_DIALER && rsync -a -v out/Addon/arm64/BiTGApps-addon-dialer-${COMMONADDONRELEASE}_signed.zip "${user}@${host}:/home/bitgapps/bitgapps.com/downloads/Addon/non-config/arm64/BiTGApps-addon-dialer-${COMMONADDONRELEASE}_signed.zip"
        $TARGET_VARIANT_DPS && rsync -a -v out/Addon/arm64/BiTGApps-addon-dps-${COMMONADDONRELEASE}_signed.zip "${user}@${host}:/home/bitgapps/bitgapps.com/downloads/Addon/non-config/arm64/BiTGApps-addon-dps-${COMMONADDONRELEASE}_signed.zip"
        $TARGET_VARIANT_GBOARD && rsync -a -v out/Addon/arm64/BiTGApps-addon-gboard-${COMMONADDONRELEASE}_signed.zip "${user}@${host}:/home/bitgapps/bitgapps.com/downloads/Addon/non-config/arm64/BiTGApps-addon-gboard-${COMMONADDONRELEASE}_signed.zip"
        $TARGET_VARIANT_GEARHEAD && rsync -a -v out/Addon/arm64/BiTGApps-addon-gearhead-${COMMONADDONRELEASE}_signed.zip "${user}@${host}:/home/bitgapps/bitgapps.com/downloads/Addon/non-config/arm64/BiTGApps-addon-gearhead-${COMMONADDONRELEASE}_signed.zip"
        $TARGET_VARIANT_MAPS && rsync -a -v out/Addon/arm64/BiTGApps-addon-maps-${COMMONADDONRELEASE}_signed.zip "${user}@${host}:/home/bitgapps/bitgapps.com/downloads/Addon/non-config/arm64/BiTGApps-addon-maps-${COMMONADDONRELEASE}_signed.zip"
        $TARGET_VARIANT_MARKUP && rsync -a -v out/Addon/arm64/BiTGApps-addon-markup-${COMMONADDONRELEASE}_signed.zip "${user}@${host}:/home/bitgapps/bitgapps.com/downloads/Addon/non-config/arm64/BiTGApps-addon-markup-${COMMONADDONRELEASE}_signed.zip"
        $TARGET_VARIANT_PHOTOS && rsync -a -v out/Addon/arm64/BiTGApps-addon-photos-${COMMONADDONRELEASE}_signed.zip "${user}@${host}:/home/bitgapps/bitgapps.com/downloads/Addon/non-config/arm64/BiTGApps-addon-photos-${COMMONADDONRELEASE}_signed.zip"
        $TARGET_VARIANT_TTS && rsync -a -v out/Addon/arm64/BiTGApps-addon-tts-${COMMONADDONRELEASE}_signed.zip "${user}@${host}:/home/bitgapps/bitgapps.com/downloads/Addon/non-config/arm64/BiTGApps-addon-tts-${COMMONADDONRELEASE}_signed.zip"
        $TARGET_VARIANT_VANCED_MICROG && rsync -a -v out/Addon/arm64/BiTGApps-addon-vanced-microg-${COMMONADDONRELEASE}_signed.zip "${user}@${host}:/home/bitgapps/bitgapps.com/downloads/Addon/non-config/arm64/BiTGApps-addon-vanced-microg-${COMMONADDONRELEASE}_signed.zip"
        # Common Packages
        $TARGET_VARIANT_CALCULATOR && rsync -a -v out/Addon/common/BiTGApps-addon-calculator-${COMMONADDONRELEASE}_signed.zip "${user}@${host}:/home/bitgapps/bitgapps.com/downloads/Addon/non-config/all/BiTGApps-addon-calculator-${COMMONADDONRELEASE}_signed.zip"
        $TARGET_VARIANT_CALENDAR && rsync -a -v out/Addon/common/BiTGApps-addon-calendar-${COMMONADDONRELEASE}_signed.zip "${user}@${host}:/home/bitgapps/bitgapps.com/downloads/Addon/non-config/all/BiTGApps-addon-calendar-${COMMONADDONRELEASE}_signed.zip"
        $TARGET_VARIANT_CHROME && rsync -a -v out/Addon/common/BiTGApps-addon-chrome-${COMMONADDONRELEASE}_signed.zip "${user}@${host}:/home/bitgapps/bitgapps.com/downloads/Addon/non-config/all/BiTGApps-addon-chrome-${COMMONADDONRELEASE}_signed.zip"
        $TARGET_VARIANT_CONTACTS && rsync -a -v out/Addon/common/BiTGApps-addon-contacts-${COMMONADDONRELEASE}_signed.zip "${user}@${host}:/home/bitgapps/bitgapps.com/downloads/Addon/non-config/all/BiTGApps-addon-contacts-${COMMONADDONRELEASE}_signed.zip"
        $TARGET_VARIANT_DESKCLOCK && rsync -a -v out/Addon/common/BiTGApps-addon-deskclock-${COMMONADDONRELEASE}_signed.zip "${user}@${host}:/home/bitgapps/bitgapps.com/downloads/Addon/non-config/all/BiTGApps-addon-deskclock-${COMMONADDONRELEASE}_signed.zip"
        $TARGET_VARIANT_LAUNCHER && rsync -a -v out/Addon/common/BiTGApps-addon-launcher-${COMMONADDONRELEASE}_signed.zip "${user}@${host}:/home/bitgapps/bitgapps.com/downloads/Addon/non-config/all/BiTGApps-addon-launcher-${COMMONADDONRELEASE}_signed.zip"
        $TARGET_VARIANT_MESSAGES && rsync -a -v out/Addon/common/BiTGApps-addon-messages-${COMMONADDONRELEASE}_signed.zip "${user}@${host}:/home/bitgapps/bitgapps.com/downloads/Addon/non-config/all/BiTGApps-addon-messages-${COMMONADDONRELEASE}_signed.zip"
        $TARGET_VARIANT_SOUNDPICKER && rsync -a -v out/Addon/common/BiTGApps-addon-soundpicker-${COMMONADDONRELEASE}_signed.zip "${user}@${host}:/home/bitgapps/bitgapps.com/downloads/Addon/non-config/all/BiTGApps-addon-soundpicker-${COMMONADDONRELEASE}_signed.zip"
        $TARGET_VARIANT_VANCED_ROOT && rsync -a -v out/Addon/common/BiTGApps-addon-vanced-root-${COMMONADDONRELEASE}_signed.zip "${user}@${host}:/home/bitgapps/bitgapps.com/downloads/Addon/non-config/all/BiTGApps-addon-vanced-root-${COMMONADDONRELEASE}_signed.zip"
        $TARGET_VARIANT_VANCED_NONROOT && rsync -a -v out/Addon/common/BiTGApps-addon-vanced-nonroot-${COMMONADDONRELEASE}_signed.zip "${user}@${host}:/home/bitgapps/bitgapps.com/downloads/Addon/non-config/all/BiTGApps-addon-vanced-nonroot-${COMMONADDONRELEASE}_signed.zip"
        $TARGET_VARIANT_WELLBEING && rsync -a -v out/Addon/common/BiTGApps-addon-wellbeing-${COMMONADDONRELEASE}_signed.zip "${user}@${host}:/home/bitgapps/bitgapps.com/downloads/Addon/non-config/all/BiTGApps-addon-wellbeing-${COMMONADDONRELEASE}_signed.zip"
      fi
    fi
    if [ "$SERVER" == "sps" ]; then
      if [ -n "$COMMONADDONRELEASE" ]; then
        # ARMEABI Packages
        $TARGET_VARIANT_ASSISTANT && rsync -a -v out/Addon/arm/BiTGApps-addon-assistant-${COMMONADDONRELEASE}_signed.zip "${user}@${host}:/home/hitman/sites/downloads/Addon/non-config/arm/BiTGApps-addon-assistant-${COMMONADDONRELEASE}_signed.zip"
        $TARGET_VARIANT_BROMITE && rsync -a -v out/Addon/arm/BiTGApps-addon-bromite-${COMMONADDONRELEASE}_signed.zip "${user}@${host}:/home/hitman/sites/downloads/Addon/non-config/arm/BiTGApps-addon-bromite-${COMMONADDONRELEASE}_signed.zip"
        $TARGET_VARIANT_DIALER && rsync -a -v out/Addon/arm/BiTGApps-addon-dialer-${COMMONADDONRELEASE}_signed.zip "${user}@${host}:/home/hitman/sites/downloads/Addon/non-config/arm/BiTGApps-addon-dialer-${COMMONADDONRELEASE}_signed.zip"
        $TARGET_VARIANT_DPS && rsync -a -v out/Addon/arm/BiTGApps-addon-dps-${COMMONADDONRELEASE}_signed.zip "${user}@${host}:/home/hitman/sites/downloads/Addon/non-config/arm/BiTGApps-addon-dps-${COMMONADDONRELEASE}_signed.zip"
        $TARGET_VARIANT_GBOARD && rsync -a -v out/Addon/arm/BiTGApps-addon-gboard-${COMMONADDONRELEASE}_signed.zip "${user}@${host}:/home/hitman/sites/downloads/Addon/non-config/arm/BiTGApps-addon-gboard-${COMMONADDONRELEASE}_signed.zip"
        $TARGET_VARIANT_GEARHEAD && rsync -a -v out/Addon/arm/BiTGApps-addon-gearhead-${COMMONADDONRELEASE}_signed.zip "${user}@${host}:/home/hitman/sites/downloads/Addon/non-config/arm/BiTGApps-addon-gearhead-${COMMONADDONRELEASE}_signed.zip"
        $TARGET_VARIANT_MAPS && rsync -a -v out/Addon/arm/BiTGApps-addon-maps-${COMMONADDONRELEASE}_signed.zip "${user}@${host}:/home/hitman/sites/downloads/Addon/non-config/arm/BiTGApps-addon-maps-${COMMONADDONRELEASE}_signed.zip"
        $TARGET_VARIANT_MARKUP && rsync -a -v out/Addon/arm/BiTGApps-addon-markup-${COMMONADDONRELEASE}_signed.zip "${user}@${host}:/home/hitman/sites/downloads/Addon/non-config/arm/BiTGApps-addon-markup-${COMMONADDONRELEASE}_signed.zip"
        $TARGET_VARIANT_PHOTOS && rsync -a -v out/Addon/arm/BiTGApps-addon-photos-${COMMONADDONRELEASE}_signed.zip "${user}@${host}:/home/hitman/sites/downloads/Addon/non-config/arm/BiTGApps-addon-photos-${COMMONADDONRELEASE}_signed.zip"
        $TARGET_VARIANT_TTS && rsync -a -v out/Addon/arm/BiTGApps-addon-tts-${COMMONADDONRELEASE}_signed.zip "${user}@${host}:/home/hitman/sites/downloads/Addon/non-config/arm/BiTGApps-addon-tts-${COMMONADDONRELEASE}_signed.zip"
        $TARGET_VARIANT_VANCED_MICROG && rsync -a -v out/Addon/arm/BiTGApps-addon-vanced-microg-${COMMONADDONRELEASE}_signed.zip "${user}@${host}:/home/hitman/sites/downloads/Addon/non-config/arm/BiTGApps-addon-vanced-microg-${COMMONADDONRELEASE}_signed.zip"
        # AARCH64 Packages
        $TARGET_VARIANT_ASSISTANT && rsync -a -v out/Addon/arm64/BiTGApps-addon-assistant-${COMMONADDONRELEASE}_signed.zip "${user}@${host}:/home/hitman/sites/downloads/Addon/non-config/arm64/BiTGApps-addon-assistant-${COMMONADDONRELEASE}_signed.zip"
        $TARGET_VARIANT_BROMITE && rsync -a -v out/Addon/arm64/BiTGApps-addon-bromite-${COMMONADDONRELEASE}_signed.zip "${user}@${host}:/home/hitman/sites/downloads/Addon/non-config/arm64/BiTGApps-addon-bromite-${COMMONADDONRELEASE}_signed.zip"
        $TARGET_VARIANT_DIALER && rsync -a -v out/Addon/arm64/BiTGApps-addon-dialer-${COMMONADDONRELEASE}_signed.zip "${user}@${host}:/home/hitman/sites/downloads/Addon/non-config/arm64/BiTGApps-addon-dialer-${COMMONADDONRELEASE}_signed.zip"
        $TARGET_VARIANT_DPS && rsync -a -v out/Addon/arm64/BiTGApps-addon-dps-${COMMONADDONRELEASE}_signed.zip "${user}@${host}:/home/hitman/sites/downloads/Addon/non-config/arm64/BiTGApps-addon-dps-${COMMONADDONRELEASE}_signed.zip"
        $TARGET_VARIANT_GBOARD && rsync -a -v out/Addon/arm64/BiTGApps-addon-gboard-${COMMONADDONRELEASE}_signed.zip "${user}@${host}:/home/hitman/sites/downloads/Addon/non-config/arm64/BiTGApps-addon-gboard-${COMMONADDONRELEASE}_signed.zip"
        $TARGET_VARIANT_GEARHEAD && rsync -a -v out/Addon/arm64/BiTGApps-addon-gearhead-${COMMONADDONRELEASE}_signed.zip "${user}@${host}:/home/hitman/sites/downloads/Addon/non-config/arm64/BiTGApps-addon-gearhead-${COMMONADDONRELEASE}_signed.zip"
        $TARGET_VARIANT_MAPS && rsync -a -v out/Addon/arm64/BiTGApps-addon-maps-${COMMONADDONRELEASE}_signed.zip "${user}@${host}:/home/hitman/sites/downloads/Addon/non-config/arm64/BiTGApps-addon-maps-${COMMONADDONRELEASE}_signed.zip"
        $TARGET_VARIANT_MARKUP && rsync -a -v out/Addon/arm64/BiTGApps-addon-markup-${COMMONADDONRELEASE}_signed.zip "${user}@${host}:/home/hitman/sites/downloads/Addon/non-config/arm64/BiTGApps-addon-markup-${COMMONADDONRELEASE}_signed.zip"
        $TARGET_VARIANT_PHOTOS && rsync -a -v out/Addon/arm64/BiTGApps-addon-photos-${COMMONADDONRELEASE}_signed.zip "${user}@${host}:/home/hitman/sites/downloads/Addon/non-config/arm64/BiTGApps-addon-photos-${COMMONADDONRELEASE}_signed.zip"
        $TARGET_VARIANT_TTS && rsync -a -v out/Addon/arm64/BiTGApps-addon-tts-${COMMONADDONRELEASE}_signed.zip "${user}@${host}:/home/hitman/sites/downloads/Addon/non-config/arm64/BiTGApps-addon-tts-${COMMONADDONRELEASE}_signed.zip"
        $TARGET_VARIANT_VANCED_MICROG && rsync -a -v out/Addon/arm64/BiTGApps-addon-vanced-microg-${COMMONADDONRELEASE}_signed.zip "${user}@${host}:/home/hitman/sites/downloads/Addon/non-config/arm64/BiTGApps-addon-vanced-microg-${COMMONADDONRELEASE}_signed.zip"
        # Common Packages
        $TARGET_VARIANT_CALCULATOR && rsync -a -v out/Addon/common/BiTGApps-addon-calculator-${COMMONADDONRELEASE}_signed.zip "${user}@${host}:/home/hitman/sites/downloads/Addon/non-config/all/BiTGApps-addon-calculator-${COMMONADDONRELEASE}_signed.zip"
        $TARGET_VARIANT_CALENDAR && rsync -a -v out/Addon/common/BiTGApps-addon-calendar-${COMMONADDONRELEASE}_signed.zip "${user}@${host}:/home/hitman/sites/downloads/Addon/non-config/all/BiTGApps-addon-calendar-${COMMONADDONRELEASE}_signed.zip"
        $TARGET_VARIANT_CHROME && rsync -a -v out/Addon/common/BiTGApps-addon-chrome-${COMMONADDONRELEASE}_signed.zip "${user}@${host}:/home/hitman/sites/downloads/Addon/non-config/all/BiTGApps-addon-chrome-${COMMONADDONRELEASE}_signed.zip"
        $TARGET_VARIANT_CONTACTS && rsync -a -v out/Addon/common/BiTGApps-addon-contacts-${COMMONADDONRELEASE}_signed.zip "${user}@${host}:/home/hitman/sites/downloads/Addon/non-config/all/BiTGApps-addon-contacts-${COMMONADDONRELEASE}_signed.zip"
        $TARGET_VARIANT_DESKCLOCK && rsync -a -v out/Addon/common/BiTGApps-addon-deskclock-${COMMONADDONRELEASE}_signed.zip "${user}@${host}:/home/hitman/sites/downloads/Addon/non-config/all/BiTGApps-addon-deskclock-${COMMONADDONRELEASE}_signed.zip"
        $TARGET_VARIANT_LAUNCHER && rsync -a -v out/Addon/common/BiTGApps-addon-launcher-${COMMONADDONRELEASE}_signed.zip "${user}@${host}:/home/hitman/sites/downloads/Addon/non-config/all/BiTGApps-addon-launcher-${COMMONADDONRELEASE}_signed.zip"
        $TARGET_VARIANT_MESSAGES && rsync -a -v out/Addon/common/BiTGApps-addon-messages-${COMMONADDONRELEASE}_signed.zip "${user}@${host}:/home/hitman/sites/downloads/Addon/non-config/all/BiTGApps-addon-messages-${COMMONADDONRELEASE}_signed.zip"
        $TARGET_VARIANT_SOUNDPICKER && rsync -a -v out/Addon/common/BiTGApps-addon-soundpicker-${COMMONADDONRELEASE}_signed.zip "${user}@${host}:/home/hitman/sites/downloads/Addon/non-config/all/BiTGApps-addon-soundpicker-${COMMONADDONRELEASE}_signed.zip"
        $TARGET_VARIANT_VANCED_ROOT && rsync -a -v out/Addon/common/BiTGApps-addon-vanced-root-${COMMONADDONRELEASE}_signed.zip "${user}@${host}:/home/hitman/sites/downloads/Addon/non-config/all/BiTGApps-addon-vanced-root-${COMMONADDONRELEASE}_signed.zip"
        $TARGET_VARIANT_VANCED_NONROOT && rsync -a -v out/Addon/common/BiTGApps-addon-vanced-nonroot-${COMMONADDONRELEASE}_signed.zip "${user}@${host}:/home/hitman/sites/downloads/Addon/non-config/all/BiTGApps-addon-vanced-nonroot-${COMMONADDONRELEASE}_signed.zip"
        $TARGET_VARIANT_WELLBEING && rsync -a -v out/Addon/common/BiTGApps-addon-wellbeing-${COMMONADDONRELEASE}_signed.zip "${user}@${host}:/home/hitman/sites/downloads/Addon/non-config/all/BiTGApps-addon-wellbeing-${COMMONADDONRELEASE}_signed.zip"
      fi
    fi
    if [ "$SERVER" == "alpha" ]; then
      if [ -n "$COMMONADDONRELEASE" ]; then
        # ARMEABI Packages
        $TARGET_VARIANT_ASSISTANT && rsync -a -v out/Addon/arm/BiTGApps-addon-assistant-${COMMONADDONRELEASE}_signed.zip "${user}@${host}:/home/hitman/sites/alpha/${revs}/Addon/non-config/arm/BiTGApps-addon-assistant-${COMMONADDONRELEASE}_signed.zip"
        $TARGET_VARIANT_BROMITE && rsync -a -v out/Addon/arm/BiTGApps-addon-bromite-${COMMONADDONRELEASE}_signed.zip "${user}@${host}:/home/hitman/sites/alpha/${revs}/Addon/non-config/arm/BiTGApps-addon-bromite-${COMMONADDONRELEASE}_signed.zip"
        $TARGET_VARIANT_DIALER && rsync -a -v out/Addon/arm/BiTGApps-addon-dialer-${COMMONADDONRELEASE}_signed.zip "${user}@${host}:/home/hitman/sites/alpha/${revs}/Addon/non-config/arm/BiTGApps-addon-dialer-${COMMONADDONRELEASE}_signed.zip"
        $TARGET_VARIANT_DPS && rsync -a -v out/Addon/arm/BiTGApps-addon-dps-${COMMONADDONRELEASE}_signed.zip "${user}@${host}:/home/hitman/sites/alpha/${revs}/Addon/non-config/arm/BiTGApps-addon-dps-${COMMONADDONRELEASE}_signed.zip"
        $TARGET_VARIANT_GBOARD && rsync -a -v out/Addon/arm/BiTGApps-addon-gboard-${COMMONADDONRELEASE}_signed.zip "${user}@${host}:/home/hitman/sites/alpha/${revs}/Addon/non-config/arm/BiTGApps-addon-gboard-${COMMONADDONRELEASE}_signed.zip"
        $TARGET_VARIANT_GEARHEAD && rsync -a -v out/Addon/arm/BiTGApps-addon-gearhead-${COMMONADDONRELEASE}_signed.zip "${user}@${host}:/home/hitman/sites/alpha/${revs}/Addon/non-config/arm/BiTGApps-addon-gearhead-${COMMONADDONRELEASE}_signed.zip"
        $TARGET_VARIANT_MAPS && rsync -a -v out/Addon/arm/BiTGApps-addon-maps-${COMMONADDONRELEASE}_signed.zip "${user}@${host}:/home/hitman/sites/alpha/${revs}/Addon/non-config/arm/BiTGApps-addon-maps-${COMMONADDONRELEASE}_signed.zip"
        $TARGET_VARIANT_MARKUP && rsync -a -v out/Addon/arm/BiTGApps-addon-markup-${COMMONADDONRELEASE}_signed.zip "${user}@${host}:/home/hitman/sites/alpha/${revs}/Addon/non-config/arm/BiTGApps-addon-markup-${COMMONADDONRELEASE}_signed.zip"
        $TARGET_VARIANT_PHOTOS && rsync -a -v out/Addon/arm/BiTGApps-addon-photos-${COMMONADDONRELEASE}_signed.zip "${user}@${host}:/home/hitman/sites/alpha/${revs}/Addon/non-config/arm/BiTGApps-addon-photos-${COMMONADDONRELEASE}_signed.zip"
        $TARGET_VARIANT_TTS && rsync -a -v out/Addon/arm/BiTGApps-addon-tts-${COMMONADDONRELEASE}_signed.zip "${user}@${host}:/home/hitman/sites/alpha/${revs}/Addon/non-config/arm/BiTGApps-addon-tts-${COMMONADDONRELEASE}_signed.zip"
        $TARGET_VARIANT_VANCED_MICROG && rsync -a -v out/Addon/arm/BiTGApps-addon-vanced-microg-${COMMONADDONRELEASE}_signed.zip "${user}@${host}:/home/hitman/sites/alpha/${revs}/Addon/non-config/arm/BiTGApps-addon-vanced-microg-${COMMONADDONRELEASE}_signed.zip"
        # AARCH64 Packages
        $TARGET_VARIANT_ASSISTANT && rsync -a -v out/Addon/arm64/BiTGApps-addon-assistant-${COMMONADDONRELEASE}_signed.zip "${user}@${host}:/home/hitman/sites/alpha/${revs}/Addon/non-config/arm64/BiTGApps-addon-assistant-${COMMONADDONRELEASE}_signed.zip"
        $TARGET_VARIANT_BROMITE && rsync -a -v out/Addon/arm64/BiTGApps-addon-bromite-${COMMONADDONRELEASE}_signed.zip "${user}@${host}:/home/hitman/sites/alpha/${revs}/Addon/non-config/arm64/BiTGApps-addon-bromite-${COMMONADDONRELEASE}_signed.zip"
        $TARGET_VARIANT_DIALER && rsync -a -v out/Addon/arm64/BiTGApps-addon-dialer-${COMMONADDONRELEASE}_signed.zip "${user}@${host}:/home/hitman/sites/alpha/${revs}/Addon/non-config/arm64/BiTGApps-addon-dialer-${COMMONADDONRELEASE}_signed.zip"
        $TARGET_VARIANT_DPS && rsync -a -v out/Addon/arm64/BiTGApps-addon-dps-${COMMONADDONRELEASE}_signed.zip "${user}@${host}:/home/hitman/sites/alpha/${revs}/Addon/non-config/arm64/BiTGApps-addon-dps-${COMMONADDONRELEASE}_signed.zip"
        $TARGET_VARIANT_GBOARD && rsync -a -v out/Addon/arm64/BiTGApps-addon-gboard-${COMMONADDONRELEASE}_signed.zip "${user}@${host}:/home/hitman/sites/alpha/${revs}/Addon/non-config/arm64/BiTGApps-addon-gboard-${COMMONADDONRELEASE}_signed.zip"
        $TARGET_VARIANT_GEARHEAD && rsync -a -v out/Addon/arm64/BiTGApps-addon-gearhead-${COMMONADDONRELEASE}_signed.zip "${user}@${host}:/home/hitman/sites/alpha/${revs}/Addon/non-config/arm64/BiTGApps-addon-gearhead-${COMMONADDONRELEASE}_signed.zip"
        $TARGET_VARIANT_MAPS && rsync -a -v out/Addon/arm64/BiTGApps-addon-maps-${COMMONADDONRELEASE}_signed.zip "${user}@${host}:/home/hitman/sites/alpha/${revs}/Addon/non-config/arm64/BiTGApps-addon-maps-${COMMONADDONRELEASE}_signed.zip"
        $TARGET_VARIANT_MARKUP && rsync -a -v out/Addon/arm64/BiTGApps-addon-markup-${COMMONADDONRELEASE}_signed.zip "${user}@${host}:/home/hitman/sites/alpha/${revs}/Addon/non-config/arm64/BiTGApps-addon-markup-${COMMONADDONRELEASE}_signed.zip"
        $TARGET_VARIANT_PHOTOS && rsync -a -v out/Addon/arm64/BiTGApps-addon-photos-${COMMONADDONRELEASE}_signed.zip "${user}@${host}:/home/hitman/sites/alpha/${revs}/Addon/non-config/arm64/BiTGApps-addon-photos-${COMMONADDONRELEASE}_signed.zip"
        $TARGET_VARIANT_TTS && rsync -a -v out/Addon/arm64/BiTGApps-addon-tts-${COMMONADDONRELEASE}_signed.zip "${user}@${host}:/home/hitman/sites/alpha/${revs}/Addon/non-config/arm64/BiTGApps-addon-tts-${COMMONADDONRELEASE}_signed.zip"
        $TARGET_VARIANT_VANCED_MICROG && rsync -a -v out/Addon/arm64/BiTGApps-addon-vanced-microg-${COMMONADDONRELEASE}_signed.zip "${user}@${host}:/home/hitman/sites/alpha/${revs}/Addon/non-config/arm64/BiTGApps-addon-vanced-microg-${COMMONADDONRELEASE}_signed.zip"
        # Common Packages
        $TARGET_VARIANT_CALCULATOR && rsync -a -v out/Addon/common/BiTGApps-addon-calculator-${COMMONADDONRELEASE}_signed.zip "${user}@${host}:/home/hitman/sites/alpha/${revs}/Addon/non-config/all/BiTGApps-addon-calculator-${COMMONADDONRELEASE}_signed.zip"
        $TARGET_VARIANT_CALENDAR && rsync -a -v out/Addon/common/BiTGApps-addon-calendar-${COMMONADDONRELEASE}_signed.zip "${user}@${host}:/home/hitman/sites/alpha/${revs}/Addon/non-config/all/BiTGApps-addon-calendar-${COMMONADDONRELEASE}_signed.zip"
        $TARGET_VARIANT_CHROME && rsync -a -v out/Addon/common/BiTGApps-addon-chrome-${COMMONADDONRELEASE}_signed.zip "${user}@${host}:/home/hitman/sites/alpha/${revs}/Addon/non-config/all/BiTGApps-addon-chrome-${COMMONADDONRELEASE}_signed.zip"
        $TARGET_VARIANT_CONTACTS && rsync -a -v out/Addon/common/BiTGApps-addon-contacts-${COMMONADDONRELEASE}_signed.zip "${user}@${host}:/home/hitman/sites/alpha/${revs}/Addon/non-config/all/BiTGApps-addon-contacts-${COMMONADDONRELEASE}_signed.zip"
        $TARGET_VARIANT_DESKCLOCK && rsync -a -v out/Addon/common/BiTGApps-addon-deskclock-${COMMONADDONRELEASE}_signed.zip "${user}@${host}:/home/hitman/sites/alpha/${revs}/Addon/non-config/all/BiTGApps-addon-deskclock-${COMMONADDONRELEASE}_signed.zip"
        $TARGET_VARIANT_LAUNCHER && rsync -a -v out/Addon/common/BiTGApps-addon-launcher-${COMMONADDONRELEASE}_signed.zip "${user}@${host}:/home/hitman/sites/alpha/${revs}/Addon/non-config/all/BiTGApps-addon-launcher-${COMMONADDONRELEASE}_signed.zip"
        $TARGET_VARIANT_MESSAGES && rsync -a -v out/Addon/common/BiTGApps-addon-messages-${COMMONADDONRELEASE}_signed.zip "${user}@${host}:/home/hitman/sites/alpha/${revs}/Addon/non-config/all/BiTGApps-addon-messages-${COMMONADDONRELEASE}_signed.zip"
        $TARGET_VARIANT_SOUNDPICKER && rsync -a -v out/Addon/common/BiTGApps-addon-soundpicker-${COMMONADDONRELEASE}_signed.zip "${user}@${host}:/home/hitman/sites/alpha/${revs}/Addon/non-config/all/BiTGApps-addon-soundpicker-${COMMONADDONRELEASE}_signed.zip"
        $TARGET_VARIANT_VANCED_ROOT && rsync -a -v out/Addon/common/BiTGApps-addon-vanced-root-${COMMONADDONRELEASE}_signed.zip "${user}@${host}:/home/hitman/sites/alpha/${revs}/Addon/non-config/all/BiTGApps-addon-vanced-root-${COMMONADDONRELEASE}_signed.zip"
        $TARGET_VARIANT_VANCED_NONROOT && rsync -a -v out/Addon/common/BiTGApps-addon-vanced-nonroot-${COMMONADDONRELEASE}_signed.zip "${user}@${host}:/home/hitman/sites/alpha/${revs}/Addon/non-config/all/BiTGApps-addon-vanced-nonroot-${COMMONADDONRELEASE}_signed.zip"
        $TARGET_VARIANT_WELLBEING && rsync -a -v out/Addon/common/BiTGApps-addon-wellbeing-${COMMONADDONRELEASE}_signed.zip "${user}@${host}:/home/hitman/sites/alpha/${revs}/Addon/non-config/all/BiTGApps-addon-wellbeing-${COMMONADDONRELEASE}_signed.zip"
      fi
    fi
    if [ "$SERVER" == "backup" ]; then
      if [ -n "$COMMONADDONRELEASE" ]; then
        # ARMEABI Packages
        $TARGET_VARIANT_ASSISTANT && rsync -a -v out/Addon/arm/BiTGApps-addon-assistant-${COMMONADDONRELEASE}_signed.zip "${user}@${host}:/home/hitman/sites/backup/${revs}/Addon/non-config/arm/BiTGApps-addon-assistant-${COMMONADDONRELEASE}_signed.zip"
        $TARGET_VARIANT_BROMITE && rsync -a -v out/Addon/arm/BiTGApps-addon-bromite-${COMMONADDONRELEASE}_signed.zip "${user}@${host}:/home/hitman/sites/backup/${revs}/Addon/non-config/arm/BiTGApps-addon-bromite-${COMMONADDONRELEASE}_signed.zip"
        $TARGET_VARIANT_DIALER && rsync -a -v out/Addon/arm/BiTGApps-addon-dialer-${COMMONADDONRELEASE}_signed.zip "${user}@${host}:/home/hitman/sites/backup/${revs}/Addon/non-config/arm/BiTGApps-addon-dialer-${COMMONADDONRELEASE}_signed.zip"
        $TARGET_VARIANT_DPS && rsync -a -v out/Addon/arm/BiTGApps-addon-dps-${COMMONADDONRELEASE}_signed.zip "${user}@${host}:/home/hitman/sites/backup/${revs}/Addon/non-config/arm/BiTGApps-addon-dps-${COMMONADDONRELEASE}_signed.zip"
        $TARGET_VARIANT_GBOARD && rsync -a -v out/Addon/arm/BiTGApps-addon-gboard-${COMMONADDONRELEASE}_signed.zip "${user}@${host}:/home/hitman/sites/backup/${revs}/Addon/non-config/arm/BiTGApps-addon-gboard-${COMMONADDONRELEASE}_signed.zip"
        $TARGET_VARIANT_GEARHEAD && rsync -a -v out/Addon/arm/BiTGApps-addon-gearhead-${COMMONADDONRELEASE}_signed.zip "${user}@${host}:/home/hitman/sites/backup/${revs}/Addon/non-config/arm/BiTGApps-addon-gearhead-${COMMONADDONRELEASE}_signed.zip"
        $TARGET_VARIANT_MAPS && rsync -a -v out/Addon/arm/BiTGApps-addon-maps-${COMMONADDONRELEASE}_signed.zip "${user}@${host}:/home/hitman/sites/backup/${revs}/Addon/non-config/arm/BiTGApps-addon-maps-${COMMONADDONRELEASE}_signed.zip"
        $TARGET_VARIANT_MARKUP && rsync -a -v out/Addon/arm/BiTGApps-addon-markup-${COMMONADDONRELEASE}_signed.zip "${user}@${host}:/home/hitman/sites/backup/${revs}/Addon/non-config/arm/BiTGApps-addon-markup-${COMMONADDONRELEASE}_signed.zip"
        $TARGET_VARIANT_PHOTOS && rsync -a -v out/Addon/arm/BiTGApps-addon-photos-${COMMONADDONRELEASE}_signed.zip "${user}@${host}:/home/hitman/sites/backup/${revs}/Addon/non-config/arm/BiTGApps-addon-photos-${COMMONADDONRELEASE}_signed.zip"
        $TARGET_VARIANT_TTS && rsync -a -v out/Addon/arm/BiTGApps-addon-tts-${COMMONADDONRELEASE}_signed.zip "${user}@${host}:/home/hitman/sites/backup/${revs}/Addon/non-config/arm/BiTGApps-addon-tts-${COMMONADDONRELEASE}_signed.zip"
        $TARGET_VARIANT_VANCED_MICROG && rsync -a -v out/Addon/arm/BiTGApps-addon-vanced-microg-${COMMONADDONRELEASE}_signed.zip "${user}@${host}:/home/hitman/sites/backup/${revs}/Addon/non-config/arm/BiTGApps-addon-vanced-microg-${COMMONADDONRELEASE}_signed.zip"
        # AARCH64 Packages
        $TARGET_VARIANT_ASSISTANT && rsync -a -v out/Addon/arm64/BiTGApps-addon-assistant-${COMMONADDONRELEASE}_signed.zip "${user}@${host}:/home/hitman/sites/backup/${revs}/Addon/non-config/arm64/BiTGApps-addon-assistant-${COMMONADDONRELEASE}_signed.zip"
        $TARGET_VARIANT_BROMITE && rsync -a -v out/Addon/arm64/BiTGApps-addon-bromite-${COMMONADDONRELEASE}_signed.zip "${user}@${host}:/home/hitman/sites/backup/${revs}/Addon/non-config/arm64/BiTGApps-addon-bromite-${COMMONADDONRELEASE}_signed.zip"
        $TARGET_VARIANT_DIALER && rsync -a -v out/Addon/arm64/BiTGApps-addon-dialer-${COMMONADDONRELEASE}_signed.zip "${user}@${host}:/home/hitman/sites/backup/${revs}/Addon/non-config/arm64/BiTGApps-addon-dialer-${COMMONADDONRELEASE}_signed.zip"
        $TARGET_VARIANT_DPS && rsync -a -v out/Addon/arm64/BiTGApps-addon-dps-${COMMONADDONRELEASE}_signed.zip "${user}@${host}:/home/hitman/sites/backup/${revs}/Addon/non-config/arm64/BiTGApps-addon-dps-${COMMONADDONRELEASE}_signed.zip"
        $TARGET_VARIANT_GBOARD && rsync -a -v out/Addon/arm64/BiTGApps-addon-gboard-${COMMONADDONRELEASE}_signed.zip "${user}@${host}:/home/hitman/sites/backup/${revs}/Addon/non-config/arm64/BiTGApps-addon-gboard-${COMMONADDONRELEASE}_signed.zip"
        $TARGET_VARIANT_GEARHEAD && rsync -a -v out/Addon/arm64/BiTGApps-addon-gearhead-${COMMONADDONRELEASE}_signed.zip "${user}@${host}:/home/hitman/sites/backup/${revs}/Addon/non-config/arm64/BiTGApps-addon-gearhead-${COMMONADDONRELEASE}_signed.zip"
        $TARGET_VARIANT_MAPS && rsync -a -v out/Addon/arm64/BiTGApps-addon-maps-${COMMONADDONRELEASE}_signed.zip "${user}@${host}:/home/hitman/sites/backup/${revs}/Addon/non-config/arm64/BiTGApps-addon-maps-${COMMONADDONRELEASE}_signed.zip"
        $TARGET_VARIANT_MARKUP && rsync -a -v out/Addon/arm64/BiTGApps-addon-markup-${COMMONADDONRELEASE}_signed.zip "${user}@${host}:/home/hitman/sites/backup/${revs}/Addon/non-config/arm64/BiTGApps-addon-markup-${COMMONADDONRELEASE}_signed.zip"
        $TARGET_VARIANT_PHOTOS && rsync -a -v out/Addon/arm64/BiTGApps-addon-photos-${COMMONADDONRELEASE}_signed.zip "${user}@${host}:/home/hitman/sites/backup/${revs}/Addon/non-config/arm64/BiTGApps-addon-photos-${COMMONADDONRELEASE}_signed.zip"
        $TARGET_VARIANT_TTS && rsync -a -v out/Addon/arm64/BiTGApps-addon-tts-${COMMONADDONRELEASE}_signed.zip "${user}@${host}:/home/hitman/sites/backup/${revs}/Addon/non-config/arm64/BiTGApps-addon-tts-${COMMONADDONRELEASE}_signed.zip"
        $TARGET_VARIANT_VANCED_MICROG && rsync -a -v out/Addon/arm64/BiTGApps-addon-vanced-microg-${COMMONADDONRELEASE}_signed.zip "${user}@${host}:/home/hitman/sites/backup/${revs}/Addon/non-config/arm64/BiTGApps-addon-vanced-microg-${COMMONADDONRELEASE}_signed.zip"
        # Common Packages
        $TARGET_VARIANT_CALCULATOR && rsync -a -v out/Addon/common/BiTGApps-addon-calculator-${COMMONADDONRELEASE}_signed.zip "${user}@${host}:/home/hitman/sites/backup/${revs}/Addon/non-config/all/BiTGApps-addon-calculator-${COMMONADDONRELEASE}_signed.zip"
        $TARGET_VARIANT_CALENDAR && rsync -a -v out/Addon/common/BiTGApps-addon-calendar-${COMMONADDONRELEASE}_signed.zip "${user}@${host}:/home/hitman/sites/backup/${revs}/Addon/non-config/all/BiTGApps-addon-calendar-${COMMONADDONRELEASE}_signed.zip"
        $TARGET_VARIANT_CHROME && rsync -a -v out/Addon/common/BiTGApps-addon-chrome-${COMMONADDONRELEASE}_signed.zip "${user}@${host}:/home/hitman/sites/backup/${revs}/Addon/non-config/all/BiTGApps-addon-chrome-${COMMONADDONRELEASE}_signed.zip"
        $TARGET_VARIANT_CONTACTS && rsync -a -v out/Addon/common/BiTGApps-addon-contacts-${COMMONADDONRELEASE}_signed.zip "${user}@${host}:/home/hitman/sites/backup/${revs}/Addon/non-config/all/BiTGApps-addon-contacts-${COMMONADDONRELEASE}_signed.zip"
        $TARGET_VARIANT_DESKCLOCK && rsync -a -v out/Addon/common/BiTGApps-addon-deskclock-${COMMONADDONRELEASE}_signed.zip "${user}@${host}:/home/hitman/sites/backup/${revs}/Addon/non-config/all/BiTGApps-addon-deskclock-${COMMONADDONRELEASE}_signed.zip"
        $TARGET_VARIANT_LAUNCHER && rsync -a -v out/Addon/common/BiTGApps-addon-launcher-${COMMONADDONRELEASE}_signed.zip "${user}@${host}:/home/hitman/sites/backup/${revs}/Addon/non-config/all/BiTGApps-addon-launcher-${COMMONADDONRELEASE}_signed.zip"
        $TARGET_VARIANT_MESSAGES && rsync -a -v out/Addon/common/BiTGApps-addon-messages-${COMMONADDONRELEASE}_signed.zip "${user}@${host}:/home/hitman/sites/backup/${revs}/Addon/non-config/all/BiTGApps-addon-messages-${COMMONADDONRELEASE}_signed.zip"
        $TARGET_VARIANT_SOUNDPICKER && rsync -a -v out/Addon/common/BiTGApps-addon-soundpicker-${COMMONADDONRELEASE}_signed.zip "${user}@${host}:/home/hitman/sites/backup/${revs}/Addon/non-config/all/BiTGApps-addon-soundpicker-${COMMONADDONRELEASE}_signed.zip"
        $TARGET_VARIANT_VANCED_ROOT && rsync -a -v out/Addon/common/BiTGApps-addon-vanced-root-${COMMONADDONRELEASE}_signed.zip "${user}@${host}:/home/hitman/sites/backup/${revs}/Addon/non-config/all/BiTGApps-addon-vanced-root-${COMMONADDONRELEASE}_signed.zip"
        $TARGET_VARIANT_VANCED_NONROOT && rsync -a -v out/Addon/common/BiTGApps-addon-vanced-nonroot-${COMMONADDONRELEASE}_signed.zip "${user}@${host}:/home/hitman/sites/backup/${revs}/Addon/non-config/all/BiTGApps-addon-vanced-nonroot-${COMMONADDONRELEASE}_signed.zip"
        $TARGET_VARIANT_WELLBEING && rsync -a -v out/Addon/common/BiTGApps-addon-wellbeing-${COMMONADDONRELEASE}_signed.zip "${user}@${host}:/home/hitman/sites/backup/${revs}/Addon/non-config/all/BiTGApps-addon-wellbeing-${COMMONADDONRELEASE}_signed.zip"
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
