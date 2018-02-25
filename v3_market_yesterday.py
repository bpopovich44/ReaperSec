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

            sql = "DROP TABLE IF EXISTS v3_market_yesterday"
            cursor.execute(sql)

            sql = "CREATE TABLE v3_market_yesterday (date varchar(25), hour int, buyer_organization varchar(255), \
		    inventory_source varchar(255), market_opportunities bigint, ad_attempts bigint, ad_impressions bigint, \
		    ad_errors bigint, ad_revenue decimal(15, 5), total_clicks int, iab_viewability_measurable_ad_impressions bigint, \
		    iab_viewable_ad_impressions bigint)"
            cursor.execute(sql)

            # calls get_access_token function and starts script
            logintoken = aol_api.get_access_token("daf5fa63-56c4-4279-842e-639c9af75750", "C5eBl8aErmCMO2+U85LGpw")
            print logintoken

            result = aol_api.run_existing_report(logintoken, "143991")
            #print(result)

            info = json.loads(result)
            #print(info)

            for x in json.loads(result)['data']:
	        date = x['row'][0]
	        hour = x['row'][1]
	        buyer_organization = x['row'][2]
	        inventory_source = x['row'][3]
	        market_opportunities = x['row'][4]
	        ad_attempts = x['row'][5]
	        ad_impressions = x['row'][6]
	        ad_errors = x['row'][7]
	        ad_revenue = x['row'][8]
	        total_clicks = x['row'][9]
	        iab_viewability_measurable_ad_impressions = x['row'][10]
	        iab_viewable_ad_impressions = x['row'][11]

	        list = (date, hour, buyer_organization, inventory_source, market_opportunities, ad_attempts, ad_impressions, \
			ad_errors, ad_revenue, total_clicks, iab_viewability_measurable_ad_impressions, \
                        iab_viewable_ad_impressions)
	        #print(list)

	        sql = """INSERT INTO v3_market_yesterday VALUES ("%s", "%s", "%s", "%s", "%s", "%s", "%s", "%s", "%s", \
			"%s", "%s", "%s")""" % (date, hour, buyer_organization, inventory_source, market_opportunities, \
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
        print('Connection closed.')


if __name__ == '__main__':
    connect()
