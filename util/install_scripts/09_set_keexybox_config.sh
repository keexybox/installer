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
echo "---- Update of configuration in database ----"
echo
mysql_cmd="mysql -u ${DATABASE_KEEXYBOX_USER} -p${DATABASE_KEEXYBOX_PASSWORD} ${DATABASE_KEEXYBOX_DATABASE}"

sql_queries_config="
UPDATE \`config\` SET value=\"${KEEXYBOX_NET_INPUT_IP}\" WHERE param=\"host_ip_input\";
UPDATE \`config\` SET value=\"${KEEXYBOX_NET_INPUT_MASK}\" WHERE param=\"host_netmask_input\";
UPDATE \`config\` SET value=\"${KEEXYBOX_NET_INPUT_INTERFACE}\" WHERE param=\"host_interface_input\";
UPDATE \`config\` SET value=\"${KEEXYBOX_NET_OUTPUT_IP}\" WHERE param=\"host_ip_output\";
UPDATE \`config\` SET value=\"${KEEXYBOX_NET_OUTPUT_MASK}\" WHERE param=\"host_netmask_output\";
UPDATE \`config\` SET value=\"${KEEXYBOX_NET_OUTPUT_INTERFACE}\" WHERE param=\"host_interface_output\";
UPDATE \`config\` SET value=\"${KEEXYBOX_NET_GW_IP}\" WHERE param=\"host_gateway\";
UPDATE \`config\` SET value=\"${KEEXYBOX_DNS1}\" WHERE param=\"host_dns1\";
UPDATE \`config\` SET value=\"${KEEXYBOX_DNS2}\" WHERE param=\"host_dns2\";
UPDATE \`config\` SET value=\"Etc/GMT\" WHERE param=\"host_timezone\";
UPDATE \`config\` SET value=\"en_US\" WHERE param=\"locale\";
UPDATE \`config\` SET value=1 WHERE param=\"run_wizard\";
UPDATE \`config\` SET value=0 WHERE param=\"dhcp_enabled\";
"

echo ${sql_queries_config} | ${mysql_cmd}
[[ $? -eq 0 ]] && echo "done!" || echo "failed!"

