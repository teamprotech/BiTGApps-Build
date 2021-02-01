#!/bin/bash
#
# Copyright (C) 2018-2021 TheHitMan7

# Clone this script using following commands
# curl https://raw.githubusercontent.com/BiTGApps/BiTGApps-Build/master/supload.sh > supload.sh
#
# Build kernel using following commands
# chmod +x supload.sh
# . supload.sh

function release() {
  read -p "Enter BREL: " BREL
  read -p "Enter AREL: " AREL
  read -p "Enter KREL: " KREL
}

function credentials() {
  read -p "Enter user: " user
  read -p "Enter host: " host
}

function gapps32() {
  read -p "Do you want to upload BiTGApps release for ARM platform (Y/N) ? " answer
  while true
  do
    case $answer in
     [yY]* ) scp out/arm/BiTGApps-arm-11.0.0-${BREL}_signed.zip ${user}@${host}:/home/dh_ddbfeb/bitgapps.com/downloads/arm/R
           scp out/arm/BiTGApps-arm-10.0.0-${BREL}_signed.zip ${user}@${host}:/home/dh_ddbfeb/bitgapps.com/downloads/arm/Q
           scp out/arm/BiTGApps-arm-9.0.0-${BREL}_signed.zip ${user}@${host}:/home/dh_ddbfeb/bitgapps.com/downloads/arm/Pie
           scp out/arm/BiTGApps-arm-8.1.0-${BREL}_signed.zip ${user}@${host}:/home/dh_ddbfeb/bitgapps.com/downloads/arm/Oreo
           scp out/arm/BiTGApps-arm-8.0.0-${BREL}_signed.zip ${user}@${host}:/home/dh_ddbfeb/bitgapps.com/downloads/arm/Oreo
           scp out/arm/BiTGApps-arm-7.1.2-${BREL}_signed.zip ${user}@${host}:/home/dh_ddbfeb/bitgapps.com/downloads/arm/Nougat
           scp out/arm/BiTGApps-arm-7.1.1-${BREL}_signed.zip ${user}@${host}:/home/dh_ddbfeb/bitgapps.com/downloads/arm/Nougat
           break;;
     [nN]* ) break;;
    esac
  done
}

function gapps64() {
  read -p "Do you want to upload BiTGApps release for ARM64 platform (Y/N) ? " answer
  while true
  do
    case $answer in
     [yY]* ) scp out/arm64/BiTGApps-arm64-11.0.0-${BREL}_signed.zip ${user}@${host}:/home/dh_ddbfeb/bitgapps.com/downloads/arm64/R
           scp out/arm64/BiTGApps-arm64-10.0.0-${BREL}_signed.zip ${user}@${host}:/home/dh_ddbfeb/bitgapps.com/downloads/arm64/Q
           scp out/arm64/BiTGApps-arm64-9.0.0-${BREL}_signed.zip ${user}@${host}:/home/dh_ddbfeb/bitgapps.com/downloads/arm64/Pie
           scp out/arm64/BiTGApps-arm64-8.1.0-${BREL}_signed.zip ${user}@${host}:/home/dh_ddbfeb/bitgapps.com/downloads/arm64/Oreo
           scp out/arm64/BiTGApps-arm64-8.0.0-${BREL}_signed.zip ${user}@${host}:/home/dh_ddbfeb/bitgapps.com/downloads/arm64/Oreo
           scp out/arm64/BiTGApps-arm64-7.1.2-${BREL}_signed.zip ${user}@${host}:/home/dh_ddbfeb/bitgapps.com/downloads/arm64/Nougat
           scp out/arm64/BiTGApps-arm64-7.1.1-${BREL}_signed.zip ${user}@${host}:/home/dh_ddbfeb/bitgapps.com/downloads/arm64/Nougat
           break;;
     [nN]* ) break;;
    esac
  done
}

function addonConfig64_32() {
  read -p "Do you want to upload BiTGApps Addon release config based (Y/N) ? " answer
  while true
  do
    case $answer in
     [yY]* ) scp out/arm/BiTGApps-addon-arm-${AREL}_signed.zip ${user}@${host}:/home/dh_ddbfeb/bitgapps.com/downloads/addon/config/arm
           scp out/arm64/BiTGApps-addon-arm64-${AREL}_signed.zip ${user}@${host}:/home/dh_ddbfeb/bitgapps.com/downloads/addon/config/arm64
           break;;
     [nN]* ) break;;
    esac
  done
}

function addonNonConfig64_32() {
  read -p "Do you want to upload BiTGApps Addon release non-config based (Y/N) ? " answer
  while true
  do
    case $answer in
     [yY]* ) scp out/common/BiTGApps-addon-assistant-${AREL}_signed.zip ${user}@${host}:/home/dh_ddbfeb/bitgapps.com/downloads/addon/non-config
           scp out/common/BiTGApps-addon-calculator-${AREL}_signed.zip ${user}@${host}:/home/dh_ddbfeb/bitgapps.com/downloads/addon/non-config
           scp out/common/BiTGApps-addon-calendar-${AREL}_signed.zip ${user}@${host}:/home/dh_ddbfeb/bitgapps.com/downloads/addon/non-config
           scp out/common/BiTGApps-addon-contacts-${AREL}_signed.zip ${user}@${host}:/home/dh_ddbfeb/bitgapps.com/downloads/addon/non-config
           scp out/common/BiTGApps-addon-deskclock-${AREL}_signed.zip ${user}@${host}:/home/dh_ddbfeb/bitgapps.com/downloads/addon/non-config
           scp out/common/BiTGApps-addon-dialer-${AREL}_signed.zip ${user}@${host}:/home/dh_ddbfeb/bitgapps.com/downloads/addon/non-config
           scp out/common/BiTGApps-addon-gboard-${AREL}_signed.zip ${user}@${host}:/home/dh_ddbfeb/bitgapps.com/downloads/addon/non-config
           scp out/common/BiTGApps-addon-markup-${AREL}_signed.zip ${user}@${host}:/home/dh_ddbfeb/bitgapps.com/downloads/addon/non-config
           scp out/common/BiTGApps-addon-messages-${AREL}_signed.zip ${user}@${host}:/home/dh_ddbfeb/bitgapps.com/downloads/addon/non-config
           scp out/common/BiTGApps-addon-photos-${AREL}_signed.zip ${user}@${host}:/home/dh_ddbfeb/bitgapps.com/downloads/addon/non-config
           scp out/common/BiTGApps-addon-soundpicker-${AREL}_signed.zip ${user}@${host}:/home/dh_ddbfeb/bitgapps.com/downloads/addon/non-config
           scp out/common/BiTGApps-addon-vanced-${AREL}_signed.zip ${user}@${host}:/home/dh_ddbfeb/bitgapps.com/downloads/addon/non-config
           scp out/common/BiTGApps-addon-wellbeing-${AREL}_signed.zip ${user}@${host}:/home/dh_ddbfeb/bitgapps.com/downloads/addon/non-config
           break;;
     [nN]* ) break;;
    esac
  done
}

function genericConfig() {
  read -p "Do you want to upload config files (Y/N) ? " answer
  while true
  do
    case $answer in
     [yY]* ) scp addon-config.prop ${user}@${host}:/home/dh_ddbfeb/bitgapps.com/downloads/config/Addon
           scp cts-config.prop ${user}@${host}:/home/dh_ddbfeb/bitgapps.com/downloads/config/Safetynet
           scp setup-config.prop ${user}@${host}:/home/dh_ddbfeb/bitgapps.com/downloads/config/SetupWizard
           break;;
     [nN]* ) break;;
    esac
  done
}

function androidAPK() {
  read -p "Do you want to upload BiTGApps apk (Y/N) ? " answer
  while true
  do
    case $answer in
     [yY]* ) scp BiTGApps-v${KREL}.apk ${user}@${host}:/home/dh_ddbfeb/bitgapps.com/downloads/APK
           break;;
     [nN]* ) break;;
    esac
  done
}

# Execute functions
release
credentials
gapps32
gapps64
addonConfig64_32
addonNonConfig64_32
genericConfig
androidAPK
