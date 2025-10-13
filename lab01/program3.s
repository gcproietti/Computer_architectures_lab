############################################################
# RISC-V PROGRAM — ARRAY COMPARISON & FLAG CHECKING
# ----------------------------------------------------------
# Author: Gabriele Mincigrucci, Giacomo Proietti, Vincenzo Cenzo 
#
# PROGRAM DESCRIPTION:
#   This program performs element-wise comparison between two arrays V1 and V2.
#   For each element in V1 that exists in V2, the element is stored in result array V3,
#   but only if it doesn't already exist in V3 (avoiding duplicates).
#
#   After the comparison phase, the program analyzes V3 and sets three flags:
#     - FLAG 1 (x30): Indicates if V3 is empty (1 = empty, 0 = contains data)
#     - FLAG 2 (x29): Indicates if V3 is strictly increasing (1 = increasing, 0 = not increasing)
#     - FLAG 3 (x28): Indicates if V3 is strictly decreasing (1 = decreasing, 0 = not decreasing)
#
#   The program terminates with a system call (ecall 93) for clean exit.
#
# ARRAY SPECIFICATIONS:
#   - Arrays V1 and V2 contain 10 bytes each
#   - Result array V3 is initialized to 10 zeros
#   - All arrays are stored in contiguous memory locations
#
# ALGORITHM OVERVIEW:
#   1. Initialize pointers and control registers
#   2. Nested loops: Outer loop scans V1, inner loop scans V2
#   3. For each match found, check V3 for duplicates before storing
#   4. Set FLAG 1 based on whether any elements were stored in V3
#   5. Analyze V3 sequence to determine if it's increasing/decreasing
#   6. Set FLAG 2 and FLAG 3 accordingly
#   7. Exit program
############################################################

# REGISTER USAGE REFERENCE (COMPREHENSIVE)
# ----------------------------------------------------------
# x1   → Pointer to current element in V1 (outer loop iterator)
# x2   → Pointer to current element in V2 (inner loop iterator)  
# x3   → Temporary pointer for V3 during duplicate checking
# x4   → Current element value loaded from V1
# x5   → Current element value loaded from V2 / candidate for V3 storage
# x6   → End address of V2 (used as loop boundary)
# x7   → End address of V1 (used as loop boundary)
# x8   → Array length constant (fixed value 10)
# x11  → General-purpose temporary register
# x12  → Index counter for V3 traversal during duplicate checking
# x13  → Pointer to current write position in V3 (where next element will be stored)
# x14  → Temporary value loaded from V3 during duplicate comparison
# x23  → Debug/temporary storage
# x24  → (Not actively used in current implementation)
# x25  → Temporary storage for flag comparison operations
# x26  → Temporary storage for flag comparison operations  
# x27  → Pointer used during flag checking routines
# x28  → FLAG 3: Decreasing order indicator (1 = decreasing, 0 = not decreasing)
# x29  → FLAG 2: Increasing order indicator (1 = increasing, 0 = not increasing)
# x30  → FLAG 1: V3 emptiness indicator (1 = empty, 0 = contains data)

############################################################


###############################
# DATA SECTION - ARRAY DEFINITIONS
###############################
.section .data
# Define the input and output arrays with initial values
V1: .byte 9,8,7,6,5,4,3,2,1,1    # First input array (may contain duplicates)
V2: .byte 1,2,3,3,4,5,6,7,8,9    # Second input array (may contain duplicates)  
V3: .byte 0,0,0,0,0,0,0,0,0,0    # Result array initialized to zeros


###############################
# CODE SECTION - PROGRAM EXECUTION
###############################
.section .text
.globl _start 
_start:
# INITIALIZATION PHASE
# Load the starting addresses of all three arrays into registers
la x1, V1                  # x1 ← base address of array V1
la x2, V2                  # x2 ← base address of array V2  
la x3, V3                  # x3 ← base address of array V3

# Initialize general-purpose registers to zero for clean state
li x4, 0                   # Clear V1 element temporary register
li x5, 0                   # Clear V2 element temporary register
li x6, 0                   # Clear end address temporary
li x7, 0                   # Clear end address temporary
li x8, 10                  # Set array length constant = 10 elements

# Initialize helper variables for V3 operations
li x12, 0                  # Initialize index counter for V3 traversal
la x13, V3                 # x13 stores current write position in V3 (starts at beginning)
li x14, 0                  # Initialize temporary for V3 element comparison

# Initialize flag registers with default values
li x30, 1                  # FLAG 1 = 1 (assume V3 is empty initially)
li x29, 0                  # FLAG 2 = 0 (not increasing - unknown state)
li x28, 0                  # FLAG 3 = 0 (not decreasing - unknown state)

# Initialize helper registers for control flow and comparisons
li x27, 1                  # Constant value 1 used for comparisons
li x26, 0                  # Clear flag comparison helper
li x25, 0                  # Clear flag comparison helper  
li x11, 0                  # Clear general-purpose helper
li x23, 0                  # Clear debug/temporary register


###############################
# MAIN PROCESSING - ARRAY COMPARISON ALGORITHM
###############################
Main:
# Calculate end addresses for array boundary checking
add x6, x2, x8             # Compute end address of V2 = V2_base + 10
add x7, x1, x8             # Compute end address of V1 = V1_base + 10

# OUTER LOOP: Iterate through each element of V1
for1:
    beq x1, x7, inizioflag # If V1 pointer reached end, proceed to flag checking
    la x2, V2              # Reset V2 pointer to start for new V1 element
    lb x4, 0(x1)           # Load current byte element from V1 into x4
    addi x1, x1, 1         # Increment V1 pointer to next element
    
    # INNER LOOP: Scan V2 for matches with current V1 element
    for2:
        beq x2, x6, for1       # If V2 pointer reached end, go to next V1 element
        lb x5, 0(x2)           # Load current byte element from V2 into x5
        addi x2, x2, 1         # Increment V2 pointer to next element
        bne x4, x5, for2       # If V1 and V2 elements don't match, continue V2 scan

        ###############################
        # DUPLICATE CHECKING IN V3
        # Before storing matched element in V3, ensure it's not already present
        ###############################
        check_duplicate:
            la x3, V3           # Reset V3 pointer to start for duplicate scan
            li x12, 0           # Reset index counter

            # Scan through already populated portion of V3
            check_loop:
                beq x3, x13, no_dupl   # If reached current write position, element is unique
                lb x14, 0(x3)          # Load element from current V3 position
                beq x14, x5, dupl      # If element matches candidate, skip as duplicate
                addi x3, x3, 1         # Move to next position in V3
                addi x12, x12, 1       # Increment index counter
                j check_loop           # Continue duplicate checking

            # Handle duplicate case - skip storage
            dupl:
                la x3, V3              # Reset V3 pointer (no write operation)
                li x12, 0              # Reset index counter
                j for2                 # Continue with next V2 element

            # Handle unique case - store element in V3
            no_dupl:
                sb x5, 0(x13)          # Store unique element in V3 at current write position
                li x30, 0              # FLAG 1 = 0 (V3 now contains at least one element)
                addi x13, x13, 1       # Advance V3 write pointer to next position
                j for2                 # Continue with next V2 element


############################################################
# FLAG EVALUATION PHASE
# Analyze the contents of V3 to determine array properties
############################################################
inizioflag:
    # Skip flag 2 and 3 checks if V3 is empty (FLAG 1 = 1)
    beq x30, x27, result          # If V3 empty, jump directly to result section

############################################################
# FLAG 2 CHECK: INCREASING ORDER VERIFICATION
# Checks if all elements in V3 are in strictly increasing order
############################################################
    li x29, 1                  # Assume increasing order (optimistic initialization)
    la x27, V3                 # Load start address of V3 for traversal
    addi x13, x13, -1          # Adjust to point to last valid element in V3

    # Traverse V3 checking each consecutive pair
    forfl2:
        beq x27, x13, forfl3       # If reached last element, proceed to Flag 3 check
        lb x26, 0(x27)             # Load current element value
        addi x27, x27, 1           # Move to next element position
        lb x25, 0(x27)             # Load next element value
        blt x26, x25, forfl2       # If current < next, continue checking (still increasing)
        addi x23, x26, 0           # Store current value for debugging (optional)
        li x29, 0                  # Set FLAG 2 = 0 (sequence is not strictly increasing)

############################################################
# FLAG 3 CHECK: DECREASING ORDER VERIFICATION  
# Checks if all elements in V3 are in strictly decreasing order
############################################################
forfl3:
    li x28, 1                  # Assume decreasing order (optimistic initialization)
    la x27, V3                 # Reset pointer to start of V3 for new traversal

    # Traverse V3 checking each consecutive pair for decreasing order
    forfl3a:
        beq x27, x13, result       # If reached last element, proceed to final result
        lb x26, 0(x27)             # Load current element value
        addi x27, x27, 1           # Move to next element position
        lb x25, 0(x27)             # Load next element value
        blt x25, x26, forfl3a      # If next < current, continue checking (still decreasing)
        li x28, 0                  # Set FLAG 3 = 0 (sequence is not strictly decreasing)

############################################################
# RESULT PREPARATION AND DEBUG SECTION
# Optional: Load V3 contents into registers for inspection
############################################################
result:
# Load all elements of V3 into registers for potential debugging/verification
la x11, V3                    # Get base address of V3
lb x12, 0(x11)                # Load V3[0] into x12
lb x22, 0(x13)                # Load last element of V3 into x22  
lb x13, 1(x11)                # Load V3[1] into x13
lb x14, 2(x11)                # Load V3[2] into x14
lb x15, 3(x11)                # Load V3[3] into x15
lb x16, 4(x11)                # Load V3[4] into x16
lb x17, 5(x11)                # Load V3[5] into x17
lb x18, 6(x11)                # Load V3[6] into x18
lb x19, 7(x11)                # Load V3[7] into x19
lb x20, 8(x11)                # Load V3[8] into x20
lb x21, 9(x11)                # Load V3[9] into x21


############################################################
# PROGRAM TERMINATION
# Exit cleanly using RISC-V system call
############################################################
End:
li a0, 0                      # Set exit code to 0 (success)
li a7, 93                     # Set system call number for exit (93)
ecall                         # Execute system call to terminate program