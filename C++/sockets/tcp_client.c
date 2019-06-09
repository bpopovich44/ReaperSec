//===========================================================================================
//
//
//	TCP - CLIENT SOCKET work flow
//	 socket()
//	   |
//	 connect()
//	   |
//	 recv()
//
//
//===========================================================================================
#include <stdio.h>
#include <stdlib.h>
#include <sys/types.h>
#include <sys/socket.h>
#include <netinet/in.h>
#include <unistd.h>


int main()
{

	// Create a socket
	int network_socket;
	// Call socket function AF_INET is created in header file which is domain of socket.  
	// sinse use tcp, use created SOCK_STREAM which is type of connection socket
	network_socket = socket(AF_INET, SOCK_STREAM, 0); 


	// specify an address for the socket
	struct sockaddr_in server_address;
	server_address.sin_family = AF_INET; // specify address family, which is first param passed in AF_INET
	server_address.sin_port = htons(9056); // specify port to connect to
	server_address.sin_addr.s_addr = INADDR_ANY; // specify the ip address to connect to.  use INADDR_ANY which is already in libray because using 0.0.0.0, can use specific IP address


	// call the connect function
	// first param is actual socket, cast server address structure sock_addrin to struct sock_addr, pass address because pointer, size of address
	int connection_status = connect(network_socket, (struct sockaddr *) &server_address, sizeof(server_address));

	
	// connect returns integer so use error handling.  Return 0 for true and -1 for false
	if (connection_status == -1)
	{
		printf("There was an error making a connection to the remote socket \n");
	}	
	

	// call recv function to receive data from the server. first param is socket, place to hold data we get back from server, pass address from recieve function to hold data, pass size of data(buffer),
	// optional flag paramater leaving at 0
	char server_response[256]; //buffer size to hold data received back from server
	recv(network_socket, &server_response, sizeof(server_response), 0);

	//print out data we received
	printf("The server sent the data: %s\n", server_response);

	//close socket
	close(network_socket);



	return 0;
}
