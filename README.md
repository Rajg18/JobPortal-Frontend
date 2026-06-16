# HireLoop — Flutter Frontend

<div align="center">

![Flutter](https://img.shields.io/badge/Flutter-3.x-02569B?style=for-the-badge&logo=flutter&logoColor=white)
![Dart](https://img.shields.io/badge/Dart-3.x-0175C2?style=for-the-badge&logo=dart&logoColor=white)
![Provider](https://img.shields.io/badge/State-Provider-FF6B35?style=for-the-badge)
![Vercel](https://img.shields.io/badge/Deploy-Vercel-000000?style=for-the-badge&logo=vercel&logoColor=white)

A modern Flutter web application for HireLoop — an AI-powered job portal where job seekers upload resumes, get matched to jobs intelligently, send AI-generated cold emails to recruiters, and track their applications — all in one dark-themed, responsive interface.

**Live App →** _(Vercel deployment URL)_

</div>

---

## Table of Contents

- [Tech Stack](#tech-stack)
- [Architecture Overview](#architecture-overview)
- [Navigation Diagram](#navigation-diagram)
- [Project Structure](#project-structure)
- [State Management](#state-management)
- [API Integration](#api-integration)
- [Screens & Features](#screens--features)
- [Role-based UI](#role-based-ui)
- [Design System](#design-system)
- [Key Data Models](#key-data-models)
- [Running Locally](#running-locally)
- [Deployment](#deployment)

---

## Tech Stack

| Layer | Technology | Version |
|-------|-----------|---------|
| Framework | Flutter | SDK ≥ 3.0.0 |
| Language | Dart | 3.x |
| State Management | Provider (ChangeNotifier) | 6.1.2 |
| HTTP Client | http | 1.2.1 |
| Local Storage | shared_preferences | 2.2.3 |
| Typography | google_fonts (Inter) | 6.2.1 |
| File Picker | file_picker | 8.0.3 |
| Theme | Dark — Material 3 | — |

---

## Architecture Overview

HireLoop frontend uses the **Provider pattern** for state management. Each feature domain has a `Provider` (ChangeNotifier) backed by a `Service` class that makes HTTP calls. Screens observe providers and rebuild reactively. A centralised `ApiClient` handles JWT injection and auto-logout on 401.

```
┌─────────────────────────────────────────────────────────────────────┐
│                       Application Layers                            │
│                                                                     │
│  ┌───────────────────────────────────────────────────────────────┐  │
│  │                        UI Layer                               │  │
│  │   Screens / Widgets  →  observe Providers  →  react to state  │  │
│  └────────────────────────────┬──────────────────────────────────┘  │
│                               │ context.read / context.watch        │
│  ┌────────────────────────────▼──────────────────────────────────┐  │
│  │                    Provider Layer                             │  │
│  │   ChangeNotifier subclasses — hold state, call Services       │  │
│  └────────────────────────────┬──────────────────────────────────┘  │
│                               │                                     │
│  ┌────────────────────────────▼──────────────────────────────────┐  │
│  │                    Service Layer                              │  │
│  │   ApiClient (JWT injected) → HTTP → Spring Boot REST API      │  │
│  └────────────────────────────┬──────────────────────────────────┘  │
│                               │                                     │
└───────────────────────────────┼─────────────────────────────────────┘
                                │
              ┌─────────────────▼──────────────────┐
              │       HireLoop Spring Boot API       │
              │   http://localhost:8080  (dev)       │
              │   https://jobportal-backend-         │
              │   z2pv.onrender.com      (prod)      │
              └─────────────────────────────────────┘
```

---

## Navigation Diagram

```
main.dart (AuthGate)
│
├── Not logged in → LoginScreen ──────────────────────────────────────────────►
│                       │                                                      │
│                   RegisterScreen ◄────────────────────────────────────────── │
│                                                                              │
└── Logged in
        │
        ├── role == USER  →  UserShell (IndexedStack)
        │       │
        │       ├── [0] HomeScreen
        │       │         ├── Job cards → JobDetailScreen (Navigator.push)
        │       │         │                  └── SendColdEmailScreen (push)
        │       │         └── Navbar links → other tabs
        │       │
        │       ├── [1] AiMatchScreen
        │       │         ├── ← Back to Home (onGoHome callback)
        │       │         └── Job cards
        │       │               ├── View Details → JobDetailScreen (push)
        │       │               └── Send Cold Email → SendColdEmailScreen (push)
        │       │
        │       ├── [2] MyApplicationsScreen
        │       │         └── ← Back to Home (onGoHome callback)
        │       │
        │       ├── [3] MessagesScreen
        │       │         ├── ← Back to Home (onGoHome callback)
        │       │         ├── Inbox tab  (received cold emails)
        │       │         └── Sent tab   (sent cold emails)
        │       │               └── Download Resume button
        │       │
        │       └── [4] ProfileScreen
        │                 └── ← Back to Home (onBack callback)
        │
        └── role == ADMIN  →  AdminShell (IndexedStack)
                │
                ├── [0] AdminDashboardScreen
                │
                ├── [1] JobsManagementScreen
                │         ├── CreateJobScreen (Navigator.push)
                │         └── JobApplicantsScreen (push)
                │
                └── [2] MessagesScreen (shared, onGoHome → Dashboard)
                          ├── ← Back to Dashboard (onGoHome callback)
                          ├── Inbox tab  (receives cold emails from job seekers)
                          └── Download Resume button
```

---

## Project Structure

```
lib/
│
├── main.dart                        ← App entry, AuthGate, splash screen
│
├── screens/
│   ├── auth/
│   │   ├── login_screen.dart        ← Email/password form, token storage
│   │   └── register_screen.dart
│   │
│   ├── user/
│   │   ├── user_shell.dart          ← 5-tab IndexedStack + BottomNav
│   │   ├── home_screen.dart         ← Job search, listing, wide navbar
│   │   ├── job_detail_screen.dart   ← Full job view, Apply Now + Cold Email
│   │   ├── ai_match_screen.dart     ← AI-matched jobs from resume
│   │   ├── my_applications_screen.dart ← Status tracking with stats cards
│   │   ├── messages_screen.dart     ← Inbox / Sent tabs, resume download
│   │   ├── profile_screen.dart      ← Resume upload, skill display, logout
│   │   └── send_cold_email_screen.dart ← AI email preview + send
│   │
│   └── admin/
│       ├── admin_shell.dart         ← 3-tab IndexedStack + BottomNav
│       ├── admin_dashboard_screen.dart ← Stats overview
│       ├── jobs_management_screen.dart ← CRUD job postings
│       ├── job_applicants_screen.dart  ← View applicants, Accept/Reject
│       └── create_job_screen.dart
│
├── providers/                       ← State management (ChangeNotifier)
│   ├── auth_provider.dart           ← JWT token, role, login/logout, session restore
│   ├── job_provider.dart            ← Job listing, search, admin operations
│   ├── application_provider.dart    ← Apply, my applications, admin management
│   ├── profile_provider.dart        ← Profile save, resume upload, AI poll
│   └── message_provider.dart        ← Inbox, sent, unread badge, mark read
│
├── data/
│   ├── services/                    ← HTTP API clients
│   │   ├── auth_service.dart
│   │   ├── job_service.dart
│   │   ├── application_service.dart
│   │   ├── profile_service.dart     ← Multipart resume upload
│   │   ├── admin_service.dart
│   │   ├── email_service.dart       ← generate + send cold email
│   │   └── message_service.dart     ← inbox, sent, markRead, downloadResume
│   │
│   └── models/                      ← Dart data classes (fromJson)
│       ├── job_model.dart
│       ├── application_model.dart
│       ├── profile_model.dart       ← parsedSkills, parsedTechStack, resumeUploaded
│       ├── message_model.dart       ← resumeAttached bool
│       └── stats_model.dart
│
├── core/
│   ├── constants/
│   │   ├── api_constants.dart       ← All endpoint URLs, baseUrl toggle
│   │   └── app_colors.dart          ← Full dark-theme colour palette
│   ├── theme/
│   │   └── app_theme.dart           ← Material 3 dark theme definition
│   ├── utils/
│   │   ├── api_client.dart          ← JWT header injection, 401 auto-logout
│   │   ├── storage_service.dart     ← SharedPreferences wrapper
│   │   └── download_helper.dart     ← dart:html browser file download trigger
│   └── errors/
│       └── session_expired_exception.dart
│
└── widgets/
    ├── app_text_field.dart          ← Styled text input with icon + label
    ├── job_card.dart                ← Reusable job listing card
    └── status_badge.dart            ← PENDING / ACCEPTED / REJECTED chip
```

---

## State Management

Each provider owns one domain of state and exposes clean loading/error/data fields:

```
AuthProvider
  ├── token: String?
  ├── role:  String?          ("ROLE_USER" | "ROLE_ADMIN")
  ├── email: String?
  ├── login(email, password) → bool
  ├── register(...)          → bool
  └── logout()

JobProvider
  ├── jobs: List<JobModel>
  ├── loading, error
  ├── loadJobs(reset, filters)
  ├── createJob(...)          ← ADMIN only
  └── deleteJob(id)           ← ADMIN only

ApplicationProvider
  ├── myApplications: List<ApplicationModel>
  ├── hasAppliedToJob(id, title, company) → bool
  ├── applyJob(jobId) → bool
  └── loadMyApplications()

ProfileProvider
  ├── profile: ProfileModel?
  ├── loadProfile()
  ├── saveProfile(...)
  ├── uploadResume(bytes, fileName) → bool
  └── pollUntilParsed()   ← polls every 5s until parsedSkills populated

MessageProvider
  ├── inbox: List<MessageModel>
  ├── sent:  List<MessageModel>
  ├── unreadCount: int         ← drives red badge on Messages tab
  ├── loadInbox() / loadSent()
  ├── markAsRead(messageId)
  └── downloadResume(messageId) → List<int>
```

### Session Persistence

On startup, `AuthProvider` reads `token`, `role`, and `email` from `SharedPreferences`. If a valid token exists, the user is routed straight to their shell — no login required. On logout (or 401 from any API call), the token is cleared and the user is redirected to `LoginScreen`.

---

## API Integration

All API calls pass through `ApiClient`, which:
- Injects `Authorization: Bearer <token>` on every request
- Throws `SessionExpiredException` on HTTP 401
- Sets a 60-second timeout for production (Render cold-start tolerance)

```
api_constants.dart  ← single source of truth for all endpoints

  baseUrl = http://localhost:8080          (dev)
  baseUrl = https://jobportal-backend-     (prod, toggled by flag)
            z2pv.onrender.com

Endpoints:
  /auth/register                /auth/login
  /api/profile/save             /api/profile/me
  /api/profile/resume           (multipart POST)
  /api/jobs                     /api/jobs/admin
  /api/jobs/match               (AI matching)
  /api/applications/apply/{id}  /api/applications/my
  /api/applications/admin/**
  /api/email/generate           /api/email/send
  /api/messages/inbox           /api/messages/sent
  /api/messages/{id}/read       /api/messages/{id}/resume
  /api/admin/stats
```

---

## Screens & Features

### LoginScreen / RegisterScreen
Email and password forms with loading state. On success the JWT, role, and email are persisted to SharedPreferences. Users are routed to `UserShell` or `AdminShell` based on role.

---

### HomeScreen (User — Tab 0)
- Displays all available job listings as scrollable cards
- Live search and filter by tech stack, location, experience
- Wide-screen (>900px) top navbar with links to all 5 tabs — replaces the bottom nav on desktop
- Tapping a card opens `JobDetailScreen`

---

### JobDetailScreen
- Full job information: description, tech tags, location, experience, poster
- Bottom bar with two actions:
  - **Cold Email** → `SendColdEmailScreen`
  - **Apply Now** → calls `POST /api/applications/apply/{id}`
- Once applied, the Apply button is replaced with a green "Application Submitted" indicator

---

### AiMatchScreen (User — Tab 1)
- Calls `GET /api/jobs/match` on load using the user's `parsedTechStack`
- Shows a resume status chip: no resume / parsing in progress / ready
- Each matched job card has:
  - **View Details** → `JobDetailScreen`
  - **Send Cold Email** → `SendColdEmailScreen`
- How-it-works info banner explaining the AI matching process

---

### SendColdEmailScreen
- Recruiter email is **pre-filled** from `job.postedBy`
- AI generates a personalised cold email preview automatically on open
- **Regenerate** button re-calls the LLM with an updated recruiter name
- Copy-to-clipboard button on the preview
- Green notice: "Your resume will be attached automatically"
- **Send Email to Recruiter** — calls `POST /api/email/send`, delivers as in-app message
- On success: confirmation screen with "Back to Jobs" button

---

### MyApplicationsScreen (User — Tab 2)
- Stats row: Total / Accepted / Rejected / Pending counts with animated cards
- Filter tabs: All · Applied · Accepted · Rejected
- Each application card shows company badge, job title, date applied, and a coloured status badge
- Shimmer skeleton loading state

---

### MessagesScreen (User — Tab 3 / Admin — Tab 2)
- **Inbox** and **Sent** tabs
- Unread count badge on the tab label and bottom nav icon
- Tap to expand a message card → full email body
- Green **"Download Applicant Resume"** button when `resumeAttached = true`
  - Triggers `GET /api/messages/{id}/resume`
  - On web: `dart:html` anchor-click download (saves as `resume.pdf`)
  - Shows spinner while downloading
- Pull-to-refresh on both tabs
- ← Back to Home / Dashboard button in the app bar

---

### ProfileScreen (User — Tab 4)
- Edit mode for: skills, location, phone, years of experience
- **Upload Resume** card — opens file picker (PDF only, ≤ 10 MB)
  - On upload success: shows a 5-second snackbar and begins background polling
  - `pollUntilParsed()` checks `GET /api/profile/me` every 5 seconds, up to 12 times (1 minute)
  - AI-parsed skills and tech stack displayed as chips once ready
- Logout button (top-right, red icon)

---

### AdminDashboardScreen (Admin — Tab 0)
- Aggregated stats: total users, jobs posted, applications, accepted/rejected/pending
- Calls `GET /api/admin/stats` on load

---

### JobsManagementScreen (Admin — Tab 1)
- Lists all jobs posted by this recruiter (filtered server-side via `ownerEmail`)
- **Create Job** → `CreateJobScreen`
- Tap a job → `JobApplicantsScreen`

---

### JobApplicantsScreen
- Lists all applicants for a selected job
- Accept / Reject buttons call `PUT /api/applications/admin/{id}`

---

## Role-based UI

```
┌──────────────────────────────────────────────────────────┐
│                     Auth Gate                            │
│  AuthProvider reads role from SharedPreferences          │
│                                                          │
│  role == "ROLE_USER"    →  UserShell  (5 tabs)          │
│  role == "ROLE_ADMIN"   →  AdminShell (3 tabs)          │
│  no token               →  LoginScreen                  │
└──────────────────────────────────────────────────────────┘

UserShell providers:
  JobProvider, ApplicationProvider,
  ProfileProvider, MessageProvider

AdminShell providers:
  JobProvider (ownerEmail filter),
  ApplicationProvider, MessageProvider
```

The same `MessagesScreen` widget is reused in both shells. The `onGoHome` callback is wired differently per shell — back to the Jobs tab for users, back to the Dashboard tab for admins.

---

## Design System

### Colour Palette (`app_colors.dart`)

| Token | Hex | Usage |
|-------|-----|-------|
| `background` | `#09090B` | Page backgrounds |
| `surface` | `#13151A` | App bars, cards |
| `cardBg` | `#17191F` | List item cards |
| `divider` | `#252830` | Separators, borders |
| `primary` | `#10B981` | CTAs, active states, success |
| `error` | `#EF4444` | Errors, unread badge |
| `warning` | `#F59E0B` | Pending states, cautions |
| `info` | `#3B82F6` | Messages icon, info pills |
| `accent` | `#6366F1` | Tags, profile elements |
| `textPrimary` | `#F9FAFB` | Main body text |
| `textSecondary` | `#9CA3AF` | Labels, subheadings |
| `textMuted` | `#4B5263` | Placeholders, metadata |
| `aiMatch` | `#8B5CF6` | AI Match purple — tab, badges |

### Typography
All text uses **Inter** via `google_fonts`. Font weights used: 400 (body), 500 (labels), 600 (subheadings), 700 (headings), 800 (company initials).

### Responsive Breakpoint
- `width > 900px` — Desktop layout: bottom nav hidden, full top navbar shown in `HomeScreen`
- `width ≤ 900px` — Mobile layout: bottom nav visible, compact top bar

### Shimmer Loading
The `_Shimmer` widget in `MyApplicationsScreen` provides a pulsing skeleton animation using `AnimationController` + `FadeTransition` while data loads.

---

## Key Data Models

```dart
// Job listing
class JobModel {
  final int    id;
  final String title, description, location;
  final String techStack, companyName, postedBy;
  final int    experienceRequired;
  final String createdAt;
}

// User application
class ApplicationModel {
  final int    id;
  final int?   jobId;
  final String jobTitle, companyName, status, appliedAt;
}

// User profile (includes AI-parsed fields)
class ProfileModel {
  final String  email, skills, location, phone;
  final int     experience;
  final String? parsedSkills, parsedTechStack;
  final bool    resumeUploaded;

  List<String> get parsedSkillsList    => _parseJsonArray(parsedSkills);
  List<String> get parsedTechStackList => _parseJsonArray(parsedTechStack);
}

// In-app message
class MessageModel {
  final int    id;
  final String senderEmail, senderName;
  final String recipientEmail, recipientName;
  final String subject, content, sentAt;
  final int?   jobId;
  bool         read;
  final bool   resumeAttached;
}

// Admin stats
class StatsModel {
  final int totalUsers, myJobs, myApplications;
  final int accepted, rejected, pending;
}
```

---

## Running Locally

### Prerequisites

- Flutter SDK ≥ 3.0.0
- Dart ≥ 3.0.0
- Chrome (for Flutter web)
- HireLoop backend running at `http://localhost:8080`

### Steps

```bash
# 1. Clone the repository
git clone <repo-url>
cd job_portal_frontend

# 2. Install dependencies
flutter pub get

# 3. Verify base URL is pointing to local backend
#    Open lib/core/constants/api_constants.dart
#    Ensure: static String get baseUrl => _localUrl;

# 4. Run in Chrome
flutter run -d chrome
```

The app will open at `http://localhost:XXXX` (Flutter assigns a random port).

### Switching to Production Backend

In `lib/core/constants/api_constants.dart`:

```dart
// For local development:
static String get baseUrl => _localUrl;   // http://localhost:8080

// For production:
static String get baseUrl => _productionUrl; // https://jobportal-backend-z2pv.onrender.com
```

---

## Deployment

The frontend is deployed on **Vercel** as a static Flutter web build.

### Build & Deploy

```bash
# Build Flutter web
flutter build web --release

# The output is at build/web/
# Vercel serves this as a static site
```

### vercel.json

The `vercel.json` in the repository root is configured to output from `build/web` and redirect all routes to `index.html` (required for Flutter web's client-side routing).

### Environment Note

The `baseUrl` in `api_constants.dart` must be set to the production Render URL before building for deployment:

```dart
static String get baseUrl => _productionUrl;
```
