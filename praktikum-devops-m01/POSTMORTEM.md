# Blameless Postmortem

## Ringkasan Insiden

**Insiden Kegagalan Deployment Manual.** Serah-terima aplikasi *sentra-digital-batam*
dari peran Development ke peran Operations gagal dijalankan pada percobaan pertama.
Aplikasi yang "berjalan normal di mesin Developer" tidak dapat dijalankan di
lingkungan Operations karena artefak dan instruksi serah-terima tidak lengkap.
Insiden ini merupakan manifestasi langsung dari *Wall of Confusion* dan sindrom
*"it works on my machine"*.

## Kronologi (timeline)

Waktu bersifat relatif terhadap saat Operations menerima artefak (T+0). Nilai
ilustratif, dapat disesuaikan dengan hasil aktual.

| Waktu   | Peristiwa                                                                                   |
|---------|---------------------------------------------------------------------------------------------|
| T+0     | Operations menerima folder `serah-terima/` (berisi `src/` dan `HANDOVER.md`) tanpa `requirements.txt`. |
| T+1'    | Operations menjalankan `python3 src/app.py` → `ModuleNotFoundError: No module named 'flask'`. |
| T+3'    | Operations mencoba `pip install flask` di sistem global → `error: externally-managed-environment`. |
| T+6'    | Operations tidak mengetahui versi/pin dependensi karena `requirements.txt` tidak disertakan. |
| T+9'    | Operations menebak perlunya *virtual environment*, membuat `.venv`, mengaktifkannya.        |
| T+11'   | Operations memasang `flask` tanpa versi terkunci (berpotensi beda versi dengan Developer).  |
| T+13'   | Aplikasi mencoba dijalankan; sempat terjadi keraguan port/URL karena tidak tertera di HANDOVER. |
| T+14'   | Aplikasi akhirnya merespons `curl http://127.0.0.1:5000/`. Insiden dinyatakan pulih (workaround manual). |

## Dampak (waktu terbuang, jumlah kegagalan)

- **Lead Time manual:** ± 14 menit untuk deployment yang idealnya < 1 menit.
- **Jumlah kegagalan (failed attempts):** 3 (module not found, externally-managed-environment, ketidakpastian versi/port).
- **Pertanyaan yang seharusnya diajukan ke Dev namun terhalang aturan:** ± 4.
- **Waktu bernilai tambah** hanya sebagian kecil dari total; sisanya adalah
  *wait time* dan *rework* (lihat Value Stream Map, JOB 3).
- **Risiko kualitas:** versi Flask yang terpasang di Ops berpotensi berbeda dari
  Dev sehingga hasil "berhasil" pun belum tentu setara dengan lingkungan Dev.

## Akar Masalah pada SISTEM (bukan pada orang)

Akar masalah **bukan** kelalaian individu Developer dalam menulis dokumen,
melainkan **cacat pada desain sistem kerja**:

1. **Tidak ada kontrak artefak yang dapat dieksekusi mesin.** Sistem
   mengandalkan dokumen prosa (`HANDOVER.md`) sebagai satu-satunya sumber
   kebenaran. Prosa bersifat ambigu, tidak dapat diverifikasi otomatis, dan
   rawan kehilangan konteks (versi Python, venv, pin dependensi, port).
2. **Paritas lingkungan (Dev/Prod parity) tidak dijamin oleh sistem.**
   Tidak ada mekanisme yang memaksa lingkungan Ops setara dengan Dev; perbedaan
   versi paket/OS dibiarkan implisit.
3. **Kanal komunikasi searah dan lambat.** Serah-terima berbentuk "lempar ke
   seberang tembok" tanpa umpan balik cepat, sehingga kegagalan baru ketahuan di
   hilir (The Second Way tidak terpenuhi).

Karena akarnya sistemik, mengganti personel Developer **tidak** akan mencegah
insiden serupa — orang baru akan tetap terperangkap oleh desain sistem yang sama.

## Tindakan Perbaikan (action items) + penanggung jawab peran

| # | Tindakan Perbaikan                                                                                  | Penanggung Jawab (peran) | Prioritas |
|---|-----------------------------------------------------------------------------------------------------|--------------------------|-----------|
| 1 | Ganti dokumen manual dengan **skrip otomasi `setup.sh`** yang dapat dieksekusi & idempotent (The First Way / Flow). | Dev + Ops (bersama)      | Tinggi    |
| 2 | **Pin seluruh dependensi** pada `requirements.txt` (`flask==3.0.3`) dan sertakan sebagai artefak wajib. | Dev                      | Tinggi    |
| 3 | Tambahkan **health check otomatis** (`/health`) + smoke test pada skrip agar kegagalan terdeteksi < 1 menit (The Second Way / Feedback). | Ops                      | Tinggi    |
| 4 | Tegakkan **`.gitignore` sebelum commit** untuk mencegah `.venv`/kredensial masuk repo (praktik keamanan). | Dev + Ops                | Sedang    |
| 5 | Standarkan **versi Python minimum (≥ 3.10)** dan validasi otomatis di awal skrip. | Ops                      | Sedang    |
| 6 | Simpan artefak & dokumen di **repository bersama** sebagai sumber kebenaran tunggal (Sharing). | Dev + Ops                | Sedang    |

## Pelajaran yang Diambil

- **Otomasi adalah dokumentasi yang tidak bisa bohong.** Skrip yang berjalan
  menghilangkan ambiguitas prosa dan memaksa langkah tersembunyi menjadi eksplisit.
- **Perkecil batch & percepat umpan balik.** Deteksi dini via health check jauh
  lebih murah daripada menelusuri kegagalan di hilir.
- **Perbaiki sistem, bukan salahkan orang.** Budaya *blameless* membuat tim
  berani mengungkap kegagalan sehingga perbaikan sistemik benar-benar terjadi.
- **Paritas lingkungan itu wajib.** Menyamakan lingkungan Dev–Ops (venv + pin
  versi) mencegah kelas galat "it works on my machine".
