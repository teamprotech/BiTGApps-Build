#!/bin/bash
#
##############################################################
# File name       : api.sh
#
# Description     : Set API based environmental variables
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

set_env_api() {
  if [ -f "out/ENV/env_api.sh" ]; then
    if [ -n "$(cat out/ENV/env_api.sh | grep TARGET_API_25)" ]; then
      export TARGET_API_25="true"
    else
      export TARGET_API_25="false"
    fi
    if [ -n "$(cat out/ENV/env_api.sh | grep TARGET_API_26)" ]; then
      export TARGET_API_26="true"
    else
      export TARGET_API_26="false"
    fi
    if [ -n "$(cat out/ENV/env_api.sh | grep TARGET_API_27)" ]; then
      export TARGET_API_27="true"
    else
      export TARGET_API_27="false"
    fi
    if [ -n "$(cat out/ENV/env_api.sh | grep TARGET_API_28)" ]; then
      export TARGET_API_28="true"
    else
      export TARGET_API_28="false"
    fi
    if [ -n "$(cat out/ENV/env_api.sh | grep TARGET_API_29)" ]; then
      export TARGET_API_29="true"
    else
      export TARGET_API_29="false"
    fi
    if [ -n "$(cat out/ENV/env_api.sh | grep TARGET_API_30)" ]; then
      export TARGET_API_30="true"
    else
      export TARGET_API_30="false"
    fi
  else
    echo "! API script not found. Aborting..."
    exit 1
  fi
}

# Execute function
set_env_api
