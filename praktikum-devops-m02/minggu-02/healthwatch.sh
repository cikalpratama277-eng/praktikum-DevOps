#!/usr/bin/env bash
# healthwatch.sh — CHALLENGE "Health Watcher" (Minggu 2).
# Memantau endpoint /health, mencatat log terstruktur, mendeteksi transisi
# UP/DOWN, menghitung MTTR, dan menampilkan ringkasan sesi saat Ctrl+C.
set -euo pipefail

INTERVAL=5
URL="http://127.0.0.1:5000/health"
LOG_FILE="${LOG_FILE:-/tmp/healthwatch.log}"

# ---- Status sesi ----
CHECKS=0
INCIDENTS=0
TOTAL_DOWN=0          # total detik padam (akumulasi, detik)
DOWN_SINCE=0          # epoch saat insiden dimulai (0 = sedang UP)
PREV_STATE="UP"

usage() {
  cat <<USAGE
healthwatch.sh — pemantau endpoint /health
Penggunaan: healthwatch.sh [OPSI]
  --interval N   Jeda antar pemeriksaan dalam detik (default: 5, harus > 0)
  --url URL      URL yang dipantau (default: $URL)
  -h, --help     Tampilkan bantuan ini
Exit code: 0 = tidak ada insiden, 2 = minimal satu insiden terjadi
USAGE
}

die() { echo "GALAT: $*" >&2; exit 1; }

iso_now() { date '+%Y-%m-%dT%H:%M:%S%z'; }

# ---- Penguraian & validasi argumen ----
while [[ $# -gt 0 ]]; do
  case "$1" in
    --interval)
      [[ $# -ge 2 ]] || die "--interval membutuhkan nilai"
      INTERVAL="$2"; shift 2 ;;
    --url)
      [[ $# -ge 2 ]] || die "--url membutuhkan nilai"
      URL="$2"; shift 2 ;;
    -h|--help) usage; exit 0 ;;
    *) usage >&2; die "argumen tidak dikenal: $1" ;;
  esac
done

[[ "$INTERVAL" =~ ^[0-9]+$ ]] || die "--interval harus bilangan bulat"
((INTERVAL > 0)) || die "--interval harus lebih besar dari 0"
[[ "$URL" =~ ^https?:// ]] || die "--url harus diawali http:// atau https://"

# ---- Ringkasan saat Ctrl+C (SIGINT) ----
print_summary() {
  echo
  echo "===== RINGKASAN SESI HEALTH WATCHER ====="
  local avail="100.00"
  # Bila sesi berakhir saat masih DOWN, tutup insiden berjalan.
  if ((DOWN_SINCE > 0)); then
    TOTAL_DOWN=$((TOTAL_DOWN + ($(date +%s) - DOWN_SINCE)))
  fi
  local uptime_based_total=$((CHECKS * INTERVAL))
  if ((uptime_based_total > 0)); then
    avail=$(awk -v d="$TOTAL_DOWN" -v t="$uptime_based_total" \
      'BEGIN { printf "%.2f", (t - d) / t * 100 }')
  fi
  printf '%-24s : %s\n' "Jumlah pemeriksaan"  "$CHECKS"
  printf '%-24s : %s\n' "Jumlah insiden"      "$INCIDENTS"
  printf '%-24s : %s detik\n' "Total waktu padam" "$TOTAL_DOWN"
  printf '%-24s : %s%%\n' "Ketersediaan"       "$avail"
  printf '%-24s : %s\n' "Berkas log"          "$LOG_FILE"
  echo "========================================="
  if ((INCIDENTS > 0)); then exit 2; else exit 0; fi
}
trap print_summary SIGINT

echo "Memantau $URL setiap ${INTERVAL}s — tekan Ctrl+C untuk berhenti."
: > "$LOG_FILE"

while true; do
  start_ns=$(date +%s%N)
  if curl -fsS --max-time "$INTERVAL" "$URL" >/dev/null 2>&1; then
    state="UP"
  else
    state="DOWN"
  fi
  end_ns=$(date +%s%N)
  rt_ms=$(( (end_ns - start_ns) / 1000000 ))
  CHECKS=$((CHECKS + 1))

  printf '%s status=%s rt_ms=%s\n' "$(iso_now)" "$state" "$rt_ms" | tee -a "$LOG_FILE"

  # ---- Deteksi transisi status ----
  if [[ "$state" == "DOWN" && "$PREV_STATE" == "UP" ]]; then
    DOWN_SINCE=$(date +%s)
    INCIDENTS=$((INCIDENTS + 1))
    echo "  !! INSIDEN #$INCIDENTS dimulai pada $(iso_now)" | tee -a "$LOG_FILE"
  elif [[ "$state" == "UP" && "$PREV_STATE" == "DOWN" ]]; then
    local_mttr=$(( $(date +%s) - DOWN_SINCE ))
    TOTAL_DOWN=$((TOTAL_DOWN + local_mttr))
    DOWN_SINCE=0
    echo "  >> PULIH pada $(iso_now) — MTTR insiden ini: ${local_mttr} detik" | tee -a "$LOG_FILE"
  fi

  PREV_STATE="$state"
  sleep "$INTERVAL"
done
