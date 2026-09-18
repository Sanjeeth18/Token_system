# PSG Mess Token System — Comprehensive Business Logic & Workflows

This document provides a detailed, end-to-end reference for the **business logic, token-generation pipeline, validation rules, user roles, and operational workflows** of the PSG Mess Token System.

---

## 1. System Business Logic Overview

The PSG Mess Token System manages digital hostel dining passes for students while providing mess managers and staff with real-time controls and redemption verification.

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                           CENTRAL FIRESTORE DB                              │
├──────────────────┬──────────────────┬──────────────────┬────────────────────┤
│ Tokens/Counts    │ Students/{roll}  │ Purchases        │ Users (By Role)    │
│ (Daily Pools)    │ (Token Wallet)   │ (Audit Logs)     │ (Auth & Roles)     │
└────────┬─────────┴────────┬─────────┴────────┬─────────┴──────────┬─────────┘
         │                  │                  │                    │
         ▼                  ▼                  ▼                    ▼
┌──────────────────┐┌──────────────────┐┌──────────────────┐┌──────────────────┐
│ Manager Pool     ││ Student Wallet   ││ Transaction      ││ Role Permissions │
│ Quotas (Veg/NV)  ││ (Veg, Non-Veg,   ││ History Audit    ││ (Admin, Manager, │
│ & 24h Cron Reset ││  Cumulative Eggs)││ Log Stream       ││  Staff, Student) │
└──────────────────┘└──────────────────┘└──────────────────┘└──────────────────┘
```

---

## 2. Complete End-to-End Token Generation & Redemption Flow

The complete lifecycle of a token proceeds through six main phases:

```
[Phase 1: User Selection] ──► [Phase 2: System Validation] ──► [Phase 3: Token Generation & Transaction]
                                                                          │
                                                                          ▼
[Phase 6: Final Status] ◄── [Phase 5: Counter Scan] ◄── [Phase 4: Audit Log & Wallet Sync]
```

### Phase 1: User Selection
* The student logs into the app and opens the **Book Meal** tab on `StudentHomeScreen`.
* The application computes the target dining date (`MealDateUtils.nextMealDate()`) and checks Non-Veg schedule eligibility (`MealDateUtils.isNonVegAvailable()`).
* The student selects desired items:
  * Toggles **Veg Meal** pass.
  * Toggles **Non-Veg Meal** pass (active only on Sun, Wed, Fri).
  * Adjusts **Egg Tokens** quantity using `+` / `-` stepper buttons (in batches of 15).

### Phase 2: System Validation
Before submitting to Firestore, the system performs pre-validations:
1. **Selection Check**: `selection.hasSelection` must be `true` (at least 1 item chosen).
2. **Veg Validation**:
   * Cannot book if `studentTokens.veg > 0` $\rightarrow$ Throws `alreadyUsed: "Veg token already purchased."`
   * Cannot book if `counts.veg <= 0` $\rightarrow$ Throws `soldOut: "Veg tokens are sold out."`
3. **Non-Veg Validation**:
   * Cannot book if today is not a scheduled Non-Veg day $\rightarrow$ Throws `alreadyUsed: "Non-Veg meal is not served on this dining schedule."`
   * Cannot book if `studentTokens.nonVeg > 0` $\rightarrow$ Throws `alreadyUsed: "Non-Veg token already purchased."`
   * Cannot book if `counts.nonVeg <= 0` $\rightarrow$ Throws `soldOut: "Non-Veg tokens are sold out."`
4. **Egg Validation**:
   * Eggs are bought in steps of 15; not restricted by daily manager pool quotas.

### Phase 3: Token Generation & Database Update
Upon tapping **Confirm & Book Tokens**, `FirestoreRepository.instance.purchaseTokens()` executes an atomic `runTransaction`:
* Reads `Students/{rollNumber}` and `Tokens/Counts` documents inside the transaction.
* Re-evaluates all validations atomically to avoid race conditions.
* Decrements available pool counts in `Tokens/Counts`:
  * `veg` $\rightarrow$ `FieldValue.increment(-1)`
  * `veg_purchased` $\rightarrow$ `FieldValue.increment(1)`
  * `non-veg` $\rightarrow$ `FieldValue.increment(-1)`
  * `non-veg_purchased` $\rightarrow$ `FieldValue.increment(1)`
* Updates student token balances in `Students/{rollNumber}`:
  * `veg` $\rightarrow$ `1`
  * `non-veg` $\rightarrow$ `1`
  * `eggs` $\rightarrow$ `current.eggs + selection.eggCount` (cumulative addition)

### Phase 4: Audit Logging & Wallet Sync
* Creates individual receipt records in the `Purchases` collection:
  ```json
  {
    "rollNumber": "S001",
    "category": "veg" | "nonveg" | "egg",
    "count": 1 | 15,
    "date": "18-09-2026",
    "time": "08:30 PM",
    "timestamp": "SERVER_TIMESTAMP"
  }
  ```
* Updates Riverpod providers (`studentTokensProvider`), resets selection state, and switches UI to **My Tokens** wallet tab.

### Phase 5: Counter Scan & Verification
* Student presents token pass QR code (`<RollNumber> <Type> <Count>`) on `QrDisplayScreen`.
* Staff/Employee scans QR pass code using camera scanner terminal (`ScannerScreen`).
* `FirestoreRepository.instance.redeemToken(qrData)` executes an atomic transaction:
  * Verifies student exists in `Students` collection.
  * Validates student has sufficient active tokens (`current[type] >= count`).
  * Decrements student balance in `Students/{rollNumber}` (`newBalance = (current[type] - count).clamp(0, current[type])`).

### Phase 6: Final Token Status
* **Veg / Non-Veg**: Balance returns to `0`, releasing the slot for subsequent dining session bookings.
* **Eggs**: Decremented by redeemed quantity; remaining egg balance stays active in wallet.

---

## 3. Dedicated Workflows by Token Type

```
                      ┌─────────────────────────────────────────┐
                      │            TOKEN CATEGORIES             │
                      └────────────────────┬────────────────────┘
                                           │
         ┌─────────────────────────────────┼─────────────────────────────────┐
         ▼                                 ▼                                 ▼
┌──────────────────┐              ┌──────────────────┐              ┌──────────────────┐
│ VEG TOKEN        │              │ NON-VEG TOKEN    │              │ EGG TOKENS       │
├──────────────────┤              ├──────────────────┤              ├──────────────────┤
│ • Daily Pool     │              │ • Sun, Wed, Fri  │              │ • Batches of 15  │
│ • Single Pass    │              │ • Daily Pool     │              │ • Cumulative     │
│ • Quota Limit    │              │ • Single Pass    │              │ • No Pool Limit  │
└──────────────────┘              └──────────────────┘              └──────────────────┘
```

### 🥦 Vegetarian Meal Token Workflow
1. **Availability**: Served daily based on Manager quota (`Tokens/Counts.veg > 0`).
2. **Quota Handling**: Decrements manager Veg pool by 1 and increments `veg_purchased` by 1 upon purchase.
3. **Wallet Holding**: Maximum 1 active Veg token per student at a time.
4. **QR Generation**: Produces QR payload `${rollNumber} Veg 1`.
5. **Redemption**: Staff scan decrements `Students/{rollNumber}.veg` from `1` to `0`.

---

### 🍗 Non-Vegetarian Meal Token Workflow
1. **Schedule Restriction**: Available **only on Sundays, Wednesdays, and Fridays**. Evaluated via `MealDateUtils.isNonVegAvailable(nextMealDate)`.
2. **Availability**: Requires Non-Veg Manager pool quota `Tokens/Counts.non-veg > 0`.
3. **Quota Handling**: Decrements manager Non-Veg pool by 1 and increments `non-veg_purchased` by 1 upon purchase.
4. **Wallet Holding**: Maximum 1 active Non-Veg token per student at a time.
5. **QR Generation**: Produces QR payload `${rollNumber} Non-Veg 1`.
6. **Redemption**: Staff scan decrements `Students/{rollNumber}.non-veg` from `1` to `0`.

---

### 🥚 Egg Tokens Workflow
1. **Batch Purchase**: Added in multiples of 15 (15, 30, 45...). Stepper increases/decreases quantity by $\pm 15$.
2. **Quota Exemption**: Independent of manager pool quotas; direct balance accumulation.
3. **Cumulative Wallet Balance**: Newly purchased eggs are added to existing balance (`newEggs = current.eggs + selection.eggCount`).
4. **Flexible Redemption**:
   * Student selects specific quantity to redeem (1 to available balance) on `QrDisplayScreen`.
   * Produces QR payload `${rollNumber} Eggs ${selectedQuantity}`.
5. **Redemption**: Staff scan decrements `Students/{rollNumber}.eggs` by `${selectedQuantity}`. Unused eggs remain active in wallet indefinitely.

---

## 4. Role of Date of Joining (DOJ) & Date of Birth (DOB)

| Field | Collected On | Default Fallback | Storage Field | Primary Purpose & Usage |
| :--- | :--- | :--- | :--- | :--- |
| **Date of Joining (DOJ)** | Account creation (`CreateUserScreen`) for Students & Staff | Current date (`dd-MM-yyyy`) | `doj` (`AppConstants.fieldDoj`) | • Tracks joining date and hostel tenure.<br>• Displayed on `ProfileScreen` under Account Information with green calendar icon.<br>• Maintained in Firestore user profiles for administrative records. |
| **Date of Birth (DOB)** | Account creation (`CreateUserScreen`) for Students & Staff | `'01-01-2000'` (Student)<br>`'01-01-1990'` (Staff) | `dob` (`AppConstants.fieldDob`) | • Official demographic identity metadata.<br>• Maintained in Firestore schema for member identity verification. |

---

## 5. Role-Based Permissions & System Impact

```
                          ┌──────────────────────────┐
                          │   USER ROLE HIERARCHY    │
                          └────────────┬─────────────┘
                                       │
         ┌─────────────────────────────┼─────────────────────────────┐
         ▼                             ▼                             ▼
┌──────────────────┐          ┌──────────────────┐          ┌──────────────────┐
│      ADMIN       │          │     MANAGER      │          │     EMPLOYEE     │
├──────────────────┤          ├──────────────────┤          ├──────────────────┤
│ • All User Roles │          │ • Student & Staff│          │ • Counter Staff  │
│ • System Stats   │          │ • Token Quotas   │          │ • QR Scanner     │
│ • Quotas & Purge │          │ • Account Delete │          │ • Real-Time Scan │
└──────────────────┘          └──────────────────┘          └──────────────────┘
```

### Role Permissions & Action Summary

* **Admin (`UserRole.admin`)**:
  * **Scope**: Superuser master console.
  * **Permissions**: Provisions accounts for all roles (`A`, `M`, `E`, `S`), deletes Manager/Staff/Student accounts, sets pool quotas, views system-wide statistics and full directory (`getAllMembersGrouped`).
* **Manager (`UserRole.manager`)**:
  * **Scope**: Mess administration console.
  * **Permissions**: Sets daily Veg & Non-Veg pool quotas in `Tokens/Counts`, views live meal stats, provisions and deletes Student (`S`) and Staff (`E`) accounts. Cannot manage Manager or Admin accounts.
* **Employee / Staff (`UserRole.employee`)**:
  * **Scope**: Counter redemption terminal (`ScannerScreen`).
  * **Permissions**: Scans student QR codes, executes atomic `redeemToken` transactions, views scan validation and remaining balances. Cannot book tokens or manage accounts.
* **Student (`UserRole.student`)**:
  * **Scope**: Mess portal & token wallet.
  * **Permissions**: Books Veg, Non-Veg, and Egg tokens, displays digital QR passes, scans counter purchase QRs, views personal transaction history. Cannot set quotas or manage accounts.

---

## 6. Permissions Matrix

| Feature / Action | Student | Employee (Staff) | Manager | Admin |
| :--- | :---: | :---: | :---: | :---: |
| **Book Meal Tokens** | ✅ | ❌ | ❌ | ❌ |
| **View Active Wallet Passes** | ✅ | ❌ | ❌ | ❌ |
| **Generate Pass QR Code** | ✅ | ❌ | ❌ | ❌ |
| **Scan & Redeem Tokens** | ❌ | ✅ | ❌ | ❌ |
| **Set Token Pool Quotas** | ❌ | ❌ | ✅ | ✅ |
| **View System-Wide Stats** | ❌ | ❌ | ✅ | ✅ |
| **Create Student/Staff Accounts** | ❌ | ❌ | ✅ | ✅ |
| **Create Manager Accounts** | ❌ | ❌ | ❌ | ✅ |
| **Create Admin Accounts** | ❌ | ❌ | ❌ | ✅ |
| **Delete Student/Staff Accounts** | ❌ | ❌ | ✅ | ✅ |
| **Delete Manager Accounts** | ❌ | ❌ | ❌ | ✅ |
| **Update Own Profile** | ✅ | ✅ | ✅ | ✅ |
