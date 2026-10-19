#include <iostream>
#include "cashier.h"
#include <iomanip>
#include <string>
using namespace std;

const int SIZE = 20;

extern string isbn[SIZE];
extern string bookTitle[SIZE];
extern double retail[SIZE];


void cashier()
{
    string title;
    string transactionIsbn = "";
    string choice = "";
    float subtotal = 0.0;
    double price = 0.0;

    cout << "Serendipity Booksellers\n Cashier Module" << endl;

    string date;
    cout << "\nDate: ";
    cin >> date;

    do {
        int quantity;
        cout << "Quantity of Book: ";
        cin >> quantity;
        
        cin.ignore();
        string bookIsbn;
        cout << "ISBN: ";
        cin >> bookIsbn;
        bool isbnNotFound = true;
        while (isbnNotFound){
            for (int i = 0; i < SIZE; i++)
            {
                if (bookIsbn == isbn[i])
                {
                    float price = retail[i];
                    subtotal += price * quantity;
                    title = bookTitle[i];
                    transactionIsbn = bookIsbn;
                    price = retail[i];
                    isbnNotFound = false;
                    break;
                }
            }
            if (isbnNotFound)
            {
                cout << "Book not found. Would you like to try again? (Y/N): ";
                cin >> choice;
                if (choice == "y" || choice == "Y") {
                    break;
                }
                else if (choice == "n" || choice == "N") {
                    isbnNotFound = false;
                }
            }
        }
        cout << "Would you like to process another transaction? (Y/N): ";
        cin >> choice;
        if (choice == "n" || choice == "N") {
            cout << "Total: $" << fixed << setprecision(2) << subtotal;
            cout << "\n\nSerendipity Book Sellers\n\nDate: " << date << endl;
            cout << "\nQty ISBN           Title                   Price     Total" << endl;
            cout << "____________________________________________________________" << endl;
            cout << quantity << setw(4)<< transactionIsbn << setw(15) << title << setw(25) <<"$ " << price << setw(6) << "$ "<< subtotal << endl;
            cout << "\n\n            Subtotal                                 $ " << subtotal << endl;
            cout << "            Tax                                      $ " << subtotal * 0.06 << endl;
            cout << "            Total                                    $ " << subtotal * 0.06 + subtotal << endl;

            cout << "\nThank You for Shopping at Serendipity!" << endl;
            break;
        }
    } while (choice == "y" || choice == "Y");
}