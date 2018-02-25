#!/usr/bin/python2.7

import sys
import json
import time 
import datetime
import aol_api
from mysql.connector import MySQLConnection, Error
from python_dbconfig import read_db_config
from data_file import report_book
from data_file import platforms

todaysdate = time.strftime("%Y-%m-%d %H:%M:%S")

def connect():

    # """Gets AOL Data and writes them to a MySQL table"""
    db = "mysql_sl"
    report_type = "market_today"
    p_name = sys.argv[1]
    p_id = platforms[p_name]["id"]
    db_updated = False

    # Connect To DB:
    db_config = read_db_config(db)

    try:
        #print('Connecting to database...')
        conn = MySQLConnection(**db_config)

        if conn.is_connected():
            #print('Connection established.')
    
            cursor = conn.cursor()
   
            # calls get_access_token function and starts script
            logintoken = aol_api.get_access_token(p_name)
            #print logintoken

            for report in report_book[report_type][p_name]:

                result = aol_api.run_existing_report(logintoken, str(report))
                #print(result)
        
                if len(result) == 0:
                    break

                row_count_value = json.loads(result)['row_count']
    
                if int(row_count_value) >= 1:
                    if db_updated == False:

                        sql = "DROP TABLE IF EXISTS " + p_name + "_market_today"
                        cursor.execute(sql)

                        sql = "CREATE TABLE " + p_name + "_market_today (date varchar(50), hour int, buyer_organization varchar(255), \
                            inventory_source varchar(255),  market_opportunities bigint, ad_attempts bigint, \
                            ad_impressions bigint, ad_errors bigint, ad_revenue decimal(15, 5), total_clicks int, \
                            iab_viewability_measurable_ad_impressions bigint, iab_viewable_ad_impressions bigint, platform int)"
                        cursor.execute(sql)

                        db_updated = True

                print(str(todaysdate) + "  Running " + p_name + "_market_today id_ " + str(p_id) + " report # " + str(report))
                for x in json.loads(result)['data']:
                    date = x['row'][0]
                    hour = x['row'][1]
	            buyer_organization = x['row'][2]
	            inventory_source = x['row'][3]
	            market_opportunities = x['row'][4]
	            ad_attempts = x['row'][5]
	            ad_impressions = x['row'][6]
	            ad_errors = x['row'][7]
	            ad_revenue = x['row'][8]
	            total_clicks = x['row'][9]
	            iab_viewability_measurable_ad_impressions = x['row'][10]
	            iab_viewable_ad_impressions = x['row'][11]
	            platform = str(p_id)

	            list = (date, hour, buyer_organization, inventory_source, market_opportunities, ad_attempts, ad_impressions, \
                            ad_errors, ad_revenue, total_clicks, iab_viewability_measurable_ad_impressions, \
                            iab_viewable_ad_impressions, platform)
                    #print(list)

                    sql = """INSERT INTO """ + p_name + """_market_today VALUES ("%s", "%s", "%s", "%s", "%s", "%s", "%s", \
                            "%s", "%s", "%s", "%s", "%s", "%s")""" % (date, hour, buyer_organization, inventory_source, \
                            market_opportunities, ad_attempts, ad_impressions, ad_errors, ad_revenue, total_clicks, \
                            iab_viewability_measurable_ad_impressions, iab_viewable_ad_impressions, platform)
	            cursor.execute(sql)
        
                cursor.execute('commit')
            
        else:
            print('Connection failed.')

    except Error as error:
        print(error)

    finally:
        conn.close()
        #print('Connection closed.')


if __name__ == '__main__':
    connect()

