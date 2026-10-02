# CS3520 Lab 2 - Exercise 5 stretch: greatest common divisor, recursively
# RISC-V assembly translation of model.cpp
#
# Demonstrates: recursion, so the procedure calls itself and every level of
# the call has to save its own ra and its own callee-saved registers on the
# stack. Each recursive call gets its own stack frame, and the frames are
# released in the right order as the calls return.

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
# The base case b == 0 jumps straight to the epilogue, with the answer
# already sitting in a0. Every other level computes a % b with the same
# subtraction loop as exercise 5, then calls itself with gcd(b, a % b).
#
# Because the procedure calls itself, ra must be saved before the
# recursive jal and restored before returning, or the caller would jump
# to the wrong place when the levels unwind.
# ---------------------------------------------------------------
gcd:
        addi    sp, sp, -16          # make room for ra and two registers
        sw      ra, 0(sp)            # preserve the return address
        sw      s0, 4(sp)            # preserve the caller's s0
        sw      s1, 8(sp)            # preserve the caller's s1

        mv      s0, a0               # s0 = a
        mv      s1, a1               # s1 = b
        beq     s1, zero, done       # gcd(a, 0) is a, which is already in a0

        mv      t0, s0               # t0 = a, the number being reduced
mod_loop:
        blt     t0, s1, mod_done     # stop once the leftover is smaller than b
        sub     t0, t0, s1           # a = a - b, one subtraction at a time
        beq     x0, x0, mod_loop     # keep subtracting

mod_done:
        mv      a0, s1               # first argument of the recursive call is b
        mv      a1, t0               # second argument is a % b
        jal     ra, gcd              # recurse; the answer comes back in a0

done:
        lw      ra, 0(sp)            # restore the return address
        lw      s0, 4(sp)            # restore the caller's s0
        lw      s1, 8(sp)            # restore the caller's s1
        addi    sp, sp, 16           # release this frame
        jalr    x0, ra, 0            # return to whoever called this level