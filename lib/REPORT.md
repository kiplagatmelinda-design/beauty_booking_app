# Beauty Booking App – CAT 1 Submission

## Student Details
- **Name:** MELINDA KIPLAGAT
- **Registration Number:** BIT/2024/54761
- **Course:** BIT4107
- **Date:** 16/06/2026

---

## 1. Project Overview

Beauty Booking is a Flutter-based mobile application designed to help users manage beauty services and view data from a public REST API. The app features a secure login screen, full CRUD (Create, Read, Update, Delete) operations for managing services, persistent local storage using SQLite, and network integration with a public API.

The application follows a clean, user-friendly interface with a consistent pink theme, making it easy for users to navigate and interact with.

---

## 2. Features Implemented

| Feature | Description |
|---------|-------------|
| **User Interface** | Clean, responsive design with a pink theme, icons, and card-based layouts. |
| **Navigation** | Smooth screen transitions: Login → Services → Booking / API Data. |
| **Event Handling** | Button taps, form submissions, search input, and long‑press actions. |
| **Local Data Storage** | Services stored permanently using SQLite (sqflite package). |
| **Data Retrieval** | Services loaded from the database on app startup and after each CRUD operation. |
| **Networking** | HTTP GET requests to `jsonplaceholder.typicode.com`. |
| **API Consumption** | Fetches and displays a list of posts with titles and bodies. |
| **Error Handling** | Try-catch blocks, loading indicators, and retry buttons for failed requests. |

---

## 3. Application Modules

### 3.1 Login Screen
- Accepts email and password (demo validation – any non‑empty value works).
- On successful login, navigates to the Services screen.
- Includes input validation and loading state.

### 3.2 Services Screen (Dashboard)
- Displays all services in a 2‑column grid with name, duration, price, and icon.
- **Search:** Real‑time filtering by service name.
- **Add:** Floating action button opens a form to create a new service.
- **Update:** Edit icon or long‑press on a card opens the form with existing data.
- **Delete:** Trash icon with a confirmation dialog.

### 3.3 Local Database
- Uses `sqflite` to create a `services` table with columns: `id`, `name`, `duration`, `price`, `icon`.
- Default services are inserted on first launch.
- All CRUD operations are performed against this database.

### 3.4 Booking Screen
- Receives the selected service name and price from the Services screen.
- Placeholder for booking details (customer name, date, time).

### 3.5 API Integration Screen
- Fetches data from `https://jsonplaceholder.typicode.com/posts`.
- Displays a list of posts with `id`, `title`, and `body`.
- Refresh button and retry mechanism are included.
- Shows a loading indicator while fetching and an error message on failure.

---

## 4. Technology Stack

| Component | Technology |
|-----------|------------|
| Framework | Flutter (Dart) |
| Local Storage | SQLite (sqflite + path packages) |
| Networking | HTTP package |
| State Management | setState (local state) |
| IDE | VS Code / Android Studio |

---

## 5. Project Structure
beauty_booking_app/
├── lib/
│   ├── login_screen.dart
│   ├── services_screen.dart
│   ├── booking_screen.dart
│   ├── api_data_screen.dart
│   └── main.dart
├── screenshots/
│   ├── 01_login_screen.png
│   ├── 02_services_grid.png
│   ├── 03_add_service.png
│   ├── 04_edit_service.png
│   ├── 05_delete_confirmation.png
│   ├── 06_search_results.png
│   ├── 07_booking_screen.png
│   └── 08_api_data_screen.png
├── pubspec.yaml
├── REPORT.md
└── README.md