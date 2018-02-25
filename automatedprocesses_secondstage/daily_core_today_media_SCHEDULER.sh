#!/bin/bash

##
#
# Script runs and checks daily_core_today_media database tables
#
##

reapdate=$(date +%Y-%m-%d -d yesterday)
path_sbin="/usr/local/sbin/"
path_kitchen="/root/data-integration/kitchen.sh "
path_kjb="/root/data-integration/epiphany_kjb/ERROR_kjb/"
mysql_db="mysql --defaults-group-suffix=sourcelevel -N -e "
send_email=${path_kitchen}-file="${path_kjb}daily_core_today_media_ERROR.kjb"

# Array holding platforms
platforms=( "v3" "dc" "adsym" "tm" "adtrans" )

core_today_media(){
	count=
	
	${path_sbin}"${platform}_core_today_media.py"
	check_db=$(${mysql_db}"SELECT NULL FROM "${platform}_core_today_media" LIMIT 1")
	
	if [[ -z $check_db ]]
	then
		while [[ -z $check_db ]] && [[ $count -lt 3 ]]
		do
			${path_sbin}"${platform}_core_today_media.py"
			check_db=$(${mysql_db}"SELECT NULL FROM "${platform}_core_today_media" LIMIT 1")
			count=$((count + 1))
		done
	fi

		[[ -z $check_db ]] && eval $send_email 
	
	exit 0
	}


run_core_today_media(){

	for platform in "${platforms[@]}"
	do
		core_today_media ${platform} &
	done
	
	exit 0
	}


run_core_today_media
