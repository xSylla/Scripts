#!/bin/bash

set -euo pipefail
shopt -s nullglob

# Controllo se sdat2img.py esiste
if [[ ! -f "sdat2img.py" ]]; then
    echo "Errore: sdat2img.py non trovato nella directory corrente."
    echo "È necessario clonare la seguente repo: git clone https://github.com/xpirt/sdat2img.git"
    exit 1
fi

# Ciclo su tutti i file *.new.dat.br
for br_file in *.new.dat.br; do
    base="${br_file%.new.dat.br}"  # Nome base (es: system, vendor, product, odm, system_ext)

    dat_file="${base}.new.dat"
    transfer_file="${base}.transfer.list"
    img_file="${base}.img"

    echo "-----------------------------------------"
    echo "Elaborazione della partizione: $base"
    echo "Brotli input:     $br_file"
    echo "DAT output:       $dat_file"
    echo "Transfer list:    $transfer_file"
    echo "IMG finale:       $img_file"
    echo "-----------------------------------------"

    # Verifica che il file transfer.list esista
    if [[ ! -f "$transfer_file" ]]; then
        echo "Errore: $transfer_file non trovato, salto questa partizione."
        continue
    fi

    # Step 1: Decompressione Brotli
    echo "Decompressione di $br_file..."
    brotli -d --output="$dat_file" "$br_file"

    # Step 2: Conversione con sdat2img
    echo "Conversione in IMG..."
    python3 sdat2img.py "$transfer_file" "$dat_file" "$img_file"

    echo "Completato: $img_file creato con successo."
    echo
done

echo "Tutte le partizioni sono state elaborate correttamente."