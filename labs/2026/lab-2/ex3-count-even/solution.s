# CS3520 Lab 2 - Exercise 3: count the even numbers in an array
# RISC-V assembly translation of model.cpp
#
# Demonstrates: testing a value without a divide instruction, andi and bnez
# standing in for the C++ "x % 2 == 0" test, and a loop that updates a
# counter only on some iterations.

        .data
array:  .word   3, 8, 5, 12, 7, 2, 9, 4   # four of these numbers are even
n:      .word   8                          # number of elements in the array
msg:    .asciz  "evens="                   # text printed before the answer

        .text
main:
        la      a0, array           # a0 = base address of the array
        lw      a1, n               # a1 = number of elements
        jal     ra, count_even      # call count_even(a0, a1); result in a0

        mv      s0, a0              # keep the result safe across the print

        la      a0, msg             # a0 = address of the text to print
        li      a7, 4               # a7 = 4 tells the ecall to print text
        ecall                         # print "evens=" with no newline

        mv      a0, s0              # a0 = the answer again
        li      a7, 1               # a7 = 1 tells the ecall to print int
        ecall                         # print 4 followed by a newline

        li      a7, 10              # a7 = 10 tells the ecall to stop
        ecall                         # exit cleanly

# ---------------------------------------------------------------
# count_even(base in a0, count in a1) -> number of even entries in a0
#
# The C++ model asks "arr[i] % 2 == 0", but RV32I has no remainder or
# divide instruction. A number is even exactly when its lowest bit is
# zero, so andi with 1 replaces the "%" and bnez replaces the test.
#
# s0 holds the array address and is the only callee-saved register this
# procedure needs, so the stack frame is a single word.
# ---------------------------------------------------------------
count_even:
        addi    sp, sp, -4          # make room for one saved register
        sw      s0, 0(sp)           # preserve the caller's s0

        mv      s0, a0              # s0 = base address of the array
        li      t0, 0               # t0 = i = 0
        li      t1, 0               # t1 = count = 0
        mv      t2, a1              # t2 = n, the number of elements

loop:
        bge     t0, t2, done        # leave the loop once i >= n
        slli    t3, t0, 2           # t3 = i * 4  (byte offset)
        add     t4, s0, t3          # t4 = &array[i]
        lw      t5, 0(t4)           # t5 = array[i]
        andi    t5, t5, 1           # t5 = array[i] & 1: 0 when the value is even
        bnez    t5, next            # an odd value gives 1, so skip the update
        addi    t1, t1, 1           # count = count + 1
next:
        addi    t0, t0, 1           # i++
        beq     x0, x0, loop        # repeat

done:
        mv      a0, t1              # place the result where the caller looks

        lw      s0, 0(sp)           # restore the caller's s0
        addi    sp, sp, 4           # release the stack space
        jalr    x0, ra, 0           # return