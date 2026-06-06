# JobPortal Frontend

<div align="center">

![Flutter](https://img.shields.io/badge/Flutter-3.x-02569B?style=for-the-badge&logo=flutter&logoColor=white)
![Dart](https://img.shields.io/badge/Dart-3.0+-0175C2?style=for-the-badge&logo=dart&logoColor=white)
![Provider](https://img.shields.io/badge/Provider-State_Management-764ABC?style=for-the-badge)
![Material 3](https://img.shields.io/badge/Material_Design-3-757575?style=for-the-badge&logo=material-design&logoColor=white)
![Platform](https://img.shields.io/badge/Platform-Android%20%7C%20iOS%20%7C%20Web-informational?style=for-the-badge)

**A beautifully crafted Flutter job portal app — featuring role-based portals for job seekers and recruiters, with real-time job search, application tracking, and a recruiter analytics dashboard.**

[Features](#features) • [Setup](#getting-started) • [Architecture](#architecture)

</div>

---

## Overview

JobPortal Frontend is a cross-platform Flutter application that connects job seekers with recruiters. Upon login, users are routed into one of two distinct portals based on their role — a clean job browsing experience for candidates, or a full recruiter management suite for hiring managers.

The app communicates with a [Spring Boot 4 REST API](https://github.com/Rajg18/JobPortal-Backend) over HTTP using JWT authentication.

---

## Features

### Authentication
- **Registration** — name, email, password, and role selection (Job Seeker / Recruiter)
- **Login** — email + password authentication with JWT token storage
- **Session persistence** — token and role stored in `SharedPreferences`, auto-restored on launch
- **Role-based routing** — automatically navigates to the correct portal (User or Admin) on login

### Job Seeker Portal (`USER` role)
- **Browse jobs** — paginated list of all available job postings
- **Smart search & filter** — filter by location, tech stack, company name, or experience level
- **Job details** — full job description, requirements, company info, and posting date
- **One-click apply** — apply to any job instantly; duplicate applications are prevented
- **My applications** — view personal application history with real-time status (`Applied`, `Pending`, `Accepted`, `Rejected`)
- **Profile management** — create and update personal profile (skills, phone, location, years of experience)

### Recruiter Portal (`ADMIN` role)
- **Dashboard with live stats**:
  - Total registered users on the platform
  - Jobs posted by this recruiter
  - Total applications received, accepted, and rejected (recruiter-scoped)
- **Job management** — create new job postings and delete existing ones
- **Applicant review** — browse all candidates who applied to each job
- **Status management** — accept or reject individual applicants with a single tap
- **Isolated view** — recruiters only see jobs and applications they own

### UI / UX
- **Dark theme** — deep navy background with gold accent colors for a professional look
- **Material Design 3** — modern component library with smooth transitions
- **Reusable widget library** — `AppTextField`, `JobCard`, `StatusBadge` for consistent UI
- **Snackbar feedback** — real-time success and error notifications
- **Loading & error states** — every async operation has proper visual feedback
- **Portrait-only** — optimized for mobile usage

---

## Tech Stack

| Layer | Technology |
|-------|-----------|
| Language | Dart 3.0+ |
| Framework | Flutter (Material Design 3) |
| State Management | Provider 6.1.2 (ChangeNotifier) |
| HTTP Client | http 1.2.1 |
| Local Storage | shared_preferences 2.2.3 |
| Fonts | google_fonts 6.2.1 |
| Platforms | Android, iOS, Web |

---

## Architecture

The app follows a clean layered architecture:

```
lib/
├── core/
│   ├── constants/         # API URLs, app color palette
│   ├── theme/             # MaterialApp theme configuration
│   └── utils/             # StorageService (token, role, email)
│
├── data/
│   ├── models/            # JobModel, ApplicationModel, ProfileModel, StatsModel
│   └── services/          # AuthService, JobService, ApplicationService, ProfileService, AdminService
│
├── providers/             # AuthProvider, JobProvider, ApplicationProvider, ProfileProvider
│
├── screens/
│   ├── auth/              # LoginScreen, RegisterScreen
│   ├── user/              # HomeScreen, JobDetailScreen, MyApplicationsScreen, ProfileScreen
│   └── admin/             # AdminDashboard, JobsManagement, CreateJob, JobApplicants
│
└── widgets/               # AppTextField, JobCard, StatusBadge
```

### State Management Flow

```
Screen → Provider → Service → REST API (Spring Boot)
                ↑
           ChangeNotifier (notifyListeners → UI rebuild)
```

### Authentication Flow

```
App Launch
    │
    ▼
StorageService.restoreSession()
    │
    ├── Token found → route to UserShell or AdminShell (by role)
    │
    └── No token  → route to LoginScreen
                         │
                         ▼
                   POST /auth/login
                         │
                         ▼
                   Save token + role + email
                         │
                         ▼
                   Route to correct portal
```

---

## Screens

| Screen | Role | Description |
|--------|------|-------------|
| Login | All | Email + password sign in |
| Register | All | New account with role selection |
| Home (Job List) | User | Browse and search job listings |
| Job Detail | User | Full job info + apply button |
| My Applications | User | Personal application history with status |
| User Profile | User | Create / edit skills, experience, contact |
| Admin Dashboard | Admin | Stats: users, jobs posted, applications |
| Jobs Management | Admin | List, create, and delete job postings |
| Job Applicants | Admin | View and manage candidates per job |

---

## Getting Started

### Prerequisites
- Flutter SDK 3.x ([install guide](https://docs.flutter.dev/get-started/install))
- Dart 3.0+
- Android Studio / VS Code with Flutter plugin
- A running instance of [JobPortal Backend](https://github.com/Rajg18/JobPortal-Backend)

### 1. Clone the repository
```bash
git clone https://github.com/Rajg18/JobPortal-Frontend.git
cd JobPortal-Frontend
```

### 2. Install dependencies
```bash
flutter pub get
```

### 3. Configure API URL

Edit [`lib/core/constants/api_constants.dart`](lib/core/constants/api_constants.dart):

```dart
// For Android emulator
static const String baseUrl = 'http://10.0.2.2:8080';

// For physical device / web
static const String baseUrl = 'http://localhost:8080';
```

### 4. Run the app

```bash
# Android
flutter run

# Web (with specific port for CORS)
flutter run -d chrome --web-port 3000

# iOS
flutter run -d ios
```

---

## Project Structure — Key Files

| File | Purpose |
|------|---------|
| `lib/main.dart` | App entry, `AuthGate` (splash + session restore) |
| `lib/core/constants/api_constants.dart` | Backend URL configuration |
| `lib/core/constants/app_colors.dart` | Theme color palette |
| `lib/data/services/auth_service.dart` | Login & registration API calls |
| `lib/data/services/job_service.dart` | Job listing, search, create, delete |
| `lib/data/services/application_service.dart` | Apply, fetch, update application status |
| `lib/providers/auth_provider.dart` | Auth state — token, role, login/logout |
| `lib/providers/job_provider.dart` | Job list state — filtering, pagination |
| `lib/screens/user/home_screen.dart` | Main job browsing screen |
| `lib/screens/admin/admin_dashboard_screen.dart` | Recruiter analytics screen |

---

## Backend Integration

This app is designed to work with the **JobPortal Backend** API:

- Base URL: `http://localhost:8080` (configurable)
- Auth: `Authorization: Bearer <JWT>` header on all protected requests
- Role claim embedded in JWT — decoded client-side for routing

**Backend repository:** [Rajg18/JobPortal-Backend](https://github.com/Rajg18/JobPortal-Backend)

---

## License

This project is open-source and available under the [MIT License](LICENSE).
