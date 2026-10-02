# Exercise 4 - Factorial of n

## What it does

The C++ model multiplies together every number from 1 to `n` and prints the
product. The assembly computes the same product with the same loop, so both
programs print exactly the same line.

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
factorial=120
```

## Notes on the assembly

- RV32I has no multiply instruction, so the C++ `result * i` cannot be copied
  directly. A helper procedure `multiply` builds the product one bit at a time:
  while the multiplier is not zero, it looks at the multiplier's lowest bit with
  `andi`, adds the first number to the result when that bit is 1, doubles the
  first number with `slli`, and shifts the multiplier down with `srli`.
- `factorial` calls `multiply`, so it is no longer a leaf. That is the first
  time this lab needs `ra` on the stack: `jal ra, multiply` overwrites `ra` with
  the address of the instruction after the call, so the original return address
  has to be saved with `sw ra, 0(sp)` and restored before `jalr`.
- Two procedures in one file cannot share a label name. `factorial` uses
  `f_loop` and `f_done`, and `multiply` uses `m_loop`, `m_next` and `m_done`, so
  each branch lands in the procedure it belongs to.
- Both procedures save the same registers, `s0` through `s2`, because they use
  the same ones for their own work. That is fine as long as each one puts the
  caller's values back before it returns: the values live on the stack while
  the inner call runs, so the outer procedure is not disturbed.
- `bgt s2, s0, f_done` is the pseudo-instruction for `blt s0, s2, f_done`
  (`0x07244a63`), which asks whether `i` has passed `n`.
- `multiply` returns 0 for a multiplier of 0, and `factorial` starts its product
  at 1 and counts from 2, so the empty product for `n = 0` and `n = 1` comes out
  right without a special case.

## Things to try changing

- Change `n` to 6 and check the printed product by hand.
- Print the result of `multiply(7, 9)` on its own to see the bit loop at work.
- Replace the shift-and-add loop with a plain repeated-addition loop and compare
  the number of instructions each one executes.