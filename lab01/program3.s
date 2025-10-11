
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
li x9, 0 

li x30, 1 # FLAG 1
li x29, 0 # FLAG 2
li x28, 0 # FLAG 3
li x11, 0
li x27, 1 # VARIABILE DI APPOGGIO


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
        jal check_duplicate # chiamo la funzione che controlla i duplicati
        sb x5, 0(x3) # store in posizione di x3 il valore
        li x30, 0 # imposto la FLAG 1 a 0 perche adesso v3 è NOT EMPTY
        addi x3, x3, 1 # aumento la posiizone di x3
        j for2




        check_duplicate: # funzione che controlla se il valore è già presente in v3 
            li x12, 0 # indice per scorrere v3
            li x13, 0 # flag per controllo duplicati

            check_loop:
                beq x12, x8, end_check # se l'indice arriva a 10 esco dal ciclo
                lb x14, 0(x3) # carico in x14 il valore di v3
                beq x14, x5, set_flag # se il valore è uguale a quello che sto controllando setto la flag
                addi x11, x11, 1 # incremento il puntatore di v3
                addi x12, x12, 1 # incremento l'indice
                j check_loop # torno all'inizio del ciclo

            set_flag:
                li x13, 1 # setto la flag a 1 se trovo un duplicato


            end_function:
                ret

print:
la x11, V3 


lb x12, 0(x11)
lb x13, 1(x11)
lb x14, 2(x11)
lb x15, 3(x11)
lb x16, 4(x11)
lb x17, 5(x11)
lb x18, 6(x11)
lb x19, 7(x11)
lb x20, 8(x11)
lb x21, 9(x11)



beq x30, x27, End #CONTROLLO SE DEVO CALCOLARE O MENO  FLAG 2 E 3
#QUI PROCESSERO LE FLAG  NUMERO 2 E 3



j End



# HERE CODE
End:
# exit() syscall. This is needed to end the simulation
# gracefully
li a0, 0
li a7, 93
ecall
