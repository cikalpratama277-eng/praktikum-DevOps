# Praktikum DevOps — Minggu ke-1 (JS-DVO-01)

**Introduction to DevOps: Filosofi, Budaya, & SDLC**
PT Sentra Digital Batam (studi kasus fiktif) · Politeknik Negeri Batam

| Identitas | Nilai |
|-----------|-------|
| Nama      | Cikal Pratama |
| NIM       | 4332511053 |
| Mata Kuliah | DevOps (RKS305) — 3 SKS |
| Dosen     | Antoni Haikal |
| Berkas laporan | `M01_4332511053_Cikal Pratama.pdf` |

## Struktur Repository

```
praktikum-devops-m01/
├── 00-environment-check.log        # Bukti verifikasi lingkungan (JOB 1)
├── .gitignore                      # Mengecualikan .venv, cache, .env, *.log
├── POSTMORTEM.md                   # Blameless postmortem (JOB 5)
├── README.md                       # Berkas ini
└── app-sentra/
    ├── src/app.py                  # Aplikasi Flask (JOB 2)
    ├── requirements.txt            # Dependensi terkunci: flask==3.0.3
    ├── HANDOVER.md                 # Dokumen serah-terima manual (JOB 2)
    ├── setup.sh                    # Otomasi deployment + Zero-Touch (JOB 4 + Challenge)
    └── teardown.sh                 # Pembersihan aman (Challenge)
```

## Cara Menjalankan (The First Way — satu perintah)

```bash
cd app-sentra
chmod +x setup.sh teardown.sh      # 755, BUKAN 777

./setup.sh --check                 # Validasi prasyarat saja (exit 0=siap, 1=tidak)
./setup.sh                         # Setup venv + install + jalankan + smoke test
./teardown.sh                      # Hentikan aplikasi (pertahankan .venv)
./teardown.sh --purge              # Hentikan + hapus .venv secara aman
```

Aplikasi menyimak di `http://127.0.0.1:5000/` dan `/health`. Jika port 5000
terpakai, `setup.sh` otomatis mencari port bebas berikutnya.

## Bonus Challenge — "Zero-Touch Verification"

`setup.sh` & `teardown.sh` memenuhi kelima ketentuan:
mode `--check`, deteksi + pencarian port bebas, retry health check (maks 5x @2s),
`teardown.sh` dengan validasi path sebelum penghapusan, dan bersih dari peringatan
`shellcheck`. Commit terpisah: `feat(challenge): zero-touch verification`.

Verifikasi analisis statis:

```bash
sudo apt install -y shellcheck
shellcheck setup.sh teardown.sh    # harus tidak ada peringatan
```

---

## Panduan Git & GitHub (dijalankan pada akun GitHub Anda sendiri)

> Repo **private**, dosen ditambahkan sebagai collaborator. Ganti `<username>`
> dengan username GitHub Anda.

### 1) Inisialisasi & commit utama

```bash
cd praktikum-devops-m01
git init
git branch -M main
git add .
git status                          # PASTIKAN .venv & berkas rahasia TIDAK terdaftar
git commit -m "feat: otomasi deployment menggantikan prosedur manual (Minggu 1)"
```

### 2) Buat repository PRIVATE di GitHub

- Buka <https://github.com/new>
- Repository name: `praktikum-devops-m01`
- Visibility: **Private**
- **Jangan** centang "Add a README" (repo lokal sudah punya).

### 3) Hubungkan remote & push

```bash
git remote add origin https://github.com/<username>/praktikum-devops-m01.git
git push -u origin main
```

> Jika diminta password saat push, gunakan **Personal Access Token (PAT)**
> dengan hak akses minimum & masa berlaku terbatas — bukan password akun.
> Jangan menyimpan token pada berkas apa pun di dalam repo.

### 4) Commit terpisah untuk Challenge (opsional, +10 poin)

Jika ingin memisahkan Challenge sebagai commit tersendiri, buat `setup.sh`
versi dasar lebih dulu, commit, lalu tambahkan fitur robust:

```bash
git add app-sentra/setup.sh app-sentra/teardown.sh
git commit -m "feat(challenge): zero-touch verification"
git push
```

Lampirkan tangkapan layar keluaran `shellcheck` yang bersih pada laporan.

### 5) Tambahkan dosen sebagai collaborator

- Repo → **Settings** → **Collaborators** → **Add people**
- Undang dosen: **Antoni Haikal** — email `antoni@polibatam.ac.id`
- (dan pasangan praktikum Anda, bila ada).

---

## GitHub Projects (JOB 5) — cara membuat & isi kartu

Repo → tab **Projects** → **New project** → template **Board**. Buat **dua** board:

**Board "Waterfall"** — kolom: `Requirement → Design → Implementation → Testing → Deployment`
Aturan: sebuah kartu hanya boleh pindah bila **seluruh** kartu pada kolom sebelumnya selesai.

**Board "DevOps Flow"** — kolom: `Backlog → In Progress (WIP limit 2) → Review → Deployed → Monitored`

Masukkan **lima aktivitas JOB 1–4** ini sebagai kartu ke **kedua** board:

1. Verifikasi kesiapan lingkungan kerja (JOB 1)
2. Membangun aplikasi & dokumen serah-terima manual (JOB 2 — Dev)
3. Simulasi deployment manual oleh Ops & pencatatan kegagalan (JOB 2 — Ops)
4. Value Stream Mapping & perhitungan Flow Efficiency (JOB 3)
5. Otomasi deployment dengan `setup.sh` + smoke test (JOB 4)

Jalankan simulasi pemindahan kartu sesuai aturan masing-masing board, lalu amati
board mana yang lebih cepat memindahkan satu kartu dari ujung ke ujung.

---

> **Catatan.** Nilai pada `00-environment-check.log`, tabel Value Stream Map, dan
> tabel perbandingan metrik bersifat **ilustratif/simulasi yang realistis**
> karena praktikum fisik berpasangan tidak dijalankan di sini. Semua mudah
> disesuaikan dengan hasil pengukuran aktual Anda.
