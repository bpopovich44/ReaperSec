#!/bin/bash

##
# -Runs all daily level processes
# -Sends MGNT and MonthlyReports
##

start_time=$(date +%s)
reapdate=$(date +%Y-%m-%d -d yesterday)
reapdateFormat=$(date +%m/%d/%Y -d yesterday)
path_sbin="/usr/local/sbin/backup_processes/"
path_pan="/home/ec2-user/data-integration/pan.sh "
path_kitchen="/home/ec2-user/data-integration/kitchen.sh "
path_ktr="/home/ec2-user/data-integration/epiphany_ktr/"
path_kjb="/home/ec2-user/data-integration/epiphany_kjb/"	
mysql_db="mysql --defaults-group-suffix=epiphanydb  -N -se " 
mysql_db2="mysql --defaults-group-suffix=kalturadb -N -e " 
mysql_db3="mysql --defaults-group-suffix=dailyprocess -N -se "
epiphany_daily_log="/home/ec2-user/Epiphany_logs/daily_process"
send_email="${path_kitchen}-file='${path_kjb}Daily_Processes_Error.kjb'"

platforms=( "dna" "dc" "adsym" "tm" "adtrans" "springserve" )
tables=( "inventorysources" "inventoryreport" "market_private" "market_public" ) 


daily_processes(){
	count=

	echo running ${platform}_${table}.py	
	${path_sbin}"${platform}_${table}.py"
	count_db=$(${mysql_db3}"SELECT NULL FROM "${platform}_${table}" WHERE DATE = "\'${reapdateFormat}\'" OR "\'${reapdate}\'"LIMIT 1")
	
	if [[ -z $count_db ]]
	then
		while [[ -z $count_db ]] && [[ $count -lt 3 ]]
		do
			${path_sbin}"${platform}_${table}.py"
			count_db=$(${mysql_db3}"SELECT NULL FROM "${platform}_${table}" WHERE DATE = "\'${reapdateFormat}\'" OR "\'${reapdate}\'"LIMIT 1")
			count=$(($count + 1))
		done
	fi

	[[ -z $count_db ]] && eval $send_email
	
	}
		

log_entry_new_tags(){

	printf "\r\n ${current_time}--NEW TAG CREATED" >> ${epiphany_daily_log} 
	printf "\r\n found_tag_$emptytag_inventorysources---" >> ${empiphany_daily_log}       
        printf "\r\n tag_$tag_inventorysources---" >> ${empiphany_daily_log} 
        printf "\r\n ag_id_$tag_Id---" >> ${empiphany_daily_log} 
        printf "\r\n tag_name_$tag_Name---" >> ${empiphany_daily_log} 
        printf "\r\n tag_type_$tag_Type---" >> ${empiphany_daily_log} 
        printf "\r\n tag_floor_$tag_Floor---" >> ${empiphany_daily_log} 
        printf "\r\n tag_Note_$tag_Note---" >> ${empiphany_daily_log} 
        printf "\r\n publisherID_$publisherID---" >> ${empiphany_daily_log} 
        printf "\r\n telli_ID_$telli_ID---" >> ${empiphany_daily_log} 
        printf "\r\n telli_Name_$telli_Name---" >> ${empiphany_daily_log} 
        printf "\r\n telli_Floor_$telli_Floor---" >> ${empiphany_daily_log} 
        printf "\r\n telli_Type_$telli_Type---" >> ${empiphany_daily_log} 
        printf "\r\n telli_Note_$telli_Note---" >> ${empiphany_daily_log} 
	printf "\r\n intellitagID_$intelliTagID---" >> ${empiphany_daily_log}                      
        printf "\r\n platformTagID_$platformTag_ID---" >> ${empiphany_daily_log}                      
	
	}


create_tag(){
	        
        new_created_inventorysources=$(${mysql_db}"SELECT NAME FROM inventorySources WHERE publisherID is NULL OR publisherID = '';")
        emptytag_inventorysources=$(${mysql_db}"SELECT CONCAT(id, '-'), NAME FROM inventorySources WHERE publisherID is NULL OR publisherID = '' LIMIT 1;")
        tag_inventorysources=$(${mysql_db}"SELECT NAME FROM inventorySources WHERE publisherID is NULL OR publisherID = '' LIMIT 1;")
	
	echo "In function create_tag"
        
        if [[ -n $emptytag_inventorysources ]]
        then    
                while IFS='-' read -r tagId tagName tagType tagNote tagFloor last
                do
                        tag_Id="$(sed -e 's/[[:space:]]*$//' <<<${tagId})"
                        tag_Name="$(sed -e 's/[[:space:]]*$//' <<<${tagName})"
                        tag_Type="$(sed -e 's/[[:space:]]*$//' <<<${tagType})"
                        tag_Note="$(sed -e 's/[[:space:]]*$//' <<<${tagNote//$/})"
                        tag_Floor="$(sed -e 's/[^0-9]*$//' <<<${tagFloor//$/})"
#                       tag_Floor="$(sed -e 's/[[:space:]]*$//' <<<${tagFloor//$/})"

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
                                        tag_Type=''
                                ;;
                        esac

                        case $tag_Note in
                                EAI|eai|EAi|dc|DC|adsym|ADSYM|adtrans|ADTRANS|tm|TM|ss|SS )
                                        tag_Note=''
                                ;;

                                *[0-9]* )
                                        tag_Floor=$(echo $tag_Note | sed -e 's/[^0-9]*$//')  && tag_Note='-'
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
                                        tag_Floor=$tag_Floor
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

                        # If no intelligentTag, this creates intelligentTag.  Double quotes to keep \n
                        intelliTags="$(${mysql_db}"SELECT CONCAT(id, '-'), NAME FROM intelligentTags WHERE publisherID = \"$publisherID\" ")"

                        # Reaches out to kaltura db to grab platformTag_id
			platformTag_ID=$(${mysql_db2}"SELECT product_id FROM demand WHERE NAME = '$tag_inventorysources'")

                        if [[ -n $intelliTags ]]
                        then
                                while read -r line
                                do
                                        readLine=$line
                                        intelliTagID=

                                         while IFS='-' read  -r telliID telliName telliFloor telliType telliNote last
                                        do
                                                telli_ID="$(sed -e 's/[[:space:]]*$//' <<<${telliID})"
                                                telli_Name="$(sed -e 's/[[:space:]]*$//' <<<${telliName})"
                                                telli_Floor="$(sed -e 's/[[:space:]]*$//' <<<${telliFloor//$/})"
                                                telli_Type="$(sed -e 's/[[:space:]]*$//' <<<${telliType})"
                                                telli_Note="$(sed -e 's/[[:space:]]*$//' <<<${telliNote})"

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

                                                if [[ $telli_Name = $tag_Name ]] &&
                                                	[[ $telli_Floor = $tag_Floor ]] &&
                                                	[[ $telli_Type = $tag_Type ]] &&
                                                	[[ $telli_Note = $tag_Note ]]
                                                then
                                                        intelliTagID=$telli_ID
                                                fi

                                        done < <(echo "$readLine")

                                        # break out of loop when finds tag      
                                        [[ -n $intelliTagID ]] && break

                                #need echo and quotes to get to format correctly
                                done < <(echo "$intelliTags")

                                [[ -z $intelliTagID ]] && intelliTagID=$(${mysql_db}"INSERT INTO intelligentTags (name, publisherID, platformTagID)
                                        values (\"$tag_Name - \$$tag_Floor - $tag_Type - $tag_Note - IntelligentTag\", \"$publisherID\", \"$platformTag_ID\" );SELECT LAST_INSERT_ID();")

                        else
                                intelliTagID=$(${mysql_db}"INSERT INTO intelligentTags (name, publisherID, platformTagID) 
                                        VALUES (\"$tag_Name - \$$tag_Floor - $tag_Type - $tag_Note - IntelligentTag\", \"$publisherID\", \"$platformTag_ID\" );SELECT LAST_INSERT_ID();")
                        fi

			echo found_tag_$emptytag_inventorysources---       
		        echo tag_$tag_inventorysources-- 
        		echo tag_id_$tag_Id--- 
        		echo tag_name_$tag_Name--- 
        		echo tag_type_$tag_Type--- 
        		echo tag_floor_$tag_Floor---
        		echo tag_Note_$tag_Note--- 
        		echo publisherID_$publisherID--- 
        		echo telli_ID_$telli_ID--- 
        		echo telli_Name_$telli_Name--- 
        		echo telli_Floor_$telli_Floor--- 
        		echo telli_Type_$telli_Type--- 
        		echo telli_Note_$telli_Note--- 
			echo intellitagID_$intelliTagID---                      
        		echo platformTagID_$platformTag_ID---                      

			
			## log entry Epiphany_logs
  
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

                                "" )
                                        tag_creation=$(${mysql_db}"UPDATE inventorySources SET publisherID = $publisherID, intelligentTagID = $intelliTagID, \
                                                createdAt = CURDATE(), WHERE id = "${tag_Id}";")
                                        ;;
                        esac

                done <<< $emptytag_inventorysources
        fi

	}


send_reports(){

	## Check tables and send reports if yesterdays date present
	reports_InventorySource=$(${mysql_db} "SELECT NULL FROM reports_InventorySource WHERE DATE ="\'${reapdate}\'"LIMIT 1") 
	reports_Marketplace=$(${mysql_db} "SELECT NULL FROM reports_Marketplace WHERE DATE ="\'${reapdate}\'"LIMIT 1") 
	test_Aggregate=$(${mysql_db} "SELECT NULL FROM test_Aggregate WHERE DATE ="\'${reapdate}\'"LIMIT 1") 
	test_Final=$(${mysql_db} "SELECT NULL FROM test_Final WHERE DATE ="\'${reapdate}\'"LIMIT 1") 

	if [[ -n $reports_InventorySource ]] &&
   	   [[ -n $reports_Marketplace ]] &&
   	   [[ -n $test_Aggregate ]] &&
   	   [[ -n $test_Final ]]
	then
		${path_sbin}reportMGNT.sy
		${path_sbin}reportMonthly.sh
	else
		printf "\r\n Error.  Reports were not sent" >> ${epiphany_daily_log} && exit 1
	fi
	}


launch_processes(){

	# Two for loops to launch python processes
	for platform in "${platforms[@]}"
	do
		for table in "${tables[@]}"
		do
			daily_processes ${platform} ${table}
		done
	done 
	}


check_for_empty_tag(){

	echo "checking for empty tag"
	emptytag=$(${mysql_db}"SELECT CONCAT(id, '-'), NAME FROM inventorySources WHERE publisherID IS NULL OR publisherID = '' OR publisherID = '0';")
	if [[ -n $emptytag ]]
	then
       		while [[ -n $emptytag ]]
       		do
               		create_tag
               		emptytag=$(${mysql_db}"SELECT CONCAT(id, '-'), NAME FROM inventorySources WHERE publisherID IS NULL OR publisherID = '' OR publisherID = '0' LIMIT 1;")
       		done
	fi
	}


## STEP 1 launch python scripts
launch_processes

## STEP 2 run pentaho kitchen process for inventhry sources for previous day
${path_kitchen}-file="${path_kjb}daily_process_inventorysources_part1.kjb"

## STEP 3 check for any new inventory sources
check_for_empty_tag

## STEP 4 run slice and dice for number manipulation (fees etc.) 
${path_kitchen}-file="${path_kjb}daily_process_sliceNdice_part2.kjb"

## STEP 5 send reports  
#send_reports

# Entry into Epiphany_logs		
current_time=$(date)
end_time=$(date +%s)
runtime=$((end_time - start_time))

printf "\r\n ${current_time}--Morning processes completed successfully. Runtime: ${runtime} seconds.  New tags created are: $new_created_inventorysources" >> ${epiphany_daily_log}
