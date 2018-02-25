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
send_email="/home/ec2-user/data-integration/kitchen.sh -file='/home/ec2-user/data-integration/epiphany_kjb/adsym_InventorySources_v2_Error.kjb'"


adsym_knuckled_a(){

        local adsym_counta=

        ${path_sbin}adsym_InventorySources_v2_AA.py
        local adsym=$(${mysql_db}"SELECT NULL FROM adsym_InventorySources_v2 WHERE DATE = "\'${reapdateFormat}\'"LIMIT 1")

        if [[ -z $adsym ]]
	then
        
		while [[ -z $adsym ]] && [[ $adsym_counta -lt 3 ]]
        	do
                	${path_sbin}adsym_InventorySources_v2_AA.py
                	local adsym=$(${mysql_db}"SELECT NULL FROM adsym_InventorySources_v2 WHERE DATE = "\'${reapdateFormat}\'"LIMIT 1")
                	local adsym_counta=$(($adsym_counta + 1))

        	done
        fi

        [[ $adsym == 'NULL' ]] && return 0 || eval $sendemail

        }


adsym_knuckled_b(){

        local adsym_countb=

        ${path_sbin}adsym_InventorySources_v2_BB.py
        local adsym=$(${mysql_db}"SELECT NULL FROM adsym_InventorySources_v2 WHERE DATE = "\'${reapdateFormat}\'"LIMIT 1")

        if [[ -z $adsym ]]
	then
        
		while [[ -z $adsym ]] && [[ $adsym_countb -lt 3 ]]
        	do
                	${path_sbin}adsym_InventorySources_v2_BB.py
                	local adsym=$(${mysql_db}"SELECT NULL FROM adsym_InventorySources_v2 WHERE DATE = "\'${reapdateFormat}\'"LIMIT 1")
                	local adsym_countb=$(($adsym_countb + 1))

        	done
        fi

        [[ $adsym == 'NULL' ]] && return 0 || eval $sendemail

        }


adsym_knuckled_c(){

        local adsym_countc=

        ${path_sbin}adsym_InventorySources_v2_CC.py
        local adsym=$(${mysql_db}"SELECT NULL FROM adsym_InventorySources_v2 WHERE DATE = "\'${reapdateFormat}\'"LIMIT 1")

        if [[ -z $adsym ]]
	then
        
		while [[ -z $adsym ]] && [[ $adsym_countc -lt 3 ]]
        	do
                	${path_sbin}adsym_InventorySources_v2_CC.py
                	local adsym=$(${mysql_db}"SELECT NULL FROM adsym_InventorySources_v2 WHERE DATE = "\'${reapdateFormat}\'"LIMIT 1")
                	local adsym_countc=$(($adsym_countc + 1))

        	done
        fi

        [[ $adsym == 'NULL' ]] && return 0 || eval $sendemail

        }


adsym_knuckled_d(){

        local adsym_countd=

        ${path_sbin}adsym_InventorySources_v2_DD.py
        local adsym=$(${mysql_db}"SELECT NULL FROM adsym_InventorySources_v2 WHERE DATE = "\'${reapdateFormat}\'"LIMIT 1")

        if [[ -z $adsym ]]
	then
        
		while [[ -z $adsym ]] && [[ $adsym_countd -lt 3 ]]
        	do
                	${path_sbin}adsym_InventorySources_v2_DD.py
                	local adsym=$(${mysql_db}"SELECT NULL FROM adsym_InventorySources_v2 WHERE DATE = "\'${reapdateFormat}\'"LIMIT 1")
			local adsym_countd=$(($adsym_countd + 1))

        	done
        fi

        [[ $adsym == 'NULL' ]] && return 0 || eval $sendemail

        }


adsym_knuckled_e(){

        local adsym_counte=

        ${path_sbin}adsym_InventorySources_v2_EE.py
        local adsym=$(${mysql_db}"SELECT NULL FROM adsym_InventorySources_v2 WHERE DATE = "\'${reapdateFormat}\'"LIMIT 1")

        if [[ -z $adsym ]]
	then
        
		while [[ -z $adsym ]] && [[ $adsym_counte -lt 3 ]]
        	do
                	${path_sbin}adsym_InventorySources_v2_EE.py
                	local adsym=$(${mysql_db}"SELECT NULL FROM adsym_InventorySources_v2 WHERE DATE = "\'${reapdateFormat}\'"LIMIT 1")
                	local adsym_counte=$(($adsym_counte + 1))

        	done
        fi

        [[ $adsym == 'NULL' ]] && return 0 || eval $sendemail

        }


adsym_knuckled_f(){

        local adsym_countf=

        ${path_sbin}adsym_InventorySources_v2_FF.py
        local adsym=$(${mysql_db}"SELECT NULL FROM adsym_InventorySources_v2 WHERE DATE = "\'${reapdateFormat}\'"LIMIT 1")

        if [[ -z $adsym ]]
	then
        
		while [[ -z $adsym ]] && [[ $adsym_countf -lt 3 ]]
        	do
                	${path_sbin}adsym_InventorySources_v2_FF.py
                	local adsym=$(${mysql_db}"SELECT NULL FROM adsym_InventorySources_v2 WHERE DATE = "\'${reapdateFormat}\'"LIMIT 1")
                	local adsym_countf=$(($adsym_countf + 1))

        	done
        fi

        [[ $adsym == 'NULL' ]] && return 0 || eval $sendemail

        }


run_adsym_InventorySources_v2(){
        adsym_knuckled_a
        adsym_knuckled_b
        adsym_knuckled_c
        adsym_knuckled_d
        adsym_knuckled_e
        adsym_knuckled_f
        }


run_adsym_domain(){
	adsym_count=
        adsymrownum_start=1
        adsymrownum_end=299999
	
	# Run inventorySource level adsym & grab pid
#	run_adsym_InventorySources_v2 &
#	adsym_v2_pid=$!

	# Run domain level adsym
	${path_sbin}adsym_domainreport_v2.py
	adsym=$(${mysql_db}"SELECT NULL FROM adsym_domainreport_v2 WHERE DATE = "\'${reapdateFormat}\'"LIMIT 1")
	
	if [[ -z $adsym ]]
	then

		while [[ -z $adsym ]] && [[ $adsym_count -lt 3 ]];
		do
			${path_sbin}adsym_domainreport_v2.py
			adsym=$(${mysql_db}"SELECT NULL FROM adsym_domainreport_v2 WHERE DATE = "\'${reapdateFormat}\'"LIMIT 1")
			adsym_count=$((adsym_count + 1))
		done
		

		# If domain level execute then run pentaho automation
		[[ -n $adsym ]] && ${path_pan}-file="${path_ktr}adsym_domainreport_v2.ktr" || return 1
		
		# Wait for run_adsym funtion to complete before continuing 
		run_adsym_InventorySources_v2
#		wait "$adsym_v2_pid"
		
		adsym_invsources_v2_count=$(${mysql_db} "SELECT COUNT(*) FROM adsym_InventorySources_v2 WHERE DATE ="\'${reapdateFormat}\'"")
		
		# Continuous for loop will increment counter until reach one rotation after adsym_inventorces_v2_count
		for (( ; ; ))
		do
			[[ $adsymrownum_start -eq 1 ]] && adsymrownum_start=0
			${path_pan}-file="${path_ktr}adsym_inventorysources_v2.ktr" -param:ROWNUM_START="${adsymrownum_start}" -param:ROWNUM_END="${adsymrownum_end}"
		
			[[ "$adsymrownum_end" -ge "$adsym_invsources_v2_count" ]] && break
			
			adsymrownum_start=$(($adsymrownum_start + 300000));
			adsymrownum_end=$(($adsymrownum_end + 300000));
	       	done
	
		return 0
	
	else
		# If domain level execute then run pentaho automation
		[[ -n $adsym ]] && ${path_pan}-file="${path_ktr}adsym_domainreport_v2.ktr" || return 1
		
		# Wait for run_adsym funtion to complete before continuing 
		run_adsym_InventorySources_v2
#		wait "$adsym_v2_pid"

		
		adsym_invsources_v2_count=$(${mysql_db} "SELECT COUNT(*) FROM adsym_InventorySources_v2 WHERE DATE ="\'${reapdateFormat}\'"")
		
		# Continuous for loop will increment counter until reach one rotation after adsym_inventorces_v2_count
		for (( ; ; ))
		do
			[[ $adsymrownum_start -eq 1 ]] && adsymrownum_start=0
			${path_pan}-file="${path_ktr}adsym_inventorysources_v2.ktr" -param:ROWNUM_START="${adsymrownum_start}" -param:ROWNUM_END="${adsymrownum_end}"
		
			[[ "$adsymrownum_end" -ge "$adsym_invsources_v2_count" ]] && break
			
			adsymrownum_start=$(($adsymrownum_start + 300000));
			adsymrownum_end=$(($adsymrownum_end + 300000));
	       	done
	fi

	return 0
}
		

# Beginning function executes script
run_adsym_domain
