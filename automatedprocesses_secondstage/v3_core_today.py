#!/usr/bin/python2.7

import json
from mysql.connector import MySQLConnection, Error
from python_dbconfig import read_db_config
import aol_api

def connect():

    # """Gets AOL Data and writes them to a MySQL table"""
    db = "mysql_sl"
    api = "aol"

    # Connect To DB:
    db_config = read_db_config(db)

    try:
        print('Connecting to database...')
        conn = MySQLConnection(**db_config)

        if conn.is_connected():
            print('Connection established.')

            cursor = conn.cursor()

            # Create Table:
            sql = "DROP TABLE IF EXISTS v3_core_today"
            cursor.execute(sql)

            sql = "CREATE TABLE v3_core_today (hour int, inventory_source varchar(255), ad_opportunities bigint, \
                    market_opportunities bigint, ad_attempts bigint, ad_impressions bigint, ad_errors bigint, ad_revenue decimal(15, 5), \
		    total_clicks int, iab_viewability_measurable_ad_impressions bigint, iab_viewable_ad_impressions bigint)"
            cursor.execute(sql)

            # calls get_access_token function and starts script
            logintoken = aol_api.get_access_token(api)
            print(logintoken)

            result = aol_api.run_existing_report(logintoken, "142557")
            #print(result)

            info = json.loads(result)
            #print(info)

            for x in json.loads(result)['data']:
	        hour = x['row'][0]
        	inventory_source = x['row'][1]
	        ad_opportunities = x['row'][2]
	        market_opportunities = x['row'][3]
	        ad_attempts = x['row'][4]
	        ad_impressions = x['row'][5]
	        ad_errors = x['row'][6]
	        ad_revenue = x['row'][7]
	        total_clicks = x['row'][8]
	        iab_viewability_measurable_ad_impressions = x['row'][9]
	        iab_viewable_ad_impressions = x['row'][10]
	       
	        list = (hour, inventory_source, ad_opportunities, market_opportunities, ad_attempts, ad_impressions, \
			ad_errors, ad_revenue, total_clicks, iab_viewability_measurable_ad_impressions, iab_viewable_ad_impressions)
#	        print(list)

        	sql = """INSERT INTO v3_core_today VALUES ("%s", "%s", "%s", "%s", "%s", "%s", "%s", "%s", \
			"%s", "%s", "%s")""" % (hour, inventory_source, ad_opportunities, market_opportunities, \
			ad_attempts, ad_impressions, ad_errors, ad_revenue, total_clicks, \
                        iab_viewability_measurable_ad_impressions, iab_viewable_ad_impressions)
	        cursor.execute(sql)

            cursor.execute('commit')

        else:
            print('Connection failed.')
    
    except Error as error:
        print(error)

    finally:
        conn.close()
        print('Connection closed')


if __name__ == '__main__':
    connect()
