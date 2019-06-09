//======================================================================================================
//
//	tcp server socket workflow
//	
//		socket()
//		   |
//		bind() ip & port
//		   |
//		listen()
//		   |
//		accept()
//                 |
//              send()/recv()
//
//======================================================================================================
#include <stdio.h>
#include <stdlib.h>
#include <sys/socket.h>
#include <sys/types.h>
#include <netinet/in.h>
#include <unistd.h>


int main()
{
	// create string to hold data sent to clients with buffer size
	char server_message[256] = "You have reached the server.";

	// create the server socket. Use AF_NET because internet socket and tcp socket so user SOCK_STREAM. set protocol to 0
	int server_socket;
	server_socket = socket(AF_INET, SOCK_STREAM, 0);

	// define the server address structure
	struct sockaddr_in server_address;
	server_address.sin_family = AF_INET;
	server_address.sin_port = htons(9056); // user htons() to convert data format of port
	server_address.sin_addr.s_addr = INADDR_ANY; //INADDR_ANY resolves to any local ip address on machine

	// Bind socket to specified IP and port. first pass socket, cast address, size of server address
	bind(server_socket, (struct sockaddr*) &server_address, sizeof(server_address));

	// listen function to listen for connections.  pass server socket and backlog of how many connects can be waiting for connections
	listen(server_socket, 5);

	// int to hold client socket. use accept function set return value to client socket.  client socket = result of accept function.  two way connection
	// accept( server socket accetping socket, address of client connection where client connection coming from.  using NULL
	int client_socket;
	client_socket = accept(server_socket, NULL, NULL);

	// send the message to client socket. pass socket sending data on, the data to send, specify size of message, any flags
	send(client_socket, server_message, sizeof(server_message), 0);

	// close the socket
	close(server_socket);

	return 0;
}
