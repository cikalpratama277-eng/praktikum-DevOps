# Praktikum DevOps — Minggu ke-3 (JS-DVO-03)

**Version Control (Basic): Git Fundamental, Workflow, & Konfigurasi Repository**
Lanjutan Minggu 1 & 2 · PT Sentra Digital Batam · Politeknik Negeri Batam

| Identitas | Nilai |
|-----------|-------|
| Nama      | Cikal Pratama |
| NIM       | 4332511053 |
| Mata Kuliah | DevOps (RKS305) — 3 SKS |
| Dosen     | Antoni Haikal |
| Berkas laporan | `M03_4332511053_Cikal Pratama.pdf` |

## Struktur

```
praktikum-devops-m03/
├── README.md
├── hooks/                      # CHALLENGE (salinan agar bisa dibagikan ke tim)
│   ├── pre-commit              # tolak kredensial + shellcheck berkas .sh ter-stage
│   └── commit-msg              # wajibkan Conventional Commits
├── app-sentra/                 # berkas yang ditata pada JOB 5
│   ├── README.md
│   └── .gitignore
├── minggu-03/                  # bukti output nyata tiap JOB
│   ├── job1-ssh.log            # konfigurasi Git + kunci SSH + izin
│   ├── job2-area.log           # tiga area kerja & siklus commit
│   ├── job3-objek.log          # cat-file + bukti snapshot (hash blob sama)
│   ├── job4-koreksi.log        # amend/restore/reset/reflog/revert
│   ├── job5-rilis.log          # pindai kredensial, commit atomik, tag v1.0.0
│   └── challenge-hook.log      # 3 skenario pengujian hook
├── laporan/laporan.html
└── M03_4332511053_Cikal Pratama.pdf
```

## Ringkasan perintah kunci

```bash
# JOB 1 — SSH (Ed25519) + izin least privilege + alihkan remote ke SSH
ssh-keygen -t ed25519 -C "4332511053@students.polibatam.ac.id" -f ~/.ssh/id_ed25519_polibatam
chmod 700 ~/.ssh; chmod 600 ~/.ssh/id_ed25519_polibatam; chmod 644 ~/.ssh/id_ed25519_polibatam.pub
eval "$(ssh-agent -s)"; ssh-add ~/.ssh/id_ed25519_polibatam
ssh -T git@github.com
git remote set-url origin git@github.com:<username>/praktikum-devops-m01.git

# JOB 4 — tiga mode reset + pemulihan
git reset --soft HEAD~1    # perubahan tetap di staging
git reset --mixed HEAD~1   # perubahan turun ke working dir
git reset --hard HEAD~1    # working dir DIHAPUS (hati-hati)
git reflog                 # cari hash sebelum kecelakaan, lalu reset --hard <hash>
git revert --no-edit HEAD  # satu-satunya yang aman di branch bersama

# JOB 5 — tandai rilis
git tag -a v1.0.0 -m "Rilis pertama: deployment otomatis dan laporan sistem"
git push origin main && git push origin v1.0.0
```

## Memasang Challenge hooks pada repo praktikum

```bash
cd ~/praktikum-devops/minggu-01/app-sentra
cp /path/ke/hooks/pre-commit .git/hooks/pre-commit
cp /path/ke/hooks/commit-msg .git/hooks/commit-msg
chmod +x .git/hooks/pre-commit .git/hooks/commit-msg
# simpan juga salinannya di hooks/ (sudah disertakan) agar dapat dibagikan Minggu 4
```

> **K3 / Keamanan:** kunci privat (tanpa `.pub`) **tidak boleh** di-commit/dibagikan,
> wajib izin 600; jangan `git push --force` pada branch bersama (gunakan
> `--force-with-lease` bila terpaksa); kredensial yang pernah ter-commit dianggap
> **bocor** → rotasi dulu, baru bersihkan riwayat; tinjau `git diff --staged`
> sebelum tiap commit.

---

> **Catatan.** Seluruh keluaran terminal pada laporan diambil dari **eksekusi nyata**
> di repo latihan lokal. Hash commit & stempel waktu akan berbeda saat Anda
> menjalankannya. Keluaran `ssh -T git@github.com` ditampilkan sebagai keluaran
> yang diharapkan setelah kunci publik Anda terdaftar di GitHub. Placeholder
> screenshot pada Lampiran diisi mahasiswa.
