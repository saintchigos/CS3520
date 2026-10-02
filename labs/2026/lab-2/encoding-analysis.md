# Branch and Jump Encoding Analysis

This is the encoding study for CS3520 Lab 2. Every value below comes from
assembling the exercise files in this folder and decoding the resulting machine
words, so the bit patterns can be checked against the real listings.

## Why B and J need special treatment

R-type, I-type and S-type instructions keep their immediate field in one
contiguous run of bits, so an immediate can be dropped into the instruction and
sign-extended on its way to a register. B-type and J-type instructions do not
have room for that, because they need a 12-bit and a 21-bit offset and they
need every bit of it as well.

The trick that makes it fit is that both instructions address 4-byte
instructions. The lowest bit of any instruction address is therefore always 0,
so the encoders throw that bit away and never store it. The freed bit is what
lets a long offset be split into two scattered halves instead of one.

## B-type: conditional branches

The 32 bits of a B-type instruction are laid out like this:

```text
 31           25 24     20 19     15 14  12 11      8 7    6      0
+---------------+---------+---------+------+--------+------+--------+
|  imm[12|10:5] |   rs2   |   rs1   |funct3|imm[4:1]|imm[11]|opcode  |
+---------------+---------+---------+------+--------+------+--------+
     7 bits      5 bits    5 bits    3 bits   4 bits  1 bit   7 bits
```

`opcode` is `1100011` for every branch, and `funct3` says which comparison to
make: `000` `beq`, `001` `bne`, `100` `blt`, `101` `bge`, `110` `bltu`, `111`
`bgeu`. The two registers being compared are `rs1` and `rs2`, which is why the
assembler swaps the operands of the `bgt` and `ble` pseudo-instructions instead
of inventing a new opcode for them.

The offset is split into three pieces: `imm[12]` and `imm[10:5]` sit above the
registers in bits 31:25, `imm[4:1]` sits below `funct3` in bits 11:8, and
`imm[11]` sits alone in bit 7. Putting bit 11 next to the opcode is what lets
`funct3` stay in the same place in every branch, so a branch can be decoded
without first knowing which branch it is.

### Worked example: `blt a0, a1, take_y` at address 0x44

From `ex1-larger-of-two/solution.s`:

```text
binary    0000 0000 1011 0101 0100 0100 0110 0011
word      0x00b54463
rs1 = a0 = 10, rs2 = a1 = 11, funct3 = 100 (blt)
imm[12] = 0, imm[10:5] = 000000, imm[4:1] = 0100, imm[11] = 0
```

Bits 31:25 are all zero, so `imm[12]` and `imm[10:5]` are zero. The four bits at
11:8 are `0100`, which is 4, and bit 7 is zero, so the upper half of the offset
is zero. Putting the discarded low bit back gives `0000 0000 0000 0100 0`, that
is 8, so the branch goes to `0x44 + 8 = 0x4c`, which is exactly where `take_y`
sits in the listing.

### Worked example: a backwards branch, `beq x0, x0, loop` at 0x5c

From `ex2-sum-to-n/solution.s`:

```text
binary    1111 1110 0000 0000 0000 0000 1010 1110 0011
word      0xfe000ae3
rs1 = x0 = 0, rs2 = x0 = 0, funct3 = 000 (beq)
imm[12] = 1, imm[10:5] = 111111, imm[4:1] = 1010, imm[11] = 1
```

Here the top seven bits and bit 7 are both set, which is what makes the offset
negative. Reassembling the pieces gives `1 111111 1010 1` with the low bit put
back, which is 13 bits all set except one: `-12`. The branch goes to
`0x5c - 12 = 0x50`, which is where `loop` sits. A negative offset is how a loop
jumps back to the top, and it is why the offset has to be sign-extended instead
of being treated as an unsigned count.

### Worked example: a branch that skips further, `bge t0, t2, done` at 0x58

From `ex3-count-even/solution.s`:

```text
word      0x0272d263
rs1 = t0 = 5, rs2 = t2 = 7, funct3 = 101 (bge)
imm[12] = 0, imm[10:5] = 000001, imm[4:1] = 0010, imm[11] = 0
```

The bit at position 25 is set, which is `imm[5]` in `imm[10:5]`, and the low
four bits at 11:8 are `0010`. Putting them together gives 36, so the branch goes
from `0x58` to `0x7c`, which is where `done` sits. This is the loop exit test
that inverts the C++ condition `i < n`.

### The limits this format imposes

- The offset is 13 bits including the sign bit and the discarded low bit, so a
  branch can reach from `-4096` to `+4094` bytes, about 1 KB in each direction.
- The offset must be even, because every instruction starts on a 4-byte
  boundary. An assembler asked for an odd offset has to report that rather than
  quietly dropping the low bit.
- `.data` lives at `0x10000000`, which is far outside that window, so a branch
  can never jump from `.text` into `.data`.

## J-type: `jal`

`jal` needs a bigger offset than a branch because it is used for long jumps,
such as calling a procedure that sits elsewhere in the file.

```text
 31           12 11     7 6         0
+---------------+--------+----------+------+
|   imm[20|10:1] |imm[11] |   rd     |opcode|
+---------------+--------+----------+------+
     20 bits     1 bit    5 bits    7 bits
```

`opcode` is `1101111`. The 20 bits at the top hold `imm[20]` together with the
low ten offset bits `imm[10:1]`, and bit 7 holds `imm[11]`, which is where the
`rd` field would otherwise begin. That is the only rearrangement: bits 6:0 stay
exactly where they are in every other format.

### Worked example: `jal ra, larger` at address 0x18

From `ex1-larger-of-two/solution.s`:

```text
binary    0000 0010 1100 0000 0000 0000 1110 1111
word      0x02c000ef
rd = ra = 1, opcode = 1101111
imm[20] = 0, imm[10:1] = 0000010110 = 22, imm[11] = 0, imm[19:12] = 0
```

`imm[10:1]` is 22, so the low offset bits are `22 << 1 = 44`, and everything
above them is zero, so the whole offset is 44. The target is `0x18 + 44 = 0x44`,
which is where `larger` starts in the listing. The same instruction also writes
the return address into `ra`, because `rd` is 1 rather than 0.

### `j label` is not a real instruction

There is no `j` in RV32I. Because the whole 20-bit field above bit 12 is
available, the assembler expands `j label` into `jal x0, label`: an offset of 12
becomes `0x00c0006f`, where `rd = x0` and `imm[10:1] = 6`. Because `rd` is
`x0`, the link value that `jal` would normally write is thrown away, so the
jump does not disturb `ra`. When `rd` is `ra`, the same instruction also records
where to come back to, which is the difference between a jump and a call.

Every loop in this lab uses `beq x0, x0, label` for its unconditional branch
instead, because `x0` always reads as zero, so that comparison is always true
and costs the same as a jump would.

### The limits this format imposes

- The offset is 21 bits including the sign bit and the discarded low bit, so a
  `jal` can reach from `-1048576` to `+1048574` bytes, about 1 MB in each
  direction.
- The offset must be even, for the same reason as a branch.
- To get an address in `.data` into a register, the program uses `la`, which is
  `auipc` plus `addi`. A branch or jump can never produce that address, because
  both are relative to the program counter in `.text`.

## Comparing the two formats

| | B-type | J-type |
|---|---|---|
| Used for | `beq`, `bne`, `blt`, `bge`, `bltu`, `bgeu` | `jal`, and `j` as a pseudo-instruction |
| Offset stored | `imm[12]`, `imm[10:5]`, `imm[4:1]`, `imm[11]` | `imm[20]`, `imm[10:1]`, `imm[11]` |
| Offset width | 12 bits plus sign, `imm[11:1]` | 20 bits plus sign, `imm[20:1]` |
| Reach | about 1 KB each way | about 1 MB each way |
| Registers | two, `rs1` and `rs2` | one, `rd` |
| Why the bits move | `funct3` must stay put so a branch can be decoded without knowing its kind | `rd` must stay put so a jump can still say where to return |

The part both formats share is the single bit at position 7. In B-type and in
J-type it is the sign bit of the offset, `imm[11]`, and in both cases it is
pushed down below the field that would otherwise occupy that position. One
freed bit is enough to make a long, sign-bearing offset fit around a field that
cannot move.

## Checking these results yourself

Assemble any of the programs in this folder and look at the listing, which shows
the source line next to the real instruction and the machine word, so every
number above can be traced back to a line in a solution file. The B-type
examples come from `ex1-larger-of-two`, `ex2-sum-to-n`, `ex3-count-even` and
`ex4-factorial`, and the J-type example comes from `ex1-larger-of-two`.