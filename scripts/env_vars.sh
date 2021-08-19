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
export COMMONGAPPSRELEASE="R37"
export COMMONADDONRELEASE="R25"
export GAPPS_RELEASE='"R37"'
export ADDON_RELEASE='"R25"'
export TARGET_DIRTY_INSTALL='"true"'
export TARGET_GAPPS_RELEASE='"37"'
export TARGET_RELEASE_TAG='"37"'
export GAPPS_RELEASE_TAG="37"
export COMMON_SYSTEM_LAYOUT='$S'
export TARGET_CONFIG_VERSION='"19"'
export BuildDate=`date +"%Y%m%d"`
export BuildID="R37"
export SERVER="ga"
