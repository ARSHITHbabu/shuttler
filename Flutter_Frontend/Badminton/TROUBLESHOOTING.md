# Troubleshooting Guide

## Common Errors and Solutions

### 1. Kotlin Incremental Compilation Cache Error

**Error**: 
- `IllegalArgumentException: this and base files have different roots`
- `Storage for [...] is already registered`
- `Could not close incremental caches`
- `Daemon compilation failed`

**Solution**: This error occurs when the Kotlin compilation cache is corrupted. To fix:

**Quick Fix** (Recommended):
```powershell
cd Flutter_Frontend\Badminton
.\clean_kotlin_cache.ps1
flutter pub get
flutter run
```

**Manual Fix**:
```powershell
# Stop Java/Gradle processes
Get-Process | Where-Object {$_.ProcessName -like "*java*" -or $_.ProcessName -like "*gradle*"} | Stop-Process -Force -ErrorAction SilentlyContinue

# Clean Flutter build cache
cd Flutter_Frontend\Badminton
flutter clean

# Clean Android build cache
Remove-Item -Recurse -Force build -ErrorAction SilentlyContinue
Remove-Item -Recurse -Force android\build -ErrorAction SilentlyContinue
Remove-Item -Recurse -Force android\app\build -ErrorAction SilentlyContinue
Remove-Item -Recurse -Force android\.gradle -ErrorAction SilentlyContinue

# Clean Kotlin daemon cache (optional)
Remove-Item -Recurse -Force "$env:USERPROFILE\.kotlin\daemon" -ErrorAction SilentlyContinue

# Rebuild
flutter pub get
flutter run
```

**Note**: The `clean_kotlin_cache.ps1` script automates all these steps for you.

```powershell
# Clean Flutter build cache
cd Flutter_Frontend\Badminton
flutter clean

# Clean Android build cache
cd android
Remove-Item -Recurse -Force build -ErrorAction SilentlyContinue
Remove-Item -Recurse -Force app\build -ErrorAction SilentlyContinue
Remove-Item -Recurse -Force .gradle -ErrorAction SilentlyContinue

# Rebuild
cd ..
flutter pub get
flutter run
```

### 2. Network Connection Error: "No route to host"

**Error**: `The connection errored: No route to host`

**Causes**:
- Backend server is not running
- Incorrect IP address in `api_endpoints.dart`
- Device and computer are not on the same network
- Windows Firewall is blocking the connection

**Solution Steps**:

1. **Find your correct IP address**:
   ```powershell
   cd Flutter_Frontend\Badminton
   .\get_local_ip.ps1
   ```
   This will show your local IP address (e.g., `192.168.1.7`)

2. **Update the IP address** in `lib/core/constants/api_endpoints.dart`:
   ```dart
   static String get baseUrl {
     if (kIsWeb) {
       return 'http://localhost:8000';
     }
     // Replace with your actual IP address
     return 'http://YOUR_IP_ADDRESS:8000';  // e.g., 'http://192.168.1.7:8000'
   }
   ```

3. **Start the backend server**:
   ```powershell
   cd Backend
   python main.py
   ```
   The server should start on `http://0.0.0.0:8000`

4. **Check Windows Firewall**:
   - Open Windows Defender Firewall
   - Click "Allow an app or feature through Windows Defender Firewall"
   - Ensure Python is allowed, or add port 8000 as an exception

5. **Verify network connectivity**:
   - Ensure your phone/emulator and computer are on the same WiFi network
   - Test connection: Open browser on your phone and go to `http://YOUR_IP:8000/docs`

6. **Rebuild the Flutter app**:
   ```powershell
   cd Flutter_Frontend\Badminton
   flutter run
   ```

### 3. Backend Server Not Running

**Symptoms**: All API requests fail with connection errors

**Solution**:
1. Navigate to the Backend directory
2. Ensure dependencies are installed: `pip install -r requirements.txt`
3. Start the server: `python main.py`
4. Verify it's running by visiting `http://localhost:8000/docs` in your browser

### 4. Port Already in Use

**Error**: `Address already in use` or `Port 8000 is already in use`

**Solution**:
1. Find the process using port 8000:
   ```powershell
   netstat -ano | findstr :8000
   ```
2. Kill the process (replace PID with the actual process ID):
   ```powershell
   taskkill /PID <PID> /F
   ```
3. Or change the port in `main.py` and update `api_endpoints.dart` accordingly

## Quick Fix Commands

### Complete Clean and Rebuild
```powershell
# Navigate to Flutter project
cd Flutter_Frontend\Badminton

# Clean everything
flutter clean
Remove-Item -Recurse -Force android\build -ErrorAction SilentlyContinue
Remove-Item -Recurse -Force android\app\build -ErrorAction SilentlyContinue

# Rebuild
flutter pub get
flutter run
```

### Check Backend Connection
```powershell
# Test if backend is accessible
Test-NetConnection -ComputerName localhost -Port 8000

# Or from your phone's browser, visit:
# http://YOUR_COMPUTER_IP:8000/docs
```

## Still Having Issues?

1. Check the Flutter logs: `flutter run -v` (verbose mode)
2. Check backend logs in the terminal where `main.py` is running
3. Verify your network setup:
   - Same WiFi network for device and computer
   - No VPN interfering
   - Firewall exceptions configured
4. Try using `10.0.2.2` if using Android Emulator (special IP for host machine)
