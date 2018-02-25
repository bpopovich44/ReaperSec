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
send_email="/home/ec2-user/data-integration/kitchen.sh -file='/home/ec2-user/data-integration/epiphany_kjb/springs_InventorySources_v2_Error.kjb'"


springs_knuckled_a(){

        local springs_counta=

 	${path_sbin}springserve_InventorySources_v2.py
        local springs=$(${mysql_db}"SELECT NULL FROM springserve_InventorySources_v2 WHERE DATE = "\'${reapdate}\'"LIMIT 1")

        if [[ -z $springs ]]
	then
        
		while [[ -z $springs ]] && [[ $springs_counta -lt 3 ]]
        	do
                	${path_sbin}springserve_InventorySources_v2.py
                	local springs=$(${mysql_db}"SELECT NULL FROM springserve_InventorySources_v2 WHERE DATE = "\'${reapdate}\'"LIMIT 1")
                	local springs_counta=$(($springs_counta + 1))

        	done
        fi

        [[ $springs == 'NULL' ]] && return 0 || eval $sendemail

        }



run_springs_InventorySources_v2(){
        springs_knuckled_a
        }


run_springs_domain(){
	springs_count=
        springsrownum_start=1
        springsrownum_end=299999
	
	# Run inventorySource level springs & grab pid
#	run_springs_InventorySources_v2 &
#	springs_v2_pid=$!

	# Run domain level springs
	/usr/local/sbin/springserve_domainreport_v2.py
	springs=$(${mysql_db}"SELECT NULL FROM epiphany_domainlevel.springserve_domainreport_v2 WHERE DATE = "\'${reapdate}\'"LIMIT 1")
	
	if [[ -z $springs ]]
	then

		while [[ -z $springs ]] && [[ $springs_count -lt 3 ]];
		do
			/usr/local/sbin/springserve_domainreport_v2.py
			springs=$(${mysql_db}"SELECT NULL FROM epiphany_domainlevel.springserve_domainreport_v2 WHERE DATE = "\'${reapdate}\'"LIMIT 1")
			springs_count=$((springs_count + 1))
		done
		

		# If domain level execute then run pentaho automation
		[[ -n $springs ]] && ${path_pan}-file="${path_ktr}springserve_domainreport_v2.ktr" || return 1
		
		# Wait for run_springs funtion to complete before continuing 
		run_springs_InventorySources_v2
#		wait "$springs_v2_pid"
		
		springs_invsources_v2_count=$(${mysql_db} "SELECT COUNT(*) FROM epiphany_domainlevel.springserve_InventorySources_v2 WHERE DATE ="\'${reapdate}\'"")
		
		# Continuous for loop will increment counter until reach one rotation after springs_inventorces_v2_count
		for (( ; ; ))
		do
			[[ $springsrownum_start -eq 1 ]] && springsrownum_start=0
			${path_pan}-file="${path_ktr}springserve_inventorysources_v2.ktr" -param:ROWNUM_START="${springsrownum_start}" -param:ROWNUM_END="${springsrownum_end}"
		
			[[ "$springsrownum_end" -ge "$springs_invsources_v2_count" ]] && break
			
			springsrownum_start=$(($springsrownum_start + 300000));
			springsrownum_end=$(($springsrownum_end + 300000));
	       	done
	
		return 0
	
	else
		# If domain level execute then run pentaho automation
		[[ -n $springs ]] && ${path_pan}-file="${path_ktr}springserve_domainreport_v2.ktr" || return 1
		
		# Wait for run_springs funtion to complete before continuing 
		run_springs_InventorySources_v2
#		wait "$springs_v2_pid"

		
		springs_invsources_v2_count=$(${mysql_db} "SELECT COUNT(*) FROM epiphany_domainlevel.springserve_InventorySources_v2 WHERE DATE ="\'${reapdate}\'"")
		
		# Continuous for loop will increment counter until reach one rotation after springs_inventorces_v2_count
		for (( ; ; ))
		do
			[[ $springsrownum_start -eq 1 ]] && springsrownum_start=0
			${path_pan}-file="${path_ktr}springserve_inventorysources_v2.ktr" -param:ROWNUM_START="${springsrownum_start}" -param:ROWNUM_END="${springsrownum_end}"
		
			[[ "$springsrownum_end" -ge "$springs_invsources_v2_count" ]] && break
			
			springsrownum_start=$(($springsrownum_start + 300000));
			springsrownum_end=$(($springsrownum_end + 300000));
	       	done
	fi

	return 0
}
		

# Beginning function executes script
run_springs_domain
