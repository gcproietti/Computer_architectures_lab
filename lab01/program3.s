
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
li x5, 0
li x6, 0
li x7, 0
li x8, 10

li x11, 0

Main:
add x6, x2, x8 # sommo all'address di x2 il massimo offset quindi trovo V2 length
add x7, x1, x8 # sommo all'address di x1 il massimo offset quindi trovo V1 length

for1:                       # label da cui parte il loop esterno
    beq x1, x7, print       # se x1 è arrivato al suo ultimo elemento esce dal ciclo
    la x2, V2               # riporto il puntatore di V2 alla posizione 0
    lb x4, 0(x1)            # carica il x4 il un elemento dell'array 1
    addi x1, x1, 1          # porta il puntatore a v1 dalla posizione n alla posizione n+1
    
    for2: # label di inizio del loop interno
        beq x2, x6, for1
        lb x5, 0(x2) # preleva un elemento da V2
        addi x2, x2, 1 # porta il puntatore a v2 dalla posizione n alla posizione n+1
        bne x4, x5, for2 # se i valori sono uguali 
        sb x5, 0(x3) # store in posizione di x3 il valore
        addi x3, x3, 1 # aumento la posiizone di x3
        j for2

print:
la x11, V3 
lb x1, 0(x11)
lb x2, 1(x11)
lb x3, 2(x11)
lb x4, 3(x11)
lb x5, 4(x11)
lb x6, 5(x11)
lb x7, 6(x11)
lb x8, 7(x11)
lb x9, 8(x11)
lb x10, 9(x11)
j End

# HERE CODE
End:
# exit() syscall. This is needed to end the simulation
# gracefully
li a0, 0
li a7, 93
ecall
