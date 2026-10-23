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
    string orderChoice = "";
    string newTransaction = "";
    float subtotal = 0.0;
    int orderCount = 0;
    int orderQuantity[SIZE];
    string orderIsbn[SIZE];
    string orderTitle[SIZE];
    double orderPrice[SIZE];
    double orderTotal[SIZE];

    cout << "Serendipity Booksellers\n Cashier Module" << endl;

    string date;
    cout << "\nDate: ";
    cin >> date;
    cin.ignore();

    do {
        double price = 0.0;
        orderCount++;
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
                    cout << "Title: " << title << endl;
                    cout << "Price: $" << fixed << setprecision(2) << price << endl;
                    orderQuantity[orderCount - 1] = quantity;
                    orderIsbn[orderCount - 1] = transactionIsbn;
                    orderTitle[orderCount - 1] = title;
                    orderPrice[orderCount - 1] = price;
                    orderTotal[orderCount - 1] = price * quantity;
                }
            }
            if (isbnNotFound)
            {
                cout << "Book not found. Would you like to try again? (Y/N): ";
                cin >> orderChoice;
                if (orderChoice == "y" || orderChoice == "Y") {
                    isbnNotFound = true;
                }
                else if (orderChoice == "n" || orderChoice == "N") {
                    isbnNotFound = false;
                }
            }
        }
        cout << "Add another title to the order? (Y/N): ";
        cin >> orderChoice;
        if (orderChoice == "n" || orderChoice == "N") {
            cout << "Total: $" << fixed << setprecision(2) << subtotal;
            cout << "\n\nSerendipity Book Sellers\n\nDate: " << date << endl;
            cout << "\nQty ISBN           Title                   Price     Total" << endl;
            cout << "____________________________________________________________" << endl;
            for (int i = 0; i < orderCount; i++) {
                cout << orderQuantity[i] << setw(4) << orderIsbn[i] << setw(15) << orderTitle[i] << setw(25) << "$ " << orderPrice[i] << setw(6) << "$ " << orderTotal[i] << endl;
            }            
            cout << "\n\n            Subtotal                                 $ " << fixed << setprecision(2) << subtotal << endl;
            cout << "            Tax                                      $ " << fixed << setprecision(2) << subtotal * 0.06 << endl;
            cout << "            Total                                    $ " << fixed << setprecision(2) << subtotal * 0.06 + subtotal;

            cout << "\n\nWould you like to make a new transaction? (Y/N): ";
            cin >> newTransaction;
        }
    } while (newTransaction != "n" && newTransaction != "N");
}