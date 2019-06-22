#!/bin/bash -e 

##
#
# Script runs and checks market_today database tables accross all platforms
#
##

TIMESTAMP="$(date "+%Y-%m-%d %H:%M:%S")"
TODAYDATE_1=$(date "+%m/%d/%Y")
TODAYDATE_2=$(date "+%Y-%m-%d")
path_file="/usr/local/sbin/"
path_kitchen="/home/ec2-user/data-integration/kitchen.sh "
path_kjb="/home/ec2-user/data-integration/epiphany_kjb/"
path_sourcelevel_log="/home/ec2-user/Epiphany_logs/sourcelevel.log"
path_error_log="/home/ec2-user/Epiphany_logs/error.log"
mysql_db="mysql --defaults-group-suffix=sourcelevel -N -e "

# Files
file1="data_file.py"
file2="python_dbconfig.py"
file3="aol_api.py"
file4="springs_api.py"
file5="oath_market_today.py"

script="market_today.py"
table="market_today"

# Array holding platforms
platforms=( "dna" "dc" "adsym" "tm" "adtrans" "springserve" )


send_error_mail(){
	
	ERROR_EMAIL="bill@epiphanyai.com"

	ERROR_SUBJECT="*** ${platform}_${table} had an error ***"

	# Add comments for error email
	ERROR_COMMENT=$(cat <<- EOF
	*** An error occured on ${platform}_${script} at ${TIMESTAMP} ***




	--dataTeam


	EOF
	)
	
	${path_kitchen}-file="${path_kjb}script_ERROR.kjb" -param:ERROR_EMAIL="${ERROR_EMAIL}" -param:ERROR_COMMENT="${ERROR_COMMENT}" -param:ERROR_SUBJECT="${ERROR_SUBJECT}"

	}


market_today(){
	count=
	
	[[ ${platform} == "springserve" ]] && prefix="springserve" || prefix="oath"

	[[ -x ${path_file}"${prefix}_${script}" ]] && ${path_file}"${prefix}_${script}" ${platform} || return 0
	check_db=$(${mysql_db}"SELECT NULL FROM "${platform}_${table}" WHERE DATE IN ("\'${TODAYDATE_1}\'", "\'${TODAYDATE_2}\'") LIMIT 1")
	
	if [[ -z $check_db ]]
	then
		while [[ -z "${check_db}" ]] && [[ "${count}" -lt 3 ]]
		do
			sleep 2
			[[ -x ${path_file}"${prefix}_${script}" ]] && ${path_file}"${prefix}_${script}" ${platform} || return 0
			check_db=$(${mysql_db}"SELECT NULL FROM "${platform}_${table}" WHERE DATE IN ("\'${TODAYDATE_1}\'", "\'${TODAYDATE_2}\'") LIMIT 1")
			
			count=$((count + 1))
		done
	fi

	# Error handling -- LEAVING RETURN ON EXIT CODE 0 FOR NOW, IF THERE IS AN ERROR OTHER PLATFORMS WILL RUN
	check_db=$(${mysql_db}"SELECT NULL FROM "${platform}_${table}" WHERE DATE IN ("\'${TODAYDATE_1}\'", "\'${TODAYDATE_2}\'") LIMIT 1")
	[[ -z $check_db ]] && { send_error_mail; printf "\n${TIMESTAMP} ${platform}_${script} ERROR. \
	Look at sourcelevel.log for more information." >> ${path_error_log}; return 0; } || return 0 
	
	} 


check_existing_files(){

	[[ ! -f ${path_file}"${file1}" ]] && return 1
	[[ ! -f ${path_file}"${file2}" ]] && return 1
	[[ ! -f ${path_file}"${file3}" ]] && return 1
	[[ ! -f ${path_file}"${file4}" ]] && return 1
	[[ ! -f ${path_file}"${file5}" ]] && return 1

	return 0
	}


launch_processes(){
	
	for platform in "${platforms[@]}"
	do
		[[ "$?" == "0" ]] && market_today ${platform} || return 1
	done

	[[ "$?" == "0" ]] && return 0 || return 1
	} 


run_market_today(){

	## STEP 1 check for existing files
	check_existing_files

	## STEP 2 launch processes
	[[ "$?" == "0" ]] && launch_processes || return 1

	}
	

# Execute script and error handling of script
run_market_today
# 2>&1 | tee -a ${path_sourcelevel_log} 

# SAVE TO USE WHEN PASS TO TWO LOGS
#run_market_today > >(tee -a ${path_hourly_log}) 2> >(tee -a ${path_error_log} >&2) 

# Error handling
[[ "${PIPESTATUS[0]}" == "0" ]] && exit 0 || { printf "\n${TIMESTAMP}  Exit code 1.  Look at sourcelevel.log for more information" >> ${path_error_log}; exit 1; }

  
