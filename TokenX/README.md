# TokenX 🎫
> **Smart Hostel Mess Special-Food Token Management Application**  
> *Developed for K Ramakrishnan College of Technology (KRCT), Tiruchirappalli.*

---

## 1. Project Overview
TokenX is a production-ready mobile application engineered to automate the daily hostel mess special-food token allotment system at K Ramakrishnan College of Technology (KRCT).

From Monday to Saturday, the hostel mess prepares one dedicated special dish for **Vegetarian** students and one for **Non-Vegetarian** students. TokenX eliminates manual paper coupons, long queues, proxy collection, and food wastage by providing authenticated digital tokens with cryptographic uniqueness, strict single-booking constraints, automated 9:00 AM cutoff deadlines, live kitchen preparation counters, and instant CSV exports for hostel mess management.

---

## 2. Key Features

### 🎓 KRCT Student Portal
- **Strict Domain Login**: Authenticate exclusively with `@krct.ac.in` institutional email IDs. Any outside domain (`@gmail.com`, `@yahoo.com`, etc.) is immediately blocked.
- **Today's Special Food**: Instant visual cards showing both Vegetarian and Non-Vegetarian specials for the day.
- **Weekly Menu Schedule**: Browse the full Monday-to-Saturday schedule with day badges.
- **3-Step Token Application**: Select date, pick dietary preference (🌱 Veg / 🥩 Non-Veg), and apply.
- **Zero Duplicate Booking**: Hardware & database-level prevention of multiple tokens for the same date per student.
- **Digital Perforated Ticket**: Receive an authentic digital token ticket with unique ID (`TX-YYYYMMDD-XXXX`), student details, and status.
- **Token History (My Tokens)**: Filter between `Upcoming` and `History` tokens.

### 🛡️ Hostel Warden Administration
- **Restricted Access**: Reserved strictly for `hostelwarden@krct.ac.in`. No student or unauthorized faculty account can enter the Warden Portal.
- **Real-Time 2x2 Metric Dashboard**:
  - Total Token Count
  - Vegetarian Token Count
  - Non-Vegetarian Token Count
  - Today's Token Count
- **Live Food Requirement Counters**: Real-time kitchen headcount (e.g., Chicken 65: 58, Gobi 65: 42) to optimize cooking quantities and eliminate food waste.
- **Student Token Applications Stream**: Search instantly by student name, roll number, email, or Token ID with date/category filters.
- **Token Audit & Counter Redemption**: Mark tokens as `Redeemed` as students enter the mess hall.
- **CSV Data Export**: Export filtered token datasets for hostel kitchen contractors and college records.

---

## 3. Fixed Weekly Special Food Menu

| Day | 🥩 Non-Vegetarian Special | 🌱 Vegetarian Special | Status |
| :--- | :--- | :--- | :--- |
| **Monday** | Chicken 65 | Gobi 65 | Available |
| **Tuesday** | Chicken Biryani | Mushroom Biryani | Available |
| **Wednesday** | Fish Fry | Soya 65 | Available |
| **Thursday** | Chicken Fried Rice | Paneer Fried Rice | Available |
| **Friday** | Fish Gravy | Paneer Gravy | Available |
| **Saturday** | Mutton Biryani | Paneer Biryani | Available |
| **Sunday** | *No Special Food Available Today* | *No Special Food Available Today* | Closed |

> **Sunday Blackout Notice**: Special-food tokens are available Monday to Saturday only. On Sundays, the regular hostel mess meal is served.

---

## 4. System Architecture

```
                  +-----------------------------------+
                  |             TokenX UI             |
                  |     (Flutter Material 3 App)      |
                  +-----------------+-----------------+
                                    |
            +-----------------------+-----------------------+
            |                                               |
+-----------v-----------+                       +-----------v-----------+
|     Student Portal    |                       |      Warden Portal    |
| (@krct.ac.in Student) |                       | (hostelwarden@krct)   |
| - Today's Special     |                       | - Live Metrics (2x2)  |
| - Weekly Menu         |                       | - Kitchen Count       |
| - Apply Token         |                       | - Search & Filters    |
| - My Tokens History   |                       | - CSV Export Engine   |
+-----------+-----------+                       +-----------+-----------+
            |                                               |
            +-----------------------+-----------------------+
                                    |
                  +-----------------v-----------------+
                  |          Services Layer           |
                  |  - AuthService                    |
                  |  - TokenService (Cutoff & Dup)    |
                  |  - FirestoreService               |
                  |  - ExportService                  |
                  +-----------------+-----------------+
                                    |
            +-----------------------+-----------------------+
            |                                               |
+-----------v-----------+                       +-----------v-----------+
| Firebase Auth Service |                       |  Cloud Firestore DB   |
| - Email / Password    |                       | - users/{uid}         |
| - Domain Validation   |                       | - tokens/{uid_date}   |
+-----------------------+                       +-----------+-----------+
                                                            |
                                                +-----------v-----------+
                                                |   firestore.rules     |
                                                | Strict Security Layer |
                                                +-----------------------+
```

---

## 5. Cloud Firestore Database Schema

### 1. `users` Collection (`/users/{uid}`)
```json
{
  "uid": "stu_001_abc",
  "name": "Arun Kumar",
  "email": "student1@krct.ac.in",
  "role": "student",
  "department": "Computer Science & Engineering",
  "year": "III Year",
  "createdAt": "2026-10-05T08:30:00Z"
}
```

### 2. `tokens` Collection (`/tokens/{studentUid}_{date}`)
*Deterministic Document ID guarantees 1 token per date per student at the database level.*
```json
{
  "tokenId": "TX-20261005-1042",
  "studentUid": "stu_001_abc",
  "studentName": "Arun Kumar",
  "studentEmail": "student1@krct.ac.in",
  "date": "2026-10-05",
  "day": "Monday",
  "category": "Non-Vegetarian",
  "foodItem": "Chicken 65",
  "status": "Applied",
  "appliedAt": "2026-10-05T07:15:00Z"
}
```

---

## 6. Pre-Configured Demo Accounts (Viva & Evaluation)

TokenX comes with pre-configured accounts for one-tap evaluation:

| Role | Email ID | Default Password | Features Accessible |
| :--- | :--- | :--- | :--- |
| **Hostel Warden** | `hostelwarden@krct.ac.in` | `Password@123` | Full Warden Dashboard, Kitchen Counts, Student Search, CSV Export |
| **Student 1** | `student1@krct.ac.in` | `Password@123` | Student Portal, Apply Token, View Today's Food, My Tokens |
| **Student 2** | `student2@krct.ac.in` | `Password@123` | Student Portal, Vegetarian tokens |
| **Student 3** | `student3@krct.ac.in` | `Password@123` | Student Portal |

> *Note: For production deployment, default passwords must be updated by users upon initial login.*

---

## 7. Firebase Setup Instructions

### Step 1: Create Firebase Project
1. Open the [Firebase Console](https://console.firebase.google.com/).
2. Click **Add Project** and name it `tokenx-krct`.

### Step 2: Add Android Application
1. In Project Settings, click **Add App** ➔ **Android**.
2. Package Name: `com.krct.tokenx`.
3. App Nickname: `TokenX`.
4. Download `google-services.json` and place it in:
   ```
   TokenX/android/app/google-services.json
   ```

### Step 3: Enable Authentication
1. Go to **Authentication** ➔ **Sign-in method**.
2. Enable **Email/Password** provider.

### Step 4: Create Cloud Firestore Database
1. Go to **Firestore Database** ➔ **Create Database**.
2. Choose your nearest region (e.g., `asia-south1` Mumbai).
3. Start in **Production mode**.

### Step 5: Deploy Security Rules
1. In Firestore, open the **Rules** tab.
2. Paste the contents of `TokenX/firestore.rules` and click **Publish**.

---

## 8. Build & Run Instructions

### Prerequisites
- Flutter SDK 3.19+ / 3.24+
- Android Studio / VS Code with Flutter Extension
- Android Device or Emulator running Android 7.0+ (API 24+)

### Commands
```bash
# 1. Navigate to project directory
cd TokenX

# 2. Get dependencies
flutter pub get

# 3. Run automated tests
flutter test

# 4. Run application
flutter run
```

---

### 🍽️ Food Complaint & Dynamic Priority Module
- **Student Complaint Submission**: Students can submit complaints for today's special food, specifying categories (Food Quality, Taste, Quantity, Temperature, Hygiene, Other), descriptions, and 1-5 star ratings.
- **Privacy & History**: Students view only their own complaints and review statuses (`Submitted`, `Under Review`, `Resolved`, `Closed`).
- **Warden Priority Analytics**: Dynamically groups complaints by food item and auto-calculates priority thresholds:
  - 🟢 **LOW**: 0–5 complaints
  - 🟡 **MEDIUM**: 6–15 complaints
  - 🟠 **HIGH**: 16–25 complaints
  - 🔴 **CRITICAL**: 26+ complaints
- **Internal Warden Notes**: Wardens can append private kitchen action notes to complaints invisible to students.

---

## 3. Fixed Weekly Special Food Menu

| Day | 🥩 Non-Vegetarian Special | 🌱 Vegetarian Special | Status |
| :--- | :--- | :--- | :--- |
| **Monday** | Chicken 65 | Gobi 65 | Available |
| **Tuesday** | Chicken Biryani | Mushroom Biryani | Available |
| **Wednesday** | Fish Fry | Soya 65 | Available |
| **Thursday** | Chicken Fried Rice | Paneer Fried Rice | Available |
| **Friday** | Fish Gravy | Paneer Gravy | Available |
| **Saturday** | Mutton Biryani | Paneer Biryani | Available |
| **Sunday** | *No Special Food Available Today* | *No Special Food Available Today* | Closed |

> **Sunday Blackout Notice**: Special-food tokens are available Monday to Saturday only. On Sundays, the regular hostel mess meal is served.

---

## 8. Build & Run Instructions

### Prerequisites
- Flutter SDK 3.19+ / 3.24+
- Android Studio / VS Code with Flutter Extension
- Android Device or Emulator running Android 7.0+ (API 24+)

### Commands
```bash
# 1. Navigate to project directory
cd TokenX

# 2. Get dependencies
flutter pub get

# 3. Run automated tests
flutter test

# 4. Run application
flutter run
```

---

## 9. GitHub Upload Instructions

To upload this project to a new GitHub repository:

```bash
# 1. Open terminal inside the project directory
cd TokenX

# 2. Initialize Git repository
git init

# 3. Add all files (respecting .gitignore)
git add .

# 4. Commit initial project code
git commit -m "Initial commit: TokenX Smart Hostel Mess Token Management System"

# 5. Link to your new GitHub repository
git remote add origin https://github.com/YOUR_USERNAME/YOUR_REPOSITORY.git

# 6. Push to main branch
git branch -M main
git push -u origin main
```

---

## 10. Security & Release Signing Notice
- **Keystore**: For security, release keystores (`upload-keystore.jks`) and `key.properties` are excluded via `.gitignore`.
- **Release Setup**: To sign an APK or App Bundle for production, copy `android/key.properties.example` to `android/key.properties`, supply your keystore credentials, and place your `.jks` file in `android/app/`. If `key.properties` is absent, debug signing will be used automatically.

