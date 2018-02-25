#!/usr/bin/python2.7

import json
from mysql.connector import MySQLConnection, Error
from python_dbconfig import read_db_config
import aol_api

def connect():

    # """Gets AOL Data and writes them to a MySQL table"""
    db = "mysql_sl"
    api = "adsym"

    # Connect To DB:
    db_config = read_db_config(db)

    try:
        print('Connecting to database...')
        conn = MySQLConnection(**db_config)

        if conn.is_connected():
            print('Connection established.')

            cursor = conn.cursor()

            sql = "DROP TABLE IF EXISTS adsym_core_yesterday_media"
            cursor.execute(sql)

            sql = "CREATE TABLE adsym_core_yesterday_media (date varchar(25), hour int, inventory_source varchar(255), media varchar(255),  \
	            ad_opportunities bigint, market_opportunities bigint, ad_attempts bigint, ad_impressions bigint, ad_errors bigint, \
		    ad_revenue decimal(15, 5), aol_cost decimal(15, 5), epiphany_gross_revenue decimal(15, 5), adsym_revenue decimal(15, 5), \
		    clicks bigint, iab_viewability_measurable_ad_impressions bigint, iab_viewable_ad_impressions bigint, platform int)"
            cursor.execute(sql)

            # calls get_access_token function and starts script
            logintoken = aol_api.get_access_token(api)
            print(logintoken)

            result = aol_api.run_existing_report(logintoken, "161190")
            #print(result)

            info = json.loads(result)
            #print(info)

            for x in json.loads(result)['data']:
	        date = x['row'][0]
        	hour = x['row'][1]
	        inventory_source = x['row'][2]
	        media = x['row'][3]
	        ad_opportunities = x['row'][4]
	        market_opportunities = x['row'][5]
	        ad_attempts = x['row'][6]
	        ad_impressions = x['row'][7]
	        ad_errors = x['row'][8]
	        ad_revenue = x['row'][9]
	        aol_cost = x['row'][9]
	        epiphany_gross_revenue = x['row'][9]
	        adsym_revenue = x['row'][9]
	        clicks = x['row'][10]
	        iab_viewability_measurable_ad_impressions = x['row'][11]
	        iab_viewable_ad_impressions = x['row'][12]
	        platform = '4'

	        list = (date, hour, inventory_source, media, ad_opportunities, market_opportunities, ad_attempts, ad_impressions, \
			ad_errors, ad_revenue, aol_cost, epiphany_gross_revenue, adsym_revenue, clicks, \
			iab_viewability_measurable_ad_impressions, iab_viewable_ad_impressions, platform)
                #print(list)

        	sql = """INSERT INTO adsym_core_yesterday_media VALUES ("%s", "%s", "%s", "%s", "%s", "%s", "%s", "%s", "%s", "%s", \
			"%s"*.20, "%s"*.56, "%s"*.24, "%s", "%s", "%s", "%s")""" % (date, hour, inventory_source, media,
			ad_opportunities, market_opportunities, ad_attempts, ad_impressions, ad_errors, ad_revenue, aol_cost, \
			epiphany_gross_revenue, adsym_revenue, clicks, iab_viewability_measurable_ad_impressions, \
			iab_viewable_ad_impressions, platform)
	        cursor.execute(sql)
    
            cursor.execute('commit')

        else:
            print('Connection failed')

    except Error as error:
        print(error)

    finally:
        conn.close()
        print('Connection closed.')


if __name__ == '__main__':
    connect()
