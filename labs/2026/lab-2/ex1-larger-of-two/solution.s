# CS3520 Lab 2 - Exercise 1: larger of two numbers
# RISC-V assembly translation of model.cpp
#
# Demonstrates: .data storage, a leaf procedure, a conditional branch that
# picks one of two values, and the calling convention (arguments in a0/a1,
# result in a0).

        .data
a:      .word   17                  # first number to compare
b:      .word   42                  # second number to compare
msg:    .asciz  "larger="           # text printed before the answer

        .text
main:
        la      a0, a                # a0 = address of the first number
        lw      a0, 0(a0)            # a0 = x = 17, the first argument
        la      t0, b                # t0 = address of the second number
        lw      a1, 0(t0)            # a1 = y = 42, the second argument
        jal     ra, larger           # call larger(a0, a1); result in a0

        mv      s0, a0               # keep the result safe across the print

        la      a0, msg              # a0 = address of the text to print
        li      a7, 4                # a7 = 4 tells the ecall to print text
        ecall                         # print "larger=" with no newline

        mv      a0, s0               # a0 = the answer again
        li      a7, 1                # a7 = 1 tells the ecall to print int
        ecall                         # print 42 followed by a newline

        li      a7, 10               # a7 = 10 tells the ecall to stop
        ecall                         # exit cleanly

# ---------------------------------------------------------------
# larger(x in a0, y in a1) -> the bigger number in a0
#
# This procedure is a leaf, because it calls nothing, so it does not
# have to save ra. It also uses no s-register, so it needs no stack
# frame at all: a0 is scratch space that the caller expects to be
# overwritten with the result.
# ---------------------------------------------------------------
larger:
        blt     a0, a1, take_y       # if x < y, then y must be the answer
        ret                          # x is already in a0, so just return it
take_y:
        mv      a0, a1               # the answer is y, so copy it into a0
        ret                          # return the answer to the caller