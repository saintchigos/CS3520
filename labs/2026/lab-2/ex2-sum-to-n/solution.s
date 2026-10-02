# CS3520 Lab 2 - Exercise 2: sum the integers from 1 to n
# RISC-V assembly translation of model.cpp
#
# Demonstrates: a counted loop that updates an accumulator, a procedure that
# must preserve two callee-saved registers, and bgt as a pseudo-instruction.

        .data
n:      .word   10                  # how far the loop counts
msg:    .asciz  "sum="              # text printed before the answer

        .text
main:
        lw      a0, n                # a0 = n = 10, the only argument
        jal     ra, sum_to_n         # call sum_to_n(a0); result in a0

        mv      s0, a0               # keep the result safe across the print

        la      a0, msg              # a0 = address of the text to print
        li      a7, 4                # a7 = 4 tells the ecall to print text
        ecall                         # print "sum=" with no newline

        mv      a0, s0               # a0 = the answer again
        li      a7, 1                # a7 = 1 tells the ecall to print int
        ecall                         # print 55 followed by a newline

        li      a7, 10               # a7 = 10 tells the ecall to stop
        ecall                         # exit cleanly

# ---------------------------------------------------------------
# sum_to_n(n in a0) -> 1 + 2 + ... + n in a0
#
# s0 holds n and s1 holds the running total. Both are callee-saved, so
# they have to be written to the stack before the procedure changes them
# and read back before it returns. The procedure calls nothing, so it
# does not have to save ra, and it only needs one loop.
# ---------------------------------------------------------------
sum_to_n:
        addi    sp, sp, -8           # make room for two saved registers
        sw      s0, 0(sp)            # preserve the caller's s0
        sw      s1, 4(sp)            # preserve the caller's s1

        mv      s0, a0               # s0 = n, the number to count up to
        li      s1, 0                # s1 = total = 0
        li      t1, 1                # t1 = i = 1

loop:
        bgt     t1, s0, done         # leave the loop as soon as i > n
        add     s1, s1, t1           # total = total + i
        addi    t1, t1, 1            # i = i + 1
        beq     x0, x0, loop         # repeat

done:
        mv      a0, s1               # place the result where the caller looks

        lw      s0, 0(sp)            # restore the caller's s0
        lw      s1, 4(sp)            # restore the caller's s1
        addi    sp, sp, 8            # release the stack space
        jalr    x0, ra, 0            # return