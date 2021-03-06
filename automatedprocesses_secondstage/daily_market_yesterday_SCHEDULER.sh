#!/bin/bash

##
#
# knuckled script runs and checks daily_market_yesterday database tables
#
##

path_sbin="/usr/local/sbin/"
path_kitchen="/home/ec2-user/data-integration/kitchen.sh "
path_kjb="/home/ec2-user/data-integration/epiphany_kjb/"
reapdate=$(date +%Y-%m-%d -d yesterday)
reapedateFormat=$(date +%m/%d/%Y -d yesterday)
mysql_db="mysql --defaults-group-suffix=sourcelevel -N -e "
send_email=${path_kitchen}-file="${path_kjb}Daily_Core_Today_Error.kjb"

# Array holding platforms
platforms=( "v3" "dc" "adsym" "tm" "adtrans" )

market_yesterday(){
	count=
		
	${path_sbin}"${platform}_market_yesterday.py"
	check_db=$(${mysql_db}"SELECT NULL FROM "${platform}_market_yesterday" LIMIT 1")

	if [[ -z $check_db ]]
	then
		while [[ -z $check_db ]] && [[ $count -lt 3 ]]
		do
			${path_sbin}"${platform}_market_yesterday.py"
			check_db=$(${mysql_db}"SELECT NULL FROM "${platform}_market_yesterday" LIMIT 1")
			count=$((count + 1))
		done
	fi

	[[ -z $check_db ]] && eval $sendemail

	exit 0
	}



run_market_yesterday(){

	for platform in "${platforms[@]}"
	do
		market_yesterday ${platform} &
	done
	}


run_market_yesterday	
