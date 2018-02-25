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
            print('Connection established')

            cursor = conn.cursor()

            # Create Table:
            sql = "DROP TABLE IF EXISTS springserve_market_today"
            cursor.execute(sql)

            sql = "CREATE TABLE springserve_market_today (date varchar(25), hour varchar(2), demand_partner_name varchar(255), source_id varchar(10), \
                    supply_source varchar(255), total_requests bigint, ad_opportunities bigint, ad_impressions bigint, \
		    clicks bigint, revenue decimal(15, 5))"
            cursor.execute(sql)

            # call to get logintoken
            logintoken = springs_api.get_logintoken(api)
            print(logintoken)

            jsoninfo = {
                "date_range": "Today",
	        "interval": "hour",
	        "timezone": "America/Los_Angeles",
	        "dimensions": ["supply_tag_id", "demand_partner_id"],
                #"start_date": Today,
                #"endDate": Today,
                #"sort": [{ "field": "ad_revenue", "order": "desc"}] 
	        }

            result = springs_api.get_data(logintoken, jsoninfo)
            #print(result.text)

            info = json.loads(result.text)
            #print(info)

            # use default to populate null data
            default = '0'

            for x in info:
	        date1 = x['date']
	        date = date1[:10]
	        time1 = x['date']
	        time2 = time1[11:-8].replace("00", "*0").lstrip("0")
	        hour = time2.replace("*0", "0")
	        demand_partner1  = x['demand_partner_name']
	        demand_partner_name = demand_partner1[:-4]
	        source_id = x['supply_tag_id']
	        supply_source = x['supply_tag_name']
	        total_requests = x['demand_requests']
	        ad_opportunities = x['demand_requests']
	        ad_impressions = x['impressions']
	        clicks = x['clicks']
	        revenue = x['revenue']
		
	        list = (date, hour, demand_partner_name, source_id, supply_source, total_requests, ad_opportunities, ad_impressions, clicks, revenue)
                #print(list)

	        sql = """INSERT INTO springserve_market_today VALUES ("%s", "%s", "%s", "%s", "%s", "%s", "%s", "%s", "%s", "%s")""" % \
		        (date, hour, demand_partner_name, source_id, supply_source, total_requests, ad_opportunities, ad_impressions, clicks, revenue)
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
