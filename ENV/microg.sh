#!/bin/bash
#
##############################################################
# File name       : microg.sh
#
# Description     : Set API based environmental variables
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

set_env_api() {
  if [ -f "out/ENV/env_api.sh" ]; then
    if [ -n "$(cat out/ENV/env_api.sh | grep MICROG_API_25)" ]; then
      export MICROG_API_25="true"
    else
      export MICROG_API_25="false"
    fi
    if [ -n "$(cat out/ENV/env_api.sh | grep MICROG_API_26)" ]; then
      export MICROG_API_26="true"
    else
      export MICROG_API_26="false"
    fi
    if [ -n "$(cat out/ENV/env_api.sh | grep MICROG_API_27)" ]; then
      export MICROG_API_27="true"
    else
      export MICROG_API_27="false"
    fi
    if [ -n "$(cat out/ENV/env_api.sh | grep MICROG_API_28)" ]; then
      export MICROG_API_28="true"
    else
      export MICROG_API_28="false"
    fi
    if [ -n "$(cat out/ENV/env_api.sh | grep MICROG_API_29)" ]; then
      export MICROG_API_29="true"
    else
      export MICROG_API_29="false"
    fi
    if [ -n "$(cat out/ENV/env_api.sh | grep MICROG_API_30)" ]; then
      export MICROG_API_30="true"
    else
      export MICROG_API_30="false"
    fi
    if [ -n "$(cat out/ENV/env_api.sh | grep MICROG_API_31)" ]; then
      export MICROG_API_31="true"
    else
      export MICROG_API_31="false"
    fi
  else
    echo "! MicroG API script not found. Aborting..."
    exit 1
  fi
}

# Execute function
set_env_api
