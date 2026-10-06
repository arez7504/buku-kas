# Spesifikasi Aplikasi Catatan Keuangan Pribadi (MVP)

Dokumen ini berisi spesifikasi kebutuhan minimal (Minimum Viable Product / MVP) untuk aplikasi pencatatan keuangan pribadi berbasis Flutter (Android).

---

## 1. Fitur MVP

1. **Kelola Dompet (Wallets)**
   - Menyimpan beberapa sumber dana (contoh: Tunai, Rekening Bank, E-Wallet).
   - Menampilkan saldo terkini untuk tiap dompet.

2. **Kelola Kategori (Categories)**
   - Mengelompokkan transaksi pengeluaran dan pemasukan (contoh: Makanan, Transportasi, Gaji).

3. **Catat Transaksi (Transactions)**
   - Mendukung 3 tipe transaksi:
     - **Pemasukan (Income):** Menambah saldo ke satu dompet tertentu, terhubung ke kategori pemasukan.
     - **Pengeluaran (Expense):** Mengurangi saldo dari satu dompet tertentu, terhubung ke kategori pengeluaran.
     - **Transfer:** Memindahkan saldo dari satu dompet asal ke dompet tujuan (tanpa kategori pengeluaran/pemasukan).

4. **Riwayat Bulanan**
   - Menampilkan daftar transaksi yang difilter per bulan & tahun berjalan.
   - Navigasi antar bulan (pindah ke bulan sebelumnya atau berikutnya).

5. **Ringkasan Bulanan**
   - Menampilkan total pemasukan bulan berjalan.
   - Menampilkan total pengeluaran bulan berjalan.
   - Menampilkan selisih/arus kas bersih (Pemasukan dikurangi Pengeluaran).

---

## 2. Model Data

### Aturan Utama
- **Nominal uang disimpan sebagai Integer (`int`)**:
  - Untuk mata uang Rupiah, tidak ada pecahan desimal dalam transaksi sehari-hari.
  - Penggunaan tipe `int` mencegah kesalahan pembulatan desimal (*floating-point precision error*) yang sering terjadi pada tipe `double`.

### Struktur Entitas

#### A. Dompet (`Wallet`)
- `id`: String (identifikasi unik tiap dompet)
- `name`: String (nama dompet, contoh: "Tunai", "BCA")
- `initialBalance`: int (saldo awal saat dompet pertama kali dibuat)

#### B. Kategori (`Category`)
- `id`: String (identifikasi unik)
- `name`: String (nama kategori, contoh: "Makan", "Gaji")
- `type`: String / Enum (`income` atau `expense`)

#### C. Transaksi (`Transaction`)
- `id`: String (identifikasi unik)
- `type`: String / Enum (`income`, `expense`, `transfer`)
- `amount`: int (nominal uang, selalu bernilai positif)
- `date`: DateTime (tanggal & waktu transaksi)
- `walletId`: String (dompet yang terlibat / dompet sumber jika transfer)
- `targetWalletId`: String? (opsional, hanya terisi jika tipe `transfer`)
- `categoryId`: String? (opsional, terisi jika tipe `income` atau `expense`)
- `note`: String? (catatan singkat opsional)

---

## 3. Alur Layar (Screen Flow)

1. **Layar Utama (Dashboard / Beranda)**
   - Ringkasan bulanan (Total Pemasukan, Total Pengeluaran, Selisih).
   - Kartu saldo dompet (ringkasan saldo dari semua dompet).
   - Daftar riwayat transaksi pada bulan terpilih (diurutkan dari yang terbaru).
   - Tombol Tambah Transaksi (*Floating Action Button*).
   - Tombol Navigasi ke Kelola Dompet & Kelola Kategori.

2. **Layar Tambah / Edit Transaksi**
   - Pilihan jenis transaksi: Pemasukan, Pengeluaran, atau Transfer.
   - Input nominal transaksi.
   - Input tanggal transaksi.
   - Input kondisional:
     - Jika Pemasukan/Pengeluaran: pilih Dompet dan Kategori.
     - Jika Transfer: pilih Dompet Asal dan Dompet Tujuan.
   - Input catatan (opsional).
   - Tombol Simpan Transaksi.

3. **Layar Kelola Dompet**
   - Daftar dompet yang tersimpan beserta saldonya.
   - Tombol/dialog untuk menambah dompet baru (nama dompet & saldo awal).

4. **Layar Kelola Kategori**
   - Daftar kategori yang dikelompokkan berdasarkan tipe (Pemasukan / Pengeluaran).
   - Tombol/dialog untuk menambah kategori baru (nama kategori & tipe).

---

## 4. Aturan Perhitungan

1. **Rumus Saldo Dompet:**
   - `Saldo Dompet = Saldo Awal + Total Pemasukan - Total Pengeluaran - Total Transfer Keluar + Total Transfer Masuk`.
   - Efek transaksi `transfer`: Mengurangi saldo dompet asal dan menambah saldo dompet tujuan sebesar nominal yang sama.

2. **Ringkasan Bulanan:**
   - Transaksi `transfer` **tidak dihitung** ke dalam total pemasukan maupun pengeluaran bulanan (karena hanya pergeseran dana internal).

3. **Penghapusan Transaksi:**
   - Transaksi dapat dihapus, dan saldo dompet serta ringkasan bulanan akan dihitung ulang secara otomatis.

4. **Batasan MVP:**
   - Rincian pengeluaran per kategori ditunda ke Tahap 2.

---

## 5. Status Proyek

### A. Milestone yang Sudah Selesai
1. **Milestone 1 (Tampilan Awal):**
   - Struktur dasar proyek Flutter.
   - Model `Transaction` awal dan komponen tampilan daftar transaksi dengan data statis.

2. **Milestone 2 (Logika & Navigasi Bulan):**
   - Model `Wallet` dan `Category` sesuai spesifikasi.
   - Logika murni perhitungan saldo dompet kumulatif dan ringkasan bulanan (`FinanceCalculator`).
   - Pengecualian transaksi `transfer` dari total pemasukan/pengeluaran bulanan.
   - Navigasi bulan sebelumnya/berikutnya dengan penyaringan transaksi dinamis.

3. **Milestone 3 (Form Transaksi & State Management):**
   - State management terpusat in-memory menggunakan `FinanceState` (`ChangeNotifier`) dan `FinanceScope` (`InheritedNotifier`).
   - Layar form CRUD (tambah, edit, dan dialog konfirmasi hapus transaksi).
   - Validasi: nominal > 0, transfer tidak boleh dompet asal = tujuan, kategori wajib untuk pemasukan/pengeluaran.
   - Fitur mengingat dompet terakhir yang dipilih selama aplikasi berjalan.

4. **Milestone UI-1 (Desain Layar Catat Transaksi):**
   - Penerjemahan visual `design/catat.html` & `design/catat.png`.
   - Sentralisasi token warna, ukuran, dan tipografi di `lib/theme/app_theme.dart`.
   - Font lokal `Newsreader` dan `Hanken Grotesk` dibundel di `assets/fonts/`.
   - Keypad angka custom (1-9, 000, 0, backspace) menggantikan keyboard sistem.
   - Tab Pengeluaran | Pemasukan | Transfer dan chip tanggal "Hari ini".

5. **Milestone UI-2 (Desain Layar Buku Kas / Riwayat):**
   - Penerjemahan visual `design/buku_kas.html` & `design/buku_kas.png`.
   - Header editorial dengan navigasi bulan tanpa AppBar salmon.
   - Hero ringkasan pengeluaran angka besar, sub-ringkasan dua kolom (Pemasukan & Selisih).
   - Baris saldo semua dompet (BCA, Tunai, E-Wallet) tanpa teks terpotong.
   - Pengelompokan transaksi per hari dengan subtotal harian (transfer tidak dihitung).
   - Tombol aksi Catat berwarna terracotta menggantikan FAB biasa.

6. **Milestone 4 (Database Lokal Drift/SQLite):**
   - Tiga tabel `Wallets`, `Categories`, dan `Transactions` di SQLite via Drift (`schemaVersion = 1`).
   - Foreign key aktif (`walletId`, `targetWalletId`, `categoryId`) dengan `PRAGMA foreign_keys = ON`.
   - Seed awal saat database pertama dibuat: 3 dompet (BCA, Tunai, E-Wallet) saldo 0, kategori pengeluaran & pemasukan lengkap, tanpa transaksi.
   - Akses data terisolasi rapi di `lib/data/finance_repository.dart` tanpa query langsung di layar.
   - Pembacaan data asinkron via `FinanceState.loadData()` dengan penanganan state `isLoading`.
   - Unit test database in-memory mencakup seluruh operasi CRUD, integritas foreign key, persistence, dan penghitungan ulang saldo.

### B. Hal yang Belum Dikerjakan
1. **Layar Kelola Dompet Mandiri (Bagian 3.3):**
   - Daftar dompet dan dialog penambahan dompet baru (nama & saldo awal).
2. **Layar Kelola Kategori Mandiri (Bagian 3.4):**
   - Daftar kategori dan dialog penambahan kategori baru (nama & tipe).
3. **Rincian Pengeluaran per Kategori:**
   - Visualisasi atau laporan distribusi pengeluaran per kategori (Tahap 2).

### C. Daftar Package (`pubspec.yaml`)
- `flutter` (Flutter SDK)
- `cupertino_icons: ^1.0.8` (font ikon iOS bawaan template)
- `drift: ^2.31.0` (abstraksi database SQLite type-safe)
- `drift_flutter: ^0.2.8` (konektivitas SQLite dan path resolver Flutter Android/iOS)
- `flutter_test` (Flutter SDK - dev dependency)
- `flutter_lints: ^5.0.0` (analisis linter - dev dependency)
- `drift_dev: ^2.31.0` (generator kode Drift - dev dependency)
- `build_runner: ^2.15.1` (runner generator Dart - dev dependency)

### D. Hasil `flutter test` Terakhir
- **Total Test:** 15
- **Lulus:** 15 (100%)
- **Gagal:** 0
- **Cakupan Pengujian:**
  - `database_test.dart` (4 test): Seed awal 3 dompet saldo 0 tanpa transaksi, operasi CRUD transaksi, integrasi persistence & hitung ulang saldo, dan foreign key constraints.
  - `finance_calculator_test.dart` (3 test): Rumus saldo dompet, transfer antar-dompet, ringkasan bulanan, dan filter bulan.
  - `finance_state_test.dart` (6 test): Tambah pengeluaran, transfer, edit nominal, hapus transaksi, validasi input, dan memori dompet terakhir.
  - `widget_test.dart` (2 test): Smoke test layar utama Buku Kas dan pembukaan layar form Catat Transaksi via tombol Catat.

### E. Asumsi & Bug yang Diketahui
1. **Penyimpanan Permanen Aktif:** Data tersimpan lokal di SQLite perangkat Android (`catatan_keuangan.sqlite`). Data dummy hanya dipakai pada pengujian in-memory.
2. **Nominal Bulat:** Keypad custom sengaja tidak menyediakan koma/desimal karena mata uang Rupiah disepakati disimpan dalam integer (`int`).
3. **Judul Transaksi:** Transaksi tanpa catatan otomatis menampilkan nama kategori sebagai judul baris riwayat.
