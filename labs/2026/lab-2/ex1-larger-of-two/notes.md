# Exercise 1 - Larger of Two Numbers

## What it does

The C++ model calls `larger(17, 42)` and prints the bigger of the two numbers.
The assembly does the same work, so both programs print exactly the same line.

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
larger=42
```

## Notes on the assembly

- `larger` is a leaf procedure, because it calls nothing, so it never has to
  save `ra`. It also uses no `s`-register, so it needs no stack frame: the
  answer is placed in `a0`, which is a caller-saved scratch register.
- The comparison uses one real branch, `blt a0, a1, take_y`. The C++ `if`
  became "branch when x is less than y, otherwise fall through", which is the
  shape most RISC-V branches have.
- `la` is a pseudo-instruction: it becomes `auipc` plus `addi`, which together
  add the PC to the distance from the instruction to the `.data` section.
- `mv`, `li` and `ret` are pseudo-instructions too. `mv rd, rs` becomes
  `addi rd, rs, 0` (`0x00050413` for `mv s0, a0`), `li rd, small` becomes
  `addi rd, zero, small`, and `ret` becomes `jalr x0, ra, 0` (`0x00008067`).
- `main` keeps the answer in `s0` because the print of the label text also
  uses `a0`, so the value has to survive one ecall.

## Things to try changing

- Swap the two numbers in `.data` and check that the printed answer changes.
- Change `blt` to `bltu` and see whether negative numbers behave differently.
- Rewrite the procedure so it uses an `s`-register, which forces a stack frame.