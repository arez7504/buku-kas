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

7. **Milestone 5 (Kelola Dompet dan Kategori):**
   - Layar Pengaturan diakses via ikon gerigi pada header Buku Kas, menyediakan dua menu: Kelola Dompet dan Kelola Kategori.
   - Layar Kelola Dompet: Menampilkan seluruh dompet beserta saldo sekarang, tambah dompet baru (nama & saldo awal), ubah nama dan saldo awal (otomatis menghitung ulang semua saldo), dan pengarsipan.
   - Layar Kelola Kategori: Menampilkan kategori yang dikelompokkan berdasarkan tipe (Pengeluaran / Pemasukan), tambah kategori (nama & tipe), ubah nama, dan pengarsipan.
   - Penghapusan bersyarat: Hapus permanen hanya diizinkan untuk dompet/kategori yang belum memiliki transaksi. Jika sudah pernah dipakai, sistem menampilkan dialog peringatan dan menawarkan opsi pengarsipan.
   - Penyaringan arsip: Dompet dan kategori yang diarsipkan otomatis disembunyikan dari pilihan pada form Catat Transaksi, namun riwayat transaksi lama tetap menampilkan nama dompet dan kategori terkait secara normal.
   - Validasi input: Nama dompet dan kategori tidak boleh kosong dan tidak boleh kembar (case-insensitive) dalam kelompok yang sama.
   - Migrasi SQLite: Kolom `isArchived` (boolean, default false) ditambahkan pada tabel `Wallets` dan `Categories`. Versi skema dinaikkan ke `schemaVersion = 2` dengan strategi `onUpgrade` otomatis yang melindungi dan mempertahankan seluruh data lama (diverifikasi dengan automated migration test).

8. **Milestone 6 (Backup dan Restore Data):**
   - Fitur "Cadangkan data" di layar Pengaturan: Mengekspor seluruh data dompet, kategori, dan transaksi (termasuk status arsip) ke dalam format JSON dengan nama berkas `catatan_keuangan_YYYY-MM-DD.json`. Membuka menu Bagikan Android via `share_plus` agar dapat dikirim ke Google Drive, WhatsApp, atau disimpan ke penyimpanan perangkat.
   - Fitur "Pulihkan data" di layar Pengaturan: Memilih berkas JSON via `file_picker`, memvalidasi struktur dan konten, menampilkan dialog pratinjau ringkasan (jumlah dompet, kategori, transaksi, dan rentang tanggal), meminta konfirmasi eksplisit, lalu mengganti seluruh data aplikasi dengan isi berkas.
   - Operasi Database Atomik: Seluruh proses pemulihan berjalan dalam satu transaksi database tunggal (`_db.transaction`). Jika terjadi kegagalan, seluruh perubahan di-rollback sehingga data lama tidak berubah sama sekali dan tidak menyisakan data setengah jadi.
   - Validasi Ketat & Format Versioning:
     - Berkas memuat `formatVersion` (mulai dari 1) dan `exportedAt`. Berkas dengan `formatVersion` asing/tidak dikenal ditolak secara aman.
     - Validasi integritas: format JSON valid, field wajib lengkap, nominal integer positif, relasi `walletId` dan `categoryId` merujuk ke data dalam berkas yang sama (transfer memiliki `targetWalletId` valid dan `categoryId` bernilai null), serta tipe transaksi valid.
     - Berkas yang tidak lolos validasi ditolak dengan pesan dialog yang jelas tanpa menyentuh database.
   - Logika Terisolasi: Logika serialisasi dan validasi dipisahkan secara murni di `lib/logic/backup_service.dart` tanpa ketergantungan pada UI maupun SQLite.

9. **Tahap 2 - Fitur 1 (Rincian Pengeluaran per Kategori):**
   - Layar baru "Rincian Pengeluaran" yang dibuka melalui tautan kecil "Lihat rincian" di bawah angka "Pengeluaran bulan ini" pada Buku Kas.
   - Header editorial dengan navigasi bulan yang tersinkronisasi dua arah dengan bulan yang dipilih di Buku Kas (menggeser bulan di rincian ikut menggeser bulan di Buku Kas).
   - Hero total pengeluaran bulanan sebagai angka besar yang sama persis dengan total pengeluaran bulanan di Buku Kas.
   - Distribusi kategori: menampilkan setiap kategori pengeluaran yang memiliki transaksi pada bulan itu, diurutkan dari nominal terbesar ke terkecil.
   - Setiap baris menampilkan nama kategori, nominal rupiah, persentase dari total (satu angka di belakang koma, contoh: 58,5%), dan batang horizontal proporsional dengan satu warna aksen terracotta (`AppColors.secondary`).
   - Batang horizontal sebanding dengan nominal (kategori terbesar memiliki batang terpanjang, dibatasi dalam margin layout dan bukan 100% layar).
   - Kategori yang diarsipkan tetap dihitung dan ditampilkan dengan namanya jika memiliki transaksi pengeluaran.
   - Transaksi transfer dan pemasukan dikecualikan secara ketat dari rincian pengeluaran.
   - Penanganan bulan tanpa transaksi pengeluaran dengan pesan kondisi kosong yang jelas dan informatif.
   - Logika kalkulasi terisolasi secara murni pada `FinanceCalculator.calculateExpenseBreakdown`.
   - UI mematuhi tokenisasi terpusat `AppTheme` tanpa nilai warna/dimensi mentah langsung di widget.

#10. **Revisi Layar Buku Kas (Konsistensi Ringkasan & Pemisah per Hari):**
   - **Kartu Ringkasan (Pemasukan / Pengeluaran / Selisih):**
     - Tiga kolom dengan lebar identik (`Expanded(flex: 1)`).
     - Pemisah vertikal tipis penuh di antara ketiga kolom dengan tinggi penuh kartu (`IntrinsicHeight`, `crossAxisAlignment: CrossAxisAlignment.stretch`), berwarna sama dengan garis tepi kartu (`AppColors.outlineVariant`).
     - Padding horizontal yang seragam (`AppDimens.spaceMd`) pada semua kolom.
     - Susunan kolom identik: label di atas (`AppTypography.summaryColumnLabel`), nominal di bawah dengan ukuran font sama (15 sp, w700).
     - Nominal dibungkus `FittedBox(fit: BoxFit.scaleDown)` satu baris (`maxLines: 1`), tidak membungkus ke baris kedua atau menempel ke kolom tetangga.
     - Tautan rincian dipindahkan dari kolom Pengeluaran ke baris tersendiri di bawah ketiga kolom, dipisahkan garis tipis horizontal, rata kanan, dengan teks "Lihat rincian pengeluaran" dan ikon panah.
     - Selisih negatif: tampil dengan tanda minus (`- Rp ...`) dan warna merah (`AppColors.expenseRed`). Selisih nol atau positif tetap menggunakan warna teal (`AppColors.selisihTeal`).
   - **Daftar Transaksi Dikelompokkan per Hari:**
     - Fungsi murni `FinanceCalculator.groupTransactionsByDay` mengelompokkan transaksi bulan terpilih per tanggal (tahun-bulan-hari, waktu lokal perangkat), urut hari terbaru di atas, dan di dalam satu hari urut transaksi terbaru di atas.
     - Judul tiap kelompok: kiri tanggal ("HARI INI, 8 OKT 2026", "KEMARIN, 7 OKT 2026", atau lainnya contoh "6 OKT 2026" dalam singkatan bulan kapital baku), kanan subtotal harian.
     - Subtotal harian = total pemasukan dikurangi total pengeluaran hari itu (transfer diabaikan secara ketat). Hari yang hanya berisi transfer tidak menampilkan subtotal (bukan "Rp 0"). Subtotal positif bertanda `+ Rp ...` (hijau), subtotal negatif bertanda `- Rp ...` (merah).
     - Judul kelompok berlatar kontras lembut (`AppColors.surfaceContainerLow`), lebar penuh, dan tinggi ringkas.
     - Baris transaksi di dalam kelompok tidak lagi menampilkan tanggal (sudah terwakili pada judul), berformat flat tanpa kartu individual, dipisahkan garis tipis antar baris, dan tap tetap membuka form edit transaksi.
     - Invarian matematika: jumlah seluruh subtotal harian dalam satu bulan sama persis dengan nilai Selisih bulanan di kartu ringkasan.

### B. Hal yang Belum Dikerjakan
1. **Sinkronisasi Cloud & Enkripsi Cadangan:**
   - Sinkronisasi otomatis ke cloud dan enkripsi berkas cadangan (Tahap 2).

### C. Daftar Package (`pubspec.yaml`)
- `flutter` (Flutter SDK)
- `cupertino_icons: ^1.0.8` (font ikon iOS bawaan template)
- `drift: ^2.31.0` (abstraksi database SQLite type-safe)
- `drift_flutter: ^0.2.8` (konektivitas SQLite dan path resolver Flutter Android/iOS)
- `share_plus: ^12.0.2` (membuka menu bagikan native Android/iOS untuk berkas cadangan tanpa izin penyimpanan khusus)
- `file_picker: ^11.0.3` (memilih berkas JSON cadangan via Android Storage Access Framework tanpa izin penyimpanan khusus)
- `flutter_test` (Flutter SDK - dev dependency)
- `flutter_lints: ^5.0.0` (analisis linter - dev dependency)
- `drift_dev: ^2.31.0` (generator kode Drift - dev dependency)
- `build_runner: ^2.15.1` (runner generator Dart - dev dependency)

### D. Hasil `flutter test` Terakhir
- **Total Test:** 90
- **Lulus:** 90 (100%)
- **Gagal:** 0
- **Cakupan Pengujian:**
  - `daily_grouping_test.dart` (15 test):
    - (a) Pengelompokan harian: transaksi di dua hari berbeda menghasilkan dua kelompok urut terbaru di atas, urutan transaksi intraday terbaru di atas, kalkulasi subtotal harian (pemasukan - pengeluaran), pengecualian transfer dari subtotal harian, peniadaan subtotal untuk hari berisi transfer saja (`subtotal == null`), pelabelan "HARI INI, 8 OKT 2026", "KEMARIN, 7 OKT 2026", dan singkatan kapital baku bulan lainnya ("6 OKT 2026", "17 AGU 2026").
    - (b) Invarian matematika: verifikasi kesamaan jumlah seluruh subtotal harian satu bulan dengan Selisih bulanan di kartu ringkasan (`sum(dailySubtotals) == netCashFlow`), baik dalam kondisi selisih positif maupun negatif.
    - (c) Widget test: kartu ringkasan 3 kolom sama lebar (`Expanded flex: 1`), `FittedBox(scaleDown)`, pemisah vertikal penuh, selisih negatif merah dengan tanda minus (`- Rp ...`), selisih positif teal (`Rp ...`), tautan "Lihat rincian pengeluaran" di baris tersendiri rata kanan, baris transaksi tanpa tanggal dan tap membuka form edit `TransactionFormScreen`, serta penampilan subtotal harian hijau (+), merah (-), dan tidak ada subtotal untuk hari berisi transfer saja.
  - `expense_breakdown_test.dart` (6 test): Urutan kategori dari terbesar, kalkulasi persen 1 desimal (kasus 58,5 / 24,4 / 17,1 dan total 205.000), pengecualian transfer dan pemasukan, retensi kategori terarsip, penanganan bulan kosong, integritas kesamaan total dengan ringkasan bulanan Buku Kas, dan akumulasi beberapa transaksi dalam satu kategori.
  - `expense_breakdown_widget_test.dart` (4 test): Keberadaan tautan "Lihat rincian" di Buku Kas dan alur navigasi ke layar Rincian Pengeluaran, visualisasi baris per kategori terurut dengan nominal, persen, dan batang proporsional, pesan kondisi kosong yang jelas saat bulan tanpa pengeluaran, dan sinkronisasi perpindahan bulan dua arah ke Buku Kas.
  - `catat_cursor_test.dart` (4 test): Perilaku kursor kedip ~530 ms per fase dengan transisi halus opacity, reset instan ke opacity 1.0 dan mulai ulang siklus saat keypad ditekan, penghormatan pengaturan Android "kurangi animasi" (`disableAnimations`), dan pembersihan animasi (`dispose`) saat layar ditutup.
  - `backup_service_test.dart` (21 test): Penamaan berkas YYYY-MM-DD, round-trip serialisasi objek utuh, kalkulasi ringkasan termasuk `exportedAt` & `exportedAtText`, serta pengujian penolakan menyeluruh (JSON rusak, root non-objek, missing fields, formatVersion asing/non-integer, tanggal ekspor rusak, saldo non-integer, ID duplikat, tipe kategori salah, nominal pecahan/string, nominal <= 0, foreign key wallet/category tidak terdaftar di berkas, transfer ke dompet yang sama / target tidak ada, file .json sembarang yang isinya bukan backup, dan penolakan file > 20 MB).
  - `backup_restore_db_test.dart` (3 test):
    - (a) Round-trip ekspor dari database berdata lalu impor ke database kosong menghasilkan seluruh saldo dompet dan ringkasan bulanan yang sama persis.
    - (b) Penolakan berkas cacat di level state & DB tidak mengubah data lama pada semua kasus (JSON rusak, versi asing, walletId tidak ada, nominal bukan integer).
    - (c) Atomisitas transaksi: kegagalan di tengah proses pemulihan (simulasi foreign key failure) di-rollback utuh tanpa menyisakan data setengah jadi.
  - `backup_restore_widget_test.dart` (7 test): Tampilan menu di Pengaturan, integrasi bagikan berkas `catatan_keuangan_YYYY-MM-DD.json` dengan `fileNameOverrides`, penolakan berkas rusak via dialog, alur pratinjau ringkasan dengan tanggal ekspor dari file, pemulihan backup valid dengan nama sembarang (.bin / acak) via `FileType.any`, penolakan file .json sembarang non-backup, dan penolakan berkas di atas 20 MB sebelum dibaca.
  - `migration_test.dart` (1 test): Migrasi skema SQLite v1 ke v2, penambahan kolom `isArchived`, retensi data lama, dan integritas pembaruan.
  - `database_test.dart` (6 test): Seed awal 3 dompet saldo 0, operasi CRUD transaksi & foreign key, integrasi persistence & hitung ulang saldo, serta CRUD dompet & kategori di level repository.
  - `finance_calculator_test.dart` (3 test): Rumus saldo dompet, transfer antar-dompet, ringkasan bulanan, dan filter bulan.
  - `finance_state_test.dart` (13 test): Operasi transaksi, memori dompet terakhir, hitung ulang saldo saat ubah saldo awal, validasi nama kembar/kosong, pencegahan hapus dompet/kategori berelasi transaksi, dan isolasi dompet/kategori arsip.
  - `milestone_5_widget_test.dart` (5 test): Alur UI lengkap dari header Buku Kas ke Pengaturan, ubah saldo awal BCA dan dampaknya di Buku Kas, validasi form dompet, pencegahan hapus permanen & tawaran arsip, serta penyembunyian item arsip di form Catat Transaksi.
  - `widget_test.dart` (2 test): Smoke test layar utama Buku Kas dan pembukaan layar form Catat Transaksi via tombol Catat.

### E. Asumsi & Bug yang Diketahui
1. **Penyimpanan Permanen Aktif:** Data tersimpan lokal di SQLite perangkat Android (`catatan_keuangan.sqlite`). Data dummy hanya dipakai pada pengujian in-memory.
2. **Nominal Bulat:** Seluruh nominal uang disimpan dalam integer (`int`) untuk menghindari floating-point rounding error.
3. **Penyimpanan & Berbagi Tanpa Izin Khusus:** Ekspor dan impor memanfaatkan mekanisme standar OS (Android Share Sheet via `share_plus` dan Storage Access Framework via `file_picker`), sehingga tidak memerlukan izin berbahaya (`WRITE_EXTERNAL_STORAGE` / `READ_EXTERNAL_STORAGE`).
4. **Parameter Nama Berkas Ekspor:** Pengaturan nama berkas `catatan_keuangan_YYYY-MM-DD.json` menggunakan parameter `fileNameOverrides` pada `ShareParams` (`share_plus` 12.0.2) sehingga berkas cache yang dibagikan ke Android dan aplikasi pihak ketiga (seperti WhatsApp) memiliki nama dan MIME `application/json` yang tepat, bukan nama UUID acak atau ekstensi `.bin`.
5. **Pemulihan Fleksibel & Batasan Ukuran:** Pemilih berkas menggunakan `FileType.any` tanpa pembatasan ekstensi kaku, dengan validasi berbasis isi data JSON dan batasan ukuran maksimal 20 MB untuk keamanan memori.
6. **Isolasi Status Arsip:** Status arsip (`isArchived`) ikut dicadangkan dan dipulihkan sepenuhnya, menjaga konsistensi filter dompet dan kategori di seluruh aplikasi.
7. **Transaksional Database:** Seluruh operasi restore dibungkus dalam blok `_db.transaction(...)`, menjamin sifat ACID (Atomicity, Consistency, Isolation, Durability) saat pemulihan data.
8. **Animasi Kursor Kedip & Kompatibilitas Widget Test:** Kursor nominal berkedip setiap ~530 ms per fase dengan transisi halus `FadeTransition`. Siklus langsung di-reset dan kursor tampil penuh (opacity 1.0) setiap kali tombol keypad ditekan. Animasi dihentikan dan di-dispose saat layar ditutup, serta otomatis diam dan statis (opacity 1.0) saat pengaturan Android "kurangi animasi" (`disableAnimations`) aktif. Di lingkungan widget test otomatis, blinking dicegah agar `tester.pumpAndSettle()` pada suite pengujian umum tidak menggantung, sementara unit/widget test khusus kursor dapat menguji animasi secara terisolasi.
9. **Skala Batang Rincian Pengeluaran:** Batang horizontal per kategori dinormalisasi terhadap nominal kategori pengeluaran terbesar pada bulan terpilih (`amount / maxAmount`), dengan lebar track dibatasi oleh margin standar aplikasi (`AppDimens.margin`) sehingga tidak meluap atau memenuhi 100% lebar layar.
10. **Subtotal Harian & Pengecualian Transfer:** Subtotal harian pada judul kelompok semata-mata menghitung arus kas bersih (pemasukan - pengeluaran). Transaksi bertipe transfer tidak menambah maupun mengurangi subtotal harian dan tidak ditampilkan jika dalam satu hari hanya terdapat transaksi transfer. Jumlah seluruh subtotal harian satu bulan secara matematis selalu sama dengan nilai Selisih pada kartu ringkasan bulanan.
