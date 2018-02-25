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
    page = 1
    
    # Connect to DB:
    db_config = read_db_config(db)

    try:
        print('Connecting to databse...')
        conn = MySQLConnection(**db_config)

        if conn.is_connected():
            print('Connection established.')

            cursor = conn.cursor()

            # Create Table:
            sql = "DROP TABLE IF EXISTS springserve_InventorySources_v2"
            cursor.execute(sql)

            sql = "CREATE TABLE springserve_InventorySources_v2(rownum INT NOT NULL AUTO_INCREMENT PRIMARY KEY, date varchar(25), \
                    inventory_source varchar(255), media varchar(255), ad_opportunities bigint, \
	            ad_attempts bigint, ad_impressions bigint, ad_revenue decimal(15,5), clicks int)"
            cursor.execute(sql)

            # call to get logintoken
            logintoken = springs_api.get_logintoken(api)
            print(logintoken)

            while page < 20:

                jsoninfo = {
	            "date_range": "Yesterday",
	            "interval": "day",
	            "timezone": "America/Los_Angeles",
	            "dimensions": ["supply_tag_id", "declared_domain"],
                    #"reportFormat": "JSON",
                    #"startDate": yesterday,
                    #"endDate": yesterday,
                    #"sort": [{ "field": "ad_revenue", "order": "desc"}] 
                    "page": str(page)
                    }
                print(str(page))
                result = springs_api.get_data(logintoken, jsoninfo)
                #print(result.text)

                info = json.loads(result.text)
                #print(info)

                # Use default ot populate null data
                default = 'Not Available'

                for x in info:
                    rownum = ''
                    date1 =x['date']
                    date = date1[:10]
                    inventory_source = x['supply_tag_name'].replace('"', "").replace("'", "")
                    media = x.get('declared_domain', default).replace("'", "").replace('"', "")
                    ad_opportunities = x['total_requests']
                    ad_attempts = x['opportunities']
                    ad_impressions = x['total_impressions']
                    ad_revenue = x['revenue']
                    clicks = x['clicks']

                    list = (rownum, date, inventory_source, media, ad_opportunities, ad_attempts, ad_impressions, \
                            ad_revenue, clicks)
                    print(list)

                    sql = """INSERT INTO springserve_InventorySources_v2 VALUES ("%s", "%s", "%s", "%s", "%s", "%s", "%s", "%s", "%s")""" % \
                            (rownum, date, inventory_source, media, ad_opportunities, ad_attempts, ad_impressions, ad_revenue, clicks)
                    cursor.execute(sql)

                cursor.execute('commit')
            
                page += 1
        
        else:
            print('Connection failed.')

    except Error as error:
        print(error)

    finally:
        conn.close()
        print('Connection closed.')

if __name__ == '__main__':
    connect()
    
