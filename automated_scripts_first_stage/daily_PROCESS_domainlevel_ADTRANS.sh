#!/bin/bash

##
#
#  runs all ADTRANS domain level processes
#
##

path_sbin="/usr/local/sbin/"
reapdate=$(date +%Y-%m-%d -d yesterday)
reapdateFormat=$(date +%m/%d/%Y -d yesterday)
path_pan="/home/ec2-user/data-integration/pan.sh "
path_ktr="/home/ec2-user/data-integration/epiphany_ktr/"
mysql_db="mysql --defaults-group-suffix=domainlevel -N -e "
#mysql_db="mysql -N -h epiphany-load.cayagee0hssn.us-west-2.rds.amazonaws.com -P 3306 -e "
send_email="/home/ec2-user/data-integration/kitchen.sh -file='/home/ec2-user/data-integration/epiphany_kjb/adtrans_InventorySources_v2_Error.kjb'"


adtrans_knuckled_a(){

        local adtrans_counta=

        ${path_sbin}adtrans_InventorySources_v2_AA.py
        local adtrans=$(${mysql_db}"SELECT NULL FROM adtrans_InventorySources_v2 WHERE DATE = "\'${reapdateFormat}\'"LIMIT 1")

        if [[ -z $adtrans ]]
	then
        
		while [[ -z $adtrans ]] && [[ $adtrans_counta -lt 3 ]]
        	do
                	${path_sbin}adtrans_InventorySources_v2_AA.py
                	local adtrans=$(${mysql_db}"SELECT NULL FROM adtrans_InventorySources_v2 WHERE DATE = "\'${reapdateFormat}\'"LIMIT 1")
                	local adtrans_counta=$(($adtrans_counta + 1))

        	done
        fi

        [[ $adtrans == 'NULL' ]] && return 0 || eval $sendemail

        }


adtrans_knuckled_b(){

        local adtrans_countb=

        ${path_sbin}adtrans_InventorySources_v2_BB.py
        local adtrans=$(${mysql_db}"SELECT NULL FROM adtrans_InventorySources_v2 WHERE DATE = "\'${reapdateFormat}\'"LIMIT 1")

        if [[ -z $adtrans ]]
	then
        
		while [[ -z $adtrans ]] && [[ $adtrans_countb -lt 3 ]]
        	do
                	${path_sbin}adtrans_InventorySources_v2_BB.py
                	local adtrans=$(${mysql_db}"SELECT NULL FROM adtrans_InventorySources_v2 WHERE DATE = "\'${reapdateFormat}\'"LIMIT 1")
                	local adtrans_countb=$(($adtrans_countb + 1))

        	done
        fi

        [[ $adtrans == 'NULL' ]] && return 0 || eval $sendemail

        }


adtrans_knuckled_c(){

        local adtrans_countc=

        ${path_sbin}adtrans_InventorySources_v2_CC.py
        local adtrans=$(${mysql_db}"SELECT NULL FROM adtrans_InventorySources_v2 WHERE DATE = "\'${reapdateFormat}\'"LIMIT 1")

        if [[ -z $adtrans ]]
	then
        
		while [[ -z $adtrans ]] && [[ $adtrans_countc -lt 3 ]]
        	do
                	${path_sbin}adtrans_InventorySources_v2_CC.py
                	local adtrans=$(${mysql_db}"SELECT NULL FROM adtrans_InventorySources_v2 WHERE DATE = "\'${reapdateFormat}\'"LIMIT 1")
                	local adtrans_countc=$(($adtrans_countc + 1))

        	done
        fi

        [[ $adtrans == 'NULL' ]] && return 0 || eval $sendemail

        }


adtrans_knuckled_d(){

        local adtrans_countd=

        ${path_sbin}adtrans_InventorySources_v2_DD.py
        local adtrans=$(${mysql_db}"SELECT NULL FROM adtrans_InventorySources_v2 WHERE DATE = "\'${reapdateFormat}\'"LIMIT 1")

        if [[ -z $adtrans ]]
	then
        
		while [[ -z $adtrans ]] && [[ $adtrans_countd -lt 3 ]]
        	do
                	${path_sbin}adtrans_InventorySources_v2_DD.py
                	local adtrans=$(${mysql_db}"SELECT NULL FROM adtrans_InventorySources_v2 WHERE DATE = "\'${reapdateFormat}\'"LIMIT 1")
			local adtrans_countd=$(($adtrans_countd + 1))

        	done
        fi

        [[ $adtrans == 'NULL' ]] && return 0 || eval $sendemail

        }


adtrans_knuckled_e(){

        local adtrans_counte=

        ${path_sbin}adtrans_InventorySources_v2_EE.py
        local adtrans=$(${mysql_db}"SELECT NULL FROM adtrans_InventorySources_v2 WHERE DATE = "\'${reapdateFormat}\'"LIMIT 1")

        if [[ -z $adtrans ]]
	then
        
		while [[ -z $adtrans ]] && [[ $adtrans_counte -lt 3 ]]
        	do
                	${path_sbin}adtrans_InventorySources_v2_EE.py
                	local adtrans=$(${mysql_db}"SELECT NULL FROM adtrans_InventorySources_v2 WHERE DATE = "\'${reapdateFormat}\'"LIMIT 1")
                	local adtrans_counte=$(($adtrans_counte + 1))

        	done
        fi

        [[ $adtrans == 'NULL' ]] && return 0 || eval $sendemail

        }


adtrans_knuckled_f(){

        local adtrans_countf=

        ${path_sbin}adtrans_InventorySources_v2_FF.py
        local adtrans=$(${mysql_db}"SELECT NULL FROM adtrans_InventorySources_v2 WHERE DATE = "\'${reapdateFormat}\'"LIMIT 1")

        if [[ -z $adtrans ]]
	then
        
		while [[ -z $adtrans ]] && [[ $adtrans_countf -lt 3 ]]
        	do
                	${path_sbin}adtrans_InventorySources_v2_FF.py
                	local adtrans=$(${mysql_db}"SELECT NULL FROM adtrans_InventorySources_v2 WHERE DATE = "\'${reapdateFormat}\'"LIMIT 1")
                	local adtrans_countf=$(($adtrans_countf + 1))

        	done
        fi

        [[ $adtrans == 'NULL' ]] && return 0 || eval $sendemail

        }


run_adtrans_InventorySources_v2(){
        adtrans_knuckled_a
        adtrans_knuckled_b
        adtrans_knuckled_c
        adtrans_knuckled_d
        adtrans_knuckled_e
        adtrans_knuckled_f
        }


run_adtrans_domain(){
	adtrans_count=
        adtransrownum_start=1
        adtransrownum_end=299999
	
	# Run inventorySource level adtrans & grab pid
#	run_adtrans_InventorySources_v2 &
#	adtrans_v2_pid=$!

	# Run domain level adtrans
	${path_sbin}adtrans_domainreport_v2.py
	adtrans=$(${mysql_db}"SELECT NULL FROM adtrans_domainreport_v2 WHERE DATE = "\'${reapdateFormat}\'"LIMIT 1")
	
	if [[ -z $adtrans ]]
	then

		while [[ -z $adtrans ]] && [[ $adtrans_count -lt 3 ]];
		do
			${path_sbin}adtrans_domainreport_v2.py
			adtrans=$(${mysql_db}"SELECT NULL FROM adtrans_domainreport_v2 WHERE DATE = "\'${reapdateFormat}\'"LIMIT 1")
			adtrans_count=$((adtrans_count + 1))
		done
		

		# If domain level execute then run pentaho automation
		[[ -n $adtrans ]] && ${path_pan}-file="${path_ktr}adtrans_domainreport_v2.ktr" || return 1
		
		# Wait for run_adtrans funtion to complete before continuing 
		run_adtrans_InventorySources_v2
#		wait "$adtrans_v2_pid"
		
		adtrans_invsources_v2_count=$(${mysql_db} "SELECT COUNT(*) FROM adtrans_InventorySources_v2 WHERE DATE ="\'${reapdateFormat}\'"")
		
		# Continuous for loop will increment counter until reach one rotation after adtrans_inventorces_v2_count
		for (( ; ; ))
		do
			[[ $adtransrownum_start -eq 1 ]] && adtransrownum_start=0
			${path_pan}-file="${path_ktr}adtrans_inventorysources_v2.ktr" -param:ROWNUM_START="${adtransrownum_start}" -param:ROWNUM_END="${adtransrownum_end}"
		
			[[ "$adtransrownum_end" -ge "$adtrans_invsources_v2_count" ]] && break
			
			adtransrownum_start=$(($adtransrownum_start + 300000));
			adtransrownum_end=$(($adtransrownum_end + 300000));
	       	done
	
		return 0
	
	else
		# If domain level execute then run pentaho automation
		[[ -n $adtrans ]] && ${path_pan}-file="${path_ktr}adtrans_domainreport_v2.ktr" || return 1
		
		# Wait for run_adtrans funtion to complete before continuing 
		run_adtrans_InventorySources_v2 
#		wait "$adtrans_v2_pid"

		
		adtrans_invsources_v2_count=$(${mysql_db} "SELECT COUNT(*) FROM adtrans_InventorySources_v2 WHERE DATE ="\'${reapdateFormat}\'"")
		
		# Continuous for loop will increment counter until reach one rotation after adtrans_inventorces_v2_count
		for (( ; ; ))
		do
			[[ $adtransrownum_start -eq 1 ]] && adtransrownum_start=0
			${path_pan}-file="${path_ktr}adtrans_inventorysources_v2.ktr" -param:ROWNUM_START="${adtransrownum_start}" -param:ROWNUM_END="${adtransrownum_end}"
		
			[[ "$adtransrownum_end" -ge "$adtrans_invsources_v2_count" ]] && break
			
			adtransrownum_start=$(($adtransrownum_start + 300000));
			adtransrownum_end=$(($adtransrownum_end + 300000));
	       	done
	fi

	return 0
}
		

# Beginning function executes script
run_adtrans_domain
