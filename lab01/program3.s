############################################################
# RISC-V PROGRAM — ARRAY COMPARISON & FLAG CHECKING
# ----------------------------------------------------------
# Author: Gabriele Mincigrucci, Giacomo Proietti, Vincenzo Cenzo 
#
# Description:
#   The program compares two arrays (V1 and V2).
#   Every time an element from V1 is found in V2,
#   it is stored into a result array V3.
#
#   Once the comparison is done, the program sets:
#     - FLAG 1 (x30): =1 if V3 is empty, =0 if V3 has data
#     - FLAG 2 (x29): =1 if V3 is increasing
#     - FLAG 3 (x28): =1 if V3 is decreasing
#
#   Finally, it exits cleanly with ecall 93.
############################################################
# REGISTER USAGE REFERENCE (UPDATED)
# ----------------------------------------------------------
# x1   → pointer to current element in V1
# x2   → pointer to current element in V2
# x3   → pointer used for traversing V3 (duplicate check / store)
# x4   → current element of V1
# x5   → current element of V2 / element to store in V3
# x6   → end address of V2 (V2 + length)
# x7   → end address of V1 (V1 + length)
# x8   → array length constant (10)
# x11  → general-purpose temporary
# x12  → index for traversing V3 (duplicate checking)
# x13  → pointer to current write position in V3
# x14  → temporary value loaded from V3 (duplicate checking)
# x24  → sentinel value / last valid element in V3
# x25  → temporary value for flag comparison
# x26  → temporary value for flag comparison
# x27  → pointer used during flag checking
# x28  → FLAG 3 (1 = decreasing, 0 = not decreasing)
# x29  → FLAG 2 (1 = increasing, 0 = not increasing)
# x30  → FLAG 1 (1 = V3 empty, 0 = V3 not empty)

############################################################


###############################
# DATA SECTION
###############################
.section .data
# Array definitions
V1: .byte 2,6,-3,11,9,18,-13,16,5,1    # First array
V2: .byte 4,2,-13,3,9,9,7,16,4,7       # Second array
V3: .byte 0,0,0,0,0,0,0,0,0,0          # Result array (initialized to 0)


###############################
# CODE SECTION
###############################
.section .text
.globl _start 
_start:
# Load the starting addresses of V1, V2, V3
la x1, V1                  # x1 ← address of V1
la x2, V2                  # x2 ← address of V2
la x3, V3                  # x3 ← address of V3

# Initialize general-purpose and control registers
li x4, 0                   # Clear temporary register
li x5, 0                   # Clear temporary register (used later for flags)
li x6, 0                   # Clear temporary register
li x7, 0                   # Clear temporary register
li x8, 10                  # Array length constant = 10

# Initialize helper variables for duplicate checking
li x12, 0                  # Index for V3 traversal
la x13, V3                 # x13 stores the current writing position in V3
li x14, 0                  # Temp variable for duplicate checking

# Initialize flags and helper registers
li x30, 1                  # FLAG 1 = 1 (V3 initially empty)
li x29, 0                  # FLAG 2 = 0 (not increasing yet)
li x28, 0                  # FLAG 3 = 0 (not decreasing yet)
li x27, 1                  # Helper variable used for flow control
li x26, 0                  # Helper for flag checking
li x25, 0                  # Helper for flag checking
li x24, 0                  # Placeholder for last valid value in V3
li x11, 0                  # General-purpose helper

# Initialize print register
li x17, 0
li x18, 0
li x19, 0
li x20, 0
li x21, 0
li x22, 0
li x23, 0

###############################
# MAIN LOOP — ARRAY COMPARISON
###############################
Main:
add x6, x2, x8             # Compute end address of V2 = V2 + length
add x7, x1, x8             # Compute end address of V1 = V1 + length

for1:                      # Outer loop: iterate through V1
    beq x1, x7, inizioflag # If end of V1 reached, go to flag checking
    la x2, V2              # Reset V2 pointer to start
    lb x4, 0(x1)           # Load current element from V1 into x4
    addi x1, x1, 1         # Move V1 pointer to next element
    
    # Inner loop — scan V2 for matches with current V1 element
    for2:
        beq x2, x6, for1       # If end of V2 reached, go back to next V1 element
        lb x5, 0(x2)           # Load current element from V2 into x5
        addi x2, x2, 1         # Move V2 pointer to next element
        bne x4, x5, for2       # If elements differ, continue loop

        ###############################
        # CHECK FOR DUPLICATES IN V3
        ###############################
        check_duplicate:
            la x3, V3           # Reset V3 pointer
            li x12, 0           # Reset index

            check_loop:         # Loop through V3 to check duplicates
                beq x3, x13, no_dupl   # If reached current write position, no duplicates found
                lb x14, 0(x3)          # Load element from V3
                beq x14, x5, dupl      # If element equals new one, it's a duplicate
                addi x3, x3, 1         # Increment V3 pointer
                addi x12, x12, 1       # Increment index
                j check_loop           # Continue checking

            dupl:
                la x3, V3              # Reset V3 pointer (no write)
                li x12, 0
                j for2                 # Skip writing duplicate, continue comparing V2

            no_dupl:
                sb x5, 0(x13)          # Store the matching value into V3
                li x30, 0              # FLAG 1 = 0 (V3 is not empty)
                addi x13, x13, 1       # Move V3 write pointer forward
                j for2                 # Continue with next V2 element


############################################################
# FLAGS 2 AND 3 CHECKING ROUTINE
#   Checks whether V3 is increasing or decreasing
############################################################
inizioflag:
    beq x30, x27, print          # If FLAG1 == 1 (V3 empty), skip flag checks

############################################################
# FLAG 2 CHECK (INCREASING ORDER)
############################################################
    li x29, 1                  # Assume increasing (true)
    la x27, V3                 # Load start of V3

forfl2:
    lb x26, 0(x27)             # Load current element
    addi x27, x27, 1           # Move pointer
    beq x26, x24, forfl3       # If current == sentinel (0), skip to flag 3
    lb x25, 0(x27)             # Load next element
    blt x26, x25, forfl2       # If current < next, continue
    li x29, 0                  # Otherwise, not increasing → FLAG2 = 0

############################################################
# FLAG 3 CHECK (DECREASING ORDER)
############################################################
forfl3:
    li x28, 1                  # Assume decreasing (true)
    la x27, V3                 # Reset pointer to V3 start

forfl3a:
    lb x26, 0(x27)             # Load current element
    addi x27, x27, 1           # Move pointer
    beq x26, x24, print          # If current == sentinel, done
    lb x25, 0(x27)             # Load next element
    blt x25, x26, forfl3a      # If next < current, continue
    li x28, 0                  # Otherwise, not decreasing → FLAG3 = 0

############################################################
# PRINT V3 IN THE REGISTER x18 TO x27
############################################################
print:
la x17, V3
lb x18, 0(x17)
lb x19, 1(x17)
lb x20, 2(x17)
lb x21, 3(x17)
lb x22, 4(x17)
lb x23, 5(x17)
lb x24, 6(x17)
lb x25, 7(x17)
lb x26, 8(x17)
lb x27, 9(x17)
j End

############################################################
# END OF PROGRAM
############################################################
End:
li a0, 0                      # Exit code = 0
li a7, 93                     # Syscall number for exit
ecall                         # Exit program gracefully
