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

echo "[+] Checking Dependencies..."
echo ""

install_if_missing() {

    CMD="$1"
    PKG="$2"

    if ! command -v "$CMD" >/dev/null 2>&1; then

        echo "[!] Missing: $CMD"
        echo "[+] Installing: $PKG"

        sudo apt update -y
        sudo apt install -y "$PKG"

        if ! command -v "$CMD" >/dev/null 2>&1; then
            echo "[!] Failed To Install $PKG"
            exit 1
        fi

    fi
}

install_if_missing python3 python3
install_if_missing sqlite3 sqlite3
install_if_missing iw iw
install_if_missing kismet kismet
install_if_missing pkill procps
install_if_missing find findutils

echo ""
echo "[+] Dependencies OK"
echo ""

echo "[+] Checking Kismet Group Permissions..."
echo ""

if ! groups "$USER" | grep -qw kismet; then

    echo "[!] User is not in kismet group"
    echo "[+] Adding $USER to kismet group..."

    sudo usermod -aG kismet "$USER"

    echo ""
    echo "[!] Added user to kismet group."
    echo "[!] Logout/Login or reboot required."
    echo "[!] Please run the tool again."
    echo ""

    exit 0
fi

echo "[+] Kismet group permission OK"
echo ""

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

KISMET_SOURCE="$IFACE:type=linuxwifi"

echo "[+] Source: $KISMET_SOURCE"

kismet -c "$KISMET_SOURCE" >/dev/null 2>&1 &

sleep 10

echo ""
echo "==========================================================="
echo "                    CAPTURE STARTED"
echo "==========================================================="
echo ""
echo "Walk around and collect WiFi networks."
echo "Visit here to view all wifi Networks : http://localhost:2501/"
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
