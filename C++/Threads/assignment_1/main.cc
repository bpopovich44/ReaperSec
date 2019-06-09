#include <stdio.h>
#include <stdlib.h>
#include <sys/types.h>
#include <sys/wait.h>
#include <unistd.h>
#include <assert.h>

int main(int argc, char *argv[])
{
	//fork for new process
	pid_t PID = fork();

	//if fork returns less than 0, error occured
	if (PID < 0)
	{	
		assert(PID < 0);
		perror("Child creating failed..");
	}
	//a returned PID of 0 is the child process
	if (PID == 0)
	{
		assert(PID == 0);
		execl("./counter", "./counter", "5", NULL);
		exit(0);
	}


	// anthing greater than 0 return will be the parent process
	int wstatus = 0;
	pid_t childPID = wait(&wstatus);

	//checks child returns normally
	if(WIFEXITED(wstatus))
	{
		//WEXITSTATUS graps the exit status out of the jumble
		assert(printf("Process %d exited with status %d\n", childPID, WEXITSTATUS(wstatus)) != 0);
	}else{
		perror("returned false");
	}

	return 0;
}
