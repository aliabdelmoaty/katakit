# Katakit - 🐣 Katakit App

[![Ask DeepWiki](https://devin.ai/assets/askdeepwiki.png)](https://deepwiki.com/aliabdelmoaty/katakit)

**Katakit** is a Flutter-based app designed to help poultry farmers manage chick batches with ease and efficiency. The app focuses on tracking expenses, recording deaths, and managing sales in order to accurately calculate profit and loss for each batch.

## ✨ Key Features

* **Batch Management:** Record details of each batch such as name, supplier, quantity, purchase price, and target selling price.
* **Expenses (Additions):** Add all batch-related expenses like feed and medicine to calculate actual costs.
* **Deaths Tracking:** Record the number of deaths and their dates, with automatic deduction from the remaining quantity.
* **Sales Management:** Log sales operations including buyer details, quantity, price, and amount paid.
* **Comprehensive Statistics:** Display a summary for each batch showing remaining chicks, total expenses, total sales, and profit or loss.
* **Data Sync:** Works offline and automatically syncs with the cloud when a connection is available.
* **Authentication:** Secure login/logout system to protect user data.

## 🛠️ Tech Stack

| Layer                    | Technology                       |
| ------------------------ | -------------------------------- |
| **Architecture**         | Clean Architecture               |
| **State Management**     | Cubit (flutter\_bloc)            |
| **Local Database**       | Hive DB (Offline-first)          |
| **Backend & Sync**       | Supabase (Auth, Database)        |
| **Dependency Injection** | GetIt                            |
| **Responsive UI**        | flutter\_screenutil + MediaQuery |
| **UI/UX**                | Material Design 3, Arabic (RTL)  |

## 🏗️ App Architecture (Clean Architecture)

The project follows **Clean Architecture** to enforce separation of concerns, making the codebase more organized, testable, and maintainable.

```
lib/
├── core/               # Widgets, Services, Entities, Repositories, UseCases
├── features/           # Feature-specific logic (Auth, Batches, Sales, etc.)
│   ├── auth/
│   ├── batches/
│   └── ...
└── main.dart           # Entry point
```

## 🔄 Offline-First with Sync Support

The app is designed to work seamlessly even without an internet connection.

1. **Local Database (Hive):** All data (batches, sales, etc.) is stored locally using the fast Hive database.
2. **Sync Queue:** Any changes (add, update, delete) are recorded in a local queue.
3. **Automatic Sync (Supabase):** Once an internet connection is available, the app processes the queue and syncs with Supabase cloud database, ensuring no data loss and availability across devices.

## 🚀 Getting Started

To run a local copy of the project, follow these steps:

### Prerequisites

* Install [Flutter SDK](https://flutter.dev/docs/get-started/install) (version 3.7.0 or higher).
* Create a [Supabase](https://supabase.com/) account to set up your project.

### Setup

1. **Clone the repository:**

   ```sh
   git clone https://github.com/aliabdelmoaty/katakit.git
   cd katakit
   ```

2. **Install dependencies:**

   ```sh
   flutter pub get
   ```

3. **Configure Supabase:**

   * Create a new project in Supabase.
   * Use the SQL editor to create required tables (schema can be found in `lib/core/entities/`).
   * Replace the Supabase keys in `lib/main.dart` with your project keys:

   ```dart
   // lib/main.dart
   const supabaseUrl = 'YOUR_SUPABASE_URL';
   const supabaseAnonKey = 'YOUR_SUPABASE_ANON_KEY';
   ```

4. **Run the app:**

   ```sh
   flutter run
   ```

---
