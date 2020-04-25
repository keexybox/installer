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
echo "---- Creation of keexybox admin account ----"
echo
echo -n "Creating Keexybox admin account... "
${KXB_CMD} users UpdateAdminPassword ${KEEXYBOX_ADMIN_PASSWORD}
[[ $? -eq 0 ]] && echo "done!" || echo "failed!"
echo -n "Setup Keexybox default profile... "
${KXB_CMD} profiles ResetDefaultProfile
[[ $? -eq 0 ]] && echo "done!" || echo "failed!"
