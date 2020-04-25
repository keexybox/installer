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
echo "---- Installation of required packages for Keexybox ----"
echo
rc=0

# Get list of package to install
required_packages_list="$(echo "$0" | awk -F"/" '{OFS="/"; $NF=""}1')/../required_packages.conf"
debs_to_install=$(for pkg in $(cat ${required_packages_list} | grep -v "^#"); do echo -n "$pkg ";done)

# Get Python modules to install
required_python_list="$(echo "$0" | awk -F"/" '{OFS="/"; $NF=""}1')/../required_python.conf"
pip_to_install=$(for pkg in $(cat ${required_python_list} | grep -v "^#"); do echo -n "$pkg ";done)

echo "Running apt-get update..."
apt-get update > /dev/null 2>&1 
rc=$(($rc + $?))

echo "Installing required packages from Debian apt repository..."

apt-get -y install $debs_to_install
rc=$(($rc + $?))

echo "Installing required Python modules..."

pip install ${pip_to_install}
rc=$(($rc + $?))

[[ $rc != 0 ]] && echo "Errors on installing required packages" && exit $rc
