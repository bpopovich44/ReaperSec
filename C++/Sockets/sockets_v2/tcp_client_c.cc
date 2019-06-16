//============================================================================================
//
//	tcp client
//	- Create a socket
//	- Create a hint structure for the server we are connecting with
//	- Connect to the server on the socket
//	- while loop:
//		Enter lines of text
//		Send to the server
//		Wait for the response
//		Display the respose
//	- Close the socket
//
//
//===========================================================================================
#include <iostream>
#include <sys/types.h>
#include <unistd.h>
#include <sys/socket.h>
#include <netdb.h>
#include <arpa/inet.h>
#include <string.h>
#include <string>

using namespace std;


int main()

{
	// Create a socket
	int sock = socket(AF_INET,SOCK_STREAM, 0);
	if (sock == -1)
	{
		return 1;
	}
		
	
	// Create a hint structure for the server we are connecting with
	int port = 6973;
	string ipAddress = "127.0.0.1";
	sockaddr_in hint;
	hint.sin_family = AF_INET;
	hint.sin_port = htons(port);
	inet_pton(AF_INET, ipAddress.c_str(), &hint.sin_addr);
	
	// Connect to the server on the socket
	int connect_result = connect(sock, (sockaddr*)&hint, sizeof(hint));
	if (connect_result == -1)
	{
		return 1;
	}

	// while loop:
	char buf[4096];
	string userInput;

	do
	{

		// Enter lines of text
		cout << "> ";
		getline(cin, userInput);

		// Send to the server. (socket, buffer,size of buffer need plus one bcause c string has 0 at end, flags)
		int sendRes = send(sock, userInput.c_str(), userInput.size() + 1, 0);
		if (sendRes == -1)
		{
			cout << "Could not send to server... \r\n";
			continue;
		}
	

		// Wait for the response.  clear buffer
		memset(buf, 0, 4096);
		int bytesReceived = recv(sock, buf, 4096, 0);
		
		if (bytesReceived == -1)
		{
			cout << "There was an error getting response..." << endl;
		}
		else
		{	
			// Display the respose
			cout << "Server> " << string(buf, bytesReceived) << "\r\n";
		}
	
	}while(true);

	// Close the socket
	close(sock);

	return 0;
}
