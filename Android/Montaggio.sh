#!/bin/bash

set -euo pipefail
shopt -s nullglob

# === CONFIGURAZIONE ===
# Prefisso della cartella di mount (es. "system" diventa ./mount/system/)
MOUNT_BASE="./mount"

# Crea la cartella base di mount se non esiste
mkdir -p "$MOUNT_BASE"

# === CICLO PRINCIPALE ===
for br_file in *.new.dat.br; do
    base="${br_file%.new.dat.br}"  # Nome base (es: system, vendor, product, odm, system_ext)

    img_file="${base}.img"
    mount_dir="${MOUNT_BASE}/${base}"

    # === STEP 3: Montaggio dell'immagine ===
    echo "Preparazione e montaggio di $img_file..."

    # Crea la cartella di mount se non esiste
    sudo mkdir -p "$mount_dir"

    # Smonta se già montato
    if mountpoint -q "$mount_dir"; then
        echo "Smontaggio precedente di $mount_dir..."
        sudo umount "$mount_dir"
    fi

    # Monta l'immagine
    sudo mount "$img_file" "$mount_dir"

    echo "Completato: $img_file montato su $mount_dir"
    echo
done

echo "Tutte le partizioni sono state montate correttamente."
