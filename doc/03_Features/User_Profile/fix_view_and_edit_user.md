# 📋 API Update Report & Migration Guide
## Profile Endpoint Refactoring (v2.0)

**Date**: November 26, 2025  
**Project**: Hotel_API v2  
**Audience**: Flutter Development Team  
**Status**: ✅ READY FOR MIGRATION  

---

## Executive Summary

The backend has completed a **major refactoring** of the User Profile API. Previously, "User Basic Info" and "Health Profile Info" were mixed in a single endpoint, causing data conflicts and maintenance issues.

**Result**: Two independent, decoupled endpoints with clear responsibilities:
- **`/api/userprofile/basic`** → User Account & Identity Info
- **`/api/userprofile/health`** → Medical History & Body Metrics

This separation improves **data integrity**, **performance**, and **maintainability**.

---

## 🔄 What Changed: Separation of Concerns

### Before Refactoring ❌
```
Single Monolithic Endpoint
↓
/api/userprofile/profile (Mixed Logic)
├─ Update User Account (Name, Avatar, Phone)
├─ Update Health Info (Height, Weight, Diseases)
├─ Auto-sync data between AspNetUsers & HealthProfiles
└─ Risk: Partial updates could corrupt both tables
```

### After Refactoring ✅
```
Two Independent Endpoints (Decoupled)
├─ /api/userprofile/basic (AspNetUsers Only)
│  ├─ GET: Fetch user account info
│  ├─ PUT: Update account-related fields
│  └─ Source: AspNetUsers table
│
└─ /api/userprofile/health (HealthProfiles Only)
   ├─ GET: Fetch health/medical info
   ├─ PUT: Update health-related fields
   └─ Source: HealthProfiles table
```

---

## 📊 Data Structure Analysis

### UserBasicDto (`/api/userprofile/basic`)

**Purpose**: Account & Identity Information  
**Source Table**: `AspNetUsers`  
**Use Case**: Login screens, profile settings, account management

```json
{
  "id": "728b7060-5a5c-4e25-a034-24cfde225029",
  "userName": "ngocphuc",
  "phoneNumber": "0999999999",
  "gender": "Nam",
  "age": null,
  "profilePicture": ""
}
```

**Field Details**:
| Field | Type | Notes |
|-------|------|-------|
| `id` | string | User ID (Primary Key) |
| `userName` | string | Account username |
| `phoneNumber` | string | Contact phone (editable) |
| `gender` | string | Account gender preference (⚠️ May be null) |
| `age` | int? | **Nullable** - Not stored in AspNetUsers table |
| `profilePicture` | string | Avatar URL |

**⚠️ Important Note on `age` in UserBasicDto**:
- This endpoint returns `age: null` because age is **NOT** stored in the `AspNetUsers` table
- Age is calculated/stored only in the `HealthProfiles` table
- If you need age, use the **HealthProfileDto** endpoint instead

---

### HealthProfileDto (`/api/userprofile/health`)

**Purpose**: Medical History & Body Metrics  
**Source Table**: `HealthProfiles`  
**Use Case**: Medical records, health dashboard, diagnostic features

```json
{
  "id": "82b24b70-6537-4a42-b279-6cd3fb096ce6",
  "dateOfBirth": "2004-02-11T00:00:00",
  "bloodType": "O+",
  "emergencyContactName": "",
  "emergencyContactPhone": "",
  "hasDiabetes": true,
  "hasHypertension": false,
  "hasAsthma": false,
  "hasHeartDisease": false,
  "foodAllergies": "",
  "age": 22,
  "height": 180,
  "weight": 75,
  "gender": "",
  "otherDiseases": ""
}
```

**Field Details**:
| Field | Type | Notes |
|-------|------|-------|
| `id` | string | Health Profile ID |
| `dateOfBirth` | DateTime | Used to calculate age |
| `bloodType` | string | Blood type (A+, O-, etc.) |
| `emergencyContactName` | string | Emergency contact name |
| `emergencyContactPhone` | string | Emergency contact phone |
| `hasDiabetes` | bool | Medical condition flag |
| `hasHypertension` | bool | Medical condition flag |
| `hasAsthma` | bool | Medical condition flag |
| `hasHeartDisease` | bool | Medical condition flag |
| `foodAllergies` | string | Comma-separated allergies |
| **`age`** | **int** | **Auto-calculated from DateOfBirth** ✅ |
| `height` | float | Height in cm |
| `weight` | float | Weight in kg |
| `gender` | string | Medical gender record |
| `otherDiseases` | string | Additional diseases/conditions |

**✅ Important Note on `age` in HealthProfileDto**:
- This field is **auto-calculated** from `dateOfBirth`
- Always contains a numeric value (e.g., 22)
- **This is the authoritative source** for user age
- Automatically updated when `dateOfBirth` changes

---

## 🎯 Key Differences: Gender & Age Fields

### Field: `gender`

| Context | Endpoint | Field | Meaning |
|---------|----------|-------|---------|
| **Account** | `/api/userprofile/basic` | `gender` | User preference for display/account |
| **Medical** | `/api/userprofile/health` | `gender` | Medical/biological gender record |

**Implication**:
- These are independent fields
- A user can have different values in both (e.g., account gender = "Nam", medical gender = "Nu")
- Update each separately via their respective endpoints

### Field: `age`

| Context | Endpoint | Field | Type | Behavior |
|---------|----------|-------|------|----------|
| **Account** | `/api/userprofile/basic` | `age` | `int?` | **Nullable** (may be null) |
| **Medical** | `/api/userprofile/health` | `age` | `int` | **Auto-calculated** from DOB |

**Implication**:
- Never rely on age from `/api/userprofile/basic` - use `/api/userprofile/health` instead
- Age in health profile is always current (auto-updated annually)
- Do not manually set age - it's calculated from `dateOfBirth`

---

## 🚀 Flutter Implementation Guide

### Step 1: Create Two Separate Dart Models

#### Model 1: UserBasicModel
```dart
// lib/models/user_basic_model.dart

class UserBasicModel {
  final String id;
  final String userName;
  final String phoneNumber;
  final String gender;
  final int? age; // ⚠️ Nullable - will be null in this endpoint
  final String profilePicture;

  UserBasicModel({
    required this.id,
    required this.userName,
    required this.phoneNumber,
    required this.gender,
    this.age,
    required this.profilePicture,
  });

  factory UserBasicModel.fromJson(Map<String, dynamic> json) {
    return UserBasicModel(
      id: json['id'] ?? '',
      userName: json['userName'] ?? '',
      phoneNumber: json['phoneNumber'] ?? '',
      gender: json['gender'] ?? '',
      age: json['age'], // Will be null from this endpoint
      profilePicture: json['profilePicture'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userName': userName,
      'phoneNumber': phoneNumber,
      'gender': gender,
      'age': age,
      'profilePicture': profilePicture,
    };
  }
}
```

#### Model 2: HealthProfileModel
```dart
// lib/models/health_profile_model.dart

class HealthProfileModel {
  final String id;
  final DateTime? dateOfBirth;
  final String bloodType;
  final String emergencyContactName;
  final String emergencyContactPhone;
  final bool hasDiabetes;
  final bool hasHypertension;
  final bool hasAsthma;
  final bool hasHeartDisease;
  final String foodAllergies;
  final int age; // ✅ Always populated (auto-calculated)
  final double? height;
  final double? weight;
  final String gender;
  final String otherDiseases;

  HealthProfileModel({
    required this.id,
    this.dateOfBirth,
    required this.bloodType,
    required this.emergencyContactName,
    required this.emergencyContactPhone,
    required this.hasDiabetes,
    required this.hasHypertension,
    required this.hasAsthma,
    required this.hasHeartDisease,
    required this.foodAllergies,
    required this.age,
    this.height,
    this.weight,
    required this.gender,
    required this.otherDiseases,
  });

  factory HealthProfileModel.fromJson(Map<String, dynamic> json) {
    return HealthProfileModel(
      id: json['id'] ?? '',
      dateOfBirth: json['dateOfBirth'] != null
          ? DateTime.parse(json['dateOfBirth'])
          : null,
      bloodType: json['bloodType'] ?? '',
      emergencyContactName: json['emergencyContactName'] ?? '',
      emergencyContactPhone: json['emergencyContactPhone'] ?? '',
      hasDiabetes: json['hasDiabetes'] ?? false,
      hasHypertension: json['hasHypertension'] ?? false,
      hasAsthma: json['hasAsthma'] ?? false,
      hasHeartDisease: json['hasHeartDisease'] ?? false,
      foodAllergies: json['foodAllergies'] ?? '',
      age: json['age'] ?? 0, // Auto-calculated from backend
      height: json['height']?.toDouble(),
      weight: json['weight']?.toDouble(),
      gender: json['gender'] ?? '',
      otherDiseases: json['otherDiseases'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'dateOfBirth': dateOfBirth?.toIso8601String(),
      'bloodType': bloodType,
      'emergencyContactName': emergencyContactName,
      'emergencyContactPhone': emergencyContactPhone,
      'hasDiabetes': hasDiabetes,
      'hasHypertension': hasHypertension,
      'hasAsthma': hasAsthma,
      'hasHeartDisease': hasHeartDisease,
      'foodAllergies': foodAllergies,
      'age': age,
      'height': height,
      'weight': weight,
      'gender': gender,
      'otherDiseases': otherDiseases,
    };
  }
}
```

---

### Step 2: Update Service Layer (API Calls)

#### UserService Updates
```dart
// lib/services/user_service.dart

class UserService {
  final ApiService apiService;

  UserService(this.apiService);

  /// Fetch user basic info (Account & Identity)
  Future<UserBasicModel> getBasicProfile(String userId) async {
    try {
      final response = await apiService.get(
        '/api/userprofile/basic',
        headers: {'Authorization': 'Bearer ${await getToken()}'},
      );
      
      return UserBasicModel.fromJson(response.data);
    } catch (e) {
      print('[UserService] Error fetching basic profile: $e');
      rethrow;
    }
  }

  /// Update user basic info (Account & Identity)
  Future<UserBasicModel> updateBasicProfile(Map<String, dynamic> data) async {
    try {
      final response = await apiService.put(
        '/api/userprofile/basic',
        data: data,
        headers: {'Authorization': 'Bearer ${await getToken()}'},
      );
      
      return UserBasicModel.fromJson(response.data);
    } catch (e) {
      print('[UserService] Error updating basic profile: $e');
      rethrow;
    }
  }

  /// Fetch health profile (Medical & Body Metrics)
  Future<HealthProfileModel> getHealthProfile(String userId) async {
    try {
      final response = await apiService.get(
        '/api/userprofile/health',
        headers: {'Authorization': 'Bearer ${await getToken()}'},
      );
      
      return HealthProfileModel.fromJson(response.data);
    } catch (e) {
      print('[UserService] Error fetching health profile: $e');
      rethrow;
    }
  }

  /// Update health profile (Medical & Body Metrics)
  Future<HealthProfileModel> updateHealthProfile(Map<String, dynamic> data) async {
    try {
      final response = await apiService.put(
        '/api/userprofile/health',
        data: data,
        headers: {'Authorization': 'Bearer ${await getToken()}'},
      );
      
      return HealthProfileModel.fromJson(response.data);
    } catch (e) {
      print('[UserService] Error updating health profile: $e');
      rethrow;
    }
  }
}
```

---

### Step 3: Update UI Screens

#### Screen 1: Account Settings (Uses Basic Profile)
```dart
// lib/screens/account_settings_screen.dart

class AccountSettingsScreen extends StatefulWidget {
  @override
  State<AccountSettingsScreen> createState() => _AccountSettingsScreenState();
}

class _AccountSettingsScreenState extends State<AccountSettingsScreen> {
  late UserBasicModel basicProfile;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadBasicProfile();
  }

  Future<void> _loadBasicProfile() async {
    try {
      final profile = await userService.getBasicProfile(userId);
      setState(() {
        basicProfile = profile;
        isLoading = false;
      });
    } catch (e) {
      // Handle error
    }
  }

  Future<void> _saveBasicProfile() async {
    try {
      final updated = await userService.updateBasicProfile({
        'phoneNumber': phoneController.text,
        'gender': selectedGender,
        // ... other account fields
      });
      
      setState(() => basicProfile = updated);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Account updated successfully')),
      );
    } catch (e) {
      // Handle error
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) return Scaffold(body: Center(child: CircularProgressIndicator()));

    return Scaffold(
      appBar: AppBar(title: Text('Account Settings')),
      body: Column(
        children: [
          TextField(
            controller: phoneController,
            decoration: InputDecoration(labelText: 'Phone Number'),
          ),
          // ... more account fields
          ElevatedButton(
            onPressed: _saveBasicProfile,
            child: Text('Save Account Info'),
          ),
        ],
      ),
    );
  }
}
```

#### Screen 2: Medical Records (Uses Health Profile)
```dart
// lib/screens/medical_records_screen.dart

class MedicalRecordsScreen extends StatefulWidget {
  @override
  State<MedicalRecordsScreen> createState() => _MedicalRecordsScreenState();
}

class _MedicalRecordsScreenState extends State<MedicalRecordsScreen> {
  late HealthProfileModel healthProfile;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadHealthProfile();
  }

  Future<void> _loadHealthProfile() async {
    try {
      final profile = await userService.getHealthProfile(userId);
      setState(() {
        healthProfile = profile;
        isLoading = false;
      });
    } catch (e) {
      // Handle error
    }
  }

  Future<void> _saveHealthProfile() async {
    try {
      final updated = await userService.updateHealthProfile({
        'dateOfBirth': selectedDOB?.toIso8601String(),
        'bloodType': selectedBloodType,
        'height': heightController.text,
        'weight': weightController.text,
        'hasDiabetes': diabetesSwitch,
        'hasDiabetes': hypertensionSwitch,
        // ... other medical fields
      });
      
      setState(() {
        healthProfile = updated;
        // Note: age will be auto-updated by backend
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Health profile updated successfully')),
      );
    } catch (e) {
      // Handle error
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) return Scaffold(body: Center(child: CircularProgressIndicator()));

    return Scaffold(
      appBar: AppBar(title: Text('Medical Records')),
      body: Column(
        children: [
          // Display age (always populated)
          Text('Age: ${healthProfile.age}'), // ✅ Always has value
          
          TextField(
            controller: heightController,
            decoration: InputDecoration(labelText: 'Height (cm)'),
          ),
          TextField(
            controller: weightController,
            decoration: InputDecoration(labelText: 'Weight (kg)'),
          ),
          
          // Medical condition checkboxes
          CheckboxListTile(
            title: Text('Diabetes'),
            value: healthProfile.hasDiabetes,
            onChanged: (val) => setState(() => healthProfile = healthProfile.copyWith(hasDiabetes: val)),
          ),
          CheckboxListTile(
            title: Text('Hypertension'),
            value: healthProfile.hasHypertension,
            onChanged: (val) => setState(() => healthProfile = healthProfile.copyWith(hasHypertension: val)),
          ),
          
          ElevatedButton(
            onPressed: _saveHealthProfile,
            child: Text('Save Health Info'),
          ),
        ],
      ),
    );
  }
}
```

---

### Step 4: Update Provider/State Management

```dart
// lib/providers/user_provider.dart

class UserProvider with ChangeNotifier {
  UserBasicModel? _basicProfile;
  HealthProfileModel? _healthProfile;

  UserBasicModel? get basicProfile => _basicProfile;
  HealthProfileModel? get healthProfile => _healthProfile;

  /// Fetch both profiles independently
  Future<void> loadAllProfiles(String userId) async {
    try {
      // Load in parallel
      await Future.wait([
        _loadBasicProfile(userId),
        _loadHealthProfile(userId),
      ]);
    } catch (e) {
      print('[UserProvider] Error loading profiles: $e');
    }
  }

  Future<void> _loadBasicProfile(String userId) async {
    try {
      _basicProfile = await _userService.getBasicProfile(userId);
      notifyListeners();
    } catch (e) {
      print('[UserProvider] Error loading basic profile: $e');
      rethrow;
    }
  }

  Future<void> _loadHealthProfile(String userId) async {
    try {
      _healthProfile = await _userService.getHealthProfile(userId);
      notifyListeners();
    } catch (e) {
      print('[UserProvider] Error loading health profile: $e');
      rethrow;
    }
  }

  /// Update basic profile only
  Future<void> updateBasicProfile(Map<String, dynamic> data) async {
    try {
      _basicProfile = await _userService.updateBasicProfile(data);
      notifyListeners();
    } catch (e) {
      print('[UserProvider] Error updating basic profile: $e');
      rethrow;
    }
  }

  /// Update health profile only
  Future<void> updateHealthProfile(Map<String, dynamic> data) async {
    try {
      _healthProfile = await _userService.updateHealthProfile(data);
      notifyListeners();
    } catch (e) {
      print('[UserProvider] Error updating health profile: $e');
      rethrow;
    }
  }

  /// Get age from health profile (authoritative source)
  int? get userAge => _healthProfile?.age;
}
```

---

## ⚠️ Common Migration Pitfalls

### ❌ Pitfall 1: Using `age` from Basic Profile
```dart
// WRONG - age will be null
int age = userBasicProfile.age; // 🚫 null
```

### ✅ Solution 1: Use Health Profile Age
```dart
// CORRECT - age is auto-calculated
int age = healthProfile.age; // ✅ Always has value
```

---

### ❌ Pitfall 2: Mixing Gender Fields
```dart
// WRONG - assuming gender is the same in both profiles
String accountGender = basicProfile.gender;
String medicalGender = healthProfile.gender;
// These can be different!
```

### ✅ Solution 2: Use Correct Gender for Context
```dart
// For account display
String accountGender = basicProfile.gender; // Account preference

// For medical records
String medicalGender = healthProfile.gender; // Medical record
```

---

### ❌ Pitfall 3: Trying to Update Age Manually
```dart
// WRONG - age should never be updated directly
updateHealthProfile({'age': 25}); // 🚫 Ignored by backend
```

### ✅ Solution 3: Update DateOfBirth Instead
```dart
// CORRECT - age auto-calculated from DOB
updateHealthProfile({
  'dateOfBirth': DateTime(1999, 6, 15).toIso8601String(),
  // age will be auto-calculated by backend ✅
});
```

---

## 📈 API Endpoint Summary

### GET Endpoints

| Endpoint | Purpose | Response | Auth Required |
|----------|---------|----------|---|
| `GET /api/userprofile/basic` | Fetch user account info | `UserBasicDto` | ✅ Yes |
| `GET /api/userprofile/health` | Fetch user health info | `HealthProfileDto` | ✅ Yes |

### PUT Endpoints

| Endpoint | Purpose | Request Body | Response | Auth Required |
|----------|---------|---|---|---|
| `PUT /api/userprofile/basic` | Update account info | `UpdateUserBasicDto` | `UserBasicDto` | ✅ Yes |
| `PUT /api/userprofile/health` | Update health info | `UpdateHealthProfileDto` | `HealthProfileDto` | ✅ Yes |

---

## 🔐 Authentication

All endpoints require Bearer token in Authorization header:

```dart
headers: {
  'Authorization': 'Bearer $accessToken',
  'Content-Type': 'application/json',
}
```

---

## 📊 Request/Response Examples

### Example 1: Get Basic Profile

**Request**:
```bash
GET /api/userprofile/basic
Authorization: Bearer eyJhbGc...
```

**Response (200 OK)**:
```json
{
  "id": "728b7060-5a5c-4e25-a034-24cfde225029",
  "userName": "ngocphuc",
  "phoneNumber": "0999999999",
  "gender": "Nam",
  "age": null,
  "profilePicture": ""
}
```

---

### Example 2: Update Basic Profile

**Request**:
```bash
PUT /api/userprofile/basic
Content-Type: application/json
Authorization: Bearer eyJhbGc...

{
  "phoneNumber": "0888888888",
  "gender": "Nam"
}
```

**Response (200 OK)**:
```json
{
  "id": "728b7060-5a5c-4e25-a034-24cfde225029",
  "userName": "ngocphuc",
  "phoneNumber": "0888888888",
  "gender": "Nam",
  "age": null,
  "profilePicture": ""
}
```

---

### Example 3: Get Health Profile

**Request**:
```bash
GET /api/userprofile/health
Authorization: Bearer eyJhbGc...
```

**Response (200 OK)**:
```json
{
  "id": "82b24b70-6537-4a42-b279-6cd3fb096ce6",
  "dateOfBirth": "2004-02-11T00:00:00",
  "bloodType": "O+",
  "emergencyContactName": "",
  "emergencyContactPhone": "",
  "hasDiabetes": true,
  "hasHypertension": false,
  "hasAsthma": false,
  "hasHeartDisease": false,
  "foodAllergies": "",
  "age": 22,
  "height": 180,
  "weight": 75,
  "gender": "",
  "otherDiseases": ""
}
```

---

### Example 4: Update Health Profile

**Request**:
```bash
PUT /api/userprofile/health
Content-Type: application/json
Authorization: Bearer eyJhbGc...

{
  "dateOfBirth": "2004-02-11T00:00:00",
  "height": 182,
  "weight": 78,
  "hasDiabetes": true,
  "bloodType": "O+",
  "foodAllergies": "Shrimp, Peanuts"
}
```

**Response (200 OK)**:
```json
{
  "id": "82b24b70-6537-4a42-b279-6cd3fb096ce6",
  "dateOfBirth": "2004-02-11T00:00:00",
  "bloodType": "O+",
  "emergencyContactName": "",
  "emergencyContactPhone": "",
  "hasDiabetes": true,
  "hasHypertension": false,
  "hasAsthma": false,
  "hasHeartDisease": false,
  "foodAllergies": "Shrimp, Peanuts",
  "age": 22,
  "height": 182,
  "weight": 78,
  "gender": "",
  "otherDiseases": ""
}
```

---

## 🚨 Error Handling

### Possible HTTP Status Codes

| Status | Meaning | Example |
|--------|---------|---------|
| **200 OK** | Request successful | Data returned successfully |
| **400 Bad Request** | Invalid input | `{ "message": "Invalid request body" }` |
| **401 Unauthorized** | Missing/invalid token | No Authorization header |
| **404 Not Found** | Profile doesn't exist | User has no health profile yet |
| **500 Internal Server Error** | Backend error | Database connection failed |

---

## 📋 Migration Checklist for Flutter Team

- [ ] Create `UserBasicModel` class (Dart)
- [ ] Create `HealthProfileModel` class (Dart)
- [ ] Update `UserService` with new endpoints
- [ ] Create/Update `UserProvider` for state management
- [ ] Separate UI screens:
  - [ ] Account Settings Screen (uses `/basic`)
  - [ ] Medical Records Screen (uses `/health`)
- [ ] Update existing profile editing flow
- [ ] Test both endpoints independently
- [ ] Test loading both profiles in parallel
- [ ] Verify age calculation (should come from health profile)
- [ ] Handle null cases for account age
- [ ] Update error handling for each endpoint
- [ ] Integration test with real backend
- [ ] Update API documentation in Flutter project

---

## 🔍 Testing Guide

### Unit Test Example

```dart
// test/services/user_service_test.dart

void main() {
  group('UserService', () {
    late UserService userService;
    late MockApiService mockApiService;

    setUp(() {
      mockApiService = MockApiService();
      userService = UserService(mockApiService);
    });

    test('getBasicProfile returns UserBasicModel', () async {
      // Arrange
      final mockResponse = {
        "id": "123",
        "userName": "testuser",
        "phoneNumber": "0999999999",
        "gender": "Nam",
        "age": null, // ✅ Expect null
        "profilePicture": ""
      };
      when(mockApiService.get('/api/userprofile/basic'))
          .thenAnswer((_) async => mockResponse);

      // Act
      final result = await userService.getBasicProfile('123');

      // Assert
      expect(result.age, isNull); // ✅ Age should be null
      expect(result.userName, equals('testuser'));
    });

    test('getHealthProfile returns HealthProfileModel with calculated age', () async {
      // Arrange
      final mockResponse = {
        "id": "456",
        "dateOfBirth": "2004-02-11T00:00:00",
        "bloodType": "O+",
        "age": 22, // ✅ Age auto-calculated
        "height": 180,
        "weight": 75,
        // ... other fields
      };
      when(mockApiService.get('/api/userprofile/health'))
          .thenAnswer((_) async => mockResponse);

      // Act
      final result = await userService.getHealthProfile('123');

      // Assert
      expect(result.age, equals(22)); // ✅ Age should be populated
      expect(result.height, equals(180));
    });
  });
}
```

---

## 📚 Additional Resources

- Backend Documentation: `IMPLEMENTATION_REPORT.md`
- DTO Optimization Guide: `DTO_OPTIMIZATION_LEAN_API_RESPONSES.md`
- Full API Reference: `API_QUICK_REFERENCE.md`
- Postman Collection: `Hotel_API.postman_collection.json`

---

## 📞 Support & Questions

For questions or issues during migration:
- Check the `#api-support` Slack channel
- Review the API documentation in `/Doc` folder
- Contact: Backend Team (Slack: @backend-team)

---

## ✅ Sign-Off

| Role | Name | Date | Approval |
|------|------|------|----------|
| Backend Lead | DevOps Team | Nov 26, 2025 | ✅ |
| API Architect | Solution Architect | Nov 26, 2025 | ✅ |
| Flutter Lead | Mobile Team | Pending | ⏳ |

---

**Document Version**: 1.0  
**Last Updated**: November 26, 2025  
**Status**: Ready for Flutter Migration
