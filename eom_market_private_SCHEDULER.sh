#!/bin/bash

##
#
# knuckled script runs and checks daily_market_private database tables
#
##


path_sbin="/usr/local/sbin/"
path_pan="/home/ec2-user/data-integration/pan.sh "
path_ktr="/home/ec2-user/data-integration/epiphany_ktr/"
mysql_db="mysql --defaults-group-suffix=epiphanyeom -N -e "
send_email="/home/ec2-user/data-integration/kitchen.sh -file='/home/ec2-user/data-integration/epiphany_kjb/Daily_Core_Today_Error.kjb'"

dna_startdate="$(date -d "-1 month" +%m/01/%Y)"
#dna_startdate=$(date -d "$(date +%Y-%m) -15 last month" '+%Y/%m/01')
dna_lastdate="$(date -d "-$(date +%d) days +0  month" +%m/%d/%Y)"

dc_startdate="$(date -d "-1 month" +%m/01/%Y)"
#dc_startdate=$(date -d "$(date +%Y-%m) -15 last month" '+%Y/%m/01')
dc_lastdate="$(date -d "-$(date +%d) days +0  month" +%m/%d/%Y)"

adsym_startdate="$(date -d "-1 month" +%m/01/%Y)"
#adsym_startdate=$(date -d "$(date +%Y-%m) -15 last month" '+%Y/%m/01')
adsym_lastdate="$(date -d "-$(date +%d) days +0  month" +%m/%d/%Y)"

adtrans_startdate="$(date -d "-1 month" +%m/01/%Y)"
#adtrans_startdate=$(date -d "$(date +%Y-%m) -15 last month" '+%Y/%m/01')
adtrans_lastdate="$(date -d "-$(date +%d) days +0  month" +%m/%d/%Y)"

tm_startdate="$(date -d "-1 month" +%m/01/%Y)"
#tm_startdate=$(date -d "$(date +%Y-%m) -15 last month" '+%Y/%m/01')
tm_lastdate="$(date -d "-$(date +%d) days +0  month" +%m/%d/%Y)"

springs_startdate="$(date -d "-1 month" +%Y-%m-01)"
#springs_startdate=$(date -d "$(date +%Y-%m) -15 last month" '+%Y-%m-01')
springs_lastdate="$(date -d "-$(date +%d) days +0  month" +%Y-%m-%d)"


dna_knuckled(){
	dna_count=

	${path_sbin}dna_market_private_EOM.py
	dna=$(${mysql_db} "SELECT NULL FROM dna_market_private_EOM LIMIT 1")
	
	if [[ -z $dna ]]
	then
		while [[ -z $dna ]] && [[ $dna_count -le 3 ]]
		do
			${path_sbin}dna_market_private_EOM.py
			dna=$(${mysql_db} "SELECT NULL FROM dna_market_private_EOM LIMIT 1")
			dna_count=$(($dna_count + 1))	
		done
	fi

	[[ -z $dna ]] && eval $sendemail
	}


dc_knuckled(){
	dc_count=

	${path_sbin}dc_market_private_EOM.py
	dc=$(${mysql_db} "SELECT NULL FROM dc_market_private_EOM LIMIT 1")
	
	if [[ -z $dc ]]
	then
		while [[ -z $dc ]] && [[$dc_count -le 3 ]]
		do
			${path_sbin}dc_market_private_EOM.py
			dc=$(${mysql_db} "SELECT NULL FROM dc_market_private_EOM LIMIT 1")
			dc_count=$(($dc_count + 1))
		done
	fi	
	
	[[ -z $dc ]] && eval $sendemail
	}


adsym_knuckled(){
	adsym_count=

	${path_sbin}adsym_market_private_EOM.py
	adsym=$(${mysql_db} "SELECT NULL FROM adsym_market_private_EOM LIMIT 1")

	if [[ -z $adsym ]]
	then
		while [[ -z $adsym ]] && [[ $adsym_count -le 3 ]]
		do
			${path_sbin}adsym_market_private_EOM.py
			adsym=$(${mysql_db} "SELECT NULL FROM adsym_market_private_EOM LIMIT 1")
			adsym_count=$(($adsym_count + 1))
		done
	fi

	[[ -z $adsym ]] && eval $sendemail
	}


tm_knuckled(){
	tm_count=

	${path_sbin}tm_market_private_EOM.py
	tm=$(${mysql_db} "SELECT NULL FROM tm_market_private_EOM LIMIT 1")

	if [[ -z $tm ]]
	then
		while [[ -z $tm ]] && [[ $tm_count -le 3 ]]
		do
			${path_sbin}tm_market_private_EOM.py
			tm=$(${mysql_db} "SELECT NULL FROM tm_market_private_EOM LIMIT 1")
			tm_count=$(($tm_count + 1))
		done
	fi

	[[ -z $tm ]] && eval $sendemail
	}


adtrans_knuckled(){
	adtrans_count=

	${path_sbin}adtrans_market_private_EOM.py
	adtrans=$(${mysql_db} "SELECT NULL FROM adtrans_market_private_EOM LIMIT 1")
	
	if [[ -z $adtrans ]]
	then
		while [[ -z $adtrans ]] && [[ $adtrans_count -le 3 ]]
		do
			${path_sbin}adtrans_market_private_EOM.py
			adtrans=$(${mysql_db} "SELECT NULL FROM adtrans_market_private_EOM LIMIT 1")
			adtrans_count=$(($adtrans_count + 1))
		done
	fi	
	
	[[ -z $adtrans ]] && eval $sendemail
	}


springs_knuckled(){
	springs_count=

	${path_sbin}springserve_market_private_EOM.py
	springs=$(${mysql_db} "SELECT NULL FROM springserve_market_private_EOM LIMIT 1")

	if [[ -z $springs ]]
	then
		while [[ -z $springs ]] && [[ $springs_count -le 3 ]]
		do
			${path_sbin}springserve_market_private_EOM.py
			springs=$(${mysql_db} "SELECT NULL FROM springserve_market_private_EOM LIMIT 1")
			springs_count=$(($springs_count + 1))
		done
	fi

	[[ -z $springs ]] && eval $sendemail
	}


# FUNCTION TO process marketprivate_eom
dna_marketprivate_eom(){

	until [[ "$dna_startdate" > "$dna_lastdate" ]]
	do
		${path_pan}-file="${path_ktr}dna_market_private_EOM.ktr" -param:PROCESS_DATE="${dna_startdate}" 
			
		dna_startdate=$(date +"%m/%d/%Y" -d "$dna_startdate + 1 day")
	done
	}


# FUNCTION TO process marketprivate_eom
dc_marketprivate_eom(){

	until [[ "$dc_startdate" > "$dc_lastdate" ]]
	do
		${path_pan}-file="${path_ktr}dc_market_private_EOM.ktr" -param:PROCESS_DATE="${dc_startdate}" 
	
		dc_startdate=$(date +"%m/%d/%Y" -d "$dc_startdate + 1 day")
	done
	}


# FUNCTION TO process marketprivate_eom
adsym_marketprivate_eom(){
	
	until [[ "$adsym_startdate" > "$adsym_lastdate" ]]
	do
		${path_pan}-file="${path_ktr}adsym_market_private_EOM.ktr" -param:PROCESS_DATE="${adsym_startdate}" 
	
		adsym_startdate=$(date +"%m/%d/%Y" -d "$adsym_startdate + 1 day")
	done
	}

# FUNCTION TO process marketprivate_eom
adtrans_marketprivate_eom(){

	until [[ "$adtrans_startdate" > "$adtrans_lastdate" ]]
	do
		${path_pan}-file="${path_ktr}adtrans_market_private_EOM.ktr" -param:PROCESS_DATE="${adtrans_startdate}" 
	
		adtrans_startdate=$(date +"%m/%d/%Y" -d "$adtrans_startdate + 1 day")
	done
	}

# FUNCTION TO process marketprivate_eom
tm_marketprivate_eom(){

	until [[ "$tm_startdate" > "$tm_lastdate" ]]
	do
		${path_pan}-file="${path_ktr}tm_market_private_EOM.ktr" -param:PROCESS_DATE="${tm_startdate}" 
	
		tm_startdate=$(date +"%m/%d/%Y" -d "$tm_startdate + 1 day")
	done
	}

# FUNCTION TO process marketprivate_eom
springs_marketprivate_eom(){
	
	until [[ "$springs_startdate" > "$springs_lastdate" ]]
	do
		${path_pan}-file="${path_ktr}springserve_market_private_EOM.ktr" -param:PROCESS_DATE="${springs_startdate}" 

		springs_startdate=$(date +"%Y-%m-%d" -d "$springs_startdate + 1 day")
	done
	}


# Beginning of script
dna_knuckled
dc_knuckled
adsym_knuckled
tm_knuckled
adtrans_knuckled
#springs_knuckled

# function call 
dna_marketprivate_eom
dc_marketprivate_eom
adsym_marketprivate_eom
adtrans_marketprivate_eom
tm_marketprivate_eom
springs_marketprivate_eom

