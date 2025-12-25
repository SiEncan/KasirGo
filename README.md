# 📠 KasirGo - Modern Point of Sale (POS) Application

![Banner Placeholder](assets/preview_kasirgo.png)

> A high-performance, aesthetically pleasing mobile POS application built with Flutter, designed to streamline retail operations with smart caching and robust state management.

---
## 📖 Overview
KasirGo is a modern solution for small to medium retail businesses. Unlike traditional clunky POS systems, KasirGo focuses on **User Experience (UX)** and **Performance**. The app connects to a Django backend but is engineered to handle network instability gracefully through robust error handling and smart image caching.

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
-   **Automated Stock System**:
    -   Stock decreases automatically upon checkout.
    -   **Auto-OOS**: Products automatically marked "Unavailable" when stock hits 0, removing them from the menu.

### � Transaction History & Management
-   **Advanced Search**: Filter transactions by `Transaction No`, `Customer Name`, or `Notes`.
-   **Digital Receipt**: Detailed transaction view mimicking a real receipt.
-   **Void/Edit Transaction**:
    -   Edit Customer Name or Notes after transaction.
    -   **Safe Delete**: Deleting a transaction automatically **restores stock** to inventory.

### ⚙️ Store & Profile Settings
-   **Shop Configuration**: Customize Shop Name, Address, and Phone Number for receipts.
-   **Tax & Fees**: Configure Global Tax (%) and Takeaway Charges with a **Live Calculation Preview**.
-   **Local Persistence**: Settings are saved locally on the device for quick access.
-   **Profile Management**: easy-to-use profile update screen.

---

## 🧠 Technical Highlights

### ⚡ Performance Optimization
-   **Image Caching**: Implemented `CachedNetworkImage` with custom `memCacheWidth` to reduce memory usage by ~90% during heavy scrolling.
-   **Debounced Search**: Optimized live search to prevent API flooding.

### 🛡️ Security & Networking (Dio)
-   **Smart Authentication**: Auto-refresh JWT tokens using **Dio Interceptors** ensuring uninterrupted sessions.
-   **Robust Error Handling**: Centralized error interceptor to gracefully handle timeouts and connection failures.

### 🏗️ State Management (Riverpod)
-   **Unidirectional Data Flow**: Using Riverpod 2.0 Notifiers for predictable state changes.
-   **Separation of Concerns**: Business logic decoupled from UI widgets.

---

## 🛠 Tech Stack

![Flutter](https://img.shields.io/badge/Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white)
![Dart](https://img.shields.io/badge/Dart-0175C2?style=for-the-badge&logo=dart&logoColor=white)
![Django](https://img.shields.io/badge/django-%23092E20.svg?style=for-the-badge&logo=django&logoColor=white)
![Vercel](https://img.shields.io/badge/Vercel-000000?style=for-the-badge&logo=vercel&logoColor=white)
![Neon](https://img.shields.io/badge/Neon.com-00E599?style=for-the-badge&logo=neon&logoColor=black)

-   **Framework**: [Flutter](https://flutter.dev/) (SDK 3.x)
-   **State Management**: [Riverpod 2.0](https://riverpod.dev/) (Unidirectional Data Flow)
-   **Networking**: Dio (with Interceptors for error handling)
-   **Assets & UI**: `cached_network_image` for memory optimization.
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
