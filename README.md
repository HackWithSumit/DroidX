# 🚀 DroidX
### A Complete Android Manager (PowerShell GUI)

DroidX is a lightweight, GUI-based Android management tool built using PowerShell and Windows Forms. It provides essential ADB functionalities in a clean and user-friendly interface without requiring manual command-line interaction.

---


<img width="2879" height="1694" alt="image" src="https://github.com/user-attachments/assets/f91e56a0-aa83-485c-a8c1-625bf0ae1c06" />


## ✨ Features

### 🔌 Connect (ADB Installer)
- Automatically downloads **official Android Platform Tools**
- Installs safely from Google source
- Stores ADB path for reuse
- Detects existing installation

---

### 🔄 Refresh (Device Detection)
- Runs `adb devices`
- Displays connected devices
- Shows status:
  - `device`
  - `unauthorized`
  - `offline`

---

### 📱 Devices Manager
- Supports **multiple devices**
- Lists all connected devices
- Allows device selection
- Prepares for multi-device control

---

### 📦 Bloatware Manager
- Lists installed apps:
  - All apps
  - User apps
  - System apps
- Features:
  - 🔍 Search filter
  - 🚫 Disable apps
  - ❌ Uninstall apps (user-level)

---

### 🔧 Recovery Tools
- Reboot options:
  - Recovery Mode
  - System
  - Download Mode (Samsung supported)
- Quick-access popup UI

---

### 📸 Screenshot Tool
- Captures device screen using ADB
- Saves to PC automatically
- Displays preview instantly
- Cleans temporary device files

---

### 📘 User Guide
- Step-by-step guide to enable USB Debugging
- Beginner-friendly instructions
- Built-in help system

---

### ℹ️ About Section
- App information
- Developer details
- Contact information

---

## 🖥️ System Requirements

- Windows 10 / 11
- PowerShell 5.1+
- .NET Framework (pre-installed on Windows)
- Internet connection (first run for ADB download)

---

## 📱 Device Requirements

- Android device
- USB cable
- USB Debugging enabled

---

## ⚙️ Setup & Usage

### 1. Run the Script
```powershell
powershell -ExecutionPolicy Bypass -File DroidX.ps1
