#!/usr/bin/python2.7

import json
import time
import datetime
from mysql.connector import MySQLConnection, Error
from python_dbconfig import read_db_config
import springs_api

last60 = datetime.date.fromordinal(datetime.date.today().toordinal()-60).strftime("%F")
todaysdate = time.strftime("%Y-%m-%d")

def connect():

    # """Gets Springserve data and writes to MySQL table"""
    db = "mysql_sl"
    api = "springs"

    # Connect to DB:
    db_config = read_db_config(db)

    try:
        print('connecting to database...')
        conn = MySQLConnection(**db_config)

        if conn.is_connected():
            print('Connection established.')
    
            cursor  = conn.cursor()

            # Create Table:
            sql = "DROP TABLE IF EXISTS springserve_core_last60"
            cursor.execute(sql)

            sql = "CREATE TABLE springserve_core_last60 (DATE VARCHAR(25), source_id VARCHAR(10), supply_source VARCHAR(255), \
	            Total_Requests BIGINT, usable_requests BIGINT, opportunities BIGINT, ad_impressions BIGINT, \
                    revenue DECIMAL(15, 5), clicks BIGINT)"
            cursor.execute(sql)

            # call to get logintoken
            logintoken = springs_api.get_logintoken(api)
            print(logintoken)
    
            jsoninfo = {
                #"date_range": "Yesterday",
             	"interval": "day",
        	"timezone": "America/Los_Angeles",
        	"dimensions": ["supply_tag_id"],
        	"start_date": last60,
        	"end_date": todaysdate,
                #"sort": [{ "field": "ad_revenue", "order": "desc"}] 
                #page": 2
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
	        source_id = x['supply_tag_id']
	        supply_source = x['supply_tag_name']
	        Total_Requests = x['total_requests']
	        usable_requests = x['usable_requests']
	        opportunities = x['opportunities']
	        ad_impressions = x['total_impressions']
	        revenue = x['revenue']
	        clicks = x['clicks']

	        list = (date, source_id, supply_source, Total_Requests, usable_requests, opportunities, ad_impressions, revenue, clicks)
                #print(list)

	        sql = """INSERT INTO springserve_core_last60 VALUES ("%s", "%s", "%s", "%s", "%s", "%s", "%s", "%s", "%s")""" % \
		    (date, source_id, supply_source, Total_Requests, usable_requests, opportunities, ad_impressions, revenue, clicks)
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
