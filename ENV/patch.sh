#!/bin/bash
#
##############################################################
# File name       : patch.sh
#
# Description     : Set PATCH based environmental variables
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

set_env_patch() {
  if [ -f "out/ENV/env_patch.sh" ]; then
    if [ -n "$(cat out/ENV/env_patch.sh | grep TARGET_BOOTLOG_PACKAGE)" ]; then
      export TARGET_BOOTLOG_PACKAGE="true"
    else
      export TARGET_BOOTLOG_PACKAGE="false"
    fi
    if [ -n "$(cat out/ENV/env_patch.sh | grep TARGET_SAFETYNET_PACKAGE)" ]; then
      export TARGET_SAFETYNET_PACKAGE="true"
    else
      export TARGET_SAFETYNET_PACKAGE="false"
    fi
    if [ -n "$(cat out/ENV/env_patch.sh | grep TARGET_WHITELIST_PACKAGE)" ]; then
      export TARGET_WHITELIST_PACKAGE="true"
    else
      export TARGET_WHITELIST_PACKAGE="false"
    fi
  else
    echo "! PATCH script not found. Aborting..."
    exit 1
  fi
}

# Execute function
set_env_patch
