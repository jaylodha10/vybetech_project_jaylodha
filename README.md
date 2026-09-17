# VybeCabs — Rider App

A fast, modern ride-hailing client built with Flutter. Designed with a clean feature-first architecture, responsive map interactions, and realistic turn-by-turn ride simulations.

---

## 1. Architecture Choices

This project uses **Clean Architecture with Feature-First organization**, paired with **`flutter_bloc`** for state management and **`flutter_map`** for mapping.

### Why Feature-First?
Instead of grouping files by generic types (`controllers/`, `views/`, `models/`), the codebase is divided by feature domain:
- `lib/features/auth/` — Sign-in, registration, phone OTP verification, and session persistence.
- `lib/features/booking/` — GPS location discovery, destination search, dynamic fare computation, and ride booking.
- `lib/features/tracking/` — Driver matching simulation, turn-by-turn road navigation, car heading rotation, and trip completion.
- `lib/features/history/` — Past ride receipts and pagination.
- `lib/features/splash/` — Startup screen and session routing.

Shared code is kept strictly separate:
- `lib/core/` — Global configurations (app theme, colors, declarative GoRouter routing, constants, and math/routing utilities).
- `lib/shared/` — Cross-cutting domain models (`Driver`, `Trip`, `RideLocation`, `VehicleCategory`) and reusable UI components (`VybeButton`, `VybeCard`, `DriverInfoCard`).

This structure keeps dependencies unidirectional, isolates feature bugs, and makes testing each module straightforward.

### State Management (`flutter_bloc`)
- **Predictable & testable**: Business logic is separated completely from the UI via explicit events and states.
- **Consistent pattern**: All flows (`AuthBloc`, `BookingBloc`, `TrackingBloc`, `HistoryBloc`) adhere to the same event-driven architecture, avoiding mixed state management approaches.

### Mapping & Routing (`flutter_map` + OpenStreetMap & OSRM)
- Built using **`flutter_map`** with OpenStreetMap raster tiles and **OSRM (Open Source Routing Machine)** for real road polyline calculations.
- **Zero API Keys & Zero Billing Barriers**: No Google Cloud billing accounts, credit cards, or restricted API keys are required to run or review the app. It works immediately on any machine or device out-of-the-box.
- Routes follow actual street layouts, roundabouts, and lake shorelines rather than unrealistic straight-line vectors.

---

## 2. Authentication Method

The app features a **dual-layer authentication flow**:

1. **Production Firebase Auth**:
   - Integrated with `firebase_auth` for Phone Number OTP verification (`verifyPhoneNumber`) and Email/Password sign-in/registration.
2. **Reviewer / Demo Fallback Mode**:
   - If `google-services.json` is not provided or SMS quotas fail, the app switches to an offline demo authentication flow so reviewers can test without friction:
     - **Phone OTP**: Pre-filled with `+91 9876543210` and accepts demo OTP `123456`.
     - **Email Sign-in**: Pre-filled with `rider@vybecabs.com` / `vybe1234`.
3. **Session Persistence**:
   - Auth tokens and user session states are saved via `SharedPreferences`. Once logged in, restarting the app automatically bypasses the auth screen and takes the rider directly to the map home screen.

---

## 3. Dummy Data Structure

All mock data is centralized in `lib/features/booking/data/dummy/mock_data.dart` and organized around realistic entities:

### 1. Locations & Curated Udaipur Landmarks
- **Default Pickup**: Anchored at Chetak Circle, Udaipur (`24.5854, 73.6879`) with an Ashwini Road street address.
- **6 Authentic Destinations**:
  - *Fateh Sagar Lake (Paal)* (`24.6025, 73.6738`)
  - *City Palace & Lake Pichola* (`24.5764, 73.6835`)
  - *Celebration Mall, Bhuwana* (`24.6142, 73.7078`)
  - *Maharana Pratap Airport, Dabok* (`24.6177, 73.8961`)
  - *Saheliyon Ki Bari* (`24.6006, 73.6872`)
  - *Udaipur City Railway Station* (`24.5732, 73.6983`)
- **Dynamic Distance & ETA Calculation**: When the user's GPS position is acquired or a destination is picked, `BookingRepository.getDropLocationsFor()` calculates real-time Haversine distances to every point and updates travel times and fares dynamically.

### 2. Vehicle Categories & Dynamic Pricing
Four distinct vehicle classes with realistic pricing and capacity parameters:
| Category | Tagline | Base Fare | Per Km Rate | Seats | Pickup ETA |
|---|---|---|---|---|---|
| **Vybe Go** | Affordable compact hatchbacks | ₹50 | ₹14/km | 4 | 2 mins |
| **Vybe Sedan** | Comfortable sedans with top drivers | ₹80 | ₹18/km | 4 | 4 mins |
| **Vybe XL** | Spacious 6-seater SUVs | ₹130 | ₹25/km | 6 | 6 mins |
| **Vybe Premier** | Premium executive rides | ₹200 | ₹35/km | 4 | 5 mins |

*Fare formula:* `Fare = Base Price + (Price Per Km × Distance in Km)`.

### 3. Driver Profile & Live Navigation Simulation
- **Driver Entity**: Modeled with driver name (`Rajesh Kumar`), photo, vehicle details (`White Swift Dzire`), Udaipur RTO registration (`RJ 27 CZ 4892`), rating (`4.9` with 1,420 trips), and phone number.
- **Road Routing & Heading Rotation**: 
  - Routes from driver to pickup and pickup to drop are fetched live via OSRM (`router.project-osrm.org`).
  - Waypoints are smoothly sampled at 750ms intervals.
  - The vehicle marker dynamically calculates bearing between successive coordinates using spherical trigonometry (`PolylineUtils.getBearing`) so the vehicle icon rotates accurately along the road's curves.

### 4. Past Ride History
- Pre-populated list of completed rides in `HistoryRepository` with unique trip IDs, pickup/drop addresses, timestamps, vehicle names, driver names, and formatted fares.

---

## 4. UI/UX Highlights

- **Camera Centering & Non-Overlapping Bottom Sheet**: The bottom sheet is capped between 38% and 44% screen height, while the map camera applies a southward latitude offset so that both the user location pin and the animated vehicle marker stay centered in the open visible map area.
- **Floating "Locate Me" Button**: Clean floating action button located right above the bottom sheet for instant one-tap GPS re-centering.
- **Theme Support**: Includes both Dark Mode (default, sleek deep-navy and Rapido/Uber yellow) and Light Mode, toggled easily from the top app bar.

---

## 5. How to Run the App

### Prerequisites
- Flutter SDK (3.24+ recommended)
- Android Studio / VS Code with Flutter extension
- Connected Android/iOS physical device or emulator

### Steps
```bash
# 1. Get packages
flutter pub get

# 2. Run static analysis (0 errors, 0 warnings)
flutter analyze

# 3. Run unit tests
flutter test

# 4. Run the app
flutter run
```

---

## 6. Directory Tree

```
lib/
├── main.dart
├── core/
│   ├── constants/
│   │   └── app_constants.dart
│   ├── router/
│   │   └── app_router.dart
│   ├── services/
│   │   └── road_routing_service.dart     # OSRM turn-by-turn road polylines
│   ├── theme/
│   │   ├── app_colors.dart
│   │   └── app_theme.dart
│   └── utils/
│       └── polyline_utils.dart          # Spherical bearing & polyline decoders
├── shared/
│   ├── models/                          # Shared domain entities
│   │   ├── driver.dart
│   │   ├── ride_location.dart
│   │   ├── trip.dart
│   │   └── vehicle_category.dart
│   └── widgets/                         # Design system components
│       ├── driver_info_card.dart
│       ├── radar_animation.dart
│       └── vybe_widgets.dart
└── features/
    ├── splash/                          # Startup & session check
    ├── auth/                            # Firebase & offline fallback auth
    ├── booking/                         # Map, Udaipur landmarks & fare calculation
    ├── tracking/                        # Live road navigation & car bearing rotation
    └── history/                         # Past ride receipts & pagination
```
