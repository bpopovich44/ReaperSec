#!/bin/bash

##
#
# REPORT-GENERATOR-----MGMT
#
##

path_kitchen="/home/ec2-user/data-integration/kitchen.sh "
path_kjb="/home/ec2-user/data-integration/epiphany_kjb/"

# FUNCTION TO SEND MGNT REPORT
send_mail(){


	# SEND EMAIL 
	#${path_kitchen}-file="${path_kjb}ReportMGMT-EMAILER.kjb"
	#${path_kitchen}-file="${path_kjb}ReportMGMT--6_FL-REPORT-EMAILER.kjb"
	${path_kitchen}-file="${path_kjb}ReportMGMT--6_REPORT-EMAILER.kjb"
	#${path_kitchen}-file="${path_kjb}ReportMGMT--6_MESSAGE-REPORT-EMAILER.kjb"
	#${path_kitchen}-file="${path_kjb}ReportMGMT--6_TO_BILL_REPORT-EMAILER.kjb"



}


## function call 
send_mail



