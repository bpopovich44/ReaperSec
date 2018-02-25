#!/bin/bash

##
#
# knuckled script runs and checks daily_market_public database tables
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


dna_knuckled(){
	dna_count=

	${path_sbin}dna_market_public_EOM.py
	dna=$(${mysql_db} "SELECT NULL FROM dna_market_public_EOM LIMIT 1")

	if [[ -z $dna ]]
	then
		while [[ -z $dna ]] && [[ $dna_count -le 3 ]]
		do
			${path_sbin}dna_market_public_EOM.py
			dna=$(${mysql_db} "SELECT NULL FROM dna_market_public_EOM LIMIT 1")
			dna_count=$(($dna_count + 1))
		done
	fi

	[[ -z $dna ]] && eval $sendemail
	}


dc_knuckled(){
	dc_count=

	${path_sbin}dc_market_public_EOM.py
	dc=$(${mysql_db} "SELECT NULL FROM dc_market_public_EOM LIMIT 1")
	
	if [[ -z $dc ]]
	then
		while [[ -z $dc ]] && [[ $dc_count -le 3 ]]
		do
			${path_sbin}dc_market_public_EOM.py
			dc=$(${mysql_db} "SELECT NULL FROM dc_market_public_EOM LIMIT 1")
			dc_count=$(($dc_count + 1))
		done
	fi		
	[[ -z $dc ]] && eval $sendemail
	}


adsym_knuckled(){
	adsym_count=

	${path_sbin}adsym_market_public_EOM.py
	adsym=$(${mysql_db} "SELECT NULL FROM adsym_market_public_EOM LIMIT 1")
	
	if [[ -z $adsym ]]
	then
		while [[ -z $adsym ]] && [[ $adsym_count -le 3 ]]
		do
			${path_sbin}adsym_market_public_EOM.py
			adsym=$(${mysql_db} "SELECT NULL FROM adsym_market_public_EOM LIMIT 1")
			adsym_count=$(($adsym_count + 1))
		done
	fi	
	
	[[ -z $adsym ]] && eval $sendemail
	}


tm_knuckled(){
	tm_count=

	${path_sbin}tm_market_public_EOM.py
	tm=$(${mysql_db} "SELECT NULL FROM tm_market_public_EOM LIMIT 1")
	
	if [[ -z $tm ]]
	then
		while [[ -z $tm ]] && [[ $tm_count -le 3 ]]
		do
			${path_sbin}tm_market_public_EOM.py
			tm=$(${mysql_db} "SELECT NULL FROM tm_market_public_EOM LIMIT 1")
			tm_count=$(($tm_count + 1))
		done
	fi
	
	[[ -z $tm ]] && eval $sendemail
	}


adtrans_knuckled(){
	adtrans_count=

	${path_sbin}adtrans_market_public_EOM.py
	adtrans=$(${mysql_db} "SELECT NULL FROM adtrans_market_public_EOM LIMIT 1")
	
	if [[ -z $adtrans ]]
	then
		while [[ -z $adtrans ]] && [[ $adtrans_count -le 3 ]]
		do
			${path_sbin}adtrans_market_public_EOM.py
			adtrans=$(${mysql_db} "SELECT NULL FROM adtrans_market_public_EOM LIMIT 1")
			adtrans_count=$(($adtrans_count + 1))
		done
	fi	
	
	[[ -z $adtrans ]] && eval $sendemail
	}


# FUNCTION TO process marketpublic_eom
dna_marketpublic_eom(){
	
	until [[ "$dna_startdate" > "$dna_lastdate" ]]
	do
		${path_pan}-file="${path_ktr}dna_market_public_EOM.ktr" -param:PROCESS_DATE="${dna_startdate}" 
	
		dna_startdate=$(date +"%m/%d/%Y" -d "$dna_startdate + 1 day")
	done
}


# FUNCTION TO process marketpublic_eom
dc_marketpublic_eom(){

	until [[ "$dc_startdate" > "$dc_lastdate" ]]
	do
		${path_pan}-file="${path_ktr}dc_market_public_EOM.ktr" -param:PROCESS_DATE="${dc_startdate}" 
	
		dc_startdate=$(date +"%m/%d/%Y" -d "$dc_startdate + 1 day")
	done
	}


# FUNCTION TO process marketpublic_eom
adsym_marketpublic_eom(){

	until [[ "$adsym_startdate" > "$adsym_lastdate" ]]
	do
		${path_pan}-file="${path_ktr}adsym_market_public_EOM.ktr" -param:PROCESS_DATE="${adsym_startdate}" 
	
		adsym_startdate=$(date +"%m/%d/%Y" -d "$adsym_startdate + 1 day")
	done
	}


# FUNCTION TO process marketpublic_eom
adtrans_marketpublic_eom(){

	until [[ "$adtrans_startdate" > "$adtrans_lastdate" ]]
	do
		${path_pan}-file="${path_ktr}adtrans_market_public_EOM.ktr" -param:PROCESS_DATE="${adtrans_startdate}" 
	
		adtrans_startdate=$(date +"%m/%d/%Y" -d "$adtrans_startdate + 1 day")
	done
	}


# FUNCTION TO process marketpublic_eom
tm_marketpublic_eom(){
 
	until [[ "$tm_startdate" > "$tm_lastdate" ]]
	do
		${path_pan}-file="${path_ktr}tm_market_public_EOM.ktr" -param:PROCESS_DATE="${tm_startdate}" 
	
		tm_startdate=$(date +"%m/%d/%Y" -d "$tm_startdate + 1 day")
	done
	}


# Beginning of script
dna_knuckled
dc_knuckled
adsym_knuckled
tm_knuckled
adtrans_knuckled

# function call 
dna_marketpublic_eom
dc_marketpublic_eom
adsym_marketpublic_eom
adtrans_marketpublic_eom
tm_marketpublic_eom
