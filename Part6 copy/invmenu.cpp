#include<iostream>
#include "invmenu.h"
using namespace std;

void invmenu(){
    cout << "Hello World!" << endl;
    int choice = 0;
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