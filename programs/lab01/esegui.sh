#!/bin/bash

# Verifica che sia stato passato un parametro
if [ -z "$1" ]; then
    echo "Uso: $0 <nome_programma_senza_estensione>"
    exit 1
fi

# Salva il parametro in una variabile
PROGRAM=$1

# Vai alla home directory
cd ~

# Entra nella cartella ARENA sul Desktop
cd Desktop/ARENA || { echo "Cartella ARENA non trovata"; exit 1; }

# Esegui la compilazione e l'esecuzione
echo "Compilo $PROGRAM.s..."
riscv_compile "$PROGRAM.s"

echo "Eseguo con gem5..."
gem5_run gem5_config.py "$PROGRAM" "$PROGRAM.log"

