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
echo "---- Installation of Keexybox packages ----"
echo
rc=0
for app in bind dhcpd tor hostapd keexyapp; do
	#-------- CREATE APP DIRECTORY
	if [ ! -d "${KEEXYBOX_HOME}/${app}" ]; then
		mkdir "${KEEXYBOX_HOME}/${app}"
	fi

    if [ -f ${KEEXYBOX_PKG_DIR_PATH}/keexybox-${app}.tar.gz ]; then
	    #-------- DEPLOY APP
	    echo -n "Installing ${app} for Keexybox... "
	    tar xzf ${KEEXYBOX_PKG_DIR_PATH}/keexybox-${app}.tar.gz -C ${KEEXYBOX_HOME}/
        if [ $? -ne 0 ]; then
	        echo "Error while installing ${app}"
            rc=$(expr $rc + 1)
        else
	        echo "done"
        fi
    else
        echo "No package available to install ${app}"
    fi
done

if [ $rc -eq 0 ]; then
    exit 0
else
    exit 1
fi

