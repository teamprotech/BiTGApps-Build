#!/bin/bash
#
##############################################################
# File name       : env_vars.sh
#
# Description     : Set environmental variables
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

# Set static environmental variables
. scripts/static_env_vars.sh

# Set release tag in all GApps build file
export COMMONGAPPSRELEASE=""

# Set release tag in all Addons build file
export COMMONADDONRELEASE=""

# Set GApps package release tag; Used by installer
export GAPPS_RELEASE='""'

# Set Addon package release tag; Used by installer
export ADDON_RELEASE='""'

# Set deprecated package release tag; Used by installer
export TARGET_GAPPS_RELEASE='""'

# Set dirty install target; Used by installer
export TARGET_DIRTY_INSTALL='""'

# Set release tag; Used by installer
export TARGET_RELEASE_TAG='""'

# Set release tag; Used by OTA script
export GAPPS_RELEASE_TAG=""

# Set system layout for release tag function; used by build script
export COMMON_SYSTEM_LAYOUT=''

# Set release date; Used by build property file
export BuildDate=""

# Set release tag; Used by build property file
export BuildID=""

# Set hosting server; Used by release script
export SERVER=""

# Set "1" for test release else leave empty; Used by release script
export TESTRELEASE=""

# Set ZIP file token; used by build script
export TOKEN=""

# Set APK release tag; Used by release script
export APKRELEASE=""

# Set Addon config for upload
export TARGET_CONFIG_ADDON="false"

# Set Boot log config for upload
export TARGET_CONFIG_BOOT="false"

# Set CTS config for upload
export TARGET_CONFIG_CTS="false"

# Set SetupWizard config for upload
export TARGET_CONFIG_SETUP="false"

# Set Uninstall config for upload
export TARGET_CONFIG_WIPE="false"
