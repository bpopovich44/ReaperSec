#!/usr/bin/python2.7

import json
from mysql.connector import MySQLConnection, Error
from python_dbconfig import read_db_config
import aol_api

def connect():

    # """Gets AOL Data and writes them to a MySQL table"""
    db = "mysql_sl"
    api = "aol"

    report_book=[190031, 190032, 190147, 190148]


    # Connect To DB:
    db_config = read_db_config(db)

    try:
        print('Connecting to database...')
        conn = MySQLConnection(**db_config)

        if conn.is_connected():
            print('connection established.')

            cursor = conn.cursor()

            sql = "DROP TABLE IF EXISTS v3_core_today_media"
            cursor.execute(sql)

            sql = "CREATE TABLE v3_core_today_media (inventory_source varchar(255), media varchar(255), \
                    ad_opportunities bigint, market_opportunities bigint, ad_attempts bigint, ad_impressions bigint, \
                    ad_errors bigint, ad_revenue decimal(15, 5), clicks int, iab_viewability_measurable_ad_impressions bigint, \
                    iab_viewable_ad_impressions bigint)"
            cursor.execute(sql)

            # calls get_access_token function and starts script
            logintoken = aol_api.get_access_token(api)
            print(logintoken)

            for report in report_book:

                result = aol_api.run_existing_report(logintoken, str(report))
                #print(result)

                info = json.loads(result)
                #print(info)

                for x in json.loads(result)['data']:
                    inventory_source = x['row'][0]
                    media = x['row'][1].replace('"', " ")
                    ad_opportunities = x['row'][2]
                    market_opportunities = x['row'][3]
                    ad_attempts = x['row'][4]
                    ad_impressions = x['row'][5]
                    ad_errors = x['row'][6]
                    ad_revenue = x['row'][7]
                    clicks = x['row'][8]
                    iab_viewability_measurable_ad_impressions = x['row'][9]
                    iab_viewable_ad_impressions = x['row'][10]

                    list = (inventory_source, media, ad_opportunities, market_opportunities, ad_attempts, ad_impressions, \
                            ad_errors, ad_revenue, clicks, iab_viewability_measurable_ad_impressions, iab_viewable_ad_impressions)
       	            #print(list)

                    sql = """INSERT INTO v3_core_today_media VALUES ("%s", "%s", "%s", "%s", "%s", "%s", "%s", "%s", \
                            "%s", "%s", "%s")""" % (inventory_source, media, ad_opportunities, market_opportunities, ad_attempts, \
                            ad_impressions, ad_errors, ad_revenue, clicks, iab_viewability_measurable_ad_impressions, \
                            iab_viewable_ad_impressions)
                    cursor.execute(sql)
            
                cursor.execute('commit')
            
        else:
            print('Connection failed')
    
    except Error as error:
        print(error)
    
    finally:
        conn.close()
        print('Connection Closed')
    
if __name__ == '__main__':
    connect()
