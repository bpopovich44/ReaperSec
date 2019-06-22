#!/bin/bash -e 

##
#
# Script runs and checks siteAdditions
#
##

TODAYDATE=$(date "+%Y-%m-%d")
TIMESTAMP="$(date "+%Y-%m-%d %H:%M:%S")"
YESTERDAYDATE_1=$(date +%m/%d/%Y -d yesterday)
YESTERDAYDATE_2=$(date +%Y-%m-%d -d yesterday)
path_file="/usr/local/sbin/"
path_kitchen="/home/ec2-user/data-integration/kitchen.sh "
path_kjb="/home/ec2-user/data-integration/epiphany_kjb/"
path_siteAdditions_log="/home/ec2-user/Epiphany_logs/siteAdditions.log"
path_error_log="/home/ec2-user/Epiphany_logs/error.log"
mysql_db="mysql --defaults-group-suffix=epiphanysa -N -e "

# Needed files for script 
file1="data_file.py"
file2="python_dbconfig.py"
file3="aol_api.py"
script="siteAdditions.py"

table="site_addition"

# Array holding platforms
platforms=( "dc" "adsym" "tm" "adtrans" )


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


send_mail(){

	REPORT_EMAIL="collen@epiphanyai.com"
	REPORT_EMAIL_CC="bill@epiphanyai.com, eric@epiphanyai.com"
	REPORT_EMAIL_BCC="bill@epiphanai.com"

	REPORT_SUBJECT="Site additions for "${TODAYDATE}""
	
	#Add comments for email
	REPORT_COMMENT=$(cat <<- EOF
		Team,
	
		Site additions attached for dc, adsym, tm, adtrans.


		



		--dataTeam



	EOF
	)

	${path_kitchen}-file="${path_kjb}Site_addition-EMAILER.kjb" -param:REPORT_EMAIL="${REPORT_EMAIL}" -param:REPORT_EMAIL_CC="${REPORT_EMAIL_CC}" \
	-param:REPORT_EMAIL_BCC="bill@epiphanyai.com" -param:REPORT_SUBJECT="${REPORT_SUBJECT}" -param:REPORT_COMMENT="${REPORT_COMMENT}" 

	}


site_additions(){
	count=0
	
	# Check if scripts exists, then continue through loop
	[[ -x ${path_file}"${script}" ]] && ${path_file}"${script}" ${platform} || return 0 
	check_db=$(${mysql_db}"SELECT NULL FROM "${platform}_${table}" WHERE DATE IN ("\'${YESTERDAYDATE_1}\'", "\'${YESTERDAYDATE_2}\'") LIMIT 1")
	if [[ -z "${check_db}" ]]
	then
		while [[ -z "${check_db}" ]] && [[ "${count}" -lt 3 ]]
		do

			[[ -x ${path_file}"${script}" ]] && ${path_file}"${script}" ${platform} 
			check_db=$(${mysql_db}"SELECT NULL FROM "${platform}_${table}" WHERE DATE IN ("\'${YESTERDAYDATE_1}\'", "\'${YESTERDAYDATE_2}\'") LIMIT 1")
				
			count=$((count + 1))
		done
	fi

	# Error handling -- LEAVING RETURN ON EXIT CODE 0 FOR NOW, IF THERE IS AN ERROR OTHER PLATFORMS WILL RUN
	check_db=$(${mysql_db}"SELECT NULL FROM "${platform}_${table}" WHERE DATE IN ("\'${YESTERDAYDATE_1}\'", "\'${YESTERDAYDATE_2}\'") LIMIT 1")
	[[ -z $check_db ]] && { send_error_mail; printf "\n${TIMESTAMP} ${platform}_${script} ERROR. \
	Look at daily_process.log for more information." >> ${path_error_log}; return 1; } || return 0 
		
	} 


launch_processes(){

	for platform in "${platforms[@]}"
	do

		[[ "$?" == "0" ]] && site_additions ${platform} || return 1
		#[[ -x ${path_file}"${script}" ]] && site_additions ${platform} 
	done

	[[ "$?" == "0" ]] && return 0 || return 1

	}


check_existing_scripts(){

	[[ ! -f ${path_file}"${file1}" ]] && return 1
	[[ ! -f ${path_file}"${file2}" ]] && return 1
	[[ ! -f ${path_file}"${file3}" ]] && return 1
	[[ ! -f ${path_file}"${script}" ]] && return 1

	return 0
	}


run_site_additions(){

	## STEP 1 check existing processes
	check_existing_scripts 

	## STEP 2 launch python scripts
	[[ "$?" == "0" ]] && launch_processes || return 1

	## STEP 3 send email
	[[ "$?" == "0" ]] && send_mail || return 1

	}


# Execute script and error handling of script
run_site_additions 
#2>&1 | tee -a ${path_siteAdditions_log} 

# SAVE TO USE WHEN PASS TO TWO LOGS
#run_site_additions > >(tee -a ${path_hourly_log}) 2> >(tee -a ${path_error_log} >&2) 

# Error handling for pipe status on execution function and end of script
[[ "${PIPESTATUS[0]}" == "0" ]] && exit 0 || { printf "\n${TIMESTAMP} ${script} Exit code 1.  Look at daily_process.log for more information" >> ${path_error_log}; exit 1; }

  
