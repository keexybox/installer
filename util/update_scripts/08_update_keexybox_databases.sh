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
#
# This script run only if naming convention is respected for SQL files for update
# The file naming convention is in 4 parts seperated by "_"
#  - prefix name
#  - number 4 digits: it is for the sorting of SQL. This number should be uniq and incremented by 1 for each new sql file
#  - current version of Keexybox database
#  - target version of Keexybox database
#
# For example :
# keexybox_0001_1.0.0_1.0.1.sql
# keexybox_0002_1.0.1_1.0.2.sql
# keexybox_0003_1.0.2_11.5.1.sql
#
# This script will import as many SQL files to update database from current Keexybox version 

#mysql_cmd="mysql -u ${MARIADB_ROOT_LOGIN}"

#KEEXYBOX_CURRENT_VERSION=1.0.0
#KEEXYBOX_NEW_VERSION=11.5.1

SQL_UPDATES_PATH="/root/keexybox_install/util/sql/sql_update/"

update_database() {
	database=$1
	user=$2
	password=$3
	file_prefix=$4

	if [ ${KEEXYBOX_CURRENT_VERSION} != ${KEEXYBOX_NEW_VERSION} ]; then
		sql_file_num=$(find -name "${database}_*_${KEEXYBOX_CURRENT_VERSION}_*.sql" | sed "s/.\///g"  | head -n 1 | cut -d"_" -f2)
		sql_last_file_num=$(find -name "${database}_*_*_${KEEXYBOX_NEW_VERSION}.sql" | sed "s/.\///g"  | head -n 1 | cut -d"_" -f2)
	
		sql_file_to_update=$(find ${SQL_UPDATES_PATH} -name "${database}_${sql_file_num}*" | head -n 1)

		while [ "${sql_file_to_update}" != "" ]; do
			echo "updating: ${sql_file_to_update}"
			if [ "${sql_file_to_update}" != "" ]; then
				echo "mysql -u${user} -p${password} ${database} < ${sql_file_to_update}"
			fi
			sql_file_num=$(printf %04d $(expr $sql_file_num + 1))
			sql_file_to_update=$(find ${SQL_UPDATES_PATH} -name "${database}_${sql_file_num}*" | head -n 1)
		done
	fi
}

echo
echo "---- Update of Keexybox databases  ----"
echo
cd $SQL_UPDATES_PATH
update_database ${DATABASE_KEEXYBOX_DATABASE} ${DATABASE_KEEXYBOX_USER} ${DATABASE_KEEXYBOX_PASSWORD} keexybox
update_database ${DATABASE_KEEXYBOX_BLACKLIST_DATABASE} ${DATABASE_KEEXYBOX_BLACKLIST_USER} ${DATABASE_KEEXYBOX_BLACKLIST_PASSWORD} keexyboxblacklist
update_database ${DATABASE_KEEXYBOX_LOGS_DATABASE} ${DATABASE_KEEXYBOX_LOGS_USER} ${DATABASE_KEEXYBOX_LOGS_PASSWORD} keexyboxlogs
