// CS3520 Lab 2 - Exercise 4: factorial of n
// This C++ model is written and tested first, then translated to RISC-V assembly.

#include <iostream>  // std::cout lives here

// Multiply 1 * 2 * 3 * ... * n.  The result of 1 is used for n = 0 and n = 1.
int factorial(int n)
{
    int result = 1;                  // the empty product is 1
    for (int i = 2; i <= n; i++) {   // multiply in every number from 2 to n
        result = result * i;         // build the product up one factor at a time
    }
    return result;                   // hand the finished product back
}

int main()
{
    int n = 5;                                             // the number to use
    std::cout << "factorial=" << factorial(n) << std::endl;  // print the product
    return 0;                                              // leave main with success
}