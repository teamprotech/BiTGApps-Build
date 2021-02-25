#!/bin/bash
#
##############################################################
# File name       : platform.sh
#
# Description     : Set Platform based environmental variables
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

set_env_platform() {
  if [ -f "out/ENV/env_platform.sh" ]; then
    if [ -n "$(cat out/ENV/env_platform.sh | grep TARGET_PLATFORM_ARM)" ]; then
      export TARGET_PLATFORM_ARM="true"
    else
      export TARGET_PLATFORM_ARM="false"
    fi
    if [ -n "$(cat out/ENV/env_platform.sh | grep TARGET_PLATFORM_ARM64)" ]; then
      export TARGET_PLATFORM_ARM64="true"
    else
      export TARGET_PLATFORM_ARM64="false"
    fi
  else
    echo "! Platform script not found. Aborting..."
    exit 1
  fi
}

# Execute function
set_env_platform
