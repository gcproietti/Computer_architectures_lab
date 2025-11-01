############################################################
############################################################
#
#   Solution developed in a collaboration between:
#
#         Authors         |    Student ID
#   Gabriele Mincigrucci  |     s358987
#   Giacomo Proietti      |     f642298
#
# lab_03
############################################################
############################################################

.section .data

############################################################
# DATA SECTION — array initialization
############################################################

# V1: Input array with 32 float values (1.0 → 32.0)
V1: .float  1.0,  2.0,  3.0,  4.0,  5.0,  6.0,  7.0,  8.0, 9.0, 10.0, 11.0, 12.0, 13.0, 14.0, 15.0, 16.0, 17.0, 18.0, 19.0, 20.0, 21.0, 22.0, 23.0, 24.0, 25.0, 26.0, 27.0, 28.0, 29.0, 30.0, 31.0, 32.0

# V2: Second input array identical to V1
V2: .float  1.0,  2.0,  3.0,  4.0,  5.0,  6.0,  7.0,  8.0, 9.0, 10.0, 11.0, 12.0, 13.0, 14.0, 15.0, 16.0, 17.0, 18.0, 19.0, 20.0, 21.0, 22.0, 23.0, 24.0, 25.0, 26.0, 27.0, 28.0, 29.0, 30.0, 31.0, 32.0

# V3: Third input array identical to V1
V3: .float  1.0,  2.0,  3.0,  4.0,  5.0,  6.0,  7.0,  8.0, 9.0, 10.0, 11.0, 12.0, 13.0, 14.0, 15.0, 16.0, 17.0, 18.0, 19.0, 20.0, 21.0, 22.0, 23.0, 24.0, 25.0, 26.0, 27.0, 28.0, 29.0, 30.0, 31.0, 32.0

# Output arrays (32 floats each = 128 bytes)
V4: .space 128
V5: .space 128
V6: .space 128
myfloat: .float 3.14
.section .text
.globl _start
_start:

############################################################
# REGISTER INITIALIZATION
############################################################

li x1, 31        # Loop index i = 31 (starting from last element)
la x2, V1        # Pointer to V1 array
la x3, V2        # Pointer to V2 array
la x4, V3        # Pointer to V3 array
la x5, V4        # Pointer to V4 output
la x6, V5        # Pointer to V5 output
la x7, V6        # Pointer to V6 output

li x9, 0         # Temporary register
li x10, 1        # Integer m = 1 (updated dynamically)
li x30, 3        # Constant used for modulo operation (i % 3)
la x15, myfloat

############################################################
# Initialize: set pointers to the last element of each array
############################################################
addi x2, x2, 124
addi x3, x3, 124
addi x4, x4, 124
rem x9, x1, x30       # i % 3 calculation for conditional branching
addi x5, x5, 124
addi x6, x6, 124
addi x7, x7, 124
flw f19, 0(x15)       # Load constant b into f19

############################################################
# Main loop: iterate backward through all elements
############################################################
for1:
    blt x1, x0, End        # Exit loop when i < 0

    bne x9, x0, else       # Branch if i is not a multiple of 3

############################################################
# Case 1: i is divisible by 3
############################################################
    sll x11, x10, x1       # intermed = m << i
    flw f1, 0(x2)          # Load V1[i]
    fcvt.s.w f11, x11, rtz # Convert intermed to float
    fdiv.s f8, f1, f11     # a = V1[i] / intermed
    addi x1, x1, -1
    addi x2, x2, -4
    flw f2, 0(x3)          # Load V2[i]
    flw f3, 0(x4)          # Load V3[i]
    j oldprog              # Jump to shared section

############################################################
# Case 2: i is not divisible by 3
############################################################
else:
    fcvt.s.w f20, x10, rtz # Convert m to float
    flw f1, 0(x2)          # Load V1[i]
    fcvt.s.w f30, x1, rtz  # Convert i to float
    addi x1, x1, -1
    fmul.s f12, f20, f30   # intermed = (float)m * i
    addi x2, x2, -4
    flw f2, 0(x3)          # Load V2[i]
    flw f3, 0(x4)          # Load V3[i]
    fmul.s f8, f1, f12     # a = V1[i] * intermed

############################################################
# Common operations after 'a' computation
############################################################
oldprog:
    rem x9, x1, x30        # Update (i % 3) for next iteration
    fcvt.w.s x10, f8, rtz  # m = (int)a
    fcvt.s.w f8, x10, rtz  # Update a = (float)m

    ########################################################
    # Compute V4[i] = a * V1[i] - V2[i]
    ########################################################
    fmul.s f14, f8, f1
    fsub.s f4, f14, f2

    ########################################################
    # Compute V5[i] = (V4[i] / V3[i]) - b
    ########################################################
    fdiv.s f5, f4, f3
    fsw f4, 0(x5)
    addi x3, x3, -4
    addi x4, x4, -4
    addi x5, x5, -4
    fsub.s f5, f5, f19
    fsw f5, 0(x6)

    ########################################################
    # Compute V6[i] = (V4[i] - V1[i]) * V5[i]
    ########################################################
    fsub.s f6, f4, f1
    addi x6, x6, -4
    fmul.s f6, f6, f5
    fsw f6, 0(x7)

    ########################################################
    # Update pointers for next reverse iteration
    ########################################################
    addi x7, x7, -4
    j for1

############################################################
# Program termination
############################################################
End:
    li a0, 0
    li a7, 93
    ecall
