#!/bin/bash

##
#
# knuckled script runs and checks daily_core_today database tables
#
##

path_sbin="/usr/local/sbin/"
reapdate=$(date +%Y-%m-%d -d yesterday)
reapdateFormat=$(date +%m/%d/%Y -d yesterday)
mysql_db="mysql --defaults-group-suffix=sourcelevel -N -e "
#mysql_db="mysql -N -h epiphany-load.cayagee0hssn.us-west-2.rds.amazonaws.com -P 3306 -e "
send_email="/home/ec2-user/data-integration/kitchen.sh -file='/home/ec2-user/data-integration/epiphany_kjb/Daily_Core_Today_Error.kjb'"

v3_knuckled(){
	v3_count=
	
	${path_sbin}v3_core_today.py
	v3=$(${mysql_db}"SELECT NULL FROM v3_core_today LIMIT 1")
	while [[ -z $v3 ]] && [[ $v3_count -lt 3 ]]
	do
		${path_sbin}v3_core_today.py
		v3=$(${mysql_db}"SELECT NULL FROM v3_core_today LIMIT 1")
		v3_count=$(($v3_count + 1))
			
	done
		
	[[ $v3 -eq 0 ]] && eval $sendemail
		
	}


dc_knuckled(){
	dc_count=
	
	${path_sbin}dc_core_today.py
	dc=$(${mysql_db}"SELECT NULL FROM dc_core_today LIMIT 1")
	while [[ -z $dc ]] && [[ $dc_count -lt 3 ]]
	do
		${path_sbin}dc_core_today.py
		dc=$(${mysql_db}"SELECT NULL FROM dc_core_today LIMIT 1")
		dc_count=$(($dc_count + 1))
			
	done
		
	[[ $dc -eq 0 ]] && eval $sendemail
		
	}



adsym_knuckled(){
	adsym_count=
	
	${path_sbin}adsym_core_today.py
	adsym=$(${mysql_db}"SELECT NULL FROM adsym_core_today LIMIT 1")
	while [[ -z $adsym ]] && [[ $adsym_count -lt 3 ]]
	do
		${path_sbin}adsym_core_today.py
		adsym=$(${mysql_db}"SELECT NULL FROM adsym_core_today LIMIT 1")
		adysm_count=$(($adsym_count + 1))
			
	done
		
	[[ $adsym -eq 0 ]] && eval $sendemail
		
	}


tm_knuckled(){
	tm_count=
	
	${path_sbin}tm_core_today.py
	tm=$(${mysql_db}"SELECT NULL FROM tm_core_today LIMIT 1")
	while [[ -z $tm ]] && [[ $tm_count -lt 3 ]]
	do
		${path_sbin}tm_core_today.py
		tm=$(${mysql_db}"SELECT NULL FROM tm_core_today LIMIT 1")
		tm_count=$(($tm_count + 1))
			
	done
		
	[[ $tm -eq 0 ]] && eval $sendemail
		
	}



adtrans_knuckled(){
	adtrans_count=
	
	${path_sbin}adtrans_core_today.py
	adtrans=$(${mysql_db}"SELECT NULL FROM adtrans_core_today LIMIT 1")
	while [[ -z $adtrans ]] && [[ $adtrans_count -lt 3 ]]
	do
		${path_sbin}adtrans_core_today.py
		adtrans=$(${mysql_db}"SELECT NULL FROM adtrans_core_today LIMIT 1")
		adtrans_count=$(($adtrans_count + 1))
			
	done
		
	[[ $adtrans -eq 0 ]] && eval $sendemail
		
	}


springs_knuckled(){
	dc_count=
	
	${path_sbin}springserve_core_today.py
	springs=$(${mysql_db}"SELECT NULL FROM springserve_core_today LIMIT 1")
	while [[ -z $springs ]] && [[ $springs_count -lt 3 ]]
	do
		${path_sbin}springserve_core_today.py
		springs=$(${mysql_db}"SELECT NULL FROM springserve_core_today LIMIT 1")
		springs_count=$(($springs_count + 1))
			
	done
		
	[[ $springs -eq 0 ]] && eval $sendemail
		
	}



run_core_today(){
	v3_knuckled &
	dc_knuckled &
	adsym_knuckled &
	tm_knuckled &
	adtrans_knuckled &
	springs_knuckled &

	wait %1 %2 %3 %4 %5 %6	
	}

run_core_today
