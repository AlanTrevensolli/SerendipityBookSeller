#include<iostream>
using namespace std;

#include "cashier.h"
#include "invmenu.h"
#include "bookinfo.h"
#include "reports.h"

//Constant for array size
const int SIZE = 20;

//Global arrays
string bookTitle[SIZE];
string isbn[SIZE];
string author[SIZE];
string publisher[SIZE];
string dateAdded[SIZE];
int qtyOnHand[SIZE];
double wholesale[SIZE];
double retail[SIZE];

using namespace std;

int main(){
    int choice;
    while (choice != 4) {
        choice = 0;
        
        cout << "\t\tSerendipity Booksellers" << endl;
        cout << "\t\t   Main Menu" << endl;
        cout << "1. Cashier Module" << endl;
        cout << "2. Inventory Database Module" << endl;
        cout << "3. Report Module" << endl;
        cout << "4. Exit" << endl;
        cout << "\nEnter Your Choice: ";
        while (choice < 1 || choice > 4)
        {
            cin >> choice;
            if (choice < 1 || choice > 4)
            {
                cout << "\nYou must enter a number between 1 and 4.\n";
                cout << "Please try again.\n\n";
            }
        }

        switch (choice)
        {
            case 1:
                cin.ignore();
                cashier();
                break;
            case 2:
                invmenu();
                break;
            case 3:
                reports();
                break;
            case 4:
                cout << "\nYou selected item 4.\n";
                break;
        }
        cout << endl << endl;
    }

    return 0;
}