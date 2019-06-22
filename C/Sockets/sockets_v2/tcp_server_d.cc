//==============================================================================
//	TCP Server 
//
// 	- Create a socket
// 	- Bind a socket to IP / port
// 	- Mark the socket for listening in
// 	- Accept a call
// 	- Close the listening socket
// 	- While receiving - display message, echo message
// 	- Close socket
//
//==============================================================================
#include <iostream>
#include <sys/types.h>
#include <unistd.h>
#include <sys/socket.h>
#include <netdb.h>
#include <arpa/inet.h>
#include <cstring>
#include <string.h>

using namespace std;

int main()
{


	// Create a socket.  User AF_NET because internet socket and tcp socket so user SOCK_STREAM, set protocol to 0
	int listening = socket(AF_INET, SOCK_STREAM, 0);
	if (listening == -1)
	{
		cerr << "Can't create socket...";
		return -1;
	}

	// define the server address structure
	struct sockaddr_in server_address;	// sockadd_in for version 4
	server_address.sin_family = AF_INET;
	server_address.sin_port = htons(6973);	// because intel processor and little indian, need htons() "host to network short" to convert to network short. user htons() to convert data format of port
	//inet_pton(AF_INET, "0.0.0.0", &server_address.sin_addr);	//internet command pointer to string to number convert number to array of integers. takes ip address string 
	server_address.sin_addr.s_addr = INADDR_ANY;
	// Bind a socket to IP / port
	if (bind(listening, (struct sockaddr*) &server_address, sizeof(server_address)) == -1) // bind this socket, using this format , to this server_address structure
	{
		cerr << "Can't bind to IP port..." << endl;;
		return -2;
	}

	// Mark the socket for listening in
	if (listen(listening, SOMAXCONN) == -1) // maximum number of connectios
	{ 
		cerr << " Can't listen..." << endl;;
		return -3;
	}

	// Accept a call
	
	sockaddr_in client;
	socklen_t clientSize = sizeof(client);
	char host[NI_MAXHOST]; // buffers putting name in size 1025
	char svc[NI_MAXSERV];  // buffer putting name in size 32
	
	int clientSocket = accept(listening,
				  (sockaddr*)&client,
		       		  &clientSize);
	if (clientSocket == -1)
	{
		cerr << "Problem with client connecting..." << endl;;
		return -4;
	}

	// Close the listening socket
	close(listening);
	
	// clean up buffer
	memset(host, 0, NI_MAXHOST);
	memset(svc, 0, NI_MAXSERV);

	// get name of computer
	int result = getnameinfo((sockaddr*)&client,
	    			sizeof(client),
				host,
				NI_MAXHOST,
				svc,
				NI_MAXSERV,
				0);
	
	if (result)
	{
		cout << host << " connect on " << svc << endl;
	}
	else
	{	// place to put host, location of address, where want to go, maximum size of buffer
		inet_ntop(AF_INET, &client.sin_addr, host,NI_MAXHOST); // numeric array to string
		cout << host << "connect on " << ntohs(client.sin_port) << endl;
	}

	// While receiving - display message, echo message
	char buf[4096];
	while(true)
	{
		// clear buffer
		memset(buf, 0, 4096);
		// wait for message 
		int byteRecv = recv(clientSocket, buf, 4096, 0);
		if (byteRecv == -1)
		{
			cerr << "There was a connection issue..." << endl;
			break;
		}
		
		if (byteRecv == 0)
		{
			cout << "The client disconnected..." << endl;
		}

		// display message 
		cout << "Received: " << string(buf, 0,byteRecv) << endl;
		
		// resend message + 1 because need 0 at end...
		send(clientSocket, buf, byteRecv + 1, 0);
	}
	
	// Close socket
	close(clientSocket);


	return 0;
}
