#!/usr/bin/python2.7

import sys
import json
import time
import aol_api
from python_dbconfig import read_db_config
from data_file import report_book 
from mysql.connector import MySQLConnection, Error

todaysdate = time.strftime("%Y-%m-%d %H:%M:%S")

def connect():

    # """Gets AOL Data and writes them to a MySQL table"""
    db = "mysql_dl"
    report_type = "Domain_v2"
    p_name = sys.argv[1]
    db_updated = False

    # Connect To DB:
    db_config = read_db_config(db)

    try:
        #print('Connecting to database...')
        conn =  MySQLConnection(**db_config)

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
    
                        sql = "DROP TABLE IF EXISTS " + p_name + "_domain_v2"
                        cursor.execute(sql)
    
                        sql = "CREATE TABLE " + p_name + "_domain_v2 (date varchar(25), media varchar(255) CHARACTER SET 'utf8', \
                            ad_opportunities bigint, ad_attempts bigint, ad_impressions bigint, ad_revenue decimal(15, 5), ecpm decimal(6, 4))"
                        cursor.execute(sql)
                
                        db_updated = True

            print(str(todaysdate) + "  Running " + p_name + "_domain_v2 with report # " + str(report)) 
            for x in json.loads(result)['data']:
                    date = x['row'][0]
                    media = x['row'][1].replace('"', " ")
                    ad_opportunities = x['row'][2]
                    ad_attempts = x['row'][3]
                    ad_impressions = x['row'][4]
                    ad_revenue = x['row'][5]
                    ecpm = x['row'][6]

                    list = (date, media, ad_opportunities, ad_attempts, ad_impressions, \
                            ad_revenue, ecpm)
                    #print(list)

                    sql = """INSERT INTO """ + p_name + """_domain_v2 VALUES ("%s", "%s", "%s", "%s", "%s",\
                            "%s", "%s")""" % (date, media, ad_opportunities, ad_attempts, ad_impressions, ad_revenue, ecpm)
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
