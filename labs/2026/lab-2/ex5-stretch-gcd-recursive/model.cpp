// CS3520 Lab 2 - Exercise 5 stretch: greatest common divisor, recursively
// The recursive form of exercise 5. This C++ model is written and tested
// first, then translated to RISC-V assembly.

#include <iostream>  // std::cout lives here

// Find the largest number that divides both a and b by calling itself.
// The base case is b == 0, where the answer is a.
int gcd(int a, int b)
{
    if (b == 0) {         // nothing left to reduce, so a is the answer
        return a;
    }
    int r = a % b;        // whatever is left over from dividing a by b
    return gcd(b, r);     // recurse on the smaller pair
}

int main()
{
    int a = 54;                                     // first number
    int b = 24;                                     // second number
    std::cout << "gcd=" << gcd(a, b) << std::endl;  // print the answer
    return 0;                                       // leave main with success
}