# PSG Mess Token System (Token_system)

Digital meal token management system built with **Flutter**, **Firebase Authentication**, **Cloud Firestore**, and **Cloudinary**. Designed for hostel students, mess managers, service staff, and superuser administrators.

---

## 🏗 System Architecture & Technical Flow

```
   ┌─────────────────────────────────────────────────────────┐
   │                     Flutter Client                      │
   │  (Riverpod State Management, Material 3 Dark Theme)     │
   └─────────────┬─────────────────────────────┬─────────────┘
                 │                             │
                 ▼                             ▼
   ┌───────────────────────────┐  ┌───────────────────────────┐
   │   Firebase Authentication │  │      Cloud Firestore      │
   │ (Email/Password & Sessions)│  │ (Admins, Managers, Staff, │
   └───────────────────────────┘  │  Students & Token Counts) │
                                  └─────────────┬─────────────┘
                                                │
                                                ▼
                                  ┌───────────────────────────┐
                                  │   Cloudinary Media REST   │
                                  │ (Profile Picture Storage) │
                                  └───────────────────────────┘
```

---

## 🔑 Key Features & Role-Based Workflows

> [!NOTE]
> For complete step-by-step role guides, permissions matrix, and day-to-day workflows, see the dedicated [**WORKFLOW.md**](file:///e:/Token_system/WORKFLOW.md) document.

### Multi-Role System Overview

* **Student (Prefix: `S` or `2`)**:
  * Books meal tokens (Veg, Non-Veg, Egg batches).
  * Displays digital QR passes at mess counters.
  * Views categorized purchase receipts & transaction history.
* **Staff / Employee (Prefix: `E`)**:
  * Uses live camera scanner terminal to scan student QR codes.
  * Performs real-time atomic token validation and wallet deductions.
* **Manager (Prefix: `M`)**:
  * Sets daily Veg & Non-Veg token pool quotas.
  * Views real-time dining statistics dashboard.
  * Provisions and deletes Student & Staff accounts.
* **Admin (Prefix: `A`)**:
  * Master superuser console with system-wide analytics.
  * Full account provisioning (Student, Staff, Manager, Admin).
  * Deletes accounts across all non-admin roles.

---

## 🍽 Business Logic & Token System Rules

### 1. Token Generation & Categories
* **Vegetarian Meal Pass (`Veg`)**:
  * Single meal pass per dining session (max 1 active pass in student wallet: `veg = 1`).
  * Constrained by Manager daily pool quota (`Tokens/Counts.veg > 0`).
  * Booking decrements pool quota by 1 and increments `veg_purchased` by 1.
* **Non-Vegetarian Meal Pass (`Non-Veg`)**:
  * Single meal pass per dining session (max 1 active pass in student wallet: `non-veg = 1`).
  * **Schedule Restriction**: Served **exclusively on Sundays, Wednesdays, and Fridays** (`MealDateUtils.isNonVegAvailable()`).
  * Constrained by Manager daily pool quota (`Tokens/Counts.non-veg > 0`).
  * Booking decrements pool quota by 1 and increments `non-veg_purchased` by 1.
* **Egg Tokens (`Eggs`)**:
  * Purchased in **batches of 15 eggs** ($\pm 15$ stepper).
  * **Exempt from Manager pool quotas**; cumulative balance accumulation (`current.eggs + selection.eggCount`).
  * Flexible redemption: Student selects desired egg quantity (1 to available balance) when generating redemption QR code.

### 2. Validations & Atomic Transaction Safety
* **Purchase Pre-Validations**:
  * Duplicate Booking: Throws `alreadyUsed` error if student already holds active Veg or Non-Veg token.
  * Quota Depletion: Throws `soldOut` error if Manager pool quota is 0.
  * Schedule Check: Throws `alreadyUsed` error if Non-Veg booking is attempted on non-scheduled days.
* **Atomic Firestore Transactions**:
  * All token purchases (`purchaseTokens`) and redemptions (`redeemToken`) execute inside `FirebaseFirestore.instance.runTransaction` to guarantee zero race conditions and prevent double redemptions.
* **24-Hour Automated Quota Reset**:
  * Scheduled Cloud Function (`resetVegNonvegFields`) resets `veg` and `nonveg` pool counts in `Tokens/Counts` back to `0` every 24 hours.

### 3. Purpose of Date of Joining (DOJ) & Date of Birth (DOB)
* **Date of Joining (DOJ)**:
  * Collected during account creation (`CreateUserScreen`) for Students and Staff.
  * Defaults to current date (`dd-MM-yyyy`). Stored under field `doj` (`AppConstants.fieldDoj`).
  * Displayed on `ProfileScreen` as hostel tenure and joining metadata.
* **Date of Birth (DOB)**:
  * Collected during account creation (`CreateUserScreen`) for Students and Staff.
  * Defaults to `'01-01-2000'` (Student) and `'01-01-1990'` (Staff). Stored under field `dob` (`AppConstants.fieldDob`).
  * Serves as official demographic identity verification metadata in Firestore profiles.

---

## 🆔 Auto-Generated User IDs & Password Policy

- **Auto-Incrementing User ID Logic**:
  - When creating an account, the system queries the target Firestore collection, extracts existing numeric indices, and generates the next ID automatically:
    - **Student**: `M101`, `M102`, `M103`...
    - **Staff / Employee**: `E101`, `E102`...
    - **Manager**: `M101`, `M102`...
    - **Admin**: `A101`, `A102`...
  - User ID input is **read-only** to prevent manual duplicate entries.
- **Default Password Standard**:
  - All newly created accounts receive the default password: **`Password@1234`**
  - Upon successful registration, an administrator modal popup presents the generated User ID and Default Password with a one-tap **Copy Credentials** option.

---

## 🐍 Python Firebase Initialization Script

A standalone Python script [`init_firebase.py`](file:///e:/Token_system/init_firebase.py) is provided to initialize your Firebase Auth and Cloud Firestore instance with sample documents for all collections (`Admins`, `Managers`, `Employees`, `Students`, `Tokens`).

### Instructions to Run:
1. Install `firebase-admin`:
   ```bash
   pip install firebase-admin
   ```
2. Download your Service Account JSON key from Firebase Console (*Project Settings > Service accounts > Generate new private key*). Save it as `serviceAccountKey.json` in the root directory.
3. Run the script:
   ```bash
   python init_firebase.py
   ```

---

## 🖼 Profile & Cloudinary Circular Crop Avatar Management

- Dedicated **Profile** (`/profile`) and **Edit Profile** (`/profile/edit`) screens.
- **Interactive Circular Crop**:
  - Image selection via `image_picker`.
  - Interactive circular crop frame via `image_cropper` (`CropStyle.circle` & 1:1 aspect ratio) allowing users to scale and position their avatar image cleanly before saving.
- **Cloudinary Integration**:
  - Direct REST API upload to `https://api.cloudinary.com/v1_1/<cloud_name>/image/upload` using an Unsigned Upload Preset (`psg_token_preset`).
  - Cloudinary `secure_url` is saved in the user's Firestore document (`photoUrl`) and displayed as a circular avatar across the application.

---

## 🗄 Cloud Firestore Schema Structure

```
Cloud Firestore
├── Admins (Collection)
│   └── A01 (Document) -> { uid, name, email, department, role, createdAt, photoUrl }
├── Managers (Collection)
│   └── M101 (Document) -> { uid, name, email, department, role, createdAt, photoUrl }
├── Employees (Collection)
│   └── E101 (Document) -> { uid, name, email, department, dob, doj, role, createdAt, photoUrl }
├── Students (Collection)
│   └── M102 (Document) -> { uid, name, email, course, department, dob, doj, veg: 0, non-veg: 0, eggs: 0, photoUrl }
└── Tokens (Collection)
    └── Counts (Document) -> { veg: 150, non-veg: 100, veg_purchased: 45, non-veg_purchased: 30 }
```

---

## 📋 Required Configuration Changes

> [!IMPORTANT]
> The section below outlines all manual configuration steps required to connect your Firebase and Cloudinary environments.

### 1. Firebase Project Setup
- **Firebase Console**: Ensure project `mess-tokens` (or your project) is active.
- **Firebase Authentication**:
  - Enable the **Email/Password** provider under *Authentication > Sign-in method*.
  - (Synthetic emails of format `id@psgtoken.com` are automatically assigned during account creation).
- **Google Services Files**:
  - **Android**: Ensure `android/app/google-services.json` contains your Firebase app configuration.
  - **iOS**: Ensure `ios/Runner/GoogleService-Info.plist` is linked to your Xcode runner.

### 2. Cloudinary Setup
- Log in to your [Cloudinary Dashboard](https://cloudinary.com/).
- Retrieve your **Cloud Name**, **API Key**, and **API Secret** (or configure an **Unsigned Upload Preset**).
- Update `lib/core/constants/app_constants.dart`:
  ```dart
  static const String cloudinaryCloudName = 'YOUR_CLOUD_NAME';
  static const String cloudinaryApiKey = 'YOUR_API_KEY';       // For Signed Uploads
  static const String cloudinaryApiSecret = 'YOUR_API_SECRET'; // For Signed Uploads
  static const String cloudinaryUploadPreset = 'mess_tokens_preset'; // Unsigned fallback
  ```

### 3. Firestore Security Rules
Copy and apply the following Firestore rules in Firebase Console:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {

    match /Admins/{id} {
      allow read, write: if request.auth != null;
    }

    match /Managers/{id} {
      allow read, write: if request.auth != null;
    }

    match /Employees/{id} {
      allow read, write: if request.auth != null;
    }

    match /Students/{id} {
      allow read, write: if request.auth != null;
    }

    match /Tokens/{id} {
      allow read, write: if request.auth != null;
    }

    match /Purchases/{id} {
      allow read, write: if request.auth != null;
    }
  }
}
```

### 4. Required Dependencies
Already added in `pubspec.yaml`:
- `firebase_core: ^3.6.0`
- `cloud_firestore: ^5.4.3`
- `firebase_auth: ^5.3.1`
- `image_picker: ^1.1.2`
- `image_cropper: ^8.0.2`
- `flutter_riverpod: ^2.5.1`
- `http: ^1.1.0`

### 5. Running Commands
To run the app locally:
```bash
flutter pub get
flutter run
```

