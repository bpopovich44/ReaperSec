#!/bin/bash

##
#
#  runs all TM domain level processes
#
##

path_sbin="/usr/local/sbin/"
reapdate=$(date +%Y-%m-%d -d yesterday)
reapdateFormat=$(date +%m/%d/%Y -d yesterday)
path_pan="/home/ec2-user/data-integration/pan.sh "
path_ktr="/home/ec2-user/data-integration/epiphany_ktr/"
mysql_db="mysql --defaults-group-suffix=domainlevel -N -e "
#mysql_db="mysql -N -h epiphany-load.cayagee0hssn.us-west-2.rds.amazonaws.com -P 3306 -e "
send_email="/home/ec2-user/data-integration/kitchen.sh -file='/home/ec2-user/data-integration/epiphany_kjb/tm_InventorySources_v2_Error.kjb'"


tm_knuckled_a(){

        local tm_counta=

        ${path_sbin}tm_InventorySources_v2_AA.py
        local tm=$(${mysql_db}"SELECT NULL FROM tm_InventorySources_v2 WHERE DATE = "\'${reapdateFormat}\'"LIMIT 1")

        if [[ -z $tm ]]
	then
		while [[ -z $tm ]] && [[ $tm_counta -lt 3 ]]
        	do
			echo inloop_tm_AA
                	${path_sbin}tm_InventorySources_v2_AA.py
                	local tm=$(${mysql_db}"SELECT NULL FROM tm_InventorySources_v2 WHERE DATE = "\'${reapdateFormat}\'"LIMIT 1")
                	local tm_counta=$(($tm_counta + 1))

        	done
        fi

        [[ $tm == 'NULL' ]] && return 0 || eval $sendemail

        }


tm_knuckled_b(){

        local tm_countb=

        ${path_sbin}tm_InventorySources_v2_BB.py
        local tm=$(${mysql_db}"SELECT NULL FROM tm_InventorySources_v2 WHERE DATE = "\'${reapdateFormat}\'"LIMIT 1")

        if [[ -z $tm ]]
	then
		while [[ -z $tm ]] && [[ $tm_countb -lt 3 ]]
        	do
			echo inloop_tm_BB
                	${path_sbin}tm_InventorySources_v2_BB.py
                	local tm=$(${mysql_db}"SELECT NULL FROM tm_InventorySources_v2 WHERE DATE = "\'${reapdateFormat}\'"LIMIT 1")
                	local tm_countb=$(($tm_countb + 1))

        	done
        fi

        [[ $tm == 'NULL' ]] && return 0 || eval $sendemail

        }


tm_knuckled_c(){

        local tm_countc=

        ${path_sbin}tm_InventorySources_v2_CC.py
        local tm=$(${mysql_db}"SELECT NULL FROM tm_InventorySources_v2 WHERE DATE = "\'${reapdateFormat}\'"LIMIT 1")

        if [[ -z $tm ]]
	then
		while [[ -z $tm ]] && [[ $tm_countc -lt 3 ]]
        	do
			echo inloop_tm_CC
                	${path_sbin}tm_InventorySources_v2_CC.py
                	local tm=$(${mysql_db}"SELECT NULL FROM tm_InventorySources_v2 WHERE DATE = "\'${reapdateFormat}\'"LIMIT 1")
                	local tm_countc=$(($tm_countc + 1))

        	done
        fi

        [[ $tm == 'NULL' ]] && return 0 || eval $sendemail

        }


tm_knuckled_d(){

        local tm_countd=

        ${path_sbin}tm_InventorySources_v2_DD.py
        local tm=$(${mysql_db}"SELECT NULL FROM tm_InventorySources_v2 WHERE DATE = "\'${reapdateFormat}\'"LIMIT 1")

        if [[ -z $tm ]]
	then
		while [[ -z $tm ]] && [[ $tm_countd -lt 3 ]]
        	do
			echo inloop_tm_DD
                	${path_sbin}tm_InventorySources_v2_DD.py
                	local tm=$(${mysql_db}"SELECT NULL FROM tm_InventorySources_v2 WHERE DATE = "\'${reapdateFormat}\'"LIMIT 1")
			local tm_countd=$(($tm_countd + 1))

        	done
        fi

        [[ $tm == 'NULL' ]] && return 0 || eval $sendemail

        }


tm_knuckled_e(){

        local tm_counte=

        ${path_sbin}tm_InventorySources_v2_EE.py
        local tm=$(${mysql_db}"SELECT NULL FROM tm_InventorySources_v2 WHERE DATE = "\'${reapdateFormat}\'"LIMIT 1")

        if [[ -z $tm ]]
	then
		while [[ -z $tm ]] && [[ $tm_counte -lt 3 ]]
        	do
			echo inloop_tm_EE
                	${path_sbin}tm_InventorySources_v2_EE.py
                	local tm=$(${mysql_db}"SELECT NULL FROM tm_InventorySources_v2 WHERE DATE = "\'${reapdateFormat}\'"LIMIT 1")
                	local tm_counte=$(($tm_counte + 1))

        	done
        fi

        [[ $tm == 'NULL' ]] && return 0 || eval $sendemail

        }


tm_knuckled_f(){

        local tm_countf=

        ${path_sbin}tm_InventorySources_v2_FF.py
        local tm=$(${mysql_db}"SELECT NULL FROM tm_InventorySources_v2 WHERE DATE = "\'${reapdateFormat}\'"LIMIT 1")

        if [[ -z $tm ]]
	then
		while [[ -z $tm ]] && [[ $tm_countf -lt 3 ]]
        	do
			echo inloop_tm_FF
                	${path_sbin}tm_InventorySources_v2_FF.py
                	local tm=$(${mysql_db}"SELECT NULL FROM tm_InventorySources_v2 WHERE DATE = "\'${reapdateFormat}\'"LIMIT 1")
                	local tm_countf=$(($tm_countf + 1))

        	done
        fi

        [[ $tm == 'NULL' ]] && return 0 || eval $sendemail

        }


run_tm_InventorySources_v2(){
        echo tm_knuckled_a && tm_knuckled_a 
        echo tm_knuckled_b && tm_knuckled_b 
        echo tm_knuckled_c && tm_knuckled_c 
        echo tm_knuckled_d && tm_knuckled_d 
        echo tm_knuckled_e && tm_knuckled_e 
        echo tm_knuckled_f && tm_knuckled_f 
        }


run_tm_domain(){
	tm_count=
        tmrownum_start=1
        tmrownum_end=299999
	
	# Run inventorySource level tm & grab pid
#	run_tm_InventorySources_v2 &
#	tm_v2_pid=$!

	# Run domain level tm
	${path_sbin}tm_domainreport_v2.py
	tm=$(${mysql_db}"SELECT NULL FROM tm_domainreport_v2 WHERE DATE = "\'${reapdateFormat}\'"LIMIT 1")
	
	if [[ -z $tm ]]
	then

		while [[ -z $tm ]] && [[ $tm_count -lt 3 ]];
		do
			${path_sbin}tm_domainreport_v2.py
			tm=$(${mysql_db}"SELECT NULL FROM tm_domainreport_v2 WHERE DATE = "\'${reapdateFormat}\'"LIMIT 1")
			tm_count=$((tm_count + 1))
		done
		

		# If domain level execute then run pentaho automation
		[[ -n $tm ]] && ${path_pan}-file="${path_ktr}tm_domainreport_v2.ktr" || return 1
		
		# Wait for run_tm funtion to complete before continuing 
		run_tm_InventorySources_v2
#		wait "$tm_v2_pid"
		
		tm_invsources_v2_count=$(${mysql_db} "SELECT COUNT(*) FROM tm_InventorySources_v2 WHERE DATE ="\'${reapdateFormat}\'"")
		
		# Continuous for loop will increment counter until reach one rotation after tm_inventorces_v2_count
		for (( ; ; ))
		do
			[[ $tmrownum_start -eq 1 ]] && tmrownum_start=0
			${path_pan}-file="${path_ktr}tm_inventorysources_v2.ktr" -param:ROWNUM_START="${tmrownum_start}" -param:ROWNUM_END="${tmrownum_end}"
		
			[[ "$tmrownum_end" -ge "$tm_invsources_v2_count" ]] && break
			
			tmrownum_start=$(($tmrownum_start + 300000));
			tmrownum_end=$(($tmrownum_end + 300000));
	       	done
	
		return 0
	
	else
		# If domain level execute then run pentaho automation
		[[ -n $tm ]] && ${path_pan}-file="${path_ktr}tm_domainreport_v2.ktr" || return 1
		
		# Wait for run_tm funtion to complete before continuing 
		run_tm_InventorySources_v2
#		wait "$tm_v2_pid"

		
		tm_invsources_v2_count=$(${mysql_db} "SELECT COUNT(*) FROM tm_InventorySources_v2 WHERE DATE ="\'${reapdateFormat}\'"")
		
		# Continuous for loop will increment counter until reach one rotation after tm_inventorces_v2_count
		for (( ; ; ))
		do
			[[ $tmrownum_start -eq 1 ]] && tmrownum_start=0
			${path_pan}-file="${path_ktr}tm_inventorysources_v2.ktr" -param:ROWNUM_START="${tmrownum_start}" -param:ROWNUM_END="${tmrownum_end}"
		
			[[ "$tmrownum_end" -ge "$tm_invsources_v2_count" ]] && break
			
			tmrownum_start=$(($tmrownum_start + 300000));
			tmrownum_end=$(($tmrownum_end + 300000));
	       	done
	fi

	return 0
}
		

# Beginning function executes script
run_tm_domain
