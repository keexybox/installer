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
#----- TEST DB CONNEXION AS ROOT WITHOUT PASSWORD
mysql_cmd="mysql -u ${MARIADB_ROOT_LOGIN}"

create_database() {
	database=$1
	user=$2
	password=$3

	echo "CREATE DATABASE ${database}" | $mysql_cmd
	echo "GRANT ALL PRIVILEGES on ${database}.* to \"${user}\"@'localhost' IDENTIFIED BY \"${password}\";" | $mysql_cmd
	if [ "$?" -eq 0 ]; then
		$mysql_cmd ${database} < ${KEEXYBOX_SQL_DIR_PATH}/${database}.sql
		if [ "$?" -eq 0 ]; then
			echo "done"
		else
			echo "failed"
		fi
	fi
}


echo
echo "---- Keexybox databases initialization ----"
echo

echo "exit" | $mysql_cmd > /dev/null 2>&1
conn_mdb=$?
while [ "$conn_mdb" -ne 0 ]; do
	echo "Unable to connect to MariaDB as root!"
	echo -n "Please, give the MariaDB root password: "
	read -s maria_db_root_passwd
	mysql_cmd="mysql -u ${MARIADB_ROOT_LOGIN} -p'${maria_db_root_passwd}'"
	echo
	echo "exit" | $mysql_cmd > /dev/null 2>&1
	conn_mdb=$?
done

if [ $conn_mdb -eq 0 ]; then
	echo -n "${database} database initialization... "
	create_database ${DATABASE_KEEXYBOX_DATABASE} ${DATABASE_KEEXYBOX_USER} ${DATABASE_KEEXYBOX_PASSWORD}
	create_database ${DATABASE_KEEXYBOX_BLACKLIST_DATABASE} ${DATABASE_KEEXYBOX_BLACKLIST_USER} ${DATABASE_KEEXYBOX_BLACKLIST_PASSWORD}
	create_database ${DATABASE_KEEXYBOX_LOGS_DATABASE} ${DATABASE_KEEXYBOX_LOGS_USER} ${DATABASE_KEEXYBOX_LOGS_PASSWORD}

	echo -n "keexybox.config table initialization..."
	$mysql_cmd ${DATABASE_KEEXYBOX_DATABASE} < ${KEEXYBOX_SQL_DIR_PATH}/${DATABASE_KEEXYBOX_DATABASE}.config.sql
	if [ "$?" -eq 0 ]; then
		echo "done!"
	else
		echo "failed!"
	fi
fi
