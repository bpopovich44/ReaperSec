#!/usr/bin/python2.7

import sys
import json
import time
import aol_api
from mysql.connector import MySQLConnection, Error
from python_dbconfig import read_db_config
from data_file import report_book
from data_file import platforms

todaysdate = time.strftime("%Y-%m-%d %H:%M:%S")

def connect():

    # """Gets AOL Data and writes them to a MySQL table"""
    db = "mysql_eom"
    report_type = "market_public_eom"
    p_name = sys.argv[1]
    p_id = platforms[p_name]["id"]
    m_id = platforms[p_name]["market_id"]["public"]
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
            #print(logintoken)

            for report in report_book[report_type][p_name]:
        
                result = aol_api.run_existing_report(logintoken, str(report))
                #print(result)
    
                if len(result) == 0:
                    break

                if len(result) >= 1:
                    if db_updated == False:

                        sql = "DROP TABLE IF EXISTS " + p_name + "_market_public_EOM"
                        cursor.execute(sql)

                        sql = "CREATE TABLE " + p_name + "_market_public_EOM (date varchar(25), inventory_source varchar(255), \
                            geo_country varchar(50), ad_opportunities varchar(2), ad_attempts bigint, ad_impressions bigint, \
                            ad_revenue decimal(15, 5), ecpm decimal(6, 4), media_spend decimal(15, 5), completed_views int, \
                            clicks int, platform int, market_id int)"
                        cursor.execute(sql)

                        db_updated = True

                print(str(todaysdate) + "  Running " + p_name + "_market_public_EOM id " + str(p_id) + " with report # " + str(report))
                for x in json.loads(result)['data']:
	            date = x['row'][0]
	            inventory_source = x['row'][1].replace("'", " -")
            	    geo_country = x['row'][2].replace(",", " -")
                    ad_opportunities = '0'
                    ad_attempts = x['row'][4]
	            ad_impressions = x['row'][5]
	            ad_revenue = x['row'][6]
	            ecpm = x['row'][7]
	            media_spend = x['row'][8]
	            completed_views = x['row'][9]
        	    clicks = x['row'][10].replace(" ", "0")
	            platform = str(p_id)
                    market_id = str(m_id)

	            list = (date, inventory_source, geo_country, ad_opportunities, ad_attempts, ad_impressions, \
                        ad_revenue, ecpm,  media_spend, completed_views, clicks, platform, market_id)
        	    #print(list)

	            sql = """INSERT INTO """ + p_name + """_market_public_EOM VALUES ("%s", "%s", "%s", "%s", \
                            "%s", "%s", "%s", "%s", "%s", "%s", "%s", "%s", "%s")""" % (date, inventory_source, \
                            geo_country, ad_opportunities, ad_attempts, ad_impressions, ad_revenue, ecpm, \
                            media_spend, completed_views, clicks, platform, market_id)
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
