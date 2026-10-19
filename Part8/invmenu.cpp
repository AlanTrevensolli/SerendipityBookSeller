#include<iostream>
#include<iomanip>
#include<string>
#include "bookinfo.h"
#include "invmenu.h"
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

void invMenu(){
    int choice = 0;
    // while (choice != 5){
        cout << "  Serendipity Booksellers" << endl;
        cout << "    Inventory Database" << endl;
        cout << "\n1.  Look Up a Book\n2.  Add a Book\n3.  Edit a Book's Record\n4.  Delete a Book\n5.  Return to the Main Menu" << endl;
        cout << "\nEnter Your Choice: ";
        while (choice < 1 || choice > 5)
        {
            cin >> choice;
            if (choice < 1 || choice > 5)
            {
                cout << "\nYou must enter a number between 1 and 5.\n";
                cout << "Please try again.\n\n";
            }
        }
        switch (choice)
        {
            case 1:
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
            case 5:
                break;
        }
    // }
}

void lookUpBook()
{
    cin.ignore();
    cout << "\nWhat is the title of the book you would like to look up? ";
    string title;
    getline(cin, title);
    for (int i = 0; i < SIZE; i++)
    {
        if (bookTitle[i] == title)
        {
            bookInfo(isbn[i], bookTitle[i], author[i], publisher[i], dateAdded[i], qtyOnHand[i], wholesale[i], retail[i]);
            return;
        }
    }
    cout << "\nBook not found.\n";
    return;
}
void addBook()
{
    for (int i = 0; i < SIZE; i++)
    {
        if (bookTitle[i] == "")
        {
            cin.ignore();
            cout << "Enter the title of the book: ";
            getline(cin, bookTitle[i]);
            cout << "Enter the ISBN number: ";
            getline(cin, isbn[i]);
            cout << "Enter the author's name: ";
            getline(cin, author[i]);
            cout << "Enter the publisher's name: ";
            getline(cin, publisher[i]);
            cout << "Enter the date the book was added to the inventory: ";
            getline(cin, dateAdded[i]);
            cout << "Enter the quantity of the book being added: ";
            cin >> qtyOnHand[i];
            cout << "Enter the wholesale cost of the book: ";
            cin >> wholesale[i];
            cout << "Enter the retail price of the book: ";
            cin >> retail[i];
            return;
        }
    }
    cout << "\nInventory is full. Cannot add more books.\n";
    return;
}
void editBook()
{
    cin.ignore();
    cout << "\nWhat is the title of the book you would like to edit? ";
    string title;
    getline(cin, title);
    for (int i = 0; i < SIZE; i++)
    {
        if (bookTitle[i] == title)
        {
            int choice = 0;
            while (choice != 9)
            {   
                bookInfo(isbn[i], bookTitle[i], author[i], publisher[i], dateAdded[i], qtyOnHand[i], wholesale[i], retail[i]);
                cout << "\n What would you like to edit?\n";
                cout << "1. Title\n2. ISBN\n3. Author\n4. Publisher\n5. Date Added\n6. Quantity-On-Hand\n7. Wholesale Cost\n8. Retail Price\n9. Return to Main Menu\n";
                cout << "Enter your choice: ";
                cin >> choice;
                cin.ignore(); // Clear the input buffer
                while (choice < 1 || choice > 9)
                {
                    cout << "\nYou must enter a number between 1 and 9.\n";
                    cout << "Please try again.\n\n";
                    cin >> choice;
                    cin.ignore(); // Clear the input buffer
                }
                switch (choice)
                {
                case 1:
                    cout << "Enter the new title of the book: ";
                    getline(cin, bookTitle[i]);
                    break;
                
                case 2:
                    cout << "Enter the new ISBN number: ";
                    getline(cin, isbn[i]);
                    break;
                case 3:
                    cout << "Enter the new author's name: ";
                    getline(cin, author[i]);
                    break;
                case 4:
                    cout << "Enter the new publisher's name: ";
                    getline(cin, publisher[i]);
                    break;
                case 5:
                    cout << "Enter the new date the book was added to the inventory: ";
                    getline(cin, dateAdded[i]);
                    break;
                case 6:
                    cout << "Enter the new quantity of the book: ";
                    cin >> qtyOnHand[i];
                    break;
                case 7:
                    cout << "Enter the new wholesale cost of the book: ";
                    cin >> wholesale[i];
                    break;
                case 8:
                    cout << "Enter the new retail price of the book: ";
                    cin >> retail[i];
                    break;
                case 9:
                    cout << "\nReturning to Main Menu.\n";
                    break;
                }
            }
            return;
        }
    }
    cout << "\nBook not found.\n";
    return;
}
void deleteBook()
{
    cout << "\nWhat is the title of the book you would like to delete? ";
    string book;
    cin.ignore();
    getline(cin, book);
    for (int i = 0; i < SIZE; i++)
    {
        if (book == bookTitle[i])
        {
            bookInfo(isbn[i], bookTitle[i], author[i], publisher[i], dateAdded[i], qtyOnHand[i], wholesale[i], retail[i]);
            cout << "\nAre you sure you want to delete this book? (y/n): ";
            char confirm;
            cin >> confirm;
            if (confirm == 'y' || confirm == 'Y')
            {
                bookTitle[i] = "";
                isbn[i] = "";
                author[i] = "";
                publisher[i] = "";
                dateAdded[i] = "";
                qtyOnHand[i] = 0;
                wholesale[i] = 0.0;
                retail[i] = 0.0;
                cout << "\nBook deleted.\n";
            }
            return;
        }
    }
    cout << "\nBook not found.\n";
    return;
}