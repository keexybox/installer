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
echo "---- Creation of keexybox user on the system ----"
echo
useradd -m -s /bin/bash -d ${KEEXYBOX_HOME} ${KEEXYBOX_SYSUSER}
res_usr_create=$?
#chown -R ${KEEXYBOX_SYSUSER}:${KEEXYBOX_SYSUSER} ${KEEXYBOX_HOME}
mkdir -p ${KEEXYBOX_HOME}/logs
mkdir -p ${KEEXYBOX_HOME}/tmp

if [ $res_usr_create -eq 0 ]; then
	echo "done!"
else
	echo "failed!"
fi
