# CS3520 Lab 2 - Exercise 5: greatest common divisor
# RISC-V assembly translation of model.cpp
#
# Demonstrates: Euclid's algorithm as a loop, a remainder computed with a
# subtraction loop because RV32I has no remainder instruction, and a
# procedure that preserves three callee-saved registers.

        .data
a:      .word   54                  # first number
b:      .word   24                  # second number
msg:    .asciz  "gcd="              # text printed before the answer

        .text
main:
        lw      a0, a                # a0 = a = 54, the first argument
        lw      a1, b                # a1 = b = 24, the second argument
        jal     ra, gcd              # call gcd(a0, a1); result in a0

        mv      s0, a0               # keep the result safe across the print

        la      a0, msg              # a0 = address of the text to print
        li      a7, 4                # a7 = 4 tells the ecall to print text
        ecall                         # print "gcd=" with no newline

        mv      a0, s0               # a0 = the answer again
        li      a7, 1                # a7 = 1 tells the ecall to print int
        ecall                         # print 6 followed by a newline

        li      a7, 10               # a7 = 10 tells the ecall to stop
        ecall                         # exit cleanly

# ---------------------------------------------------------------
# gcd(a in a0, b in a1) -> the common divisor in a0
#
# Euclid's rule: gcd(a, b) == gcd(b, a % b), and once b is 0 the answer
# is a. RV32I has no remainder instruction, so a % b is found by
# subtracting b from a until what is left is smaller than b.
# ---------------------------------------------------------------
gcd:
        addi    sp, sp, -16          # make room for three saved registers
        sw      s0, 0(sp)            # preserve the caller's s0
        sw      s1, 4(sp)            # preserve the caller's s1
        sw      s2, 8(sp)            # preserve the caller's s2

        mv      s0, a0               # s0 = a
        mv      s1, a1               # s1 = b

loop:
        beq     s1, zero, done      # gcd(a, 0) is a, so the answer is ready

        mv      s2, s0               # s2 = a, the number being reduced
mod_loop:
        blt     s2, s1, mod_done     # stop once the leftover is smaller than b
        sub     s2, s2, s1           # a = a - b, one subtraction at a time
        beq     x0, x0, mod_loop     # keep subtracting

mod_done:
        mv      s0, s1               # a = b
        mv      s1, s2               # b = a % b
        beq     x0, x0, loop         # go round again with the smaller pair

done:
        mv      a0, s0               # place the result where the caller looks

        lw      s0, 0(sp)            # restore the caller's s0
        lw      s1, 4(sp)            # restore the caller's s1
        lw      s2, 8(sp)            # restore the caller's s2
        addi    sp, sp, 16           # release the stack space
        jalr    x0, ra, 0            # return