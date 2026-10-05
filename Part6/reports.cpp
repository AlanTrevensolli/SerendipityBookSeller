#include<iostream>
#include "reports.h"
using namespace std;

void reports(){

    int choice = 0;
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
    }
}

void repListing()
{
    cout << "\nYouselected Inventory Listing.\n";
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