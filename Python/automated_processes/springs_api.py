import requests
import json
from data_file import platforms

def get_logintoken(platform):

    client_id = platforms[platform]["access"]['id']
    client_secret = platforms[platform]["access"]['secret']

    jsonlogin = {
            "email": client_id,
            "password": client_secret 
            }

    # Authenticate
    response = requests.post('https://video.springserve.com/api/v0/auth', json=jsonlogin)
    logintoken = response.json()['token']
 
    return logintoken
    

def get_data(logintoken, jsoninfo):

    header = {"Content-Type": "application/json", "Authorization": logintoken}
    return requests.post('https://video.springserve.com/api/v0/report', headers=header, json=jsoninfo)


