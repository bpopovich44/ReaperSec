#!/usr/bin/python2.7

import json
from mysql.connector import MySQLConnection, Error
from python_dbconfig import read_db_config
import aol_api

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
            print('Connection established.')

            cursor = conn.cursor()

            sql = "DROP TABLE IF EXISTS  adsym_inventorysources"
            cursor.execute(sql)

            sql = "CREATE TABLE  adsym_inventorysources (date varchar(25), inventory_source varchar(255), ad_opportunities bigint, \
		ad_attempts bigint, ad_impressions bigint, ad_revenue decimal(15, 5), ecpm decimal(15, 5), platform int)"
            cursor.execute(sql)

            # calls get_access_token function and starts script
            logintoken = aol_api.get_access_token(api)
            print(logintoken)

            result = aol_api.run_existing_report(logintoken, "161173")
            #print(result)

            info = json.loads(result)
            #print(info)

            for x in json.loads(result)['data']:
	        date = x['row'][0]
	        inventory_source = x['row'][1]
	        ad_opportunities = x['row'][2]
	        ad_attempts = x['row'][3]
	        ad_impressions = x['row'][4]
	        ad_revenue = x['row'][5]
	        ecpm = x['row'][6]
	        platform = '4'

	        list = (date, inventory_source, ad_opportunities, ad_attempts, ad_impressions, ad_revenue, ecpm, platform)
	        #print(list)

	        sql = """INSERT INTO  adsym_inventorysources VALUES ("%s", "%s", "%s", "%s", "%s", "%s", "%s", "%s")""" % \
			(date, inventory_source, ad_opportunities, ad_attempts, ad_impressions, ad_revenue, ecpm, platform)
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
