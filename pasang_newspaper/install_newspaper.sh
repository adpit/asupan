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
    # Pindahkan semua konten dari direktori sementara ke direktori target tanpa membuat subfolder baru
    mkdir -p "$target_dir"
    echo "Memindahkan konten dari $TMP_DIR ke $target_dir"
    mv "$TMP_DIR"/*/* "$target_dir"
    echo "Membersihkan direktori sementara $TMP_DIR"
    rm -rf "$TMP_DIR"/*
}

# Fungsi untuk mengekstrak isi folder
extract_folder() {
    local src_folder="$1"
    local target_dir="$2"
    echo "Mengekstrak konten dari $src_folder ke $target_dir"
    unzip -q "$src_folder/revslider.zip" -d "$TMP_DIR"
    mkdir -p "$target_dir"
    mv "$TMP_DIR"/*/* "$target_dir"
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

# Fungsi untuk memastikan baris konfigurasi FS_METHOD ada di wp-config.php
add_fs_method_to_wp_config() {
    local wp_config_file="$1"
    local fs_method_line="// Menginstruksikan WordPress untuk menggunakan metode direktori langsung
define('FS_METHOD', 'direct');"

    if ! grep -q "define('FS_METHOD', 'direct');" "$wp_config_file"; then
        echo "Menambahkan FS_METHOD ke wp-config.php"
        echo -e "\n$fs_method_line" >> "$wp_config_file"
    else
        echo "FS_METHOD sudah ada di wp-config.php"
    fi
}

# Fungsi untuk memeriksa dan mengubah user dan group di httpd.conf jika diperlukan
check_and_update_httpd_conf() {
    local httpd_conf="/Applications/XAMPP/xamppfiles/etc/httpd.conf"
    local current_user
    local current_group
    local new_user
    local new_group

    current_user=$(grep -E "^User" "$httpd_conf" | awk '{print $2}')
    current_group=$(grep -E "^Group" "$httpd_conf" | awk '{print $2}')
    new_user=$(whoami)
    new_group="staff"

    if [[ "$current_user" != "$new_user" || "$current_group" != "$new_group" ]]; then
        echo "Mengubah user dan group di $httpd_conf"
        echo "User saat ini: $current_user"
        echo "Group saat ini: $current_group"
        echo "User baru: $new_user"
        echo "Group baru: $new_group"

        sudo sed -i.bak "s/^User .*/User $new_user/" "$httpd_conf"
        sudo sed -i.bak "s/^Group .*/Group $new_group/" "$httpd_conf"

        echo "Restarting XAMPP..."
        sudo /Applications/XAMPP/xamppfiles/xampp restart
    else
        echo "User dan group sudah sesuai di $httpd_conf"
    fi

    # Verifikasi dan ubah izin hanya jika diperlukan
    if [[ $(stat -f "%u:%g" /Applications/XAMPP/xamppfiles/phpmyadmin/config.inc.php) != "$new_user:$new_group" ]]; then
        echo "Mengubah kepemilikan phpmyadmin/config.inc.php ke $new_user:$new_group"
        sudo chown $new_user:$new_group /Applications/XAMPP/xamppfiles/phpmyadmin/config.inc.php
    fi
    if [[ $(stat -f "%u:%g" /Applications/XAMPP/xamppfiles/temp) != "$new_user:$new_group" ]]; then
        echo "Mengubah kepemilikan temp ke $new_user:$new_group"
        sudo chown -R $new_user:$new_group /Applications/XAMPP/xamppfiles/temp
    fi
    if [[ $(stat -f "%u:%g" /Applications/XAMPP/xamppfiles/logs) != "$new_user:$new_group" ]]; then
        echo "Mengubah kepemilikan logs ke $new_user:$new_group"
        sudo chown -R $new_user:$new_group /Applications/XAMPP/xamppfiles/logs
    fi
    if [[ $(stat -f "%u:%g" /Applications/XAMPP/xamppfiles/htdocs) != "$new_user:$new_group" ]]; then
        echo "Mengubah kepemilikan htdocs ke $new_user:$new_group"
        sudo chown -R $new_user:$new_group /Applications/XAMPP/xamppfiles/htdocs
    fi

    echo "Mengubah izin temp/mysql ke 777"
    sudo chmod 777 /Applications/XAMPP/xamppfiles/temp/mysql/
}

# Periksa dan ubah user dan group di httpd.conf jika diperlukan
check_and_update_httpd_conf

# Bersihkan target directories terlebih dahulu
clean_target_directories


# Periksa dan ubah user dan group di httpd.conf jika diperlukan
check_and_update_httpd_conf

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

# Mengekstrak semua plugin yang ada di folder plugins kecuali td-demo-plugins dan menangani revolution_slider_5 secara khusus
PLUGIN_DIR="$SOURCE_DIR/plugins"
if [ -d "$PLUGIN_DIR" ]; then
    for item in "$PLUGIN_DIR"/*; do
        if [[ "$(basename "$item")" == "td-demo-plugins" ]]; then
            echo "Melewati td-demo-plugins"
            continue
        elif [[ "$(basename "$item")" == "revolution_slider_5" ]]; then
            extract_folder "$item" "$PLUGINS_DIR/revslider"
        elif [[ "$item" == *.zip ]]; then
            extract_zip "$item" "$PLUGINS_DIR/$(basename "$item" .zip)"
        elif [ -d "$item" ]; then
            copy_folder "$item" "$PLUGINS_DIR/$(basename "$item")"
        fi
    done
fi

# Tambahkan FS_METHOD ke wp-config.php jika belum ada
WP_CONFIG_FILE="wp1/wp-config.php"
if [ -f "$WP_CONFIG_FILE" ]; then
    add_fs_method_to_wp_config "$WP_CONFIG_FILE"
else
    echo "wp-config.php tidak ditemukan!"
fi

# Bersihkan direktori sementara
rm -rf "$TMP_DIR"

echo "Semua file dan folder yang relevan telah berhasil diproses dan disalin ke folder tujuan!"
