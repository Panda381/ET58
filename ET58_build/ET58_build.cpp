
#include <stdio.h>
#ifdef __linux__
#include <time.h>
#include <sys/time.h>
#else
#include <Windows.h>
#endif

// main function
int main(int argc, char* argv[])
{
	if (argc != 2)
	{
		printf("Syntax: Enter calculator name\n");
		return 2;
	}
#ifdef __linux__
	struct timeval TV;
	struct tm *TM;
	gettimeofday(&TV,NULL);
	TM=localtime(&TV.tv_sec);
#else
	SYSTEMTIME st;
	GetLocalTime(&st);
#endif
	printf("; %s build version, auto generated, do not modify!\n\n"
			"\t.text\n\n"
			".global Build\n"
			"Build:	.asciz\t\"%s %02d%02d%02d\"\n"
#ifdef __linux__
			"\t.balign\t2\n", argv[1], argv[1], TM->tm_year-100, TM->tm_mon+1, TM->tm_mday);
#else
			"\t.balign\t2\n", argv[1], argv[1], st.wYear-2000, st.wMonth, st.wDay);
#endif
	return 0;
}

