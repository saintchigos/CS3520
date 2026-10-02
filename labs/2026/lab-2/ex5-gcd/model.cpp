// CS3520 Lab 2 - Exercise 5: greatest common divisor
// This C++ model is written and tested first, then translated to RISC-V assembly.

#include <iostream>  // std::cout lives here

// Find the largest number that divides both a and b.
// The rule is: gcd(a, b) == gcd(b, a % b), and gcd(a, 0) == a.
int gcd(int a, int b)
{
    while (b != 0) {     // keep going until the second number runs out
        int r = a % b;   // whatever is left over from dividing a by b
        a = b;            // the bigger number becomes the smaller one
        b = r;            // and the leftover becomes the new smaller number
    }
    return a;             // when b is 0, a is the common divisor
}

int main()
{
    int a = 54;                                       // first number
    int b = 24;                                       // second number
    std::cout << "gcd=" << gcd(a, b) << std::endl;    // print the answer
    return 0;                                         // leave main with success
}