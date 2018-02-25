#!/bin/bash

##
#
# sliceNdice_EOM
# RUN TIME 112 min
##

path_pan="/home/ec2-user/data-integration/pan.sh "
path_ktr="/home/ec2-user/data-integration/epiphany_ktr/" 

# FUNCTION TO process marketpublic_eom
sliceNdice_eom(){

	eom_startdate="$(date -d "-1 month" +%Y-%m-01)"
	#eom_startdate=$(date -d "$(date +%Y-%m) -15 last month" '+%Y-%m-01')
	eom_lastdate="$(date -d "-$(date +%d) days +0  month" +%Y-%m-%d)"

	cdate_startdate="$(date -d "-1 month" +%Y-%m-01)"
	#cdate_startdate=$(date -d "$(date +%Y-%m) -15 last month" '+%Y-%m-01')
	cdate_lastdate="$(date -d "-$(date +%d) days +0  month" +%Y-%m-%d)"
	
	until [[ "$eom_startdate" > "$eom_lastdate" ]]
	do
		${path_pan}-file="${path_ktr}sliceNdice_EOM.ktr" -param:PROCESS_DATE="${eom_startdate}" -param:CDATE="${cdate_startdate}"

		eom_startdate=$(date +"%Y-%m-%d" -d "$eom_startdate + 1 day")
		cdate_startdate=$(date +"%Y-%m-%d" -d "$cdate_startdate + 1 day")
	done
	}



# function call
sliceNdice_eom
