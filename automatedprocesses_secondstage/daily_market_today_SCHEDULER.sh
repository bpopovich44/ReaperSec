#!/bin/bash

##
#
# knuckled script runs and checks daily_market_today database tables
#
##

path_sbin="/usr/local/sbin/"
path_kitchen="/home/ec2-user/data-integration/kitchen.sh "
path_kjb="/home/ec2-user/data-integration/epiphany_kjb/"
reapdate=$(date +%Y-%m-%d -d yesterday)
reapdateFormat=$(date +%m/%d/%Y -d yesterday)
mysql_db="mysql --defaults-group-suffix=sourcelevel -N -e "
send_email=${path_kitchen}-file="${path_kjb}Daily_Core_Today_Error.kjb"

platforms=( "v3" "dc" "adsym" "tm" "adtrans" "springserve" )
market_today(){
	count=

	echo "Running ${platform}_market_today"
	${path_sbin}"${platform}_market_today.py"
	check_db=$(${mysql_db}"SELECT NULL FROM "${platform}_market_today" LIMIT 1")

	if [[ -z $check_db ]]
	then
		while [[ -z $check_db ]] && [[ $count -lt 3 ]]
		do
			${path_sbin}"${platform}_market_today.py"
			check_db=$(${mysql_db}"SELECT NULL FROM "${platform}_market_today" LIMIT 1")
			count=$((count + 1))
		done
	fi

	[[ -z $check_db ]] && eval $sendemail
	
	}

run_market_today(){

	for platform in ${platforms[@]}
	do
		market_today $platform &
	done
	}


run_market_today	
