# WiFi War Walking Assessment Tool

A lightweight WiFi War Walking Assessment Tool built around Kismet to automate wireless network discovery and reporting.

The tool automatically:

* Detects available wireless interfaces
* Launches Kismet for wireless reconnaissance
* Captures nearby WiFi networks
* Exports results into a structured CSV report
* Removes hidden SSIDs
* Removes invalid SSID=BSSID entries
* Removes duplicate BSSIDs
* Organizes assessments into dedicated folders

---

## Features

### Wireless Discovery

* Automatic wireless interface selection
* Kismet integration
* Passive WiFi network detection
* Support for 2.4 GHz, 5 GHz and 6 GHz networks

### Reporting

* CSV report generation
* Vendor extraction
* Channel identification
* Protocol identification
* Authentication identification
* Assessment folder organization

### Data Cleanup

* Hidden SSID filtering
* Duplicate BSSID removal
* Invalid ESSID filtering
* SSID equals BSSID filtering

---

## Report Format

Generated reports contain:

| Column        | Description                      |
| ------------- | -------------------------------- |
| SSID          | Wireless Network Name            |
| MAC           | BSSID / Access Point MAC Address |
| Vendor        | Device Manufacturer              |
| Channel       | Wireless Channel                 |
| Band          | 2.4 GHz / 5 GHz / 6 GHz          |
| Protocol      | WPA / WPA2 / WPA3 / Open         |
| Auth          | PSK / SAE / 802.1X / Open        |
| HDFC Comments | Assessment Notes                 |

---

## Folder Structure

After every assessment:

```text
Assessments/
└── Assessment_Name/
    ├── captures/
    │   └── Kismet-xxxx.kismet
    │
    └── reports/
        └── Assessment_Name_war_walking.csv
```

---

## Installation

### Kali Linux

```bash
sudo apt update

sudo apt install \
kismet \
python3 \
python3-pip \
sqlite3 \
iw
```

---

## Usage

Make scripts executable:

```bash
chmod +x wifi-warwalk.sh
chmod +x wifi_report.py
```

Run assessment:

```bash
sudo ./wifi-warwalk.sh
```

---

## Workflow

### Step 1

Enter Assessment Name

```text
HDFC_Haridwar
```

### Step 2

Select Wireless Interface

```text
1) wlan0
2) wlan1
```

### Step 3

Walk around target area and collect WiFi networks.

### Step 4

Press ENTER when assessment is complete.

### Step 5

Tool automatically:

* Stops Kismet
* Finds latest capture
* Generates report
* Saves assessment artifacts

---

## Sample Output

```csv
SSID,MAC,Vendor,Channel,Band,Protocol,Auth,HDFC Comments

Airtel_PG_Home_2.4,F4:4D:5C:ED:17:AC,Nokia,11,2.4 GHz,WPA2,PSK,

Sequretek,CE:4F:86:C9:51:A3,Unknown,36,5 GHz,WPA2,PSK,

Sequretek_1stfloor,D2:4F:86:C9:51:A3,Unknown,149,5 GHz,WPA2,PSK,
```

---

## Example Assessment

```text
===========================================================

WiFi War Walking Assessment Tool

By Av

===========================================================

Enter Assessment Folder Name:

HDFC_Haridwar

1) wlan0
2) wlan1

Select: 1

[+] Starting Kismet

Walk around and collect WiFi networks

Press ENTER when assessment is complete
```

Generated:

```text
Assessments/
└── HDFC_Haridwar/
    ├── captures/
    │   └── Kismet-20260603-07-30-58-1.kismet
    │
    └── reports/
        └── HDFC_Haridwar_war_walking.csv
```

---

## Disclaimer

This tool is intended for authorized wireless security assessments, wireless inventory collection, training environments, and defensive security engagements.

Always obtain proper authorization before collecting wireless network information.

---

## Author

**Av**

Wireless Security Assessment Automation
