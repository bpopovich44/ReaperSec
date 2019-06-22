//=============================================================================================================================
//
//		SERVER			CLIENT
//		-------			-------
//		socket()		socket()
//		   |                       |
//		setsocketopt()             |
//		   |                       |
//		bind() ip & port           |
//		   |                       |
//		listen()<-------------->connect()
//		   |			   |				
//		accept()                   |
//		   |                       |
//		send()/recv()		send()/recv()
//		   |                       |
//		closesocket()<--------->closesocket()
//
//		TCP Server					TCP Client
//		- create a socket				- create a socket
//		- bind a socket to IP/PORT			- create a hint structure for the servewe are connecting
//		- mark the socket for listening in		- connect to server on the socket
//		- accept a call					- while loop:
//		- close the listening socket				enter lines of text
//		- while receiving - display message			send to the server
//		- close socket						wait for the response
//									display the response
//								- close the socket
//=============================================================================================================================
#include <stdio.h>
#include <iostream>
#include <sys/types.h>
#include <unistd.h>
#include <sys/socket.h>
#include <netdb.h>
#include <arpa/inet.h>
#include <cstring>
#include <string.h>
#include <stdlib.h>
#include <netinet/in.h>



int main(int argc, char* argv[])
{










	return 0;
}


