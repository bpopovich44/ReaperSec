#!/bin/bash -e

##
# -Runs all daily level processes
# -Sends MGNT and MonthlyReports
##

EMAIL="bill@epiphanyai.com"
START_TIME=$(date +%s)
YESTERDAYDATE_1=$(date "+%Y-%m-%d" -d yesterday)
YESTERDAYDATE_2=$(date "+%m/%d/%Y" -d yesterday)
TIMESTAMP="$(date "+%Y-%m-%d %H:%M:%S")"

# Paths
path_file="/usr/local/sbin/"
path_pan="/home/ec2-user/data-integration/pan.sh "
path_kitchen="/home/ec2-user/data-integration/kitchen.sh "
path_ktr="/home/ec2-user/data-integration/epiphany_ktr/"
path_kjb="/home/ec2-user/data-integration/epiphany_kjb/"	
path_kjb_error="/home/ec2-user/data-integration/epiphany_kjb/ERROR_kjb/"	
path_daily_log="/home/ec2-user/Epiphany_logs/daily_domain.log"
path_error_log="/home/ec2-user/Epiphany_logs/error.log"

file1="aol_api.py"
file2="springs_api.py"
file3="data_file.py"
file4="python_dbconfig.py"

# Databases
mysql_db="mysql --defaults-group-suffix=epiphanydb  -N -se " 
mysql_db1="mysql --defaults-group-suffix=domainlevel -N -se "

# Arrays to hold platforms and daily tables
platforms=( "dna" "dc" "adsym" "tm" "adtrans" "springserve" )
report_book=( "domain" "InventorySources" ) 


send_error_mail(){

	${path_kitchen}-file="${path_kjb_error}script_ERROR.kjb" -param:EMAIL="${EMAIL}" -param:TABLE="${report}" -param:PLATFORM="${platform}" -param:TIMESTAMP_ERROR="${TIMESTAMP}"

	}


send_reports(){

	## Check tables and send reports if yesterdays date present
	reports_InventorySource=$(${mysql_db} "SELECT NULL FROM reports_InventorySource WHERE DATE ="\'${YESTERDAYDATE_1}\'"LIMIT 1") 
	reports_Marketplace=$(${mysql_db} "SELECT NULL FROM reports_Marketplace WHERE DATE ="\'${YESTERDAYDATE_1}\'"LIMIT 1") 
	test_Aggregate=$(${mysql_db} "SELECT NULL FROM test_Aggregate WHERE DATE ="\'${YESTERDAYDATE_1}\'"LIMIT 1") 
	test_Final=$(${mysql_db} "SELECT NULL FROM test_Final WHERE DATE ="\'${YESTERDAYDATE_1}\'"LIMIT 1") 


	if [[ -n $reports_InventorySource ]] &&
   	   [[ -n $reports_Marketplace ]] &&
   	   [[ -n $test_Aggregate ]] &&
   	   [[ -n $test_Final ]]
	then
		${path_file}report_TOTALS_INTERNAL.sh
		${path_file}report_Monthly_NEW.sh

		return 0
	else
		printf "\n ${TIMESTAMP} Error.  Reports were not sent." >> ${path_daily_log} && return 1
	fi
		
	}


run_inventorySources(){
	
        count=0
        num_per_rotation="300000"
        invsources_v2_count=$(${mysql_db1} "SELECT COUNT(*) FROM "${platform}_InventorySources_v2" WHERE DATE ="\'${YESTERDAYDATE_1}\'" OR "\'${YESTERDAYDATE_2}\'"")
        number_of_loops=$(($invsources_v2_count / $num_per_rotation))
	rownum_start=0
        rownum_end=299999

        # Loop rotates through count 
        until [[ $count -eq $number_of_loops ]]
        do

        	${path_pan}-file="${path_ktr}${platform}_inventorysources_v2.ktr" -param:ROWNUM_START="${rownum_start}" -param:ROWNUM_END="${rownum_end}"
		
                count=$((count + 1))
                rownum_start=$((rownum_start + ${num_per_rotation}))
		
		[[ $count -eq $number_of_loops ]] && break
                rownum_end=$((rownum_end + ${num_per_rotation}))

        done

        ${path_pan}-file="${path_ktr}${platform}_inventorysources_v2.ktr" -param:ROWNUM_START="${rownum_start}" -param:ROWNUM_END="${invsources_v2_count}"
	return 0
        }


run_domain(){

	# Run domain level ktr
	${path_pan}-file="${path_ktr}${platform}_domain_v2.ktr" # -param:PROCESS_REPORT="${platform}_${report}_v2"

	[[ "$?" == '0' ]] && run_inventorySources ${platform} || return 1
	}


daily_domain(){
	count=

	[[ $platform == "springserve" ]] && prefix="springserve" || prefix="oath"		

	[[ -x ${path_file}"${prefix}_${report}_v2.py" ]] && ${path_file}"${prefix}_${report}_v2.py" ${platform} || return 0 
	check_db=$(${mysql_db1}"SELECT NULL FROM "${platform}_${report}_v2" WHERE DATE IN ("\'${YESTERDAYDATE_1}\'", "\'${YESTERDAYDATE_2}\'") LIMIT 1")
	
	if [[ -z "${check_db}" ]]
	then
		while [[ -z "${check_db}" ]] && [[ "${count}" -lt 3 ]]
		do
			[[ -x ${path_file}"${prefix}_${report}_v2.py" ]] && ${path_file}"${prefix}_${report}_v2.py" ${platform} || return 0 
			check_db=$(${mysql_db1}"SELECT NULL FROM "${platform}_${report}_v2" WHERE DATE IN ("\'${YESTERDAYDATE_1}\'", "\'${YESTERDAYDATE_2}\'") LIMIT 1")

			count=$((count + 1))
		done
	fi

	check_db=$(${mysql_db1}"SELECT NULL FROM "${platform}_${report}_v2" WHERE DATE IN ("\'${YESTERDAYDATE_1}\'", "\'${YESTERDAYDATE_2}\'") LIMIT 1")
			
	case ${check_db} in

                ""|"0" )

                        { send_error_mail; printf "\n${TIMESTAMP} ${platform}_${report}_v2.py ERROR. \
                        LOOK AT daily_process.log for more information." >> ${path_error_log}; return 1; }

                ;;

                "NULL" )

                        [[ ${report} = "domain" ]] && return 0
                        [[ ${report} = "InventorySources" ]] && run_domain ${platform} ${report} ${prefix}

                ;;
        esac

	}


run_scripts(){
	
	# Two for loops to launch python processes
	for report in "${report_book[@]}"
	do
		[[ "$?" == "0" ]] && daily_domain ${platform} ${report}
	done 

	[[ "$?" == "0" ]] && return 0 || return 1
	}


launch_processes(){
	
	# Two for loops to launch python processes
	for platform in "${platforms[@]}"
	do
		[[ "$?" == "0" ]] && run_scripts ${platform} &
	done 

	[[ "$?" == "0" ]] && return 0 || return 1
	}


check_existing_scripts(){

	[[ ! -f ${path_file}"${file1}" ]] && return 1
	[[ ! -f ${path_file}"${file2}" ]] && return 1
	[[ ! -f ${path_file}"${file3}" ]] && return 1
	[[ ! -f ${path_file}"${file4}" ]] && return 1
	
	return 0
	}


run_daily_domain(){

	## STEP 1 check for existing processes
	check_existing_scripts

	## STEP 2 launch python scripts
	[[ "$?" == '0' ]] && launch_processes || return 1
	
	## STEP 3
#	[[ "$?" == '0' ]] && send_reports

	## STEP 4 Entry into Epiphany_logs		
#	log_entry
	}



# Execute script and error handling of script
run_daily_domain
# 2>&1 | tee -a ${path_daily_log}

# SAVE TO USE WHEN PASS TO TWO LOGS
#run_daily_domain > >(tee -a ${path_daily_log}) 2> >(tee -a ${path_error_log} >&2)

#[[ "${PIPESTATUS[0]}" == "0" ]] && exit 0 || { printf "\n${TIMESTAMP} Exit code 1.  Look at daily_process.log for more information" >> ${path_error_log}; exit 1; }
