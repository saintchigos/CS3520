# Exercise 3 - Count the Even Numbers in an Array

## What it does

The C++ model counts how many entries of `{3, 8, 5, 12, 7, 2, 9, 4}` are even.
The assembly walks the same array with the same counted loop, so both programs
print exactly the same line.

## Files

- `model.cpp` - the C++ model, written and tested first
- `solution.s` - the RISC-V assembly translation

## How to run it

```bash
g++ -Wall -std=c++17 model.cpp -o model
./model
```

Then open `solution.s` in Ripes or RARS, assemble it, and run it.

## Expected output

Both the model and the assembly print:

```text
evens=4
```

## Notes on the assembly

- RV32I has no divide or remainder instruction, so the C++ test
  `arr[i] % 2 == 0` cannot be copied literally. A number is even exactly when
  its lowest bit is zero, so `andi t5, t5, 1` replaces the `%` (`0x001f7f13`)
  and the branch replaces the comparison.
- `bnez t5, next` is a pseudo-instruction for `bne t5, zero, next`
  (`0x000f1463`). Branching to `next` when the bit was 1 skips the increment,
  which is how the C++ `if` body became an optional step in the loop.
- `bge t0, t2, done` keeps the C++ condition `i < n` by branching out when the
  condition is false. Every loop in this lab uses that inverted form, because
  RV32I can only branch forwards to a label and a `while` loop needs its exit
  test before the body.
- The array is indexed exactly like in the worked example: `slli` by 2 turns
  the element number into a byte offset, `add` turns that into an address, and
  `lw` reads the word. Words are 4 bytes wide, so the shift is by 2, not by 1.
- The count lives in `t1`, which is caller-saved, so nothing extra has to be
  saved on the stack for it.

## Things to try changing

- Add an odd number to the array and check that the count stays the same.
- Change `andi t5, t5, 1` to `andi t5, t5, 2` and work out what the loop
  counts now.
- Count the odd numbers instead by swapping the two branch operands.