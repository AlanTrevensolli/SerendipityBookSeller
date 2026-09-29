#include<iostream>
#include "invmenu.h"
using namespace std;

void invmenu(){
    int choice = 0;
    cout << "  Serendipity Booksellers" << endl;
	cout << "    Inventory Database" << endl;
	cout << "\n1.  Look Up a Book\n2.  Add a Book\n3.  Edit a Book's Record\n4.  Delete a Book\n5.  Return to the Main Menu" << endl;
	cout << "\nEnter Your Choice: ";
    while (choice < 1 || choice > 5)
    {
        cin >> choice;
        if (choice < 1 || choice > 5)
        {
            cout << "\nYou must enter a number between 1 and 5.\n";
            cout << "Please try again.\n\n";
        }
    }
    switch (choice)
    {
        case 1:
            cin.ignore();
            lookUpBook();
            break;
        case 2:
            addBook();
            break;
        case 3:
            editBook();
            break;
        case 4:
            deleteBook();
            break;
        case 5:
            return;
    }
}

void lookUpBook()
{
    cout << "\nYou selected Look Up Book.\n";
}
void addBook()
{
    cout << "\nYou selected Add Book.\n";
}
void editBook()
{
    cout << "\nYou selected Edit Book.\n";
}
void deleteBook()
{
    cout << "\nYou selected Delete Book.\n";
}