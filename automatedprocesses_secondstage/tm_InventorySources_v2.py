#!/usr/bin/python2.7

import json
from mysql.connector import MySQLConnection, Error
from python_dbconfig import read_db_config
import aol_api

def connect():

    # """Gets AOL Data and writes them to a MySQL table"""
    db = "mysql_dl"
    api = "tm"

    report_book=[190598, 190599, 190601, 190602, 190603, 190605]

    # Connect To DB:
    db_config = read_db_config(db)

    try:
        print('Connecting to databse...')
        conn = MySQLConnection(**db_config)

        if conn.is_connected():
            print('Connection established')

            cursor = conn.cursor()

            sql = "DROP TABLE IF EXISTS tm_InventorySources_v2"
            cursor.execute(sql)

            sql = "CREATE TABLE tm_InventorySources_v2 (rownum INT NOT NULL AUTO_INCREMENT PRIMARY KEY, date varchar(25), inventory_source varchar(255), geo_country varchar(50), \
	            media varchar(255), ad_opportunities bigint, ad_attempts bigint, ad_impressions bigint, ad_revenue decimal(15,5), \
		    ecpm decimal(6,4), ad_errors int, iab_viewability_measurable_ad_impressions bigint, \
		    iab_viewable_ad_impressions bigint, market_ops varchar(255), clicks int)"
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
                    rownum = ''
                    date = x['row'][0]
                    inventory_source = x['row'][1].replace("'", " -").replace('"', "")
                    geo_country = x['row'][2].replace("'", "")
                    media = x['row'][3].replace('"', "").replace("'", "")
                    ad_opportunities = x['row'][4]
                    ad_attempts = x['row'][5]
                    ad_impressions = x['row'][6]
                    ad_revenue = x['row'][7]
                    ecpm = x['row'][8]
                    ad_errors = x['row'][9]
                    iab_viewability_measurable_ad_impressions = x['row'][10]
                    iab_viewable_ad_impressions = x['row'][11]
                    market_ops = x['row'][12]
                    clicks = x['row'][13].replace(" ", "0")

                    list = (rownum, date, inventory_source, geo_country, media,  ad_opportunities, ad_attempts, ad_impressions, \
                            ad_revenue, ecpm, ad_errors, iab_viewability_measurable_ad_impressions, iab_viewable_ad_impressions, market_ops, clicks)
                    #print(list)

                    sql = """INSERT INTO tm_InventorySources_v2 VALUES ("%s", "%s", "%s", "%s", "%s", "%s", "%s", "%s", "%s", "%s", "%s", \
                            "%s", "%s", "%s", "%s")""" % (rownum, date, inventory_source, geo_country, media, ad_opportunities, ad_attempts, ad_impressions, \
                            ad_revenue, ecpm, ad_errors, iab_viewability_measurable_ad_impressions, iab_viewable_ad_impressions, market_ops, clicks)
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

