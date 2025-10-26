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

############################################################
# MOVE POINTERS TO END OF EACH ARRAY (reverse traversal)
############################################################
addi x2, x2, 124
addi x3, x3, 124
addi x4, x4, 124
addi x5, x5, 124
addi x6, x6, 124
addi x7, x7, 124

############################################################
# MAIN LOOP: Process all elements in reverse order
############################################################
for1:
    blt x1, x0, End        # If i < 0 → exit loop
    rem x9, x1, x30       # Compute i % 3
    bne x9, x0, else      # If (i % 3) != 0 → jump to else case

############################################################
# CASE 1: Index i is a multiple of 3
############################################################
    # Compute intermed = m << i  (integer left-shift)
    sll x11, x10, x1
    # Convert integer to float
    fcvt.s.w f11, x11, rtz
    # Compute a = V1[i] / intermed

    fdiv.s f8, f1, f11
    flw f1, 0(x2)
    flw f2, 0(x3)         # Load V1[i] into f1
    flw f3, 0(x4)
    j oldprog              # Continue common code

############################################################
# CASE 2: Index i is NOT a multiple of 3
############################################################

else:
    # Convert m and i to float

    fcvt.s.w f20, x10, rtz
    fcvt.s.w f30, x1, rtz
    # intermed = (float)m * i
    flw f1, 0(x2)
    fmul.s f12, f20, f30
    flw f3, 0(x4)
    # a = V1[i] * intermed
    fmul.s f8, f1, f12
    flw f2, 0(x3)



############################################################
# COMMON CODE AFTER a COMPUTED
############################################################
oldprog:
    
    # Update m = (int) a
    fcvt.w.s x10, f8, rtz
    # Load required V2 and V3 values

    fmul.s f14, f8, f1
    

    ########################################################
    # Compute V4[i] = a * V1[i] – V2[i]
    ########################################################
    

    fsub.s f4, f14, f2
    
    
    fmv.s f21, f4 #implemento un mv per poter fare diverse operazioi con lo stresso dato

    fdiv.s f5, f21, f3
    addi x1, x1, -1
    
    fsub.s f6, f4, f1
    fsw f4, 0(x5)
    addi x5, x5, -4


    fsub.s f5, f5, f2
    addi x2, x2, -4
    addi x3, x3, -4
    fmul.s f6, f6, f5
    fsw f5, 0(x6)
    addi x6, x6, -4
    
    addi x4, x4, -4
    fsw f6, 0(x7)
    ########################################################
    # Compute V5[i] = V4[i] / V3[i] – V2[i]
    ########################################################
    ########################################################
    # Compute V6[i] = (V4[i] – V1[i]) * V5[i]
    ########################################################
    ########################################################
    # Update pointers and loop index to move backward
    ########################################################
    
    
    
    
    
    addi x7, x7, -4

    j for1                # Repeat loop

############################################################
# PROGRAM END — terminate execution
############################################################
End:
    li a0, 0
    li a7, 93
    ecall

# f1
# f2
# f3
# f4
# f5
# f6
# f7 x
# f8
# f9 x
# f10 x
# f11
# f12
# f13 x
# f14
# f15
# f16
# f17
# f18
# f19
# f20
# f21




