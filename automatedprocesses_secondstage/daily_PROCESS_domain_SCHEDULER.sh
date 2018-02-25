#!/bin/bash

##
# - Runs all domain level processes
# - Send Domain level reports when complete	
##

path_sbin="/usr/local/sbin/"
reapdate=$(date +%Y-%m-%d -d yesterday)
reapdateFormat=$(date +%m/%d/%Y -d yesterday)
path_pan="/home/ec2-user/data-integration/pan.sh "
path_ktr="/home/ec2-user/data-integration/epiphany_ktr/"
path_kitchen="/home/ec2-user/data-integration/kitchen.sh "
path_kjb="'/home/ec2-user/data-integration/epiphany_kjb/" 
mysql_db="mysql --defaults-group-suffix=domainlevel -N -e "
send_email="${path_kitchen}-file=${path_kjb}InventorySources_v2_Error.kjb'"

platforms=( "dna" "dc" "adsym" "tm" "adtrans" "springserve" )

start_script(){
	for platform in "${platforms[@]}" 
	do
		echo running:\) "${platform} domain level and InventorySources_v2"
		run_domain_data ${platform} & 
	done
	}


process_domain_data(){
	${path_sbin}"${platform}_domainreport_v2.py" 
	${path_sbin}"${platform}_InventorySources_v2.py"

	}


run_domain_data(){
	count=
	
	process_domain_data ${platform}
	
	check_db=$(${mysql_db}"SELECT NULL FROM "${platform}_InventorySources_v2" WHERE DATE = "\'${reapdateFormat}\'" OR "\'${reapdate}\'"LIMIT 1")
	
	case $check_db in

		"NULL" ) 
			process_data ${platform}	
		;;
		
		"" )
			while [[ -z $check_db ]] && [[ $count -lt 3 ]]
       			do
      				process_domain_data ${platform}
				check_db=$(${mysql_db}"SELECT NULL FROM "${platform}_InventorySources_v2" WHERE DATE = "\'${reapdateFormat}\'" OR "\'${reapdate}\'"LIMIT 1")
				count=$((count + 1))
			done
       
			case $check_db in

				"NULL" ) 
					process_data ${platform}
				;;

				"" ) 
					eval $sendemail && exit 1
				;;
			esac
		;;
	esac
	}


process_data(){
	count=0
        number_per_rotation="300000"
	invsources_v2_count=$(${mysql_db} "SELECT COUNT(*) FROM "${platform}_InventorySources_v2" WHERE DATE ="\'${reapdateFormat}\'" OR "\'${reapdate}\'"")
	number_of_loops=$((invsources_v2_count / number_per_rotation))

	rownum_start=1
        rownum_end=299999

	# If database not empty with yesterday data, process domain level data for new tags 
	[[ -n $check_db ]] && ${path_pan}-file="${path_ktr}${platform}_domainreport_v2.ktr" || exit 1
				
	# Loop rotates through count 
	until [[ $count -eq $number_of_loops ]]
	do
		[[ $rownum_start -eq 1 ]] && rownum_start=0
		${path_pan}-file="${path_ktr}${platform}_inventorysources_v2.ktr" -param:ROWNUM_START="${rownum_start}" -param:ROWNUM_END="${rownum_end}"
		
		count=$((count + 1))			
		rownum_start=$((rownum_start + 300000))
		rownum_end=$((rownum_end + 300000))
	done
		${path_pan}-file="${path_ktr}${platform}_inventorysources_v2.ktr" -param:ROWNUM_START="${rownum_start}" -param:ROWNUM_END="${invsources_v2_count}"
	}


# Run domain script to check for new domains then run Inventorysources_v2 to process data
start_script

