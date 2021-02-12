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
echo "---- Creation of Keexybox configuration ----"
echo

#public function AddBlacklistConf($template, $conffile, $params = null)

# Create Apache configuration ports + vhosts + envvars
echo "Apache:"
echo "  ${KXB_CMD} config apache all"
${KXB_CMD} config apache all >> /dev/null
cd /etc/apache2/mods-enabled/ >> /dev/null
ln -s ../mods-available/rewrite.load >> /dev/null
ln -s ../mods-available/ssl.load >> /dev/null
cd -

mkdir -p ${KEEXYBOX_HOME}/backupconf
mkdir -p ${KEEXYBOX_HOME}/tmp
mkdir -p ${KEEXYBOX_HOME}/keexyapp/logs

#mkdir -p ${KEEXYBOX_HOME}/ssl
#${KXB_CMD} config certificate generate

# Only update logrotate and sudoers if update is running as root
if [ $(id -u) -eq 0 ]; then
    echo "Logrotate:"
    echo "  ${KXB_CMD} config logrotate all"
    ${KXB_CMD} config logrotate all >> /dev/null

    echo "Sudoers:"
    echo "  ${KXB_CMD} config sudoers all"
    ${KXB_CMD} config sudoers all >> /dev/null
fi

#echo "  --- Network ---"
#echo "  ${KXB_CMD} config network all"
#${KXB_CMD} config network all

echo "Tor:"
echo "  ${KXB_CMD} config tor all"
${KXB_CMD} config tor all >> /dev/null
mkdir -p ${KEEXYBOX_HOME}/tor/var/run

# Create Bind configurations : named + update_acl + set_acl + set_logging + set_default_zone + set_safesearch + set_profiles
echo "Bind:"
echo "  ${KXB_CMD} config bind all"
${KXB_CMD} config bind all >> /dev/null
${KEEXYBOX_HOME}/bind/sbin/rndc-confgen -a >> /dev/null
mkdir -p ${KEEXYBOX_HOME}/bind/var/log/ >> /dev/null
touch ${KEEXYBOX_HOME}/bind/var/log/queries.log >> /dev/null
touch ${KEEXYBOX_HOME}/bind/var/log/debug.log >> /dev/null

# Create  python conf
echo "Scripts:"
echo "  ${KXB_CMD} config scripts all"
${KXB_CMD} config scripts all >> /dev/null

echo "NTP:"
echo "  ${KXB_CMD} config ntp all"
${KXB_CMD} config ntp all >> /dev/null

# Create dhcpd configurations : main + reservations
echo "DHCP:"
echo "  ${KXB_CMD} config dhcp all"
${KXB_CMD} config dhcp all >> /dev/null
touch ${KEEXYBOX_HOME}/dhcpd/etc/dhcpd.leases >> /dev/null

# Create hostapd configuration : main
echo "Hostapd:"
echo "  ${KXB_CMD} config hostapd all"
${KXB_CMD} config hostapd all >> /dev/null

# Create Startup keexybox Script
echo "Startup keexybox scripts:"
cd /etc/init.d/
ln -s ${KEEXYBOX_HOME}/keexyapp/src/Shell/scripts/init_keexybox keexybox >> /dev/null
update-rc.d keexybox defaults >> /dev/null
cd -
#${KXB_SCRIPTS}/acl.sh
