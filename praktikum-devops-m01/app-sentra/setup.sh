#!/usr/bin/env bash
# setup.sh — Otomasi penyiapan & verifikasi aplikasi (The First Way: Flow)
#
# Menggantikan seluruh prosedur manual pada HANDOVER.md dengan satu perintah.
# Termasuk penyelesaian CHALLENGE "Zero-Touch Verification":
#   - mode --check (validasi prasyarat saja)
#   - deteksi port bentrok + pencarian port bebas otomatis
#   - retry health check (maks 5x, jeda 2 detik)
#   - bersih dari peringatan shellcheck
#
# Penggunaan:
#   ./setup.sh            Menyiapkan venv, memasang dependensi, menjalankan app + smoke test.
#   ./setup.sh --check    Hanya memvalidasi prasyarat (Python, pip, port). exit 0=siap, 1=tidak.

set -euo pipefail

APP_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
VENV_DIR="$APP_DIR/.venv"
PORT="${PORT:-5000}"
MAX_PORT_SCAN=20
HEALTH_RETRIES=5
HEALTH_DELAY=2

log() { echo "[setup] $*"; }
fail() { echo "[setup] GAGAL: $*" >&2; exit 1; }

# Mengembalikan 0 jika port sedang terpakai.
port_in_use() {
  local p="$1"
  if command -v ss >/dev/null 2>&1; then
    ss -ltn 2>/dev/null | grep -q ":${p}[[:space:]]"
  else
    python3 - "$p" <<'PY'
import socket, sys
p = int(sys.argv[1])
s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
try:
    s.bind(("127.0.0.1", p))
    sys.exit(1)  # bebas
except OSError:
    sys.exit(0)  # terpakai
finally:
    s.close()
PY
  fi
}

# Mencari port bebas mulai dari $PORT. Menuliskan hasil ke stdout.
find_free_port() {
  local start="$1" p end
  end=$((start + MAX_PORT_SCAN))
  for ((p = start; p < end; p++)); do
    if ! port_in_use "$p"; then
      echo "$p"
      return 0
    fi
  done
  return 1
}

check_prereq() {
  log "[1/5] Memeriksa prasyarat..."
  command -v python3 >/dev/null || fail "python3 tidak ditemukan."
  python3 -c 'import sys; sys.exit(0 if sys.version_info >= (3, 10) else 1)' \
    || fail "dibutuhkan Python 3.10 atau lebih baru."
  python3 -m pip --version >/dev/null 2>&1 || python3 -m ensurepip >/dev/null 2>&1 \
    || fail "pip tidak tersedia dan gagal di-bootstrap."
  [ -f "$APP_DIR/requirements.txt" ] || fail "requirements.txt tidak ditemukan."
  log "Prasyarat terpenuhi (python3, pip, requirements.txt)."
}

# ----- Mode --check: hanya validasi prasyarat lalu keluar -----
if [ "${1:-}" = "--check" ]; then
  check_prereq
  if port_in_use "$PORT"; then
    log "Port $PORT sedang terpakai."
    if free_port="$(find_free_port "$PORT")"; then
      log "Port bebas tersedia: $free_port."
    else
      fail "tidak ada port bebas pada rentang $PORT–$((PORT + MAX_PORT_SCAN))."
    fi
  else
    log "Port $PORT bebas."
  fi
  log "SIAP: seluruh prasyarat lingkungan terpenuhi."
  exit 0
fi

# ----- Alur penuh -----
check_prereq

log "[2/5] Menyiapkan virtual environment..."
[ -d "$VENV_DIR" ] || python3 -m venv "$VENV_DIR"
# shellcheck source=/dev/null
source "$VENV_DIR/bin/activate"

log "[3/5] Memasang dependensi terkunci..."
pip install --quiet --upgrade pip
pip install --quiet -r "$APP_DIR/requirements.txt"

# Deteksi port bentrok — cari port bebas alih-alih gagal.
if port_in_use "$PORT"; then
  log "Port $PORT terpakai, mencari port bebas berikutnya..."
  PORT="$(find_free_port "$PORT")" || fail "tidak ada port bebas yang tersedia."
  log "Menggunakan port $PORT."
fi

log "[4/5] Menjalankan aplikasi pada port $PORT..."
PORT="$PORT" python3 "$APP_DIR/src/app.py" &
APP_PID=$!
trap 'kill "$APP_PID" 2>/dev/null || true' EXIT

log "[5/5] Melakukan smoke test (retry maks $HEALTH_RETRIES x, jeda ${HEALTH_DELAY}s)..."
ok=0
for ((i = 1; i <= HEALTH_RETRIES; i++)); do
  if curl -fsS "http://127.0.0.1:$PORT/health" >/dev/null 2>&1; then
    ok=1
    break
  fi
  log "  percobaan $i/$HEALTH_RETRIES belum berhasil, menunggu ${HEALTH_DELAY}s..."
  sleep "$HEALTH_DELAY"
done

if [ "$ok" -eq 1 ]; then
  log "SUKSES: aplikasi berjalan dan lulus health check (PID $APP_PID, port $PORT)."
else
  fail "aplikasi tidak merespons health check setelah $HEALTH_RETRIES percobaan."
fi

log "Aplikasi aktif di http://127.0.0.1:$PORT/  (tekan Ctrl+C untuk berhenti)."
wait "$APP_PID"
