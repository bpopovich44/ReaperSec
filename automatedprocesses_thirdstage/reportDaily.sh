#!/bin/bash -e

##
#
# REPORT-GENERATOR-----SCHEDULER Daily 
#
##

path_kjb="/home/ec2-user/data-integration/epiphany_kjb/"
path_kitchen="/home/ec2-user/data-integration/kitchen.sh " 
path_reports_xls="/home/ec2-user/data-integration/epiphany_reports_xls/"
mysql_db="mysql --defaults-group-suffix=epiphanydb -N -e "

# PARAMETERS FOR MAIL
INTERNAL_EMAIL="bill@epiphanyai.com"
INTERNAL_EMAIL_CC=""
EMAIL_BCC="data@epiphanyai.com"
TODAY="$(date "+%Y-%m-%d")"
CHECKDATE=$(date "+%d")
BANNER_DATE=$(date "+%A %B %d, %Y")
CURRENT_MONTH_START="$(date -d "$TODAY" '+%Y-%m-01')"
CURRENT_MONTH_END="$(date "+%Y-%m-%d" -d yesterday)"
LAST_MONTH_START="$(date -d "$CURRENT_MONTH_START -1 month" '+%Y-%m-%d')"
LAST_MONTH_END="$(date -d "$LAST_MONTH_START +1 month -1 day" '+%Y-%m-%d')"
SUBJECT="Epiphany Daily report for ${BANNER_DATE} Attached"


if [[ ${CHECKDATE} -eq "01" ]]
then
	REPORT_START=${LAST_MONTH_START}
	REPORT_END=${LAST_MONTH_END}
else
	REPORT_START=${CURRENT_MONTH_START}
	REPORT_END=${CURRENT_MONTH_END}
fi



COMMENT=$(cat <<- EOF
	Please find attached your dail report.


	





	--dataTeam



	**Daily reports are not final numbers.  EOM'S are sent by the 5th of the following month.**
	EOF
	)



create_clipboard(){

	# Creates new files at beginning of execution 
	> ${path_reports_xls}publisher_total.xls
	[[ "$?" == "0" ]] && > ${path_reports_xls}publisher_total.txt

	[[ "$?" == "0" ]] && return 0 || return 1
	}


send_publisher_report(){

	
	EMAIL_PUB_REPORT="eric@epiphanyai.com, bill@epiphanyai.com"
	EMAIL_PUB_REPORT_CC="data@epiphanyai.com"
	SUBJECT_PUB_REPORT="List of Publishers who received reports for ${YESTERDAY} attached"


	COMMENT_PUB_REPORT=$(cat <<- EOF
		Attached list of publishers who received daily reports.



		--dataTeam

		EOF
		)	

	${path_kitchen}-file="${path_kjb}ReportPublisherTotal-EMAILER.kjb" -param:EMAIL_PUB_REPORT="${EMAIL_PUB_REPORT}" -param:EMAIL_PUB_REPORT_CC="${EMAIL_PUB_REPORT_CC}" \
	-param:SUBJECT_PUB_REPORT="${SUBJECT_PUB_REPORT}" -param:COMMENT_PUB_REPORT="${COMMENT_PUB_REPORT}"

	}


# FUNCTION TO SEND DOMAIN REPORT
send_report(){

	KEY=$(${mysql_db}"SELECT id, email FROM publishers")
		
	 		
	# TRIGGER TO SEND MAIL 
	while read -r id pub_email
	do
			
		# REACH OUT TO SEE IF adRevenue > 0, if so will send report
		checkRev=$(${mysql_db}"SELECT SUM(adRevenue) FROM test_Aggregate a LEFT JOIN inventorySources i ON a.invSourceID = i.id WHERE a.date \
		BETWEEN "\'${REPORT_START}\'" AND "\'${REPORT_END}\'" AND i.publisherID = '${id}'")
	
		#check, if checkRev = NULL, assign to 0.00 for float
		[[ "$checkRev" == "NULL" ]] && checkRev="0.000"
		
		# SEND KEY through kitchen command line if revenue > 0 
		if (( $(bc <<< "$checkRev>0.001") > 0 ))
		then

	#		echo $id $pub_email $checkRev $CURRENT_MONTH_START $YESTERDAY
			# Monthly report
			${path_kitchen}-file="${path_kjb}reportDaily--EMAILER.kjb" -param:P_ID=${id} -param:EMAIL="${pub_email}" -param:EMAIL_CC="${INTERNAL_EMAIL_CC}" \
			-param:EMAIL_BCC="${INTERNAL_EMAIL_BCC}" -param:SUBJECT="${SUBJECT}" -param:COMMENT="${COMMENT}" -param:START_DATE="${REPORT_START}" \
			-param:END_DATE="${REPORT_END}"

			printf "\r\n $id, $pub_email" >> ${path_reports_xls}publisher_total.txt
		fi
#	shift
	done < <(echo "$KEY")
}


get_process_date
send_daily_report(){

	# STEP 1 Creates new files
	create_clipboard

	# STEP 2 Send reports for yesterday revenue for any pub who has made money in the current month
	[[ "$?" == "0" ]] && send_report || return 1

	# STEP 3 Send todays publisher report to epiphany employee
	[[ "$?" == "0" ]] && send_publisher_report || return 1

	}


# Execute script and error handling of script
#send_daily_report
#2>&1 | tee -a ${path_daily_log}

# SAVE TO USE WHEN PASS TO TWO LOGS
#run_daily_report > >(tee -a ${path_daily_log}) 2> >(tee -a ${path_error_log} >&2)

[[ "${PIPESTATUS[0]}" == "0" ]] && exit 0 || { printf "\n${TIMESTAMP} Exit code 1.  Look at daily_process.log for more information" >> ${path_error_log}; exit 1; }
