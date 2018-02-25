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
    db = "mysql_dl"
    api = "springs"

    db_config = read_db_config(db)

    try:
        print('Connecting to database...')
        conn = MySQLConnection(**db_config)

        if conn.is_connected():
            print('Connection established.')

            cursor = conn.cursor()

            # Create Table:
            sql = "DROP TABLE IF EXISTS springserve_domainreport_v2"
            cursor.execute(sql)

            sql = "CREATE TABLE springserve_domainreport_v2 (date varchar(25), media varchar(255) CHARACTER SET 'utf8', \
                    ad_opportunities bigint, ad_attempts bigint, ad_impressions bigint, ad_revenue decimal(15, 5))"
            cursor.execute(sql)

            # call to get logintoken
            logintoken = springs_api.get_logintoken(api)
            print(logintoken)

            for page in range(1, 10):

                jsoninfo = {
	            "date_range": "Yesterday",
	            "interval": "day",
	            "timezone": "America/Los_Angeles",
	            "dimensions": ["supply_tag_id"],
                    #"reportFormat": "JSON",
                    #"startDate": yesterday,
                    #"endDate": yesterday,
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
	            date1 =x['date']
	            date = date1[:10]
	            media = x['supply_tag_name']
	            ad_opportunities = x['total_requests']
        	    ad_attempts = x['opportunities']
	            ad_impressions = x['total_impressions']
	            ad_revenue = x['revenue']

	            list = (date, media, ad_opportunities, ad_attempts, ad_impressions, ad_revenue)
                    #print(list)

	            sql = """INSERT INTO springserve_domainreport_v2 VALUES ("%s", "%s", "%s", "%s", "%s", \
                            "%s")""" % (date, media, ad_opportunities, ad_attempts, ad_impressions, ad_revenue)

	            cursor.execute(sql)

                cursor.execute('commit')

        else:
            print('connection failed.')

    except Error as error:
        print(error)

    finally:
        conn.close()
        print('Connection closed.')

if __name__ == '__main__':
    connect()
