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

# Databases
mysql_db="mysql --defaults-group-suffix=epiphanydb  -N -se " 
mysql_db1="mysql --defaults-group-suffix=domainlevel -N -se "

# Arrays to hold platforms and daily tables
#platforms=( "springserve" )
platforms=( "dna" "dc" "adsym" "tm" "adtrans" "springserve" )
report_book=( "domain" "InventorySources" ) 




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

        	echo ${path_pan}-file="${path_ktr}${platform}_inventorysources_v2.ktr" -param:ROWNUM_START="${rownum_start}" -param:ROWNUM_END="${rownum_end}"
		
                count=$((count + 1))
                rownum_start=$((rownum_start + ${num_per_rotation}))
		
		[[ $count -eq $number_of_loops ]] && break
                rownum_end=$((rownum_end + ${num_per_rotation}))

        done

        echo ${path_pan}-file="${path_ktr}${platform}_inventorysources_v2.ktr" -param:ROWNUM_START="${rownum_start}" -param:ROWNUM_END="${invsources_v2_count}"
	return 0
        }


run_domain(){
	
	# Run domain level ktr
	echo ${path_pan}-file="${path_ktr}${platform}_domain_v2.ktr" # -param:PROCESS_REPORT="${platform}_${report}_v2"

	[[ "$?" == '0' ]] && run_inventorySources ${platform} || return 1
	}


daily_domain(){

	count=

	[[ $platform == "springserve" ]] && prefix="springserve" || prefix="oath"		

	[[ -x ${path_file}"${prefix}_${report}_v2.py" ]] && echo ${path_file}"${prefix}_${report}_v2.py" ${platform} || return 0 
	check_db=$(${mysql_db1}"SELECT NULL FROM "${platform}_${report}_v2" WHERE DATE IN ("\'${YESTERDAYDATE_1}\'", "\'${YESTERDAYDATE_2}\'") LIMIT 1")
	
	if [[ -z "${check_db}" ]]
	then
		while [[ -z "${check_db}" ]] && [[ "${count}" -lt 3 ]]
		do
			[[ -x ${path_file}"${prefix}_${report}_v2.py" ]] && echo ${path_file}"${prefix}_${report}_v2.py" ${platform} || return 0 
			check_db=$(${mysql_db1}"SELECT NULL FROM "${platform}_${report}_v2" WHERE DATE IN ("\'${YESTERDAYDATE_1}\'", "\'${YESTERDAYDATE_2}\'") LIMIT 1")

			count=$((count + 1))
		done
	fi

	check_db=$(${mysql_db1}"SELECT NULL FROM "${platform}_${report}_v2" WHERE DATE IN ("\'${YESTERDAYDATE_1}\'", "\'${YESTERDAYDATE_2}\'") LIMIT 1")
			
	case ${check_db} in

                ""|"0" )
			echo no revenue
                        #{ send_error_mail; printf "\n${TIMESTAMP} ${platform}_${report}_v2.py ERROR. LOOK AT daily_process.log for more information." >> ${path_error_log}; return 1; }

                ;;

                "NULL" )

                        echo [[ ${report} = "domain" ]] && return 0
                        #[[ ${report} = "InventorySources" ]] && echo complete 
			echo [[ ${report} = "InventorySources" ]] && run_domain ${platform} ${report} ${prefix}

                ;;
        esac

	}


run_scripts(){
	
	for report in "${report_book[@]}"
	do
		[[ "$?" == "0" ]] && daily_domain ${platform} ${report}
	done 

	[[ "$?" == "0" ]] && return 0 || return 1
	}


launch_processes(){

	#Need two loops so can run each platform together and put as a background process
	for platform in "${platforms[@]}"
	do
		[[ "$?" == "0" ]] && run_scripts ${platform}
	done 

	[[ "$?" == "0" ]] && return 0 || return 1
	}



launch_processes

