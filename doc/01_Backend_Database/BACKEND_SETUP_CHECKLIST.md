# Backend Setup & Connectivity Verification Checklist

## BEFORE PROCEEDING TO PHASE 4-5

### Backend API Requirements

- [ ] **Start Hotel_API Service**
  - Location: `d:\Workspace\01 Project\Project Dev\Graduation project\Main Project\Hotel_API`
  - Command: `dotnet run` or run in Visual Studio
  - Expected URL: `https://localhost:7135`
  - Expected output: "Application started. Press Ctrl+C to shut down."

- [ ] **Verify Database Connection**
  - Database: `Hotel_Web` in SQLEXPRESS
  - Check: Can connect via SQL Server Management Studio
  - Connection string in `appsettings.json`: Verify server and database name
  - Sample tables: Users, Posts, Comments, MonAn, BaiThuoc should exist

- [ ] **Check API Endpoints**
  - POST `/api/auth/register` - Should accept username, email, password, age, gender
  - POST `/api/auth/login` - Should accept email and password
  - Expected response: Returns User object and JWT token in Authorization header

### Flutter App Connectivity Testing

#### Step 1: Use Debug Screen
1. Launch Flutter app on Android device
2. Click "Debug" button on Login Screen
3. Verify output shows:
   ```
   Base URL: https://localhost:7135/api
   Host: localhost
   Port: 7043
   Scheme: https
   ```

#### Step 2: Test Registration
1. Click "Register" on Login Screen
2. Fill in form:
   - Username: `testuser001`
   - Email: `test001@example.com`
   - Password: `Test@123456`
   - Confirm Password: `Test@123456`
   - Age: 25 (optional)
   - Gender: Nam (optional)
3. Click "Register" button
4. Expected outcomes:
   - ✅ No error message appears
   - ✅ Redirects to Login Screen (if successful)
   - ✅ Error SnackBar shown (if failed) with specific error

#### Step 3: Test Login
1. On Login Screen, enter:
   - Email: `test001@example.com`
   - Password: `Test@123456`
2. Click "Login" button
3. Expected outcomes:
   - ✅ Loading spinner appears for 2-5 seconds
   - ✅ Navigates to Home Screen (if successful)
   - ✅ Error SnackBar with message (if failed)
   - ✅ Error message should clearly indicate:
     - "No internet connection" → Backend not running
     - "Unauthorized (401)" → Wrong credentials
     - "Not found (404)" → Wrong endpoint URL
     - "Server error (500)" → Backend error

#### Step 4: Test Logout
1. If login successful, on Home Screen click "Logout"
2. Expected:
   - ✅ Navigates back to Login Screen
   - ✅ Token removed from secure storage

### Troubleshooting Guide

#### "No internet connection" Error
**Possible Causes:**
- Backend API not running on https://localhost:7135
- SSL certificate issue (currently bypassed in development)
- Emulator/device cannot access localhost

**Solutions:**
1. Verify `Hotel_API` is running: Check terminal shows "Application started"
2. Check URL in Debug Screen: Should show "https://localhost:7135/api"
3. Try accessing from Windows browser: `https://localhost:7135/api/auth/profile`
4. For Android device: Ensure it's on same network as backend PC

#### "Unauthorized (401)" Error
**Cause:** Wrong email or password

**Solution:** Verify credentials match what was registered

#### "Not found (404)" Error
**Causes:**
- Wrong API URL configuration
- Endpoint doesn't exist in backend
- Path parameters missing

**Solutions:**
1. Check `lib/services/api_config.dart` - Verify endpoints match backend
2. Check backend API structure - Verify endpoints exist
3. Test endpoint in Postman or browser directly

#### "Server error (500)" Error
**Cause:** Backend threw an exception

**Solution:**
1. Check Hotel_API console output for error details
2. Check SQL Server database connection
3. Verify database schema matches expected structure

### Success Indicators

✅ **All Passing When:**
1. Debug Screen shows correct API configuration
2. Registration creates new user in database
3. Login returns JWT token and user data
4. Home Screen displays after login
5. Logout clears token and returns to login
6. Multiple register/login cycles work without errors

### Phase 4-5 Go/No-Go Criteria

**PROCEED TO PHASE 4-5 IF:**
- [x] Code builds successfully (`flutter analyze` passes)
- [x] UI renders correctly (Material 3 design)
- [ ] API connectivity verified (registration and login work)
- [ ] Database connectivity verified
- [ ] JWT token exchange working

**DO NOT PROCEED IF:**
- Backend API not running
- Database connection failing
- API returning unexpected responses
- SSL certificate issues persist

---

## Next Steps

### Immediate (Today)
1. Ensure Hotel_API is running
2. Ensure Hotel_Web database is accessible
3. Run Flutter app and test with Debug Screen
4. Attempt registration and login
5. Report any errors with full error messages

### Phase 4: Posts API Services (After Connectivity Verified)
- Create PostService with:
  - `getPosts(page, pageSize)` - Get paginated posts
  - `getPost(id)` - Get single post details
  - `createPost(title, content, images)` - Create new post
  - `updatePost(id, title, content)` - Update existing post
  - `deletePost(id)` - Delete post
  - `likePost(id)` - Like/unlike post
  - `getComments(postId, page)` - Get post comments

### Phase 5: Posts Feed UI (After PostService Tested)
- Create HomeScreen with:
  - BottomNavigationBar (Feed, Profile, Settings)
  - PostListScreen with infinite scroll
  - Pull-to-refresh functionality
  - Like button with visual feedback
  - Comment section
  - Share functionality

---

**Current Status**: ⏳ Awaiting Backend Connectivity Test
**Blocker**: Backend API must be running on https://localhost:7135
**Time to Resolution**: ~5 minutes (start backend + test login)
