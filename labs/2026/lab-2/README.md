# Lab 2 - RISC-V Assembly from Tested C++ Models

## What this lab is about

Every exercise here is written twice: first as a small C++ program that is
compiled and tested, and then as a hand-written RV32I translation of the same
algorithm. The C++ model fixes the expected output, so the assembly can be
checked against something instead of against a guess. The programs are
deliberately small, because the point is the translation and the calling
convention rather than the algorithm.

## Requirements

- A C++17 compiler for the models: `g++ -Wall -std=c++17 model.cpp -o model`
- Ripes or RARS to assemble and run the `.s` files
- The `.text` section starts at `0x00000000` and `.data` starts at
  `0x10000000`, which is the layout Ripes uses

Every program prints through `ecall`: `a7 = 4` prints a string with no newline,
`a7 = 1` prints an integer followed by a newline, and `a7 = 10` stops the
program. That is why the label text is printed first, then the number.

## How to run an exercise

```bash
cd ex1-larger-of-two
g++ -Wall -std=c++17 model.cpp -o model
./model
```

Then open `solution.s` in Ripes or RARS, assemble it, and run it. The two must
print the same line, which is listed for each exercise below.

## Exercises

| # | Folder | What it does | Expected output |
|---|--------|--------------|-----------------|
| 1 | [`ex1-larger-of-two`](ex1-larger-of-two/) | Calls a leaf procedure that returns the bigger of two numbers | `larger=42` |
| 2 | [`ex2-sum-to-n`](ex2-sum-to-n/) | Sums 1 through `n` in a counted loop | `sum=55` |
| 3 | [`ex3-count-even`](ex3-count-even/) | Counts even array entries without a divide instruction | `evens=4` |
| 4 | [`ex4-factorial`](ex4-factorial/) | Builds a factorial with a nested call and no multiply instruction | `factorial=120` |
| 5 | [`ex5-gcd`](ex5-gcd/) | Euclid's algorithm as a loop, remainder by subtraction | `gcd=6` |
| 5 stretch | [`ex5-stretch-gcd-recursive`](ex5-stretch-gcd-recursive/) | The same GCD written recursively, one stack frame per call | `gcd=6` |

Each folder holds `model.cpp`, the C++ model that was tested first; `solution.s`,
the RV32I translation; and `notes.md`, which explains the instructions, the
pseudo-instruction expansions, and what to try changing.

The exercises build on each other. Exercise 1 is a leaf procedure with no stack
frame at all, exercise 2 needs one because of a callee-saved register,
exercise 4 adds a procedure that calls another procedure so `ra` has to be
saved, and the stretch exercise puts that call inside the procedure itself.

## Answers about the worked example

These answer the discussion points in
[`examples/2026/array-max`](../../../examples/2026/array-max/) README, using the
machine words from assembling that file.

### `find_max` is a leaf, so why does it still use the stack?

Because being a leaf only settles the question of `ra`, not of `s1`. `ra` is
written by `jal`, and `find_max` never calls anything, so the return address
that `main` stored there is still correct when the procedure reaches its `jalr`
and it never has to be saved or restored. `s1` is a different matter: `find_max`
uses it for the running maximum, and every `s`-register is callee-saved, so the
procedure owes the caller the value it had on entry. That is what the four
bytes of stack are for: `addi sp, sp, -4` and `sw s1, 0(sp)` on the way in,
`lw s1, 0(sp)` and `addi sp, sp, 4` on the way out. A leaf procedure that used
no `s`-register would need no frame at all, which is what exercise 1 shows.

### What do `li`, `mv`, `la` and `ble` expand into?

Each one becomes real instructions. `li rd, small` becomes `addi rd, zero, small`
because `addi` can only reach -2048 to 2047, so `li a7, 4` is the single
instruction `0x00400893`, while a value too large for one `addi`, such as
`li a2, 0x12345`, becomes `lui` plus `addi` that adds the low part back. `mv rd, rs` becomes `addi rd, rs, 0`, so `mv s0, a0` is
`0x00050413`. `la rd, label` becomes `auipc` plus `addi`, which add the program
counter to the distance to the label, so `la a0, array` is `0x10000517` followed
by `0x00050513`. `ble` has no opcode of its own, so the assembler swaps the
operands and emits `bge`: `ble t4, s1, skip` is the single instruction
`bge s1, t4, skip`, `0x01d4d463`.

### Why is the loop exit test inverted relative to the C++?

Because the C++ condition is the condition for continuing, and a RISC-V branch
is the condition for leaving. The loop in `find_max` is tested at the top, so
the first thing the loop body has to decide is whether to keep going, and the
branch instruction that comes before the body has to be the one that jumps out
of the loop. Writing `bge t1, a1, done` says "leave once `i >= n`", which is
exactly the negation of C++'s `i < n`. The positive form cannot be used there,
because a branch offset always counts from its own instruction, so `blt t1, a1`
would have to jump forward into the middle of the loop to reach the body, and
the instruction that starts the body is the one immediately after the branch.
The way to keep the C++ wording is to restructure the loop so the branch at the
top is the one that goes backwards, which is what a `while` loop translated as
`loop: if (!cond) goto done; body; goto loop;` is doing.

## Also in this folder

- [`encoding-analysis.md`](encoding-analysis.md) - how B-type branches and
  J-type jumps encode their offsets, with worked examples taken from the
  solutions in this folder