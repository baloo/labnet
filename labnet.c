#define _GNU_SOURCE
#include <limits.h>
#include <sched.h>
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/mman.h>
#include <sys/utsname.h>
#include <sys/wait.h>
#include <unistd.h>

#define errExit(msg)                                                           \
	do {                                                                   \
		perror(msg);                                                   \
		exit(EXIT_FAILURE);                                            \
	} while (0)

#define STACK_SIZE (1024 * 1024) /* Stack size for cloned child */

static int childFunc(char *argv[])
{
	char buf[PATH_MAX];
	sprintf(&buf, "/proc/%d/ns/net", getpid());

	unlink("./netns");
	symlink(&buf, "./netns");
	execvp(argv[0], argv);

	return 0;
}

void main(int argc, char *argv[])
{
	char *stack;
	char *stackTop;
	pid_t pid;
	int status;

	stack = mmap(NULL, STACK_SIZE, PROT_READ | PROT_WRITE,
		     MAP_PRIVATE | MAP_ANONYMOUS | MAP_STACK, -1, 0);
	if (stack == MAP_FAILED)
		errExit("mmap");

	stackTop = stack + STACK_SIZE;

	pid = clone(childFunc, stackTop, CLONE_NEWNET | SIGCHLD | CLONE_NEWUSER,
		    argv+1);
	if (pid == -1)
		errExit("clone");

	if (waitpid(pid, &status, 0) == -1)
		errExit("waitpid");

	return status;
}
