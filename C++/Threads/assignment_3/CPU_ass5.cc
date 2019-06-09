#include <iostream>
#include <list>
#include <iterator>
#include <unistd.h>
#include <signal.h>
#include <errno.h>
#include <stdio.h>
#include <sys/types.h>
#include <sys/wait.h>
#include <assert.h>
#include <cstring>

using namespace std;

#define NUM_SECONDS 20
#define EVER ;;

#define assertsyscall(x, y) if(!((x) y)){int err = errno; \
	fprintf(stderr, "In file %s at line %d: ", __FILE__, __LINE__); \
    	perror(#x); exit(err);}

#ifdef EBUG
#   define dmess(a) cout << "in " << __FILE__ << \
    " at " << __LINE__ << " " << a << endl;

#   define dprint(a) cout << "in " << __FILE__ << \
    " at " << __LINE__ << " " << (#a) << " = " << a << endl;

#   define dprintt(a,b) cout << "in " << __FILE__ << \
    " at " << __LINE__ << " " << a << " " << (#b) << " = " \
    << b << endl
#else
#   define dmess(a)
#   define dprint(a)
#   define dprintt(a,b)
#endif

#define WRITES(a) { const char *foo = a; write(1, foo, strlen(foo)); }
#define WRITEI(a) { char buf[10]; assert(eye2eh(a, buf, 10, 10) != -1); WRITES(buf); }


enum STATE { NEW, RUNNING, WAITING, READY, TERMINATED };

struct PCB
{
    STATE state;
    const char *name;   // name of the executable
    int pid;            // process id from fork();
    int ppid;           // parent process id
    int interrupts;     // number of times interrupted
    int switches;       // may be < interrupts
    int started;        // the time this process started
};

PCB *running;
PCB *idle;

// http://www.cplusplus.com/reference/list/list/
list<PCB *> new_list;//NOT USED
list<PCB *> processes;

int sys_time;

/*
** Async-safe integer to a string. i is assumed to be positive. The number
** of characters converted is returned; -1 will be returned if bufsize is
** less than one or if the string isn't long enough to hold the entire
** number. Numbers are right justified. The base must be between 2 and 16;
** otherwise the string is filled with spaces and -1 is returned.
*/
int eye2eh(int i, char *buf, int bufsize, int base)
{
    if(bufsize < 1) return(-1);
    buf[bufsize-1] = '\0';
    if(bufsize == 1) return(0);
    if(base < 2 || base > 16)
    {
        for(int j = bufsize-2; j >= 0; j--)
        {
            buf[j] = ' ';
        }
        return(-1);
    }

    int count = 0;
    const char *digits = "0123456789ABCDEF";
    for(int j = bufsize-2; j >= 0; j--)
    {
        if(i == 0)
        {
            buf[j] = ' ';
        }
        else
        {
            buf[j] = digits[i%base];
            i = i/base;
            count++;
        }
    }
    if(i != 0)
		return(-1);
    return(count);
}

/*
** a signal handler for those signals delivered to this process, but
** not already handled.
*/
void grab(int signum) { WRITEI(signum); WRITES("\n"); }

// c++decl> declare ISV as array 32 of pointer to function(int) returning void
void(*ISV[32])(int) = {
/*        00    01    02    03    04    05    06    07    08    09 */
/*  0 */ grab, grab, grab, grab, grab, grab, grab, grab, grab, grab,
/* 10 */ grab, grab, grab, grab, grab, grab, grab, grab, grab, grab,
/* 20 */ grab, grab, grab, grab, grab, grab, grab, grab, grab, grab,
/* 30 */ grab, grab
};

/*
** stop the running process and index into the ISV to call the ISR
*/
void ISR(int signum)
{
    if(signum != SIGCHLD)
    {
        if(kill(running->pid, SIGSTOP) == -1)
        {
            WRITES("In ISR kill returned: ");
            WRITEI(errno);
            WRITES("\n");
            return;
        }

        WRITES("In ISR stopped: ");
        WRITEI(running->pid);
        WRITES("\n");
        running->state = READY;
    }

    ISV[signum](signum);
}

/*
** an overloaded output operator that prints a PCB
*/
ostream& operator <<(ostream &os, struct PCB *pcb)
{
    os << "state:        " << pcb->state << endl;
    os << "name:         " << pcb->name << endl;
    os << "pid:          " << pcb->pid << endl;
    os << "ppid:         " << pcb->ppid << endl;
    os << "interrupts:   " << pcb->interrupts << endl;
    os << "switches:     " << pcb->switches << endl;
    os << "started:      " << pcb->started << endl;
    return(os);
}

/*
** an overloaded output operator that prints a list of PCBs
*/
ostream& operator <<(ostream &os, list<PCB *> which)
{
    list<PCB *>::iterator PCB_iter;
    for(PCB_iter = which.begin(); PCB_iter != which.end(); PCB_iter++)
    {
        os <<(*PCB_iter);
    }
    return(os);
}

/*
**  send signal to process pid every interval for number of times.
*/
void send_signals(int signal, int pid, int interval, int number)
{
    dprintt("at beginning of send_signals", getpid());

    for(int i = 1; i <= number; i++)
    {
        assertsyscall(sleep(interval), == 0);
        dprintt("sending", signal);
        dprintt("to", pid);
        assertsyscall(kill(pid, signal), == 0)
    }

    dmess("at end of send_signals");
}

struct sigaction *create_handler(int signum, void(*handler)(int))
{
    struct sigaction *action = new(struct sigaction);

    action->sa_handler = handler;

/*
**  SA_NOCLDSTOP
**  If  signum  is  SIGCHLD, do not receive notification when
**  child processes stop(i.e., when child processes  receive
**  one of SIGSTOP, SIGTSTP, SIGTTIN or SIGTTOU).
*/
    if(signum == SIGCHLD)
    {
        action->sa_flags = SA_NOCLDSTOP | SA_RESTART;
    }
    else
    {
        action->sa_flags =  SA_RESTART;
    }

    sigemptyset(&(action->sa_mask));
    assert(sigaction(signum, action, NULL) == 0);
    return(action);
}


// add states in scheduler//
void scheduler(int signum)
{
    WRITES("---- entering scheduler\n");
    assert(signum == SIGALRM);
    sys_time++;

	bool found_one = false;
	
	running->interrupts++;	

	for(int i = 0; i < (int)processes.size(); i++)
	{
		PCB *front = processes.front();
		processes.pop_front();
		processes.push_back(front);

		if(front->state == NEW)
		{
			front->state = RUNNING;
			front->ppid = getpid();
			front->interrupts = 0;
			front->switches = 0;
			front->started = sys_time;
			running = front;
			WRITES("Running New: ");

			WRITES(front->name);
			WRITES("\n");

			if((front->pid = fork()) == 0)
			{
				execl(front->name, front->name, NULL);
				//assertsyscall(execl(front->name, front->name, NULL), != -1);
			}
			
			found_one = true;

			break;
		}

		else if(front->state == READY)
		{
			front->state = RUNNING;
			running = front;
			
			WRITES("New process...");
			WRITEI(front->pid);

			if(running->pid != front->pid)
			{ 
				running->switches++;
			}
			

			if(kill(front->pid, SIGCONT) == -1)
			{
				WRITES(" ready ");
				kill(0, SIGTERM);
			}

			found_one = true;

			break;
		
			if(!found_one)
			{
				//continue idle

				idle->state = RUNNING;
				running = idle;

				if(kill(idle->pid, SIGCONT) == -1)
				{
					kill(0, SIGTERM);

				}
				
			}
		}
	}


    PCB* tocont = idle;

    WRITES("continuing");
    WRITEI(tocont->pid);
    WRITES("\n");

    //tocont->state = RUNNING;
    if(kill(running->pid, SIGCONT) == -1)
    {
        WRITES("in sceduler kill error: ");
        WRITEI(errno);
        WRITES("\n");
        return;
    }
    WRITES("---- leaving scheduler\n");

	cout << running;
}

void process_done(int signum)
{
    assert(signum == SIGCHLD);
    WRITES("---- entering process_done\n");

    // might have multiple children done.
    for(;;)
    {
        int status, cpid;

        // we know we received a SIGCHLD so don't wait.
        cpid = waitpid(-1, &status, WNOHANG);

        if(cpid < 0)
        {
            WRITES("cpid < 0\n");
            assertsyscall(kill(0, SIGTERM), != 0);
        }
        else if(cpid == 0)
        {
            // no more children.
            break;
        }
        else
        {
			//terminates
            WRITES("process exited: ");
			cout << running;  //ADDED from code
            WRITEI(cpid);
            WRITES("\n");
        }
    }
	
	running = idle;
	idle->state = RUNNING;
    WRITES("---- leaving process_done\n");
}


/*
** set up the "hardware"
*/
void boot()
{
    sys_time = 0;

    ISV[SIGALRM] = scheduler;
    ISV[SIGCHLD] = process_done;
    struct sigaction *alarm = create_handler(SIGALRM, ISR);
    struct sigaction *child = create_handler(SIGCHLD, ISR);

    // start up clock interrupt
    int ret;
    if((ret = fork()) == 0)
    {
        send_signals(SIGALRM, getppid(), 1, NUM_SECONDS);// num of seconds to run

        // once that's done, cleanup and really kill everything...
        delete(alarm);
        delete(child);
        delete(idle);
        kill(0, SIGTERM);
    }

    if(ret < 0)
    {
        perror("fork");
    }
}

void create_idle()
{
    idle = new(PCB);
    idle->state = READY;
    idle->name = "IDLE";
    idle->ppid = getpid();
    idle->interrupts = 0;
    idle->switches = 0;
    idle->started = sys_time;

    if((idle->pid = fork()) == 0)
    {
        pause();
        perror("pause in create_idle");
    }
}

int main(int argc, char **argv)
{

	/* NEW PCB STRUCT GETTING PUSHED ONTO BACK OF LIST IF ARGC DETECTED*/
	if (argc > 1)
	{
		for (int i = 1; i < argc; i++)
		{

			PCB *process;
			process = new(PCB);
			process->state = NEW;
			process->name = argv[i];
			process->interrupts = 0;
			process->switches = 0;
			process-> started = 0;

			processes.push_back(process);
		}
	}

			for(auto v: processes)
			{
				std::cout << v << endl;
			}
	
	boot();

    create_idle();
    running = idle;
    cout << running;

    // we keep this process around so that the children don't die and
    // to keep the IRQs in place.
    for(EVER)
    {
        // "Upon termination of a signal handler started during a
        // pause(), the pause() call will return."
        pause();
    }
}
