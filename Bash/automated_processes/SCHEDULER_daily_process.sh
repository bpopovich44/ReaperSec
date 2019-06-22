#!/bin/bash -e 

##
# -Runs all daily level processes
# -Sends MGNT and MonthlyReports
##


START_TIME=$(date +%s)
YESTERDAYDATE_1=$(date +%Y-%m-%d -d yesterday)
YESTERDAYDATE_2=$(date +%m/%d/%Y -d yesterday)
TIMESTAMP="$(date "+%Y-%m-%d %H:%M:%S")"

# Paths
path_file="/usr/local/sbin/"
path_pan="/home/ec2-user/data-integration/pan.sh "
path_kitchen="/home/ec2-user/data-integration/kitchen.sh "
path_ktr="/home/ec2-user/data-integration/epiphany_ktr/"
path_kjb="/home/ec2-user/data-integration/epiphany_kjb/"	
path_daily_log="/home/ec2-user/Epiphany_logs/daily_process.log"
path_error_log="/home/ec2-user/Epiphany_logs/error.log"

# Databases
mysql_db="mysql --defaults-group-suffix=epiphanydb  -N -se " 
mysql_db2="mysql --defaults-group-suffix=kalturadb -N -e " 
mysql_db3="mysql --defaults-group-suffix=dailyprocess -N -se "

# Files
file1="data_file.py"
file2="python_dbconfig.py"
file3="aol_api.py"
file4="springs_api.py"

# Arrays to hold platforms and daily tables
platforms=( "dna" "dc" "adsym" "tm" "adtrans" "springserve" )
report_book=( "inventorysources" "inventoryreport" "market_private" "market_public" ) 


send_error_mail(){

	ERROR_EMAIL="bill@epiphanyai.com"

	ERROR_SUBJECT="*** ${platform}_${report} had an error ***"

	# Add comments for error email
	ERROR_COMMENT=$(cat <<- EOF
	*** An error occured on ${platform}_${report}.py at ${TIMESTAMP} ***







	--dataTeam



	EOF
	)

	${path_kitchen}-file="${path_kjb}script_ERROR.kjb" -param:ERROR_EMAIL="${ERROR_EMAIL}" -param:ERROR_COMMENT="${ERROR_COMMENT}" -param:ERROR_SUBJECT="${ERROR_SUBJECT}"

	}


create_tag(){

        emptytag_inventorysources=$(${mysql_db}"SELECT CONCAT(id, '-'), NAME FROM inventorySources WHERE publisherID is NULL OR publisherID = '' LIMIT 1;")
        tag_inventorysources=$(${mysql_db}"SELECT NAME FROM inventorySources WHERE publisherID is NULL OR publisherID = '' LIMIT 1;")
	
	# Empty array to hold found inventorysources in tag generator
	declare -a bag_of_tags

	
	if [[ -n $emptytag_inventorysources ]]
        then    
                while IFS='-' read -r tagId tagName tagType tagNote tagFloor last
                do
       
			tag_Id="$(echo -e "${tagId}" | sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//')"
			tag_Name="$(echo -e "${tagName}" | sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//')"
			tag_Type="$(echo -e "${tagType//$/}" | sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//')"
			tag_Note="$(echo -e "${tagNote//$/}" | sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//')"
			tag_Floor="$(echo -e "${tagFloor//$/}" | sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//')"


                        case $tag_Type in
                                mw|MW|"Mobile Web"|"mobile web"|"mobileweb"|"MobileWeb" )
                                        tag_Type="MW"
                                ;;

                                dt|DT|"Desktop"|"DeskTop"|"desktop" )
                                        tag_Type="DT"
                                ;;

                                INAPP|InApp|inapp|"In App"|"in app" )
                                        tag_Type="INAPP"
                                ;;

                                ctv|CTV )
                                        tag_Type="CTV"
                                ;;

                                *latform* )
                                        tag_Type="Platform Account"
                                ;;

                                Rev*|rev* )
                                        tag_Type="REVSHARE"
                                ;;
				
				display|Display|DISPLAY )
					tag_Type="DISPLAY"
				;;

                                * )
                                        tag_Type=$tag_Type
                                ;;
                        esac

                        case $tag_Note in
                                EAI|eai|EAi|dc|DC|adsym|ADSYM|adtrans|ADTRANS|tm|TM|ss|SS )
                                        tag_Note=''
                                ;;

                                [0-9]* )
					tag_Floor=$(echo -e $tag_Note | sed -e 's/\([a-zA-Z: \t]\)//g')  && tag_Note='-'
                                ;;
     
                                *Test*|*test*|*TEST* )
                                        tag_Note="TEST"
                                ;;

                                "" )
                                        tag_Note="-"
                                ;;

                                * )
                                        tag_Note=$tag_Note
                                ;;
                        esac

                        case $tag_Floor in
                                *[0-9]* )
					tag_Floor=$(echo $tag_Floor | sed 's/\([a-zA-Z: \t]\)//g')
                                ;;

                                "RevShare"|"Revshare"|"revshare"|"rev"|"REV" )
                                        tag_Floor="REV"
                                ;;

                                "" )
                                        tag_Floor="0"
                                ;;

                        esac

                        [[ -z $emptytag_inventorysources ]] && publisherID='0' break || publisherID=$(${mysql_db}"SELECT id FROM publishers WHERE friendlyName = \"$tag_Name\" ")

                        # If no publisher, this creates publisher
                        if [[ -z $publisherID ]]
                        then
                                ${mysql_db}"INSERT INTO publishers (friendlyName) VALUES (\"$tag_Name\");"
                                publisherID=$(${mysql_db}"SELECT id FROM publishers WHERE friendlyName = \"$tag_Name\" ")
                        fi
			
                        # Reaches out to kaltura db to grab platformTag_id
			platformTag_ID=$(${mysql_db2}"SELECT product_id FROM demand WHERE NAME = '$tag_inventorysources'")

                        # Check for pre-existing intelligent tags.   Double quotes to keep \n
                        query="$(${mysql_db}"SELECT CONCAT(id, '-'), NAME FROM intelligentTags WHERE publisherID = \"$publisherID\" ")"

			# Add new tags to bag_of_tags array
			bag_of_tags=("${bag_of_tags[@]}" "${query}")

                        if [[ -n $bag_of_tags ]]
                        then
                                while read -r line
                                do
                                        readLine=$line
                                        intelliTagID=

                                        while IFS='-' read  -r telliID telliName telliFloor telliType telliNote last
                                        do
         
						telli_Id="$(echo -e "${telliID}" | sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//')"
						telli_Name="$(echo -e "${telliName}" | sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//')"
						telli_Floor="$(echo -e "${telliFloor//$/}" | sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//')"
						telli_Type="$(echo -e "${telliType//$/}" | sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//')"
						telli_Note="$(echo -e "${telliNote//$/}" | sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//')"

                                                case $telli_Floor in
                                                        *[0-9]* )
                                                                telli_Floor=$telli_Floor
                                                        ;;

#                                                       "Revshare"|"revshare"|"RevShare"|"REVSHARE"|"rev"|"REV" )
#                                                               telli_Floor="REV"
#                                                       ;;

                                                        *latform* )
                                                                telli_Floor="Platform Account"
                                                        ;;

                                                        * )
                                                                telli_Floor=
                                                        ;;

                                                esac

                                                case $telli_Type in
                                                        mw|MW|"Mobile Web"|"mobile web"|"mobileweb"|"MobileWeb" )
                                                                 telli_Type="MW"
                                                        ;;

                                                        dt|DT|"Desktop"|"DeskTop"|"desktop" )
                                                                telli_Type="DT"
                                                        ;;

                                                        INAPP|InApp |inapp|"In App"|"in app" )
                                                                telli_Type="INAPP"
                                                        ;;

                                                        ctv|CTV )
                                                                telli_Type="CTV"
                                                        ;;
							
							display|Display|DISPLAY )
								telli_Type="DISPLAY"
							;;

                                                        "" )
                                                                telli_Type='-'
                                                        ;;

                                                esac

                                                case $telli_Note in
                                                        "IntelligentTag" )
                                                                telli_Note=
 	                                                ;;

                                                        *Test*|*test*|*TEST* )
                                                                telli_Note="TEST"
                                                        ;;

                                                        "" )
                                                                telli_Note="-"
                                                        ;;

                                                        * )
                                                                telli_Note=$telli_Note
                                                        ;;
                                                esac

                                                if [[ "$telli_Name" == "$tag_Name" ]] &&
                                               	   [[ "$telli_Floor" == "$tag_Floor" ]] &&
                                                   [[ "$telli_Type" == "$tag_Type" ]] &&
                                                   [[ "$telli_Note" == "$tag_Note" ]]

                                                then
							echo equal
                                                        intelliTagID=$telli_Id 
                                                fi

                                        done < <(echo "$readLine")
					
                                        # break out of loop when finds tag      
                                        [[ -n $intelliTagID ]] && break

                                #need echo and quotes to get to format correctly
                                done < <(echo "$bag_of_tags")
				
                                [[ -z $intelliTagID ]] && intelliTagID=$(${mysql_db}"INSERT INTO intelligentTags (name, publisherID, platformTagID)
                                        values (\"$tag_Name - \$$tag_Floor - $tag_Type - $tag_Note - IntelligentTag\", \"$publisherID\", \"$platformTag_ID\" );SELECT LAST_INSERT_ID();")

                        else
                                intelliTagID=$(${mysql_db}"INSERT INTO intelligentTags (name, publisherID, platformTagID) 
                                        VALUES (\"$tag_Name - \$$tag_Floor - $tag_Type - $tag_Note - IntelligentTag\", \"$publisherID\", \"$platformTag_ID\" );SELECT LAST_INSERT_ID();")
                        fi
			
			# Actual tag creation   
                        case "$tag_Type" in

				dt|DT|Desktop|DeskTop|desktop|platform*|Platform*|rev|Rev*|REV* )
                                       tag_creation=$(${mysql_db}"UPDATE inventorySources SET publisherID = $publisherID, intelligentTagID = $intelliTagID, \
                                                createdAt = CURDATE(), floor = "${tag_Floor}", isPlatformTag = "1" WHERE id = "${tag_Id}";")
                                        ;;

                                mw|MW|"Mobile Web"|"MovileWeb"|"mobile web"|"mobileweb"|platform*|Platform*|Rev*|rev* )
                                        tag_creation=$(${mysql_db}"UPDATE inventorySources SET publisherID = $publisherID, intelligentTagID = $intelliTagID, \
                                                createdAt = CURDATE(), floor = $tag_Floor, isMobile = "1", isMobileWeb = "1", isPlatformTag = "1" WHERE id = "${tag_Id}";")
                                        ;;

                                INAPP|InApp|inapp|"In App"|"in app" )
                                        tag_creation=$(${mysql_db}"UPDATE inventorySources SET publisherID = $publisherID, intelligentTagID = $intelliTagID, \
                                                createdAt = CURDATE(), floor = $tag_Floor, isMobile = "1", isMobileApp = "1", isPlatformTag = "1" WHERE id = "${tag_Id}";")
                                        ;;

                                ctv|CTV )
                                        tag_creation=$(${mysql_db}"UPDATE inventorySources SET publisherID = $publisherID, intelligentTagID = $intelliTagID, \
                                                createdAt = CURDATE(), floor = $tag_Floor, isPlatformTag = "1" WHERE id = "${tag_Id}";")
                                        ;;

                                 * )
                                        tag_creation=$(${mysql_db}"UPDATE inventorySources SET publisherID = $publisherID, intelligentTagID = $intelliTagID, \
                                                createdAt = CURDATE(), floor = $tag_Floor, isPlatformTag = "1" WHERE id = "${tag_Id}";")
					;;
                        esac

                done <<< $emptytag_inventorysources
	
	fi

	}


send_reports(){

	## Check tables and send reports if yesterdays date present
	reports_InventorySource=$(${mysql_db} "SELECT NULL FROM reports_InventorySource WHERE DATE ="\'${YESTERDAYDATE_1}\'"LIMIT 1") 
	reports_Marketplace=$(${mysql_db} "SELECT NULL FROM reports_Marketplace WHERE DATE ="\'${YESTERDAYDATE_1}\'"LIMIT 1") 
	test_Aggregate=$(${mysql_db} "SELECT NULL FROM test_Aggregate WHERE DATE ="\'${YESTERDAYDATE_1}\'"LIMIT 1") 
	test_Final=$(${mysql_db} "SELECT NULL FROM test_Final WHERE DATE ="\'${YESTERDAYDATE_1}\'"LIMIT 1") 


	if [[ -n $reports_InventorySource ]] &&
   	   [[ -n $reports_Marketplace ]] &&
   	   [[ -n $test_Aggregate ]] &&
   	   [[ -n $test_Final ]]
	then
		${path_file}reportPlatformTotals.sh
		${path_file}reportDaily.sh

		return 0
	else
		printf "\n ${TIMESTAMP} Error.  Reports were not sent." >> ${path_daily_log} && return 1
	fi
		
	}


check_for_empty_tag(){

	echo checking for empty tags
	emptytag=$(${mysql_db}"SELECT NULL FROM inventorySources WHERE publisherID IS NULL OR publisherID = '' OR publisherID = '0' LIMIT 1;")
	if [[ -n $emptytag ]]
	then
       		while [[ -n $emptytag ]]
       		do
               		create_tag
               		emptytag=$(${mysql_db}"SELECT NULL FROM inventorySources WHERE publisherID IS NULL OR publisherID = '' OR publisherID = '0' LIMIT 1;")
       		done
	fi

	return 0
	}


check_new_tag(){
	
	echo checking for new tags
	${path_kitchen}-file="${path_kjb}check_new_tag.kjb" 
	
	return 0
	}


log_entry(){

	end_time=$(date +%s)
	runtime=$((end_time - start_time))

	printf "\n${TIMESTAMP}--Morning processes completed successfully. Runtime: ${runtime} seconds.  " >> ${path_daily_log}
	
	if [[ ${#bag_of_tags[@]} -eq 0 ]]
	then
		printf "No new tags." >> ${path_daily_log}
	else
		printf "New tags: " >> ${path_daily_log}
		printf '\n%s' "${bag_of_tags[@]}" >> ${path_daily_log}
	fi
	}


daily_processes(){
	count=

	[[ $platform == "springserve" ]] && prefix="springserve" || prefix="oath"		

	[[ -x ${path_file}"${prefix}_${report}.py" ]] && ${path_file}"${prefix}_${report}.py" ${platform} || return 0 
	check_db=$(${mysql_db3}"SELECT NULL FROM "${platform}_${report}" WHERE DATE IN ("\'${YESTERDAYDATE_1}\'", "\'${YESTERDAYDATE_2}\'") LIMIT 1")
		
	if [[ -z "${check_db}" ]]
	then
		while [[ -z "${check_db}" ]] && [[ "${count}" -lt 3 ]]
		do
			sleep 2
			[[ -x ${path_file}"${prefix}_${report}.py" ]] && ${path_file}"${prefix}_${report}.py" ${platform} || return 0 
			check_db=$(${mysql_db3}"SELECT NULL FROM "${platform}_${report}" WHERE DATE IN ("\'${YESTERDAYDATE_1}\'", "\'${YESTERDAYDATE_2}\'") LIMIT 1")

			count=$((count + 1))
		done
	fi

	# Error handling -- LEAVING RETURN ON EXIT CODE 0 FOR NOW, IF THERE IS AN ERROR OTHER PLATFORMS WILL RUN
	check_db=$(${mysql_db3}"SELECT NULL FROM "${platform}_${report}" WHERE DATE IN ("\'${YESTERDAYDATE_1}\'", "\'${YESTERDAYDATE_2}\'") LIMIT 1")
	[[ -z "${check_db}" ]] && { send_error_mail; printf "\n${TIMESTAMP} ${platform}_${report}.py ERROR. \
	LOOK AT daily_process.log for more information." >> ${path_error_log}; return 1; } || return 0

	}
		

launch_processes(){
	
	# Two for loops to launch python processes
	for report in "${report_book[@]}"
	do
		[[ "$?" == "0" ]] && for platform in "${platforms[@]}" 
		do
			[[ "$?" == "0" ]] && daily_processes ${report} ${platform}  
		done
	done 

	[[ "$?" == "0" ]] && return 0 || return 1
	}


check_existing_scripts(){

	[[ ! -f ${path_file}"${file1}" ]] && return 1
	[[ ! -f ${path_file}"${file2}" ]] && return 1
	[[ ! -f ${path_file}"${file3}" ]] && return 1
	[[ ! -f ${path_file}"${file4}" ]] && return 1

	return 0
	}


run_daily_processes(){

	## STEP 1 check existing scripts
#	check_existing_scripts

	## STEP 2 launch python scripts
#	[[ "$?" == '0' ]] && launch_processes || return 1
	
	## STEP 3 run pentaho kitchen process for inventhry sources for previous day
#	[[ "$?" == '0' ]] && ${path_kitchen}-file="${path_kjb}daily_process_inventorysources_part1.kjb"
	 
	## STEP 4 check for any new inventory sources
#	[[ "$?" == '0' ]] && check_new_tag
	
	## STEP 5 if new inventorysources, create new tag 
	[[ "$?" == '0' ]] && check_for_empty_tag 
		
	## STEP 6 run slice and dice for number manipulation (fees etc.) 
#	[[ "$?" == '0' ]] && ${path_kitchen}-file="${path_kjb}daily_process_sliceNdice_part2.kjb" 

	## STEP 7 send reports  
#	[[ "$?" == '0' ]] && send_reports

	## STEP 8 Entry into Epiphany_logs		
#	log_entry
	}



# Execute script and error handling of script
run_daily_processes
# 2>&1 | tee -a ${path_daily_log}

# SAVE TO USE WHEN PASS TO TWO LOGS
#run_daily_processes > >(tee -a ${path_daily_log}) 2> >(tee -a ${path_error_log} >&2)

[[ "${PIPESTATUS[0]}" == "0" ]] && exit 0 || { printf "\n${TIMESTAMP} Exit code 1.  Look at daily_process.log for more information" >> ${path_error_log}; exit 1; }
