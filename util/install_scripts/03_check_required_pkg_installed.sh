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
echo "---- Checking installation of required packages for Keexybox ----"
echo
rc=0

echo_red() {
	echo $(printf '\033[%sm%s\033[m\n' "31" "$1")
}
echo_green() {
	echo $(printf '\033[%sm%s\033[m\n' "32" "$1")
}

# Get list of package to install
required_packages_list="$(echo "$0" | awk -F"/" '{OFS="/"; $NF=""}1')/../required_packages.conf"

# Get Python modules to install
required_python_list="$(echo "$0" | awk -F"/" '{OFS="/"; $NF=""}1')/../required_python.conf"


# Set number of uninstalled requid package
install_nok=0

echo "Checking installed packages"
for pkg in $(cat ${required_packages_list} | grep -v "^#"); do
	dpkg -l $pkg > /dev/null 2>&1
	res=$?
	if [ $res -eq 0 ]; then
		echo "$pkg: $(echo_green "OK")"
	else
		echo "$pkg: $(echo_red "FAILED")"
		install_nok=$(expr $install_nok + 1)
	fi
done

# directly exit if first check is not ok
if [ $install_nok -gt 0 ]; then
	exit 1
fi

echo 
echo "Checking installed python modules"
for pmod in $(cat $required_python_list | grep -v "^#"); do
	pip show $pmod > /dev/null 2>&1
	res=$?
	if [ $res -eq 0 ]; then
		echo "$pmod: $(echo_green "OK")"
	else
		echo "$pmod: $(echo_red "FAILED")"
		install_nok=$(expr $install_nok + 1)
	fi
done

if [ $install_nok -gt 0 ]; then
	echo
	echo "-----------------------------------------------"
	echo "Some required packages for Keexybox are missing"
	echo "Installation aborted!"
	echo "-----------------------------------------------"
	echo
	exit 1
else
	exit 0
fi

