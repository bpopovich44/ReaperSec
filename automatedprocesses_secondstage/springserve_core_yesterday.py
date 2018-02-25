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
    db = "mysql_sl"
    api = "springs"

    # Connect to DB:
    db_config = read_db_config(db)

    try:
        print('Connecting to database...')
        conn = MySQLConnection(**db_config)

        if conn.is_connected():
            print('Connection established.')
            
            cursor = conn.cursor()

            # Create Table:
            sql = "DROP TABLE IF EXISTS springserve_core_yesterday"
            cursor.execute(sql)

            sql = "CREATE TABLE springserve_core_yesterday (date varchar(25), hour int(2), source_id varchar(10), supply_source varchar(255), \
	            total_requests bigint, usable_requests bigint, opportunities bigint, ad_impressions bigint, revenue decimal(15, 5), clicks bigint)"
            cursor.execute(sql)

            # call to get logintoken
            logintoken = springs_api.get_logintoken(api)
            print(logintoken)

            for page in range(1, 10):

                jsoninfo = {
                    "date_range": "Yesterday",
                    "interval": "hour",
                    "timezone": "America/Los_Angeles",
                    "dimensions": ["supply_tag_id"],
                    #"start_date": Today,
                    #"endDate": Today,
                    #"sort": [{ "field": "ad_revenue", "order": "desc"}] 
	            "page": str(page)
                    }

                result = springs_api.get_data(logintoken, jsoninfo)
                #print(result.text)

                info = json.loads(result.text)
                # print(info)

                # use default to populate null data
                default = '0'

                for x in info:
	            date1 = x['date']
	            date = date1[:10]
	            time1 = x['date']
        	    time2 = time1[11:-8].replace("00", "*0").lstrip("0")
	            hour = time2.replace("*0", "0")
	            source_id = x['supply_tag_id']
	            supply_source = x['supply_tag_name']
	            total_requests = x['total_requests']
	            usable_requests = x['usable_requests']
	            opportunities = x['opportunities']
	            ad_impressions = x['total_impressions']
	            revenue = x['revenue']
	            clicks = x['clicks']
		
        	    list = (date, hour, source_id, supply_source, total_requests, usable_requests, opportunities, ad_impressions, revenue, clicks)
                    #print(list)

	            sql = """INSERT INTO springserve_core_yesterday VALUES ("%s", "%s", "%s", "%s", "%s", "%s", "%s", "%s", "%s", "%s")""" % \
		        (date, hour, source_id, supply_source, total_requests, usable_requests, opportunities, ad_impressions, revenue, clicks)

	            cursor.execute(sql)

                cursor.execute('commit')

        else:
            print('Connection failed.')
    
    except Error as Error:
        print(error)

    finally:
        conn.close()
        print('Connection closed.')

if __name__ == '__main__':
    connect()
