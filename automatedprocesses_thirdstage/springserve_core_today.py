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

    # """Get Springserve data and write to MySQL table"""
    db = "mysql_sl"
    api = "springs"
    page = 1
    db_updated = False

    # Connect to db:
    db_config = read_db_config(db)

    try:
        #print('connecting to database...')
        conn = MySQLConnection(**db_config)

        if conn.is_connected():
            #print('Connection established.')
    
            cursor = conn.cursor()

            # call to get logintoken
            logintoken = springs_api.get_logintoken(api)
            #print(logintoken)
    
            while True:

                jsoninfo = {
                    "date_range": "Today",
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
                if len(info) == 0:
                    break

                if len(info) >= 1:
                    if db_updated == False:

                        sql = "DROP TABLE IF EXISTS springserve_core_today"
                        cursor.execute(sql)

                        sql = "CREATE TABLE springserve_core_today (date varchar(25), hour int(2), source_id varchar(10), \
                            supply_source varchar(255), total_requests bigint, usable_requests bigint, \
                            opportunities bigint, ad_impressions bigint, revenue decimal(15, 5), clicks bigint)"
                        cursor.execute(sql)

                        db_updated = True
    
                print(str(todaytime) +  "  Running springserve_core_today.  Page # " + str(page) + " Count " + str(len(info)))
    
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
		
                    list = (date, hour, source_id, supply_source, total_requests, usable_requests, \
                            opportunities, ad_impressions, revenue, clicks)
                    #print(list)

                    sql = """INSERT INTO springserve_core_today VALUES ("%s", "%s", "%s", "%s", "%s", \
                            "%s", "%s", "%s", "%s", "%s")""" % (date, hour, source_id, supply_source, \
                            total_requests, usable_requests, opportunities, ad_impressions, revenue, clicks)
                    cursor.execute(sql)

                cursor.execute('commit')
       
                page += 1

        else:
            print('Connection failed.')
    
    except Error as error:
        print(error)

    finally:
        conn.close()
        #print('Connection closed.')

if __name__ == '__main__':
     connect()
