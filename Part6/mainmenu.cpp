#include<iostream>
#include "cashier.h"
#include "invmenu.h"
#include "bookinfo.h"
#include "reports.h"

using namespace std;

int main(){
    int choice = 0;

    // while {

    // }

    // {
    //     {
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
    //     }
    //     cout << endl << endl;
    // }

    return 0;
}