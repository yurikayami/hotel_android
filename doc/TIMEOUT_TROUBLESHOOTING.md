# 🔧 Timeout Error Troubleshooting Guide

## Problem
```
TimeoutException after 0:00:30.0000 seconds
Future note completed with error
```

This means the app **successfully connected** to the correct port (7043) but **received no response** from the backend API within 30 seconds.

---

## ✅ What Works Now
- ✅ Port configuration is correct (7043)
- ✅ Connection attempted successfully
- ✅ Network path reachable

## ❌ What's Not Working
- ❌ Backend API is NOT running
- ❌ Backend API is not responding
- ❌ Backend API is blocked/inaccessible

---

## 🔍 Diagnostic Checklist

### 1. Check if Backend API is Running

**Windows PowerShell:**
```powershell
# Try to access the API health endpoint
curl https://localhost:7043/api -SkipCertificateCheck

# Or using Invoke-WebRequest
Invoke-WebRequest https://localhost:7043/api -SkipCertificateCheck
```

**Expected Response:**
- Status code 200-500 (anything other than timeout)
- Some response from server

**If You Get:**
- `Connection refused` → Backend NOT running
- `No response timeout` → Backend stopped or crashed
- Error response → Backend is running but has error

### 2. Start Hotel_API Backend

**Navigate to API folder:**
```bash
cd "d:\Workspace\01 Project\Project Dev\Graduation project\Main Project\Hotel_API"
```

**Run the API:**
```bash
# Using dotnet CLI
dotnet run

# Or open in Visual Studio and press F5
```

**Expected Output in Terminal:**
```
info: Microsoft.Hosting.Lifetime[14]
      Now listening on: https://localhost:7135
info: Microsoft.Hosting.Lifetime[0]
      Application started. Press Ctrl+C to shut down.
```

### 3. Verify Database Connection

**Check SQL Server:**
```sql
-- In SQL Server Management Studio, connect to:
Server: DESKTOP-XXXXX\SQLEXPRESS
Database: Hotel_Web
```

**Expected:**
- Can connect to SQL Server
- Database "Hotel_Web" exists
- Tables exist (Users, Posts, Comments, etc.)

### 4. Check Port Configuration

**Verify Backend Port:**

In `Hotel_API/Properties/launchSettings.json`:
```json
{
  "https": {
    "commandName": "Project",
    "launchBrowser": false,
    "applicationUrl": "https://localhost:7043;http://localhost:5043",
    "environmentVariables": {
      "ASPNETCORE_ENVIRONMENT": "Development"
    }
  }
}
```

**Verify Flutter App Configuration:**

In `lib/services/api_config.dart`:
```dart
static const String baseUrl = 'https://localhost:7043/api';
```

Both should match port **7043** ✅

### 5. Test API Endpoints

**Register endpoint:**
```bash
curl -X POST https://localhost:7043/api/Auth/register \
  -H "Content-Type: application/json" \
  -d '{"username":"test","email":"test@example.com","password":"Test@123456"}' \
  -SkipCertificateCheck
```

**Login endpoint:**
```bash
curl -X POST https://localhost:7043/api/Auth/login \
  -H "Content-Type: application/json" \
  -d '{"email":"test@example.com","password":"Test@123456"}' \
  -SkipCertificateCheck
```

---

## 🚀 Solution Steps

### Step 1: Start Backend API

```powershell
# Navigate to API project
cd "d:\Workspace\01 Project\Project Dev\Graduation project\Main Project\Hotel_API"

# Run the API
dotnet run
```

**Wait for message:**
```
Application started. Press Ctrl+C to shut down.
```

### Step 2: Verify API is Accessible

```powershell
# In a new PowerShell window, test the endpoint
curl https://localhost:7043/api/health -SkipCertificateCheck
# Or check any endpoint
curl https://localhost:7043/api/Auth/profile -SkipCertificateCheck
```

**You should get a response** (even if it's an error)

### Step 3: Rebuild Flutter App

```bash
# In Flutter project directory
flutter clean
flutter pub get
flutter run
```

### Step 4: Test Registration

1. App launches on login screen
2. Click "Register"
3. Fill form:
   - Username: `testuser`
   - Email: `test@example.com`
   - Password: `Test@123456`
   - Confirm: `Test@123456`
4. Click "Register"

**Expected:**
- Loading spinner appears
- Wait 2-5 seconds
- Either:
  - ✅ Success → Redirects to login
  - ❌ Error message with details

### Step 5: If Still Timing Out

**Check these:**

1. **Is backend terminal still showing "listening"?**
   - If not, backend crashed
   - Check error messages in backend terminal

2. **Can you manually access the API?**
   ```powershell
   curl https://localhost:7043/api -SkipCertificateCheck
   ```
   - If this times out → Backend not responding

3. **Is SQL Server running?**
   - Check Services: `Services.msc`
   - Look for `MSSQL$SQLEXPRESS`
   - Should be "Running"

4. **Check Windows Firewall**
   - Make sure port 7043 is not blocked
   - Try: `netstat -ano | findstr :7043`

---

## 📋 Common Causes & Solutions

| Cause | Check | Solution |
|-------|-------|----------|
| Backend not running | Terminal shows "listening"? | Run `dotnet run` in API folder |
| Database offline | SQL Server service running? | Start MSSQLSERVER service |
| Port mismatch | Config shows 7043? | Update api_config.dart or launchSettings.json |
| Firewall blocked | Can ping localhost:7043? | Disable firewall or add exception |
| SSL certificate | Certificate valid? | Using SSL bypass in dev (MyHttpOverrides) |
| Network isolated | Android device on same network? | For device, use IP address not localhost |

---

## 🎯 Configuration Summary

### For Local Development (Emulator)
```dart
// api_config.dart
static const String baseUrl = 'https://localhost:7043/api';
```

### For Physical Device (Same Network)
```dart
// api_config.dart
static const String baseUrl = 'https://192.168.1.8:7043/api';
// Replace 192.168.1.8 with your PC's IP on local network
```

### Find Your PC's IP Address
```powershell
ipconfig
# Look for "IPv4 Address: 192.168.x.x"
```

---

## 🔄 Step-by-Step Recovery

### Quick Fix (5 minutes)
1. Open PowerShell in `Hotel_API` folder
2. Run: `dotnet run`
3. Wait for "Application started" message
4. In Flutter app, click "Register"
5. If still timeout, continue to detailed diagnostics

### Detailed Diagnostics (15 minutes)
1. Stop backend (`Ctrl+C` in terminal)
2. Check SQL Server is running
3. Open `Hotel_API` in Visual Studio
4. Press `F5` to start with debugger
5. Try again in Flutter app
6. Check Visual Studio console for errors

### Full Recovery (30 minutes)
1. Restart SQL Server service
2. Rebuild Hotel_API project in Visual Studio
3. Run migrations if needed: `dotnet ef database update`
4. Start backend with debugger
5. Restart Flutter app: `flutter run`
6. Test registration flow

---

## ✅ Success Indicators

You'll know it's working when:
- ✅ Backend terminal shows "Application started"
- ✅ Manual API test returns response (even error 401 is OK)
- ✅ Flutter app shows loading spinner for 2-3 seconds
- ✅ Either registration success OR specific error message
- ✅ NOT the generic "Timeout" error

---

## 📞 If Still Not Working

### Check Backend Logs

In Visual Studio, look at **Debug Output** for errors like:
- `DbContext error` → Database issue
- `Connection string error` → Config issue
- `Port already in use` → Another app using port 7043
- `SSL certificate error` → Certificate issue

### Check Flutter Logs

```bash
# In Flutter terminal, press 'l' for logs
# Look for specific error messages
# Screenshot the error message
```

### Check System Resources

```powershell
# Check if port 7043 is in use
netstat -ano | findstr :7043

# Check SQL Server connection
sqlcmd -S localhost\SQLEXPRESS
```

---

## 🎓 Understanding the Timeline

1. **App launches** → Shows login screen
2. **User clicks Register** → Loading spinner starts
3. **App prepares request** → Data validated
4. **App connects to backend** → Socket connection established ✅
5. **App sends HTTP request** → Request sent to backend
6. **Backend processes request** → Should take <5 seconds
7. **Backend sends response** → App receives and processes
8. **App shows result** → Success or error message

**Timeout occurs at Step 6** → Backend not responding

---

## 📄 Current Configuration

**File**: `lib/services/api_config.dart`
```dart
// For LOCAL (Emulator/Localhost)
static const String baseUrl = 'https://localhost:7043/api';

// For NETWORK (Physical Device)
// static const String baseUrl = 'https://192.168.1.8:7043/api';
```

**Backend URL** (to test in browser):
```
https://localhost:7043
```

**API Endpoint** (to test registration):
```
POST https://localhost:7043/api/Auth/register
```

---

## 🎯 Next Actions

1. **Immediately**: Start backend API (`dotnet run`)
2. **Wait for**: "Application started" message
3. **Test**: Manual API call with curl
4. **Retry**: Flutter app registration
5. **Report**: If still failing with different error

**Expected result**: Either success message OR specific error (not timeout)

---

**Last Updated**: Today
**Status**: Configuration corrected, awaiting backend start
**Next Step**: Start Hotel_API backend service
