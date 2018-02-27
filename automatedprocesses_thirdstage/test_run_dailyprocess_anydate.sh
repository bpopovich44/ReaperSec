#!/bin/bash -e

##
# -Runs all daily level processes
# -Sends MGNT and Daily reports
##

begin_date_d="1"
end_date_d="12"

begin_date1="02/01/2018"
begin_date2="2018-02-01"

ending_date1="02/12/2018"
ending_date2="2018-02-12"

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
	end_date="12"
	
	startdate_1="02/01/2018"
	lastdate_1="02/12/2018"

	startdate_2="2018-02-01"
	lastdate_2="2018-02-12"

	for (( date=$start_date; date<=$end_date; date++ ))
	do
	
	       	case $platform in

                	"springserve" )

                                	${path_pan}-file="${path_ktr}${platform}_${report}_SPECIFIC_DATE.ktr" -param:PROCESS_DATE="${startdate_2}" 

                                	startdate_2=$(date +"%Y-%m-%d" -d "$startdate_2 + 1 day")
                	;;

                	"dna"|"dc"|"adsym"|"tm"|"adtrans" )

                                	${path_pan}-file="${path_ktr}${platform}_${report}_SPECIFIC_DATE.ktr" -param:PROCESS_DATE="${startdate_1}" 

                                	startdate_1=$(date +"%m/%d/%Y" -d "$startdate_1 + 1 day")
                	;;
        	esac

	done

        # Reset variable to beginning of month for next iteration
        #startdate_1="$(date -d "-1 month" +%m/01/%Y)"
        #startdate_2="$(date -d "-1 month" +%Y-%m-01)"

        }



launch_processes(){

        for report in "${report_book[@]}"
        do
                [[ "$?" == "0" ]] && for platform in "${platforms[@]}"
                do
                        [[ "$?" == "0" ]] && pentaho ${report} ${platform}
                done
        done

        [[ "$?" == "0" ]] && return 0 || return 1

        }


	
	## STEP 3 
	[[ "$?" == '0' ]] && launch_processes
	
	## STEP 4 
#	[[ "$?" == '0' ]] && sliceNdice_eom 

