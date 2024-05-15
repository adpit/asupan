```markdown
# Instalasi Newspaper Theme dan Plugins di WordPress

Skrip ini digunakan untuk menginstal tema Newspaper dan plugin terkait ke dalam instalasi WordPress. Skrip akan membersihkan direktori target dari folder dan plugin yang tidak diperlukan, kemudian mengekstrak dan menyalin file yang relevan dari folder sumber.
kamu bisa beli di https://themeforest.net/item/newspaper/5489609 tidak ada affliasi dengan mereka dan tidak ada promosi memang bagus saja
## Persiapan

1. Pastikan Anda memiliki struktur direktori berikut:

```
Newspaper-tf/
├── Newspaper.zip
├── code/
│   └── Newspaper-child/
├── plugins/
│   ├── plugin1.zip
│   ├── plugin2.zip
│   └── ...
└── patch_12.6.5_12.6.6/
```

2. Buat direktori tujuan `wp1/wp-content` jika belum ada, wp1 adalah wordpress yang benar-benar baru

## Cara Penggunaan

1. Salin skrip berikut ke dalam file bernama `install_newspaper.sh` atau wget saja dari repo ini

2. Jalankan skrip dengan perintah berikut di terminal:

```sh
bash install_newspaper.sh
```

## Perhatian

- Skrip ini akan menghapus semua folder di `wp-content/themes` kecuali `twentytwentyfour` dan `Newspaper*`.
- Skrip ini juga akan menghapus plugin `hello` dari `wp-content/plugins`.
- Pastikan untuk memeriksa kembali struktur direktori Anda sebelum menjalankan skrip untuk menghindari penghapusan data yang tidak diinginkan.
```
