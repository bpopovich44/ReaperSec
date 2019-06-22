#!/usr/bin/python2.7

import sys
import json
import time
import aol_api
from data_file import report_book
from mysql.connector import MySQLConnection, Error
from python_dbconfig import read_db_config

todaytime = time.strftime("%Y-%m-%d %H:%M:%S")

def connect():

    # """Gets AOL Data and writes them to a MySQL table"""
    db = "mysql_sa"
    report_type = "site_additions"
    p_name = sys.argv[1]

    # Connect To DB:
    db_config = read_db_config(db)

    try:
        #print('Connecting to database...')
        conn = MySQLConnection(**db_config)

        if conn.is_connected():
            #print('Connection established')
            
            cursor = conn.cursor()

            sql = "DROP TABLE IF EXISTS " + p_name + "_site_addition"
            cursor.execute(sql)

            sql = "CREATE TABLE " + p_name + "_site_addition (date varchar(50), media varchar(255), ad_revenue decimal(15, 5))"
            cursor.execute(sql)

            # calls get_access_token function and starts script
            logintoken = aol_api.get_access_token(p_name)
            #print(logintoken)

            for report in report_book[report_type][p_name]:

                print(str(todaytime) + "  Running " + p_name + "_site addition with report # " + str(report))
                result = aol_api.run_existing_report(logintoken, str(report))
                #print(result)

                for x in json.loads(result)['data']:
                    date = x['row'][0]
                    media = x['row'][1]
                    ad_revenue = x['row'][2]

                    list = (date, media, ad_revenue)
                    #print(list)

                    sql = """INSERT INTO """ + p_name + """_site_addition VALUES ("%s", "%s", "%s")""" % (date, media, ad_revenue)
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

