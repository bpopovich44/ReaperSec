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
from data_file import fees

todaysdate = time.strftime("%Y-%m-%d %H:%M:%S")
yesterday = datetime.date.fromordinal(datetime.date.today().toordinal()-1).strftime("%F")

def connect():

    # """Gets AOL Data and writes them to a MySQL table"""
    db = "mysql_sl"
    report_type = "core_yesterday_media"
    p_name = sys.argv[1]
    p_id = platforms[p_name]["id"]
    gross_rev = platforms[p_name]["fee"]
    r = fees["aol_platform"]
    a_cost = fees["aol_cost"]
    platform_rev = p_name + "_revenue"

    # Connect To DB:
    db_config = read_db_config(db)

    try:
        #print('Connecting to database...')
        conn = MySQLConnection(**db_config)

        if conn.is_connected():
            #print('Connection established.')

            cursor = conn.cursor()
 
            sql = "DROP TABLE IF EXISTS " + p_name + "_core_yesterday_media"
            cursor.execute(sql)

            sql = "CREATE TABLE " + p_name + "_core_yesterday_media (date varchar(25), hour int, inventory_source varchar(255), \
                    media varchar(255), ad_opportunities bigint, market_opportunities bigint, ad_attempts bigint, \
                    ad_impressions bigint, ad_errors bigint, ad_revenue decimal(15, 5), aol_cost decimal(15,5), \
                    epiphany_gross_revenue decimal(15, 5)," + p_name + "_revenue decimal(15, 5), clicks int, \
                    iab_viewability_measurable_ad_impressions bigint, iab_viewable_ad_impressions bigint, platform int)"
            cursor.execute(sql)

            # calls get_access_token function and starts script
            logintoken = aol_api.get_access_token(p_name)
            #print logintoken

            for report in report_book[report_type][p_name]:

                print(str(todaysdate) + "  Running " + p_name + "_core_yesterday_media report # " + str(report))
                # Make Calls And Write To DB:
                result = aol_api.run_existing_report(logintoken, str(report))
                #print(result)
    
                # Make Calls And Write To DB:
                for x in json.loads(result)['data']:
                    date = x['row'][0]
                    hour = x['row'][1]
                    inventory_source = x['row'][2]
                    media = x['row'][3].replace('"', " ")
                    ad_opportunities = x['row'][4]
                    market_opportunities = x['row'][5]
                    ad_attempts = x['row'][6]
                    ad_impressions = x['row'][7]
                    ad_errors = x['row'][8]
                    ad_revenue = x['row'][9]
                    aol_cos = x['row'][9]
                    epiphany_gross_rev = x['row'][9]
                    platform_rev = x['row'][9]
                    clicks = x['row'][10]
                    iab_viewability_measurable_ad_impressions = x['row'][11]
                    iab_viewable_ad_impressions = x['row'][12]
                    platform = str(p_id)

                    list = (date, hour, inventory_source, media, ad_opportunities, market_opportunities, ad_attempts, \
                            ad_impressions, ad_errors, ad_revenue, aol_cos, epiphany_gross_rev, platform_rev, clicks, \
                            iab_viewability_measurable_ad_impressions, iab_viewable_ad_impressions, platform)
                    #print(list)

                    if p_name == 'dna':
                        aol_cost = "0"
                        epiphany_gross_revenue = "0"
                        platform_revenue = "0"
                    else:
                        aol_cost = float(float(aol_cos) * float(a_cost))
                        epiphany_gross_revenue = float(float(epiphany_gross_rev) * float(gross_rev))
                        platform_revenue = float(float(platform_rev) * float(r))

                    sql = """INSERT INTO """ + p_name + """_core_yesterday_media VALUES ("%s", "%s", "%s", "%s", "%s", "%s", \
                            "%s", "%s", "%s", "%s", "%s", "%s", "%s", "%s", "%s", "%s", "%s")""" % (date, hour, inventory_source, \
                            media, ad_opportunities, market_opportunities, ad_attempts, ad_impressions, ad_errors, ad_revenue, \
                            aol_cost, epiphany_gross_revenue, platform_revenue, clicks, iab_viewability_measurable_ad_impressions, \
                            iab_viewable_ad_impressions, platform)
                    cursor.execute(sql)

                cursor.execute('commit')
    
        else:
            print('Connection failed')

    except Error as error:
        print(error)

    finally:
        conn.close()
        #print('Connection closed.')


if __name__ == '__main__':
    connect()
