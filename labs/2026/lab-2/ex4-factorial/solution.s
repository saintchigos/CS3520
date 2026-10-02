# CS3520 Lab 2 - Exercise 4: factorial of n
# RISC-V assembly translation of model.cpp
#
# Demonstrates: a procedure that calls another procedure and therefore has to
# save ra, and a multiplication written with shifts and adds because RV32I has
# no multiply instruction.

        .data
n:      .word   5                   # the number to take the factorial of
msg:    .asciz  "factorial="        # text printed before the answer

        .text
main:
        lw      a0, n                # a0 = n = 5, the only argument
        jal     ra, factorial        # call factorial(a0); result in a0

        mv      s0, a0               # keep the result safe across the print

        la      a0, msg              # a0 = address of the text to print
        li      a7, 4                # a7 = 4 tells the ecall to print text
        ecall                         # print "factorial=" with no newline

        mv      a0, s0               # a0 = the answer again
        li      a7, 1                # a7 = 1 tells the ecall to print int
        ecall                         # print 120 followed by a newline

        li      a7, 10               # a7 = 10 tells the ecall to stop
        ecall                         # exit cleanly

# ---------------------------------------------------------------
# factorial(n in a0) -> 1 * 2 * ... * n in a0
#
# This procedure calls multiply, so it is not a leaf any more. That
# means ra now points at the instruction after the caller's own call,
# so ra has to be saved on the stack and restored before returning or
# the caller would jump to the wrong place.
# ---------------------------------------------------------------
factorial:
        addi    sp, sp, -16          # room for ra plus three saved registers
        sw      ra, 0(sp)            # preserve the return address
        sw      s0, 4(sp)            # preserve the caller's s0
        sw      s1, 8(sp)            # preserve the caller's s1
        sw      s2, 12(sp)           # preserve the caller's s2

        mv      s0, a0               # s0 = n, the number to count up to
        li      s1, 1                # s1 = result = 1, the empty product
        li      s2, 2                # s2 = i = 2, multiplying from 2 upwards

f_loop:
        bgt     s2, s0, f_done        # leave the loop as soon as i > n
        mv      a0, s1               # first argument: the product so far
        mv      a1, s2               # second argument: the next factor
        jal     ra, multiply         # a0 = result * i, computed by the helper
        mv      s1, a0               # keep the new product
        addi    s2, s2, 1            # i++
        beq     x0, x0, f_loop        # repeat

f_done:
        mv      a0, s1               # place the result where the caller looks

        lw      ra, 0(sp)            # restore the return address
        lw      s0, 4(sp)            # restore the caller's s0
        lw      s1, 8(sp)            # restore the caller's s1
        lw      s2, 12(sp)           # restore the caller's s2
        addi    sp, sp, 16           # release the stack space
        jalr    x0, ra, 0            # return to whoever called factorial

# ---------------------------------------------------------------
# multiply(a in a0, b in a1) -> a * b in a0
#
# RV32I cannot multiply, so the product is built one bit at a time.
# While b still has bits left, look at its lowest bit: if that bit is
# 1 then a has to be added to the result. Then double a and shift b
# right by one, which moves the next bit into the lowest position.
# After b becomes 0 every bit of the multiplier has been handled.
# ---------------------------------------------------------------
multiply:
        addi    sp, sp, -16          # room for ra plus three saved registers
        sw      ra, 0(sp)            # preserve the return address
        sw      s0, 4(sp)            # preserve the caller's s0
        sw      s1, 8(sp)            # preserve the caller's s1
        sw      s2, 12(sp)           # preserve the caller's s2

        mv      s0, a0               # s0 = a, the number that gets doubled
        mv      s1, a1               # s1 = b, the multiplier
        li      s2, 0                # s2 = result = 0

m_loop:
        beq     s1, zero, m_done      # every bit has been used once b is zero
        andi    t0, s1, 1            # t0 = b & 1, the lowest bit of b
        beq     t0, zero, m_next      # a zero bit contributes nothing
        add     s2, s2, s0           # a one bit adds a to the result
m_next:
        slli    s0, s0, 1            # a = a * 2, ready for the next bit
        srli    s1, s1, 1            # b = b / 2, bringing the next bit down
        beq     x0, x0, m_loop        # repeat

m_done:
        mv      a0, s2               # place the product where the caller looks

        lw      ra, 0(sp)            # restore the return address
        lw      s0, 4(sp)            # restore the caller's s0
        lw      s1, 8(sp)            # restore the caller's s1
        lw      s2, 12(sp)           # restore the caller's s2
        addi    sp, sp, 16           # release the stack space
        jalr    x0, ra, 0            # return to whoever called multiply