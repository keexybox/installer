#!/bin/bash
#
# ***** BEGIN LICENSE BLOCK *****
# @author Benoit Saglietto <bsaglietto[AT]keexybox.org>
#
# @copyright Copyright (c) 2018, Benoit SAGLIETTO
# @license GPLv3
#
# This file is part of Keexybox project.

# Keexybox is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# Keexybox is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with Keexybox.	If not, see <http://www.gnu.org/licenses/>.
# ***** END LICENSE BLOCK *****
echo
echo "---- Setup of main Keexybox configuration file  ----"
echo
sed "s/CHANGE_DATABASE_KEEXYBOX_HOST/${DATABASE_KEEXYBOX_HOST}/g" ${KEEXYAPP_CFG_TEMPLATE} |
sed "s/CHANGE_DATABASE_KEEXYBOX_USER/${DATABASE_KEEXYBOX_USER}/g" |
sed "s/CHANGE_DATABASE_KEEXYBOX_PASSWORD/${DATABASE_KEEXYBOX_PASSWORD}/g" |
sed "s/CHANGE_DATABASE_KEEXYBOX_DATABASE/${DATABASE_KEEXYBOX_DATABASE}/g" |
sed "s/CHANGE_DATABASE_KEEXYBOX_BLACKLIST_HOST/${DATABASE_KEEXYBOX_BLACKLIST_HOST}/g" |
sed "s/CHANGE_DATABASE_KEEXYBOX_BLACKLIST_USER/${DATABASE_KEEXYBOX_BLACKLIST_USER}/g" |
sed "s/CHANGE_DATABASE_KEEXYBOX_BLACKLIST_PASSWORD/${DATABASE_KEEXYBOX_BLACKLIST_PASSWORD}/g" |
sed "s/CHANGE_DATABASE_KEEXYBOX_BLACKLIST_DATABASE/${DATABASE_KEEXYBOX_BLACKLIST_DATABASE}/g" |
sed "s/CHANGE_DATABASE_KEEXYBOX_LOGS_HOST/${DATABASE_KEEXYBOX_LOGS_HOST}/g" |
sed "s/CHANGE_DATABASE_KEEXYBOX_LOGS_USER/${DATABASE_KEEXYBOX_LOGS_USER}/g" |
sed "s/CHANGE_DATABASE_KEEXYBOX_LOGS_PASSWORD/${DATABASE_KEEXYBOX_LOGS_PASSWORD}/g" |
sed "s/CHANGE_DATABASE_KEEXYBOX_LOGS_DATABASE/${DATABASE_KEEXYBOX_LOGS_DATABASE}/g" > ${KEEXYAPP_CFG}

if [ $? -eq 0 ]; then 
	echo "done!"
	exit 0
else
	echo "failed!"
	exit 1
fi


