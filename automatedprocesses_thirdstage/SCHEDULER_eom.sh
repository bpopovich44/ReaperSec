#!/bin/bash -e

##
# -Runs all daily level processes
# -Sends MGNT and Daily reports
##

EMAIL="bill@epiphanyai.com"
START_TIME=$(date +%s)
YESTERDAYDATE_1=$(date +%Y-%m-%d -d yesterday)
YESTERDAYDATE_2=$(date +%m/%d/%Y -d yesterday)
TIMESTAMP="$(date "+%Y-%m-%d %H:%M:%S")"

lastmonth_start1="$(date -d "-1 month" +%m/01/%Y)"
lastmonth_end1="$(date -d "-$(date +%d) days +0  month" +%m/%d/%Y)"

lastmonth_start2="$(date -d "-1 month" +%Y-%m-01)"
lastmonth_end2="$(date -d "-$(date +%d) days +0 month" +%Y-%m-%d)"

# Paths
path_kitchen="/home/ec2-user/data-integration/kitchen.sh "
path_kjb="/home/ec2-user/data-integration/epiphany_kjb/"	
path_daily_log="/home/ec2-user/Epiphany_logs/daily_process.log"
path_error_log="/home/ec2-user/Epiphany_logs/daily_error.log"
path_daily_eom="/home/ec2-user/Epiphany_logs/daily_eom.log"
path_file="/usr/local/sbin/"
path_pan="/home/ec2-user/data-integration/pan.sh "
path_ktr="/home/ec2-user/data-integration/epiphany_ktr/"

# Databases
mysql_db="mysql --defaults-group-suffix=epiphanyeom -N -e "
mysql_db1="mysql --defaults-group-suffix=epiphanydb -N -e "

file1="data_file.py"
file2="python_dbconfig.py"
file3="aol_api.py"
file4="springs_api.py"

platforms=( "dna" "dc" "adsym" "tm" "adtrans" "springserve")
report_book=(  "inventoryreport" "market_private" "market_public" )

send_error_mail(){

	ERROR_EMAIL="bill@epiphanyai.com"

	ERROR_SUBJECT="*** ${platform}_${report}.py had an error ***"

	# Add comments for error email
	ERROR_COMMENT=$(cat <<- EOF
	*** An error occured on ${platform}_${script} at ${TIMESTAMP} ***




	--dataTeam



	EOF
	)

	${path_kitchen}-file="${path_kjb}script_ERROR.kjb" -param:ERROR_EMAIL="${ERROR_EMAIL}" -param:ERROR_COMMENT="${ERROR_COMMENT}" -param:ERROR_SUBJECT="${ERROR_SUBJECT}" 

	}


send_reports(){

	## Check tables and send reports if yesterdays date present
	EOM_Aggregate=$(${mysql_db1} "SELECT NULL FROM EOM_Aggregate WHERE DATE IN ("\'${YESTERDAYDATE_1}\'" "\'${YESTERDAYDATE_2}\'"  LIMIT 1") 
	EOM_Final=$(${mysql_db} "SELECT NULL FROM reports_Marketplace WHERE DATE ="\'${YESTERDAYDATE_1}\'"LIMIT 1") 


	if [[ -n $EOM_Aggregate ]] &&
   	   [[ -n $EOM_Final ]] 
	then
		${path_file_g}report_EOM.sh

		return 0
	else
		printf "\n ${TIMESTAMP} Error.  Reports were not sent." >> ${path_error_log} && return 1
	fi
		
	}


sliceNdice_eom(){

        eom_startdate="$(date -d "-1 month" +%Y-%m-01)"
        eom_lastdate="$(date -d "-$(date +%d) days +0  month" +%Y-%m-%d)"

        cdate_startdate="$(date -d "-1 month" +%Y-%m-01)"
        cdate_lastdate="$(date -d "-$(date +%d) days +0  month" +%Y-%m-%d)"

        until [[ "$eom_startdate" > "$eom_lastdate" ]]
        do
                ${path_pan}-file="${path_ktr}sliceNdice_EOM.ktr" -param:PROCESS_DATE="${eom_startdate}" -param:CDATE="${cdate_startdate}"

                eom_startdate=$(date +"%Y-%m-%d" -d "$eom_startdate + 1 day")
                cdate_startdate=$(date +"%Y-%m-%d" -d "$cdate_startdate + 1 day")
        done
        }


pentaho(){
	
	start_date="1"
	end_date=$(date -d "-$(date +%d) days +0 month" +%d)
	
	startdate_1="$(date -d "-1 month" +%m/01/%Y)"
	lastdate_1="$(date -d "-$(date +%d) days +0  month" +%m/%d/%Y)"

	startdate_2="$(date -d "-1 month" +%Y-%m-01)"
	lastdate_2="$(date -d "-$(date +%d) days +0 month" +%Y-%m-%d)"

	for (( date=$start_date; date<=$end_date; date++ ))
	do
	
	       	case $platform in

                	"springserve" )

                                	${path_pan}-file="${path_ktr}${platform}_${report}_EOM.ktr" -param:PROCESS_DATE="${startdate_2}" 

                                	startdate_2=$(date +"%Y-%m-%d" -d "$startdate_2 + 1 day")
                	;;

                	"dna"|"dc"|"adsym"|"tm"|"adtrans" )

                                	${path_pan}-file="${path_ktr}${platform}_${report}_EOM.ktr" -param:PROCESS_DATE="${startdate_1}" 

                                	startdate_1=$(date +"%m/%d/%Y" -d "$startdate_1 + 1 day")
                	;;
        	esac

	done

        # Reset variable to beginning of month for next iteration
        #startdate_1="$(date -d "-1 month" +%m/01/%Y)"
        #startdate_2="$(date -d "-1 month" +%Y-%m-01)"

        }


eom_processes(){
	count=

	[[ $platform == "springserve" ]] && prefix="springserve" || prefix="oath"		

	[[ -x ${path_file}"${prefix}_${report}_eom.py" ]] && ${path_file}"${prefix}_${report}_eom.py" ${platform} || return 0 
	check_db=$(${mysql_db}"SELECT NULL FROM "${platform}_${report}_EOM" WHERE DATE IN ("\'${lastmonth_start1}\'", "\'${lastmonth_start2}\'") LIMIT 1")
	#check_db=""	
	if [[ -z "${check_db}" ]]
	then
		while [[ -z "${check_db}" ]] && [[ "${count}" -lt 3 ]]
		do
			[[ -x ${path_file}"${prefix}_${report}_eom.py" ]] && ${path_file}"${prefix}_${report}_eom.py" ${platform} || return 0 
			check_db=$(${mysql_db}"SELECT NULL FROM "${platform}_${report}_EOM" WHERE DATE IN ("\'${lastmonth_start1}\'", "\'${lastmonth_start2}\'") LIMIT 1")
			#check_db=""

			count=$((count + 1))
		done
	fi

	# Error handling 
	check_db=$(${mysql_db}"SELECT NULL FROM "${platform}_${report}_EOM" WHERE DATE IN ("\'${lastmonth_start1}\'", "\'${lastmonth_start2}\'") LIMIT 1")
	[[ -z "${check_db}" ]] && { send_error_mail; printf "\n${TIMESTAMP} ${platform}_${script} ERROR. \
	LOOK AT daily_process.log for more information." >> ${path_error_log}; return 1; } || pentaho ${platform} ${report}

	}
		

launch_processes(){

        for report in "${report_book[@]}"
        do
                [[ "$?" == "0" ]] && for platform in "${platforms[@]}"
                do
                        [[ "$?" == "0" ]] && eom_processes ${report} ${platform}
                done
        done

        [[ "$?" == "0" ]] && return 0 || return 1

        }


clear_tables(){

        clean_Aggregate=$(${mysql_db1}"DELETE FROM EOM_Aggregate")
        clean_Final=$(${mysql_db1}"DELETE FROM EOM_Final")
        clean_InventorySource=$(${mysql_db1}"DELETE FROM EOM_InventorySource")
        clean_Marketplace=$(${mysql_db1}"DELETE FROM EOM_Marketplace")

        }


check_existing_processes(){

	[[ ! -f ${path_file}"${file1}" ]] && return 1
	[[ ! -f ${path_file}"${file2}" ]] && return 1
	[[ ! -f ${path_file}"${file3}" ]] && return 1
	[[ ! -f ${path_file}"${file4}" ]] && return 1
	
	return 0
	}


run_eom(){

	## STEP 1 check existing processes
	check_existing_processes

	## STEP 2 clear db tables of last month data
	[[ "$?" == '0' ]] && clear_tables || return 1
	
	## STEP 3 
	[[ "$?" == '0' ]] && launch_processes
	
	## STEP 4 
	[[ "$?" == '0' ]] && sliceNdice_eom 

	## STEP 5	 
#	[[ "$?" == '0' ]] && send_reports
	
	}


# Execute script and error handling of script
run_eom 2>&1 | tee -a ${path_daily_eom}

# SAVE TO USE WHEN PASS TO TWO LOGS
#run_eom > >(tee -a ${path_daily_log}) 2> >(tee -a ${path_error_log} >&2)

[[ "${PIPESTATUS[0]}" == "0" ]] && exit 0 || { printf "\n${TIMESTAMP} Exit code 1.  Look at daily_process.log for more information" >> ${path_error_log}; exit 1; }
