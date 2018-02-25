#!/bin/bash

##
#
# EOM script runs all processes for EOM's
#
##

path_sbin="/usr/local/sbin/"
path_pan="/home/ec2-user/data-integration/pan.sh "
path_ktr="/home/ec2-user/data-integration/epiphany_ktr/"
path_ERROR="/root/data-integration/epiphany_kjb/ERROR_kjb/"
mysql_db="mysql --defaults-group-suffix=epiphanyeom -N -e "
sendemail="${path_kitchen}-file='${path_ERROR}eom_ERROR.kjb'"

startdate_1="$(date -d "-1 month" +%m/01/%Y)"
lastdate_1="$(date -d "-$(date +%d) days +0  month" +%m/%d/%Y)"

startdate_2="$(date -d "-1 month" +%Y-%m-01)"
lastdate_2="$(date -d "-$(date +%d) days +0 month" +%Y-%m-%d)"

platforms=( "dna" "dc" "adsym" "tm" "adtrans" "springserve" )
report_book=( "inventoryreport" "market_private" "market_public" )


eom_processes(){
	count=

	${path_sbin}"${platform}_${report}_EOM.py"
	check_db=$(${mysql_db} "SELECT NULL FROM "${platform}_${report}_EOM" WHERE DATE = "\'${startdate_1}\'" OR "\'${startdate_2}\'" LIMIT 1")

	if [[ -z $check_db ]]
	then	
		while [[ -z $check_db ]] && [[ $count -lt 3 ]]
		do
			${path_sbin}"${platform}_${report}_EOM.py"
			check_db=$(${mysql_db} "SELECT NULL FROM "${platform}_${report}_EOM" WHERE DATE = "\'${startdate_1}\'" OR "\'${startdate_2}\'" LIMIT 1")
			count=$((count + 1))
		done
	fi		
	
	pentaho ${platform} ${report}
	}


pentaho(){

        case $platform in

		"springserve" )
			
			until [[ "$startdate_2" > "$lastdate_2" ]]
        		do
                		${path_pan}-file="${path_ktr}${platform}_${report}_EOM.ktr" -param:PROCESS_DATE="${startdate_2}"

                		startdate_2=$(date +"%Y-%m-%d" -d "$startdate_2 + 1 day")
        		done
	
			# Reset variable to beginning of month for next iteration
			startdate_2="$(date -d "-1 month" +%Y-%m-01)"
		;;
		
		"dna"|"dc"|"adsym"|"tm"|"adtrans" )
			
			until [[ "$startdate_1" > "$lastdate_1" ]]
        		do
                		${path_pan}-file="${path_ktr}${platform}_${report}_EOM.ktr" -param:PROCESS_DATE="${startdate_1}"

                		startdate_1=$(date +"%m/%d/%Y" -d "$startdate_1 + 1 day")
        		done
	
			# Reset variable to beginning of month for next iteration
			startdate_1="$(date -d "-1 month" +%m/01/%Y)"
		;;	
	esac
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


launch_processes(){
		
	for platform in "${platforms[@]}"
	do
		for report in "${report_book[@]}"
		do
			eom_processes ${platform} ${report} & 
		done
	done
	} 


#launch_processes
sliceNdice_eom


