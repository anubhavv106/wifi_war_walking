#!/bin/bash

set -e

clear

echo "==========================================================="
echo "          WiFi War Walking Assessment Tool"
echo "==========================================================="
echo ""
echo "                    By Av"
echo ""
echo "==========================================================="
echo ""

for cmd in kismet python3 sqlite3 iw pkill find; do
    if ! command -v "$cmd" >/dev/null 2>&1; then
        echo "[!] Missing dependency: $cmd"
        exit 1
    fi
done

read -p "Enter Assessment Folder Name: " PROJECT

PROJECT=$(echo "$PROJECT" | tr ' ' '_' | tr -cd '[:alnum:]_-')

if [ -z "$PROJECT" ]; then
    echo "[!] Invalid Assessment Name"
    exit 1
fi

BASE_DIR="Assessments/$PROJECT"

mkdir -p "$BASE_DIR"
mkdir -p "$BASE_DIR/captures"
mkdir -p "$BASE_DIR/reports"

echo ""
echo "[+] Assessment Directory Created"
echo "[+] $BASE_DIR"
echo ""

echo "[+] Detecting Wireless Interfaces..."
echo ""

INTERFACES=$(iw dev | awk '$1=="Interface"{print $2}')

if [ -z "$INTERFACES" ]; then
    echo "[!] No Wireless Interface Found"
    exit 1
fi

select IFACE in $INTERFACES
do
    if [ -n "$IFACE" ]; then
        break
    fi
done

echo ""
echo "[+] Selected Interface : $IFACE"

echo ""
echo "[+] Stopping Existing Kismet Sessions..."

pkill -9 kismet >/dev/null 2>&1 || true

sleep 2

echo ""
echo "[+] Starting Kismet..."
echo ""

kismet -c "$IFACE" >/dev/null 2>&1 &

sleep 10

echo ""
echo "==========================================================="
echo "                    CAPTURE STARTED"
echo "==========================================================="
echo ""
echo "Walk around and collect WiFi networks."
echo " Visit here to view all wifi Networks : http://localhost:2501/"
echo "Press ENTER when assessment is complete."
echo ""
echo "==========================================================="
echo ""

read

echo ""
echo "[+] Stopping Kismet..."

pkill -INT kismet >/dev/null 2>&1 || true

sleep 5

LATEST=$(find "$(pwd)" \
-type f \
\( -name "*.kismet" -o -name "*.kismetdb" \) \
-printf '%T@ %p\n' 2>/dev/null |
sort -nr |
head -1 |
cut -d' ' -f2-)

echo ""
echo "[DEBUG] Latest Capture:"
echo "$LATEST"

if [ -z "$LATEST" ]; then
    echo "[!] No Kismet Database Found"
    exit 1
fi

if [ ! -f "$LATEST" ]; then
    echo "[!] Capture File Missing"
    exit 1
fi

echo ""
echo "[+] Latest Capture Found"
echo "[+] $LATEST"

cp "$LATEST" "$BASE_DIR/captures/"

OUTPUT="$BASE_DIR/reports/${PROJECT}_war_walking.csv"

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

echo ""
echo "[+] Generating Report..."
echo ""

python3 "$SCRIPT_DIR/wifi_report.py" \
"$LATEST" \
"$OUTPUT"

echo ""
echo "==========================================================="
echo "                     ASSESSMENT COMPLETE"
echo "==========================================================="
echo ""
echo "[+] Capture Saved:"
echo "    $BASE_DIR/captures/"
echo ""
echo "[+] Report Saved:"
echo "    $OUTPUT"
echo ""
