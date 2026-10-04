# Praktikum DevOps — Minggu ke-2 (JS-DVO-02)

**Linux Foundation for DevOps: Shell Scripting, CLI, & Manajemen Sistem**
Lanjutan Minggu 1 · PT Sentra Digital Batam (studi kasus) · Politeknik Negeri Batam

| Identitas | Nilai |
|-----------|-------|
| Nama      | Cikal Pratama |
| NIM       | 4332511053 |
| Mata Kuliah | DevOps (RKS305) — 3 SKS |
| Dosen     | Antoni Haikal |
| Berkas laporan | `M02_4332511053_Cikal Pratama.pdf` |

## Struktur

```
praktikum-devops-m02/
├── .gitignore
├── README.md
├── minggu-02/
│   ├── buat-log.sh            # Generator log sintetis (JOB 2)
│   ├── app.log                # Contoh log hasil generate (500 baris)
│   ├── ringkasan-log.txt      # Hasil analisis pipeline (JOB 2)
│   ├── sysreport.sh           # Skrip Bash modular (JOB 4)
│   ├── healthwatch.sh         # CHALLENGE "Health Watcher"
│   ├── job1-izin.log          # Bukti output JOB 1
│   └── job3-proses.log        # Bukti output JOB 3
└── app-sentra/                # Refaktor proyek Minggu 1 (JOB 5)
    ├── src/app.py
    ├── requirements.txt
    ├── setup.sh               # Versi MODULAR (source lib/common.sh + logging)
    └── lib/common.sh          # Pustaka fungsi bersama
```

## Menjalankan artefak

```bash
# JOB 2 — generate & analisis log
cd minggu-02
chmod +x *.sh
./buat-log.sh app.log
awk '{print $9}' app.log | sort | uniq -c | sort -rn      # sebaran status

# JOB 4 — sysreport (lihat exit code tiap skenario)
./sysreport.sh ; echo $?        # 0 sehat
./sysreport.sh -j               # JSON
./sysreport.sh -d 1 ; echo $?   # 2 lewat ambang
./sysreport.sh -d abc ; echo $? # 1 validasi gagal

# JOB 5 — setup.sh modular (logging bertimestamp ke /tmp/sentra-deploy.log)
cd ../app-sentra && chmod +x setup.sh lib/common.sh
shellcheck setup.sh lib/common.sh
./setup.sh

# CHALLENGE — Health Watcher (Ctrl+C untuk ringkasan sesi + MTTR)
cd ../minggu-02
./healthwatch.sh --interval 5 --url http://127.0.0.1:5000/health
```

Analisis statis (wajib bersih):
```bash
shellcheck buat-log.sh sysreport.sh healthwatch.sh ../app-sentra/setup.sh ../app-sentra/lib/common.sh
```

## Git — simpan ke repo Minggu 1 (lanjutan)

Artefak Minggu 2 diunggah ke repository yang **sama** (`praktikum-devops-m01`).

```bash
# salin skrip minggu-02 ke proyek app-sentra (sesuai job sheet JOB 5 langkah 4)
cp minggu-02/sysreport.sh minggu-02/buat-log.sh app-sentra/
cd app-sentra
printf 'app.log\nringkasan-log.txt\n' >> .gitignore

git add .
git status                      # WAJIB: pastikan app.log & kredensial TIDAK ikut
git commit -m "refactor: pisahkan fungsi bersama ke lib/common.sh dan tambahkan logging"
git push

# Commit terpisah untuk Challenge (+10):
git add minggu-02/healthwatch.sh
git commit -m "feat(challenge): health watcher dengan MTTR dan ringkasan sesi"
git push
```

> **Keamanan (K3):** jalankan `ls` sebelum `rm`; jangan `chmod/chown -R` pada
> direktori sistem; gunakan `kill -TERM` sebelum `kill -9`; jangan `chmod 777`;
> jangan commit kredensial/log produksi; `sudo` hanya untuk instalasi paket.

---

> **Catatan.** Seluruh keluaran pada laporan diambil dari eksekusi nyata skrip ini.
> Nilai spesifik (sebaran status, CFR, pemakaian disk/memori, dsb.) bergantung
> pada data sintetis acak & mesin Anda — jalankan ulang untuk angka Anda sendiri.
> Placeholder screenshot pada Lampiran diisi mahasiswa.
