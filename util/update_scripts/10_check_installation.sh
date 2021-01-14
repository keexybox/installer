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

echo_red() {
	echo $(printf '\033[%sm%s\033[m\n' "31" "$1")
}
echo_green() {
	echo $(printf '\033[%sm%s\033[m\n' "32" "$1")
}

echo
echo "---- Check of Keexybox installation ----"
echo

mysql_cmd="mysql -u ${DATABASE_KEEXYBOX_USER} -p${DATABASE_KEEXYBOX_PASSWORD} ${DATABASE_KEEXYBOX_DATABASE}"
echo "exit" | $mysql_cmd > /dev/null 2>&1
conn_mdb=$?

if [ $conn_mdb -eq 0 ]; then
	exec_files=$(echo "SELECT value FROM config WHERE type='exec_file';" | ${mysql_cmd} | awk '{if (NR!=1) {print}}')
	config_files=$(echo "SELECT value FROM config WHERE type='config_file' AND param!='dhcp_conffile' AND param!='dhcp_reservations_conffile';" | ${mysql_cmd} | awk '{if (NR!=1) {print}}')
	dir_paths=$(echo "SELECT value FROM config WHERE type='dir_path';" | ${mysql_cmd} | awk '{if (NR!=1) {print}}')
	tcpip_ports=$(echo "SELECT value FROM config WHERE type='tcpip_port';" | ${mysql_cmd} | awk '{if (NR!=1) {print}}')

	# Initialize counters 
	exec_files_nok=0
	config_files_nok=0
	dir_paths_nok=0
	tcpip_ports_nok=0

	echo "Checking exec files:"
	for exec_file in $exec_files; do
		if [ -f $exec_file ]; then
			echo $exec_file : $(echo_green "OK")
		else
			echo $exec_file : $(echo_red "MISSING")
			exec_files_nok=$(expr $kxb_exec_files_nok + 1)
		fi
	done

	echo ""
	echo "Checking config files:"
	for config_file in $config_files; do
		if [ -f $config_file ]; then
			echo $config_file : $(echo_green "OK")
		else
			echo $config_file : $(echo_red "MISSING")
			config_files_nok=$(expr $kxb_config_files_nok + 1)
		fi
	done

	echo ""
	echo "Checking directories:"
	for dir_path in $dir_paths; do
		if [ -d $dir_path ]; then
			echo $dir_path : $(echo_green "OK") 
		else
			echo $dir_path : $(echo_red "MISSING")
			dir_paths_nok=$(expr $kxb_dir_paths_nok + 1)
		fi
	done

	#echo ""
	#echo "Checking ports:"
	#for tcpip_port in $tcpip_ports 80 443 53; do
	#	ss -H -ltun | awk -F' ' '{print $5}' | grep :${tcpip_port}$ > /dev/null 2>&1 
	#	res=$?
	#	if [ $res == 1 ]; then
	#		echo Port $tcpip_port : $(echo_green "OK")
	#	else
	#		echo Port $tcpip_port : $(echo_red "USED")
	#		tcpip_ports_nok=$(expr $kxb_tcpip_ports_nok + 1)
	#	fi
	#done

	#if [ $(expr $exec_file_nok + $config_files_nok + $dir_paths_nok + $tcpip_ports_nok) -gt 0 ]; then
	if [ $(expr $exec_file_nok + $config_files_nok + $dir_paths_nok) -gt 0 ]; then
		echo "-------------------------------------------------"
		echo "Some Keexybox component should not work properly."
		echo "Please run installation again."
		echo "-------------------------------------------------"
		exit 1
	else
		exit 0
	fi
else
	echo "Unable to check Keexybox installation!"
	exit 2

fi

