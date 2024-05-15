#!/bin/bash

# Direktori sumber
SOURCE_DIR="Newspaper-tf"
# Direktori tujuan
DEST_DIR="wp1/wp-content"
THEMES_DIR="$DEST_DIR/themes"
PLUGINS_DIR="$DEST_DIR/plugins"
# Direktori sementara untuk ekstraksi
TMP_DIR="/tmp/wp_extraction"

# Pastikan direktori tujuan ada
if [ ! -d "$DEST_DIR" ]; then
    echo "Direktori tujuan tidak ditemukan!"
    exit 1
fi

# Buat direktori sementara jika belum ada
mkdir -p "$TMP_DIR"

# Fungsi untuk menghapus folder dan file yang tidak diperlukan
clean_target_directories() {
    echo "Membersihkan folder di $THEMES_DIR kecuali twentytwentyfour dan Newspaper*"
    for dir in "$THEMES_DIR"/*; do
        if [[ "$dir" != *"twentytwentyfour"* && "$dir" != *"Newspaper"* ]]; then
            echo "Menghapus $dir"
            rm -rf "$dir"
        fi
    done

    echo "Menghapus plugin hello di $PLUGINS_DIR"
    if [ -f "$PLUGINS_DIR/hello.php" ]; then
        rm -f "$PLUGINS_DIR/hello.php"
    fi
}

# Fungsi untuk mengekstrak file zip
extract_zip() {
    local zip_file="$1"
    local target_dir="$2"
    echo "Mengekstrak $zip_file ke $TMP_DIR"
    unzip -q "$zip_file" -d "$TMP_DIR"
    mkdir -p "$target_dir"
    echo "Memindahkan konten dari $TMP_DIR ke $target_dir"
    mv "$TMP_DIR"/* "$target_dir"
    echo "Membersihkan direktori sementara $TMP_DIR"
    rm -rf "$TMP_DIR"/*
}

# Fungsi untuk menyalin folder
copy_folder() {
    local src_folder="$1"
    local target_dir="$2"
    echo "Menyalin $src_folder ke $target_dir"
    mkdir -p "$target_dir"
    cp -rf "$src_folder"/* "$target_dir"
    echo "Konten dari $src_folder telah disalin ke $target_dir"
}

# Bersihkan target directories terlebih dahulu
clean_target_directories

# Mengekstrak file tema Newspaper.zip ke dalam folder themes
THEME_ZIP="$SOURCE_DIR/Newspaper.zip"
if [ -f "$THEME_ZIP" ]; then
    extract_zip "$THEME_ZIP" "$THEMES_DIR/Newspaper"
fi

# Mengekstrak file child theme jika ada
CHILD_THEME_DIR="$SOURCE_DIR/code/Newspaper-child"
if [ -d "$CHILD_THEME_DIR" ]; then
    copy_folder "$CHILD_THEME_DIR" "$THEMES_DIR/Newspaper-child"
fi

# Mengekstrak semua plugin yang ada di folder plugins
PLUGIN_DIR="$SOURCE_DIR/plugins"
if [ -d "$PLUGIN_DIR" ]; then
    for item in "$PLUGIN_DIR"/*; do
        if [[ "$item" == *.zip ]]; then
            extract_zip "$item" "$PLUGINS_DIR/$(basename "$item" .zip)"
        elif [ -d "$item" ]; then
            copy_folder "$item" "$PLUGINS_DIR/$(basename "$item")"
        fi
    done
fi

# Menyalin folder yang relevan ke dalam folder wp-content/themes/Newspaper
RELEVANT_FOLDERS=("patch_12.6.5_12.6.6")

for folder in "${RELEVANT_FOLDERS[@]}"; do
    if [ -d "$SOURCE_DIR/$folder" ]; then
        copy_folder "$SOURCE_DIR/$folder" "$THEMES_DIR/Newspaper/$folder"
    fi
done

# Bersihkan direktori sementara
rm -rf "$TMP_DIR"

echo "Semua file dan folder yang relevan telah berhasil diproses dan disalin ke folder tujuan!"
