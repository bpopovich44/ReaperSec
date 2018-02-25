#!/bin/bash

##
#
#  runs all ADSYM domain level processes
#
##

path_sbin="/usr/local/sbin/"
reapdate=$(date +%Y-%m-%d -d yesterday)
reapdateFormat=$(date +%m/%d/%Y -d yesterday)
path_pan="/home/ec2-user/data-integration/pan.sh "
path_ktr="/home/ec2-user/data-integration/epiphany_ktr/"
mysql_db="mysql --defaults-group-suffix=domainlevel -N -e "
#mysql_db="mysql -N -h epiphany-load.cayagee0hssn.us-west-2.rds.amazonaws.com -P 3306 -e "
send_email="/home/ec2-user/data-integration/kitchen.sh -file='/home/ec2-user/data-integration/epiphany_kjb/dc_InventorySources_v2_Error.kjb'"


dc_knuckled_a(){

        local dc_counta=

        ${path_sbin}dc_InventorySources_v2_AA.py
        local dc=$(${mysql_db}"SELECT NULL FROM dc_InventorySources_v2 WHERE DATE = "\'${reapdateFormat}\'"LIMIT 1")

        if [[ -z $dc ]]
	then
       		while [[ -z $dc ]] && [[ $dc_counta -lt 3 ]]
        	do
			echo in loop_AA
                	${path_sbin}dc_InventorySources_v2_AA.py
                	local dc=$(${mysql_db}"SELECT NULL FROM dc_InventorySources_v2 WHERE DATE = "\'${reapdateFormat}\'"LIMIT 1")
                	local dc_counta=$(($dc_counta + 1))

        	done
        fi

        [[ $dc == 'NULL' ]] && return 0 || eval $sendemail

        }


dc_knuckled_b(){

        local dc_countb=

        ${path_sbin}dc_InventorySources_v2_BB.py
        local dc=$(${mysql_db}"SELECT NULL FROM dc_InventorySources_v2 WHERE DATE = "\'${reapdateFormat}\'"LIMIT 1")

        if [[ -z $dc ]]
	then
        	while [[ -z $dc ]] && [[ $dc_countb -lt 3 ]]
        	do
			echo in loop_BB
                	${path_sbin}dc_InventorySources_v2_BB.py
                	local dc=$(${mysql_db}"SELECT NULL FROM dc_InventorySources_v2 WHERE DATE = "\'${reapdateFormat}\'"LIMIT 1")
                	local dc_countb=$(($dc_countb + 1))

        	done
        fi

        [[ $dc == 'NULL' ]] && return 0 || eval $sendemail

        }


dc_knuckled_c(){

        local dc_countc=

        ${path_sbin}dc_InventorySources_v2_CC.py
        local dc=$(${mysql_db}"SELECT NULL FROM dc_InventorySources_v2 WHERE DATE = "\'${reapdateFormat}\'"LIMIT 1")

        if [[ -z $dc ]]
	then
        	while [[ -z $dc ]] && [[ $dc_countc -lt 3 ]]
        	do
			echo in_loop_CC
                	${path_sbin}dc_InventorySources_v2_CC.py
                	local dc=$(${mysql_db}"SELECT NULL FROM dc_InventorySources_v2 WHERE DATE = "\'${reapdateFormat}\'"LIMIT 1")
                	local dc_countc=$(($dc_countc + 1))

        	done
        fi

        [[ $dc == 'NULL' ]] && return 0 || eval $sendemail

        }


dc_knuckled_d(){

        local dc_countd=

        ${path_sbin}dc_InventorySources_v2_DD.py
        local dc=$(${mysql_db}"SELECT NULL FROM dc_InventorySources_v2 WHERE DATE = "\'${reapdateFormat}\'"LIMIT 1")

        if [[ -z $dc ]]
	then
        	while [[ -z $dc ]] && [[ $dc_countd -lt 3 ]]
        	do
			echo in_loop_DD
                	${path_sbin}dc_InventorySources_v2_DD.py
                	local dc=$(${mysql_db}"SELECT NULL FROM dc_InventorySources_v2 WHERE DATE = "\'${reapdateFormat}\'"LIMIT 1")
			local dc_countd=$(($dc_countd + 1))

        	done
        fi

        [[ $dc == 'NULL' ]] && return 0 || eval $sendemail

        }


dc_knuckled_e(){

        local dc_counte=

        ${path_sbin}dc_InventorySources_v2_EE.py
        local dc=$(${mysql_db}"SELECT NULL FROM dc_InventorySources_v2 WHERE DATE = "\'${reapdateFormat}\'"LIMIT 1")

        if [[ -z $dc ]]
	then
        	while [[ -z $dc ]] && [[ $dc_counte -lt 3 ]]
        	do
			echo in_loop_EE
                	${path_sbin}dc_InventorySources_v2_EE.py
                	local dc=$(${mysql_db}"SELECT NULL FROM dc_InventorySources_v2 WHERE DATE = "\'${reapdateFormat}\'"LIMIT 1")
                	local dc_counte=$(($dc_counte + 1))

        	done
        fi

        [[ $dc == 'NULL' ]] && return 0 || eval $sendemail

        }


dc_knuckled_f(){

        local dc_countf=

        ${path_sbin}dc_InventorySources_v2_FF.py
        local dc=$(${mysql_db}"SELECT NULL FROM dc_InventorySources_v2 WHERE DATE = "\'${reapdateFormat}\'"LIMIT 1")

        if [[ -z $dc ]]
	then
        	while [[ -z $dc ]] && [[ $dc_countf -lt 3 ]]
        	do
			echo in_loop_FF
                	${path_sbin}dc_InventorySources_v2_FF.py
                	local dc=$(${mysql_db}"SELECT NULL FROM dc_InventorySources_v2 WHERE DATE = "\'${reapdateFormat}\'"LIMIT 1")
                	local dc_countf=$(($dc_countf + 1))

        	done
        fi

        [[ $dc == 'NULL' ]] && return 0 || eval $sendemail

        }


run_dc_InventorySources_v2(){
	dc_knuckled_a 
        dc_knuckled_b 
        dc_knuckled_c 
        dc_knuckled_d 
        dc_knuckled_e 
        dc_knuckled_f
        }


run_dc_domain(){
	dc_count=
        dcrownum_start=1
        dcrownum_end=299999
	
	# Run inventorySource level dc & grab pid
#	run_dc_InventorySources_v2 &
#	dc_v2_pid=$!

	# Run domain level dc
	${path_sbin}dc_domainreport_v2.py
	dc=$(${mysql_db}"SELECT NULL FROM dc_domainreport_v2 WHERE DATE = "\'${reapdateFormat}\'"LIMIT 1")
	
	if [[ -z $dc ]]
	then

		while [[ -z $dc ]] && [[ $dc_count -lt 3 ]];
		do
			${path_sbin}dc_domainreport_v2.py
			dc=$(${mysql_db}"SELECT NULL FROM dc_domainreport_v2 WHERE DATE = "\'${reapdateFormat}\'"LIMIT 1")
			dc_count=$(($dc_count + 1))
		done
		

		# If domain level execute then run pentaho automation
		[[ -n $dc ]] && ${path_pan}-file="${path_ktr}dc_domainreport_v2.ktr" || return 1
		
		# Wait for run_dc funtion to complete before continuing 
		run_dc_InventorySources_v2
#		wait "$dc_v2_pid"
		
		dc_invsources_v2_count=$(${mysql_db} "SELECT COUNT(*) FROM dc_InventorySources_v2 WHERE DATE ="\'${reapdateFormat}\'"")
		
		# Continuous for loop will increment counter until reach one rotation after dc_inventorces_v2_count
		for (( ; ; ))
		do
			[[ $dcrownum_start -eq 1 ]] && dcrownum_start=0
			${path_pan}-file="${path_ktr}dc_inventorysources_v2.ktr" -param:ROWNUM_START="${dcrownum_start}" -param:ROWNUM_END="${dcrownum_end}"
		
			[[ "$dcrownum_end" -ge "$dc_invsources_v2_count" ]] && break
			
			dcrownum_start=$(($dcrownum_start + 300000));
			dcrownum_end=$(($dcrownum_end + 300000));
	       	done
	
		return 0
	
	else
		# If domain level execute then run pentaho automation
		[[ -n $dc ]] && ${path_pan}-file="${path_ktr}dc_domainreport_v2.ktr" || return 1
		
		# Wait for run_dc funtion to complete before continuing 
		run_dc_InventorySources_v2 
#		wait "$dc_v2_pid"

		
		dc_invsources_v2_count=$(${mysql_db} "SELECT COUNT(*) FROM dc_InventorySources_v2 WHERE DATE ="\'${reapdateFormat}\'"")
		
		# Continuous for loop will increment counter until reach one rotation after dc_inventorces_v2_count
		for (( ; ; ))
		do
			[[ $dcrownum_start -eq 1 ]] && dcrownum_start=0
			${path_pan}-file="${path_ktr}dc_inventorysources_v2.ktr" -param:ROWNUM_START="${dcrownum_start}" -param:ROWNUM_END="${dcrownum_end}"
		
			[[ "$dcrownum_end" -ge "$dc_invsources_v2_count" ]] && break
			
			dcrownum_start=$(($dcrownum_start + 300000));
			dcrownum_end=$(($dcrownum_end + 300000));
	       	done
	fi

	return 0
}
		

# Beginning function executes script
run_dc_domain
