#!/bin/bash -e 

##
# -Runs all daily level processes
# -Sends MGNT and MonthlyReports
##


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



create_tag(){

        #new_created_inventorysources=$(${mysql_db}"SELECT NAME FROM inventorySources_TEST WHERE publisherID is NULL OR publisherID = '';")
        emptytag_inventorysources=$(${mysql_db}"SELECT CONCAT(id, '-'), NAME FROM inventorySources_TEST WHERE publisherID is NULL OR publisherID = '' LIMIT 1;")
        tag_inventorysources=$(${mysql_db}"SELECT NAME FROM inventorySources_TEST WHERE publisherID is NULL OR publisherID = '' LIMIT 1;")
	# Empty array to hold found inventorysources in tag generator
	
	declare -a bag_of_tags
	echo bagOtags1---$bag_of_tags---

	tagCounter=0

#	while [[ $tagCounter -le 2 ]]
#	do
	
	if [[ -n $emptytag_inventorysources ]]
        then    
                while IFS='-' read -r tagId tagName tagType tagNote tagFloor last
                do
                        

			tag_Id="$(echo -e "${tagId}" | sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//')"
			tag_Name="$(echo -e "${tagName}" | sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//')"
			tag_Type="$(echo -e "${tagType//$/}" | sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//')"
			tag_Note="$(echo -e "${tagNote//$/}" | sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//')"
			tag_Floor="$(echo -e "${tagFloor//$/}" | sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//')"

			echo tag_id---$tag_Id---
			echo tag_Name---$tag_Name---
			echo tag_Type---$tag_Type---
			echo tag_Note---$tag_Note---
			echo tag_Floor---$tag_Floor---
			echo

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
                                        #tag_Floor=$(echo -e $tag_Note | sed -e 's/[^0-9]*$//')  && tag_Note='-'
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
					#tag_Floor=$(echo $tag_Floor | sed 's/[^0-9]*//g')
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
: <<'END'
                        # If no publisher, this creates publisher
                        if [[ -z $publisherID ]]
                        then
                                ${mysql_db}"INSERT INTO publishers (friendlyName) VALUES (\"$tag_Name\");"
                                publisherID=$(${mysql_db}"SELECT id FROM publishers WHERE friendlyName = \"$tag_Name\" ")
                        fi

			
                        # Reaches out to kaltura db to grab platformTag_id
			platformTag_ID=$(${mysql_db2}"SELECT product_id FROM demand WHERE NAME = '$tag_inventorysources'")
			
END
                        # Check for pre-existing intelligent tags.   Double quotes to keep \n
                        query="$(${mysql_db}"SELECT CONCAT(id, '-'), NAME FROM intelligentTags_TEST WHERE publisherID = \"$publisherID\" ")"

			# Add new tags to bag_of_tags array
			bag_of_tags=("${bag_of_tags[@]}" "${query}")
			echo ---bagOtags2---$bag_of_tags
                        if [[ -n $bag_of_tags ]]
                        then
                                while read -r line
                                do
                                        readLine=$line
					echo readLine---$readLine---
                                        intelliTagID=

 			

                                        while IFS='-' read  -r telliID telliName telliFloor telliType telliNote last
                                        do
         
						echo in loop

						telli_Id="$(echo -e "${telliID}" | sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//')"
						telli_Name="$(echo -e "${telliName}" | sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//')"
						telli_Floor="$(echo -e "${telliFloor//$/}" | sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//')"
						telli_Type="$(echo -e "${telliType//$/}" | sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//')"
						telli_Note="$(echo -e "${telliNote//$/}" | sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//')"
						echo
						echo "from telliTag telli_Id---"$telli_Id---
						echo "from telliTag telli_Name---"$telli_Name---
						echo "from telliTag telli_type---"$telli_Type---
						echo "from telliTag telli_Note---"$telli_Note---
						echo "from telliTag telli_Floor---"$telli_Floor---
						echo
						



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

						echo $telli_Name = $tag_Name 
                                               	echo $telli_Floor = $tag_Floor 
                                                echo $telli_Type = $tag_Type 
                                                echo $telli_Note = $tag_Note 

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
				
                                [[ -z $intelliTagID ]] && intelliTagID=$(${mysql_db}"INSERT INTO intelligentTags_TEST (name, publisherID, platformTagID)
                                        values (\"$tag_Name - \$$tag_Floor - $tag_Type - $tag_Note - IntelligentTag\", \"$publisherID\", \"$platformTag_ID\" );SELECT LAST_INSERT_ID();")

                        else
                                intelliTagID=$(${mysql_db}"INSERT INTO intelligentTags_TEST (name, publisherID, platformTagID) 
                                        VALUES (\"$tag_Name - \$$tag_Floor - $tag_Type - $tag_Note - IntelligentTag\", \"$publisherID\", \"$platformTag_ID\" );SELECT LAST_INSERT_ID();")
                        fi


			echo found_tag---$emptytag_inventorysources---       
        		echo tag---$tag_inventorysources--- 
        		echo tag_id---$tag_Id--- 
        		echo tag_name---$tag_Name--- 
        		echo tag_type---$tag_Type--- 
        		echo tag_floor---$tag_Floor---
        		echo tag_Note---$tag_Note--- 
        		echo publisherID---$publisherID--- 
			echo
			echo
        		echo telli_ID---$telli_Id--- 
        		echo telli_Name---$telli_Name--- 
        		echo telli_Floor---$telli_Floor--- 
        		echo telli_Type---$telli_Type--- 
        		echo telli_Note---$telli_Note--- 
			echo intellitagID---$intelliTagID---                      
        		echo platformTagID---$platformTag_ID--- 


#: <<'END'
			# Actual tag creation   
                        case "$tag_Type" in

				dt|DT|Desktop|DeskTop|desktop|platform*|Platform*|rev|Rev*|REV* )
                                       tag_creation=$(${mysql_db}"UPDATE inventorySources_TEST SET publisherID = $publisherID, intelligentTagID = $intelliTagID, \
                                                createdAt = CURDATE(), floor = "${tag_Floor}", isPlatformTag = "1" WHERE id = "${tag_Id}";")
                                        ;;

                                mw|MW|"Mobile Web"|"MovileWeb"|"mobile web"|"mobileweb"|platform*|Platform*|Rev*|rev* )
                                        tag_creation=$(${mysql_db}"UPDATE inventorySources_TEST SET publisherID = $publisherID, intelligentTagID = $intelliTagID, \
                                                createdAt = CURDATE(), floor = $tag_Floor, isMobile = "1", isMobileWeb = "1", isPlatformTag = "1" WHERE id = "${tag_Id}";")
                                        ;;

                                INAPP|InApp|inapp|"In App"|"in app" )
                                        tag_creation=$(${mysql_db}"UPDATE inventorySources_TEST SET publisherID = $publisherID, intelligentTagID = $intelliTagID, \
                                                createdAt = CURDATE(), floor = $tag_Floor, isMobile = "1", isMobileApp = "1", isPlatformTag = "1" WHERE id = "${tag_Id}";")
                                        ;;

                                ctv|CTV )
                                        tag_creation=$(${mysql_db}"UPDATE inventorySources_TEST SET publisherID = $publisherID, intelligentTagID = $intelliTagID, \
                                                createdAt = CURDATE(), floor = $tag_Floor, isPlatformTag = "1" WHERE id = "${tag_Id}";")
                                        ;;

                                 * )
                                        tag_creation=$(${mysql_db}"UPDATE inventorySources_TEST SET publisherID = $publisherID, intelligentTagID = $intelliTagID, \
                                                createdAt = CURDATE(), floor = $tag_Floor, isPlatformTag = "1" WHERE id = "${tag_Id}";")
                                        #tag_creation=$(${mysql_db}"UPDATE inventorySources_TEST SET publisherID = $publisherID  WHERE id = "${tag_Id}";")
                                        
					;;
                        esac
#END
                done <<< $emptytag_inventorysources
	
	
	
	fi


	# exit loop if cycle through more than 2 times
#	[[ $tagCounter -eq 1 ]] && exit || tagCounter=$((tagCounter + 1))

#	done
	echo publisherID---$publisherID---
	echo bagOtags---$bag_of_tags---
	
	}




check_for_empty_tag(){

	echo checking for empty tags
	emptytag=$(${mysql_db}"SELECT NULL FROM inventorySources_TEST WHERE publisherID IS NULL OR publisherID = '' OR publisherID = '0' LIMIT 1;")
	#emptytag=$(${mysql_db}"SELECT CONCAT(id, '-'), NAME FROM inventorySources_TEST WHERE publisherID IS NULL OR publisherID = '' OR publisherID = '0' LIMIT 1;")
	if [[ -n $emptytag ]]
	then
       		while [[ -n $emptytag ]]
       		do
               		create_tag
               		emptytag=$(${mysql_db}"SELECT NULL FROM inventorySources_TEST WHERE publisherID IS NULL OR publisherID = '' OR publisherID = '0' LIMIT 1;")
       		done
	fi

	return 0
	}

check_for_empty_tag 
