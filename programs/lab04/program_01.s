############################################################
############################################################
#
#   Solution developed in a collaboration between:
#
#         Authors         |    Student ID
#   Gabriele Mincigrucci  |     s358987
#   Giacomo Proietti      |     f642298
#   Vincenzo Pio Altieri  |     s353170
#
# lab_04
############################################################
############################################################

.section .data

############################################################
# DATA SECTION — array initialization
############################################################

# V1: values of the I vector
V1: .float 1.0,  2.0,  3.0,  4.0,  5.0,  6.0,  7.0,  8.0, 9.0, 10.0, 11.0, 12.0, 13.0, 14.0, 15.0, 16.0

# V2: values of the W vector
V2: .float 1.0,  2.0,  3.0,  4.0,  5.0,  6.0,  7.0,  8.0, 9.0, 10.0, 11.0, 12.0, 13.0, 14.0, 15.0, 16.0

# b: bias value (constant 0xab)
b: .word 0xab

# y: output value, initialized to 0
y: .space 4


.section .text
.globl _start
_start:


############################################################
# REGISTER INITIALIZATION
############################################################

li x1, 15        # Loop index i = 15 (starting from last element)
la x2, V1        # Pointer to V1 array
la x3, V2        # Pointer to V2 array
la x4, b         # Load b value
la x5, y         # Load y value (output)
li x6, 0         # To shift f0
li x7, 0xFF      # Mask used to confront the exponent value

fmv.s.x f0, x0   # Initialize accumulator f0 (sum) to 0.0

############################################################
# MOVE POINTERS TO END OF EACH ARRAY (reverse traversal)
############################################################

addi x2, x2, 60
addi x3, x3, 60

############################################################
# MAIN LOOP: Process all elements in reverse order
############################################################

for:
    blt x1, x0, End        # If i < 0 → exit loop

    flw f1, 0(x2)
    flw f2, 0(x3)

    addi x1, x1, -1
    addi x2, x2, -4
    addi x3, x3, -4

    fmul.s f3, f1, f2
    fadd.s f0, f0, f3
    
    j for

End:
    # Add the bias 'b' to the sum
    flw f4, 0(x4)          # Load the float value of b into f4
    fadd.s f0, f0, f4      # f0 = f0 + b. Now f0 holds the final value of x


############################################################
# EXPONENT CHECK AND SAVE RESULT
############################################################
check:
    fmv.x.s x6, f0          # Move the result in x6 to apply the shift

    srli x6, x6, 23         # Shift to the right the result by 23 bits
    beq x6, x7, is_nan      # Check the bits of the exponent
    j store_result

is_nan:
    # If exponent is 0xFF, set y to 0.0
    fmv.s.x f0, x0         # f0 = 0.0

store_result:
    fsw f0, 0(x5)          # Store the final value of y (from f0) into memory

############################################################
# PROGRAM TERMINATION
############################################################
exit:
    li a7, 10              # ecall 10: exit program
    ecall