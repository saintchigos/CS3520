# Exercise 5 - Greatest Common Divisor

## What it does

The C++ model applies Euclid's rule to `54` and `24` and prints the answer.
The assembly applies the same rule with a loop, so both programs print exactly
the same line.

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
gcd=6
```

## Notes on the assembly

- Euclid's rule is what makes this loop short: `gcd(a, b) == gcd(b, a % b)`, and
  `gcd(a, 0) == a`. The outer loop is therefore just `beq s1, zero, done`
  followed by the swap of the two numbers, and it always makes the pair smaller.
- RV32I has no remainder instruction either, so `a % b` is computed by
  subtracting `b` from `a` until what is left is smaller than `b`. That inner
  loop is `blt s2, s1, mod_done`, `sub s2, s2, s1`, `beq x0, x0, mod_loop`.
- `beq x0, x0, label` is the unconditional branch that sends the program back
  round the loop. Encoding it as a comparison of `x0` with itself costs nothing
  extra, because `x0` always reads as zero.
- The working values live in `s0`, `s1` and `s2`, all callee-saved, so the
  procedure saves all three on the stack and puts them back before returning.
  The stack pointer ends up exactly where the caller left it.
- `sub s2, s2, s1` is `0x40990933`. Its most significant bit of the `funct7`
  field is the one that tells `add` and `sub` apart: `0x20` means subtract, `0x00`
  means add, while the other six bits of `funct7` select the shift and logical
  instructions.

## Things to try changing

- Try other pairs, such as `17` and `5`, or two numbers where one is a multiple
  of the other.
- Count the subtractions the inner loop performs for `54` and `24`, and compare
  with the answer the C++ model gives for `a % b`.
- Rewrite the remainder with a shift-based method and compare the two.