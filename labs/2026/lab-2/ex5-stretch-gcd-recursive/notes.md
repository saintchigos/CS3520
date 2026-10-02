# Exercise 5 Stretch - Greatest Common Divisor, Recursively

## What it does

This is the recursive version of exercise 5. It applies the same rule,
`gcd(a, b) == gcd(b, a % b)`, but instead of looping it calls itself. Both
programs print exactly the same line.

## Files

- `model.cpp` - the recursive C++ model, written and tested first
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

- `54` and `24` need three calls: `gcd(54, 24)`, then `gcd(24, 6)`, then
  `gcd(6, 0)`, which is the base case. The answer is built up on the way back
  out, and each level simply returns whatever the level below it produced in
  `a0`.
- The base case is `beq s1, zero, done`, which jumps straight to the epilogue.
  The answer is already in `a0` because the procedure never overwrote it on
  that path, so there is no `mv a0, s0` before returning.
- Each level needs its own stack frame, because `jal ra, gcd` overwrites `ra`
  with the address of the next instruction. Saving `ra` at the top and
  restoring it at the bottom is what lets three nested calls all return to the
  right place.
- The recursive call is a plain `jal ra, gcd`, exactly the same instruction
  that `main` uses to call it the first time. Recursion costs nothing extra in
  assembly; it only costs a stack frame per level.
- `t0` holds the remainder while `a % b` is being computed. `t0` is
  caller-saved, so the callee is free to overwrite it, which saves the
  procedure from putting it on the stack.
- The subtract loop is unchanged from exercise 5, because the remainder still
  has to be found without a remainder instruction.

## Things to try changing

- Try a pair that needs many levels, such as `89` and `34`, and count the calls
  by watching the stack pointer move.
- Change the frame size and check that the program still runs, then explain why
  any multiple of 4 works.
- Turn this recursive version into the loop from exercise 5 and compare the two
  stack traces.