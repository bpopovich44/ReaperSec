#!/usr/bin/python2.7

import json
import time
import datetime
from mysql.connector import MySQLConnection, Error
from python_dbconfig import read_db_config
import springs_api

yesterday = datetime.date.fromordinal(datetime.date.today().toordinal()-1).strftime("%F")
todaysdate = time.strftime("%Y-%m-%d")

def connect():
    
    #"""Gets Springserve data and writes to MySQL table"""
    db = "mysql_dp"
    api = "springs"

    # Connect to DB:
    db_config = read_db_config(db)

    try:
        print('connecting to database...')
        conn = MySQLConnection(**db_config)

        if conn.is_connected():
            print('Connection established.')

            cursor = conn.cursor()

            # Create Table:
            sql = "DROP TABLE IF EXISTS springserve_inventorysources"
            cursor.execute(sql)

            sql = "CREATE TABLE springserve_inventorysources (date varchar(25), inventory_source varchar(255), ad_opportunities bigint, \
                    ad_impressions bigint, ad_revenue decimal(15, 5), platform int)"
            cursor.execute(sql)

            # Call to get logintoken
            logintoken = springs_api.get_logintoken(api)
            print(logintoken)

            jsoninfo = {
	        "date_range": "Yesterday",
	        "interval": "day",
	        "timezone": "America/Los_Angeles",
	        "dimensions": ["supply_tag_id"],
                #"reportFormat": "JSON",
                #"start_date": Today,
                #"endDate": Today,
                #"sort": [{ "field": "ad_revenue", "order": "desc"}] 
                }

            result = springs_api.get_data(logintoken, jsoninfo)
            #print(result.text)

            info = json.loads(result.text)
            #print(info)

            # use default to populate null data
            default = 'Not Applicable'

            for x in info:
	        date1 = x['date']
	        date = date1[:10]
	        inventory_source = x['supply_tag_name']
	        ad_opportunities = x['total_requests']
	        ad_impressions = x['total_impressions']
	        ad_revenue = x['revenue']
	        platform = 7

        	list = (date, inventory_source, ad_opportunities, ad_impressions, ad_revenue, platform)
                #print(list)

	        sql = """INSERT INTO springserve_inventorysources VALUES ("%s", "%s", "%s", "%s", "%s", "%s")""" % \
		        (date, inventory_source, ad_opportunities, ad_impressions, ad_revenue, platform)
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
