#include <iostream>
#include "cashier.h"
#include <iomanip>
using namespace std;

void cashier()
{
    int choice = 1;
    while(choice){
        cout << "Serendipity Booksellers\n Cashier Module" << endl;
        
        string date;
        cout << "\nDate: ";
        cin >> date;
        
        int quantity;
        cout << "Quantity of Book: ";
        cin >> quantity;
        
        string isbn;
        cout << "ISBN: ";
        cin >> isbn;
        
        string title;
        cout << "Title: ";
        cin.ignore();
        getline(cin, title);
        
        float price;
        cout << "Price: ";
        cin >> price;
        
        float subtotal = price * quantity;
        cout << fixed << setprecision(2);
        cout << "\n\nSerendipity Book Sellers\n\nDate: " << date << endl;
        cout << "\nQty ISBN           Title                   Price     Total" << endl;
        cout << "____________________________________________________________" << endl;
        cout << quantity << setw(4)<< isbn << setw(15) << title << setw(25) <<"$ " << price << setw(6) << "$ "<< subtotal << endl;
        cout << "\n\n            Subtotal                                 $ " << subtotal << endl;
        cout << "            Tax                                      $ " << subtotal * 0.06 << endl;
        cout << "            Total                                    $ " << subtotal * 0.06 + subtotal << endl;
        cout << "\nThank You for Shopping at Serendipity!" << endl;
        cout << "Do you want to process another transaction? (1 for yes 0 for no) " << endl;
        cin >> choice;
    }
    return;
}