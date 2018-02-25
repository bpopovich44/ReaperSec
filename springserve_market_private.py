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
        print('Connecting to database...')
        conn = MySQLConnection(**db_config)

        if conn.is_connected():
            print('Connection established.')

            cursor = conn.cursor()

            # Create Table:
            sql = "DROP TABLE IF EXISTS springserve_market_private"
            cursor.execute(sql)

            sql = "CREATE TABLE springserve_market_private (date varchar(25), source_id varchar(10), supply_source varchar(255), country varchar(100), \
                    demand_partner_name varchar(100), tag_requests bigint, ad_impressions bigint, revenue decimal(15, 5), clicks bigint, platform int)"
            cursor.execute(sql)

            # call to get logintoken
            logintoken = springs_api.get_logintoken(api)
            print(logintoken)

            jsoninfo = {
	        "date_range": "Yesterday",
	        "interval": "day",
	        "timezone": "America/Los_Angeles",
	        "dimensions": ["supply_tag_id", "country", "demand_partner_id"]
                #"reportFormat": "JSON",
                #"start_date": "2017-07-18",
                #"end_date": "2017-07-18"
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
                source_id = x['supply_tag_id']
                supply_source = x['supply_tag_name']
                country = x.get('country_code', default)
                demand_partner1 = x['demand_partner_name']
                demand_partner_name = demand_partner1[:-4]
                tag_requests = x['demand_requests']
                ad_impressions = x['impressions']
                revenue = x['revenue']
                clicks = x['clicks']
                platform = 7

                list = (date, source_id, supply_source, country, demand_partner_name, tag_requests, ad_impressions, revenue, clicks, platform)
                #print(list)
    
                sql = """INSERT INTO springserve_market_private VALUES ("%s", "%s", "%s", "%s", "%s", "%s", "%s", "%s", "%s", "%s")""" % \
                        (date, source_id, supply_source, country, demand_partner_name, tag_requests, ad_impressions, revenue, clicks, platform)
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
