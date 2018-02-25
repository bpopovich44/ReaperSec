#!/usr/bin/python2.7

import json
from mysql.connector import MySQLConnection, Error
from python_dbconfig import read_db_config
import aol_api_R

def connect():

    # """Gets AOL Data and writes them to a MySQL table"""
    db = "mysql_dl"
    api = "adsym"

    # Connect To DB:
    db_config = read_db_config(db)

    try:
        print('Connecting to database...')
        conn =  MySQLConnection(**db_config)

        if conn.is_connected():
            print('Connection established.')

            cursor = conn.cursor()

            sql = "DROP TABLE IF EXISTS adsym_domainreport_v2"
            cursor.execute(sql)

            sql = "CREATE TABLE adsym_domainreport_v2 (date varchar(25), media varchar(255) CHARACTER SET 'utf8',ad_opportunities bigint, \
                    ad_attempts bigint, ad_impressions bigint, ad_revenue decimal(15, 5), ecpm decimal(6, 4))"
            cursor.execute(sql)

            # calls get_access_token function and starts script
            logintoken = aol_api_R.get_access_token(api)
            print(logintoken)

            result = aol_api_R.run_existing_report(logintoken, "161179")
            #print(result)

            info = json.loads(result)
            #print(info)

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

                sql = """INSERT INTO adsym_domainreport_v2 VALUES ("%s", "%s", "%s", "%s", "%s",\
                        "%s", "%s")""" % (date, media, ad_opportunities, ad_attempts, ad_impressions, ad_revenue, ecpm)
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
