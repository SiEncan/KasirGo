# 📠 KasirGo - Modern Point of Sale (POS) Application

![Banner Placeholder](assets/preview_kasirgo.png)

> A high-performance, aesthetically pleasing mobile POS application built with Flutter, designed to streamline retail operations with smart caching and robust state management.

---
## 📖 Overview
KasirGo is a modern solution for small to medium retail businesses. Unlike traditional clunky POS systems, KasirGo focuses on **User Experience (UX)** and **Performance**. The app connects to a robust Django backend (**[View Backend Repository](https://github.com/SiEncan/KasirGo-Backend)**) but is engineered to handle network instability gracefully through robust error handling, smart image caching, and a built-in **Real-Time Kitchen Display System (KDS)**.

---

## ✨ App Features

### 🛒 Smart Point of Sales (POS)
-   **Dynamic Cart Manager**: Add items, adjust quantity, reset order, and view real-time calculations (Subtotal, Tax, Final Total).
-   **Catalog Browsing**: Filter products by **Category** or use **Search** to quickly find items.
-   **Granular Notes**: Add specific notes per item (e.g., "No Spicy", "Less Ice") and Transaction notes (e.g. "GoFood", "Sambelnya Dipisah").
-   **Order Modes**: Support for **Dine In** and **Take Away**. Automatically applies configurable *Take Away Charges*.

### 💳 Flexible Checkout & Payments
-   **Multiple Payment Methods**: Support for **Cash** and **QRIS**.
-   **Payment Gateway Integration**: Integrated with **Duitku** for seamless QRIS generation and status checking.
-   **Smart Change Calculation**: Auto-calculate change for cash payments.

### 📦 Inventory & Catalog Control
-   **Full CRUD Management**: Add, Edit, and Delete Products and Categories with ease.
-   **Smart Management**: Filter inventory by Category or Search to quickly update products.
-   **Product Image Upload**: Supports uploading product images directly from device gallery (sent as **Multipart/Form-Data** to the backend).
-   **Automated Stock System**:
    -   Stock decreases automatically upon checkout.
    -   **Auto-OOS**: Products automatically marked "Unavailable" when stock hits 0, removing them from the menu.

### 📝 Transaction History & Management
-   **Advanced Search**: Filter transactions by `Transaction No`, `Customer Name`, or `Notes`.
-   **Digital Receipt**: Detailed transaction view mimicking a real receipt.
-   **Void/Edit Transaction**:
    -   Edit Customer Name or Notes after transaction.
    -   **Safe Delete**: Deleting a transaction automatically **restores stock** to inventory.

### 👨‍🍳 Kitchen Display System (KDS)
-   **Real-Time Dashboard**: Live order feed for kitchen staff using Hybrid Sync/Fetch architecture.
-   **Smart Urgency Timer**: Color-coded cards (Green/Orange/Red) to track cooking duration in real-time.
-   **Role-Based Access**: Dedicated mode for kitchen staff vs cashiers.
-   **Order Routing**: Automatically filters items that need preparation.

### ⚙️ Store & Profile Settings
-   **Shop Configuration**: Customize Shop Name, Address, and Phone Number for receipts.
-   **Tax & Fees**: Configure Global Tax (%) and Takeaway Charges with a **Live Calculation Preview**.
-   **Local Persistence**: Settings are saved locally on the device for quick access.
-   **Profile Management**: easy-to-use profile update screen.

---

## 🛠 Technical Highlights

### ⚡ Performance Optimization
-   **Image Caching**: Implemented `CachedNetworkImage` with custom `memCacheWidth` to reduce memory usage by ~90% during heavy scrolling.
-   **Debounced Search**: Optimized live search to prevent API flooding.

### 🛡️ Security & Networking (Dio)
-   **Smart Authentication**: Auto-refresh JWT tokens using **Dio Interceptors** ensuring uninterrupted sessions.
-   **Hybrid Authentication**: Implements a **Backend-to-Firebase** token exchange protocol to secure realtime streams without public access.
-   **Robust Error Handling**: Centralized error interceptor to gracefully handle timeouts and connection failures.

### 🏗️ State Management (Riverpod)
-   **Unidirectional Data Flow**: Using Riverpod 2.0 Notifiers for predictable state changes.
-   **Separation of Concerns**: Business logic decoupled from UI widgets.


---

## 💡 Key Challenges & Solutions

### 1. High-Resolution Image Lag
- **Challenge**: Loading hundreds of product images (4MB+ each) in a `GridView` caused significant frame drops and memory spikes on mid-range devices.  
- **Solution**: Implemented `CachedNetworkImage` with specific `memCacheWidth` parameters. This forces the engine to decode images into smaller thumbnails in RAM, reducing memory usage by **~90%** and achieving 60 FPS scrolling.

### 2. Complex Cart State Synchronization
- **Challenge**: Managing cart updates (add, remove, update quantity, notes) across multiple screens caused data inconsistency.  
- **Solution**: Leveraged **Riverpod's Immutable State** pattern (`CartState`). Every update recreates the state object, ensuring UI rebuilds are predictable and eliminating "ghost items" in the cart.

### 3. Efficient Configuration Persistence
- **Challenge**: Storing lightweight settings (Tax Rate, Takeaway Charges) in the database requires unnecessary schema changes, while keeping them in Riverpod state causes data loss on restart.  
- **Solution**: Implemented a **Local-First Strategy** using `SharedPreferences`. Settings are persisted locally on the device, ensuring they survive app restarts without bloating the backend database.

### 4. Secure Authentication Persistence
- **Challenge**: Storing sensitive JWT tokens in `SharedPreferences` is insecure and prone to leaks.  
- **Solution**: Integrated **Flutter Secure Storage** to encrypt tokens in the device's Keystore/Keychain. Coupled with **Dio Interceptors**, the app silently refreshes tokens without user intervention, balancing security with UX.

### 5. Live Search Performance
- **Challenge**: Searching through thousands of transaction records caused API spam and UI freezing.  
- **Solution**: Implemented **Debouncing** (500ms) on the search input and optimized State Notifiers to only redraw the list when necessary, preventing unnecessary builds.

### 6. KDS Data Integrity vs Real-Time Sync
- **Challenge**: Syncing full order data to a NoSQL cloud (Firebase) creates a **"Double Data"** problem where the Cloud state might mismatch the SQL state (e.g., "Ghost Orders" that persist in KDS after being voided in POS due to network failure).
- **Solution**: Rejected full-data sync in favor of a **Hybrid Signal Architecture**. Firebase is used *strictly* as a trigger ("Ding!"). When triggered, KDS fetches the payload directly from the Django SQL database. This guarantees **Single Source of Truth** and 100% data consistency, eliminating sync bugs.

### 7. Securing Multi-Tenant Realtime Streams
- **Challenge**: In a SaaS model, how do we ensure "Cafe A" cannot listen to "Cafe B's" realtime order stream without building a complex backend proxy or forcing every cashier to have a separate Firebase account?
- **Solution**: Implemented a **Hybrid Token Exchange**. The Django Backend (which knows the user's SaaS scope) mints a **Firebase Custom Token** injected with a specific `cafe_id` claim. Firebase Security Rules then reject any listener unless `auth.cafe_id` matches the requested channel. This provides **Zero-Trust Security** at the database level without authentication friction.
---

## 🍳 Kitchen Display System (KDS) & Hybrid Architecture

KasirGo features a **Real-Time Kitchen Display System** that syncs with the POS without complex server infrastructure.

### 📡 Hybrid Architecture (Signal + Fetch)
Instead of syncing complex order data to Firebase (which creates data integrity risks), we use a **Hybrid Approach**. Here is the step-by-step flow:

1.  **[Auth]**: User logs in via backend. The app requests a **Firebase Custom Token** which grants access restricted to their specific Cafe ID.
2.  **[KDS]**: The Kitchen App connects to Firebase Realtime Database and listens to a **Dynamic Path**: `stores/$cafe_id/kitchen_trigger`.
3.  **[POS]**: Cashier completes a transaction. The app saves the full order details to the **Django SQL Database** (Authoritative Source).
4.  **[POS]**: Once saved, the app sends a lightweight *Timestamp Signal* to the specific Firebase path.
5.  **[Firebase]**: Instantly broadcasts this signal to KDS devices belonging to that specific Cafe.
6.  **[KDS]**: Receives the signal ("Ding!").
7.  **[KDS]**: Reacts by asking Django: *"Hey, give me the latest open orders!"* (Fetch API).
8.  **[KDS]**: Updates the screen with the verified data from Django.

**Benefit:** 100% Data Integrity, Multi-Tenant Security, and Real-Time Speed.

### 🛠️ Firebase Setup (Optional for Real-Time)
The KDS works in **Manual Refresh Mode** by default. To enable **Real-Time Automatic Updates**, you must configure Firebase:

1.  **Add Configuration File**: 
    -   Place `google-services.json` in `android/app/`.
    -   *Note: This file is git-ignored for security.*

2. **Hybrid Authentication & Security**
We use **Firebase Custom Tokens** to bridge our JWT Backend with Firebase.
    -   The backend generates a token with a `cafe_id` claim.
    -   Firebase Security Rules enforce that a user can only listen to `stores/$cafe_id`.
    -   Copy this to your Firebase Console Rules:
```json
{
  "rules": {
    "stores": {
      "$cafe_id": {
        ".read": "auth != null && auth.cafe_id === $cafe_id",
        ".write": "auth != null && auth.cafe_id === $cafe_id"
      }
    }
  }
}
```

### 👨‍🍳 Smart Features
-   **Startup Mode Selection**: Choose between **POS Role** or **Kitchen Role** at login. Selection is remembered permanently until you switch it.
-   **Smart Routing**: Only items marked "Needs Preparation" are sent to KDS. Grab & Go items (like bottled water) skip the kitchen.

---

## 🧰 Tech Stack

![Flutter](https://img.shields.io/badge/Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white)
![Dart](https://img.shields.io/badge/Dart-0175C2?style=for-the-badge&logo=dart&logoColor=white)
![Firebase](https://img.shields.io/badge/Firebase-FFCA28?style=for-the-badge&logo=firebase&logoColor=black)

-   **Framework**: [Flutter](https://flutter.dev/) (SDK 3.x)
-   **State Management**: [Riverpod 2.0](https://riverpod.dev/) (Unidirectional Data Flow)
-   **Networking**: Dio (with Interceptors for error handling)
-   **Assets & UI**: 
    -   `cached_network_image`: Optimized image loading.
    -   `qr_flutter`: Generate QRIS codes for dynamic payments from *Duitku* payment gateway.
    -   `barcode_widget`: Render Code 128 barcodes for transaction receipts.
    -   `firebase_auth` & `firebase_database`: For Hybrid Real-time/Auth capabilities.
-   **LocalStorage**: `flutter_secure_storage` for token management.

## 🏗 Architecture

This project follows a **Feature-First** directory structure to ensure distinct separation of concerns and scalability.

```
lib/
├── providers/       # Global State Management (Riverpod)
├── screen/          # UI Logic (Features)
│   ├── home/        # Dashboard & POS Interface
│   ├── history/     # Transaction Logs with Search
│   ├── products/    # CRUD Operations
│   └── checkout/    # Payment Flows
├── services/        # API Communication Layer (Repository Pattern)
└── utils/           # Shared Helpers (Formatters, Dialogs)
```

---

## 🚀 Getting Started

### 1️⃣ Clone the repository
```bash
git clone https://github.com/SiEncan/kasirgo.git
cd kasirgo
```

### 2️⃣ Install dependencies
```bash
flutter pub get
```

### 3️⃣ Run on emulator or device
```bash
flutter run
```
Make sure you have Flutter SDK installed and an emulator/device ready.
