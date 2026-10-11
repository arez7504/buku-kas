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
- `iconKey`: String? (kunci ikon dari registry Material Icons, contoh: "makan", "kafe", "mobil")
- `colorKey`: String? (kunci warna dari palet 12 gradasi, contoh: "violet", "emerald", "cyan")

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

11. **Fitur Kunci Aplikasi (Keamanan Layar Kunci Perangkat):**
    - Sakelar "Kunci aplikasi" di layar Pengaturan (bagian Keamanan), tersimpan permanen via `shared_preferences`.
    - Wajib autentikasi perangkat (sidik jari/wajah, dengan cadangan PIN/pola/sandi) setiap kali dibuka dari kondisi tertutup (cold start), dan setiap kembali ke aplikasi setelah berada di latar belakang lebih dari 30 detik.
    - Kembali dari latar belakang di bawah/sampai 30 detik tidak mengunci aplikasi, menjaga alur kerja pengguna tetap lancar.
    - Mengaktifkan sakelar mewajibkan autentikasi berhasil terlebih dahulu. Mematikan sakelar juga mewajibkan autentikasi.
    - Jika perangkat tidak memiliki layar kunci (PIN, pola, sandi, atau biometrik), sakelar tidak dapat diaktifkan dan menampilkan pesan penolakan yang jelas.
    - Jika sakelar sudah aktif lalu layar kunci perangkat dihapus oleh pengguna di pengaturan OS, aplikasi tetap terbuka dan menampilkan satu banner pemberitahuan yang dapat ditutup, mencegah pengguna terkunci di luar datanya sendiri.
    - Saat berstatus terkunci, seluruh isi aplikasi disembunyikan menggunakan `LockScreen` polos dengan tombol "Buka" (isi aplikasi tidak terlihat baik di layar utama maupun di tampilan aplikasi terbaru / Recent Apps).
    - Arsitektur terisolasi: abstraksi `AppLockAuthService`, `AppLockStorage`, dan `AppLockManager` (`ChangeNotifier` & `WidgetsBindingObserver`) dipisahkan rapi dari UI untuk pengujian otomatis menggunakan fake/mock.

12. **Milestone UI-3 (Tema Gelap Baru + Redesain Layar Buku Kas):**
    - Tema gelap fintech modern (`#0b0b13` surface, `#181826` container, dsb.) menjadi satu-satunya tema aplikasi, menggantikan seluruh palet krem/terracotta.
    - Ekstraksi token terpusat ke `lib/theme/app_theme.dart` (`AppColors`, `AppGradients`, `AppDimens`, `AppTypography`) tanpa hardcoded nilai mentah di widget.
    - Font lokal `Plus Jakarta Sans` dibundel offline di `assets/fonts/` (bobot 400, 500, 600, 700, 800) berlisensi SIL Open Font License dan didaftarkan di `pubspec.yaml` tanpa package eksternal `google_fonts`.
    - Angka nominal diformat dengan tabular figures (`FontFeature.tabularFigures()`).
    - Latar peluncuran native Android diubah ke warna latar gelap `#0b0b13` (`colors.xml`, `launch_background.xml`, `styles.xml`) untuk mengeliminasi kedipan putih saat dibuka, tanpa menyentuh applicationId, namespace, atau penandatanganan.
    - Redesain Layar Buku Kas (`HistoryScreen` dan komponen terkait):
      - Header: Ikon dompet bulat bertint gradasi + judul tunggal "Buku Kas", ikon gerigi Pengaturan berdesain selaras, dan pemilih bulan pil panah kiri/kanan.
      - Kartu Hero: Label "PENGELUARAN BULAN INI", nominal besar dengan `FittedBox`, dua kartu kecil berdampingan (Pemasukan bertanda panah hijau dan Selisih dengan tanda minus & merah saat defisit), serta tautan "Lihat rincian pengeluaran" di baris bawah kartu.
      - Bagian Akun & Dompet: Menampilkan counter "X Akun Aktif", kartu dompet scrollable horizontal dengan nama 1 baris (`maxLines: 1`, `ellipsis`), dan tint kartu bergilir dari palet HTML via `lib/theme/wallet_card_style.dart`.
      - Transaksi Terkini: Menampilkan counter catatan bulanan, pengelompokan transaksi per hari dalam kartu modern dengan dot indicator warna neon, header tanggal, dan subtotal harian (pemasukan - pengeluaran; hari transfer saja tanpa subtotal).
      - Baris Transaksi: Kotak ikon bertint (`lib/theme/category_icon_mapping.dart`), judul berupa catatan (jika ada) atau nama kategori / "Transfer: A → B", baris kedua nama dompet (ditambah jam hanya bila bermakna), kanan nominal dan badge kategori huruf kapital kecil. Tap baris tetap membuka form edit.
      - Tombol Aksi: Tombol gradasi mengambang "Catat Transaksi" di bagian bawah menggantikan bilah navigasi bawah, dengan bottom padding pada daftar agar baris terakhir tidak tertutup.
      - Elemen yang sengaja tidak diterjemahkan (sesuai arahan karena tidak ada di SPEC): titik hijau di samping judul, kata "Pribadi", pil "Sep 2026" di kartu utama, teks "Alokasi gaji & dividen", bilah progres dan persen di kartu Selisih, keterangan tipe dompet ("Rekening Utama / Dompet Fisik / GoPay / OVO"), tautan "Lihat Semua", tab "Riwayat", dan dock bilah navigasi bawah.

13. **Milestone UI-4 (Layar Catat Transaksi Bertema Gelap):**
    - Redesain layar Catat Transaksi (`TransactionFormScreen`) dan sub-komponennya mengikuti acuan `design/catat.html` dan `design/catat.png`.
    - Memakai ulang seluruh token tema gelap dari UI-3 dan menambahkan token khusus Catat di `lib/theme/app_theme.dart` (`AppColors.catatSourceActive`, `catatKeypadKey`, `catatKeypadBg`, `catatDateChipBg`, `secondaryFixed`, `AppGradients.catatTabActive`, `catatAmountCard`, `catatCursor`, `catatCategoryActive`, `catatSubmitButton`, `AppShadows`).
    - **Header:** Panah kembali + judul "Catat Transaksi" (atau "Edit Transaksi" saat edit). Tanpa tombol menu opsi "...".
    - **Tab Tipe:** Pil 3 pilihan (Pengeluaran / Pemasukan / Transfer) dengan ikon panah bawah, panah atas, dan sync; tab aktif bergradasi neon ungu-biru dengan bayangan halus. Dilengkapi `FittedBox` agar teks tidak pernah overflow pada layar sempit.
    - **Kartu Nominal:** Gradasi vertikal `#181826` ke `#12121E`, label kapital "NOMINAL <TIPE>", nominal ekstra besar dengan tabular figures, kursor berkedip gradasi cyan-ungu (menjaga seluruh perilaku kedip kursor, key `catat_cursor_fade`, dan reset kedip saat input keypad), serta chip tanggal di bawahnya (tap membuka dialog pemilih tanggal).
    - **Kategori Cepat:** Khusus tipe Pemasukan dan Pengeluaran, chip horizontal dengan ikon Material hasil pemetaan `AppCategoryIcons`, nama kategori terpilih ditampilkan di sebelah kanan label.
    - **Sumber Dana:** Chip dompet dilengkapi dot indicator bulat 6px (warna cyan saat aktif). Pada mode Transfer, menampilkan baris "DARI (SUMBER)" dan "KE (TUJUAN)" dengan gaya chip titik yang seragam.
    - **Catatan:** SATU kolom teks bertepi tunggal (`Border.all(color: AppColors.borderFaint)`), mengoreksi cacat kotak bersarang berlapis pada mockup HTML.
    - **Keypad Angka:** 1-9, 000 (aksen cyan), 0, dan tombol hapus (backspace). Subteks huruf ABC/DEF/dst pada tombol angka telah DIHAPUS bersih sesuai arahan.
    - **Tombol Simpan:** Tombol CTA bergradasi penuh di bagian bawah dengan ikon `check_circle`, label dinamis mengikuti tipe transaksi, serta menghormati safe area bawah (gesture bar).
    - **Tata Letak Fleksibel & Responsif:** Menggunakan `SingleChildScrollView` + `ConstrainedBox` + `IntrinsicHeight` + `Spacer()` fleksibel antara kolom catatan dan keypad. Menjamin bebas overflow (0 RenderFlex errors) pada resolusi 360x640 dp maupun 411x891 dp.

14. **Milestone UI-5 (Layar Pengaturan & Kelola Dompet Bertema Gelap):**
    - Redesain layar Pengaturan (`SettingsScreen`) dan Kelola Dompet (`WalletManagementScreen`) mengacu pada `design/settings_screen/settings_screen.html` & `.png` serta `design/kelola dompet/kelola_dompet.html` & `.png`.
    - Menggunakan kembali token tema gelap UI-3 & UI-4 dan menambahkan token spesifik UI-5 di `lib/theme/app_theme.dart` (`AppColors.settingsCardBg`, `switchTrackActive`, `walletInitialBalance`, `walletCardBg`, `AppGradients.settingsWalletIcon`, `settingsCategoryIcon`, `settingsSecurityIcon`, `settingsBackupIcon`, `settingsRestoreIcon`, `walletBankIcon`, `walletCashIcon`, `walletEWalletIcon`, `walletGeneralIcon`, `AppShadows.settingsCard`, `settingsIconPurple`, `settingsIconCyan`, `settingsIconAmber`, `settingsIconTeal`, `settingsIconViolet`, `walletIconBank`, `walletIconCash`, `walletIconEWallet`, `walletIconGeneral`, `walletAddButton`, `walletCard`, `AppDimens.settingsIconBoxSize`, `settingsIconInner`, `walletIconBoxSize`, `walletIconInner`, `addButtonSize`, `AppTypography.settingsSectionHeader`, `settingsItemTitle`, `settingsItemSubtitle`, `walletCardTitle`, `walletBalanceLabel`, `walletBalanceValue`, `walletInitialBalance`).
    - **Pengaturan (`SettingsScreen`):**
      - Header: Judul tengah "Pengaturan" dan panah kembali.
      - Dikelompokkan rapi dalam tiga kartu berlatar gelap: "MASTER DATA" (Kelola Dompet, Kelola Kategori), "KEAMANAN" (Kunci aplikasi), dan "CADANGAN & PEMULIHAN" (Cadangkan data, Pulihkan data).
      - Ikon squircle bertint gradasi untuk setiap opsi menu.
      - Sakelar modern Kunci Aplikasi dengan `Key('switch_kunci_aplikasi')` terintegrasi autentikasi biometrik/PIN perangkat.
      - Cadangkan & Pulihkan data mempertahankan seluruh fungsi dialog konfirmasi, validasi berkas JSON, pratinjau ringkasan, dan penolakan berkas rusak/>20MB.
    - **Kelola Dompet (`WalletManagementScreen`):**
      - Header: Panah kembali, judul "Kelola Dompet", dan tombol tambah melingkar bertint dengan `Key('add_wallet_button')`.
      - Ikon dompet dipetakan secara cerdas dari nama dompet (kata kunci bank/tunai/e-wallet, fallback dompet umum) terpusat di `lib/theme/wallet_icon_mapping.dart` memanfaatkan palet `wallet_card_style.dart` tanpa mengubah skema database.
      - Kartu dompet menampilkan squircle ikon bertint gradasi, nama dompet (1 baris dengan ellipsis), Saldo sekarang (hasil kalkulasi real time), dan Saldo awal.
      - Nominal uang dan nilai saldo menggunakan angka tabular (`FontFeature.tabularFigures()`).
      - Teks "Saldo awal" dinaikkan terangnya menggunakan `AppColors.walletInitialBalance` agar memenuhi standar kontras WCAG AA (>= 4.5:1), dengan ukuran minimal 12 sp.
      - Bagian "DIARSIPKAN" di bawah mengelompokkan dompet yang diarsipkan dengan gaya redup, badge "Diarsipkan", serta opsi "Buka Arsip" untuk pemulihan.
      - Menu popup titik tiga `Key('wallet_menu_<id>')` menyediakan aksi Ubah, Arsipkan/Buka Arsip, dan Hapus (dengan validasi transaksi).
    - **Responsivitas & Bebas Overflow:** Teruji 100% bebas error RenderFlex overflow pada ukuran layar kecil 360x640 dp maupun 411x891 dp, termasuk nama dompet yang sangat panjang.

15. **Milestone UI-6 (Layar Kelola Kategori Bertema Gelap):**
    - Redesain layar Kelola Kategori (`CategoryManagementScreen`) mengacu pada `design/kelola_kategori_pengeluaran/*.html` & `.png` serta `design/kelola_kategori_pemasukan/*.html` & `.png` sebagai dua keadaan dari satu layar terpadu dengan tab Pengeluaran dan Pemasukan.
    - **Header:** Judul tengah "Kelola Kategori", tombol kembali panah, dan tombol tambah (+) melingkar bertint dengan `Key('add_category_button')` yang membuka dialog tambah kategori.
    - **Segmented Control Pill Tab:** Tab bar `CategorySegmentedTabs` berbentuk kapsul gelap halus yang menghubungkan tab "Pengeluaran" dan "Pemasukan", terintegrasi secara reaktif dengan `TabController` dan `TabBarView`.
    - **Kartu Kategori (`CategoryManagementCard`):**
      - Squircle ikon bertint dinamis yang dipetakan dari nama kategori (`AppCategoryIcons`), kategori kustom buatan pengguna memakai ikon netral umum (`Icons.label_outline`), tanpa kolom database baru.
      - Nama kategori satu baris dengan pemotongan ellipsis (`TextOverflow.ellipsis`).
      - Menu popup titik tiga `Key('category_menu_<id>')` dengan aksi Ubah Nama, Arsipkan/Buka Arsip, dan Hapus (bersyarat dengan validasi transaksi).
    - **Daftar Tetap Lazy:** Menggunakan `ListView.builder` yang sepenuhnya lazy, efisien dalam alokasi memori saat kategori bertambah banyak.
    - **Pengelompokan Arsip:** Kategori yang diarsipkan tampil terpisah di bagian "DIARSIPKAN" di bawah dengan gaya redup, badge "Diarsipkan", serta opsi pemulihan ("Buka Arsip").
    - **Dialog & SnackBar Bertema Gelap:** `CategoryAddDialog`, `CategoryEditDialog`, `CategoryCannotDeleteDialog`, dan `CategoryConfirmDeleteDialog` mengadopsi token tema gelap terpadu, menjaga seluruh key widget dan validasi nama kosong/kembar dalam kelompok tipe yang sama.

17. **Milestone UI-8 (Ikon dan Warna Dompet):**
    - Skema database dinaikkan ke versi 4 dengan penambahan dua kolom teks nullable (`icon_key` dan `color_key`) pada tabel `wallets`. Migrasi `onUpgrade` dari 3 ke 4 (serta rantai lengkap 1->4) berjalan otomatis via `m.addColumn`, menjaga data lama tetap utuh dengan kedua kolom baru bernilai NULL. Tabel `categories`, `transactions`, dan rumus saldo tidak diubah.
    - Registry terpusat `WalletStyleRegistry` di `lib/theme/wallet_style.dart` memuat tepat 3 ikon Material Icons (`'uang'` -> `Icons.payments`, `'dompet'` -> `Icons.account_balance_wallet`, `'bank'` -> `Icons.account_balance`) sebagai `const IconData` dalam map statis, serta memakai ulang palet 12 warna dari UI-7 (`CategoryStyleRegistry.colors`) tanpa duplikasi.
    - Satu fungsi resolusi tunggal `WalletStyleRegistry.resolveWalletStyle` diterapkan di seluruh aplikasi: kartu Kelola Dompet (`WalletManagementCard`), baris akun Buku Kas (`BukuKasWalletBar`), pemilih sumber dana Layar Catat (`CatatWalletSelector`), dan pratinjau live di form dompet. Aturan resolusi: jika `iconKey` dan/atau `colorKey` valid di registry, pakai pilihan pengguna; jika null atau tidak dikenal, fallback mulus ke pemetaan nama bawaan (`AppWalletIconMapping.getMapping`).
    - Layar penuh `WalletFormScreen` menggantikan `WalletFormDialog` untuk tombol (+) dan menu "Ubah" di Kelola Dompet. Menyediakan pratinjau live squircle 48x48 dp bertint gradasi + nama + saldo, input nama dompet dengan penghitung 0/30 dan batas 30 karakter, input saldo awal (angka), baris 3 pilihan ikon (touch target >= 48x48 dp), grid 12 bulatan warna bergradasi dengan centang putih, serta tombol Simpan di `bottomNavigationBar`. Menjaga kompatibilitas penuh key widget untuk testing (`wallet_name_input`, `wallet_name_edit_input`, `wallet_balance_input`, `wallet_balance_edit_input`, `wallet_save_button`, `wallet_update_button`, `wallet_icon_$key`, `wallet_color_$key`).
    - Cadangan data dinaikkan ke `formatVersion: 3` (menyertakan `iconKey` dan `colorKey` dompet). Fitur impor mendukung `formatVersion: 1`, `2` (kunci dompet diisi null), dan `3`. Kunci ikon atau warna dompet yang tidak dikenal otomatis disanitasi menjadi null (fallback aman tanpa menolak berkas).

18. **Milestone UI-9 (Pemilih Ikon Kategori Geser per Halaman):**
    - Menggantikan grid 41 ikon memanjang (9 baris) di `CategoryFormScreen` dengan pemilih berhalaman horizontal (`PageView.builder`) bawaan Flutter tanpa package eksternal baru.
    - Satu halaman menampilkan grid 3 baris x 4 kolom = 12 ikon (rata kiri, tile persegi `constraints.maxWidth - spacing * 3 / 4` dan tinggi konsisten tanpa melompat pada halaman terakhir yang berisi 5 ikon).
    - Jumlah halaman dihitung otomatis secara dinamis: `ceil(CategoryStyleRegistry.icons.length / 12)` = 4 halaman.
    - Penanda titik (`CategoryPageIndicatorDots`) di bawah area ikon menampilkan 4 titik yang berubah reaktif mengikuti geseran posisi (`page.round()`). Titik aktif berbentuk kapsul (lebar 18 dp) dan titik tidak aktif berbentuk lingkaran (lebar 6 dp) dengan kontras >= 3:1 terhadap latar `#141422`. Tanpa teks angka visual "1/4"; dilengkapi label TalkBack Semantics `Halaman X dari Y`. Deretan titik disembunyikan otomatis jika jumlah halaman <= 1.
    - Seleksi ikon bersifat global tunggal: pilihan tetap terpilih saat berpindah halaman dan kembali. Layar Ubah otomatis membuka langsung halaman tempat ikon kategori berada (mis. Halaman 3 atau 4). Mode Tambah otomatis menggeser pemilih ke halaman ikon hasil pemetaan nama (selama pengguna belum memilih manual).
    - Area sentuh minimal tile memenuhi standar aksesibilitas WCAG (>= 48x48 dp) dengan token terpusat `AppDimens.minTouchTarget`. Bebas RenderFlex overflow pada resolusi 360x640 dp dan 411x891 dp dengan skala font 1.0 dan 2.0.

19. **Milestone NAV-1 (Kerangka Navigasi Bilah Bawah):**
    - Root aplikasi menggunakan satu kerangka `MainNavigationScreen` dengan bilah navigasi bawah (`MainBottomNavBar`) berisi 4 tab: Beranda (`nav_beranda`), Riwayat (`nav_riwayat`), Statistik (`nav_statistik`), Pengaturan (`nav_pengaturan`), ditambah tombol Catat (`nav_catat`) yang menonjol di tengah dengan gradasi token `AppGradients.catatButton`.
    - Tab Beranda menggunakan `HistoryScreen` tanpa tombol aksi mengambang "Catat Transaksi" dan tanpa ikon gerigi Pengaturan di header (fungsinya diambil alih bilah navigasi bawah). Padding bawah daftar transaksi tetap dipertahankan (`AppDimens.bottomListPadding`) agar baris transaksi terakhir tidak tertutup bilah.
    - Tab Riwayat dan Statistik menggunakan `PlaceholderTabScreen` bertema gelap dengan ikon, judul, dan teks "Segera hadir".
    - Tab Pengaturan menggunakan `SettingsScreen` dengan parameter `showBackButton: false` sehingga panah kembali dihilangkan saat tampil sebagai tab. Sub-layar (Kelola Dompet, Kelola Kategori, dsb.) dibuka via push di atas kerangka layar penuh, otomatis menyembunyikan bilah navigasi bawah.
    - Tombol Catat di tengah membuka `TransactionFormScreen` layar penuh tanpa bilah navigasi; setelah selesai atau ditutup, kembali ke tab asal tanpa mengubah indeks tab aktif.
    - State setiap tab dipertahankan saat berpindah tab dan kembali (posisi gulir dan bulan terpilih di Beranda tidak hilang) menggunakan `IndexedStack` dan `PageStorageKey`.
    - Tombol back sistem Android ditangani via `PopScope`: dari tab Riwayat/Statistik/Pengaturan kembali ke Beranda (`currentIndex = 0`); dari Beranda mengizinkan penutupan aplikasi. Sub-layar yang dibuka lewat push ditutup terlebih dahulu sebelum back berpindah tab.
    - Layar kunci `AppLockWrapper` tetap membungkus seluruh kerangka navigasi, memastikan tidak ada konten maupun bilah navigasi yang bocor saat terkunci.
22. **Milestone NAV-2 (Beranda, Bagian Atas Baru - Saldo Total):**
    - Redesain bagian atas layar Beranda (`HistoryScreen`) menggantikan hero summary lama dengan urutan komponen terstruktur:
      1. Header (`BukuKasHeader`): Ikon dompet dan judul tunggal "Buku Kas" (pemilih bulan dipindah ke bawah).
      2. Kartu Hero "Saldo Total" (`BukuKasSaldoTotalCard`, `Key('saldo_total_card')`): Label "SALDO TOTAL", nominal besar satu baris dengan angka tabular dan `FittedBox` scaleDown (`Key('saldo_total_amount')`), keterangan kecil "Semua dompet aktif" (>= 12 sp, memenuhi standar kontras AA), saldo negatif tampil dengan tanda minus dan warna merah `AppColors.expenseRed`.
      3. Bagian Bulan (`BukuKasMonthSection`): Pemilih bulan berbentuk pill (`< Bulan Tahun >`), dua kartu berdampingan berukuran lebar sama (`Expanded` flex: 1) untuk Pemasukan (`Key('bulan_pemasukan')`) dan Pengeluaran (`Key('bulan_pengeluaran')`), baris tipis Selisih (`Key('bulan_selisih')`) dengan warna teal saat positif/nol dan merah minus saat negatif, serta tautan "Lihat rincian pengeluaran" (`Key('lihat_rincian_link')`).
      4. Bagian "Akun & Dompet" (`BukuKasWalletBar`): Deretan kartu dompet yang dapat digulir horizontal dipindahkan ke bawah bagian bulan, dengan header adaptif ber-`Flexible` bebas overflow.
      5. Daftar transaksi harian (`BukuKasDayGroup`): Tetap dipertahankan di bawah seksi dompet tanpa perubahan format.
    - **Perhitungan Total Balance (`FinanceCalculator.calculateTotalBalance` & `FinanceState.totalBalance`):**
      - Menjumlahkan seluruh saldo dompet aktif (`!wallet.isArchived`). Saldo masing-masing dompet mengikuti rumus standar (saldo awal + pemasukan - pengeluaran +/- transfer). Dompet terarsip tidak dihitung.
      - Transfer antar dua dompet aktif tidak mengubah total. Transfer dari dompet aktif ke dompet terarsip mengurangi total sebesar nominal transfer; transfer dari dompet terarsip ke dompet aktif menambah total.
      - Saldo negatif diperbolehkan dan dijumlahkan apa adanya. Total selalu dihitung secara dinamis dari data, otomatis mencerminkan perubahan saat dompet ditambah, saldo awal diubah, dompet diarsipkan, atau transaksi berubah.
      - Total bersifat independen terhadap navigasi pemilih bulan.
    - **Peringatan Arsip Dompet (`WalletArchiveWarningDialog`):**
      - Saat pengguna mengarsipkan dompet yang saldonya BUKAN nol dari layar Kelola Dompet (`WalletManagementScreen`), dialog konfirmasi muncul menyebutkan nama dompet, nominal saldonya, dan peringatan bahwa Saldo Total akan berkurang sebesar nominal tersebut. Tombol "Batal" membatalkan aksi, tombol "Arsipkan" (`Key('confirm_archive_wallet_button')`) memproses pengarsipan.
      - Dompet bersaldo nol langsung diarsipkan tanpa dialog tambahan.
      - Memulihkan dompet dari arsip ("Buka Arsip") dilakukan langsung tanpa dialog.
    - **Aksesibilitas & Responsivitas:**
      - Bebas error RenderFlex overflow pada resolusi 360x640 dp dan 411x891 dp, termasuk dengan skala teks 1.5/2.0 dan nominal ekstrem (contoh Rp 123.456.789.012).
      - Tanpa package eksternal baru, tanpa BackdropFilter/blur, dan seluruh styling menggunakan token tema terpusat di `lib/theme/app_theme.dart`.

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
- `local_auth: ^3.0.1` (autentikasi biometrik dan layar kunci perangkat Android/iOS)
- `shared_preferences: ^2.5.4` (penyimpanan preferensi sederhana status sakelar kunci aplikasi)
- `flutter_test` (Flutter SDK - dev dependency)
- `flutter_lints: ^5.0.0` (analisis linter - dev dependency)
- `drift_dev: ^2.31.0` (generator kode Drift - dev dependency)
- `build_runner: ^2.15.1` (runner generator Dart - dev dependency)

### D. Hasil `flutter test` Terakhir
- **Total Test:** 199
- **Lulus:** 199 (100%)
- **Gagal:** 0
- **Cakupan Pengujian:**
  - `milestone_nav2_test.dart` (14 test):
    - (a) `totalBalance` = jumlah saldo semua dompet aktif pada data uji (mengabaikan dompet terarsip dan menjumlahkan saldo negatif).
    - (b) Tambah dompet dengan saldo awal 100.000 menaikkan total 100.000; ubah saldo awal mengubah total; arsipkan dompet mengurangi total sebesar saldonya.
    - (c) Transfer antar dua dompet aktif tidak mengubah total; transfer ke dompet terarsip mengurangi total sebesar nominal; transfer dari dompet terarsip menambah total sebesar nominal.
    - (d) Pindah bulan: Pemasukan, Pengeluaran, dan Selisih berubah mengikuti bulan terpilih, sedangkan Saldo Total TIDAK berubah.
    - (e) Saldo Total di layar sama dengan jumlah angka yang tertera di kartu-kartu dompet aktif pada `BukuKasWalletBar`.
    - (f) Dialog arsip muncul untuk dompet bersaldo bukan nol memuat nama dompet, nominal saldo, dan efek terhadap Saldo Total; Batal membatalkan; dompet bersaldo nol langsung diarsipkan tanpa dialog; pemulihan ("Buka Arsip") langsung tanpa dialog.
    - (g) Saldo Total negatif tampil merah dengan tanda minus (`- Rp ...`).
    - Uji urutan tampilan visual: Header -> Saldo Total -> Bagian Bulan -> Akun & Dompet.
    - Uji tipografi: Label SALDO TOTAL, angka tabular, FittedBox scaleDown, subtitle >= 12 sp.
    - Uji responsivitas: Layar 360x640 dp dan 411x891 dp dengan nominal ekstrem (Rp 123.456.789.012) dan text scale 1.5/2.0 bebas overflow.
  - `milestone_nav1_test.dart` (8 test)
  - `milestone_ui9_test.dart` (10 test):
    - Uji total 41 ikon dan kalkulasi dinamis jumlah halaman = 4 (12 ikon/halaman, sisa 5 ikon di halaman 4).
    - Uji token dimensi indikator titik dan rasio kontras >= 3:1 terhadap latar kartu `#141422`.
    - Uji tampilan widget: 4 titik indikator hadir (kapsul aktif 18x6 dp vs lingkaran 6x6 dp), tanpa teks visual "1/4", serta label TalkBack Semantics `Halaman 1 dari 4`.
    - Uji geser halaman horizontal: titik aktif berpindah dinamis dan tinggi area PageView di Halaman 4 identik dengan Halaman 1 (tidak melompat).
    - Uji seleksi ikon bersifat global antar-halaman (pilih di halaman 2, geser ke halaman 1 dan kembali, ikon tetap terpilih; disimpan ke database dengan tepat).
    - Uji layar Ubah membuka langsung di halaman tempat ikon lama berada (Halaman 3 untuk 'rumah' dan Halaman 4 untuk 'gadget').
    - Uji mode Tambah: mengetik nama kategori yang memiliki pemetaan bawaan menggeser pemilih ke halaman terkait; setelah pengguna memilih manual, pengetikan nama tidak lagi memindahkan halaman.
    - Uji responsivitas bebas RenderFlex overflow pada resolusi 360x640 dp dan 411x891 dp dengan skala huruf 1.0 dan 2.0, serta touch target tile >= 48x48 dp.
    - Uji indikator titik otomatis disembunyikan (`SizedBox.shrink()`) jika hanya ada 1 halaman.
  - `milestone_ui8_test.dart` (11 test)
  - `milestone_ui7_test.dart` (9 test)
  - `milestone_ui6_test.dart` (11 test)
  - `milestone_ui5_test.dart` (10 test)
  - `milestone_ui4_test.dart` (10 test)
  - `milestone_ui3_test.dart` (10 test)
  - `app_lock_test.dart` (9 test)
  - `app_lock_widget_test.dart` (5 test)
  - `daily_grouping_test.dart` (15 test)
  - `expense_breakdown_test.dart` (6 test)
  - `expense_breakdown_widget_test.dart` (4 test)
  - `catat_cursor_test.dart` (4 test)
  - `backup_service_test.dart` (21 test)
  - `backup_restore_db_test.dart` (3 test)
  - `backup_restore_widget_test.dart` (7 test)
  - `migration_test.dart` (3 test: migrasi v1->v4, v2->v4, dan v3->v4)
  - `database_test.dart` (6 test)
  - `finance_calculator_test.dart` (3 test)
  - `finance_state_test.dart` (13 test)
  - `milestone_5_widget_test.dart` (5 test)
  - `widget_test.dart` (2 test)

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
11. **Penguncian Aplikasi & Timeout Latar Belakang:** Perhitungan timeout 30 detik diukur dari waktu aplikasi beralih ke status `paused`/`hidden` hingga `resumed`. Autentikasi biometrik menggunakan konfigurasi `biometricOnly: false` sehingga perangkat dapat menggunakan PIN, pola, atau sandi layar kunci sebagai cadangan resmi.
12. **Perlindungan Tampilan Aplikasi Terbaru:** Saat terkunci, hierarki widget aplikasi dibungkus oleh `AppLockWrapper` yang menampilkan `LockScreen` polos dengan tombol "Buka" sehingga pratinjau snapshot sistem OS Android pada tampilan Recent Apps tidak membocorkan informasi finansial apa pun.
13. **Penanganan Layar Kunci Dihapus:** Jika layar kunci perangkat dihapus setelah fitur aktif, sistem mendeteksi `isDeviceSupported() == false`, menjaga aplikasi tetap terbuka (`isLocked = false`) dan menampilkan banner peringatan di bagian atas layar agar pengguna tidak kehilangan akses terhadap datanya.
14. **Tema Gelap Tunggal (UI-3):** Seluruh antarmuka aplikasi menggunakan tema gelap modern dengan sistem token terpusat (`AppTheme`, `AppColors`, `AppTypography`, `AppDimens`, `AppGradients`). Komponen visual tidak memiliki hardcoded nilai warna mentah atau dimensi acak. Layar Catat Transaksi, Pengaturan, Kelola Dompet/Kategori, dan dialog mengadopsi token gelap yang seragam tanpa ada area putih/krem tersisa. Font offline `Plus Jakarta Sans` digunakan di seluruh aplikasi dengan fitur `FontFeature.tabularFigures()` pada teks nominal.
15. **Layar Catat Transaksi Fleksibel (UI-4):** Seluruh elemen form Catat Transaksi disusun secara adaptif menggunakan `SingleChildScrollView` dengan pembatas `IntrinsicHeight` dan `Spacer()` fleksibel antara input catatan dan keypad. Pada layar tinggi (411x891 dp), keypad dan tombol CTA tersemat di bawah (*pinned to bottom*) meniru perilaku `justify-between` pada mockup HTML. Pada layar rendah/sempit (360x640 dp), area form dapat digulir mulus tanpa memicu `RenderFlex overflow` sama sekali. Input catatan memakai satu border tunggal untuk menghilangkan cacat visual kotak bersarang pada desain awal, dan keypad dibersihkan dari label huruf sekunder (ABC/DEF) agar fokus penuh pada angka nominal.
16. **Layar Pengaturan & Kelola Dompet Bertema Gelap (UI-5):** Seluruh elemen visual layar Pengaturan dan Kelola Dompet mengadopsi tema gelap terpadu mengacu pada desain HTML/PNG. Kartu dompet menampilkan ikon squircle bertint yang dipetakan secara terpusat dari nama dompet (kata kunci bank/tunai/e-wallet/fallback), saldo sekarang (real time), dan saldo awal yang dinaikkan kontrasnya memenuhi standar WCAG AA (>= 4.5:1). Teks nominal menggunakan angka tabular (`FontFeature.tabularFigures()`). Nama dompet panjang diamankan satu baris dengan ellipsis. Dompet yang diarsipkan dikelompokkan terpisah di bagian "DIARSIPKAN" di bawah dengan badge dan opsi pemulihan ("Buka Arsip"). Semua dialog dan SnackBar konsisten mengikuti tema gelap dan 100% bebas overflow pada layar 360x640 dp dan 411x891 dp.
17. **Layar Kelola Kategori Bertema Gelap (UI-6):** Layar Kelola Kategori menyatukan dua keadaan mockup (Pengeluaran dan Pemasukan) dalam satu layar dengan tab `CategorySegmentedTabs`. Ikon kategori dipetakan secara dinamis dari nama kategori menggunakan `AppCategoryIcons` dengan tinting squircle, nama kategori panjang diamankan satu baris dengan ellipsis, dan daftar dirender secara lazy (`ListView.builder`). Kategori yang diarsipkan dikelompokkan di bagian "DIARSIPKAN" dengan gaya redup dan opsi "Buka Arsip". Seluruh dialog (tambah, ubah, tolak hapus, konfirmasi hapus) dan SnackBar mengikuti token tema gelap. Bebas overflow pada layar 360x640 dp dan 411x891 dp.
18. **Ikon dan Warna Kategori (UI-7):**
    - Skema database dinaikkan ke versi 3 dengan penambahan dua kolom teks nullable (`icon_key` dan `color_key`) pada tabel `categories`. Migrasi `onUpgrade` dari 2 ke 3 berjalan otomatis via `m.addColumn`, menjaga data lama tetap utuh dengan kedua kolom baru bernilai NULL. Tabel `wallets` dan `transactions` tidak diubah.
    - Registry terpusat `CategoryStyleRegistry` di `lib/theme/category_style.dart` memuat 41 ikon Material Icons sebagai `const IconData` dalam map statis untuk memastikan *icon tree shaking* Flutter berjalan bersih tanpa peringatan saat `flutter build apk --release`.
    - Palet 12 warna gradasi (`violet`, `cyan`, `emerald`, `amber`, `rose`, `blue`, `orange`, `pink`, `indigo`, `teal`, `lime`, `slate`) didefinisikan dengan pasangan gradasi untuk pemilih dan tinting (latar belakang, bingkai, ikon) di `AppColors`.
    - Satu fungsi resolusi tunggal `CategoryStyleRegistry.resolveCategoryStyle` diterapkan di seluruh aplikasi: daftar Kelola Kategori (`CategoryManagementCard`), baris transaksi di Buku Kas (`BukuKasTransactionRow`), pemilih kategori di Layar Catat (`CatatCategorySelector`), dan baris laporan Rincian Pengeluaran (`ExpenseCategoryRow`). Aturan resolusi: jika `iconKey`/`colorKey` terisi dan valid, gunakan kunci tersebut; jika kosong atau tidak dikenal, gunakan pemetaan nama bawaan (`category_icon_mapping.dart`).
    - Layar penuh `CategoryFormScreen` menggantikan dialog lama untuk tambah dan ubah kategori. Komponen disusun dari atas: pratinjau kecil dinamis (squircle ikon + warna + nama yang diketik), pemilih tipe Pengeluaran/Pemasukan (dengan `FittedBox` mencegah teks terpotong; hanya saat tambah, saat ubah tampil teks read-only), input nama dengan penghitung 0/30 dan batas 30 karakter, grid 5 kolom ikon dengan pembatas sentuh >=48 dp, grid 12 bulatan gradasi warna dengan tanda centang, dan tombol Simpan di `bottomNavigationBar` yang otomatis menyesuaikan saat keyboard terbuka.
    - Cadangan data dinaikkan ke `formatVersion: 2` (menyertakan `iconKey` dan `colorKey` kategori). Fitur impor mendukung `formatVersion: 1` (kunci diisi null) dan `formatVersion: 2`. Kunci ikon atau warna yang tidak dikenal otomatis disanitasi menjadi null (fallback aman tanpa menolak berkas).
19. **Ikon dan Warna Dompet (UI-8):**
    - Skema database tabel `wallets` diperluas dengan kolom nullable `icon_key` dan `color_key` (`schemaVersion = 4`). Seluruh rumus saldo kumulatif dan tabel lainnya tetap terjaga tanpa perubahan.
    - 3 ikon dompet (`Icons.payments`, `Icons.account_balance_wallet`, `Icons.account_balance`) didefinisikan sebagai `const IconData` statis untuk memastikan *icon tree shaking* Flutter berjalan bersih dengan pengurangan ukuran aset font 99,3% saat build release.
    - Palet 12 warna diimpor langsung dari UI-7 (`CategoryStyleRegistry.colors`) tanpa redundansi deklarasi warna.
    - Form dompet `WalletFormScreen` berjalan layar penuh dengan pratinjau live, penghitung 0/30, touch target >= 48x48 dp, validasi nama kosong, batas 30 karakter, dan pencegahan nama kembar (case-insensitive, trimmed) dengan izin nama yang sama pada mode ubah.
    - Cadangan formatVersion 3 mendukung ekspor dan impor dompet ber-ikon dan ber-warna, dengan backward compatibility penuh untuk berkas formatVersion 1 dan 2.
20. **Pemilih Ikon Kategori Paged UI-9:**
    - Pemilih ikon kategori horizontal paged dengan 12 ikon per halaman (3 baris x 4 kolom), kalkulasi otomatis `ceil(41 / 12) = 4` halaman, slot kosong halaman terakhir tetap menjaga tinggi area PageView identik sehingga bebas lonjakan layout saat digeser.
    - Penanda titik reaktif dengan kapsul aktif (18x6 dp) dan lingkaran tidak aktif (6x6 dp) memenuhi kontras >= 3:1 terhadap latar, TalkBack Semantics `Halaman X dari Y`, disembunyikan otomatis bila <= 1 halaman.
    - Seleksi ikon bersifat global tunggal (tidak ter-reset saat digeser), pembukaan form Ubah langsung memposisikan pemilih ke halaman ikon terkait, dan form Tambah mendukung auto-scroll saat mengetik nama dengan pemetaan bawaan selama belum dipilih manual.
    - Bebas overflow pada layar 360x640 dp dan 411x891 dp serta skala font 1.0 hingga 2.0, touch target >= 48x48 dp via token `AppDimens.minTouchTarget`.

21. **Kerangka Navigasi Bilah Bawah (NAV-1):**
    - Root aplikasi dibungkus oleh `MainNavigationScreen` yang menyajikan kerangka tunggal dengan `MainBottomNavBar` (Beranda, Riwayat, Catat, Statistik, Pengaturan). Tombol tengah Catat menonjol dengan gradasi neon `AppGradients.catatButton` dan border melingkar, dengan ukuran compact (44 dp) pada bilah 64 dp sehingga tidak memotong atau menutupi label teks tab sekitarnya pada layar sempit 360 dp.
    - Tab state persistence dicapai dengan `IndexedStack` dan `PageStorageKey` pada scroll view Beranda, menjaga posisi scroll dan bulan terpilih saat beralih antar-tab.
    - Navigasi back Android memakai `PopScope`: ketika berada di tab 1, 2, atau 3 (Riwayat, Statistik, Pengaturan), tombol back sistem beralih kembali ke tab Beranda (indeks 0). Dari Beranda, penekanan back keluar dari aplikasi. Sub-layar yang di-push (seperti Kelola Dompet/Kategori, form transaksi) berada di atas Navigator root sehingga back menutup sub-layar terlebih dahulu sebelum PopScope tab dipicu.
    - Form Catat Transaksi dibuka layar penuh di atas kerangka via `Navigator.push`, menyembunyikan bilah navigasi bawah secara alami dan mengembalikannya saat form ditutup tanpa mereset tab asal.
    - Seluruh kerangka navigasi tetap berada di dalam `AppLockWrapper`, sehingga saat status terkunci aktif, `LockScreen` menutupi seluruh layar termasuk bilah bawah tanpa kebocoran data visual.

22. **Saldo Total & Bagian Atas Beranda Baru (NAV-2):**
    - Saldo Total dihitung secara independen dari bulan terpilih sebagai akumulasi saldo riil semua dompet aktif (`!wallet.isArchived`). Transfer antar dompet aktif bersifat netral (0 dampak pada total). Transfer antara dompet aktif dan terarsip mengubah Saldo Total sesuai arah aliran dana.
    - Perpindahan bulan di pemilih bulan memperbarui data transaksi bulanan (Pemasukan, Pengeluaran, Selisih, rincian kategori, dan daftar per hari) tanpa mengubah nominal kartu Saldo Total.
    - Dialog konfirmasi arsip dompet melindungi pengguna dari ketidaksengajaan saat mengarsipkan dompet yang memiliki saldo riil bukan nol, mencegah kebingungan pengguna atas penurunan nilai Saldo Total.
    - Penataan ulang urutan komponen di Beranda (Header -> Saldo Total -> Bagian Bulan -> Akun & Dompet -> Daftar Transaksi) memberikan hierarki visual yang jelas dari ringkasan global kekayaan (Saldo Total), performa periode berjalan (Bulan), persebaran akun (Dompet), hingga catatan granular (Transaksi Harian).

