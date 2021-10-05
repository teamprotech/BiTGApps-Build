#!/bin/bash
#
##############################################################
# File name       : env_vars.sh
#
# Description     : Set environmental variables
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

# Set static environmental variables
. scripts/static_env_vars.sh

# Set runtime environmental variables
export COMMONGAPPSRELEASE="R39"
export COMMONADDONRELEASE="R27"
export GAPPS_RELEASE='"R39"'
export ADDON_RELEASE='"R27"'
export TARGET_DIRTY_INSTALL='"false"'
export TARGET_GAPPS_RELEASE='"39"'
export TARGET_RELEASE_TAG='"39"'
export GAPPS_RELEASE_TAG="39"
export COMMON_SYSTEM_LAYOUT='$S'
export TARGET_CONFIG_VERSION='"99"'
export BuildDate=`date +"%Y%m%d"`
export BuildID="R39"
export SERVER="ga"
