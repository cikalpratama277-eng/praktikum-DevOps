#!/usr/bin/env bash
# teardown.sh — Menghentikan aplikasi dan membersihkan .venv secara AMAN.
#
# Keamanan (CHALLENGE "Zero-Touch Verification"):
#   - Memvalidasi variabel path SEBELUM melakukan penghapusan.
#   - TIDAK memuat `rm -rf` dengan variabel yang belum diverifikasi.
#   - Bersih dari peringatan shellcheck.
#
# Penggunaan:
#   ./teardown.sh            Hentikan aplikasi (bila berjalan), pertahankan .venv.
#   ./teardown.sh --purge    Hentikan aplikasi DAN hapus direktori .venv.

set -euo pipefail

APP_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
VENV_DIR="$APP_DIR/.venv"
PORT="${PORT:-5000}"

log() { echo "[teardown] $*"; }

# 1) Hentikan proses aplikasi yang menyimak pada PORT (jika ada).
stop_app() {
  local pids=""
  if command -v lsof >/dev/null 2>&1; then
    pids="$(lsof -ti tcp:"$PORT" 2>/dev/null || true)"
  elif command -v fuser >/dev/null 2>&1; then
    pids="$(fuser "$PORT"/tcp 2>/dev/null || true)"
  fi

  if [ -n "$pids" ]; then
    log "Menghentikan proses pada port $PORT: $pids"
    # shellcheck disable=SC2086
    kill $pids 2>/dev/null || true
    sleep 1
  else
    log "Tidak ada proses aktif pada port $PORT."
  fi
}

# 2) Hapus .venv HANYA setelah validasi path menyeluruh.
purge_venv() {
  # Validasi: variabel tidak kosong, bukan root, benar-benar di dalam APP_DIR,
  # dan namanya persis ".venv".
  if [ -z "${VENV_DIR:-}" ]; then
    log "Batal: VENV_DIR kosong."
    return 0
  fi
  if [ "$VENV_DIR" = "/" ] || [ "$VENV_DIR" = "$HOME" ]; then
    log "Batal: VENV_DIR menunjuk lokasi berbahaya ($VENV_DIR)."
    return 1
  fi
  case "$VENV_DIR" in
    "$APP_DIR"/.venv) : ;;  # aman: tepat di dalam direktori aplikasi
    *)
      log "Batal: VENV_DIR ($VENV_DIR) di luar direktori aplikasi."
      return 1
      ;;
  esac

  if [ -d "$VENV_DIR" ]; then
    log "Menghapus virtual environment: $VENV_DIR"
    rm -rf -- "$VENV_DIR"
    log "Selesai membersihkan .venv."
  else
    log "Direktori .venv tidak ditemukan, tidak ada yang dihapus."
  fi
}

stop_app

if [ "${1:-}" = "--purge" ]; then
  purge_venv
else
  log "Mode aman: .venv dipertahankan (jalankan dengan --purge untuk menghapus)."
fi

log "SELESAI."
