# Vybe Cabs — Flutter Developer Assignment
## Rider App — Full Ride Flow (Dummy Data)

### Overview
Build the complete rider-side experience of the VybeCabs app — from login to ride completion — using Firebase Authentication for login and local dummy data for everything else (no backend or external APIs required).

---

### Key Requirements & Features

1. **Splash Screen**
   - Display Vybe Cabs app logo / brand assets.
   - Check Firebase Auth state (persistent login check).
   - Route to **Auth Screen** or **Home Screen** accordingly.

2. **Auth Screen (Firebase Authentication)**
   - Login using Firebase Auth:
     - Phone Number + OTP (Firebase real OTP flow) OR Email/Password (explicitly documented in README).
   - Basic input validation (valid email/phone format, password strength).
   - Loading state during authentication.
   - User-friendly error handling (wrong OTP / invalid credentials / network errors).
   - On success: Navigate to **Home Screen** and persist session for auto-login on app restart.

3. **Home Screen**
   - Google Map (`google_maps_flutter`) centered on current location using device GPS permission (`geolocator`).
   - "Where to?" search bar and expandable bottom sheet.
   - Dummy list of 4–5 hardcoded locations (e.g. Airport, Tech Park, City Center, Railway Station, Shopping Mall).
   - Tapping a location sets it as the drop location.
   - Display dynamic dummy fare, vehicle options (Vybe Go, Vybe Sedan, Vybe XL, Vybe Premier), and ETA.
   - "Book Ride" button to initiate booking flow.

4. **Finding Driver Screen**
   - Simulated searching animation (3–5 seconds loading state with pulsing radar / glowing animations).
   - Simulated driver matching result: assigned dummy driver with name, photo/avatar, vehicle details (car model & number plate), and rating loaded from local dummy data.

5. **Live Tracking Screen**
   - Google Map showing pickup pin, dropoff pin, and an animated vehicle marker.
   - Driver marker moving smoothly along path 1 toward pickup point (simulated using hardcoded lat-lng waypoints with Timer / `AnimationController`).
   - Driver info card with live status, driver name, vehicle info, and ETA countdown.
   - Auto-transition when marker reaches pickup -> "Driver Arrived".
   - Start trip animation moving marker along path 2 toward drop location.
   - Transition to **Trip Completed** summary screen on arrival.

6. **Ride History Screen**
   - Local dummy list of 5–6 past rides with date, time, pickup location, drop location, fare, ride status, and vehicle type.
   - Rendered in a clean, interactive, scrollable UI list.

7. **State Management & Architecture**
   - BLoC pattern (`flutter_bloc`) applied consistently across all flows (Auth, Booking, Live Tracking, Ride History).
   - Clean Architecture: Feature-first directory structure (`features/`, `core/`, `shared/`).
   - Local JSON / Repository mock system designed to easily swap dummy data for real backend APIs.

---

### Deliverables & Submission Checklist
- **GitHub Repository**: Pushed code with clear commit history.
- **Built APK**: Generated release/debug APK for direct installation and testing.
- **Demo Video**: 2–3 minute screen recording demonstrating full flow end-to-end.
- **README.md**: Comprehensive explanation of architecture choices, Auth method used, dummy data structure, and build/run instructions.
