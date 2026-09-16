# VybeCabs — Rider App

> Flutter Assignment — Full Ride Flow (Dummy Data)  
> Submitted by: **Jay Lodha**

---

## App Name & Logo

**VybeCabs** — Blending "Vybe" with a fast, modern, premium cab ride experience.

The logo features a stylish **yellow V-mark** on a deep navy background — inspired by Rapido/Uber's minimal design aesthetic. The vector asset is located at `assets/images/logo.svg`.

---

## Architecture: Clean Architecture (Feature-First)

The project strictly follows **Clean Architecture with Feature-First Organization** as mandated by `REQUIREMENTS.md`:

- `lib/core/` — Global configurations: theme (`AppColors`, `AppTheme`), router (`AppRouter`), constants, and math/map utilities (`PolylineUtils`).
- `lib/shared/` — Common entities across features: shared models (`Driver`, `Trip`, `RideLocation`, `VehicleCategory`) and shared design-system UI components (`VybeButton`, `VybeCard`, `VybeTextField`, `DriverInfoCard`, `RadarAnimation`).
- `lib/features/` — Domain & presentation partitioned per feature:
  - `splash/` — Brand splash screen with session verification.
  - `auth/` — Firebase Authentication & local demo fallback repository, BLoC, and login/register UI.
  - `booking/` — GPS location fetching, interactive "Where to?" destination search, vehicle category selection with live ETAs, fare calculation, and Booking BLoC.
  - `tracking/` — Radar finding driver simulation, live GPS polyline navigation with vehicle heading rotation, auto-arrival, and trip completion summary.
  - `history/` — Past ride log repository with pagination, History BLoC, and detailed ride receipts.

### Directory Structure

```
lib/
├── main.dart
├── core/
│   ├── constants/
│   │   └── app_constants.dart
│   ├── router/
│   │   └── app_router.dart
│   ├── theme/
│   │   ├── app_colors.dart
│   │   └── app_theme.dart
│   └── utils/
│       └── polyline_utils.dart
├── shared/
│   ├── models/
│   │   ├── driver.dart
│   │   ├── ride_location.dart
│   │   ├── trip.dart
│   │   └── vehicle_category.dart
│   └── widgets/
│       ├── driver_info_card.dart
│       ├── radar_animation.dart
│       └── vybe_widgets.dart
└── features/
    ├── splash/
    │   └── presentation/screens/splash_screen.dart
    ├── auth/
    │   ├── data/repositories/auth_repository.dart
    │   └── presentation/
    │       ├── bloc/ (auth_bloc.dart, auth_event.dart, auth_state.dart)
    │       └── screens/auth_screen.dart
    ├── booking/
    │   ├── data/
    │   │   ├── dummy/mock_data.dart
    │   │   └── repositories/booking_repository.dart
    │   └── presentation/
    │       ├── bloc/ (booking_bloc.dart, booking_event.dart, booking_state.dart)
    │       └── screens/home_screen.dart
    ├── tracking/
    │   └── presentation/
    │       ├── bloc/ (tracking_bloc.dart, tracking_event.dart, tracking_state.dart)
    │       └── screens/
    │           ├── finding_driver_screen.dart
    │           └── live_tracking_screen.dart
    └── history/
        ├── data/
        │   ├── models/ride_history_item.dart
        │   └── repositories/history_repository.dart
        └── presentation/
            ├── bloc/ (history_bloc.dart, history_event.dart, history_state.dart)
            └── screens/history_screen.dart
```

---

## State Management (`flutter_bloc`)

**flutter_bloc** is applied consistently across all flows without any mixing of other state management libraries:

| BLoC | Features / Screens | Responsibility |
|------|--------------------|----------------|
| `AuthBloc` | Splash, Auth | Persistent session check, Phone OTP, Email/Password auth, Logout |
| `BookingBloc` | Home / Booking | GPS location detection, "Where to?" drop selection, vehicle option selection, fare computation, Trip creation |
| `TrackingBloc` | Finding Driver, Live Tracking | Radar search simulation, vehicle waypoint animation, car bearing heading, driver arrival, trip progress, completion |
| `HistoryBloc` | Ride History | Paginated ride records, lazy load more, state persistence |

---

## Navigation (`go_router`)

Declarative routing configured in `lib/core/router/app_router.dart`:

| Path | Screen | Behavior |
|------|--------|----------|
| `/` | `SplashScreen` | Checks authentication session and auto-routes |
| `/auth` | `AuthScreen` | Tabbed Phone OTP and Email sign-in / registration |
| `/home` | `HomeScreen` | Google Map, "Where to?" search bar, vehicle options with ETA & fare |
| `/finding-driver` | `FindingDriverScreen` | 3.5s radar search animation & driver assignment card |
| `/live-tracking` | `LiveTrackingScreen` | Live animated car marker, bearing rotation, auto-arrival, trip receipt |
| `/history` | `HistoryScreen` | Paginated past rides list with detailed bottom sheet receipts |

---

## Authentication & Offline Fallback Demo Mode

The assignment explicitly permits local testing without backend servers:
1. **Firebase Authentication (Real Flow)**:
   - Phone verification: `FirebaseAuth.instance.verifyPhoneNumber`.
   - Email/Password: `FirebaseAuth.instance.signInWithEmailAndPassword` / `createUserWithEmailAndPassword`.
2. **Reviewer Demo Mode (Automatic Fallback)**:
   - If `google-services.json` is not provided or offline, the app executes seamlessly without crashing:
     - **Phone OTP**: Pre-filled `+91 9876543210`, Demo OTP `123456`.
     - **Email Sign In**: Pre-filled `rider@vybecabs.com` / `vybe1234`.
   - User sessions are safely persisted via `SharedPreferences` for auto-login on restart.

---

## Live Tracking Simulation

The `TrackingBloc` drives smooth multi-phase map animation:
1. **Driver → Pickup** (`driverToPickupRoute`): 5 waypoints interpolated into smooth sub-steps.
2. **Heading & Bearing**: `PolylineUtils.getBearing` dynamically rotates the vehicle marker (`flat: true`, `rotation: carBearing`) in real time.
3. **Auto-Arrival & Auto-Start**: Automatically announces arrival at pickup and transitions to trip progress toward destination after a short countdown (with manual "Start Trip Now" override).
4. **Pickup → Drop** (`pickupToDropRoute`): Traverses route to drop destination, triggering the Trip Completed receipt sheet.

---

## Theme & Design System

- **Dark Mode (Default)** & **Light Mode** supported via top-level `themeModeNotifier` toggle on the home screen.
- Colors: Jet Black (`#1A1A2E`, `#16213E`) + Rapido/Uber Golden Yellow (`#FFD60A`).
- Typography: Plus Jakarta Sans via `google_fonts`.

---

## Setup & Testing Instructions

```bash
# 1. Install dependencies
flutter pub get

# 2. Run static analysis (0 errors, 0 warnings)
flutter analyze

# 3. Run unit & domain tests
flutter test

# 4. Run the app
flutter run
```

---

## Submission Checklist

- [x] **Feature-first Clean Architecture**: `features/`, `core/`, `shared/`
- [x] **BLoC State Management**: Consistently applied across Auth, Booking, Tracking, History
- [x] **Interactive "Where to?" Search**: Real-time location search and filtering
- [x] **Vehicle Categories with ETA & Dynamic Fare**: 4 vehicle categories with pickup ETA badges
- [x] **Simulated Driver Search**: Radar animation + matching result
- [x] **Live Tracking Animation**: Vehicle marker heading rotation & auto-trip progression
- [x] **Ride History**: Paginated past rides with detailed receipt sheets
- [x] **Unit Tests Passed**: `flutter test` passing 100%
- [ ] **Google Services JSON** (Optional for production real SMS): Place in `android/app/google-services.json`
- [ ] **Google Maps Key** (Optional for production satellite tiles): Add in `AndroidManifest.xml`
- [ ] **Release APK**: Run `flutter build apk --release`
- [ ] **Demo Video**: Record 2–3 minute screen walkthrough
