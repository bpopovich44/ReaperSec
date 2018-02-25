#!/usr/bin/python2.7

import json
from mysql.connector import MySQLConnection, Error
from python_dbconfig import read_db_config
import aol_api

def connect():

    # """Gets AOL Data and writes them to a MySQL table"""
    db = "mysql_sa"
    platform = "adsym"
    report = "197789"

    platforms = ["adsym", "adtrans", "dc", "tm"]
    #platform = ("adsym", "adtrans", "dc", "tm")
    report_book = [197789, 197863, 197788, 197791]

    # Connect To DB:
    db_config = read_db_config(db)

    try:
        print('Connecting to database...')
        conn = MySQLConnection(**db_config)

        if conn.is_connected():
            print('Connection established')

            cursor = conn.cursor()

            for platform, report in zip(platforms, report_book):

                print("Running " + str(platform) + "_site addition with report # " + str(report))
                sql = "DROP TABLE IF EXISTS " + str(platform) + "_site_addition"
                cursor.execute(sql)

                sql = "CREATE TABLE " + str(platform) + "_site_addition (media varchar(255), ad_revenue decimal(15, 5))"
                cursor.execute(sql)

                # calls get_access_token function and starts script
                logintoken = aol_api.get_access_token(platform)
                print(logintoken)

                result = aol_api.run_existing_report(logintoken, str(report))
                #print(result)

                info = json.loads(result)
                #print(info)

                for x in json.loads(result)['data']:
	            media = x['row'][0]
	            ad_revenue = x['row'][1]

	            list = (media, ad_revenue)
	            #print(list)

	            sql = """INSERT INTO """ + str(platform) + """_site_addition VALUES ("%s", "%s")""" % (media, ad_revenue)
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

