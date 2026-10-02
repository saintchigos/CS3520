// CS3520 Lab 2 - Exercise 3: count the even numbers in an array
// This C++ model is written and tested first, then translated to RISC-V assembly.

#include <iostream>  // std::cout lives here

// Count how many entries of the array are even numbers.
int count_even(const int arr[], int n)
{
    int count = 0;                 // nothing counted yet
    for (int i = 0; i < n; i++) {  // look at every element in turn
        if (arr[i] % 2 == 0) {     // is this element even?
            count++;               // yes, so keep count of one more
        }
    }
    return count;                  // hand the finished count back
}

int main()
{
    int array[] = {3, 8, 5, 12, 7, 2, 9, 4};       // four of these are even
    int n = 8;                                     // number of elements
    std::cout << "evens=" << count_even(array, n) << std::endl;  // print it
    return 0;                                      // leave main with success
}