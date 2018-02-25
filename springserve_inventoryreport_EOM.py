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

    # """Gets Springserve data and writes to MySQL table"""
    db = "mysql_eom"
    api = "springs"
       
    # connect to db:
    db_config = read_db_config(db)

    try:
        print('Connecting to database...')
        conn = MySQLConnection(**db_config)

        if conn.is_connected():
            print('Connection established.')

            cursor = conn.cursor()

            # Create Table:
            sql = "DROP TABLE IF EXISTS springserve_inventoryreport_EOM"
            cursor.execute(sql)

            sql = "CREATE TABLE springserve_inventoryreport_EOM (date varchar(25), sourceID varchar(10), supply_source varchar(255), \
                    country varchar(255), ad_opportunities bigint, ad_impressions bigint, revenue decimal(15, 5), platform int)"
            cursor.execute(sql)

           # call to get logintoken
            logintoken = springs_api.get_logintoken(api)
            print(logintoken)

            for page in range(1, 20):

                jsoninfo = {
                    #"date_range": "Yesterday",
	            "interval": "day",
	            "timezone": "America/Los_Angeles",
	            "dimensions": ["supply_tag_id", "country"],
                    #"reportFormat": "JSON",
	            "start_date": "2017-10-01",
	            "end_date": "2017-10-31",
                    #"sort": [{ "field": "ad_revenue", "order": "desc"}] 
                    "page": str(page) 
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
	            country = x.get('country_code', default)
	            ad_opportunities = x['total_requests']
	            ad_impressions = x['total_impressions']
	            revenue = x['revenue']
	            platform = 7

	            list = (date, source_id, supply_source, country, ad_opportunities, ad_impressions, revenue, platform)
	            print(list)

	            sql = """INSERT INTO springserve_inventoryreport_EOM VALUES ("%s", "%s", "%s", "%s", "%s", "%s", "%s", "%s")""" % \
		            (date, source_id, supply_source, country, ad_opportunities, ad_impressions, revenue, platform)
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
