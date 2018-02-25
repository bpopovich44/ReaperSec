#!/usr/bin/python2.7

import json
from mysql.connector import MySQLConnection, Error
from python_dbconfig import read_db_config
import aol_api_R

def connect():

    # """Gets AOL Data and writes them to a MySQL table"""
    db = "mysql_eom"
    api = "adtrans"

    # Connect To DB:
    db_config = read_db_config(db)

    try:
        print('Connecting to database...')
        conn = MySQLConnection(**db_config)

        if conn.is_connected():
            print('Connection established')

            cursor = conn.cursor()

            sql = "DROP TABLE IF EXISTS adtrans_inventoryreport_EOM"
            cursor.execute(sql)

            sql = "CREATE TABLE adtrans_inventoryreport_EOM (date varchar(50), inventory_source varchar(255), geo_country varchar(50), \
		    ad_opportunities bigint, ad_attempts bigint, ad_impressions bigint, \
		    ad_revenue decimal(15, 5), ecpm decimal(15, 5), platform int)"
            cursor.execute(sql)

            # calls get_access_token function and starts script
            logintoken = aol_api_R.get_access_token(api)
            print(logintoken)

            result = aol_api_R.run_existing_report(logintoken, "193903")
            #print(result)

            info = json.loads(result)
            #print(info)

            for x in json.loads(result)['data']:
	        date = x['row'][0]
        	inventory_source = x['row'][1]
	        geo_country = x['row'][2]
	        ad_opportunities = x['row'][3]
	        ad_attempts = x['row'][4]
	        ad_impressions = x['row'][5]
        	ad_revenue = x['row'][6]
        	ecpm = x['row'][7]
	        platform = '6'

	        list = (date, inventory_source, geo_country, ad_opportunities, ad_attempts, ad_impressions, ad_revenue, ecpm, \
			platform)
	        #print(list)

	        sql = """INSERT INTO adtrans_inventoryreport_EOM VALUES ("%s", "%s", "%s", "%s", "%s", "%s", "%s", "%s", "%s")""" % \
			(date, inventory_source, geo_country, ad_opportunities, ad_attempts, ad_impressions, ad_revenue, ecpm, \
			platform)
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
