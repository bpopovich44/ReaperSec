#!/bin/bash

##
#
# REPORT-GENERATOR-----EOM
#
##

startdate=$(date -d "-1 month" +%Y-%m-01)
enddate=$(date -d "-$(date +%d) days +0 month" +%Y-%m-%d)
pubID=2


send_report() 
{

	KEY=$(mysql -N -h epiphany-load.cayagee0hssn.us-west-2.rds.amazonaws.com -P 3306 -e "SELECT id, email FROM epiphany_db.publishers")
 	echo $KEY

	# TRIGGER TO SEND MAIL 
	while read -r id email; do

		checkRev=$(mysql -N -h epiphany-load.cayagee0hssn.us-west-2.rds.amazonaws.com -P 3306 -e "SELECT SUM(adRevenue) FROM epiphany_db.EOM_Aggregate a LEFT JOIN
			epiphany_db.inventorySources i ON a.invSourceID = i.id WHERE a.date BETWEEN '${startdate}' AND '${enddate}' AND i.publisherID = '${id}'")

		if [[ $checkRev = 'NULL' ]]; then checkRev="0.0"; fi
		
		if (( $(bc <<< "$checkRev > 0") )); then		
			/home/ec2-user/data-integration/kitchen.sh \
			-file='/home/ec2-user/data-integration/epiphany_kjb/ReportEOM-EMAILER.kjb' -param:P_ID="${id}" -param:EMAIL="${email}" -param:STARTDATE="${startdate}" -param:ENDDATE="${enddate}"

			printf "\r\n $id, $email" >> /home/ec2-user/data-integration/epiphany_reports_xls/publisher_total.txt
		fi
	shift
	done < <(echo "$KEY")

}


> /home/ec2-user/data-integration/epiphany_reports_xls/publisher_total.xls

## function call 
send_report

#/home/ec2-user/data-integration/kitchen.sh -file='/home/ec2-user/data-integration/epiphany_kjb/ReportPublisherTotal-EMAILER.kjb'

> /home/ec2-user/data-integration/epiphany_reports_xls/publisher_total.txt

