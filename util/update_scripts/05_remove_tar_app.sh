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
echo "---- Removing installed Keexybox packages ----"
echo
for app in bind dhcpd tor; do
	echo -n "Removing ${app}... "
	rm -rf ${KEEXYBOX_HOME}/${app}
	echo "done"
done
# Saving keexyapp and scripts in case of fail update and still able to get information of current installation
for app in keexyapp; do
	echo -n "Removing ${app}... "
	if [ ! -d ${KEEXYBOX_HOME}/${app}_old/ ]; then
		mkdir -p ${KEEXYBOX_HOME}/${app}_old >> /dev/null 2>&1
		mv -f ${KEEXYBOX_HOME}/${app} ${KEEXYBOX_HOME}/${app}_old
		echo "done"
	fi
done
