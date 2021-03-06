#!/usr/bin/python2.7

import json
import time
import datetime
from mysql.connector import MySQLConnection, Error
from python_dbconfig import read_db_config
import springs_api

yesterday = datetime.date.fromordinal(datetime.date.today().toordinal()-1).strftime("%F")
todaysdate = time.strftime("%Y-%m-%d")
todaytime = time.strftime("%Y-%m-%d %H:%M:%S")

def connect():
    
    #"""Gets Springserve data and writes to MySQL table"""
    db = "mysql_dl"
    api = "springs"
    page = 1
    db_updated = False
    
    # Connect to DB:
    db_config = read_db_config(db)

    try:
        #print('Connecting to database...')
        conn = MySQLConnection(**db_config)

        if conn.is_connected():
            #print('Connection established.')

            cursor = conn.cursor()

            # call to get logintoken
            logintoken = springs_api.get_logintoken(api)
            #print(logintoken)

            while True:

                jsoninfo = {
	            "date_range": "Yesterday",
	            "interval": "day",
	            "timezone": "America/Los_Angeles",
	            "dimensions": ["supply_tag_id"],
                    #"startDate": yesterday,
                    #"endDate": yesterday,
                    #"sort": [{ "field": "ad_revenue", "order": "desc"}] 
                    "page": str(page)
                    }

                result = springs_api.get_data(logintoken, jsoninfo)
                #print(result.text)

                info = json.loads(result.text)
                if len(info) == 0:
                    break

                if len(info) >= 1:
                    if db_updated == False:
                
                        # Create Table:
                        sql = "DROP TABLE IF EXISTS springserve_domain_v2"
                        cursor.execute(sql)

                        sql = "CREATE TABLE springserve_domain_v2 (date varchar(25), media varchar(255) CHARACTER SET 'utf8', \
                            ad_opportunities bigint, ad_attempts bigint, ad_impressions bigint, ad_revenue decimal(15, 5))"
                        cursor.execute(sql)

                        db_updated = True

                print(str(todaytime) + "  Running springserve_domain_v2.  Page # " + str(page) + " Count " + str(len(info)))
                
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

	            sql = """INSERT INTO springserve_domain_v2 VALUES ("%s", "%s", "%s", "%s", "%s", \
                            "%s")""" % (date, media, ad_opportunities, ad_attempts, ad_impressions, ad_revenue)

	            cursor.execute(sql)

                cursor.execute('commit')
        
                page += 1

        else:
            print('connection failed.')

    except Error as error:
        print(error)

    finally:
        conn.close()
        #print('Connection closed.')

if __name__ == '__main__':
    connect()
