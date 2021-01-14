#!/bin/bash
#
# ***** BEGIN LICENSE BLOCK *****
# @author Benoit Saglietto <bsaglietto[AT]keexybox.org>
#
# @copyright Copyright (c) 2020, Benoit SAGLIETTO
# @license GPLv3
#
# This file is part of KeexyBox project.

# KeexyBox is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# KeexyBox is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with KeexyBox.	If not, see <http://www.gnu.org/licenses/>.
# ***** END LICENSE BLOCK *****
#
# Title of installation
BACKTITLE="KeexyBox installation"

# IP address used to check routing settings
TESTING_IP_FOR_ROUTING="8.8.8.8"

# Domain used to test internet connection
TESTING_DOMAIN_FOR_INTERNET="www.google.com"

# KeexyBox version check script
KEEXYBOX_VER_FILE="/opt/keexybox/keexyapp/src/keexybox_version"
if [ ! -f ${KEEXYBOX_VER_FILE} ]; then
	KEEXYBOX_VER_FILE="/opt/keexybox/keexyapp_old/src/keexybox_version"
fi

# Name of config file to create for new installation
INSTALL_CONF="./install.conf"

# Name of config file to create for update
UPDATE_CONF="./update.conf"
	
# Default KeexyBox home dir
KEEXYBOX_HOME="/opt/keexybox"

# KeexyBox version beeing installed
KEEXYBOX_NEW_VERSION="20.10.1"

# This function required to converts cidr to IP mask.
# Example : it converts /24 to 255.255.255.0
cidr2mask() {
    cidr=$1
	cidr_zeros=$(expr 32 - ${cidr})
	mask_bin=""
	mask_zeros=""
    mask_dec=""

	# create binary string bits with 1
	for bit in $(seq ${cidr})
	do
		mask_bin="${mask_bin}1"
	done

	# complete missing bits with 0
	for bit in $(seq ${cidr_zeros})
	do
		mask_bin="${mask_bin}0"
	done

	# split 32 bits into 4 parts to get 4 bytes
	# then convert into decimal and concatenate each bytes seperate by dots
	for byte in $(echo $mask_bin | fold -w8)
	{
		mask_dec="${mask_dec}$((2#${byte}))."
	}
	# Define mask and remove last dot
	mask=$(echo ${mask_dec} | sed 's/\.$//g')
	echo ${mask}
}

# This function gets DNS current config
set_dns_config() {
	dns[1]=""
	dns[2]=""
    dnsid=1
    for dns in $(grep ^nameserver /etc/resolv.conf | sed 's/nameserver //g'); do
        dns[$dnsid]=$dns
		dnsid=$(expr $dnsid + 1)
    done
}

########################################
####### PASSWORD SET ######
########################################

PASSWORD_TITLE="Admin password"

# MESSAGES TO SET KEEXYBOX ADMIN PASSWORD
MSG_KEEXYBOX_ADMIN_PASSWORD="Please set keexybox admin password"
MSG_CONFIRM_KEEXYBOX_ADMIN_PASSWORD="confirm password"
MSG_ERR_KEEXYBOX_ADMIN_PASSWORD="The given password does not match or does not contain at least 8 characters, please try again."

# This function prompt the user with whiptail to set keexybox admin password
whiptail_ask_admin_password() {
	KEEXYBOX_ADMIN_PASSWORD=$(whiptail --backtitle "$BACKTITLE" --title "$PASSWORD_TITLE" --passwordbox "$MSG_KEEXYBOX_ADMIN_PASSWORD" 10 40 3>&1 1>&2 2>&3)
	[[ $? -eq 1 ]] && exit
	CONFIRM_KEEXYBOX_ADMIN_PASSWORD=$(whiptail --backtitle "$BACKTITLE" --title "$PASSWORD_TITLE" --passwordbox "$MSG_CONFIRM_KEEXYBOX_ADMIN_PASSWORD" 10 40 3>&1 1>&2 2>&3)
	[[ $? -eq 1 ]] && exit

	# Ak password until it match
	while [[ "${KEEXYBOX_ADMIN_PASSWORD}" != "${CONFIRM_KEEXYBOX_ADMIN_PASSWORD}" ]] || [[ "${#KEEXYBOX_ADMIN_PASSWORD}" -lt 8 ]]; do
		KEEXYBOX_ADMIN_PASSWORD=$(whiptail --backtitle "$BACKTITLE" --title "$PASSWORD_TITLE" --passwordbox "$MSG_ERR_KEEXYBOX_ADMIN_PASSWORD" 10 40 3>&1 1>&2 2>&3)
		[[ $? -eq 1 ]] && exit
		CONFIRM_KEEXYBOX_ADMIN_PASSWORD=$(whiptail --backtitle "$BACKTITLE" --title "$PASSWORD_TITLE" --passwordbox "$MSG_CONFIRM_KEEXYBOX_ADMIN_PASSWORD" 10 40 3>&1 1>&2 2>&3)
		[[ $? -eq 1 ]] && exit
	done
}

# This function prompt the user to set keexybox admin password
cli_ask_admin_password() {
	echo
	echo "$MSG_KEEXYBOX_ADMIN_PASSWORD:"
	read -s KEEXYBOX_ADMIN_PASSWORD
	echo
	echo "$MSG_CONFIRM_KEEXYBOX_ADMIN_PASSWORD:"
	read -s CONFIRM_KEEXYBOX_ADMIN_PASSWORD
	
	while [[ "${KEEXYBOX_ADMIN_PASSWORD}" != "${CONFIRM_KEEXYBOX_ADMIN_PASSWORD}" ]] || [[ "${#KEEXYBOX_ADMIN_PASSWORD}" -lt 8 ]]; do
		echo
		echo "$MSG_ERR_KEEXYBOX_ADMIN_PASSWORD:"
		read -s KEEXYBOX_ADMIN_PASSWORD
		echo
		echo "$MSG_CONFIRM_KEEXYBOX_ADMIN_PASSWORD:"
		read -s CONFIRM_KEEXYBOX_ADMIN_PASSWORD
	done
}
########################################
####### END PASSWORD SET ######
########################################

# This function create a new config file that be use to install KeexyBox
create_install_config_file() {
	# Name of config file to create
	#INSTALL_CONF="./install.conf"
	
	# Default KeexyBox home dir
	#KEEXYBOX_HOME="/opt/keexybox"
	
	# KeexyBox versions
	conf_data+=("export KEEXYBOX_CURRENT_VERSION=${KEEXYBOX_CURRENT_VERSION}")
	conf_data+=("export KEEXYBOX_NEW_VERSION=${KEEXYBOX_NEW_VERSION}")
	
	# Package to install
	conf_data+=("export INSTALL_PKG_REQUIRED=1")
	conf_data+=("export INSTALL_PKG_BIND=1")
	conf_data+=("export INSTALL_PKG_DHCPD=1")
	conf_data+=("export INSTALL_PKG_TOR=1")
	conf_data+=("export INSTALL_PKG_KEEXYAPP=1")
	conf_data+=("export INSTALL_PKG_SCRIPTS=1")

	# Database settings

	db_host="localhost"
	db_username="keexybox"
	db_password=$(/usr/bin/head /dev/urandom | tr -dc A-Za-z0-9 | head -c 13)	
	
	conf_data+=("export DATABASE_KEEXYBOX_HOST=${db_host}")
	conf_data+=("export DATABASE_KEEXYBOX_USER=${db_username}")
	conf_data+=("export DATABASE_KEEXYBOX_PASSWORD=${db_password}")
	conf_data+=("export DATABASE_KEEXYBOX_DATABASE=keexybox")

	conf_data+=("export DATABASE_KEEXYBOX_BLACKLIST_HOST=${db_host}")
	conf_data+=("export DATABASE_KEEXYBOX_BLACKLIST_USER=${db_username}")
	conf_data+=("export DATABASE_KEEXYBOX_BLACKLIST_PASSWORD=${db_password}")
	conf_data+=("export DATABASE_KEEXYBOX_BLACKLIST_DATABASE=keexybox_blacklist")

	conf_data+=("export DATABASE_KEEXYBOX_LOGS_HOST=${db_host}")
	conf_data+=("export DATABASE_KEEXYBOX_LOGS_USER=${db_username}")
	conf_data+=("export DATABASE_KEEXYBOX_LOGS_PASSWORD=${db_password}")
	conf_data+=("export DATABASE_KEEXYBOX_LOGS_DATABASE=keexybox_logs")

	# Some settings for installation
	conf_data+=("export KEEXYBOX_SYSUSER=\"keexybox\"")
	conf_data+=("export KEEXYBOX_HOME=\"${KEEXYBOX_HOME}\"")
	conf_data+=("export KEEXYBOX_MARIADB_USER=\"keexybox\"")
	conf_data+=("export KEEXYBOX_MARIADB_PASSWORD='$(/usr/bin/head /dev/urandom | tr -dc A-Za-z0-9 | head -c 13)'")
	conf_data+=("export MARIADB_ROOT_LOGIN=\"root\"")
	conf_data+=("export KEEXYAPP_CFG_TEMPLATE=\"${KEEXYBOX_HOME}/keexyapp/config/app.template.php\"")
	conf_data+=("export KEEXYAPP_CFG=\"${KEEXYBOX_HOME}/keexyapp/config/app.php\"")
	conf_data+=("export KXB_CMD=\"${KEEXYBOX_HOME}/keexyapp/bin/cake\"")
	conf_data+=("export KXB_SCRIPTS=\"${KEEXYBOX_HOME}/keexyapp/src/Shell/scripts/\"")

	# KeexyBox admin password
	conf_data+=("export KEEXYBOX_ADMIN_PASSWORD='${KEEXYBOX_ADMIN_PASSWORD}'")

	# Output Network settings
	conf_data+=("export KEEXYBOX_NET_OUTPUT_IP=$KEEXYBOX_NET_OUTPUT_IP")
	conf_data+=("export KEEXYBOX_NET_OUTPUT_MASK=$KEEXYBOX_NET_OUTPUT_MASK")
	conf_data+=("export KEEXYBOX_NET_OUTPUT_INTERFACE=$KEEXYBOX_NET_OUTPUT_INTERFACE")
	conf_data+=("export KEEXYBOX_NET_GW_IP=${KEEXYBOX_NET_GW_IP}")

	# Input Network settings
	conf_data+=("export KEEXYBOX_NET_INPUT_IP=169.254.1.1")
	conf_data+=("export KEEXYBOX_NET_INPUT_MASK=255.255.255.0")
	conf_data+=("export KEEXYBOX_NET_INPUT_INTERFACE=${KEEXYBOX_NET_OUTPUT_INTERFACE}:0")

	# DNS servers
	conf_data+=("export KEEXYBOX_DNS1=${dns[1]}")
	conf_data+=("export KEEXYBOX_DNS2=${dns[2]}")

	IFS=""
	echo "#!/bin/bash" > ${INSTALL_CONF}
	for conf in ${conf_data[@]}; do
		echo $conf >> ${INSTALL_CONF}
	done
	
	unset IFS
}

# This function create a new config file that be use to update KeexyBox
create_update_config_file() {
	# Name of config file to create
	#INSTALL_CONF="./install.conf"
	
	# Default KeexyBox home dir
	#KEEXYBOX_HOME="/opt/keexybox"
	
	# KeexyBox versions
	conf_data+=("export KEEXYBOX_CURRENT_VERSION=${KEEXYBOX_CURRENT_VERSION}")
	conf_data+=("export KEEXYBOX_NEW_VERSION=${KEEXYBOX_NEW_VERSION}")
	
	# Package to install
	conf_data+=("export INSTALL_PKG_REQUIRED=1")
	conf_data+=("export INSTALL_PKG_BIND=1")
	conf_data+=("export INSTALL_PKG_DHCPD=1")
	conf_data+=("export INSTALL_PKG_TOR=1")
	conf_data+=("export INSTALL_PKG_KEEXYAPP=1")
	conf_data+=("export INSTALL_PKG_SCRIPTS=1")

	# Some settings for installation
	conf_data+=("export KEEXYBOX_SYSUSER=\"keexybox\"")
	conf_data+=("export KEEXYBOX_HOME=\"${KEEXYBOX_HOME}\"")

	conf_data+=("export DATABASE_KEEXYBOX_HOST=${DATABASE_KEEXYBOX_HOST}")
	conf_data+=("export DATABASE_KEEXYBOX_USER=${DATABASE_KEEXYBOX_USER}")
	conf_data+=("export DATABASE_KEEXYBOX_PASSWORD=${DATABASE_KEEXYBOX_PASSWORD}")
	conf_data+=("export DATABASE_KEEXYBOX_DATABASE=${DATABASE_KEEXYBOX_DATABASE}")

	conf_data+=("export DATABASE_KEEXYBOX_BLACKLIST_HOST=${DATABASE_KEEXYBOX_BLACKLIST_HOST}")
	conf_data+=("export DATABASE_KEEXYBOX_BLACKLIST_USER=${DATABASE_KEEXYBOX_BLACKLIST_USER}")
	conf_data+=("export DATABASE_KEEXYBOX_BLACKLIST_PASSWORD=${DATABASE_KEEXYBOX_BLACKLIST_PASSWORD}")
	conf_data+=("export DATABASE_KEEXYBOX_BLACKLIST_DATABASE=${DATABASE_KEEXYBOX_BLACKLIST_DATABASE}")

	conf_data+=("export DATABASE_KEEXYBOX_LOGS_HOST=${DATABASE_KEEXYBOX_LOGS_HOST}")
	conf_data+=("export DATABASE_KEEXYBOX_LOGS_USER=${DATABASE_KEEXYBOX_LOGS_USER}")
	conf_data+=("export DATABASE_KEEXYBOX_LOGS_PASSWORD=${DATABASE_KEEXYBOX_LOGS_PASSWORD}")
	conf_data+=("export DATABASE_KEEXYBOX_LOGS_DATABASE=${DATABASE_KEEXYBOX_LOGS_DATABASE}")


	conf_data+=("export MARIADB_ROOT_LOGIN=\"root\"")
	conf_data+=("export KEEXYAPP_CFG_TEMPLATE=\"${KEEXYBOX_HOME}/keexyapp/config/app.template.php\"")
	conf_data+=("export KEEXYAPP_CFG=\"${KEEXYBOX_HOME}/keexyapp/config/app.php\"")
	conf_data+=("export KXB_CMD=\"${KEEXYBOX_HOME}/keexyapp/bin/cake\"")
	conf_data+=("export KXB_SCRIPTS=\"${KEEXYBOX_HOME}/keexyapp/src/Shell/scripts/\"")

	IFS=""
	echo "#!/bin/bash" > ${UPDATE_CONF}
	for conf in ${conf_data[@]}; do
		echo $conf >> ${UPDATE_CONF}
	done
	
	unset IFS
}

#-------- CHECK IF THIS SCRIPT IS RUNNING AS ROOT OR AS KEEXYBOX USER
# Installation must be done as root
# Update can be done as root or as keexybox user. As keexybox, required packages will not be updated 
user_inst=''
if [ $(id -u) -eq 0 ]; then
    user_inst='root'
elif [ $USER == 'keexybox' ]; then
    user_inst='keexybox'
else
	echo "This script must be run as root or as keexybox!"
	exit 1
fi

#------- IF USER IS ROOT CHECK NETWORK CONFIGURATION
if [ $user_inst == 'root' ]; then
    echo "Please wait, checks are in progress before starting KeexyBox installation... "
    ping -W 2 -c 4 ${TESTING_IP_FOR_ROUTING} > /dev/null 2>&1
    ping_ok=$?

    if [ "${ping_ok}" -ne 0 ]; then
	    echo "No internet connection detected. Installation aborted!"
	    exit 1
    fi

    # Getting current IP setting for Internet connection
    KEEXYBOX_NET_GW_IP=$(ip route get ${TESTING_IP_FOR_ROUTING} | grep ${TESTING_IP_FOR_ROUTING} | cut -d" " -f3)
    #KEEXYBOX_NET_GW_INT=$(ip route get ${TESTING_IP_FOR_ROUTING} | grep ${TESTING_IP_FOR_ROUTING} | cut -d" " -f5)
    KEEXYBOX_NET_OUTPUT_INTERFACE=$(ip route get ${TESTING_IP_FOR_ROUTING} | grep ${TESTING_IP_FOR_ROUTING} | cut -d" " -f5)
    KEEXYBOX_NET_OUTPUT_IP=$(ip route get ${TESTING_IP_FOR_ROUTING} | grep ${TESTING_IP_FOR_ROUTING} | cut -d" " -f7)
    KEEXYBOX_NET_OUTPUT_CIDR=$(ip addr | grep ${KEEXYBOX_NET_OUTPUT_IP} | cut -d" " -f6 | cut -d"/" -f2)
    KEEXYBOX_NET_OUTPUT_MASK=$(cidr2mask ${KEEXYBOX_NET_OUTPUT_CIDR})

    # Check if host network is properly configured
    if [ "${KEEXYBOX_NET_GW_IP}" = "" -o "${KEEXYBOX_NET_OUTPUT_INTERFACE}" = "" -o "${KEEXYBOX_NET_OUTPUT_IP}" = "" -o "${KEEXYBOX_NET_OUTPUT_MASK}" = "" ]; then
	    echo "Unable to detect the current network settings for Internet access. Installation aborted!"
	    exit 1
    fi
fi

# Change directory to install directory 
install_script_dir=$(echo "$0" | awk -F"/" '{OFS="/"; $NF=""}1')
cd $install_script_dir

# Check existing KeexyBox installation
if [ -f ${KEEXYBOX_VER_FILE} ]; then
	KEEXYBOX_CURRENT_VERSION=$(head -n 1 ${KEEXYBOX_VER_FILE})

	if [ -f ${KEEXYBOX_HOME}/keexyapp/bin/cake ]; then
		cake_cmd=${KEEXYBOX_HOME}/keexyapp/bin/cake
	elif [ -f ${KEEXYBOX_HOME}/keexyapp_old/bin/cake ]; then
		cake_cmd=${KEEXYBOX_HOME}/keexyapp_old/bin/cake
	else
		echo "Unable to locate the command which get information of current KeexyBox installation. Installation aborted!"
		exit 1
	fi	

	db_rc=0
	DATABASE_KEEXYBOX_HOST=$(${cake_cmd} config get_db_config keexybox_db_config host)
	db_rc=$(expr $db_rc + $?)
	DATABASE_KEEXYBOX_USER=$(${cake_cmd} config get_db_config keexybox_db_config username)
	db_rc=$(expr $db_rc + $?)
	DATABASE_KEEXYBOX_PASSWORD=$(${cake_cmd} config get_db_config keexybox_db_config password)
	db_rc=$(expr $db_rc + $?)
	DATABASE_KEEXYBOX_DATABASE=$(${cake_cmd} config get_db_config keexybox_db_config database)
	db_rc=$(expr $db_rc + $?)

	DATABASE_KEEXYBOX_BLACKLIST_HOST=$(${cake_cmd} config get_db_config blacklist_db_config host)
	db_rc=$(expr $db_rc + $?)
	DATABASE_KEEXYBOX_BLACKLIST_USER=$(${cake_cmd} config get_db_config blacklist_db_config username)
	db_rc=$(expr $db_rc + $?)
	DATABASE_KEEXYBOX_BLACKLIST_PASSWORD=$(${cake_cmd} config get_db_config blacklist_db_config password)
	db_rc=$(expr $db_rc + $?)
	DATABASE_KEEXYBOX_BLACKLIST_DATABASE=$(${cake_cmd} config get_db_config blacklist_db_config database)
	db_rc=$(expr $db_rc + $?)

	DATABASE_KEEXYBOX_LOGS_HOST=$(${cake_cmd} config get_db_config logs_db_config host)
	db_rc=$(expr $db_rc + $?)
	DATABASE_KEEXYBOX_LOGS_USER=$(${cake_cmd} config get_db_config logs_db_config username)
	db_rc=$(expr $db_rc + $?)
	DATABASE_KEEXYBOX_LOGS_PASSWORD=$(${cake_cmd} config get_db_config logs_db_config password)
	db_rc=$(expr $db_rc + $?)
	DATABASE_KEEXYBOX_LOGS_DATABASE=$(${cake_cmd} config get_db_config logs_db_config database)
	db_rc=$(expr $db_rc + $?)

	if [ "$db_rc" -ne 0 ]; then
		echo
		echo "It looks like you have an existing installation of KeexyBox, but we can not get all the information for the update."
		exit 1
	fi
	
	create_update_config_file

	./util/run_update.sh ${UPDATE_CONF}
else
    if [ $user_inst == 'root' ]; then
    	KEEXYBOX_CURRENT_VERSION=${KEEXYBOX_NEW_VERSION}
    	#-------- INITIALIZE CONFIGURATION VALUES
    	set_dns_config
    	
    	if [ -f "/usr/bin/whiptail" ]; then
    		#whiptail_ask_packages_to_install
    		whiptail_ask_admin_password
    	else
    		#cli_ask_packages_to_install
    		cli_ask_admin_password
    	fi
    	create_install_config_file
    	
    	#-------- RUN INSTALLATION
    	./util/run_install.sh ${INSTALL_CONF}
    else
	    echo "The installation must be done as root!"
	    exit 1
    fi
fi
