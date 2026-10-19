#include <iostream>
#include "bookinfo.h"
#include <iomanip>
#include <string>
using namespace std;

//Constant for array size
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
    cout << "Serendipity Booksellers\n";
    cout << "\tBook Information\n\n";
    
    cout << "ISBN: " << isbn << endl;
    cout << "Title: " << title << endl;
    cout << "Author: " << author << endl;
    cout << "Publisher: " << publisher << endl;
    cout << "Date Added: " << date << endl;
    cout << "Quantity-On-Hand: " << qty << endl;
    cout << fixed << setprecision(2);
    cout << "Wholesale Cost: " << wholesale << endl;
    cout << "Retail Price: " << retail << endl;
}