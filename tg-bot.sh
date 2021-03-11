#!/bin/bash
#
##############################################################
# File name       : tg-bot.sh
#
# Description     : Send message from server to telegram
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

export CHAT_ID="${CHAT_ID}"

function message()
{
  for chat in $CHAT_ID
    do
      curl -s "https://api.telegram.org/bot${BOT_API}/sendmessage" --data "text=${*}&chat_id=$CHAT_ID&parse_mode=Markdown" > /dev/null
    done
  echo -e
}

message "Hello World!"
