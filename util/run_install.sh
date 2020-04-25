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

#-------- CHECK IF THIS SCRIPT IS RUNNING AS ROOT
if [ $(id -u) -ne 0 ]; then
	echo "This install script must be run as root!"
	exit 1
fi

if [ $1 ]; then
	install_conf=$1
else
	echo "You must specify the configuration file!"
	exit 1
fi

#-------- LOADING CONFIGURATION FILE
if [ -f $install_conf ]; then
	. ${install_conf}
else
	echo "No such configuration file!"
	exit 1
fi

#-------- RUN INSTALLATION FROM DIRECTORY THAT CONTAINS INSTALLATION SOURCES
install_script_dir=$(echo "$0" | awk -F"/" '{OFS="/"; $NF=""}1')
cd $install_script_dir

MODULES_DIR_PATH="./install_scripts"

${MODULES_DIR_PATH}/01_confirm_installation.sh

confirm_install=$?

if [ ${confirm_install} -ne 0 ]; then
	echo
	echo "Installation aborted!"
	echo
	exit 0
fi

#-------- SCRIPT TO INSTALL PACKAGES
# Set location of tar.gz sources
export KEEXYBOX_PKG_DIR_PATH="../install_pkg/"

# Install packages and Python modules
${MODULES_DIR_PATH}/02_install_required_pkg.sh

# Check packages and Python modules installation
${MODULES_DIR_PATH}/03_check_required_pkg_installed.sh
if [ $? -ne 0 ]; then
	exit 1
fi

#-------- SCRIPT TO CREATE KEEXYBOX SYSTEM USER
${MODULES_DIR_PATH}/04_create_keexybox_sysuser.sh

# Install provided Keexybox packages
${MODULES_DIR_PATH}/05_deploy_tar_app.sh

#-------- SCRIPT TO INITIALIZE KEEXYBOX DATABASES
# Set location of sql files
#export KEEXYBOX_SQL_DIR_PATH="./sql/"
export KEEXYBOX_SQL_DIR_PATH="/opt/keexybox/keexyapp/config/schema/"
${MODULES_DIR_PATH}/06_initialize_keexybox_databases.sh

#-------- SCRIPT TO SETUP KEEXYAPP CONFIG
${MODULES_DIR_PATH}/07_create_keexyapp_config_file.sh

#-------- RUN SCRIPT TO CREATE KEEXYBOX ADMIN ACCOUNT AND DEFAULT PROFILE
${MODULES_DIR_PATH}/08_set_keexybox_admin_account.sh

#-------- RUN SCRIPT TO UPDATE KEEXYBOX CONFIG
${MODULES_DIR_PATH}/09_set_keexybox_config.sh

#-------- RUN SCRIPT TO GENERATE CONFIG FILES AND SET PERMISSIONS
${MODULES_DIR_PATH}/10_gen_keexybox_config.sh

#-------- RUN SCRIPT TO FINISH INSTALLATION
${MODULES_DIR_PATH}/11_check_installation.sh
if [ $? -eq 0 ]; then
	${MODULES_DIR_PATH}/12_start_keexybox.sh
	${MODULES_DIR_PATH}/13_display_installation_result.sh
fi

