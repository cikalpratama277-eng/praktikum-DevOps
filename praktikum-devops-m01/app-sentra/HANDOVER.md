# Instruksi Deployment (Manual)

Halo tim Ops,

Aplikasi sudah selesai dan sudah saya tes di laptop saya, jalan normal.

Cara menjalankan:

1. Install dependensi.
2. Jalankan aplikasi.
3. Buka di browser.

Terima kasih.

---

> **Catatan untuk laporan (bukan bagian dari dokumen serah-terima asli).**
> Dokumen di atas **sengaja dibuat tidak lengkap** sesuai skenario JOB 2
> untuk mendemonstrasikan fenomena *Wall of Confusion* dan *"it works on my
> machine"*. Informasi kritis yang **absen** dari HANDOVER.md ini:
>
> - Tidak menyebut pembuatan *virtual environment* (`python3 -m venv .venv`).
> - Tidak menyebut versi Python minimum (≥ 3.10) yang dibutuhkan.
> - Tidak menyertakan `requirements.txt` (artefak sengaja tidak dikemas).
> - Tidak menyebut perintah persis instalasi (`pip install -r requirements.txt`).
> - Tidak menyebut port (5000) maupun URL uji (`http://127.0.0.1:5000/`).
> - Tidak ada cara verifikasi/health check (`curl .../health`).
>
> Kekurangan inilah yang menyebabkan galat seperti
> `ModuleNotFoundError: No module named 'flask'` dan
> `externally-managed-environment` pada mesin Ops.
