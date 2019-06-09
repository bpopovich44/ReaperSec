#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <signal.h>
#include <sys/types.h>
#include <sys/wait.h>
#include <assert.h>


void handler (int signum)
{
	switch(signum)
	{
		case 1:
			write(1,"CHILD: Received a (1)SIGHUP form parent.\n", 42);
			break;
	}
}

int main(int argc, char *argv[])
{
	pid_t  PID = (int) getpid();
	pid_t parentPID = (int) getppid();

	int i, input;
	
	void (*phandler)(int);
	phandler = &handler;
	
	//Assert to confirm an arguement was received from PARENT
	assert(argv[1] != NULL);
	input = strtol(argv[1], NULL, 10);
	
	//Assert to meet HW requirement
	assert(input == 3);	
	
	//Set up sigaction to handle signals
	struct sigaction chewbacca;
	sigemptyset(&chewbacca.sa_mask);
	chewbacca.sa_flags = SA_RESTART;

	//Set up handler for signals
	chewbacca.sa_handler = *phandler;  
	
	if (sigaction(SIGHUP, &chewbacca, NULL) < 0)
	{
		perror("sigaction()");
	}
	
	printf("CHILD: I am alive... PID --> %d\n", PID);	
	printf("CHILD: Sending SIGILL  to PARENT...\n");
	kill(parentPID, SIGILL);
	printf("CHILD: Sending SIGTERM to PARENT...\n");
	kill(parentPID, SIGTERM);
	printf("CHILD: SIGTERM was blocked by Process Signal Mask...\n");
	printf("CHILD: Sending SIGALRM to PARENT...\n");
	kill(parentPID, SIGALRM);
	printf("CHILD: Sending -- 3 -- SIGHUP to PARENT...\n");
	for (i = 1; i <= input; i++)
	{
		kill(parentPID, SIGHUP);
	}

	exit(0);
}
