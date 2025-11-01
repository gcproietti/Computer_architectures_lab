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
# DATA SEGMENT — input and output arrays
############################################################

# V1: Input array (values 1.0 → 32.0)
V1: .float  1.0,  2.0,  3.0,  4.0,  5.0,  6.0,  7.0,  8.0, 9.0, 10.0, 11.0, 12.0, 13.0, 14.0, 15.0, 16.0, 17.0, 18.0, 19.0, 20.0, 21.0, 22.0, 23.0, 24.0, 25.0, 26.0, 27.0, 28.0, 29.0, 30.0, 31.0, 32.0

# V2: Second input array (same as V1)
V2: .float  1.0,  2.0,  3.0,  4.0,  5.0,  6.0,  7.0,  8.0, 9.0, 10.0, 11.0, 12.0, 13.0, 14.0, 15.0, 16.0, 17.0, 18.0, 19.0, 20.0, 21.0, 22.0, 23.0, 24.0, 25.0, 26.0, 27.0, 28.0, 29.0, 30.0, 31.0, 32.0

# V3: Third input array (same as V1)
V3: .float  1.0,  2.0,  3.0,  4.0,  5.0,  6.0,  7.0,  8.0, 9.0, 10.0, 11.0, 12.0, 13.0, 14.0, 15.0, 16.0, 17.0, 18.0, 19.0, 20.0, 21.0, 22.0, 23.0, 24.0, 25.0, 26.0, 27.0, 28.0, 29.0, 30.0, 31.0, 32.0

# V4–V6: Output buffers (each 32 floats = 128 bytes)
V4: .space 128
V5: .space 128
V6: .space 128

# Constant used as 'b' in arithmetic operations
myfloat: .float 3.14

.section .text
.globl _start
_start:

############################################################
# REGISTER INITIALIZATION
############################################################

li x1, 31        # Loop index i = 31 (start from last element)
la x2, V1        # Pointer to V1
la x3, V2        # Pointer to V2
la x4, V3        # Pointer to V3
la x5, V4        # Pointer to V4 (output)
la x6, V5        # Pointer to V5 (output)
la x7, V6        # Pointer to V6 (output)

li x9, 0         # Temp register for modulo
li x10, 1        # m = 1 (integer, updated dynamically)
li x30, 3        # Constant divisor for modulo operation
la x15, myfloat  # Load address of float constant b

############################################################
# ADJUST POINTERS TO ARRAY END (for reverse iteration)
############################################################
addi x2, x2, 124
addi x3, x3, 124
addi x4, x4, 124
rem x9, x1, x30       # Compute i % 3
addi x5, x5, 124
addi x6, x6, 124
addi x7, x7, 124
flw f19, 0(x15)       # Load b constant into f19

############################################################
# MAIN LOOP — process all elements in reverse order
############################################################
for1:
    blt x1, x0, End        # Exit when i < 0
    bne x9, x0, else       # If i % 3 != 0 → go to else case

############################################################
# CASE 1: index i is multiple of 3
############################################################
    sll x11, x10, x1       # intermed = m << i
    flw f1, 0(x2)          # Load V1[i]
    fcvt.s.w f11, x11, rtz # Convert to float
    fdiv.s f8, f1, f11     # a = V1[i] / intermed
    addi x1, x1, -1
    addi x2, x2, -4
    flw f2, 0(x3)          # Load V2[i]
    flw f3, 0(x4)          # Load V3[i]
    j oldprog              # Jump to shared computation

############################################################
# CASE 2: index i is not multiple of 3
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
# COMMON COMPUTATION — executed after 'a' is computed
############################################################
oldprog:
    rem x9, x1, x30        # Update i % 3
    fcvt.w.s x10, f8, rtz  # m = (int)a
    fcvt.s.w f8, x10, rtz  # a = (float)m

    ########################################################
    # Compute V4[i] = a * V1[i] – V2[i]
    ########################################################
    fmul.s f14, f8, f1
    fsub.s f4, f14, f2

    ########################################################
    # Compute V5[i] = (V4[i] / V3[i]) – b
    ########################################################
    fdiv.s f5, f4, f3
    fsw f4, 0(x5)
    addi x3, x3, -4
    addi x4, x4, -4

    ########################################################
    # Prepare for nested processing or end-iteration logic
    ########################################################
    blt x1, x0, saltoperfinire   # Exit if i < 0
    bne x9, x0, else1            # If i % 3 != 0 → go to else1

############################################################
# SECOND CASE 1: i is multiple of 3 (nested iteration)
############################################################
    sll x11, x10, x1
    fsub.s f6, f4, f1
    flw f1, 0(x2)
    fcvt.s.w f11, x11, rtz
    fsw f5, 0(x6)
    fsub.s f5, f5, f19
    fdiv.s f8, f1, f11
    addi x5, x5, -4
    addi x6, x6, -4
    fmul.s f6, f6, f5
    fsw f6, 0(x7)
    addi x1, x1, -1
    addi x2, x2, -4
    addi x7, x7, -4
    flw f2, 0(x3)
    flw f3, 0(x4)
    j oldprog

############################################################
# SECOND CASE 2: i is not multiple of 3 (nested iteration)
############################################################
else1:
    fcvt.s.w f20, x10, rtz
    fsw f5, 0(x6)
    fsub.s f5, f5, f19
    fsub.s f6, f4, f1
    flw f1, 0(x2)
    fcvt.s.w f30, x1, rtz
    addi x6, x6, -4
    fmul.s f6, f6, f5
    fsw f6, 0(x7)
    addi x5, x5, -4
    fmul.s f12, f20, f30
    addi x1, x1, -1
    addi x7, x7, -4
    addi x2, x2, -4
    flw f2, 0(x3)
    flw f3, 0(x4)
    fmul.s f8, f1, f12

############################################################
# COMMON CODE (nested level)
############################################################
oldprog1:
    rem x9, x1, x30
    fcvt.w.s x10, f8, rtz
    fcvt.s.w f8, x10, rtz

    ########################################################
    # Compute V4[i], V5[i], and V6[i] again at nested depth
    ########################################################
    fmul.s f14, f8, f1
    fsub.s f4, f14, f2
    fdiv.s f5, f4, f3
    fsw f4, 0(x5)
    addi x3, x3, -4
    addi x4, x4, -4
    addi x5, x5, -4
    fsub.s f5, f5, f19
    fsw f5, 0(x6)
    fsub.s f6, f4, f1
    addi x6, x6, -4
    fmul.s f6, f6, f5
    fsw f6, 0(x7)
    addi x7, x7, -4
    j for1

############################################################
# FINALIZATION — complete last iteration and exit
############################################################
saltoperfinire:
    addi x5, x5, -4
    fsub.s f5, f5, f19
    fsw f5, 0(x6)
    fsub.s f6, f4, f1
    addi x6, x6, -4
    fmul.s f6, f6, f5
    fsw f6, 0(x7)

End:
    li a0, 0
    li a7, 93
    ecall
