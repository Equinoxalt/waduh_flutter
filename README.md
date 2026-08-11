# Waduh — Aplikasi Pencatatan Stok

Aplikasi Flutter untuk mencatat & merekap stok barang terjual — tempel banyak baris `Nama : Jumlah` sekaligus, otomatis dijumlahkan per nama.

## Latar Belakang

Waduh awalnya aplikasi Android native (Kotlin) yang sangat sederhana: dua field input dan satu tombol jumlah, dengan hasil yang cuma hidup di memori — tertutup aplikasinya, semua data hilang. Proyek ini adalah migrasi penuh dari versi itu ke Flutter, sekaligus kesempatan membangun ulang dari nol dengan arsitektur yang benar: UI modern (Material 3), backend REST API sendiri (Node.js/Express + MySQL), dan kemampuan yang sebelumnya sama sekali tidak ada — autentikasi, penyimpanan permanen, riwayat, dan multi-akun.

## Fitur

- **Autentikasi** — login & signup dengan JWT, sesi tetap tersimpan lintas restart aplikasi
- **Isolasi data per akun** — setiap pengguna hanya melihat datanya sendiri
- **Hitung cepat** — tempel banyak baris sekaligus, otomatis dijumlahkan; baris berformat salah ditandai jelas, bukan dilewati diam-diam
- **Sesi & riwayat** — total sesi yang sedang berjalan terpisah dari total harian; riwayat dikelompokkan per tanggal, bisa dihapus per tanggal atau seluruhnya
- **Edit & hapus per baris** — telusuri hingga baris individual di balik satu angka total
- **Kalkulator pendapatan** — set harga satuan per barang, otomatis dikalikan kuantitas dari cakupan waktu manapun
- **Bagikan hasil** — ekspor rekap ke WhatsApp/aplikasi lain lewat share sheet native
- **Tema & mode gelap** — warna brand kustom, preferensi tersimpan

## Arsitektur

Mengikuti pemisahan Model – View – Controller/Service:
```
lib/
├── models/ # bentuk data (Item, ItemTotal, ItemRow, dst)
├── views/ # halaman & widget UI
├── controllers/ # state management (Provider) & logika alur
├── services/ # komunikasi HTTP ke backend
├── config/ # tema & konfigurasi environment
└── utils/ # helper (format tanggal, format Rupiah, dll)
```
State management pakai **Provider**, komunikasi ke API pakai **Dio** dengan interceptor yang otomatis menyisipkan token JWT ke setiap request, token disimpan di **flutter_secure_storage** (bukan `SharedPreferences` biasa — datanya sensitif).

## Tech Stack

Flutter, Dart, Provider, Dio, flutter_secure_storage, share_plus, Material 3.

Backend terpisah: Node.js/Express + MySQL — [lihat repo backend](https://github.com/Equinoxalt/waduh-backend).

## Setup

1. `flutter pub get`
2. Salin `lib/config/env.example.dart` menjadi `lib/config/env.dart`, isi `baseUrl` sesuai alamat backend (`http://10.0.2.2:3001` untuk emulator Android, atau IP LAN untuk HP fisik).
3. Pastikan backend sudah berjalan.
4. `flutter run`

## Dari Kotlin ke Flutter — apa yang berubah

| Versi lama (Kotlin, native) | Versi ini (Flutter) |
|---|---|
| Tidak ada penyimpanan — data hilang saat app ditutup | MySQL, data permanen |
| Satu pengguna implisit, tidak ada akun | Autentikasi JWT, multi-akun dengan data terisolasi |
| Baris format salah dilewati diam-diam | Ditandai jelas ke pengguna |
| Tab "Kalkulator" kosong (placeholder) | Kalkulator pendapatan fungsional |
| UI standar Android bawaan | Material 3, tema brand kustom, dark mode |
| Tidak ada riwayat | Riwayat per tanggal, bisa dibagikan & diedit |