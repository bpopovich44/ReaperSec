#!/bin/bash

##
#
# knuckled script runs and checks daily_core_today_media database tables
#
##

path_sbin="/usr/local/sbin/"
reapdate=$(date +%Y-%m-%d -d yesterday)
reapdateFormat=$(date +%m/%d/%Y -d yesterday)
#mysql_db="mysql --defaults-group-suffix=sourcelevel -N -e "
mysql_db="mysql -N -h epiphany-load.cayagee0hssn.us-west-2.rds.amazonaws.com epiphany_sourcelevel-P 3306 -e "
send_email="/home/ec2-user/data-integration/kitchen.sh -file='/home/ec2-user/data-integration/epiphany_kjb/Daily_Core_Today_Error.kjb'"


dc_knuckled(){
	dc_count=
	
	${path_sbin}dc_core_today_media.py
	dc=$(${mysql_db}"SELECT NULL FROM dc_core_today_media LIMIT 1")
	
	while [[ -z $dc ]] && [[ $dc_count -lt 3 ]]
	do
		${path_sbin}dc_core_today_media.py
		dc=$(${mysql_db}"SELECT NULL FROM dc_core_today_media LIMIT 1")
		dc_count=$(($dc_count + 1))
	done
	
	[[ -z $dc ]] && eval $sendemail
	
	}


adsym_knuckled(){
	adsym_count=
	
	${path_sbin}adsym_core_today_media.py
	adsym=$(${mysql_db}"SELECT NULL FROM adsym_core_today_media LIMIT 1")
	
	while [[ -z $adsym ]] && [[ $adsym_count -lt 3 ]]
	do
		${path_sbin}adsym_core_today_media.py
		adsym=$(${mysql_db}"SELECT NULL FROM adsym_core_today_media LIMIT 1")
		adsym_count=$(($adsym_count + 1))
	done
	
	[[ -z $adsym ]] && eval $sendemail
	
	}


adtrans_knuckled(){
	adtrans_count=
	
	${path_sbin}adtrans_core_today_media.py
	adtrans=$(${mysql_db}"SELECT NULL FROM adtrans_core_today_media LIMIT 1")
	
	while [[ -z $adtrans ]] && [[ $adtrans_count -lt 3 ]]
	do
		${path_sbin}adtrans_core_today_media.py
		adtrans=$(${mysql_db}"SELECT NULL FROM adtrans_core_today_media LIMIT 1")
		adtrans_count=$(($adtrans_count + 1))
	done
	
	[[ -z $adtrans ]] && eval $sendemail
	
	}




run_core_today(){
	dc_knuckled &
	adsym_knuckled &
	adtrans_knuckled &

	wait %1 %2 %3
	}

run_core_today
