#!/bin/bash

####
##
## RUN TOTALS ON ALL PROCESSES TO GIVE OVERVIEW OF DATABASE
##
####
clear

# firstdaylastmonth="$(date --date "-0 month" +%Y-%m-01)"
TODAYSDATE_1=$(date +%Y-%m-%d)
TODAYSDATE_2=$(date +%m/%d/%Y)
YESTERDAYDATE_1=$(date +%Y-%m-%d -d yesterday)
YESTERDAYDATE_2=$(date +%m/%d/%Y -d yesterday)
LAST60_1=$(date "+%Y-%m-%d" --date="60 days ago")
LAST60_2=$(date "+%m/%d/%Y" --date="60 days ago")
YESTERDAY_HOUR="23"
#HOUR=$(date +%H)
#HOUR1=$($HOUR + 1)
mysql_db="mysql --defaults-group-suffix=epiphanydb -N -se"
mysql_db2="mysql --defaults-group-suffix=dailyprocess -N -se"
mysql_db3="mysql --defaults-group-suffix=sourcelevel -N -se"
BANNER_DATE=$(date "+%A %B %d,%Y")
BANNER_HOUR=$(date +%H)
u="$USER"


dna_sourcelevel() {
	echo "$(tput bold)$(tput setaf 5)__CURRENT REALTIME TOTALS PER ACCOUNT:__ $(tput sgr0)"

	dna_corel60=$(${mysql_db3} "SELECT NULL FROM dna_core_last60 WHERE date IN ("\'${TODAYSDATE_1}\'", "\'${TODAYSDATE_2}\'") LIMIT 1")
	[[ -n "${dna_corel60}" ]] && echo "$(tput setaf 3)dna_core_last60:$(tput sgr0)                       $(tput setaf 4)UPDATED $(tput sgr0)" || \
       	echo "$(tput setaf 3)dna_core_last60:$(tput sgr0)                       $(tput setaf 1)NOT UPDATED $(tput sgr0)"

	dna_coretoday=$(${mysql_db3} "SELECT hour FROM dna_core_today WHERE date IN ("\'${TODAYSDATE_1}\'", "\'${TODAYSDATE_2}\'") GROUP BY hour DESC LIMIT 1")
	[[ -n $dna_coretoday ]] && echo "$(tput setaf 3)dna_core_today:$(tput sgr0)                          $(tput setaf 3)${dna_coretoday}$(tput sgr0)$(tput bold)$(tput setaf 4)h$(tput sgr0)" || \
	echo "$(tput setaf 3)dna_core_today:$(tput sgr0)                        $(tput setaf 1)NOT UPDATED $(tput sgr0)"

	dna_coretodaymedia=$(${mysql_db3} "SELECT hour FROM dna_core_today_media where date IN ("\'${TODAYSDATE_1}\'", "\'${TODAYSDATE_2}\'") GROUP BY hour DESC LIMIT 1")
	[[ -n "${dna_coretodaymedia}" ]] && echo "$(tput setaf 3)dna_core_today_media:$(tput sgr0)                    $(tput setaf 3)${dna_coretodaymedia}$(tput sgr0)$(tput bold)$(tput setaf 4)h$(tput sgr0)" || \
	echo "$(tput setaf 3)dna_core_today_media:$(tput sgr0)                  $(tput setaf 1)NOT UPDATED $(tput sgr0)"

	dna_coreyesterday=$(${mysql_db3}"SELECT hour FROM dna_core_yesterday WHERE DATE IN ("\'${YESTERDAYDATE_1}\'", "\'${YESTERDAYDATE_2}\'") GROUP BY hour DESC LIMIT 1")
	[[ "${dna_coreyesterday}" -eq "${YESTERDAY_HOUR}" ]] && echo "$(tput setaf 3)dna_core_yesterday:$(tput sgr0)                    $(tput setaf 4)UPDATED $(tput sgr0)" || \
	echo "$(tput setaf 3)dna_core_yesterday:$(tput sgr0)                    $(tput setaf 1)NOT UPDATED $(tput sgr0)"

	dna_coreyesterdaymedia=$(${mysql_db3} "SELECT hour FROM dna_core_yesterday_media WHERE DATE IN ("\'${YESTERDAYDATE_1}\'", "\'${YESTERDAYDATE_2}\'") GROUP BY hour DESC LIMIT 1")
	[[ "${dna_coreyesterdaymedia}" -eq "${YESTERDAY_HOUR}" ]] && echo "$(tput setaf 3)dna_core_yesterday_media:$(tput sgr0)              $(tput setaf 4)UPDATED $(tput sgr0)" || \
	echo "$(tput setaf 3)dna_core_yesterday_media:$(tput sgr0)              $(tput setaf 1)NOT UPDATED $(tput sgr0)"

	dna_marketl60=$(${mysql_db3} "SELECT NULL FROM dna_market_last60 WHERE date IN ("\'${YESTERDAYDATE_1}\'", "\'${YESTERDAYDATE_2}\'") LIMIT 1")
	[[ -n "${dna_marketl60}" ]] && echo "$(tput setaf 3)dna_market_last60:$(tput sgr0)                     $(tput setaf 4)UPDATED $(tput sgr0)" || \
	echo "$(tput setaf 3)dna_market_last60:$(tput sgr0)                     $(tput setaf 1)NOT UPDATED $(tput sgr0)"

	dna_markettoday=$(${mysql_db3} "SELECT hour FROM dna_market_today WHERE date IN ("\'${TODAYSDATE_1}\'", "\'${TODAYSDATE_2}\'") GROUP BY hour DESC LIMIT 1")
	[[ -n "${dna_markettoday}" ]] && echo "$(tput setaf 3)dna_market_today:$(tput sgr0)                        $(tput setaf 3)${dna_markettoday}$(tput sgr0)$(tput bold)$(tput setaf 4)h$(tput sgr0)" || \
	echo "$(tput setaf 3)dna_market_today:$(tput sgr0)                      $(tput setaf 1)NOT UPDATED $(tput sgr0)"

	dna_marketyesterday=$(${mysql_db3} "SELECT hour FROM dna_market_yesterday WHERE DATE IN ("\'${YESTERDAYDATE_1}\'", "\'${YESTERDAYDATE_2}\'") GROUP BY HOUR DESC LIMIT 1")
	[[ "${dna_marketyesterday}" -eq "${YESTERDAY_HOUR}" ]] && echo "$(tput setaf 3)dna_market_yesterday:$(tput sgr0)                  $(tput setaf 4)UPDATED $(tput sgr0)" || \
	echo "$(tput setaf 3)dna_market_yesterday:$(tput sgr0)                  $(tput setaf 1)NOT UPDATED $(tput sgr0)"

	echo
	}


dc_sourcelevel() {

	dc_corel60=$(${mysql_db3} "SELECT NULL FROM dc_core_last60 WHERE date IN ("\'${TODAYSDATE_1}\'", "\'${TODAYSDATE_2}\'") LIMIT 1")
	[[ -n "${dc_corel60}" ]] && echo "$(tput setaf 3)dc_core_last60:$(tput sgr0)                        $(tput setaf 4)UPDATED $(tput sgr0)" || \
       	echo "$(tput setaf 3)dc_core_last60:$(tput sgr0)                        $(tput setaf 1)NOT UPDATED $(tput sgr0)"

	dc_coretoday=$(${mysql_db3} "SELECT hour FROM dc_core_today WHERE date IN ("\'${TODAYSDATE_1}\'", "\'${TODAYSDATE_2}\'") GROUP BY hour DESC LIMIT 1")
	[[ -n $dc_coretoday ]] && echo "$(tput setaf 3)dc_core_today:$(tput sgr0)                           $(tput setaf 3)${dc_coretoday}$(tput sgr0)$(tput bold)$(tput setaf 4)h$(tput sgr0)" || \
	echo "$(tput setaf 3)dc_core_today:$(tput sgr0)                         $(tput setaf 1)NOT UPDATED $(tput sgr0)"

	dc_coretodaymedia=$(${mysql_db3} "SELECT hour FROM dc_core_today_media where date IN ("\'${TODAYSDATE_1}\'", "\'${TODAYSDATE_2}\'") GROUP BY hour DESC LIMIT 1")
	[[ -n "${dc_coretodaymedia}" ]] && echo "$(tput setaf 3)dc_core_today_media:$(tput sgr0)                     $(tput setaf 3)${dc_coretodaymedia}$(tput sgr0)$(tput bold)$(tput setaf 4)h$(tput sgr0)" || \
	echo "$(tput setaf 3)dc_core_today_media:$(tput sgr0)                   $(tput setaf 1)NOT UPDATED $(tput sgr0)"

	dc_coreyesterday=$(${mysql_db3}"SELECT hour FROM dc_core_yesterday WHERE DATE IN ("\'${YESTERDAYDATE_1}\'", "\'${YESTERDAYDATE_2}\'") GROUP BY hour DESC LIMIT 1")
	[[ "${dc_coreyesterday}" -eq "${YESTERDAY_HOUR}" ]] && echo "$(tput setaf 3)dc_core_yesterday:$(tput sgr0)                     $(tput setaf 4)UPDATED $(tput sgr0)" || \
	echo "$(tput setaf 3)dc_core_yesterday:$(tput sgr0)                     $(tput setaf 1)NOT UPDATED $(tput sgr0)"

	dc_coreyesterdaymedia=$(${mysql_db3} "SELECT hour FROM dc_core_yesterday_media WHERE DATE IN ("\'${YESTERDAYDATE_1}\'", "\'${YESTERDAYDATE_2}\'") GROUP BY hour DESC LIMIT 1")
	[[ "${dc_coreyesterdaymedia}" -eq "${YESTERDAY_HOUR}" ]] && echo "$(tput setaf 3)dc_core_yesterday_media:$(tput sgr0)               $(tput setaf 4)UPDATED $(tput sgr0)" || \
	echo "$(tput setaf 3)dc_core_yesterday_media:$(tput sgr0)               $(tput setaf 1)NOT UPDATED $(tput sgr0)"

	dc_marketl60=$(${mysql_db3} "SELECT NULL FROM dc_market_last60 WHERE date IN ("\'${YESTERDAYDATE_1}\'", "\'${YESTERDAYDATE_2}\'") LIMIT 1")
	[[ -n "${dc_marketl60}" ]] && echo "$(tput setaf 3)dc_market_last60:$(tput sgr0)                      $(tput setaf 4)UPDATED $(tput sgr0)" || \
	echo "$(tput setaf 3)dc_market_last60:$(tput sgr0)                      $(tput setaf 1)NOT UPDATED $(tput sgr0)"

	dc_markettoday=$(${mysql_db3} "SELECT hour FROM dc_market_today WHERE date IN ("\'${TODAYSDATE_1}\'", "\'${TODAYSDATE_2}\'") GROUP BY hour DESC LIMIT 1")
	[[ -n "${dc_markettoday}" ]] && echo "$(tput setaf 3)dc_market_today:$(tput sgr0)                         $(tput setaf 3)${dc_markettoday}$(tput sgr0)$(tput bold)$(tput setaf 4)h$(tput sgr0)" || \
	echo "$(tput setaf 3)dc_market_today:$(tput sgr0)              $(tput setaf 1)NOT UPDATED $(tput sgr0)"

	dc_marketyesterday=$(${mysql_db3} "SELECT hour FROM dc_market_yesterday WHERE DATE IN ("\'${YESTERDAYDATE_1}\'", "\'${YESTERDAYDATE_2}\'") GROUP BY HOUR DESC LIMIT 1")
	[[ "${dc_marketyesterday}" -eq "${YESTERDAY_HOUR}" ]] && echo "$(tput setaf 3)dc_market_yesterday:$(tput sgr0)                   $(tput setaf 4)UPDATED $(tput sgr0)" || \
	echo "$(tput setaf 3)dc_market_yesterday:$(tput sgr0)                   $(tput setaf 1)NOT UPDATED $(tput sgr0)"

	echo
	}


adsym_sourcelevel() {

	adsym_corel60=$(${mysql_db3} "SELECT NULL FROM adsym_core_last60 WHERE date IN ("\'${TODAYSDATE_1}\'", "\'${TODAYSDATE_2}\'") LIMIT 1")
	[[ -n "${adsym_corel60}" ]] && echo "$(tput setaf 3)adsym_core_last60:$(tput sgr0)                     $(tput setaf 4)UPDATED $(tput sgr0)" || \
       	echo "$(tput setaf 3)adsym_core_last60:$(tput sgr0)                     $(tput setaf 1)NOT UPDATED $(tput sgr0)"

	adsym_coretoday=$(${mysql_db3} "SELECT hour FROM adsym_core_today WHERE date IN ("\'${TODAYSDATE_1}\'", "\'${TODAYSDATE_2}\'") GROUP BY hour DESC LIMIT 1")
	[[ -n $adsym_coretoday ]] && echo "$(tput setaf 3)adsym_core_today:$(tput sgr0)                        $(tput setaf 3)${adsym_coretoday}$(tput sgr0)$(tput bold)$(tput setaf 4)h$(tput sgr0)" || \
	echo "$(tput setaf 3)adsym_core_today:$(tput sgr0)                      $(tput setaf 1)NOT UPDATED $(tput sgr0)"

	adsym_coretodaymedia=$(${mysql_db3} "SELECT hour FROM adsym_core_today_media where date IN ("\'${TODAYSDATE_1}\'", "\'${TODAYSDATE_2}\'") GROUP BY hour DESC LIMIT 1")
	[[ -n "${adsym_coretodaymedia}" ]] && echo "$(tput setaf 3)adsym_core_today_media:$(tput sgr0)                  $(tput setaf 3)${adsym_coretodaymedia}$(tput sgr0)$(tput bold)$(tput setaf 4)h$(tput sgr0)" || \
	echo "$(tput setaf 3)adsym_core_today_media:$(tput sgr0)                $(tput setaf 1)NOT UPDATED $(tput sgr0)"

	adsym_coreyesterday=$(${mysql_db3}"SELECT hour FROM adsym_core_yesterday WHERE DATE IN ("\'${YESTERDAYDATE_1}\'", "\'${YESTERDAYDATE_2}\'") GROUP BY hour DESC LIMIT 1")
	[[ "${adsym_coreyesterday}" -eq "${YESTERDAY_HOUR}" ]] && echo "$(tput setaf 3)adsym_core_yesterday:$(tput sgr0)                  $(tput setaf 4)UPDATED $(tput sgr0)" || \
	echo "$(tput setaf 3)adsym_core_yesterday:$(tput sgr0)                  $(tput setaf 1)NOT UPDATED $(tput sgr0)"

	adsym_coreyesterdaymedia=$(${mysql_db3} "SELECT hour FROM adsym_core_yesterday_media WHERE DATE IN ("\'${YESTERDAYDATE_1}\'", "\'${YESTERDAYDATE_2}\'") GROUP BY hour DESC LIMIT 1")
	[[ "${adsym_coreyesterdaymedia}" -eq "${YESTERDAY_HOUR}" ]] && echo "$(tput setaf 3)adsym_core_yesterday_media:$(tput sgr0)            $(tput setaf 4)UPDATED $(tput sgr0)" || \
	echo "$(tput setaf 3)adsym_core_yesterday_media:$(tput sgr0)            $(tput setaf 1)NOT UPDATED $(tput sgr0)"

	adsym_marketl60=$(${mysql_db3} "SELECT NULL FROM adsym_market_last60 WHERE date IN ("\'${YESTERDAYDATE_1}\'", "\'${YESTERDAYDATE_2}\'") LIMIT 1")
	[[ -n "${adsym_marketl60}" ]] && echo "$(tput setaf 3)adsym_market_last60:$(tput sgr0)                   $(tput setaf 4)UPDATED $(tput sgr0)" || \
	echo "$(tput setaf 3)adsym_market_last60:$(tput sgr0)             $(tput setaf 1)NOT UPDATED $(tput sgr0)"

	adsym_markettoday=$(${mysql_db3} "SELECT hour FROM adsym_market_today WHERE date IN ("\'${TODAYSDATE_1}\'", "\'${TODAYSDATE_2}\'") GROUP BY hour DESC LIMIT 1")
	[[ -n "${adsym_markettoday}" ]] && echo "$(tput setaf 3)adsym_market_today:$(tput sgr0)                      $(tput setaf 3)${adsym_markettoday}$(tput sgr0)$(tput bold)$(tput setaf 4)h$(tput sgr0)" || \
	echo "$(tput setaf 3)adsym_market_today:$(tput sgr0)                    $(tput setaf 1)NOT UPDATED $(tput sgr0)"

	adsym_marketyesterday=$(${mysql_db3} "SELECT hour FROM adsym_market_yesterday WHERE DATE IN ("\'${YESTERDAYDATE_1}\'", "\'${YESTERDAYDATE_2}\'") GROUP BY HOUR DESC LIMIT 1")
	[[ "${adsym_marketyesterday}" -eq "${YESTERDAY_HOUR}" ]] && echo "$(tput setaf 3)adsym_market_yesterday:$(tput sgr0)                $(tput setaf 4)UPDATED $(tput sgr0)" || \
	echo "$(tput setaf 3)adsym_market_yesterday:$(tput sgr0)                $(tput setaf 1)NOT UPDATED $(tput sgr0)"

	echo
	}


tm_sourcelevel() {

	tm_corel60=$(${mysql_db3} "SELECT NULL FROM tm_core_last60 WHERE date IN ("\'${TODAYSDATE_1}\'", "\'${TODAYSDATE_2}\'") LIMIT 1")
	[[ -n "${tm_corel60}" ]] && echo "$(tput setaf 3)tm_core_last60:$(tput sgr0)                        $(tput setaf 4)UPDATED $(tput sgr0)" || \
       	echo "$(tput setaf 3)tm_core_last60:$(tput sgr0)               $(tput setaf 1)NOT UPDATED $(tput sgr0)"

	tm_coretoday=$(${mysql_db3} "SELECT hour FROM tm_core_today WHERE date IN ("\'${TODAYSDATE_1}\'", "\'${TODAYSDATE_2}\'") GROUP BY hour DESC LIMIT 1")
	[[ -n $tm_coretoday ]] && echo "$(tput setaf 3)tm_core_today:$(tput sgr0)                           $(tput setaf 3)${tm_coretoday}$(tput sgr0)$(tput bold)$(tput setaf 4)h$(tput sgr0)" || \
	echo "$(tput setaf 3)tm_core_today:$(tput sgr0)                         $(tput setaf 1)NOT UPDATED $(tput sgr0)"

	tm_coretodaymedia=$(${mysql_db3} "SELECT hour FROM tm_core_today_media where date IN ("\'${TODAYSDATE_1}\'", "\'${TODAYSDATE_2}\'") GROUP BY hour DESC LIMIT 1")
	[[ -n "${tm_coretodaymedia}" ]] && echo "$(tput setaf 3)tm_core_today_media:$(tput sgr0)                     $(tput setaf 3)${tm_coretodaymedia}$(tput sgr0)$(tput bold)$(tput setaf 4)h$(tput sgr0)" || \
	echo "$(tput setaf 3)tm_core_today_media:$(tput sgr0)                   $(tput setaf 1)NOT UPDATED $(tput sgr0)"

	tm_coreyesterday=$(${mysql_db3}"SELECT hour FROM tm_core_yesterday WHERE DATE IN ("\'${YESTERDAYDATE_1}\'", "\'${YESTERDAYDATE_2}\'") GROUP BY hour DESC LIMIT 1")
	[[ "${tm_coreyesterday}" -eq "${YESTERDAY_HOUR}" ]] && echo "$(tput setaf 3)tm_core_yesterday:$(tput sgr0)                     $(tput setaf 4)UPDATED $(tput sgr0)" || \
	echo "$(tput setaf 3)tm_core_yesterday:$(tput sgr0)                     $(tput setaf 1)NOT UPDATED $(tput sgr0)"

	tm_coreyesterdaymedia=$(${mysql_db3} "SELECT hour FROM tm_core_yesterday_media WHERE DATE IN ("\'${YESTERDAYDATE_1}\'", "\'${YESTERDAYDATE_2}\'") GROUP BY hour DESC LIMIT 1")
	[[ "${tm_coreyesterdaymedia}" -eq "${YESTERDAY_HOUR}" ]] && echo "$(tput setaf 3)tm_core_yesterday_media:$(tput sgr0)               $(tput setaf 4)UPDATED $(tput sgr0)" || \
	echo "$(tput setaf 3)tm_core_yesterday_media:$(tput sgr0)               $(tput setaf 1)NOT UPDATED $(tput sgr0)"

	tm_marketl60=$(${mysql_db3} "SELECT NULL FROM tm_market_last60 WHERE date IN ("\'${YESTERDAYDATE_1}\'", "\'${YESTERDAYDATE_2}\'") LIMIT 1")
	[[ -n "${tm_marketl60}" ]] && echo "$(tput setaf 3)tm_market_last60:$(tput sgr0)                      $(tput setaf 4)UPDATED $(tput sgr0)" || \
	echo "$(tput setaf 3)tm_market_last60:$(tput sgr0)                      $(tput setaf 1)NOT UPDATED $(tput sgr0)"

	tm_markettoday=$(${mysql_db3} "SELECT hour FROM tm_market_today WHERE date IN ("\'${TODAYSDATE_1}\'", "\'${TODAYSDATE_2}\'") GROUP BY hour DESC LIMIT 1")
	[[ -n "${tm_markettoday}" ]] && echo "$(tput setaf 3)tm_market_today:$(tput sgr0)                         $(tput setaf 3)${tm_markettoday}$(tput sgr0)$(tput bold)$(tput setaf 4)h$(tput sgr0)" || \
	echo "$(tput setaf 3)tm_market_today:$(tput sgr0)                       $(tput setaf 1)NOT UPDATED $(tput sgr0)"

	tm_marketyesterday=$(${mysql_db3} "SELECT hour FROM tm_market_yesterday WHERE DATE IN ("\'${YESTERDAYDATE_1}\'", "\'${YESTERDAYDATE_2}\'") GROUP BY HOUR DESC LIMIT 1")
	[[ "${tm_marketyesterday}" -eq "${YESTERDAY_HOUR}" ]] && echo "$(tput setaf 3)tm_market_yesterday:$(tput sgr0)                   $(tput setaf 4)UPDATED $(tput sgr0)" || \
	echo "$(tput setaf 3)tm_market_yesterday:$(tput sgr0)                   $(tput setaf 1)NOT UPDATED $(tput sgr0)"

	echo
	}

adtrans_sourcelevel() {

	adtrans_corel60=$(${mysql_db3} "SELECT NULL FROM adtrans_core_last60 WHERE date IN ("\'${TODAYSDATE_1}\'", "\'${TODAYSDATE_2}\'") LIMIT 1")
	[[ -n "${adtrans_corel60}" ]] && echo "$(tput setaf 3)adtrans_core_last60:$(tput sgr0)                   $(tput setaf 4)UPDATED $(tput sgr0)" || \
       	echo "$(tput setaf 3)adtrans_core_last60:$(tput sgr0)               $(tput setaf 1)NOT UPDATED $(tput sgr0)"

	adtrans_coretoday=$(${mysql_db3} "SELECT hour FROM adtrans_core_today WHERE date IN ("\'${TODAYSDATE_1}\'", "\'${TODAYSDATE_2}\'") GROUP BY hour DESC LIMIT 1")
	[[ -n $adtrans_coretoday ]] && echo "$(tput setaf 3)adtrans_core_today:$(tput sgr0)                      $(tput setaf 3)${adtrans_coretoday}$(tput sgr0)$(tput bold)$(tput setaf 4)h$(tput sgr0)" || \
	echo "$(tput setaf 3)adtrans_core_today:$(tput sgr0)                    $(tput setaf 1)NOT UPDATED $(tput sgr0)"

	adtrans_coretodaymedia=$(${mysql_db3} "SELECT hour FROM adtrans_core_today_media where date IN ("\'${TODAYSDATE_1}\'", "\'${TODAYSDATE_2}\'") GROUP BY hour DESC LIMIT 1")
	[[ -n "${adtrans_coretodaymedia}" ]] && echo "$(tput setaf 3)adtrans_core_today_media:$(tput sgr0)                $(tput setaf 3)${adtrans_coretodaymedia}$(tput sgr0)$(tput bold)$(tput setaf 4)h$(tput sgr0)" || \
	echo "$(tput setaf 3)adtrans_core_today_media:$(tput sgr0)              $(tput setaf 1)NOT UPDATED $(tput sgr0)"

	adtrans_coreyesterday=$(${mysql_db3}"SELECT hour FROM adtrans_core_yesterday WHERE DATE IN ("\'${YESTERDAYDATE_1}\'", "\'${YESTERDAYDATE_2}\'") GROUP BY hour DESC LIMIT 1")
	[[ "${adtrans_coreyesterday}" -eq "${YESTERDAY_HOUR}" ]] && echo "$(tput setaf 3)adtrans_core_yesterday:$(tput sgr0)                $(tput setaf 4)UPDATED $(tput sgr0)" || \
	echo "$(tput setaf 3)adtrans_core_yesterday:$(tput sgr0)                $(tput setaf 1)NOT UPDATED $(tput sgr0)"

	adtrans_coreyesterdaymedia=$(${mysql_db3} "SELECT hour FROM adtrans_core_yesterday_media WHERE DATE IN ("\'${YESTERDAYDATE_1}\'", "\'${YESTERDAYDATE_2}\'") GROUP BY hour DESC LIMIT 1")
	[[ "${adtrans_coreyesterdaymedia}" -eq "${YESTERDAY_HOUR}" ]] && echo "$(tput setaf 3)adtrans_core_yesterday_media:$(tput sgr0)          $(tput setaf 4)UPDATED $(tput sgr0)" || \
	echo "$(tput setaf 3)adtrans_core_yesterday_media:$(tput sgr0)          $(tput setaf 1)NOT UPDATED $(tput sgr0)"

	adtrans_marketl60=$(${mysql_db3} "SELECT NULL FROM adtrans_market_last60 WHERE date IN ("\'${YESTERDAYDATE_1}\'", "\'${YESTERDAYDATE_2}\'") LIMIT 1")
	[[ -n "${adtrans_marketl60}" ]] && echo "$(tput setaf 3)adtrans_market_last60:$(tput sgr0)                 $(tput setaf 4)UPDATED $(tput sgr0)" || \
	echo "$(tput setaf 3)adtrans_market_last60:$(tput sgr0)             $(tput setaf 1)NOT UPDATED $(tput sgr0)"

	adtrans_markettoday=$(${mysql_db3} "SELECT hour FROM adtrans_market_today WHERE date IN ("\'${TODAYSDATE_1}\'", "\'${TODAYSDATE_2}\'") GROUP BY hour DESC LIMIT 1")
	[[ -n "${adtrans_markettoday}" ]] && echo "$(tput setaf 3)adtrans_market_today:$(tput sgr0)                    $(tput setaf 3)${adtrans_markettoday}$(tput sgr0)$(tput bold)$(tput setaf 4)h$(tput sgr0)" || \
	echo "$(tput setaf 3)adtrans_market_today:$(tput sgr0)                  $(tput setaf 1)NOT UPDATED $(tput sgr0)"

	adtrans_marketyesterday=$(${mysql_db3} "SELECT hour FROM adtrans_market_yesterday WHERE DATE IN ("\'${YESTERDAYDATE_1}\'", "\'${YESTERDAYDATE_2}\'") GROUP BY HOUR DESC LIMIT 1")
	[[ "${adtrans_marketyesterday}" -eq "${YESTERDAY_HOUR}" ]] && echo "$(tput setaf 3)adtrans_market_yesterday:$(tput sgr0)              $(tput setaf 4)UPDATED $(tput sgr0)" || \
	echo "$(tput setaf 3)adtrans_market_yesterday:$(tput sgr0)              $(tput setaf 1)NOT UPDATED $(tput sgr0)"

	echo
	}


springs_sourcelevel() {
	springs_corel60=$(${mysql_db3} "SELECT NULL FROM springserve_core_last60 WHERE DATE IN ("\'${TODAYSDATE_1}\'", "\'${TODAYSDATE_2}\'") LIMIT 1")
	[[ -n "${springs_corel60}" ]] && echo "$(tput setaf 3)springs_core_last60:$(tput sgr0)                   $(tput setaf 4)UPDATED $(tput sgr0)" || \
	echo "$(tput setaf 3)springs_core_last60:$(tput sgr0)                   $(tput setaf 1)NOT UPDATED $(tput sgr0)"
	
	springs_coretoday=$(${mysql_db3} "SELECT hour FROM springserve_core_today WHERE DATE IN ("\'${TODAYSDATE_1}\'", "\'${TODAYSDATE_2}\'") GROUP BY hour DESC LIMIT 1")
	[[ -n "${springs_coretoday}" ]] && echo "$(tput setaf 3)springs_core_today:$(tput sgr0)                      $(tput setaf 3)${springs_coretoday}$(tput sgr0)$(tput bold)$(tput setaf 4)h$(tput sgr0)" || \
	echo "$(tput setaf 3)springs_coretoday:$(tput sgr0)                     $(tput setaf 1)NOT UPDATED $(tput sgr0)"
	
	springs_markettoday=$(${mysql_db3} "SELECT hour FROM springserve_market_today WHERE DATE IN ("\'${TODAYSDATE_1}\'", "\'${TODAYSDATE_2}\'") GROUP BY HOUR DESC LIMIT 1")
	[[ -n ${springs_markettoday} ]] && echo "$(tput setaf 3)springs_market_today:$(tput sgr0)                    $(tput setaf 3)${springs_markettoday}$(tput sgr0)$(tput bold)$(tput setaf 4)h$(tput sgr0)" || \
	echo "$(tput setaf 3)springs_markettoday:$(tput sgr0)                   $(tput setaf 1)NOT UPDATED $(tput sgr0)"

	springs_coreyesterday=$(${mysql_db3} "SELECT hour FROM springserve_core_yesterday WHERE DATE IN ("\'${YESTERDAYDATE_1}\'", "\'${YESTERDAYDATE_2}\'") GROUP BY hour DESC LIMIT 1")
	[[ "${springs_coreyesterday}" -eq "${YESTERDAY_HOUR}" ]] && echo "$(tput setaf 3)springs_core_yesterday:$(tput sgr0)                $(tput setaf 4)UPDATED $(tput sgr0)" || \
	echo "$(tput setaf 3)springs_core_yesterday:$(tput sgr0)                $(tput setaf 1)NOT UPDATED $(tput sgr0)"


	}




yesterday_totals_per_account_domain() {

	tput cup 2 165; echo "$(tput bold)$(tput setaf 5)__YESTERDAY TOTAL REVENUE DOMAIN LEVEL__$(tput sgr0)"

	dna_v2_Server=$(${mysql_db} "SELECT SUM(adRevenue) FROM V2_Server WHERE DATE IN ("\'${YESTERDAYDATE_1}\'", "\'${YESTERDAYDATE_2}\'") AND platformID = 1")

	echo $dna_v2_Server
#	[[ $dna_v2_Server = 'NULL' ]] && dna_v2_Server="0.00"
#	tput cup 3 165
#	(( $(bc <<< "$dna_v2_Server > 0") )) && echo "$(tput setaf 3)dna_v2_Server total:$(tput sgr0)     \$$dna_v2_Server" || \
#	echo "$(tput setaf 3)dna_v2_Server total:$(tput sgr0)     $(tput setaf 1)NOT UPDATED $(tput sgr0)"

#	dc_v2_Server=$(${mysql_db} "SELECT SUM(adRevenue) FROM V2_Server WHERE DATE IN ("\'${YESTERDAYDATE_1}\'", "\'${YESTERDAYDATE_2}\'") AND platformID = 2")
#	[[ $dc_v2_Server = 'NULL' ]] && dc_v2_Server="0.00"
#	tput cup 4 165
#	(( $(bc <<< " $dc_v2_Server > 0") )) && echo "$(tput setaf 3)dc_v2_Server total:$(tput sgr0)      \$$dc_v2_Server" || \
#	echo "$(tput setaf 3)dc_v2_Server total:$(tput sgr0)      $(tput setaf 1)NOT UPDATED $(tput sgr0)"
#
#	adsym_v2_Server=$(${mysql_db} "SELECT SUM(adRevenue) FROM V2_Server WHERE DATE IN("\'${YESTERDAYDATE_1}\'", "\'${YESTERDAYDATE_2}\'") AND platformID = 4")
#	[[ $adsym_v2_Server = 'NULL' ]] && adsym_v2_Server="0.00"
#	tput cup 5 165
#	(( $(bc <<< " $adsym_v2_Server > 0") ))	&& echo "$(tput setaf 3)adsym_v2_Server total:$(tput sgr0)   \$$adsym_v2_Server" || \
#	echo "$(tput setaf 3)adsym_v2_Server total:$(tput sgr0)   $(tput setaf 1)NOT UPDATED $(tput sgr0)"
#
#	tm_v2_Server=$(${mysql_db} "SELECT SUM(adRevenue) FROM V2_Server WHERE DATE IN ("\'${YESTERDAYDATE_1}\'", "\'${YESTERDAYDATE_2}\'") AND platformID = 5")
#	[[ $tm_v2_Server = 'NULL' ]] && tm_v2_Server="0.00"
#	tput cup 6 165
#	(( $(bc <<< "$tm_v2_Server > 0") )) && echo "$(tput setaf 3)tm_v2_Server total:$(tput sgr0)      \$$tm_v2_Server" || \
#	echo "$(tput setaf 3)tm_v2_Server total:$(tput sgr0)      $(tput setaf 1)NOT UPDATED $(tput sgr0)"
#
#	adtrans_v2_Server=$(${mysql_db} "SELECT SUM(adRevenue) FROM V2_Server WHERE DATE IN ("\'${YESTERDAYDATE_1}\'", "\'${YESTERDAYDATE_2}\'") AND platformID = 6")
#	[[ $adtrans_v2_Server = 'NULL' ]] && adtrans_v2_Server="0.00"
#	tput cup 7 165
#	(( $(bc <<< " $adtrans_v2_Server > 0") )) && echo "$(tput setaf 3)adtrans_v2_Server total:$(tput sgr0) \$$adtrans_v2_Server" || \
#	echo "$(tput setaf 3)adtrans_v2_Server total:$(tput sgr0) $(tput setaf 1)NOT UPDATED $(tput sgr0)"
#
#	springs_v2_Server=$(${mysql_db} "SELECT SUM(adRevenue) FROM V2_Server WHERE DATE IN ("\'${YESTERDAYDATE_1}\'", "\'${YESTERDAYDATE_2}\'") AND platformID = 7")
#	[[ $springs_v2_Server = 'NULL' ]] && springs_v2_Server="0.00"
#	tput cup 8 165
#	(( $(bc <<< "$springs_v2_Server > 0") )) && echo "$(tput setaf 3)springs_v2_Server total:$(tput sgr0) \$$springs_v2_Server" || \
#	echo "$(tput setaf 3 )springs_v2_server total:$(tput sgr0) $(tput setaf 1)NOT UPDATED $(tput sgr0)"
#
#	totaldomain=$(bc <<< "$dna_v2_Server + $dc_v2_Server + $adsym_v2_Server + $tm_v2_Server + $adtrans_v2_Server + $springs_v2_Server")
#	
#	tput cup 9 165; echo "$(tput bold)$(tput setaf 5)Total:$(tput sgr0)                   $(tput setaf 2)$(tput bold)\$$totaldomain$(tput sgr0)"
	}



ORIGyesterday_totals_per_account_domain() {
	tput cup 2 165; echo "$(tput bold)$(tput setaf 5)__YESTERDAY TOTAL REVENUE DOMAIN LEVEL__$(tput sgr0)"

	dna_v2_Server=$(${mysql_db} "SELECT SUM(adRevenue) FROM epiphany_db.V2_Server WHERE DATE ="\'${yesterdayDate}\'" AND platformID = 1")
	[[ $dna_v2_Server = 'NULL' ]] && dna_v2_Server="0.00"
	tput cup 3 165; if (( $(bc <<< "$dna_v2_Server>0.00") > 0 )); then echo "$(tput setaf 3)dna_v2_Server total:$(tput sgr0)     \$$dna_v2_Server";
		else echo "$(tput setaf 3)dna_v2_Server total:$(tput sgr0)     $(tput setaf 1)>>ERROR $(tput sgr0)"; fi

	dc_v2_Server=$(${mysql_db} "SELECT SUM(adRevenue) FROM epiphany_db.V2_Server WHERE DATE ="\'${yesterdayDate}\'" AND platformID = 2")
	if [[ $dc_v2_Server = 'NULL' ]]; then dc_v2_Server="0.0"; fi
	tput cup 4 165; if (( $(bc <<< " $dc_v2_Server > 0") )); then echo "$(tput setaf 3)dc_v2_Server total:$(tput sgr0)      \$$dc_v2_Server";
		else echo "$(tput setaf 3)dc_v2_Server total:$(tput sgr0)      $(tput setaf 1)>>ERROR $(tput sgr0)"; fi

	adsym_v2_Server=$(${mysql_db} "SELECT SUM(adRevenue) FROM epiphany_db.V2_Server WHERE DATE ="\'${yesterdayDate}\'" AND platformID = 4")
	if [[ $adsym_v2_Server = 'NULL' ]]; then adsym_v2_Server="0.0"; fi
	tput cup 5 165; if (( $(bc <<< " $adsym_v2_Server > 0") )); then echo "$(tput setaf 3)adsym_v2_Server total:$(tput sgr0)   \$$adsym_v2_Server";
		else echo "$(tput setaf 3)adsym_v2_Server total:$(tput sgr0)   $(tput setaf 1)>>ERROR $(tput sgr0)"; fi

	tm_v2_Server=$(${mysql_db} "SELECT SUM(adRevenue) FROM epiphany_db.V2_Server WHERE DATE ="\'${yesterdayDate}\'" AND platformID = 5")
	if [[ $tm_v2_Server = 'NULL' ]]; then tm_v2_Server="0.0"; fi
	tput cup 6 165; if (( $(bc <<< "$tm_v2_Server > 0") )); then echo "$(tput setaf 3)tm_v2_Server total:$(tput sgr0)      \$$tm_v2_Server";
		else echo "$(tput setaf 3)tm_v2_Server total:$(tput sgr0)      $(tput setaf 1)>>ERROR $(tput sgr0)"; fi

	adtrans_v2_Server=$(${mysql_db} "SELECT SUM(adRevenue) FROM epiphany_db.V2_Server WHERE DATE ="\'${yesterdayDate}\'" AND platformID = 6")
	if [[ $adtrans_v2_Server = 'NULL' ]]; then adtrans_v2_Server="0.0"; fi
	tput cup 7 165; if (( $(bc <<< " $adtrans_v2_Server > 0") )); then echo "$(tput setaf 3)adtrans_v2_Server total:$(tput sgr0) \$$adtrans_v2_Server";
		else echo "$(tput setaf 3)adtrans_v2_Server total:$(tput sgr0) $(tput setaf 1)>>ERROR $(tput sgr0)"; fi

	springs_v2_Server=$(${mysql_db} "SELECT SUM(adRevenue) FROM epiphany_db.V2_Server WHERE DATE ="\'${yesterdayDate}\'" AND platformID = 7")
	if [[ $springs_v2_Server = 'NULL' ]]; then springs_v2_Server="0.0"; fi
	tput cup 8 165; if (( $(bc <<< "$springs_v2_Server > 0") )); then echo "$(tput setaf 3)springs_v2_Server total:$(tput sgr0) \$$springs_v2_Server";
		else echo "$(tput setaf 3 )springs_v2_server total:$(tput sgr0) $(tput setaf 1)>>ERROR $(tput sgr0)"; fi

	totaldomain=$(bc <<< "$dna_v2_Server + $dc_v2_Server + $adsym_v2_Server + $tm_v2_Server + $adtrans_v2_Server + $springs_v2_Server")
	
	tput cup 9 165; echo "$(tput bold)$(tput setaf 5)Total:$(tput sgr0)                   $(tput setaf 2)$(tput bold)\$$totaldomain$(tput sgr0)"
	}


yesterday_totals_per_account_tag() {
	tput cup 3 110; echo "$(tput bold)$(tput setaf 5)__YESTERDAY TOTAL REVENUE TAG LEVEL__$(tput sgr0)"

	dna_test_Final=$(${mysql_db} "SELECT SUM(adRevenue) FROM test_Final WHERE DATE IN ("\'${YESTERDAYDATE_1}\'", "\'${YESTERDAYDATE_2}\'") AND marketID IN ('1', '2')")
	[[ $dna_test_Final = 'NULL' ]] && dna_test_Final="0.00"
	tput cup 4 110 
	(( $(bc <<< "$dna_test_Final > 0") )) && echo "$(tput setaf 3)dna_test_Final total:$(tput sgr0)     \$$dna_test_Final" || \
	echo "$(tput setaf 3)dna_test_Final total:$(tput sgr0)     $(tput setaf 1)NOT POPULATED $(tput sgr0)"

	dc_test_Final=$(${mysql_db} "SELECT SUM(adRevenue) FROM test_Final WHERE DATE IN ("\'${YESTERDAYDATE_1}\'", "\'${YESTERDAYDATE_2}\'") AND marketID IN ('25', '26')")
	[[ $dc_test_Final = 'NULL' ]] && dc_test_Final="0.00"
	tput cup 5 110 
	(( $(bc <<< " $dc_test_Final > 0") )) && echo "$(tput setaf 3)dc_test_Final total:$(tput sgr0)      \$$dc_test_Final" || \
	echo "$(tput setaf 3)dc_test_Final total:$(tput sgr0)      $(tput setaf 1)NOT POPULATED $(tput sgr0)"

	adsym_test_Final=$(${mysql_db} "SELECT SUM(adRevenue) FROM test_Final WHERE DATE IN ("\'${YESTERDAYDATE_1}\'", "\'${YESTERDAYDATE_2}\'") AND marketID IN ('32', '30')")
	[[ $adsym_test_Final = 'NULL' ]] && adsym_test_Final="0.00"
	tput cup 6 110 
	(( $(bc <<< " $adsym_test_Final > 0") )) && echo "$(tput setaf 3)adsym_test_Final total:$(tput sgr0)   \$$adsym_test_Final" || \
	echo "$(tput setaf 3)adsym_test_Final total:$(tput sgr0)   $(tput setaf 1)NOT UPDATED $(tput sgr0)"

	tm_test_Final=$(${mysql_db} "SELECT SUM(adRevenue) FROM test_Final WHERE DATE IN ("\'${YESTERDAYDATE_1}\'", "\'${YESTERDAYDATE_2}\'") AND marketID IN ('36', '37')")
	[[ $tm_test_Final = 'NULL' ]] && tm_test_Final="0.00"
	tput cup 7 110 
	(( $(bc <<< "$tm_test_Final > 0") )) && echo "$(tput setaf 3)tm_test_Final total:$(tput sgr0)      \$$tm_test_Final" || \
	echo "$(tput setaf 3)tm_test_Final total:$(tput sgr0)      $(tput setaf 1)NOT UPDATED $(tput sgr0)"

	adtrans_test_Final=$(${mysql_db} "SELECT SUM(adRevenue) FROM test_Final WHERE DATE IN ("\'${YESTERDAYDATE_1}\'", "\'${YESTERDAYDATE_2}\'") AND marketID IN ('34', '35')")
	[[ $adtrans_test_Final = 'NULL' ]] && adtrans_test_Final="0.00"
	tput cup 8 110 
	(( $(bc <<< " $adtrans_test_Final > 0") )) && echo "$(tput setaf 3)adtrans_test_Final total:$(tput sgr0) \$$adtrans_test_Final" || \
	echo "$(tput setaf 3)adtrans_test_Final total:$(tput sgr0) $(tput setaf 1)NOT UPDATED $(tput sgr0)"

	springs_test_Final=$(${mysql_db} "SELECT SUM(adRevenue) FROM test_Final WHERE DATE IN ("\'${YESTERDAYDATE_1}\'", "\'${YESTERDAYDATE_2}\'") AND marketID = ('39')")
	[[ $springs_test_Final = 'NULL' ]] && springs_test_Final="0.00"
	tput cup 9 110 
	(( $(bc <<< "$springs_test_Final > 0") )) && echo "$(tput setaf 3)springs_test_Final total:$(tput sgr0) \$$springs_test_Final" || \
	echo "$(tput setaf 3)springs_test_Final total:$(tput sgr0) $(tput setaf 1)NOT UPDATED $(tput sgr0)"
	
	totaltag=$(bc <<< "$dna_test_Final + $dc_test_Final + $adsym_test_Final + $tm_test_Final + $adtrans_test_Final + $springs_test_Final")
	
	tput cup 10 110; echo "$(tput bold)$(tput setaf 5)Total:$(tput sgr0)                    $(tput setaf 2)$(tput bold)\$$totaltag$(tput sgr0)"
	}


daily_totals_per_hour() {
	
	hour=0
	location=4
	bagged=0.0

	tput cup 3 58; echo "$(tput bold)$(tput setaf 5)__EPIPHANY HOURLY TOTAL TODAY__$(tput sgr0)"

	while [[ $hour != 24 ]]
	do
#		tput cup 3 58; echo "$(tput bold)$(tput setaf 5)__EPIPHANY HOURLY TOTAL TODAY__$(tput sgr0)"

		dna_core_today=$(${mysql_db3} "SELECT SUM(ad_revenue) FROM dna_core_today WHERE hour = $hour") 
		[[ $dna_core_today = 'NULL' ]] && dna_core_today="0.00"

		dc_core_today=$(${mysql_db3} "SELECT SUM(ad_revenue) FROM dc_core_today WHERE hour = $hour")
		[[ $dc_core_today = 'NULL' ]] && dc_core_today="0.00"

		adsym_core_today=$(${mysql_db3} "SELECT SUM(ad_revenue) FROM adsym_core_today WHERE hour = $hour")
		[[ $adsym_core_today = 'NULL' ]] && adsym_core_today="0.00"

		tm_core_today=$(${mysql_db3} "SELECT SUM(ad_revenue) FROM tm_core_today WHERE hour = $hour")
		[[ $tm_core_today = 'NULL' ]] && tm_core_today="0.00"

		adtrans_core_today=$(${mysql_db3} "SELECT SUM(ad_revenue) FROM adtrans_core_today WHERE hour = $hour") 
		[[ $adtrans_core_today = 'NULL' ]] && adtrans_core_today="0.00"

		springs_core_today=$(${mysql_db3} "SELECT SUM(revenue) FROM springserve_core_today WHERE hour = $hour") 
		[[ $springs_core_today = 'NULL' ]] && springs_core_today="0.00"


		total=$(bc <<<  "$dna_core_today + $dc_core_today + $adsym_core_today + $tm_core_today + $adtrans_core_today + $springs_core_today")
		bagged=$(bc <<< "$bagged + $total")	
		tput cup $location 58; echo "$(tput setaf 3)Epiphany total for hour $hour:$(tput sgr0) \$$total" 
				
		hour=$((hour+1))
		location=$((location+1))	
	done
	tput cup $location 58; echo "$(tput setaf 5)$(tput bold)Daily Total for Hours:$(tput sgr0)      $(tput setaf 2)$(tput bold)\$$bagged$(tput sgr0)"
	}


monthly_total_by_day() {
	
	location=14
	startdate="$(date --date "-0 month" +%Y-%m-01)"
	todaydate=$(date +%Y-%m-%d)
	lastdate="$(date --date "-$(date +%d) days +1 month" +%Y-%m-%d)"
	dailytotal="0.00"

	tput cup 13 110; echo "$(tput bold)$(tput setaf 5)__MONTHLY TOTAL BY DAY__$(tput sgr0)"
	
	until [[ "$startdate" > "$lastdate" ]]
	do
		dna_test_Final=$(${mysql_db} "SELECT SUM(adRevenue) FROM test_Final WHERE DATE ="\'${startdate}\'" AND marketID IN ('1', '2')")
		[[ $dna_test_Final = 'NULL' ]] && dna_test_Final="0.00"
	
		dc_test_Final=$(${mysql_db} "SELECT SUM(adRevenue) FROM test_Final WHERE DATE ="\'${startdate}\'" AND marketID IN ('25', '26')")
		[[ $dc_test_Final = 'NULL' ]] && dc_test_Final="0.00"
	
		adsym_test_Final=$(${mysql_db} "SELECT SUM(adRevenue) FROM test_Final WHERE DATE ="\'${startdate}\'" AND marketID IN ('32', '30')")
		[[ $adsym_test_Final = 'NULL' ]] && adsym_test_Final="0.00"
	
		tm_test_Final=$(${mysql_db} "SELECT SUM(adRevenue) FROM test_Final WHERE DATE ="\'${startdate}\'" AND marketID IN ('36', '37')")
		[[ $tm_test_Final = 'NULL' ]] && tm_test_Final="0.00"
	
		adtrans_test_Final=$(${mysql_db} "SELECT SUM(adRevenue) FROM test_Final WHERE DATE ="\'${startdate}\'" AND marketID IN ('34', '35')")
		[[ $adtrans_test_Final = 'NULL' ]] && adtrans_test_Final="0.00"
	
		springs_test_Final=$(${mysql_db} "SELECT SUM(adRevenue) FROM test_Final WHERE DATE ="\'${startdate}\'" AND marketID = ('39')")
		[[ $springs_test_Final = 'NULL' ]] && springs_test_Final="0.00"

		## DAILY TOTALS
		totalmtbd=$(bc <<<  "$dna_test_Final + $dc_test_Final + $adsym_test_Final + $tm_test_Final + $adtrans_test_Final + $springs_test_Final")
		## DAILY TOTALS INCREMENTED FOR MONTH END TOTAL
		dailytotal=$(bc <<< "$dailytotal + $totalmtbd") 


		tput cup $location 110; echo "$(tput setaf 3)Total for $startdate:$(tput sgr0) \$$totalmtbd" 

		location=$((location+1))	
		startdate=$(date +"%Y-%m-%d" -d "$startdate + 1 day");
	done

	tput cup $location 110; echo "$(tput bold)$(tput setaf 5)Total for month:$(tput sgr0)      $(tput setaf 2)$(tput bold)\$$dailytotal$(tput sgr0)"	
	
	}

yearly_total_by_month() {

	location=14

	current_month=1
	day=$(date '+%d')
	month=$(date '+%m')
	year=$(date '+%Y')
	year_total="0.00"

	tput cup 13 165; echo "$(tput bold)$(tput setaf 5)__YEARLY TOTAL BY MONTH__$(tput sgr0)"

	while [[ $current_month -le 12  ]]
	do
		start_month=$(printf "${year}-%02d-01" $current_month)
		end_month=$(date -d "$current_month/1 + 1 month -1 day" "+%Y-%m-%d")


		dna_test_Final=$(${mysql_db} "SELECT SUM(adRevenue) FROM test_Final WHERE DATE BETWEEN "\'${start_month}\'" AND "\'${end_month}\'" AND marketID IN ('1', '2')")
		[[ $dna_test_Final = 'NULL' ]] && dna_test_Final="0.00"
		
		dc_test_Final=$(${mysql_db} "SELECT SUM(adRevenue) FROM test_Final WHERE DATE BETWEEN "\'${start_month}\'" AND "\'${end_month}\'" AND marketID IN ('25', '26')")
		[[ $dc_test_Final = 'NULL' ]] && dc_test_Final="0.00"
		
		adsym_test_Final=$(${mysql_db} "SELECT SUM(adRevenue) FROM test_Final WHERE DATE BETWEEN "\'${start_month}\'" AND "\'${end_month}\'" AND marketID IN ('32', '30')")
		[[ $adsym_test_Final = 'NULL' ]] && adsym_test_Final="0.00"
		
		tm_test_Final=$(${mysql_db} "SELECT SUM(adRevenue) FROM test_Final WHERE DATE BETWEEN "\'${start_month}\'" AND "\'${end_month}\'" AND marketID IN ('36', '37')")
		[[ $tm_test_Final = 'NULL' ]] && tm_test_Final="0.00"
		
		adtrans_test_Final=$(${mysql_db} "SELECT SUM(adRevenue) FROM test_Final WHERE DATE BETWEEN "\'${start_month}\'" AND "\'${end_month}\'" AND marketID IN ('34', '35')")
		[[ $adtrans_test_Final = 'NULL' ]] && adtrans_test_Final="0.00"
		
		springs_test_Final=$(${mysql_db} "SELECT SUM(adRevenue) FROM test_Final WHERE DATE BETWEEN "\'${start_month}\'" AND "\'${end_month}\'" AND marketID = ('39')")
		[[ $springs_test_Final = 'NULL' ]] && springs_test_Final="0.00"

		monthlytotal=$(bc <<<  "$dna_test_Final + $dc_test_Final + $adsym_test_Final + $tm_test_Final + $adtrans_test_Final + $springs_test_Final")
		year_total=$(bc <<< "$year_total + $monthlytotal") 
	
		tput cup $location 165; echo "$(tput setaf 3)Total for $start_month:$(tput sgr0) \$$monthlytotal" 

		location=$((location+1))
		current_month=$((current_month+1))	
	done

	tput cup $location 165; echo "$(tput bold)$(tput setaf 5)Total for year:$(tput sgr0)      $(tput setaf 2)$(tput bold)\$$year_total$(tput sgr0)"	
	
	}



echo "$(tput bold) $(tput setaf 6)================================================================================================================================================================================================================$(tput sgr0)"                           
echo   "$(tput bold) $(tput setaf 6) |  EPIPHANY DATABASE OVERVIEW $(tput sgr0) $(tput setaf 3) "${BANNER_DATE}" $(tput sgr0) $(tput bold) $(tput setaf 6)  |  CURRENT HOUR = $(tput sgr0) $(tput setaf 3) "${BANNER_HOUR}"$(tput sgr0)$(tput bold)$(tput setaf 4)h$(tput sgr0)                                                                                                     $(tput bold)$(tput setaf 6)Hello$(tput sgr0)  $u"
echo "$(tput bold) $(tput setaf 6)================================================================================================================================================================================================================$(tput sgr0)"                           

dna_sourcelevel  
dc_sourcelevel 
adsym_sourcelevel
tm_sourcelevel
adtrans_sourcelevel
springs_sourcelevel
daily_totals_per_hour
yesterday_totals_per_account_tag
#yesterday_totals_per_account_domain
monthly_total_by_day
yearly_total_by_month


# puts cursor at end of screen
tput cup 55
