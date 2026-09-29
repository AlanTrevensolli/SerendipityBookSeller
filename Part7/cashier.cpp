#include <iostream>
#include "cashier.h"
#include <iomanip>
using namespace std;

void cashier()
{
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
    
	cout << "\n\nSerendipity Book Sellers\n\nDate: " << date << endl;
	cout << "\nQty ISBN           Title                   Price     Total" << endl;
	cout << "____________________________________________________________" << endl;
	cout << quantity << "   " << isbn << "  " << title << "     $ " << price << "   $ " << subtotal << endl;
	cout << "\n\n            Subtotal                                 $ " << subtotal << endl;
	cout << "            Tax                                      $ " << subtotal * 0.06 << endl;
	cout << "            Total                                    $ " << subtotal * 0.06 + subtotal << endl;
	cout << "\nThank You for Shopping at Serendipity!" << endl;
    
}