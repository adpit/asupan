#!/bin/bash

# Tentukan lokasi folder data MT4
MT4_BASE_DIR="$HOME/Library/Application Support/net.metaquotes.wine.metatrader4/drive_c/Program Files (x86)/MetaTrader 4"
EX_COMPILE_SHARED="$HOME/Documents"

# Tentukan lokasi file sumber (file .mq4)
EA2_SOURCE="./sample.mq4" # Lokasi file sumber di direktori lokal

# Tentukan lokasi tujuan untuk file .ex4
EXPERTS_DIR="$MT4_BASE_DIR/MQL4/Experts"

# Fungsi untuk membuat backup file tujuan
function backup_file() {
    DESTINATION_FILE=$1
    DESTINATION_DIR=$2

    # Ekstrak nama file dari path tujuan
    FILENAME=$(basename "$DESTINATION_FILE")

    # Buat subfolder arsip jika belum ada
    ARCHIVE_DIR="$DESTINATION_DIR/arsip"
    mkdir -p "$ARCHIVE_DIR"

    # Tambahkan timestamp ke nama file backup
    TIMESTAMP=$(date +"%Y-%m-%d-%H-%M-%S")
    BACKUP_NAME="${FILENAME%.*}-$TIMESTAMP.${FILENAME##*.}"
    BACKUP_PATH="$ARCHIVE_DIR/$BACKUP_NAME"

    # Pindahkan file tujuan ke subfolder arsip
    if [ -f "$DESTINATION_FILE" ]; then
        mv "$DESTINATION_FILE" "$BACKUP_PATH"
        echo "File '$FILENAME' telah dibackup sebagai '$BACKUP_NAME' di '$ARCHIVE_DIR'."
    else
        echo "Tidak ada file '$FILENAME' untuk dibackup."
    fi
}

# Fungsi untuk membandingkan file berdasarkan checksum
function compare_and_copy() {
    SOURCE_FILE=$1
    DESTINATION_DIR=$2

    # Ekstrak nama file dari path sumber
    FILENAME=$(basename "$SOURCE_FILE")
    DESTINATION_FILE="$DESTINATION_DIR/$FILENAME"

    # Hitung checksum file sumber dan tujuan
    SOURCE_CHECKSUM=$(md5sum "$SOURCE_FILE" | awk '{print $1}')
    if [ -f "$DESTINATION_FILE" ]; then
        DESTINATION_CHECKSUM=$(md5sum "$DESTINATION_FILE" | awk '{print $1}')
    else
        DESTINATION_CHECKSUM=""
    fi

    # Bandingkan checksum
    if [ "$SOURCE_CHECKSUM" != "$DESTINATION_CHECKSUM" ]; then
        # Backup file tujuan sebelum menyalin
        backup_file "$DESTINATION_FILE" "$DESTINATION_DIR"

        # Salin file sumber ke lokasi tujuan
        cp "$SOURCE_FILE" "$DESTINATION_DIR/"
        echo "File '$FILENAME' berhasil disalin ke '$DESTINATION_DIR/' karena ada perubahan."
    else
        echo "Tidak ada perubahan pada file '$FILENAME'. File tidak disalin."
    fi
}

# Fungsi untuk memeriksa apakah file .ex4 sudah ada di folder target
function check_ex4_in_target() {
    MQ4_FILE=$1
    TARGET_EX4="$EXPERTS_DIR/${MQ4_FILE%.mq4}.ex4"

    # Periksa apakah file .ex4 ada di folder target
    if [ ! -f "$TARGET_EX4" ]; then
        echo "File '$TARGET_EX4' tidak ditemukan di folder target. Pastikan file .mq4 sudah dikompilasi di MetaEditor."
    else
        echo "File '$TARGET_EX4' sudah ada di folder target."
    fi
}

# Salin file .mq4 ke folder MQL4/Experts jika ada perubahan
compare_and_copy "$EA_SOURCE" "$EXPERTS_DIR"
compare_and_copy "$EA2_SOURCE" "$EXPERTS_DIR"
compare_and_copy "$EA3_SOURCE" "$EXPERTS_DIR"

# Periksa apakah file .ex4 sudah ada di folder target
check_ex4_in_target "$EA_SOURCE"
check_ex4_in_target "$EA2_SOURCE"
check_ex4_in_target "$EA3_SOURCE"

# Jika Anda ingin menyalin file .ex4 ke lokasi lain (misalnya shared folder), tambahkan logika berikut:
EX4_FILE="${EA_SOURCE%.mq4}.ex4"
SHARED_EX4="$EX_COMPILE_SHARED/${EX4_FILE##*/}"

if [ -f "$EXPERTS_DIR/$EX4_FILE" ]; then
    # Salin file .ex4 ke lokasi shared
    cp "$EXPERTS_DIR/$EX4_FILE" "$SHARED_EX4"
    echo "File '$EX4_FILE' berhasil disalin ke lokasi shared: '$SHARED_EX4'."

    # Salin file .ex4 ke direktori kerja saat ini (pwd)
    cp "$EXPERTS_DIR/$EX4_FILE" "./$EX4_FILE"
    echo "File '$EX4_FILE' berhasil disalin ke direktori kerja saat ini: '$(pwd)/$EX4_FILE'."
else
    echo "File '$EX4_FILE' tidak ditemukan di folder target. Pastikan file .mq4 sudah dikompilasi di MetaEditor."
fi

# Jika Anda ingin menyalin file .ex4 ke lokasi lain (misalnya shared folder), tambahkan logika berikut:
EX42_FILE="${EA2_SOURCE%.mq4}.ex4"
SHARED_EX4="$EX_COMPILE_SHARED/${EX42_FILE##*/}"

if [ -f "$EXPERTS_DIR/$EX42_FILE" ]; then
    # Salin file .ex4 ke lokasi shared
    cp "$EXPERTS_DIR/$EX42_FILE" "$SHARED_EX4"
    echo "File '$EX42_FILE' berhasil disalin ke lokasi shared: '$SHARED_EX4'."

    # Salin file .ex4 ke direktori kerja saat ini (pwd)
    cp "$EXPERTS_DIR/$EX42_FILE" "./$EX42_FILE"
    echo "File '$EX42_FILE' berhasil disalin ke direktori kerja saat ini: '$(pwd)/$EX42_FILE'."
else
    echo "File '$EX42_FILE' tidak ditemukan di folder target. Pastikan file .mq4 sudah dikompilasi di MetaEditor."
fi

# Jika Anda ingin menyalin file .ex4 ke lokasi lain (misalnya shared folder), tambahkan logika berikut:
EX43_FILE="${EA3_SOURCE%.mq4}.ex4"
SHARED_EX4="$EX_COMPILE_SHARED/${EX43_FILE##*/}"

if [ -f "$EXPERTS_DIR/$EX43_FILE" ]; then
    # Salin file .ex4 ke lokasi shared
    cp "$EXPERTS_DIR/$EX43_FILE" "$SHARED_EX4"
    echo "File '$EX43_FILE' berhasil disalin ke lokasi shared: '$SHARED_EX4'."

    # Salin file .ex4 ke direktori kerja saat ini (pwd)
    cp "$EXPERTS_DIR/$EX43_FILE" "./$EX43_FILE"
    echo "File '$EX43_FILE' berhasil disalin ke direktori kerja saat ini: '$(pwd)/$EX43_FILE'."
else
    echo "File '$EX43_FILE' tidak ditemukan di folder target. Pastikan file .mq4 sudah dikompilasi di MetaEditor."
fi
