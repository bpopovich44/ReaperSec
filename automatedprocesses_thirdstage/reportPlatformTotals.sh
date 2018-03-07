#!/bin/bash -e

##
#
# REPORT-GENERATOR-----MGMT
#
##

path_kitchen="/home/ec2-user/data-integration/kitchen.sh "
path_kjb="/home/ec2-user/data-integration/epiphany_kjb/"

# PARAMETERS FOR MAIL
#EMAIL="bill@epiphanyai.com"
#EMAIL_CC="bill@epiphanyai.com"



EMAIL="joe@epiphanyai.com, brian@epiphanyai.com"
EMAIL_CC="bill@epiphanyai.com, aaron@epiphanyai.com, mark@epiphanyai.com, eric@epiphanyai.com"
EMAIL_BCC=""
CHECKDATE=$(date "+%d")
TODAY="$(date "+%Y-%m-%d" )"
BANNER_DATE=$(date "+%A %B %d, %Y")
CURRENT_MONTH_START="$(date -d "$TODAY" '+%Y-%m-01')"
CURRENT_MONTH_END="$(date "+%Y-%m-%d" -d yesterday )"
LAST_MONTH_START="$(date -d "$CURRENT_MONTH_START -1 month" '+%Y-%m-%d')"
LAST_MONTH_END="$(date -d "$LAST_MONTH_START +1 month -1 day" '+%Y-%m-%d')"

if [[ ${CHECKDATE} -eq "01" ]]
then
	REPORT_START=${LAST_MONTH_START}
	REPORT_END=${LAST_MONTH_END}
else
	REPORT_START=${CURRENT_MONTH_START}
	REPORT_END=${CURRENT_MONTH_END}
fi


SUBJECT="Epiphany Management Daily Report for "${BANNER_DATE}""
COMMENT=$(cat <<- EOF
	Team,

	Please find attached your daily report.




	--data Team	


	EOF
	)


# FUNCTION TO SEND MGNT REPORT
send_mail(){

	# SEND EMAIL 
	${path_kitchen}-file="${path_kjb}report_platformTotals--EMAILER.kjb" -param:EMAIL="${EMAIL}" -param:EMAIL_CC="${EMAIL_CC}" \
	-param:EMAIL_BCC="${EMAIL_BCC}" -param:SUBJECT="${SUBJECT}" -param:COMMENT="${COMMENT}" -param:START_DATE="${CURRENT_MONTH_START}" -param:END_DATE="${CURRENT_MONTH_END}"

	}


## function call 
send_mail 2>&1 | tee -a ${path_daily_log}

[[ "${PIPESTATUS[0]}" == "0" ]] && exit 0 || { printf "\n${TIMESTAMP} Exit code 1.  Look at dail_process.log for more information" >> ${path_error_log}; exit 1; }
