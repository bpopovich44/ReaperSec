#!/usr/bin/python2.7

import json
from  mysql.connector import MySQLConnection, Error
from python_dbconfig import read_db_config
import aol_api_R

def connect():

    # """Gets AOL Data and writes them to a MySQL table"""
    db = "mysql_dp"
    api = "adsym"

    # Connect To DB:
    db_config = read_db_config(db)

    try:
        print('Connecting to database...')
        conn = MySQLConnection(**db_config)

        if conn.is_connected():
            print('Connected established.')

            cursor = conn.cursor()

            sql = "DROP TABLE IF EXISTS adsym_market_private"
            cursor.execute(sql)

            sql = "CREATE TABLE adsym_market_private (date varchar(25), inventory_source varchar(255), geo_country varchar(50), \
	    	    buyer_organization varchar(100), ad_opportunities varchar(2), ad_attempts bigint, ad_impressions bigint, \
		    ad_revenue decimal(15, 5), media_spend decimal(15, 5), ecpm decimal(6, 4), completed_views int, clicks int, \
		    platform int)"
            cursor.execute(sql)

            # calls get_access_token function and starts script
            logintoken = aol_api_R.get_access_token(api)
            print(logintoken)

            result = aol_api_R.run_existing_report(logintoken, "161184")
            #print(result)

            info = json.loads(result)
            #print(info)

            for x in json.loads(result)['data']:
	        date = x['row'][0]
	        inventory_source = x['row'][1].replace("'", " -")
	        geo_country = x['row'][2].replace(",", " -")
    	        buyer_organization = x['row'][3].replace('"', " ")
                ad_opportunities = '0'
	        ad_attempts = x['row'][5]
	        ad_impressions = x['row'][6]
	        ad_revenue = x['row'][7]
	        media_spend = x['row'][8]
	        ecpm = x['row'][9]
	        completed_views = x['row'][10]
	        clicks = x['row'][11].replace(" ", "0")
	        platform = '4'

	        list = (date, inventory_source, geo_country, buyer_organization, ad_opportunities, ad_attempts, ad_impressions, \
	                ad_revenue, media_spend, ecpm, completed_views, clicks, platform)
                #print(list)

	        sql = """INSERT INTO adsym_market_private VALUES ("%s", "%s", "%s", "%s", "%s", "%s", "%s", "%s", "%s", "%s", "%s", \
			"%s", "%s")""" % \
			(date, inventory_source, geo_country, buyer_organization, ad_opportunities, ad_attempts, ad_impressions, \
			ad_revenue, media_spend, ecpm, completed_views, clicks, platform)
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

