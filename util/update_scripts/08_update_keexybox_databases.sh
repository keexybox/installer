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
# This script import all SQL files from current database version to new version
#
# It works only if naming convention is respected for SQL files for update.
# The convention is : 
#    <database_name>_db_from_<current_version>_to_<new_version>.sql
#
# "database_name" is the database name
# "current_version" is the current database version
# "new_version" is the target version database version
#

# Uncomment for testing
#KEEXYBOX_CURRENT_VERSION="20.04.6"
#KEEXYBOX_NEW_VERSION="20.04.6"

KEEXYBOX_HOME="/opt/keexybox"
SQL_UPDATES_PATH="${KEEXYBOX_HOME}/keexyapp/config/schema/updates/"

update_database() {
	database=$1
	user=$2
	password=$3
	file_prefix=$4

    if [ ${KEEXYBOX_CURRENT_VERSION} != ${KEEXYBOX_NEW_VERSION} -a ${KEEXYBOX_CURRENT_VERSION} != "" -a ${KEEXYBOX_NEW_VERSION} != "" ]; then
        sql_files_list=$(ls -1v ${database}_db_from_*_to_*.sql 2> /dev/null | grep -A 999999999 from_${KEEXYBOX_CURRENT_VERSION} | grep -B 999999999 to_${KEEXYBOX_NEW_VERSION})

        for sql_file in ${sql_files_list}; do
            echo "updating: ${sql_file}"
		    if [ "${sql_file}" != "" ]; then
		    	mysql -u${user} -p${password} ${database} < ${sql_file}
			fi
        done
    else
        echo "Nothing to update for database ${database}!"
    fi
}

echo
echo "---- Update of Keexybox databases  ----"
echo
cd $SQL_UPDATES_PATH
update_database ${DATABASE_KEEXYBOX_DATABASE} ${DATABASE_KEEXYBOX_USER} ${DATABASE_KEEXYBOX_PASSWORD} keexybox
update_database ${DATABASE_KEEXYBOX_BLACKLIST_DATABASE} ${DATABASE_KEEXYBOX_BLACKLIST_USER} ${DATABASE_KEEXYBOX_BLACKLIST_PASSWORD} keexybox_blacklist
update_database ${DATABASE_KEEXYBOX_LOGS_DATABASE} ${DATABASE_KEEXYBOX_LOGS_USER} ${DATABASE_KEEXYBOX_LOGS_PASSWORD} keexybox_logs
mysql -u${DATABASE_KEEXYBOX_USER} -p${DATABASE_KEEXYBOX_PASSWORD} ${DATABASE_KEEXYBOX_DATABASE} < "${KEEXYBOX_HOME}/keexyapp/config/keexybox.config.${HW_ARCH}.sql"
