// CS3520 Lab 2 - Exercise 2: sum the integers from 1 to n
// This C++ model is written and tested first, then translated to RISC-V assembly.

#include <iostream>  // std::cout lives here

// Add up every integer from 1 through n.
int sum_to_n(int n)
{
    int total = 0;          // the running total starts at zero
    for (int i = 1; i <= n; i++) {  // count 1, 2, 3, ... up to n
        total += i;         // add the current number to the total
    }
    return total;           // hand the finished total back to the caller
}

int main()
{
    int n = 10;                                              // how far to count
    std::cout << "sum=" << sum_to_n(n) << std::endl;        // print the total
    return 0;                                                // leave main with success
}