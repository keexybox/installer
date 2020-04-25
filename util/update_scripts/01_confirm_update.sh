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
# Check if whiptail exist
if [ -f "/usr/bin/whiptail" ]; then
	use_whiptail="yes"
else
	use_whiptail="no"
fi

echo
echo "---- Confirm installation ----"
echo

CONFIRM_MSG="Keexybox will be updated from version 
${KEEXYBOX_CURRENT_VERSION} to ${KEEXYBOX_NEW_VERSION}

Do you confirm the update ?"

if [ "$use_whiptail" = "yes" ];then
	whiptail --backtitle "Keexybox installation" --title "Confirm installation" --defaultno --yesno "$CONFIRM_MSG" 10 50 
	answer=$?
	[[ $answer -eq 0 ]] && confirm_install="y" || confirm_install="n"
else
	echo -n "$CONFIRM_MSG [y/N] "
	read confirm_install
fi

if [ "$confirm_install" = "y" -o "$confirm_install" = "Y" ]
then
	exit "0"
else
	exit "1"
fi
