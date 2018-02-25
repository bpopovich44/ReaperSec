#!/bin/bash

##
#
# REPORT-GENERATOR-----MGMT
#
##

path_kitchen="/home/ec2-user/data-integration/kitchen.sh "
path_kjb="/home/ec2-user/data-integration/epiphany_kjb/"
path_python="/usr/local/sbin/"


# FUNCTION TO SEND MGNT REPORT

launch_scripts(){

	reportSiteAdditions.py
	}



send_mail(){


	# SEND EMAIL 
	${path_kitchen}-file="${path_kjb}Site_addition-EMAILER.kjb"

}


## function call 

launch_scripts
send_mail



