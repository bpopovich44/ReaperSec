#include <stdio.h>
#include <signal.h>
#include <unistd.h>
#include <sys/types.h>
#include <stdlib.h>
#include <sys/wait.h>
#include <assert.h>


//SIGNAL HANDLER FOR INCOMING SIGNALS
void handler(int signum)
{
	switch(signum)
	{
		case 1: 
			write(1, "PARENT: Received (1)SIGHUP --> Interrupting signal...\n", 55);
			break;

		case 4:
			write(1, "PARENT: Recieved a (4)SIGILL --> Interrupting signal...\n", 57);
			break;

		case 14:
			write(1, "PARENT: Received a (14)SIGALRM from CHILD --> Interrupting signal...\n", 70);
			break;	
	}
}


//FUNCTIONS FOR PARENT-CHILD-ERROR AFTER FORK
void function_error()
{
	perror("error did not fork");
	exit(1);
}

void function_child()
{
	execl("./child", "./child", "3", NULL);
}

int function_parent(int child_pid)
{
	int parentPID = getpid();
	int childPID = child_pid;

	void (*phandler)(int);
	phandler = &handler;

	// Creating sigaction to handle all signals coming to process
	struct sigaction han_solo;
	sigemptyset(&han_solo.sa_mask);  // EMPTIES THE sa_mask TO ENSURE NO SIGNAL IS BLOCKED
	han_solo.sa_flags = SA_RESTART;  // WHEN ESTABLISHING A SIGNAL HANDLER
	
	//Process Signal Mask(PSM)
	// Block SIGTERM not permitted to interrupt execution of handler
	sigset_t darthVader, oldest;
	sigemptyset(&darthVader);
	sigaddset(&darthVader, SIGTERM);
	sigprocmask(SIG_BLOCK, &darthVader, &oldest);

	//Signal catcher with error handling...
	han_solo.sa_handler = *phandler;
	{
		if (sigaction(SIGHUP, &han_solo, NULL) < 0)
		{
			perror("sigaction()");
		}		
	
		if (sigaction(SIGALRM, &han_solo, NULL) < 0)
		{
			perror("sigaction()");
		}	
	
		if (sigaction(SIGILL, &han_solo, NULL) < 0)
		{
			perror("sigaction()");
		}
	}

	printf("PARENT: I am alive...  PID --> %d\n", parentPID);
	printf("PARENT: Sending SIGHUP to CHILD...\n");
	sleep(5);
	kill(childPID, SIGHUP);

	int wstatus = 0;
	pid_t childReturn = wait(&wstatus);

	//Checks child returns normally
	if(WIFEXITED(wstatus))
	{
		printf("CHILD %d: exited with status %d\n", childReturn, WEXITSTATUS(wstatus));
	}else {
		perror("returned false");
	}
	
	return 0;
}



//MAIN FUNCTION
int main(void)
{
	pid_t childPID = fork();
	
	if (childPID < 0)
		function_error();
	if (childPID == 0)
		function_child();
	if (childPID > 0)
		function_parent(childPID);
}
