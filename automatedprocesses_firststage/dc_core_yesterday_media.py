#!/usr/bin/python2.7

import json
from mysql.connector import MySQLConnection, Error
from python_dbconfig import read_db_config
import aol_api

def connect():

    # """Gets AOL Data and writes them to a MySQL table"""
    db = "mysql_sl"

    # Connect To DB:
    db_config = read_db_config(db)

    try:
        print('Connecting to database...')
        conn = MySQLConnection(**db_config)

        if conn.is_connected():
            print('Connection established.')

            cursor = conn.cursor()

            sql = "DROP TABLE IF EXISTS dc_core_yesterday_media"
            cursor.execute(sql)

            sql = "CREATE TABLE dc_core_yesterday_media (date varchar(25), inventory_source varchar(255), media varchar(255),  \
	            ad_opportunities bigint, market_opportunities bigint, ad_attempts bigint, ad_impressions bigint, ad_errors bigint, \
		    ad_revenue decimal(15, 5), aol_cost decimal(15, 5), epiphany_gross_revenue decimal(15, 5), dc_revenue decimal(15, 5), \
		    clicks bigint, iab_viewability_measurable_ad_impressions bigint, iab_viewable_ad_impressions bigint, platform int)"
            cursor.execute(sql)

            # calls get_access_token function and starts script
            logintoken = aol_api.get_access_token("0e30062d-6746-4a9b-882a-3f61185479c7", "9O7SnFq/yDbNK+4M2bkSqg")
            print(logintoken)

            result = aol_api.run_existing_report(logintoken, "143983")
            #print(result)

            info = json.loads(result)
            #print(info)

            for x in json.loads(result)['data']:
	        date = x['row'][0]
        	inventory_source = x['row'][1]
	        media = x['row'][2]
	        ad_opportunities = x['row'][3]
	        market_opportunities = x['row'][4]
	        ad_attempts = x['row'][5]
	        ad_impressions = x['row'][6]
	        ad_errors = x['row'][7]
	        ad_revenue = x['row'][8]
	        aol_cost = x['row'][8]
	        epiphany_gross_revenue = x['row'][8]
	        dc_revenue = x['row'][8]
	        clicks = x['row'][9]
	        iab_viewability_measurable_ad_impressions = x['row'][10]
	        iab_viewable_ad_impressions = x['row'][11]
	        platform = '2'

	        list = (date, inventory_source, media, ad_opportunities, market_opportunities, ad_attempts, ad_impressions, \
			ad_errors, ad_revenue, aol_cost, epiphany_gross_revenue, dc_revenue, clicks, \
			iab_viewability_measurable_ad_impressions, iab_viewable_ad_impressions, platform)
                #print(list)

        	sql = """INSERT INTO dc_core_yesterday_media VALUES ("%s", "%s", "%s", "%s", "%s", "%s", "%s", "%s", "%s", \
			"%s"*.20, "%s"*.56, "%s"*.24, "%s", "%s", "%s", "%s")""" % (date, inventory_source, media,
			ad_opportunities, market_opportunities, ad_attempts, ad_impressions, ad_errors, ad_revenue, aol_cost, \
			epiphany_gross_revenue, dc_revenue, clicks, iab_viewability_measurable_ad_impressions, \
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
