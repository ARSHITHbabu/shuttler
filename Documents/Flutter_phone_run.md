# Flutter Phone Run Guide - Badminton Academy Management App

**Document Created**: January 13, 2026
**Purpose**: Guide for running Flutter app on phone and deploying to cloud
**Status**: Development & Production Ready

---

## Table of Contents

1. [Quick Start - Running on Phone](#quick-start---running-on-phone)
2. [Running on Different Devices](#running-on-different-devices)
3. [How the Configuration Works](#how-the-configuration-works)
4. [When You Change Computers/Networks](#when-you-change-computersnetworks)
5. [Cloud Deployment Guide](#cloud-deployment-guide)
6. [Troubleshooting](#troubleshooting)
7. [Technical Details](#technical-details)

---

## Quick Start - Running on Phone

### Step 1: Find Your Computer's IP Address

Open Command Prompt and run:
```bash
ipconfig
```

Look for **IPv4 Address** under your Wi-Fi adapter:
```
Wireless LAN adapter Wi-Fi:
   IPv4 Address. . . . . . . . . . . : 192.xxx.x.x  ← THIS IS YOUR IP
```

### Step 2: Configure Flutter App

1. Open: `Flutter_Frontend/Badminton/lib/core/config/environment.dart`
2. Find line 35:
   ```dart
   static const String developmentIp = ''; // ← CHANGE THIS TO YOUR IP
   ```
3. Add your IP address:
   ```dart
   static const String developmentIp = '192.xxx.x.x'; // Your actual IP
   ```
4. Save the file

### Step 3: Start Backend Server

```bash
cd d:\laptop new\f\Personal Projects\badminton\abhi_colab\shuttler\Backend
python main.py
```

**Verify backend is running:**
- Open browser: http://localhost:8000/docs
- You should see FastAPI documentation page

### Step 4: Connect Your Phone

**Make sure**:
- Phone and laptop are on the **same Wi-Fi network**
- USB debugging is enabled on phone (Settings → Developer Options)
- Phone is connected via USB cable

**Check connection:**
```bash
cd "d:\laptop new\f\Personal Projects\badminton\abhi_colab\shuttler\Flutter_Frontend\Badminton"
flutter devices
```

You should see your phone listed.

### Step 5: Run Flutter App

```bash
flutter run
```

**Or press `r` if already running to hot reload.**

---

## Running on Different Devices

### Option 1: Android Phone (Recommended for Mobile Testing)

```bash
# Check devices
flutter devices

# Run on phone
flutter run -d <device-name>
# Example: flutter run -d CPH2423
```

**Requirements**:
- ✅ Same Wi-Fi network
- ✅ USB debugging enabled
- ✅ Correct IP in environment.dart
- ✅ Backend running with host="0.0.0.0"

### Option 2: Web Browser (Best for Development)

```bash
# Microsoft Edge
flutter run -d edge

# Google Chrome
flutter run -d chrome
```

**Benefits**:
- ⚡ Fastest hot reload
- 🌐 No network configuration needed (uses localhost)
- 🔍 Browser DevTools available
- 💻 No phone required

### Option 3: Windows Desktop App

```bash
flutter run -d windows
```

**Note**: Requires Developer Mode enabled on Windows

---

## How the Configuration Works

### Architecture Overview

```
┌─────────────────────────────────────────────────────────────┐
│                    Configuration System                       │
└─────────────────────────────────────────────────────────────┘

📄 environment.dart (Configuration File)
   ├── isDevelopment = true/false (mode switch)
   ├── developmentIp = 'YOUR_IP' (local network IP)
   ├── port = 8000 (backend port)
   └── productionUrl = 'https://...' (cloud URL)

📄 api_endpoints.dart (Uses Configuration)
   └── baseUrl = Environment.apiBaseUrl (auto-selected)

Platform Detection:
   ├── Web → Uses localhost:8000
   ├── Mobile → Uses YOUR_IP:8000
   └── Desktop → Uses YOUR_IP:8000
```

### Files Modified (Implementation Done on Jan 13, 2026)

**1. Created:** `lib/core/config/environment.dart`
```dart
class Environment {
  static const bool isDevelopment = true;
  static const String developmentIp = '192.xxx.x.x'; // ← Change this
  static const int port = 8000;
  static const String productionUrl = 'https://api.yourdomain.com';

  static String get apiBaseUrl {
    if (isDevelopment) {
      return 'http://$developmentIp:$port';
    } else {
      return productionUrl;
    }
  }
}
```

**2. Modified:** `lib/core/constants/api_endpoints.dart`
```dart
import '../config/environment.dart';

class ApiEndpoints {
  static String get baseUrl {
    if (kIsWeb) {
      return 'http://localhost:${Environment.port}'; // Web uses localhost
    }
    return Environment.apiBaseUrl; // Mobile uses configured IP
  }
}
```

**3. Modified:** `Backend/main.py` (Line 2295)
```python
# Changed from host="127.0.0.1" to host="0.0.0.0"
uvicorn.run(app, host="0.0.0.0", port=8000)
```

**4. Created:** `Flutter_Frontend/Badminton/SETUP.md`
- Complete setup guide
- Step-by-step instructions
- Troubleshooting section

---

## When You Change Computers/Networks

### Scenario 1: Different Laptop (Same Code)

If you move your code to another laptop:

1. **Get new laptop's IP:**
   ```bash
   ipconfig
   ```

2. **Update environment.dart:**
   ```dart
   static const String developmentIp = '192.xxx.x.x'; // New IP
   ```

3. **Restart backend:**
   ```bash
   python main.py
   ```

4. **Hot reload Flutter app:**
   - Press `r` in Flutter terminal
   - Or `R` for full restart

**That's it!** No other changes needed.

### Scenario 2: Different Wi-Fi Network

When you connect to a different Wi-Fi (home → college, etc.):

1. Your IP address will change
2. Run `ipconfig` to get new IP
3. Update `developmentIp` in environment.dart
4. Restart backend and hot reload app

**Example:**
- Home IP: `192.xxx.x.x` → College IP: `10.0.0.25`
- Just change that one line!

### Scenario 3: Sharing with Teammates

When someone else wants to run your code:

1. They clone the repository
2. They run `ipconfig` on their laptop
3. They update `developmentIp` with their IP
4. They start backend on their laptop
5. They run Flutter app on their phone

**Each developer has their own IP!**

---

## Cloud Deployment Guide

### When to Deploy to Cloud

Deploy when you want:
- 🌍 Access from anywhere (not just local network)
- 📱 Test app without running backend locally
- 👥 Share app with multiple users
- 🚀 Production-ready deployment

### Step-by-Step Cloud Deployment

#### Option 1: Deploy to Render (Recommended - Free)

**1. Prepare Backend for Cloud:**

Update `Backend/main.py` to read port from environment:
```python
import os

if __name__ == "__main__":
    import uvicorn
    port = int(os.getenv("PORT", 8000))
    uvicorn.run(app, host="0.0.0.0", port=port)
```

**2. Create `render.yaml` in Backend folder:**
```yaml
services:
  - type: web
    name: badminton-api
    env: python
    buildCommand: pip install -r requirements.txt
    startCommand: python main.py
    envVars:
      - key: DATABASE_URL
        generateValue: true
```

**3. Deploy to Render:**
- Create account at https://render.com
- Connect your GitHub repository
- Deploy backend service
- Note the URL: `https://badminton-api.onrender.com`

**4. Update Flutter Configuration:**

Open `lib/core/config/environment.dart`:
```dart
static const bool isDevelopment = false; // ← CHANGE TO FALSE
static const String productionUrl = 'https://badminton-api.onrender.com'; // ← YOUR RENDER URL
```

**5. Rebuild Flutter App:**
```bash
# For Android
flutter build apk --release

# For Web
flutter build web

# For Windows
flutter build windows
```

**6. Test:**
- Install APK on phone
- App should connect to cloud backend
- Works from anywhere with internet!

---

#### Option 2: Deploy to Heroku

**1. Install Heroku CLI:**
Download from https://devcenter.heroku.com/articles/heroku-cli

**2. Login:**
```bash
heroku login
```

**3. Create Heroku App:**
```bash
cd Backend
heroku create badminton-api
```

**4. Create `Procfile` in Backend folder:**
```
web: uvicorn main:app --host=0.0.0.0 --port=${PORT:-8000}
```

**5. Deploy:**
```bash
git add .
git commit -m "Deploy to Heroku"
git push heroku main
```

**6. Get URL:**
```bash
heroku open
```

Note the URL: `https://badminton-api.herokuapp.com`

**7. Update Flutter (same as Render Option 1, step 4-6)**

---

#### Option 3: Deploy to AWS/Azure/GCP

**Backend Deployment:**
1. Create EC2 instance / App Service / Compute Engine
2. Install Python and dependencies
3. Run backend with `host="0.0.0.0"`
4. Configure domain (optional)
5. Set up SSL certificate (Let's Encrypt)

**Flutter Configuration:**
```dart
static const bool isDevelopment = false;
static const String productionUrl = 'https://your-domain.com';
```

**Build and deploy Flutter app as shown above.**

---

### Important: Switching Back to Development

When you want to test locally again:

**1. Switch back to development mode:**
```dart
static const bool isDevelopment = true; // ← CHANGE TO TRUE
static const String developmentIp = '192.xxx.x.x'; // Your local IP
```

**2. Restart backend locally:**
```bash
python main.py
```

**3. Hot reload Flutter app:**
```bash
r  # in Flutter terminal
```

---

## Troubleshooting

### Issue 1: "Connection Refused" on Phone

**Symptoms:**
- ❌ App shows network error
- ❌ Can't login
- ❌ Terminal shows "Connection refused"

**Solutions:**

✅ **Check 1: Both on Same Wi-Fi**
```bash
# On laptop
ipconfig

# On phone
Settings → Wi-Fi → Check network name
```
Both should show same network.

✅ **Check 2: IP Address Correct**
```dart
// In environment.dart
static const String developmentIp = '192.xxx.x.x'; // Must match your laptop IP
```

✅ **Check 3: Backend Running with Correct Host**
```python
# In Backend/main.py (line 2295)
uvicorn.run(app, host="0.0.0.0", port=8000) # Must be 0.0.0.0, not 127.0.0.1
```

✅ **Check 4: Test Backend from Phone Browser**
Open phone browser and go to: `http://192.xxx.x.x:8000/docs`
If this works, backend is accessible!

✅ **Check 5: Windows Firewall**
```bash
# Press Win + R
wf.msc

# Add inbound rule for port 8000
- New Rule → Port → TCP → 8000 → Allow → Finish
```

---

### Issue 2: Web Version Can't Connect

**Symptoms:**
- ❌ Web app shows "Network error"
- ❌ API calls fail

**Solutions:**

✅ **Check Backend is Running:**
```bash
# Open browser
http://localhost:8000/docs

# Should show FastAPI docs
```

✅ **Clear Browser Cache:**
- Press `Ctrl + Shift + Delete`
- Clear cached images and files
- Reload page

✅ **Check CORS Settings:**
Backend should allow localhost (already configured in main.py)

---

### Issue 3: Hot Reload Not Working

**Symptoms:**
- ⚠️ Press `r` but changes don't appear
- ⚠️ App still shows old code

**Solutions:**

✅ **Try Full Restart:**
```bash
R  # Capital R for full restart
```

✅ **Clean and Rebuild:**
```bash
flutter clean
flutter pub get
flutter run
```

✅ **Check for Syntax Errors:**
```bash
flutter analyze
```

---

### Issue 4: Phone Not Detected

**Symptoms:**
- `flutter devices` doesn't show phone
- USB debugging enabled but not working

**Solutions:**

✅ **On Phone:**
- Settings → About Phone → Tap "Build Number" 7 times (enables Developer Options)
- Settings → Developer Options → Enable USB Debugging
- Accept "Allow USB debugging" prompt when connecting

✅ **On Laptop:**
```bash
# Check ADB devices
adb devices

# If empty, restart ADB
adb kill-server
adb start-server
```

✅ **Try Different USB Cable:**
Some cables are charge-only (no data transfer)

---

### Issue 5: Production App Not Connecting

**Symptoms:**
- ❌ App builds successfully
- ❌ But can't connect to cloud backend

**Solutions:**

✅ **Verify Production URL:**
```dart
// In environment.dart
static const bool isDevelopment = false; // Must be false
static const String productionUrl = 'https://badminton-api.onrender.com'; // Correct URL
```

✅ **Test Backend URL:**
Open browser: `https://badminton-api.onrender.com/docs`
Should show API documentation.

✅ **Rebuild App:**
```bash
flutter clean
flutter build apk --release
```

✅ **Check Backend Logs:**
- Render: Check dashboard logs
- Heroku: `heroku logs --tail`

---

## Technical Details

### Network Configuration Summary

| Platform | URL Used | Configuration File | Notes |
|----------|----------|-------------------|-------|
| **Web (Chrome/Edge)** | `http://localhost:8000` | Auto-detected | No config needed |
| **Android Phone** | `http://YOUR_IP:8000` | environment.dart | Requires same Wi-Fi |
| **Windows Desktop** | `http://YOUR_IP:8000` | environment.dart | Works on same laptop |
| **Production (All)** | `https://your-cloud-url` | environment.dart | Internet required |

### Configuration Files Location

```
Flutter_Frontend/Badminton/
└── lib/
    └── core/
        ├── config/
        │   └── environment.dart          ← MAIN CONFIG FILE (change IP here)
        └── constants/
            └── api_endpoints.dart        ← Uses environment.dart (don't edit)
```

### Backend Configuration

```
Backend/
└── main.py
    └── Line 2295: uvicorn.run(app, host="0.0.0.0", port=8000)
                                    ↑
                            Must be 0.0.0.0 for network access
```

### Why This Setup Works

**Development Mode:**
- Phone needs to connect to laptop over Wi-Fi
- Laptop's backend runs on local IP (192.168.1.7)
- Phone connects to that IP on same network
- Web uses localhost (same machine)

**Production Mode:**
- Backend is deployed to cloud (Render, Heroku, etc.)
- Has public URL (https://...)
- App connects to cloud URL
- Works from anywhere with internet

**The Smart Part:**
- `kIsWeb` automatically detects platform
- Web always uses localhost (no config needed)
- Mobile uses environment config (one line to change)
- Production uses cloud URL (one flag to switch)

---

## Quick Reference Commands

### Development

```bash
# Find your IP
ipconfig

# Start backend
cd Backend
python main.py

# Run Flutter (phone)
cd Flutter_Frontend/Badminton
flutter run

# Run Flutter (web)
flutter run -d edge

# Hot reload
r

# Hot restart
R

# Check devices
flutter devices
```

### Production

```bash
# Switch to production mode (in environment.dart)
isDevelopment = false

# Build Android APK
flutter build apk --release

# Build Web
flutter build web

# Build Windows
flutter build windows

# Check build output
cd build/app/outputs/flutter-apk/
```

### Troubleshooting

```bash
# Check Flutter setup
flutter doctor

# Clean build cache
flutter clean

# Reinstall dependencies
flutter pub get

# Analyze code
flutter analyze

# Check ADB devices
adb devices

# Backend logs
python main.py  # Watch terminal output
```

---

## Summary

### For Running on Phone:

1. ✅ Get your laptop's IP (`ipconfig`)
2. ✅ Update `environment.dart` (line 35)
3. ✅ Start backend (`python main.py`)
4. ✅ Connect phone (USB + same Wi-Fi)
5. ✅ Run Flutter app (`flutter run`)

### For Cloud Deployment:

1. ✅ Deploy backend to Render/Heroku
2. ✅ Get cloud URL
3. ✅ Update `environment.dart`:
   - Set `isDevelopment = false`
   - Set `productionUrl = 'https://...'`
4. ✅ Build release APK
5. ✅ Distribute app

### Key Configuration File:

**`lib/core/config/environment.dart`** - This is the ONLY file you need to change!

---

**Document Version:** 1.0
**Last Updated:** January 13, 2026
**Implementation Status:** ✅ Complete and Tested
**Author:** Claude Sonnet 4.5

---

**Need Help?** Check the [SETUP.md](../Flutter_Frontend/Badminton/SETUP.md) file for detailed setup instructions.
