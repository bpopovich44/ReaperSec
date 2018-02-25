#!/usr/bin/python2.7

import json
from mysql.connector import MySQLConnection, Error
from python_dbconfig import read_db_config
import aol_api_R

def connect():

    # """Gets AOL Data and writes them to a MySQL table"""
    db = "mysql_sa"
    api = "dc"

    # Connect To DB:
    db_config = read_db_config(db)

    try:
        print('Connecting to database...')
        conn = MySQLConnection(**db_config)

        if conn.is_connected():
            print('Connection established')

            cursor = conn.cursor()

            sql = "DROP TABLE IF EXISTS dc_site_addition"
            cursor.execute(sql)

            sql = "CREATE TABLE dc_site_addition (media varchar(255), ad_revenue decimal(15, 5))"
            cursor.execute(sql)

            # calls get_access_token function and starts script
            logintoken = aol_api_R.get_access_token(api)
            print(logintoken)

            result = aol_api_R.run_existing_report(logintoken, "197788")
            #print(result)

            info = json.loads(result)
            #print(info)

            for x in json.loads(result)['data']:
	        media = x['row'][0]
	        ad_revenue = x['row'][1]

	        list = (media, ad_revenue)
	        #print(list)

	        sql = """INSERT INTO dc_site_addition VALUES ("%s", "%s")""" % (media, ad_revenue)
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

