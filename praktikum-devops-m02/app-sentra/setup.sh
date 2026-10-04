#!/usr/bin/env bash
# setup.sh — Otomasi penyiapan & verifikasi aplikasi (versi MODULAR, Minggu 2).
# Refaktor dari Minggu 1: fungsi bersama dipindah ke lib/common.sh dan seluruh
# echo diganti logging terstruktur bertimestamp (log_info/log_warn/log_error).
set -euo pipefail

APP_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib/common.sh disable=SC1091
source "$APP_DIR/lib/common.sh"

VENV_DIR="$APP_DIR/.venv"
PORT="${PORT:-5000}"

log_info "[1/5] Memeriksa prasyarat..."
require_cmd python3
require_cmd curl
python3 -c 'import sys; sys.exit(0 if sys.version_info >= (3, 10) else 1)' \
  || die "dibutuhkan Python 3.10 atau lebih baru"
port_is_free "$PORT" || die "port $PORT sudah dipakai proses lain"

log_info "[2/5] Menyiapkan virtual environment..."
[ -d "$VENV_DIR" ] || python3 -m venv "$VENV_DIR"
# shellcheck source=/dev/null
source "$VENV_DIR/bin/activate"

log_info "[3/5] Memasang dependensi terkunci..."
pip install --quiet --upgrade pip
pip install --quiet -r "$APP_DIR/requirements.txt"

log_info "[4/5] Menjalankan aplikasi pada port $PORT..."
PORT="$PORT" python3 "$APP_DIR/src/app.py" &
APP_PID=$!
trap 'kill "$APP_PID" 2>/dev/null || true' EXIT

log_info "[5/5] Melakukan smoke test..."
ok=0
for i in 1 2 3 4 5; do
  if curl -fsS "http://127.0.0.1:$PORT/health" >/dev/null 2>&1; then
    ok=1
    break
  fi
  log_warn "  percobaan $i/5 belum berhasil, menunggu 2 detik..."
  sleep 2
done

if [ "$ok" -eq 1 ]; then
  log_info "SUKSES: aplikasi berjalan dan lulus health check (PID $APP_PID, port $PORT)."
else
  die "aplikasi tidak merespons health check"
fi

log_info "Aplikasi aktif di http://127.0.0.1:$PORT/ (tekan Ctrl+C untuk berhenti)."
wait "$APP_PID"
