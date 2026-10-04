# Rencana Pengerjaan Tugas: Praktikum DevOps Minggu ke-1 (JS-DVO-01)

## Konteks
Tugas berasal dari Job Sheet Praktikum DevOps Polibatam, Pertemuan 1: "Introduction to
DevOps: Filosofi, Budaya, & SDLC". Ini adalah tugas praktikum yang menghasilkan sekumpulan
artefak (skrip, aplikasi contoh, dokumen) beserta laporan tertulis, bukan sebuah aplikasi web.

Identitas yang dipakai pada penamaan berkas & laporan:
- Nama: Cikal Pratama
- NIM: 4332511053
- Berkas laporan akhir: `M01_4332511053_Cikal Pratama.pdf`

## Yang Akan Dihasilkan

### 1. Artefak Kode & Proyek (JOB 1–5)
Sebuah folder proyek lengkap yang siap di-push ke GitHub, berisi:
- `00-environment-check.log` — contoh log verifikasi lingkungan (OS, versi git/python/pip/curl, konfigurasi identitas Git) sesuai JOB 1.
- `app-sentra/src/app.py` — aplikasi Flask sederhana (JOB 2).
- `app-sentra/requirements.txt` — dependency ter-pin (`flask==3.0.3`).
- `app-sentra/HANDOVER.md` — dokumen serah-terima (versi sengaja tidak lengkap sesuai skenario JOB 2, dengan catatan penjelas).
- `app-sentra/setup.sh` — skrip otomasi deployment (JOB 4): buat venv, install dependency, jalankan app, health check.
- `.gitignore` — mengecualikan venv, cache, file `.env`, dsb.
- `POSTMORTEM.md` — laporan blameless postmortem mengikuti template (Summary, Timeline, Impact, Root Cause, Action Items, Lessons Learned), tanpa menyebut nama individu (JOB 5).

### 2. Bonus Challenge — "Zero-Touch Verification"
- `setup.sh` versi robust: mode `--check` (validasi prasyarat saja), deteksi konflik port + pencarian port otomatis, mekanisme retry health check (maks 5x, jeda 2 detik).
- `teardown.sh` — mematikan aplikasi & membersihkan dengan aman, disertai validasi path.
- Kedua skrip ditulis agar bersih dari peringatan `shellcheck`.

### 3. Tabel Pengukuran & Metrik
- Tabel Value Stream Map (JOB 3): Pelaku, Process Time, Wait Time, %C/A, plus perhitungan Flow Efficiency.
- Tabel perbandingan metrik Sebelum vs Sesudah Otomasi (JOB 4): Lead Time, jumlah langkah manual, jumlah kegagalan.
- Angka pada tabel diisi dengan nilai simulasi yang realistis dan konsisten (karena praktikum fisik berpasangan tidak dijalankan); diberi catatan bahwa nilai bersifat ilustratif dan dapat disesuaikan dengan hasil aktual.

### 4. Jawaban 5 Soal Analisis (Bagian 4.1)
Jawaban argumentatif untuk kelima pertanyaan (akar masalah sistemik, evaluasi klaim otomasi vs CALMS/DORA, kuantifikasi dampak 20 deployment/bulan, pemilihan model SDLC untuk perangkat medis embedded, trade-off kecepatan vs stabilitas), didukung oleh data dari tabel di atas.

### 5. Laporan Akhir (PDF)
Satu dokumen laporan `M01_4332511053_Cikal Pratama.pdf` yang merangkum seluruh JOB 1–5,
tabel metrik, jawaban analisis, dan lampiran (isi skrip, POSTMORTEM). Disusun mengikuti
struktur/rubrik pada job sheet.

### 6. Instruksi Git & GitHub
Panduan langkah demi langkah (init, add, commit dengan pesan sesuai contoh, buat repo private,
add remote, push, tambah kolaborator dosen "Antoni Haikal") agar tinggal dijalankan pada akun
GitHub milik pengguna. Pembuatan repo & undang kolaborator tetap dilakukan sendiri oleh pengguna.

## Asumsi
- Nilai pada tabel metrik dan log lingkungan bersifat simulasi/ilustratif yang realistis, karena
  praktikum fisik berpasangan (Dev/Ops) dan pengukuran waktu nyata tidak dijalankan di sini.
  Semua diberi penanda agar mudah disesuaikan dengan hasil aktual pengguna.
- Tautan repo GitHub dan screenshot output `shellcheck` yang wajib dilampirkan akan diisi oleh
  pengguna setelah menjalankan langkah git; tempat lampiran disediakan pada laporan.
- Bahasa seluruh dokumen: Indonesia (mengikuti bahasa job sheet).

## Di Luar Cakupan
- Menjalankan praktikum fisik berpasangan secara nyata dan mengukur waktu sebenarnya.
- Membuat/meng-hosting repo GitHub atas nama pengguna atau mengundang kolaborator (dilakukan
  sendiri oleh pengguna dengan instruksi yang disediakan).
- Membuat GitHub Project board (JOB 5) secara nyata — akan dijelaskan cara membuatnya beserta
  isi kartu yang harus dimasukkan, karena board dibuat langsung di akun GitHub pengguna.
