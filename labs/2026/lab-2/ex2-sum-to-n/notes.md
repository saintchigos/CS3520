# Exercise 2 - Sum the Integers from 1 to n

## What it does

The C++ model calls `sum_to_n(10)` and prints the total. The assembly runs the
same counted loop, so both programs print exactly the same line.

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
sum=55
```

## Notes on the assembly

- The loop keeps `n` in `s0`, the running total in `s1`, and the counter `i` in
  `t1`. Registers `t0` through `t6` and `a0` through `a7` are caller-saved, so
  the procedure is free to overwrite `t1`, but `s0` and `s1` have to be pushed
  on the stack and popped back before returning.
- The exit test uses `bgt t1, s0, done`, which is the pseudo-instruction for
  `blt s0, t1, done` with the two registers swapped (`0x00644863`). RISC-V has
  no `bgt`, so the assembler has to turn "is t1 greater than s0" into "is s0
  less than t1".
- `beq x0, x0, loop` is the unconditional branch. There is no `j` instruction
  in RV32I; `j` is a pseudo-instruction that the assembler turns into either
  `beq x0, x0, label` or a `jal` with `x0` as the destination register.
- `addi sp, sp, -8` and `addi sp, sp, 8` are paired around the body of the
  procedure, so the caller's stack pointer is exactly as it was afterwards.
- `sw` and `lw` store and load 4-byte words, which is why each saved register
  occupies one slot: `s0` at offset 0 and `s1` at offset 4.

## Things to try changing

- Change `n` to a larger number and check the printed total by hand.
- Use `blt t1, s0, skip` style exit test instead and compare the two versions.
- Rewrite the loop with the C++ form `for (i = 0; i < n; i++)` and note which
  branch changes.