#!/usr/bin/python2.7

import json
from mysql.connector import MySQLConnection, Error
from python_dbconfig import read_db_config
import aol_api

def connect():

    # """Gets AOL Data and writes them to a MySQL table"""
    db = "mysql_dl"
    api = "aol"

    # Connect To DB:
    db_config = read_db_config(db)

    try:
        print('Connecting to database...')
        conn = MySQLConnection(**db_config)

        if conn.is_connected():
            print('Connection established.')

            cursor = conn.cursor()

            # calls get_access_token function and starts script
            logintoken = aol_api.get_access_token(api)
            print(logintoken)

            result = aol_api.run_existing_report(logintoken, "189987")
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

                sql = """INSERT INTO dna_InventorySources_v2 VALUES ("%s", "%s", "%s", "%s", "%s", "%s", "%s", "%s", "%s", "%s", "%s", \
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
