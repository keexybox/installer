#!/bin/bash
#
# ***** BEGIN LICENSE BLOCK *****
# @author Benoit Saglietto <bsaglietto[AT]keexybox.org>
#
# @copyright Copyright (c) 2021, Benoit SAGLIETTO
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

#-------- CHECK IF THIS SCRIPT IS RUNNING AS ROOT OR AS KEEXYBOX USER
user_inst=''
if [ $(id -u) -eq 0 ]; then
    user_inst='root'
elif [ $USER == 'keexybox' ]; then
    user_inst='keexybox'
    echo "ok keexybox"
else
	echo "This install script must be run as root or keexybox!"
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

MODULES_DIR_PATH="./update_scripts"

#-------- IF ROOT CONFIRM THE INSTALLATION
if [ $user_inst == 'root' ]; then
    ${MODULES_DIR_PATH}/01_confirm_update.sh

    confirm_install=$?

    if [ ${confirm_install} -ne 0 ]; then
	    echo
	    echo "Update aborted!"
	    echo
	    exit 0
    fi
fi

if [ $user_inst == 'root' ]; then
    ${MODULES_DIR_PATH}/02_stop_keexybox.sh
fi

#-------- SCRIPT TO INSTALL PACKAGES
# Set location of tar.gz sources
export KEEXYBOX_PKG_DIR_PATH="../install_pkg/"

#-------- IF ROOT UPDATE/INSTALL REQUIRED PACKAGES 
if [ $user_inst == 'root' ]; then
    # Install packages and Python modules
    ${MODULES_DIR_PATH}/03_install_required_pkg.sh
fi

#-------- CHECK INSTALLED REQUIRED PACKAGES
# Check packages and Python modules installation
${MODULES_DIR_PATH}/04_check_required_pkg_installed.sh
if [ $? -ne 0 ]; then
	exit 1
fi

#---- removing app
#${MODULES_DIR_PATH}/05_remove_tar_app.sh

# Install provided Keexybox packages
${MODULES_DIR_PATH}/06_deploy_tar_app.sh

${MODULES_DIR_PATH}/07_create_keexyapp_config_file.sh

${MODULES_DIR_PATH}/08_update_keexybox_databases.sh

#-------- RUN SCRIPT TO GENERATE CONFIG FILES AND SET PERMISSIONS
${MODULES_DIR_PATH}/09_gen_keexybox_config.sh

#-------- RUN SCRIPT TO FINISH INSTALLATION
${MODULES_DIR_PATH}/10_check_installation.sh
if [ $? -eq 0 ]; then
	${MODULES_DIR_PATH}/11_start_keexybox.sh
	${MODULES_DIR_PATH}/12_remove_keexybox_backup.sh
	${MODULES_DIR_PATH}/13_display_installation_result.sh
else
	exit 1
fi
