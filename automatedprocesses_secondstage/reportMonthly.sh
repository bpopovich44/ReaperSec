#!/bin/bash

##
#
# REPORT-GENERATOR-----SCHEDULER Monthly 
#
##


reapdate=$(date +%Y-%m-%d -d yesterday)
path_kjb="/home/ec2-user/data-integration/epiphany_kjb/"
path_kitchen="/home/ec2-user/data-integration/kitchen.sh " 
path_reports_xls="/home/ec2-user/data-integration/epiphany_reports_xls/"
mysql_db="mysql --defaults-group-suffix=epiphanydb -N -e "


# FUNCTION TO SEND DOMAIN REPORT
send_report(){

	KEY=$(${mysql_db}"SELECT id, email FROM publishers")
	 		
	# TRIGGER TO SEND MAIL 
	while read -r id email
	do
			
		# REACH OUT TO SEE IF adRevenue > 0, if so will send report
		checkRev=$(${mysql_db}"SELECT SUM(adRevenue) FROM test_Aggregate a LEFT JOIN inventorySources i ON a.invSourceID = i.id WHERE a.date='${reapdate}' AND i.publisherID = '${id}'")

		#check, if checkRev = NULL, assign to 0.00 for float
		if [[ $checkRev = 'NULL' ]]; then checkRev="0.00"; fi
		
		# SEND KEY through kitchen command line if revenue > 0 
		if (( $(bc <<< "$checkRev > 0") ))
		then
			
			# Monthly report
			${path_kitchen}-file="${path_kjb}ReportMonthly-EMAILER.kjb" -param:P_ID=${id} -param:PUB_EMAIL="${email}" -param:YESTER=${reapdate}
			
			# Monthly report with first and last date hard-coded	
			#${path_kitchen}-file="${path_kjb}ReportMonthlyFIRSTANDLAST-EMAILER.kjb" -param:P_ID=${id} -param:PUB_EMAIL="${email}" -param:YESTER=${reapdate}
			
			# Monthly report
			#${path_kitchen}-file="${path_kjb}ReportMonthly_TO_BILL-EMAILER.kjb" -param:P_ID=${id} -param:PUB_EMAIL="${email}" -param:YESTER=${reapdate}


			printf "\r\n $id, $email" >> ${path_reports_xls}publisher_total.txt
		fi
	shift
	done < <(echo "$KEY")
}


# creates new file.xls  and function call 
> ${path_reports_xls}publisher_total.xls
send_report

# sends email and creates new file.txt
${path_kitchen}-file="${path_kjb}ReportPublisherTotal-EMAILER.kjb"
> ${path_reports_xls}publisher_total.txt




