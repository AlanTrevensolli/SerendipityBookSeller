#include<iostream>
#include "reports.h"
using namespace std;

void reports(){

    int choice = 0;

    cout << "  Serendipity Booksellers" << endl;
    cout << "          Reports" << endl;
    cout << "\n1.  Inventry Listing" << endl;
    cout << "2.  Inventory Wholesale Value" << endl;
    cout << "3.  Inventory Retail Value" << endl;
    cout << "4.  Listing by Quantity" << endl;
    cout << "5.  Listing by Cost" << endl;
    cout << "6.  Listing by Age" << endl;
    cout << "7.  Return to Main Menu" << endl;
    cout << "\nEnter Your Choice: ";
    
    while (choice < 1 || choice > 7)
    {
        cin >> choice;
        if (choice < 1 || choice > 7)
        {
            cout << "\nYou must enter a number between 1 and 7.\n";
            cout << "Please try again.\n\n";
        }
    }
    
    switch (choice)
    {
        case 1:
            cin.ignore();
            repListing();
            break;
        case 2:
            repWholesale();
            break;
        case 3:
            repRetail();
            break;
        case 4:
            repQty();
            break;
        case 5:
            repCost();
            break;
        case 6:
            repAge();
            break;
        case 7:
            cout << "\nReturning to Main Menu.\n";
            return;
    }
}

void repListing()
{
    cout << "\nYou selected Inventory Listing.\n";
}
void repWholesale()
{
    cout << "\nYou selected Inventory Wholesale Value.\n";
}
void repRetail()
{
    cout << "\nYou selected Inventory Retail Value.\n";
}
void repQty()
{
    cout << "\nYou selected Listing By Quantity.\n";
}
void repCost()
{
    cout << "\nYou selected Listing By Cost.\n";
}
void repAge()
{
    cout << "\nYou selected Listing By Age.\n";
}
