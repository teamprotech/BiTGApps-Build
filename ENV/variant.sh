#!/bin/bash
#
##############################################################
# File name       : variant.sh
#
# Description     : Set Variant based environmental variables
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

set_env_variant() {
  if [ -f "out/ENV/env_variant.sh" ]; then
    if [ -n "$(cat out/ENV/env_variant.sh | grep TARGET_VARIANT_ASSISTANT)" ]; then
      export TARGET_VARIANT_ASSISTANT="true"
    else
      export TARGET_VARIANT_ASSISTANT="false"
    fi
    if [ -n "$(cat out/ENV/env_variant.sh | grep TARGET_VARIANT_CALCULATOR)" ]; then
      export TARGET_VARIANT_CALCULATOR="true"
    else
      export TARGET_VARIANT_CALCULATOR="false"
    fi
    if [ -n "$(cat out/ENV/env_variant.sh | grep TARGET_VARIANT_CALENDAR)" ]; then
      export TARGET_VARIANT_CALENDAR="true"
    else
      export TARGET_VARIANT_CALENDAR="false"
    fi
    if [ -n "$(cat out/ENV/env_variant.sh | grep TARGET_VARIANT_CHROME)" ]; then
      export TARGET_VARIANT_CHROME="true"
    else
      export TARGET_VARIANT_CHROME="false"
    fi
    if [ -n "$(cat out/ENV/env_variant.sh | grep TARGET_VARIANT_CONTACTS)" ]; then
      export TARGET_VARIANT_CONTACTS="true"
    else
      export TARGET_VARIANT_CONTACTS="false"
    fi
    if [ -n "$(cat out/ENV/env_variant.sh | grep TARGET_VARIANT_DESKCLOCK)" ]; then
      export TARGET_VARIANT_DESKCLOCK="true"
    else
      export TARGET_VARIANT_DESKCLOCK="false"
    fi
    if [ -n "$(cat out/ENV/env_variant.sh | grep TARGET_VARIANT_DIALER)" ]; then
      export TARGET_VARIANT_DIALER="true"
    else
      export TARGET_VARIANT_DIALER="false"
    fi
    if [ -n "$(cat out/ENV/env_variant.sh | grep TARGET_VARIANT_GBOARD)" ]; then
      export TARGET_VARIANT_GBOARD="true"
    else
      export TARGET_VARIANT_GBOARD="false"
    fi
    if [ -n "$(cat out/ENV/env_variant.sh | grep TARGET_VARIANT_GEARHEAD)" ]; then
      export TARGET_VARIANT_GEARHEAD="true"
    else
      export TARGET_VARIANT_GEARHEAD="false"
    fi
    if [ -n "$(cat out/ENV/env_variant.sh | grep TARGET_VARIANT_MARKUP)" ]; then
      export TARGET_VARIANT_MARKUP="true"
    else
      export TARGET_VARIANT_MARKUP="false"
    fi
    if [ -n "$(cat out/ENV/env_variant.sh | grep TARGET_VARIANT_MESSAGES)" ]; then
      export TARGET_VARIANT_MESSAGES="true"
    else
      export TARGET_VARIANT_MESSAGES="false"
    fi
    if [ -n "$(cat out/ENV/env_variant.sh | grep TARGET_VARIANT_PHOTOS)" ]; then
      export TARGET_VARIANT_PHOTOS="true"
    else
      export TARGET_VARIANT_PHOTOS="false"
    fi
    if [ -n "$(cat out/ENV/env_variant.sh | grep TARGET_VARIANT_SOUNDPICKER)" ]; then
      export TARGET_VARIANT_SOUNDPICKER="true"
    else
      export TARGET_VARIANT_SOUNDPICKER="false"
    fi
    if [ -n "$(cat out/ENV/env_variant.sh | grep TARGET_VARIANT_VANCED)" ]; then
      export TARGET_VARIANT_VANCED="true"
    else
      export TARGET_VARIANT_VANCED="false"
    fi
    if [ -n "$(cat out/ENV/env_variant.sh | grep TARGET_VARIANT_WELLBEING)" ]; then
      export TARGET_VARIANT_WELLBEING="true"
    else
      export TARGET_VARIANT_WELLBEING="false"
    fi
  else
    echo "! Variant script not found. Aborting..."
    exit 1
  fi
}

# Execute function
set_env_variant
