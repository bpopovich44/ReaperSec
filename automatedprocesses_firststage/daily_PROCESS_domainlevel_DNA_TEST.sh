#!/bin/bash

##
#
#  runs all DNA domain level processes
#
##

path_sbin="/usr/local/sbin/"
reapdate=$(date +%Y-%m-%d -d yesterday)
reapdateFormat=$(date +%m/%d/%Y -d yesterday)
path_pan="/home/ec2-user/data-integration/pan.sh "
path_ktr="/home/ec2-user/data-integration/epiphany_ktr/"
mysql_db="mysql --defaults-group-suffix=domainlevel -N -e "
send_email="/home/ec2-user/data-integration/kitchen.sh -file='/home/ec2-user/data-integration/epiphany_kjb/dna_InventorySources_v2_Error.kjb'"


dna_knuckled_a(){
        local dna_counta=

        ${path_sbin}dna_InventorySources_v2_AA.py
        local dna=$(${mysql_db}"SELECT NULL FROM dna_InventorySources_v2 WHERE DATE = "\'${reapdateFormat}\'"LIMIT 1")

        if [[ -z $dna ]]
	then
       		while [[ -z $dna ]] && [[ $dna_counta -lt 3 ]]
        	do
                	${path_sbin}dna_InventorySources_v2_AA.py
                	local dna=$(${mysql_db}"SELECT NULL FROM dna_InventorySources_v2 WHERE DATE = "\'${reapdateFormat}\'"LIMIT 1")
                	local dna_counta=$(($dna_counta + 1))
        	done
        fi

        [[ $dna == 'NULL' ]] && return 0 || eval $sendemail
        }

dna_knuckled_b(){
        local dna_countb=

        ${path_sbin}dna_InventorySources_v2_BB.py
        local dna=$(${mysql_db}"SELECT NULL FROM dna_InventorySources_v2 WHERE DATE = "\'${reapdateFormat}\'"LIMIT 1")

        if [[ -z $dna ]]
	then
		while [[ -z $dna ]] && [[ $dna_countb -lt 3 ]]
        	do
                	${path_sbin}dna_InventorySources_v2_BB.py
                	local dna=$(${mysql_db}"SELECT NULL FROM dna_InventorySources_v2 WHERE DATE = "\'${reapdateFormat}\'"LIMIT 1")
                	local dna_countb=$(($dna_countb + 1))
        	done
        fi

        [[ $dna == 'NULL' ]] && return 0 || eval $sendemail
        }


dna_knuckled_c(){
        local dna_countc=

        ${path_sbin}dna_InventorySources_v2_CC.py
        local dna=$(${mysql_db}"SELECT NULL FROM dna_InventorySources_v2 WHERE DATE = "\'${reapdateFormat}\'"LIMIT 1")

        if [[ -z $dna ]]
	then
		while [[ -z $dna ]] && [[ $dna_countc -lt 3 ]]
        	do
                	${path_sbin}dna_InventorySources_v2_CC.py
                	local dna=$(${mysql_db}"SELECT NULL FROM dna_InventorySources_v2 WHERE DATE = "\'${reapdateFormat}\'"LIMIT 1")
                	local dna_countc=$(($dna_countc + 1))
        	done
        fi

        [[ $dna == 'NULL' ]] && return 0 || eval $sendemail
        }

dna_knuckled_d(){
        local dna_countd=

        ${path_sbin}dna_InventorySources_v2_DD.py
        local dna=$(${mysql_db}"SELECT NULL FROM dna_InventorySources_v2 WHERE DATE = "\'${reapdateFormat}\'"LIMIT 1")

        if [[ -z $dna ]]
	then
		while [[ -z $dna ]] && [[ $dna_countd -lt 3 ]]
        	do
                	${path_sbin}dna_InventorySources_v2_DD.py
                	local dna=$(${mysql_db}"SELECT NULL FROM dna_InventorySources_v2 WHERE DATE = "\'${reapdateFormat}\'"LIMIT 1")
			local dna_countd=$(($dna_countd + 1))
        	done
        fi

        [[ $dna == 'NULL' ]] && return 0 || eval $sendemail
        }

dna_knuckled_e(){
        local dna_counte=

        ${path_sbin}dna_InventorySources_v2_EE.py
        local dna=$(${mysql_db}"SELECT NULL FROM dna_InventorySources_v2 WHERE DATE = "\'${reapdateFormat}\'"LIMIT 1")

        if [[ -z $dna ]]
	then
		while [[ -z $dna ]] && [[ $dna_counte -lt 3 ]]
        	do
                	${path_sbin}dna_InventorySources_v2_EE.py
                	local dna=$(${mysql_db}"SELECT NULL FROM dna_InventorySources_v2 WHERE DATE = "\'${reapdateFormat}\'"LIMIT 1")
                	local dna_counte=$(($dna_counte + 1))
        	done
        fi

        [[ $dna == 'NULL' ]] && return 0 || eval $sendemail
        }

dna_knuckled_f(){
        local dna_countf=

        ${path_sbin}dna_InventorySources_v2_FF.py
        local dna=$(${mysql_db}"SELECT NULL FROM dna_InventorySources_v2 WHERE DATE = "\'${reapdateFormat}\'"LIMIT 1")

        if [[ -z $dna ]]
	then
		while [[ -z $dna ]] && [[ $dna_countf -lt 3 ]]
        	do
                	${path_sbin}dna_InventorySources_v2_FF.py
                	local dna=$(${mysql_db}"SELECT NULL FROM dna_InventorySources_v2 WHERE DATE = "\'${reapdateFormat}\'"LIMIT 1")
                	local dna_countf=$(($dna_countf + 1))
        	done
        fi

        [[ $dna == 'NULL' ]] && return 0 || eval $sendemail
        }

run_dna_InventorySources_v2_AM(){
        dna_knuckled_a
        dna_knuckled_b
        dna_knuckled_c
        }

run_dna_InventorySources_v2_PM(){
        dna_knuckled_d
        dna_knuckled_e
        dna_knuckled_f
        }

run_dna_domain(){
	dna_count=
        dnarownum_start=1
        dnarownum_end=299999
	

	# Run domain level dna
	${path_sbin}dna_domainreport_v2.py
	dna=$(${mysql_db}"SELECT NULL FROM dna_domainreport_v2 WHERE DATE = "\'${reapdateFormat}\'"LIMIT 1")
	
	if [[ -z $dna ]]
	then

		while [[ -z $dna ]] && [[ $dna_count -lt 3 ]];
		do
			${path_sbin}dna_domainreport_v2.py
			dna=$(${mysql_db}"SELECT NULL FROM dna_domainreport_v2 WHERE DATE = "\'${reapdateFormat}\'"LIMIT 1")
			dna_count=$((dna_count + 1))
		done
		

		# If domain level execute then run pentaho automation
		[[ -n $dna ]] && ${path_pan}-file="${path_ktr}dna_domainreport_v2.ktr" || return 1
		
		# Wait for run_dna funtion to complete before continuing 
		run_dna_InventorySources_v2
		
		dna_invsources_v2_count=$(${mysql_db} "SELECT COUNT(*) FROM dna_InventorySources_v2 WHERE DATE ="\'${reapdateFormat}\'"")
		
		# Continuous for loop will increment counter until reach one rotation after dna_inventorces_v2_count
		for (( ; ; ))
		do
			[[ $dnarownum_start -eq 1 ]] && dnarownum_start=0
			${path_pan}-file="${path_ktr}dna_inventorysources_v2.ktr" -param:ROWNUM_START="${dnarownum_start}" -param:ROWNUM_END="${dnarownum_end}"
		
			[[ "$dnarownum_end" -ge "$dna_invsources_v2_count" ]] && break
			
			dnarownum_start=$(($dnarownum_start + 300000));
			dnarownum_end=$(($dnarownum_end + 300000));
	       	done
	
		return 0
	
	else
		# If domain level execute then run pentaho automation
###		[[ -n $dna ]] && ${path_pan}-file="${path_ktr}dna_domainreport_v2.ktr" || return 1
		
		# Wait for run_dna funtion to complete before continuing 
		run_dna_InventorySources_v2

		
		dna_invsources_v2_count=$(${mysql_db} "SELECT COUNT(*) FROM dna_InventorySources_v2 WHERE DATE ="\'${reapdateFormat}\'"")
		
		# Continuous for loop will increment counter until reach one rotation after dna_inventorces_v2_count
		for (( ; ; ))
		do
			[[ $dnarownum_start -eq 1 ]] && dnarownum_start=0
			${path_pan}-file="${path_ktr}dna_inventorysources_v2.ktr" -param:ROWNUM_START="${dnarownum_start}" -param:ROWNUM_END="${dnarownum_end}"
		
			[[ "$dnarownum_end" -ge "$dna_invsources_v2_count" ]] && break
			
			dnarownum_start=$(($dnarownum_start + 300000));
			dnarownum_end=$(($dnarownum_end + 300000));
	       	done
	fi

	return 0
}
		

# Beginning function executes script
run_dna_domain
