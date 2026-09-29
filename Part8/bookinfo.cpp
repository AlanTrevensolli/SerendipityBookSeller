#include <iostream>
#include "bookinfo.h"
using namespace std;

const int SIZE = 20;

//Global arrays
extern string bookTitle[SIZE];
extern string isbn[SIZE];
extern string author[SIZE];
extern string publisher[SIZE];
extern string dateAdded[SIZE];
extern int qtyOnHand[SIZE];
extern double wholesale[SIZE];
extern double retail[SIZE];

void bookInfo(string isbn, string title, string author, string publisher, string date, int qty, double wholesale, double retail)
{
    cout << "\t\tSerendipity Bookseller" << endl;
    cout << "\t\t   Book Information" << endl;
    cout << "\nISBN: " << isbn << endl;
    cout << "Title: " << title << endl;
    cout << "Author: " << author << endl;
    cout << "Publisher: " << publisher << endl;
    cout << "Date Added: " << date << endl;
    cout << "Quantity-On-Hand: " << qty << endl;
    cout << "Wholesale Cost: $" << wholesale << endl;
    cout << "Retail Price: $" << retail << endl;

    cout << endl << endl;
    
}