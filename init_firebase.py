#!/usr/bin/env python3

"""
PSG Mess Token System - Firebase Full Reset & Data Initialization Script

This script:
1. Deletes ALL Firebase Authentication users.
2. Deletes ALL documents from the Firestore database.
3. Creates demo Firebase Auth users for all roles (Admin, Manager, Employee, Student).
4. Inserts sample Firestore documents matching current app data models:
   - Admins, Managers, Employees, Students
   - Tokens (Counts document with 5,000 default veg pool and 24-hour reset timestamp)
   - Purchases & Redemptions collections

Prerequisites:
    pip install firebase-admin

Service Account:
    Download the Firebase Service Account JSON file from:
    Firebase Console -> Project Settings -> Service accounts
    -> Generate new private key

Save it as:
    serviceAccountKey.json

Usage:
    python init_firebase.py
    python init_firebase.py path_to_service_account.json

WARNING:
    This script permanently deletes ALL Firebase Authentication users
    and ALL Firestore documents in the configured Firebase project.
"""

import sys
import os
import datetime
import firebase_admin
from firebase_admin import credentials, firestore, auth


# ---------------------------------------------------------------------------
# Firebase Initialization
# ---------------------------------------------------------------------------

def initialize_firebase(key_path):
    if not os.path.exists(key_path):
        print(f"[ERROR] Service account key file not found at: {key_path}")
        print("Please place 'serviceAccountKey.json' in the current directory")
        print("or pass its path as an argument.")
        sys.exit(1)

    try:
        cred = credentials.Certificate(key_path)
        firebase_admin.initialize_app(cred)
        print(f"[SUCCESS] Firebase initialized with key: {key_path}\n")
    except Exception as e:
        print(f"[ERROR] Failed to initialize Firebase: {e}")
        sys.exit(1)


# ---------------------------------------------------------------------------
# Delete All Firebase Authentication Users
# ---------------------------------------------------------------------------

def clear_auth_users():
    print("1. Clearing Firebase Authentication users...")
    deleted_count = 0

    try:
        page = auth.list_users()

        while True:
            for user in page.users:
                try:
                    auth.delete_user(user.uid)
                    deleted_count += 1
                    print(
                        f"   ✓ Deleted Auth user: "
                        f"{user.email or '(no email)'} | UID={user.uid}"
                    )
                except Exception as e:
                    print(
                        f"   ⚠️ Could not delete user "
                        f"{user.uid}: {e}"
                    )

            if page.next_page_token:
                page = auth.list_users(
                    page_token=page.next_page_token
                )
            else:
                break

        print(
            f"   ✓ Firebase Authentication cleared. "
            f"Deleted {deleted_count} user(s).\n"
        )

    except Exception as e:
        print(f"   ❌ Failed to clear Firebase Authentication: {e}")
        sys.exit(1)


# ---------------------------------------------------------------------------
# Delete All Firestore Documents
# ---------------------------------------------------------------------------

def delete_collection(collection_ref, batch_size=100):
    """
    Delete every document in a Firestore collection.

    Also recursively deletes documents in subcollections when they are
    discovered.
    """
    deleted_count = 0

    while True:
        docs = list(collection_ref.limit(batch_size).stream())

        if not docs:
            break

        batch = firestore.client().batch()

        for doc in docs:
            for subcollection in doc.reference.collections():
                deleted_count += delete_collection(
                    subcollection,
                    batch_size
                )

            batch.delete(doc.reference)

        batch.commit()
        deleted_count += len(docs)

    return deleted_count


def clear_firestore():
    print("2. Clearing Cloud Firestore...")

    db = firestore.client()
    total_deleted = 0

    try:
        collections = list(db.collections())

        if not collections:
            print("   ✓ Firestore is already empty.\n")
            return

        for collection in collections:
            count = delete_collection(collection)
            total_deleted += count
            print(
                f"   ✓ Deleted collection '{collection.id}' "
                f"({count} document(s))"
            )

        print(
            f"   ✓ Firestore cleared. "
            f"Deleted {total_deleted} document(s).\n"
        )

    except Exception as e:
        print(f"   ❌ Failed to clear Firestore: {e}")
        sys.exit(1)


# ---------------------------------------------------------------------------
# Create Firebase Authentication Users for All Demo Roles
# ---------------------------------------------------------------------------

def create_demo_auth_users():
    print("3. Creating Firebase Authentication accounts for demo users...")

    users_to_create = [
        {
            "role": "admin",
            "doc_id": "A101",
            "email": "sanjeeth653@gmail.com",
            "password": "Password@1234",
            "name": "Sanjeeth (Admin)",
        },
        {
            "role": "manager",
            "doc_id": "M101",
            "email": "22pw33@psgtech.ac.in",
            "password": "Password@1234",
            "name": "Sanjeeth 1 (Manager)",
        },
        {
            "role": "employee",
            "doc_id": "E101",
            "email": "myworks854@gmail.com",
            "password": "Password@1234",
            "name": "Sanjeeth 3 (Staff)",
        },
        {
            "role": "student",
            "doc_id": "S101",
            "email": "clgworks02@gmail.com",
            "password": "Password@1234",
            "name": "Sanjeeth 4 (Student)",
        },
    ]

    created_accounts = []

    for item in users_to_create:
        try:
            user = auth.create_user(
                email=item["email"],
                password=item["password"],
                display_name=item["name"],
            )
            item["uid"] = user.uid
            created_accounts.append(item)
            print(
                f"   ✓ Created {item['role'].capitalize()} Auth user: "
                f"{item['email']} | UID={user.uid}"
            )
        except Exception as e:
            print(f"   ❌ Could not create {item['role']} Auth user ({item['email']}): {e}")
            sys.exit(1)

    print()
    return created_accounts


# ---------------------------------------------------------------------------
# Insert Firestore Sample Data Matching Application Specification
# ---------------------------------------------------------------------------

def setup_sample_data(demo_accounts):
    print("4. Populating Cloud Firestore collections...")

    db = firestore.client()
    account_map = {acc["doc_id"]: acc for acc in demo_accounts}
    today_str = datetime.datetime.now().strftime("%d-%m-%Y")
    now_time_str = datetime.datetime.now().strftime("%I:%M %p")

    # -----------------------------------------------------------------------
    # Admins
    # -----------------------------------------------------------------------
    admin_acc = account_map["A101"]
    admin_data = {
        "uid": admin_acc["uid"],
        "name": "Sanjeeth",
        "email": admin_acc["email"],
        "role": "admin",
        "department": "System Administration",
        "createdAt": today_str,
    }
    db.collection("Admins").document("A101").set(admin_data)
    print("   ✓ Collection 'Admins' -> Document 'A101' created.")

    # -----------------------------------------------------------------------
    # Managers
    # -----------------------------------------------------------------------
    mgr_acc = account_map["M101"]
    manager_data = {
        "uid": mgr_acc["uid"],
        "name": "Sanjeeth 1",
        "email": mgr_acc["email"],
        "role": "manager",
        "department": "Mess Administration",
        "createdAt": today_str,
    }
    db.collection("Managers").document("M101").set(manager_data)
    print("   ✓ Collection 'Managers' -> Document 'M101' created.")

    # -----------------------------------------------------------------------
    # Employees (Staff)
    # -----------------------------------------------------------------------
    emp_acc = account_map["E101"]
    employee_data = {
        "uid": emp_acc["uid"],
        "name": "Sanjeeth 3",
        "email": emp_acc["email"],
        "role": "employee",
        "department": "Staff / Service",
        "dob": "10-05-1992",
        "doj": "01-08-2022",
        "createdAt": today_str,
    }
    db.collection("Employees").document("E101").set(employee_data)
    print("   ✓ Collection 'Employees' -> Document 'E101' created.")

    # -----------------------------------------------------------------------
    # Students
    # -----------------------------------------------------------------------
    std_acc = account_map["S101"]
    student_data = {
        "uid": std_acc["uid"],
        "name": "Sanjeeth 4",
        "email": std_acc["email"],
        "course": "Msc Software Systems",
        "department": "Msc Software Systems",
        "role": "student",
        "dob": "15-03-2004",
        "doj": "01-08-2023",
        "veg": 0,
        "non-veg": 0,
        "eggs": 15,
        "createdAt": today_str,
    }
    db.collection("Students").document("S101").set(student_data)
    print("   ✓ Collection 'Students' -> Document 'S101' created.")

    # -----------------------------------------------------------------------
    # Tokens (Counts document with 5,000 veg default & lastVegReset timestamp)
    # -----------------------------------------------------------------------
    tokens_data = {
        "veg": 5000,
        "non-veg": 100,
        "veg_purchased": 0,
        "non-veg_purchased": 0,
        "lastVegReset": firestore.SERVER_TIMESTAMP,
    }
    db.collection("Tokens").document("Counts").set(tokens_data)
    print("   ✓ Collection 'Tokens' -> Document 'Counts' created.")

    # -----------------------------------------------------------------------
    # Purchases (Sample purchase transaction)
    # -----------------------------------------------------------------------
    purchase_sample = {
        "rollNumber": "S101",
        "category": "egg",
        "count": 15,
        "date": today_str,
        "time": now_time_str,
        "timestamp": firestore.SERVER_TIMESTAMP,
    }
    db.collection("Purchases").add(purchase_sample)
    print("   ✓ Collection 'Purchases' -> Sample transaction doc created.")

    # -----------------------------------------------------------------------
    # Redemptions (Sample redemption transaction)
    # -----------------------------------------------------------------------
    redemption_sample = {
        "rollNumber": "S101",
        "category": "egg",
        "count": 5,
        "date": today_str,
        "time": now_time_str,
        "timestamp": firestore.SERVER_TIMESTAMP,
    }
    db.collection("Redemptions").add(redemption_sample)
    print("   ✓ Collection 'Redemptions' -> Sample transaction doc created.")

    print("\n🎉 Firebase reset and initialization completed successfully!")
    print("==========================================================================================")
    print(" DEMO ACCOUNTS & CREDENTIALS SUMMARY")
    print("==========================================================================================")
    for acc in demo_accounts:
        print(f" Role     : {acc['role'].upper()}")
        print(f" Doc ID   : {acc['doc_id']}")
        print(f" Email    : {acc['email']}")
        print(f" Password : {acc['password']}")
        print(f" Auth UID : {acc['uid']}")
        print("------------------------------------------------------------------------------------------")


# ---------------------------------------------------------------------------
# Main
# ---------------------------------------------------------------------------

def main():
    key = (
        sys.argv[1]
        if len(sys.argv) > 1
        else "serviceAccountKey.json"
    )

    print("============================================================")
    print(" PSG MESS TOKEN SYSTEM")
    print(" FIREBASE RESET & INITIALIZATION")
    print("============================================================")
    print()
    print("⚠️ WARNING: This operation will permanently delete:")
    print("   • ALL Firebase Authentication users")
    print("   • ALL Firestore documents")
    print()

    initialize_firebase(key)

    clear_auth_users()
    clear_firestore()

    demo_accounts = create_demo_auth_users()
    setup_sample_data(demo_accounts)


if __name__ == "__main__":
    main()
