#!/usr/bin/env python3

import sqlite3
import json
import csv
import sys
import re

if len(sys.argv) != 3:
    print(
        f"Usage: {sys.argv[0]} file.kismet output.csv"
    )
    sys.exit(1)

DB = sys.argv[1]
OUTPUT = sys.argv[2]

MAC_REGEX = re.compile(
    r'^([0-9A-F]{2}:){5}[0-9A-F]{2}$',
    re.I
)

def get_band(channel):

    try:

        ch = int(channel)

        if 1 <= ch <= 14:
            return "2.4 GHz"

        elif 36 <= ch <= 177:
            return "5 GHz"

        elif ch > 177:
            return "6 GHz"

    except:
        pass

    return "Unknown"

def get_protocol(crypt):

    crypt = crypt.upper()

    if "WPA3" in crypt:
        return "WPA3"

    if "WPA2" in crypt:
        return "WPA2"

    if "WPA" in crypt:
        return "WPA"

    return "Open"

def get_auth(crypt):

    crypt = crypt.upper()

    if "SAE" in crypt:
        return "SAE"

    if "PSK" in crypt:
        return "PSK"

    if "802.1X" in crypt:
        return "802.1X"

    if "EAP" in crypt:
        return "802.1X"

    return "Open"

print("")
print(f"[+] Opening Database: {DB}")

conn = sqlite3.connect(DB)
cur = conn.cursor()

rows = cur.execute(
    "SELECT device FROM devices"
).fetchall()

seen = set()
exported = 0

with open(
    OUTPUT,
    "w",
    newline="",
    encoding="utf-8"
) as csvfile:

    writer = csv.writer(csvfile)

    writer.writerow([
        "SSID",
        "MAC",
        "Vendor",
        "Channel",
        "Band",
        "Protocol",
        "Auth",
        "HDFC Comments"
    ])

    for row in rows:

        try:

            dev = json.loads(row[0])

            ssid = str(
                dev.get(
                    "kismet.device.base.name",
                    ""
                )
            ).strip()

            mac = str(
                dev.get(
                    "kismet.device.base.macaddr",
                    ""
                )
            ).upper()

            vendor = str(
                dev.get(
                    "kismet.device.base.manuf",
                    "Unknown"
                )
            ).strip()

            channel = str(
                dev.get(
                    "kismet.device.base.channel",
                    ""
                )
            ).strip()

            crypt = str(
                dev.get(
                    "kismet.device.base.crypt",
                    ""
                )
            )

            if not ssid:
                continue

            if not mac:
                continue

            if ssid.lower() in [
                "<hidden ssid>",
                "<hidden>",
                "hidden"
            ]:
                continue

            if ssid.upper() == mac.upper():
                continue

            if MAC_REGEX.match(ssid):
                continue

            if mac in seen:
                continue

            seen.add(mac)

            if vendor == "":
                vendor = "Unknown"

            writer.writerow([
                ssid,
                mac,
                vendor,
                channel,
                get_band(channel),
                get_protocol(crypt),
                get_auth(crypt),
                ""
            ])

            exported += 1

        except Exception:
            continue

conn.close()

print("")
print(f"[+] Networks Exported : {exported}")
print(f"[+] Output File       : {OUTPUT}")
print("")
