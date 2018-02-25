#!/bin/bash

##
#
#  runs all daily level processes
#
##

reapdate=$(date +%Y-%m-%d -d yesterday)
reapdateFormat=$(date +%m/%d/%Y -d yesterday)
path_sbin="/usr/local/sbin/"
path_pan="/home/ec2-user/data-integration/pan.sh "
path_kitchen="/home/ec2-user/data-integration/kitchen.sh "
path_ktr="/home/ec2-user/data-integration/epiphany_ktr/"
path_kjb="/home/ec2-user/data-integration/epiphany_kjb/"	
mysql_db="mysql --defaults-group-suffix=epiphanydb  -N -se " 
mysql_db2="mysql --defaults-group-suffix=kalturadb -N -e " 
mysql_db3="mysql --defaults-group-suffix=dailyprocess -N -se "
epiphany_daily_log="/home/ec2-user/Epiphany_logs/daily_process"
send_email="${path_kitchen}-file='${path_kjb}Daily_Processes_Error.kjb'"

dna_invsources(){
	dna_invsrccount=
	
	${path_sbin}dna_inventorysources.py
	dna_invsources=$(${mysql_db3}"SELECT NULL FROM dna_inventorysources WHERE DATE = "\'${reapdateFormat}\'"LIMIT 1")
	
	if [[ -z $dna_invsources ]];then
	while [[ -z $dna_invsources ]] && [[ $dna_invsrccount -lt 3 ]]
	do
		${path_sbin}dna_inventorysources.py
		dna_invsources=$(${mysql_db3}"SELECT NULL FROM dna_inventorysources WHERE DATE = "\'${reapdateFormat}\'"LIMIT 1")
		dna_invsrccount=$(($dna_invsrccount + 1))
	done
	fi

	[[ $dna_invsources == 'NULL' ]] && return 0
	
	}
		

dc_invsources(){
	dc_invsrccount=
	
	${path_sbin}dc_inventorysources.py
	dc_invsources=$(${mysql_db3}"SELECT NULL FROM dc_inventorysources WHERE DATE = "\'${reapdateFormat}\'"LIMIT 1")
	
	if [[ -z $dc_invsources ]];then
	while [[ -z $dc_invsources ]] && [[ $dc_invsrccount -lt 3 ]]
	do
		${path_sbin}dc_inventorysources.py
		dc_invsources=$(${mysql_db3}"SELECT NULL FROM dc_inventorysources WHERE DATE = "\'${reapdateFormat}\'"LIMIT 1")
		dc_invsrccount=$(($dc_invsrccount + 1))
	done
	fi

	[[ $dc_invsources == 'NULL' ]] && return 0
	
	}


adsym_invsources(){
	adsym_invsrccount=
	
	${path_sbin}adsym_inventorysources.py
	adsym_invsources=$(${mysql_db3}"SELECT NULL FROM adsym_inventorysources WHERE DATE = "\'${reapdateFormat}\'"LIMIT 1")
	
	if [[ -z $adsym_invsources ]];then
	while [[ -z $adsym_invsources ]] && [[ $adsym_invsrccount -lt 3 ]]
	do
		${path_sbin}adsym_inventorysources.py
		adsym_invsources=$(${mysql_db3}"SELECT NULL FROM adsym_inventorysources WHERE DATE = "\'${reapdateFormat}\'"LIMIT 1")
		adsym_invsrccount=$(($adsym_invsrccount + 1))
	done
	fi

	[[ $adsym_invsources == 'NULL' ]] && return 0
	
	}
		

adtrans_invsources(){
	adtrans_invsrccount=
	
	${path_sbin}adtrans_inventorysources.py
	adtrans_invsources=$(${mysql_db3}"SELECT NULL FROM adtrans_inventorysources WHERE DATE = "\'${reapdateFormat}\'"LIMIT 1")
	
	if [[ -z $adtrans_invsources ]];then
	while [[ -z $adtrans_invsources ]] && [[ $adtrans_invsrccount -lt 3 ]]
	do
		${path_sbin}adtrans_inventorysources.py
		adtrans_invsources=$(${mysql_db3}"SELECT NULL FROM adtrans_inventorysources WHERE DATE = "\'${reapdateFormat}\'"LIMIT 1")
		adtrans_invsrccount=$(($adtrans_invsrccount + 1))
	done
	fi

	[[ $adtrans_invsources == 'NULL' ]] && return 0
	
	}

tm_invsources(){
	tm_invsrccount=
	
	${path_sbin}tm_inventorysources.py
	tm_invsources=$(${mysql_db3}"SELECT NULL FROM tm_inventorysources WHERE DATE = "\'${reapdateFormat}\'"LIMIT 1")
	
	if [[ -z $tm_invsources ]];then
	while [[ -z $tm_invsources ]] && [[ $tm_invsrccount -lt 3 ]]
	do
		${path_sbin}tm_inventorysources.py
		tm_invsources=$(${mysql_db3}"SELECT NULL FROM tm_inventorysources WHERE DATE = "\'${reapdateFormat}\'"LIMIT 1")
		tm_invsrccount=$(($tm_invsrccount + 1))
	done
	fi
	
	[[ $tm_invsources == 'NULL' ]] && return 0
	
	}
		

springs_invsources(){
	springs_invsrccount=
	
	${path_sbin}springserve_inventorysources.py
	springs_invsources=$(${mysql_db3}"SELECT NULL FROM springserve_inventorysources WHERE DATE = "\'${reapdate}\'"LIMIT 1")
	
	if [[ -z $springs_invsources ]];then
	while [[ -z $springs_invsources ]] && [[ $springs_invsrccount -lt 3 ]]
	do
		${path_sbin}springserve_inventorysources.py
		springs_invsources=$(${mysql_db3}"SELECT NULL FROM springserve_inventorysources WHERE DATE = "\'${reapdate}\'"LIMIT 1")
		springs_invsrccount=$(($springs_invsrccount + 1))
	done
	fi

	[[ $springs_invsources == 'NULL' ]] && return 0
	
	}

dna_invreport(){
	dna_invreportcount=
	
	${path_sbin}dna_inventoryreport.py
	dna_invreport=$(${mysql_db3}"SELECT NULL FROM dna_inventoryreport WHERE DATE = "\'${reapdateFormat}\'"LIMIT 1")
	
	if [[ -z $dna_invreport ]];then
	while [[ -z $dna_invreport ]] && [[ $dna_invreportcount -lt 3 ]]
	do
		${path_sbin}dna_inventoryreport.py
		dna_invreport=$(${mysql_db3}"SELECT NULL FROM dna_inventoryreport WHERE DATE = "\'${reapdateFormat}\'"LIMIT 1")
		dna_invreportcount=$(($dna_invreportcount + 1))
	done
	fi

	[[ $dna_invreport == 'NULL' ]] && return 0
	

	}
		

dc_invreport(){
	dc_invreportcount=
	
	${path_sbin}dc_inventoryreport.py
	dc_invreport=$(${mysql_db3}"SELECT NULL FROM dc_inventoryreport WHERE DATE = "\'${reapdateFormat}\'"LIMIT 1")
	
	if [[ -z $dc_invreport ]];then
	while [[ -z $dc_invreport ]] && [[ $dc_invreportcount -lt 3 ]]
	do
		${path_sbin}dc_inventoryreport.py
		dc_invreport=$(${mysql_db3}"SELECT NULL FROM dc_inventoryreport WHERE DATE = "\'${reapdateFormat}\'"LIMIT 1")
		dc_invreportcount=$(($dc_invreportcount + 1))
	done
	fi

	[[ $dc_invreport == 'NULL' ]] && return 0
	
	}


adsym_invreport(){
	adsym_invreportcount=
	
	${path_sbin}adsym_inventoryreport.py
	adsym_invreport=$(${mysql_db3}"SELECT NULL FROM adsym_inventoryreport WHERE DATE = "\'${reapdateFormat}\'"LIMIT 1")
	
	if [[ -z $adsym_invreport ]];then
	while [[ -z $adsym_invreport ]] && [[ $adsym_invreportcount -lt 3 ]]
	do
		${path_sbin}adsym_inventoryreport.py
		adsym_invreport=$(${mysql_db3}"SELECT NULL FROM adsym_inventoryreport WHERE DATE = "\'${reapdateFormat}\'"LIMIT 1")
		adsym_invreportcount=$(($adsym_invreportcount + 1))
	done
	fi

	[[ $adsym_invreport == 'NULL' ]] && return 0
	
	}
		

adtrans_invreport(){
	adtrans_invreportcount=
	
	${path_sbin}adtrans_inventoryreport.py
	adtrans_invreport=$(${mysql_db3}"SELECT NULL FROM adtrans_inventoryreport WHERE DATE = "\'${reapdateFormat}\'"LIMIT 1")
		
	if [[ -z $adtrans_invreport ]];then
	while [[ -z $adtrans_invreport ]] && [[ $adtrans_invreportcount -lt 3 ]]
	do
		${path_sbin}adtrans_inventoryreport.py
		adtrans_invreport=$(${mysql_db3}"SELECT NULL FROM adtrans_inventoryreport WHERE DATE = "\'${reapdateFormat}\'"LIMIT 1")
		adtrans_invreportcount=$(($adtrans_invreportcount + 1))
	done
	fi

	[[ $adtrans_invreport == 'NULL' ]] && return 0
	
	}

tm_invreport(){
	tm_invreportcount=
	
	${path_sbin}tm_inventoryreport.py
	tm_invreport=$(${mysql_db3}"SELECT NULL FROM tm_inventoryreport WHERE DATE = "\'${reapdateFormat}\'"LIMIT 1")
	
	if [[ -z $tm_invreport ]];then
	while [[ -z $tm_invreport ]] && [[ $tm_invreportcount -lt 3 ]]
	do
		${path_sbin}tm_inventoryreport.py
		tm_invreport=$(${mysql_db3}"SELECT NULL FROM tm_inventoryreport WHERE DATE = "\'${reapdateFormat}\'"LIMIT 1")
		tm_invreportcount=$(($tm_invreportcount + 1))
	done
	fi

	[[ $tm_invreport == 'NULL' ]] && return 0
	
	}
		

springs_invreport(){
	springs_invreportcount=
	
	${path_sbin}springserve_inventoryreport.py
	springs_invreport=$(${mysql_db3}"SELECT NULL FROM springserve_inventoryreport WHERE DATE = "\'${reapdate}\'"LIMIT 1")
	
	if [[ -z $springs_invreport ]];then
	while [[ -z $springs_invreport ]] && [[ $springs_invreportcount -lt 3 ]]
	do
		${path_sbin}springserve_inventoryreport.py
		springs_invreport=$(${mysql_db3}"SELECT NULL FROM springserve_inventoryreport WHERE DATE = "\'${reapdate}\'"LIMIT 1")
		springs_invreportcount=$(($springs_invreportcount + 1))
	done
	fi

	[[ $springs_invreport == 'NULL' ]] && return 0
	
	}

dna_marketprivate(){
	dna_mprivatecount=
	
	${path_sbin}dna_market_private.py
	dna_mprivate=$(${mysql_db3}"SELECT NULL FROM dna_market_private WHERE DATE = "\'${reapdateFormat}\'"LIMIT 1")
	
	if [[ -z $dna_mprivate ]];then
	while [[ -z $dna_mprivate ]] && [[ $dna_mprivatecount -lt 3 ]]
	do
		${path_sbin}dna_market_private.py
		dna_mprivate=$(${mysql_db3}"SELECT NULL FROM dna_market_private WHERE DATE = "\'${reapdateFormat}\'"LIMIT 1")
		dna_mprivatecount=$(($dna_mprivatecount + 1))
	done
	fi

	[[ $dna_mprivate == 'NULL' ]] && return 0
	
	}
		

dc_marketprivate(){
	dc_mprivatecount=
	
	${path_sbin}dc_market_private.py
	dc_mprivate=$(${mysql_db3}"SELECT NULL FROM dc_market_private WHERE DATE = "\'${reapdateFormat}\'"LIMIT 1")
	
	if [[ -z $dc_mprivate ]];then
	while [[ -z $dc_mprivate ]] && [[ $dc_mprivatecount -lt 3 ]]
	do
		${path_sbin}dc_market_private.py
		dc_mprivate=$(${mysql_db3}"SELECT NULL FROM dc_market_private WHERE DATE = "\'${reapdateFormat}\'"LIMIT 1")
		dc_mprivatecount=$(($dc_mprivatecount + 1))
	done
	fi

	[[ $dc_mprivate == 'NULL' ]] && return 0
	
	}


adsym_marketprivate(){
	adsym_mprivatecount=
	
	${path_sbin}adsym_market_private.py
	adsym_mprivate=$(${mysql_db3}"SELECT NULL FROM adsym_market_private WHERE DATE = "\'${reapdateFormat}\'"LIMIT 1")
	
	if [[ -z $adsym_mprivate ]];then
	while [[ -z $adsym_mprivate ]] && [[ $adsym_mprivatecount -lt 3 ]]
	do
		${path_sbin}adsym_market_private.py
		adsym_mprivate=$(${mysql_db3}"SELECT NULL FROM adsym_market_private WHERE DATE = "\'${reapdateFormat}\'"LIMIT 1")
		adsym_mprivatecount=$(($adsym_mprivatecount + 1))
	done
	fi

	[[ $adsym_mprivate == 'NULL' ]]  && return 0
	
	}
		

adtrans_marketprivate(){
	adtrans_mprivatecount=
	
	${path_sbin}adtrans_market_private.py
	adtrans_mprivate=$(${mysql_db3}"SELECT NULL FROM adtrans_market_private WHERE DATE = "\'${reapdateFormat}\'"LIMIT 1")
	
	if [[ -z $adtrans_mprivate ]];then
	while [[ -z $adtrans_mprivate ]] && [[ $adtrans_mprivatecount -lt 3 ]]
	do
		${path_sbin}adtrans_market_private.py
		adtrans_mprivate=$(${mysql_db3}"SELECT NULL FROM adtrans_market_private WHERE DATE = "\'${reapdateFormat}\'"LIMIT 1")
		adtrans_mprivatecount=$(($adtrans_mprivatecount + 1))
	done
	fi

	[[ $adtrans_mprivate == 'NULL' ]] && return 0
	
	}

tm_marketprivate(){
	tm_mprivatecount=
	
	${path_sbin}tm_market_private.py
	tm_mprivate=$(${mysql_db3}"SELECT NULL FROM tm_market_private WHERE DATE = "\'${reapdateFormat}\'"LIMIT 1")
	
	if [[ -z $tm_mprivate ]];then
	while [[ -z $tm_mprivate ]] && [[ $tm_mprivatecount -lt 3 ]]
	do
		${path_sbin}tm_market_private.py
		tm_mprivate=$(${mysql_db3}"SELECT NULL FROM tm_market_private WHERE DATE = "\'${reapdateFormat}\'"LIMIT 1")
		tm_mprivatecount=$(($tm_mprivatecount + 1))
	done
	fi

	[[ $tm_mprivate == 'NULL' ]] && return 0
	
	}
		

springs_marketprivate(){
	springs_mprivatecount=
	
	${path_sbin}springserve_market_private.py
	springs_mprivate=$(${mysql_db3}"SELECT NULL FROM springserve_market_private WHERE DATE = "\'${reapdate}\'"LIMIT 1")
	
	if [[ -z $springs_mprivate ]];then
	while [[ -z $springs_mprivate ]] && [[ $springs_mprivatecount -lt 3 ]]
	do
		${path_sbin}springserve_market_private.py
		springs_mprivate=$(${mysql_db3}"SELECT NULL FROM springserve_market_private WHERE DATE = "\'${reapdate}\'"LIMIT 1")
		springs_mprivatecount=$(($springs_mprivatecount + 1))
	done
	fi

	[[ $springs_mprivate == 'NULL' ]] && return 0
	
	}

dna_marketpublic(){
	dna_mpubliccount=
	
	${path_sbin}dna_market_public.py
	dna_mpublic=$(${mysql_db3}"SELECT NULL FROM dna_market_public WHERE DATE = "\'${reapdateFormat}\'"LIMIT 1")
	
	if [[ -z $dna_mpublic ]];then
	while [[ -z $dna_mpublic ]] && [[ $dna_mpubliccount -lt 3 ]]
	do
		${path_sbin}dna_market_public.py
		dna_mpublic=$(${mysql_db3}"SELECT NULL FROM dna_market_public WHERE DATE = "\'${reapdateFormat}\'"LIMIT 1")
		dna_mpubliccount=$(($dna_mpubliccount + 1))
	done
	fi

	[[ $dna_mpublic == 'NULL' ]] && return 0
	
	}
		

dc_marketpublic(){
	dc_mpubliccount=
	
	${path_sbin}dc_market_public.py
	dc_mpublic=$(${mysql_db3}"SELECT NULL FROM dc_market_public WHERE DATE = "\'${reapdateFormat}\'"LIMIT 1")
	
	if [[ -z $dc_mpublic ]];then
	while [[ -z $dc_mpublic ]] && [[ $dc_mpubliccount -lt 3 ]]
	do
		${path_sbin}dc_market_public.py
		dc_mpublic=$(${mysql_db3}"SELECT NULL FROM dc_market_public WHERE DATE = "\'${reapdateFormat}\'"LIMIT 1")
		dc_mpubliccount=$(($dc_mpubliccountt + 1))
	done
	fi

	[[ $dc_mpublic == 'NULL' ]] && return 0
	
	}


adsym_marketpublic(){
	adsym_mpubliccount=
	
	${path_sbin}adsym_market_public.py
	adsym_mpublic=$(${mysql_db3}"SELECT NULL FROM adsym_market_public WHERE DATE = "\'${reapdateFormat}\'"LIMIT 1")
	
	if [[ -z $adsym_mpublic ]];then
	while [[ -z $adsym_mpublic ]] && [[ $adsym_mpubliccount -lt 3 ]]
	do
		${path_sbin}adsym_market_public.py
		adsym_mpublic=$(${mysql_db3}"SELECT NULL FROM adsym_market_public WHERE DATE = "\'${reapdateFormat}\'"LIMIT 1")
		adsym_mpubliccount=$(($adsym_mpubliccount + 1))
	done
	fi

	[[ $adsym_mpublic == 'NULL' ]] && return 0
	
	}
		

adtrans_marketpublic(){
	adtrans_mpubliccount=
	
	${path_sbin}adtrans_market_public.py
	adtrans_mpublic=$(${mysql_db3}"SELECT NULL FROM adtrans_market_public WHERE DATE = "\'${reapdateFormat}\'"LIMIT 1")
	
	if [[ -z $adtrans_mpublic ]];then
	while [[ -z $adtrans_mpublic ]] && [[ $adtrans_mpubliccount -lt 3 ]]
	do
		${path_sbin}adtrans_market_public.py
		adtrans_mpublic=$(${mysql_db3}"SELECT NULL FROM adtrans_market_public WHERE DATE = "\'${reapdateFormat}\'"LIMIT 1")
		adtrans_mpubliccount=$(($adtrans_mpubliccount + 1))
	done
	fi

	[[ $adtrans_mpublic == 'NULL' ]]  && return 0
	
	}

tm_marketpublic(){
	tm_mpubliccount=
	
	${path_sbin}tm_market_public.py
	tm_mpublic=$(${mysql_db3}"SELECT NULL FROM tm_market_public WHERE DATE = "\'${reapdateFormat}\'"LIMIT 1")
	
	if [[ -z $tm_mpublic ]];then
	while [[ -z $tm_mpublic ]] && [[ $tm_mpubliccount -lt 3 ]]
	do
		${path_sbin}tm_market_public.py
		tm_mpublic=$(${mysql_db3}"SELECT NULL FROM tm_market_public WHERE DATE = "\'${reapdateFormat}\'"LIMIT 1")
		tm_mpubliccount=$(($tm_mpubliccount + 1))
	done
	fi

	[[ $tm_mpublic == 'NULL' ]] && return 0
	
	}

create_tag(){
	        
        new_created_inventorysources=$(${mysql_db}"SELECT NAME FROM inventorySources WHERE publisherID is NULL OR publisherID = '';")
        emptytag_inventorysources=$(${mysql_db}"SELECT CONCAT(id, '-'), NAME FROM inventorySources WHERE publisherID is NULL OR publisherID = '' LIMIT 1;")
        tag_inventorysources=$(${mysql_db}"SELECT NAME FROM inventorySources WHERE publisherID is NULL OR publisherID = '' LIMIT 1;")
        
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

                        # If no intelligentTag, this creates intelligentTag####ADD IN platformTagID WHEN PLATFORM READY TO CONNECT == double quotes to keep \n
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
                        echo tag_$tag_inventorysources---
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

                        esac

                done <<< $emptytag_inventorysources
        fi

	}


check_tables_daily(){
	reports_InventorySource=$(${mysql_db} "SELECT NULL FROM reports_InventorySource  WHERE DATE ="\'${reapdate}\'"LIMIT 1") 
	reports_Marketplace=$(${mysql_db} "SELECT NULL FROM reports_Marketplace WHERE DATE ="\'${reapdate}\'"LIMIT 1") 
	test_Aggregate=$(${mysql_db} "SELECT NULL FROM test_Aggregate WHERE DATE ="\'${reapdate}\'"LIMIT 1") 
	test_Final=$(${mysql_db} "SELECT NULL FROM test_Final WHERE DATE ="\'${reapdate}\'"LIMIT 1") 
	}

	

# Launch Processes
if echo dna_inv && dna_invsources $1 &&
   echo dc_inv && dc_invsources $1 &&
   echo adsym_inv && adsym_invsources $1 &&
   echo tm_inv && tm_invsources $1 &&
   echo adtrans_inv && adtrans_invsources $1 &&
   echo springs_inv && springs_invsources $1 &&
   echo dna_inv && dna_invreport $1 &&
   echo dc_inv && dc_invreport $1 &&
   echo adsym_inv && adsym_invreport $1 &&
   echo tm_inv && tm_invreport $1 &&
   echo adtrans_inv && adtrans_invreport $1 &&
   echo springs_inv && springs_invreport $1 &&
   echo dna_pri && dna_marketprivate $1 &&
   echo dc_pri && dc_marketprivate $1 &&
   echo adsym_pri && adsym_marketprivate $1 &&
   echo tm_pri && tm_marketprivate $1 &&
   echo adtrans_pri && adtrans_marketprivate $1 &&
   echo springs_pri && springs_marketprivate $1 &&
   echo dna_pub && dna_marketpublic $1 &&
   echo dc_pub && dc_marketpublic $1 &&
   echo adsym_pub && adsym_marketpublic $1 &&
   echo tm_pub && tm_marketpublic $1 &&
   echo adtrans_pub && adtrans_marketpublic $1 
then
	#run daily_process_inventorysources
	${path_kitchen}-file="${path_kjb}daily_process_inventorysources_part1.kjb"

	emptytag=$(${mysql_db}"SELECT CONCAT(id, '-'), NAME FROM inventorySources WHERE publisherID IS NULL OR publisherID = '' OR publisherID = '0';")
	if [[ -n $emptytag ]]
	then
        	while [[ -n $emptytag ]]
        	do
                	create_tag
                	emptytag=$(${mysql_db}"SELECT CONCAT(id, '-'), NAME FROM inventorySources WHERE publisherID IS NULL OR publisherID = '' OR publisherID = '0' LIMIT 1;")
        	done
	fi
	
	# run slice and dice
#	${path_kitchen}-file="${path_kjb}daily_process_sliceNdice_part2.kjb"

fi

##send daily email
check_tables_daily

if [[ -n $reports_InventorySource ]] &&
   [[ -n $reports_Marketplace ]] &&
   [[ -n $test_Aggregate ]] &&
   [[ -n $test_Final ]]
then
#	${path_sbin}reportMonthly.sh
#	${path_sbin}reportMGNT.sy
	echo
fi
	
# Entry into Epiphany_logs		
current_time=$(date)
printf "\r\n ${current_time}--Morning processes completed successfully.  New tags created are: $new_created_inventorysources" >> ${epiphany_daily_log} 
