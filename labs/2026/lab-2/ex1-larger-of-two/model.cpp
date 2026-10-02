// CS3520 Lab 2 - Exercise 1: larger of two numbers
// This C++ model is written and tested first, then translated to RISC-V assembly.

#include <iostream>  // std::cout lives here

// Return whichever of the two numbers is bigger.
int larger(int x, int y)
{
    if (x > y) {   // is the first number the bigger one?
        return x;  // yes, so x is the answer
    }
    return y;      // no, so y must be the answer
}

int main()
{
    int a = 17;                        // first number stored in memory
    int b = 42;                        // second number stored in memory
    std::cout << "larger=" << larger(a, b) << std::endl;  // print the answer
    return 0;                          // leave main with success
}