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

mysql_cmd="mysql -u ${DATABASE_KEEXYBOX_USER} -p${DATABASE_KEEXYBOX_PASSWORD} ${DATABASE_KEEXYBOX_DATABASE}"
echo "exit" | $mysql_cmd > /dev/null 2>&1
conn_mdb=$?

if [ $conn_mdb -eq 0 ]; then
	# Get some settings to show message on success
	admin_https_port=$(echo "SELECT value FROM config WHERE param='apache_admin_https_port' LIMIT 1;" | ${mysql_cmd} | awk '{if (NR!=1) {print}}')
	admin_http_port=$(echo "SELECT value FROM config WHERE param='apache_admin_port' LIMIT 1;" | ${mysql_cmd} | awk '{if (NR!=1) {print}}')
	host_ip_output=$(echo "SELECT value FROM config WHERE param='host_ip_output' LIMIT 1;" | ${mysql_cmd} | awk '{if (NR!=1) {print}}')
	MESSAGE="
Congratulation ! Keexybox updated successfully.

Your keexybox addresses are the following :

 * http://${host_ip_output}:${admin_http_port}
 * https://${host_ip_output}:${admin_https_port}
"

	if [ "$use_whiptail" = "yes" ];then
		whiptail --backtitle "Keexybox installation" --title "Installation result" --msgbox "$MESSAGE" 15 100
	else
		echo "-------------------------------------------------"
		echo "$MESSAGE"
		echo "-------------------------------------------------"
	fi
	exit 0
else
	exit 1
fi

