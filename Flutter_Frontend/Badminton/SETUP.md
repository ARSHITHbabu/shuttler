# Flutter Frontend Setup Guide

## Overview

This guide will help you set up the Badminton Academy Management Flutter app on your development machine. The app can run on:
- 📱 **Android phones** (via USB or Wi-Fi)
- 💻 **Windows desktop** app
- 🌐 **Web browsers** (Chrome, Edge)

---

## Prerequisites

- ✅ Flutter SDK installed (version 3.0+)
- ✅ Dart SDK (comes with Flutter)
- ✅ Backend server code (FastAPI)
- ✅ Python 3.8+ (for backend)

---

## Backend Configuration

### Step 1: Find Your Computer's IP Address

Your phone needs to connect to your computer over the local network. First, find your computer's IP address:

#### On Windows:

```bash
ipconfig
```

Look for **"IPv4 Address"** under your active Wi-Fi or Ethernet adapter:

```
Wireless LAN adapter Wi-Fi:
   IPv4 Address. . . . . . . . . . . : 192.168.1.7    ← THIS IS YOUR IP
   Subnet Mask . . . . . . . . . . . : 255.255.255.0
   Default Gateway . . . . . . . . . : 192.168.1.1
```

#### On Mac:

```bash
ifconfig
```

Look for **"inet"** under your active network interface (usually `en0` or `en1`):

```
en0: flags=8863<UP,BROADCAST,SMART,RUNNING,SIMPLEX,MULTICAST> mtu 1500
    inet 192.168.1.7 netmask 0xffffff00 broadcast 192.168.1.255    ← THIS IS YOUR IP
```

#### On Linux:

```bash
ifconfig
# or
ip addr
```

Look for **"inet"** under your active network interface.

---

### Step 2: Update Environment Configuration

1. Open the file: `lib/core/config/environment.dart`

2. Find this line (around line 35):
   ```dart
   static const String developmentIp = '192.168.1.7'; // ← CHANGE THIS
   ```

3. Replace `192.168.1.7` with **YOUR** IP address from Step 1:
   ```dart
   static const String developmentIp = '192.168.1.15'; // Your actual IP
   ```

4. Save the file

**Note**: You only need to do this once per computer/network. If you move to a different location or network, update it again.

---

### Step 3: Start the Backend Server

The backend needs to be running and accessible from your local network.

#### Navigate to Backend Directory:

```bash
cd Backend
```

#### Start the Server:

```bash
python main.py
```

#### Verify Backend is Running:

You should see output like:

```
🚀 Starting Badminton Academy Management System API...
📖 API Documentation (Local): http://127.0.0.1:8000/docs
📖 API Documentation (Network): http://192.168.1.7:8000/docs
📱 Mobile devices can connect to: http://192.168.1.7:8000
INFO:     Uvicorn running on http://0.0.0.0:8000 (Press CTRL+C to quit)
```

**Important**: The server MUST be running with `host="0.0.0.0"` (not `127.0.0.1`) to accept connections from your phone.

#### Test Backend Access:

Open your browser and navigate to:
- **From laptop**: http://localhost:8000/docs
- **From phone**: http://192.168.1.7:8000/docs (use YOUR IP)

If the FastAPI documentation page loads, your backend is configured correctly! ✅

---

## Running the Flutter App

### Option 1: On Your Phone (Android) - Recommended for Testing

#### Connect Your Phone:

**Via USB Cable:**
1. Enable Developer Options on your Android phone
2. Enable USB Debugging
3. Connect phone to computer via USB
4. Accept "Allow USB debugging" prompt on phone

**Via Wi-Fi (Wireless Debugging - Android 11+):**
1. Enable Developer Options
2. Enable Wireless Debugging
3. Follow pairing instructions
4. No cable needed!

#### Verify Device Connection:

```bash
flutter devices
```

You should see your phone listed:
```
CPH2423 (mobile) • XXXXXXX • android-arm64 • Android 13 (API 33)
```

#### Run the App:

```bash
flutter run
```

Or specify your device explicitly:
```bash
flutter run -d CPH2423
```

**Note**: Make sure your phone and laptop are on the **same Wi-Fi network**!

---

### Option 2: On Your Laptop (Web) - Best for Development

Running in a web browser is fastest for development and doesn't require a phone.

#### Run in Microsoft Edge:

```bash
flutter run -d edge
```

#### Run in Google Chrome:

```bash
flutter run -d chrome
```

**Advantages**:
- ⚡ Faster hot reload
- 🔍 Browser DevTools for debugging
- 🖱️ No need to set up phone
- 🌐 Uses `localhost:8000` automatically (no IP configuration needed)

---

### Option 3: On Your Laptop (Windows Desktop App)

Run as a native Windows application.

#### Enable Windows Desktop Support:

```bash
flutter config --enable-windows-desktop
```

#### Run the App:

```bash
flutter run -d windows
```

**Note**: Requires Developer Mode enabled on Windows:
- Press `Win + R`
- Type: `ms-settings:developers`
- Enable "Developer Mode"

---

## Hot Reload During Development

Once your app is running, you can make changes to the code and instantly see them:

- Press `r` in the terminal for **hot reload** (keeps app state)
- Press `R` for **hot restart** (resets app state)
- Press `q` to quit

---

## Switching Between Development and Production

### Development Mode (Default)

Uses your local backend server. This is enabled by default.

In `lib/core/config/environment.dart`:
```dart
static const bool isDevelopment = true; // ← Development mode
```

### Production Mode

When you deploy your backend to a cloud server (Heroku, AWS, etc.):

1. Deploy your FastAPI backend to a cloud service
2. Note the production URL (e.g., `https://badminton-api.herokuapp.com`)
3. Update `lib/core/config/environment.dart`:
   ```dart
   static const bool isDevelopment = false; // ← Production mode
   static const String productionUrl = 'https://badminton-api.herokuapp.com';
   ```
4. Rebuild your app:
   ```bash
   flutter clean
   flutter build apk # For Android
   flutter build web # For Web
   flutter build windows # For Windows
   ```

---

## Troubleshooting

### Issue: Phone Can't Connect to Backend

**Error Message**: "Connection refused" or "Network error"

**Checklist**:
- ✅ Both devices are on the **same Wi-Fi network**
- ✅ Backend is running with `host="0.0.0.0"` in `main.py`
- ✅ Correct IP address in `environment.dart`
- ✅ Windows Firewall allows port 8000 (see below)
- ✅ Phone can access backend docs at `http://YOUR_IP:8000/docs`

**Fix Windows Firewall**:
1. Press `Win + R`
2. Type: `wf.msc` and press Enter
3. Click "Inbound Rules" → "New Rule"
4. Select "Port" → Next
5. Select "TCP" → Specific local ports: `8000` → Next
6. Select "Allow the connection" → Next
7. Check all profiles → Next
8. Name: "FastAPI Backend" → Finish

---

### Issue: Web Version Can't Connect

**Error Message**: "Network error" or "Failed to fetch"

**Checklist**:
- ✅ Backend is running (check terminal)
- ✅ Can access http://localhost:8000/docs in browser
- ✅ CORS is enabled in backend (should be by default)

**Fix**: Restart both backend and Flutter web app

---

### Issue: Flutter Devices Not Showing

**Run**:
```bash
flutter doctor
```

This will diagnose issues with your Flutter installation.

**Common fixes**:
- Android: Install Android SDK and USB drivers
- Windows: Enable Developer Mode
- Chrome/Edge: Install browser (usually already installed)

---

### Issue: Hot Reload Not Working

**Solutions**:
1. Press `R` for full hot restart instead of `r`
2. Stop app and run `flutter clean` then `flutter run` again
3. Check terminal for error messages

---

## Project Structure

```
Flutter_Frontend/Badminton/
├── lib/
│   ├── main.dart                          # App entry point
│   ├── core/
│   │   ├── config/
│   │   │   └── environment.dart           # ← CONFIGURE YOUR IP HERE
│   │   ├── constants/
│   │   │   ├── api_endpoints.dart         # API routes
│   │   │   ├── colors.dart                # Color palette
│   │   │   └── dimensions.dart            # Spacing/sizing
│   │   ├── theme/
│   │   │   └── app_theme.dart             # Material theme
│   │   └── services/
│   │       ├── api_service.dart           # HTTP client
│   │       ├── auth_service.dart          # Authentication
│   │       └── storage_service.dart       # Local storage
│   ├── models/                            # Data models
│   ├── providers/                         # Riverpod state management
│   ├── screens/                           # UI screens
│   │   ├── auth/                          # Login, signup
│   │   ├── owner/                         # Owner dashboard
│   │   ├── coach/                         # Coach portal
│   │   └── student/                       # Student portal
│   └── widgets/                           # Reusable components
├── pubspec.yaml                           # Dependencies
├── SETUP.md                               # ← YOU ARE HERE
└── README.md                              # Project overview
```

---

## Useful Commands

### Get Flutter Version:
```bash
flutter --version
```

### Install Dependencies:
```bash
flutter pub get
```

### Analyze Code Quality:
```bash
flutter analyze
```

### Run Tests:
```bash
flutter test
```

### Build Release APK (Android):
```bash
flutter build apk --release
```

### Build Web:
```bash
flutter build web
```

### Clean Build Cache:
```bash
flutter clean
```

---

## Getting Help

If you encounter issues:

1. **Check terminal output** for error messages
2. **Run `flutter doctor`** to diagnose Flutter setup
3. **Verify backend is accessible** at `http://YOUR_IP:8000/docs`
4. **Check that both devices are on same network**
5. **Try web version** (`flutter run -d edge`) to isolate phone-specific issues

---

## Next Steps

Once your app is running:

1. **Test Login**: Use existing credentials from backend
2. **Explore Features**: Navigate through owner dashboard
3. **Make Changes**: Edit code and hot reload to see changes
4. **Check Backend Logs**: Monitor API requests in backend terminal

Happy coding! 🚀
