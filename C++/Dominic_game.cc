//==================================================================
//
//	Guessing game for Dominic
//
//==================================================================
#include <iostream>
#include <ctime>
#include <cstdlib>
#include <limits>

using namespace std;


int new_random_number(int &x)
{
	int number = x;
	
	srand(time(NULL));
	int random_number = (rand() % number) + 1;
	
	return random_number;
}


int main()
{
	//  Variables
	int tries = 0;
	int tries_allowed = 10;
	int MAX_NUMBER = 100;
	char playGame;
	int guess_number;
	int random_number;
	string name;

	//  Pointers
 	int* ptries = &tries;
	int* ptralwd = &tries_allowed;
	char* pG = &playGame;
	int* pgN = &guess_number;
	int* prndNmbr = &random_number;
	int* pMN = &MAX_NUMBER;

	cout << "Hi Dominic do you wan't to play a game.....  Enter \'Y\' for Yes and \'N\' for No: " << endl;
	cin >> playGame;
	cin.clear();
	cin.ignore();


	if(*pG == 'y' || *pG == 'Y')
	do
	{
		*prndNmbr = new_random_number(MAX_NUMBER);
		
		cout << "\nPick a number between 1 and " << *pMN << "...  You have " << *ptralwd << " tries... "  << endl;
		
		
		while(*ptries < *ptralwd)
		{
			cin >> *pgN;

			
			if(!cin.good())
			{
				cout << "Error, that was not a numberic number, please try again..." << endl;
				cin.clear();
				cin.ignore(numeric_limits<streamsize>::max(), '\n' );
			}
			else
			{
				*ptries = *ptries + 1;
				cin.clear();
				cin.ignore();
				
				if(*pgN > *prndNmbr)
				{
					cout << "You guessed too high, try again... " << endl;
				}

				else if(*pgN < *prndNmbr)
				{
					cout << "You guessed too low, try again... " << endl;
				}
								
				else if(*pgN == *prndNmbr)
				{
					printf("\nCongradulations!!!  You guessed correct, the number is: %i\n", *prndNmbr); 
					break;
				}
				 
				else
				{
					break;
				}
			}
       		}

		do
		{
			printf("\nYou used %i tries.  The correct number was: %i. Do you want to try again?  \'Y\' for yes or \'N\' for No.\n", *ptries, *prndNmbr);
			cin >> *pG;
			cin.clear();
			cin.ignore();
			*ptries = 0;	
				
			if(*pG == 'y' || *pG == 'Y')
			{
				break;
			}
			else
			{	
				cout << "Thanks for playing!" << endl;
				exit(0);
			}

		}while(true);
			
	}while(*pgN != -1);
	
	else if(*pG == 'n' || *pG == 'N')
	{
		cout << "\n\nGoodbye, thanks for playing." << endl;
	}

	else
	{
		cout << "\n\nI didn't understand your input.  Good bye." << endl;
	}
	
	
	return 0;
}
