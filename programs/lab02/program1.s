############################################################
############################################################
#
#   Solution developed in a collaboration between:
#
#         Authors         |       Mat.
#   Gabriele Mincigrucci  |     s358987
#   Giacomo Proietti      |     f642298
#   Vincenzo Pio Altieri  |     s353170
#
############################################################
############################################################

.section .data                

# --- Define floating-point arrays V1, V2, and V3 (each has 32 elements) ---
V1: .float  1.0,  2.0,  3.0,  4.0,  5.0,  6.0,  7.0,  8.0, 9.0, 10.0, 11.0, 12.0, 13.0, 14.0, 15.0, 16.0, 17.0, 18.0, 19.0, 20.0, 21.0, 22.0, 23.0, 24.0, 25.0, 26.0, 27.0, 28.0, 29.0, 30.0, 31.0, 32.0   

V2: .float  1.0,  2.0,  3.0,  4.0,  5.0,  6.0,  7.0,  8.0, 9.0, 10.0, 11.0, 12.0, 13.0, 14.0, 15.0, 16.0, 17.0, 18.0, 19.0, 20.0, 21.0, 22.0, 23.0, 24.0, 25.0, 26.0, 27.0, 28.0, 29.0, 30.0, 31.0, 32.0   

V3: .float  1.0,  2.0,  3.0,  4.0,  5.0,  6.0,  7.0,  8.0, 9.0, 10.0, 11.0, 12.0, 13.0, 14.0, 15.0, 16.0, 17.0, 18.0, 19.0, 20.0, 21.0, 22.0, 23.0, 24.0, 25.0, 26.0, 27.0, 28.0, 29.0, 30.0, 31.0, 32.0   
# --- Reserve space (128 bytes each) for arrays V4, V5, and V6 ---
V4: .space 128              # Reserve 128 bytes for V4
V5: .space 128              # Reserve 128 bytes for V5
V6: .space 128              # Reserve 128 bytes for V6

.section .text              
.globl _start               
_start:                     

# ---------------- INITIALIZATION SECTION -----------------
li x1, 31                   # x1 -> Loop counter (index = 31)
la x2, V1                   # x2 -> Base address of V1
la x3, V2                   # x3 -> Base address of V2
la x4, V3                   # x4 -> Base address of V3
la x5, V4                   # x5 -> Base address of V4 (output 1)
la x6, V5                   # x6 -> Base address of V5 (output 2)
la x7, V6                   # x7 -> Base address of V6 (output 3)
li x8, 128                  # x8 -> Constant for offset management (array size in bytes)

# --- Adjust all pointers to the end of arrays (process from last to first element) ---
addi x2, x2, 124           
addi x3, x3, 124            
addi x4, x4, 124            
addi x5, x5, 124            
addi x6, x6, 124            
addi x7, x7, 124            

# ---------------- MAIN LOOP -----------------
for1:                       
    blt x1, x0, End          # If counter < 0 → end loop

    # --- Load operands from V1, V2, V3 ---
    flw f1, 0(x2)            # f1 ← V1[i]
    flw f2, 0(x3)            # f2 ← V2[i]
    flw f3, 0(x4)            # f3 ← V3[i]

    # v4[i] = v1[i]*v1[i] – v2[i];
    fmul.s f4, f1, f1        
    fsub.s f4, f4, f2
    fsw f4, 0(x5)            # Store result of v4[i]

    # v5[i] = v4[i]/v3[i] – v2[i];
    fdiv.s f5, f4, f3        
    fsub.s f5, f5, f2
    fsw f5, 0(x6)            # Store result of v5[i]
    
    # v6[i] = (v4[i]-v1[i])*v5[i];
    fsub.s f6, f4, f1        
    fmul.s f6, f6, f5
    fsw f6, 0(x7)            # Store result of v6[i]


    # --- Update loop variables ---
    addi x1, x1, -1          # Decrement index
    addi x2, x2, -4          # Move V1 pointer to previous element
    addi x3, x3, -4          # Move V2 pointer to previous element
    addi x4, x4, -4          # Move V3 pointer to previous element
    addi x5, x5, -4          # Move V4 pointer to previous element
    addi x6, x6, -4          # Move V5 pointer to previous element
    addi x7, x7, -4          # Move V6 pointer to previous element

    j for1                   # Repeat loop

# ---------------- TERMINATION -----------------
End:                         
    li a0, 0
    li a7, 93
    ecall