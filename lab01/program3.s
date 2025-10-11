############################################################
# RISC-V PROGRAM — ARRAY COMPARISON & FLAG CHECKING
# ----------------------------------------------------------
# Author: Gabriele Mincigrucci, Giacomo Proietti, Vincenzo cenzo 
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
#
############################################################
# REGISTER USAGE REFERENCE
# ----------------------------------------------------------
# x1   → address pointer for V1
# x2   → address pointer for V2
# x3   → address pointer for V3
#
# x4   → current element of V1
# x5   → current element of V2
# x6   → end address of V2 (V2 + length)
# x7   → end address of V1 (V1 + length)
# x8   → constant = 10 (array length)
#
# x11  → temporary variable (general purpose)
#
# x24  → last valid element stored in V3 (used as sentinel)
# x25  → auxiliary register for comparison in flags
# x26  → auxiliary register for comparison in flags
# x27  → auxiliary pointer for V3 (used during flag check)
#
# x28  → FLAG 3 (1 = decreasing, 0 = not decreasing)
# x29  → FLAG 2 (1 = increasing, 0 = not increasing)
# x30  → FLAG 1 (1 = V3 empty, 0 = V3 not empty)
############################################################


# Data section
.section .data
# Place here your program data.

V1: .byte 2,6,-3,11,9,18,-13,16,5,1    # PRIMO ARRAY
V2: .byte 4,2,-13,3,9,9,7,16,4,7       # SECONDO ARRAY
V3: .byte 0,0,0,0,0,0,0,0,0,0          # ARRAY RISULTATO


# Code section
.section .text
.globl _start 
_start:
# In the _start area, load the first byte/word of each of 
# the areas declared in the .data section
# This is needed to load data in the cache and avoid 
# pipeline stalls later

la x1, V1 #carico address v1
la x2, V2 #carico address v2
la x3, V3 #carico address v3

li x4, 0
li x5, 0 # OLTRE A VAR DI APPOGGIO SERVIRA NELLA DEF DI FLAG 2 E 3
li x6, 0
li x7, 0
li x8, 10

li x30, 1 # FLAG 1
li x29, 0 # FLAG 2
li x28, 0 # FLAG 3
li x27, 1 # VARIABILE DI APPOGGIO
li x26, 0 # un altro appoggio per v3 in flag 2
li x25, 0 #appoggio
li x24, 0 # appoggio ultimo valore di x3

li x11, 0



Main:
add x6, x2, x8 # sommo all'address di x2 il massimo offset quindi trovo V2 length
add x7, x1, x8 # sommo all'address di x1 il massimo offset quindi trovo V1 length

for1:                       # label da cui parte il loop esterno
    beq x1, x7, print       # se x1 è arrivato al suo ultimo elemento esce dal ciclo
    la x2, V2               # riporto il puntatore di V2 alla posizione 0
    lb x4, 0(x1)            # carica in x4 un elemento dell'array 1
    addi x1, x1, 1          # porta il puntatore a v1 dalla posizione n alla posizione n+1
    
    for2:                   # label di inizio del loop interno
        beq x2, x6, for1    # se x2 ha raggiunto fine array, ritorna al loop esterno
        lb x5, 0(x2)        # preleva un elemento da V2
        addi x2, x2, 1      # porta il puntatore a v2 dalla posizione n alla posizione n+1
        bne x4, x5, for2    # se i valori sono diversi, continua ciclo
        sb x5, 0(x3)        # store in posizione di x3 il valore comune
        add x24, x5, 0      # salva l'ultimo valore inserito in V3


        li x30, 0           # imposto la FLAG 1 a 0 perche adesso v3 è NOT EMPTY
        addi x3, x3, 1      # aumento la posiizone di x3
        j for2              # continua la ricerca di altri valori uguali


############################################################
# FLAGS 2 AND 3 CHECKING ROUTINE
#
# PURPOSE:
#   This routine processes two flags (Flag 2 and Flag 3)
#   based on the sequence of bytes stored at label V3.
#
#   - Flag 2 (x29): Set to 1 if the sequence is INCREASING
#                   (each element < next element).
#                   Set to 0 otherwise.
#
#   - Flag 3 (x28): Set to 1 if the sequence is DECREASING
#                   (each element > next element).
#                   Set to 0 otherwise.
#
# REGISTERS USED:
#   x27 → pointer to the current position in array V3
#   x26 → holds the current byte being analyzed
#   x25 → holds the next byte to compare
#   x29 → flag 2 (increasing property)
#   x28 → flag 3 (decreasing property)
#   x30 → external control flag (used to decide whether to process or not)
#   x24 → sentinel value indicating the end of the list
############################################################

    beq x30, x27, End          # IF x30 == x27 → skip processing and jump to End
                               # (control check: decide whether to compute flags or not)

############################################################
# FLAG 2 PROCESSING (CHECK INCREASING ORDER)
############################################################

    li x29, 1                  # Assume flag 2 = "OK" (1)
                               # It will be set to 0 later if property not respected
    la x27, V3                 # Load the address of V3 into x27 (array pointer)

forfl2:                        # Start of the loop for flag 2
    lb x26, 0(x27)             # Load current byte into x26
    addi x27, x27, 1           # Move pointer to next element
    beq x26, x24, forfl3       # If current byte == sentinel, go to flag 3 check

    lb x25, 0(x27)             # Load the next byte for comparison
    blt x26, x25, forfl2       # If current < next, continue loop (still increasing)

    li x29, 0                  # Otherwise, property violated → flag 2 = 0

############################################################
# FLAG 3 PROCESSING (CHECK DECREASING ORDER)
############################################################

forfl3:
    li x28, 1                  # Assume flag 3 = "OK" (1)
                               # It will be set to 0 later if property not respected
    la x27, V3                 # Reset pointer to start of V3

forfl3a:                       # Start of the loop for flag 3
    lb x26, 0(x27)             # Load current byte into x26
    addi x27, x27, 1           # Move pointer to next element
    beq x26, x24, End          # If current byte == sentinel, jump to End

    lb x25, 0(x27)             # Load the next byte for comparison
    blt x25, x26, forfl3a      # If next < current, continue loop (still decreasing)

    li x28, 0                  # Otherwise, property violated → flag 3 = 0

############################################################
# END OF ROUTINE
############################################################
End:

# exit() syscall. This is needed to end the simulation
# gracefully
li a0, 0
li a7, 93
ecall
