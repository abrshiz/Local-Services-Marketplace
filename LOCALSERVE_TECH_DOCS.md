# LocalServe — Local Services Marketplace
## System Technical Documentation Suite

This document serves as the official, production-ready **Technical Documentation Suite** for **LocalServe**, a modern peer-to-peer marketplace connecting Customers with trusted local Service Providers (Plumbers, Electricians, Cleaners, Painters, etc.). 

Prepared for **Instructor Review** and **Team Reference**, this documentation outlines the architecture, requirements, MySQL database schema design, REST API specifications, and frontend/backend integration of the LocalServe platform.

---

## Table of Contents
1. [Software Requirements Specification (SRS)](#1-software-requirements-specification-srs)
   - [1.1 Platform Roles & Permissions](#11-platform-roles--permissions)
   - [1.2 Visual Interface & Feature Mapping](#12-visual-interface--feature-mapping)
2. [Database Schema & Architecture (MySQL)](#2-database-schema--architecture-mysql)
   - [2.1 Entity Relationship Diagram (ERD)](#21-entity-relationship-diagram-erd)
   - [2.2 Production MySQL DDL Script](#22-production-mysql-ddl-script)
   - [2.3 Schema Optimizations & Indexes](#23-schema-optimizations--indexes)
3. [System Architecture & Backend Design](#3-system-architecture--backend-design)
   - [3.1 Backend Architectural Layers](#31-backend-architectural-layers)
   - [3.2 Authentication & Security Protocols](#32-authentication--security-protocols)
4. [REST API Specifications](#4-rest-api-specifications)
   - [4.1 API Endpoints Directory](#41-api-endpoints-directory)
   - [4.2 Comprehensive Endpoint Payloads](#42-comprehensive-endpoint-payloads)
5. [Flutter Client Architecture](#5-flutter-client-architecture)
   - [5.1 Clean Architecture Model](#51-clean-architecture-model)
   - [5.2 Client Side State Management & Services](#52-client-side-state-management--services)
6. [Installation & Deployment Guide](#6-installation--deployment-guide)
   - [6.1 Quick-Start Commands](#61-quick-start-commands)
   - [6.2 Build Environment Scenarios](#62-build-environment-scenarios)
   - [6.3 Android Google Maps Configuration](#63-android-google-maps-configuration)
7. [Testing & Verification Protocol](#7-testing--verification-protocol)
   - [7.1 Pre-seeded Demo Accounts](#71-pre-seeded-demo-accounts)
   - [7.2 Verification Checklist](#72-verification-checklist)

---

## 1. Software Requirements Specification (SRS)

### 1.1 Platform Roles & Permissions

The LocalServe system supports two primary authenticated user roles. Session authentication is implemented via JSON Web Tokens (JWT) stored client-side.

| Role | Core Purpose | Functional Capabilities & Permissions |
| :--- | :--- | :--- |
| **Customer** | End-users seeking professional home and local services. | <ul><li>Browse categories and dynamically search for nearby providers.</li><li>Filter providers by rating, service category, price, and distance.</li><li>Create bookings and select preferred available date/time slots.</li><li>Track booking lifecycles in real-time.</li><li>Engage in private messaging with service providers.</li><li>Submit ratings and text reviews for completed services.</li><li>Manage multiple saved addresses and card/cash payments.</li></ul> |
| **Service Provider** | Professionals offering on-demand services. | <ul><li>Register, create profiles, and select specific work categories.</li><li>Define service titles, detailed descriptions, and base prices.</li><li>Manage operational availability status and time slots.</li><li>Accept, decline, and monitor customer booking requests.</li><li>Access an earnings overview and scheduled tasks dashboard.</li><li>Engage in real-time chat with clients concerning active orders.</li></ul> |

---

### 1.2 Visual Interface & Feature Mapping

Based on the official **LocalServe user interface mockups**, the mobile client implements five high-fidelity feature interfaces:

```
+-----------------------------------------------------------------------------------+
|  [Onboarding/Auth]      [Discovery/Map]       [Service booking]       [Inbox Chat] |
|   * Standard JWT log    * Category scroll      * Select calendar       * Live bubble|
|   * Role Selection      * Nearby listings      * Service details       * Send/read  |
|   * Google SSO option   * Rating filters       * Interactive slot      * Avatar sync|
+-----------------------------------------------------------------------------------+
```

1. **Authentication & Onboarding Screen (`sign_up_login_screen`)**:
   - **Form Fields**: Dual login/registration tabs for Customers and Providers. Captures name, email, phone number, password, and optionally a professional bio and work categories.
   - **Role Selection**: Explicit toggle button between Customer and Provider that dynamically alters the sign-up fields (reveals professional categories and bios for providers).
   - **JWT Persistent State**: Client side caching of JWT in `SharedPreferences` to route authenticated users directly past the landing screens.

2. **Customer Discovery & Home Screen (`home_screen`)**:
   - **Geo-Location Sync**: Queries GPS coordinates via `Geolocator` and displays a human-readable neighborhood/street address header.
   - **Category Bar**: Horizontal interactive list of categories (e.g., Cleaning, Electrical, Gardening, Plumbing) with dynamic icons.
   - **Provider Matrix**: Visual listing of local professionals including profile avatar, name, verification badge, distance in kilometers, star rating, hourly price, and a real-time availability indicator (`available` vs. `busy`).

3. **Booking Details & Flow Screen (`booking_screen`)**:
   - **Interactive Scheduler**: Renders a custom calendar (powered by `table_calendar`) to select dates and scrollable grids of daily time slots registered by the provider.
   - **Price Summary & Notes**: Shows base price, booking summary, optional text notes, and a payment type selector (Stripe/Card or Cash on Delivery).

4. **Real-time Messaging Screen (`messages_screen` / `chat_screen`)**:
   - **Inbox view**: Lists all conversations sorted chronologically by the latest text, complete with unread indicator badges.
   - **Active Chat Window**: Displays message bubble streams marked with standard sender-receiver orientation, timestamps, and delivery/read indicators.

5. **Profile Settings & Availability Console (`profile_screen`)**:
   - **Provider Console**: For registered providers, includes settings to customize services, toggle availability status between Active and Offline, and manage specific time slots.
   - **Customer Panel**: Allows customers to view loyalty points, add/remove multiple saved addresses, and view booking history.

---

## 2. Database Schema & Architecture (MySQL)

The LocalServe database relies on an optimized, highly structured relational layout built on **MySQL (v8.0+)**. The official database is named **`Local Market Place`**. 

Primary keys are dynamically handled via standard UUID strings. Foreign key constraints are strictly enforced using the transaction-safe **InnoDB** storage engine, and high performance is guaranteed via indexed lookup trees.

### 2.1 Entity Relationship Diagram (ERD)

```mermaid
erDiagram
    USERS ||--o{ ADDRESSES : "saves (1:N)"
    USERS ||--o{ PROVIDER_SKILLS : "has_skills (1:N)"
    USERS ||--o{ SERVICES : "offers (1:N)"
    USERS ||--o{ TIME_SLOTS : "manages (1:N)"
    USERS ||--o{ BOOKINGS : "makes_or_receives (1:N)"
    USERS ||--o{ CONVERSATIONS : "chats (1:N)"
    CATEGORIES ||--o{ PROVIDER_SKILLS : "contains (1:N)"
    CATEGORIES ||--o{ SERVICES : "classifies (1:N)"
    SERVICES ||--o{ BOOKINGS : "ordered (1:1)"
    TIME_SLOTS ||--o? BOOKINGS : "reserves (0..1:1)"
    BOOKINGS ||--o{ PAYMENTS : "billed (1:N)"
    BOOKINGS ||--o? REVIEWS : "evaluated (1:1)"
    CONVERSATIONS ||--o{ MESSAGES : "contains (1:N)"
```

---

### 2.2 Production MySQL DDL Script

The production database schema is declared using standard MySQL DDL. It initializes the **`Local Market Place`** namespace and sets up 12 relational tables:

```sql
-- Create and set active the master team database
CREATE DATABASE IF NOT EXISTS `Local Market Place`;
USE `Local Market Place`;

-- =========================================================================
-- 1. USERS TABLE
-- Stores profile details for both Customers and Providers (role-differentiated)
-- =========================================================================
CREATE TABLE IF NOT EXISTS users (
  user_id VARCHAR(36) PRIMARY KEY,
  name VARCHAR(255) NOT NULL,
  email VARCHAR(255) NOT NULL UNIQUE,
  password_hash VARCHAR(255) NOT NULL,
  phone VARCHAR(50),
  role VARCHAR(50) NOT NULL, -- 'CUSTOMER' or 'PROVIDER'
  created_at DATETIME NOT NULL,
  updated_at DATETIME NOT NULL,
  bio TEXT, -- Professional description (Provider-specific)
  average_rating DECIMAL(3, 2) DEFAULT 0.00, -- Dynamic rating (Provider-specific)
  is_verified TINYINT(1) DEFAULT 0, -- Verification flag (0 = No, 1 = Yes)
  is_active TINYINT(1) DEFAULT 1, -- Active status toggle
  latitude DECIMAL(10, 8), -- Current GPS Latitude (Provider-specific)
  longitude DECIMAL(11, 8), -- Current GPS Longitude (Provider-specific)
  default_address_id VARCHAR(36), -- User-defined primary address
  loyalty_points INT DEFAULT 0 -- Gamified engagement metric
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- =========================================================================
-- 2. ADDRESSES TABLE
-- Stores multiple customer shipping/service destination addresses
-- =========================================================================
CREATE TABLE IF NOT EXISTS addresses (
  address_id VARCHAR(36) PRIMARY KEY,
  user_id VARCHAR(36) NOT NULL,
  label VARCHAR(100), -- e.g. 'Home', 'Work', 'Office'
  street VARCHAR(255),
  city VARCHAR(100),
  state VARCHAR(100),
  country VARCHAR(100),
  postal_code VARCHAR(20),
  latitude DECIMAL(10, 8),
  longitude DECIMAL(11, 8),
  is_default TINYINT(1) DEFAULT 0, -- Binary flag (0 = false, 1 = true)
  FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- =========================================================================
-- 3. CATEGORIES TABLE
-- Marketplace listing taxonomies
-- =========================================================================
CREATE TABLE IF NOT EXISTS categories (
  category_id VARCHAR(36) PRIMARY KEY,
  name VARCHAR(255) NOT NULL,
  description TEXT,
  icon_url VARCHAR(1024)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- =========================================================================
-- 4. PROVIDER SKILLS TABLE
-- Many-to-Many bridge linking Providers with their operational Categories
-- =========================================================================
CREATE TABLE IF NOT EXISTS provider_skills (
  provider_id VARCHAR(36) NOT NULL,
  category_id VARCHAR(36) NOT NULL,
  PRIMARY KEY (provider_id, category_id),
  FOREIGN KEY (provider_id) REFERENCES users(user_id) ON DELETE CASCADE,
  FOREIGN KEY (category_id) REFERENCES categories(category_id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- =========================================================================
-- 5. SERVICES TABLE
-- Actual services created by providers under marketplace categories
-- =========================================================================
CREATE TABLE IF NOT EXISTS services (
  service_id VARCHAR(36) PRIMARY KEY,
  provider_id VARCHAR(36) NOT NULL,
  category_id VARCHAR(36) NOT NULL,
  title VARCHAR(255) NOT NULL,
  description TEXT,
  price_type VARCHAR(50) NOT NULL, -- 'FIXED' or 'HOURLY'
  base_price DECIMAL(10, 2) NOT NULL,
  is_active TINYINT(1) DEFAULT 1,
  FOREIGN KEY (provider_id) REFERENCES users(user_id) ON DELETE CASCADE,
  FOREIGN KEY (category_id) REFERENCES categories(category_id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- =========================================================================
-- 6. TIME SLOTS TABLE
-- Custom schedule units registered by providers to facilitate bookings
-- =========================================================================
CREATE TABLE IF NOT EXISTS time_slots (
  slot_id VARCHAR(36) PRIMARY KEY,
  provider_id VARCHAR(36) NOT NULL,
  start_time DATETIME NOT NULL, -- ISO 8601 string parsed into SQL DATETIME
  end_time DATETIME NOT NULL,
  is_available TINYINT(1) DEFAULT 1,
  FOREIGN KEY (provider_id) REFERENCES users(user_id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- =========================================================================
-- 7. BOOKINGS TABLE
-- Orchestrates the core transaction between Customers, Providers, and Services
-- =========================================================================
CREATE TABLE IF NOT EXISTS bookings (
  booking_id VARCHAR(36) PRIMARY KEY,
  customer_id VARCHAR(36) NOT NULL,
  provider_id VARCHAR(36) NOT NULL,
  service_id VARCHAR(36) NOT NULL,
  slot_id VARCHAR(36) NULL,
  scheduled_time DATETIME NOT NULL,
  end_time DATETIME NOT NULL,
  status VARCHAR(50) NOT NULL, -- 'PENDING', 'CONFIRMED', 'CANCELLED', 'IN_PROGRESS', 'COMPLETED'
  total_price DECIMAL(10, 2) NOT NULL,
  address_id VARCHAR(36) NULL,
  notes TEXT,
  service_started_at DATETIME NULL,
  service_completed_at DATETIME NULL,
  FOREIGN KEY (customer_id) REFERENCES users(user_id) ON DELETE RESTRICT,
  FOREIGN KEY (provider_id) REFERENCES users(user_id) ON DELETE RESTRICT,
  FOREIGN KEY (service_id) REFERENCES services(service_id) ON DELETE RESTRICT,
  FOREIGN KEY (slot_id) REFERENCES time_slots(slot_id) ON DELETE SET NULL,
  FOREIGN KEY (address_id) REFERENCES addresses(address_id) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- =========================================================================
-- 8. PAYMENTS TABLE
-- Tracks transactional histories tied directly to bookings
-- =========================================================================
CREATE TABLE IF NOT EXISTS payments (
  payment_id VARCHAR(36) PRIMARY KEY,
  booking_id VARCHAR(36) NOT NULL,
  amount DECIMAL(10, 2) NOT NULL,
  status VARCHAR(50) NOT NULL, -- 'PENDING', 'PAID', 'FAILED'
  method VARCHAR(50) NOT NULL, -- 'CARD', 'CASH', 'WALLET'
  transaction_ref VARCHAR(100), -- Gateway Reference string (e.g. 'TX-UUID')
  paid_at DATETIME NULL,
  FOREIGN KEY (booking_id) REFERENCES bookings(booking_id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- =========================================================================
-- 9. REVIEWS TABLE
-- Stores customer feedback and ratings, enforcing one review per booking
-- =========================================================================
CREATE TABLE IF NOT EXISTS reviews (
  review_id VARCHAR(36) PRIMARY KEY,
  booking_id VARCHAR(36) NOT NULL UNIQUE,
  reviewer_id VARCHAR(36) NOT NULL,
  provider_id VARCHAR(36) NOT NULL,
  rating INT NOT NULL, -- Restricted between 1 and 5
  comment TEXT,
  created_at DATETIME NOT NULL,
  FOREIGN KEY (booking_id) REFERENCES bookings(booking_id) ON DELETE CASCADE,
  FOREIGN KEY (reviewer_id) REFERENCES users(user_id) ON DELETE CASCADE,
  FOREIGN KEY (provider_id) REFERENCES users(user_id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- =========================================================================
-- 10. NOTIFICATIONS TABLE
-- Audits alert triggers distributed to the users
-- =========================================================================
CREATE TABLE IF NOT EXISTS notifications (
  id VARCHAR(36) PRIMARY KEY,
  user_id VARCHAR(36) NOT NULL,
  title VARCHAR(255) NOT NULL,
  body TEXT NOT NULL,
  created_at DATETIME NOT NULL,
  FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- =========================================================================
-- 11. CONVERSATIONS TABLE
-- Connects Customers and Providers in unified active dialogs
-- =========================================================================
CREATE TABLE IF NOT EXISTS conversations (
  conversation_id VARCHAR(36) PRIMARY KEY,
  customer_id VARCHAR(36) NOT NULL,
  provider_id VARCHAR(36) NOT NULL,
  updated_at DATETIME NOT NULL,
  UNIQUE(customer_id, provider_id),
  FOREIGN KEY (customer_id) REFERENCES users(user_id) ON DELETE CASCADE,
  FOREIGN KEY (provider_id) REFERENCES users(user_id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- =========================================================================
-- 12. MESSAGES TABLE
-- Audit logs of private text transmissions inside conversation rooms
-- =========================================================================
CREATE TABLE IF NOT EXISTS messages (
  message_id VARCHAR(36) PRIMARY KEY,
  conversation_id VARCHAR(36) NOT NULL,
  sender_id VARCHAR(36) NOT NULL,
  body TEXT NOT NULL,
  created_at DATETIME NOT NULL,
  FOREIGN KEY (conversation_id) REFERENCES conversations(conversation_id) ON DELETE CASCADE,
  FOREIGN KEY (sender_id) REFERENCES users(user_id) ON DELETE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
```

---

### 2.3 Schema Optimizations & Indexes

To deliver premium responsiveness under heavy concurrency in MySQL:

*   **B-Tree Indexes for Core Lookups**:
    *   Dynamic composite B-Tree indexes speed up conversation logs:
        ```sql
        CREATE INDEX idx_messages_conversation ON messages(conversation_id, created_at);
        ```
    *   Index key for rapid authentication is handled automatically by marking `email` as `UNIQUE`.
*   **Geospatial Distance Calculations**:
    *   Using MySQL's native trigonometry, coordinates `latitude` and `longitude` are evaluated via the **Haversine formula** inside `SELECT` queries to isolate providers within specified boundaries.

---

## 3. System Architecture & Backend Design

### 3.1 Backend Architectural Layers

The Express backend application adopts a standard, clean multi-tier structure to decouple logical tasks:

```
[Client App] ---> [Express Server (index.js)] ---> [Middleware (auth.js)]
                        |
                        +---> [Database Access & Mappers (db.js & userMapper.js)]
                                     |
                                     v
                  [(MySQL Server) DB: Local Market Place]
```

1. **Routing & Core App (`src/index.js`)**: Starts the server, coordinates endpoints, registers routing structures, and parses JSON input streams.
2. **Security & Authentication Middleware (`src/middleware/auth.js`)**: Intercepts secure HTTP requests. Ensures the `Authorization: Bearer <token>` header is present and decodes the JWT payload, extracting the `userId` for use in downstream controllers.
3. **Data Mappers (`src/userMapper.js`)**: Resolves MySQL query structures into nested, standardized JSON models matching the exact entities defined in the Flutter application.
4. **Database Pool Driver (`src/db.js`)**: Replaces standard SQLite interfaces with a high-performance **MySQL Connection Pool** (`mysql2`), utilizing persistent, reusable sockets.

---

### 3.2 Authentication & Security Protocols

*   **Password Hashing**: User passwords are encrypted on the backend prior to storage. LocalServe uses **bcryptjs** (with $10$ salt rounds) to generate cryptographic hashes.
*   **JWT Handshake & Tokens**:
    *   **Token Generation**: Upon successful email/password matches, the server returns an encrypted JSON Web Token signed with a strong secure key secret.
    *   **Token Payload**: Contains the user ID (`userId`), token generation timestamp, and expiration period (typically set to 30 days).
    *   **Token Verification**: Applied to all endpoints containing user data, ensuring cross-tenant privacy (e.g., users can only view their own bookings and messages).

---

## 4. REST API Specifications

### 4.1 API Endpoints Directory

All HTTP requests use `application/json` format. Standard protected routes require the `Authorization` header.

| Category | HTTP Method | Endpoint Path | Auth Req. | Purpose |
| :--- | :--- | :--- | :--- | :--- |
| **Auth** | `POST` | `/api/v1/auth/login` | No | Authenticats credentials and returns JWT + user profile. |
| **Auth** | `POST` | `/api/v1/auth/register` | No | Registers user (Customer or Provider) and returns JWT. |
| **Auth** | `GET` | `/api/v1/auth/me` | Yes | Retrieves the caller's active user object from token. |
| **Auth** | `POST` | `/api/v1/auth/logout` | No | Standard endpoint to safely complete client session drop. |
| **Discovery**| `GET` | `/api/v1/categories` | No | Lists all available marketplace work categories. |
| **Discovery**| `GET` | `/api/v1/services` | No | Retrieves services, filterable by `categoryId`/`providerId`.|
| **Discovery**| `GET` | `/api/v1/providers/nearby`| Yes | Retrieves nearby providers, sorted by distance. |
| **Discovery**| `GET` | `/api/v1/providers/:providerId`| Yes | Gets detailed provider profile, reviews, and services. |
| **Discovery**| `GET` | `/api/v1/providers/:id/reviews`| Yes | Lists rating reviews submitted for a provider. |
| **Chat** | `GET` | `/api/v1/conversations` | Yes | Lists active conversation history for the current user. |
| **Chat** | `POST` | `/api/v1/conversations` | Yes | Creates a new chat room between customer and provider. |
| **Chat** | `GET` | `/api/v1/conversations/:id/messages`| Yes | Retrieves text message list for a specific chat room. |
| **Chat** | `POST`| `/api/v1/conversations/:id/messages`| Yes | Transmits and records a new chat message inside a room. |
| **Scheduler**| `GET` | `/api/v1/slots` | Yes | Retrieves provider-registered slots for a specific day. |
| **Bookings** | `GET` | `/api/v1/bookings` | Yes | Lists caller bookings (filterable with `asProvider`). |
| **Bookings** | `GET` | `/api/v1/bookings/pending`| Yes | Gets incoming booking requests awaiting provider review. |
| **Bookings** | `POST` | `/api/v1/bookings` | Yes | Places a booking request on a provider's time slot. |
| **Bookings** | `PATCH`| `/api/v1/bookings/:id/status`| Yes | Updates booking status (e.g. cancels booking slot). |
| **Bookings** | `POST` | `/api/v1/bookings/:id/start` | Yes | Flags that a provider has arrived and started the job. |
| **Bookings** | `POST` | `/api/v1/bookings/:id/complete`| Yes | Flags completion of a service booking. |
| **Payments** | `GET` | `/api/v1/payments` | Yes | Retrieves latest payment record linked to a booking ID. |
| **Payments** | `POST` | `/api/v1/payments` | Yes | Requests creation of a pending transaction reference. |
| **Payments** | `POST` | `/api/v1/payments/:id/process`| Yes | Simulates payment gateway validation. |
| **Reviews** | `GET` | `/api/v1/reviews/exists` | Yes | Checks if a customer has reviewed a specific booking. |
| **Reviews** | `POST` | `/api/v1/reviews` | Yes | Submits a new review and updates the provider's score. |

---

### 4.2 Comprehensive Endpoint Payloads

#### 1. Authentication: `POST /api/v1/auth/login`
*   **Request Payload**:
    ```json
    {
      "email": "customer@demo.com",
      "password": "password123"
    }
    ```
*   **Success Response (`200 OK`)**:
    ```json
    {
      "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
      "user": {
        "userId": "usr_customer_1",
        "name": "Alex Customer",
        "email": "customer@demo.com",
        "phone": "+15551234",
        "role": "CUSTOMER",
        "bio": null,
        "averageRating": 0,
        "isVerified": 0,
        "isActive": 1,
        "latitude": null,
        "longitude": null,
        "loyaltyPoints": 150
      }
    }
    ```
*   **Failure Response (`401 Unauthorized`)**:
    ```json
    {
      "error": "Invalid email or password"
    }
    ```

#### 2. Discovery: `GET /api/v1/providers/nearby`
*   **URL Query Parameters**: `latitude=37.7749&longitude=-122.4194&radiusKm=25&categoryId=cat_cleaning`
*   **Success Response (`200 OK`)**:
    ```json
    [
      {
        "userId": "usr_provider_1",
        "name": "Jordan Clean Co.",
        "email": "provider1@demo.com",
        "phone": "+15559999",
        "role": "PROVIDER",
        "bio": "Standard home cleaning, deep cleaning & carpet washes",
        "averageRating": 4.8,
        "isVerified": 1,
        "isActive": 1,
        "latitude": 37.7749,
        "longitude": -122.4194,
        "loyaltyPoints": 420,
        "distanceKm": 0
      }
    ]
    ```

#### 3. Real-Time Chat: `POST /api/v1/conversations/:id/messages`
*   **Request Payload**:
    ```json
    {
      "body": "Hey there! I am outside your apartment door now."
    }
    ```
*   **Success Response (`201 Created`)**:
    ```json
    {
      "messageId": "msg_f3c8a9f0-d021-41db-b003-88223ac1",
      "conversationId": "conv_customer_provider_1",
      "senderId": "usr_provider_1",
      "body": "Hey there! I am outside your apartment door now.",
      "createdAt": "2026-05-25T10:15:30.122Z",
      "isMine": true
    }
    ```

#### 4. Booking Flow: `POST /api/v1/bookings`
*   **Request Payload**:
    ```json
    {
      "providerId": "usr_provider_1",
      "serviceId": "srv_deep_clean_1",
      "slotId": "slot_provider_1_monday_9am",
      "addressId": "addr_customer_home",
      "totalPrice": 120.00,
      "notes": "Please bring eco-friendly cleaning detergents."
    }
    ```
*   **Success Response (`201 Created`)**:
    ```json
    {
      "bookingId": "bk_77cb33df-b420-4a81-a9f2-2b223c91ad9f",
      "customerId": "usr_customer_1",
      "providerId": "usr_provider_1",
      "serviceId": "srv_deep_clean_1",
      "slotId": "slot_provider_1_monday_9am",
      "scheduledTime": "2026-05-25T09:00:00.000Z",
      "endTime": "2026-05-25T11:00:00.000Z",
      "status": "PENDING",
      "totalPrice": 120,
      "addressId": "addr_customer_home",
      "notes": "Please bring eco-friendly cleaning detergents.",
      "serviceStartedAt": null,
      "serviceCompletedAt": null
    }
    ```

---

## 5. Flutter Client Architecture

The mobile front-end application is built with **Flutter (Dart)**, utilizing **Clean Architecture** patterns combined with **BLoC** for reliable state isolation and UI management.

### 5.1 Clean Architecture Model

```
               +----------------------------------------+
               |           PRESENTATION LAYER           |
               | (Widgets, Screens, BLoCs, UI States)   |
               +----------------------------------------+
                                   |
                                   v
               +----------------------------------------+
               |              DOMAIN LAYER              |
               |  (Entities, Usecases, Repo Interfaces)  |
               +----------------------------------------+
                                   |
                                   v
               +----------------------------------------+
               |               DATA LAYER               |
               | (Models, Data Sources, Repos Impls)   |
               +----------------------------------------+
```

1. **Presentation Layer (`lib/presentation/`)**:
   - **UI Views**: Declarative UI components grouped by feature modules: `auth`, `discovery`, `booking`, `chat`, and `profile`.
   - **BLoC Controllers (`flutter_bloc`)**: Manages UI state changes. Translates user interactions into BLoC Events, processes them through repository calls, and emits clean UI States (e.g., `Loading`, `Success`, `Error`).
2. **Domain Layer (`lib/domain/`)**:
   - **Entities**: Pure Dart objects representing core domain business concepts (e.g., `UserEntity`, `BookingEntity`), free from serialization formats.
   - **Repository Contracts**: Abstract classes defining the protocols for data storage and fetching.
3. **Data Layer (`lib/data/`)**:
   - **Models**: Extensions of Domain Entities containing serialization logic (e.g., `UserModel.fromJson`).
   - **Data Sources**: Interacts directly with external APIs via **Dio** (`DioClient`) or handles offline storage interfaces.
   - **Repository Implementations**: Fulfills domain repository contracts, executing network calls and managing offline caches.

---

### 5.2 Client Side State Management & Services

*   **Dependency Injection (`get_it`)**: Resolves service references. Registers singletons for core cross-cutting concerns (e.g., `DioClient`, `Geolocator`, `UserRepository`, `ChatBloc`) to keep the codebase highly testable.
*   **Offline Fallbacks (`connectivity_plus`)**: Detects network connectivity changes. In offline scenarios, the app switches to mock datasets or reads from cached data sources to prevent application crashes.
*   **Location Services & Maps**:
    *   `geolocator`: Retrieves coordinates from the device GPS.
    *   `google_maps_flutter`: Renders an interactive map pinning local providers.

---

## 6. Installation & Deployment Guide

### 6.1 Quick-Start Commands

#### 1. Backend API Local Setup
The backend requires Node.js (v18+) and an active MySQL Server (v8.0+).

```bash
# Navigate to the backend service workspace
cd backend

# Install project dependencies (including mysql2 driver)
npm install

# Initialize Local Market Place database schema and seed data (First time only)
npm run seed

# Run the API server in hot-reload development mode
npm run dev
```
*The local API server starts running at: `http://localhost:3000`*

> **Database Configuration Note**: Standard pool configuration details are managed inside the `backend/.env` file:
> ```ini
> DB_HOST=localhost
> DB_PORT=3306
> DB_USER=root
> DB_PASSWORD=yourpassword
> DB_NAME=Local Market Place
> ```

#### 2. Flutter Client Local Setup
The Flutter SDK must be installed on your development machine.

```bash
# Fetch Flutter pub dependencies
flutter pub get

# Launch code-generation scripts (if necessary for serialization models)
flutter pub run build_runner build --delete-conflicting-outputs

# Execute the application on an active mobile device/emulator
flutter run
```

---

### 6.2 Build Environment Scenarios

The client can be run with specific environment variables defined via Dart build definitions:

| Testing Scenario | Build Command | Description |
| :--- | :--- | :--- |
| **Local Emulator** | `flutter run --dart-define=API_BASE_URL=http://10.0.2.2:3000` | Configures the app to route requests to the local machine's dev server through the Android emulator host loopback. |
| **Offline Mock** | `flutter run --dart-define=USE_MOCK_API=true` | Starts the app in mock mode, bypassing network requests and relying on mock data. |
| **Release Build** | `flutter build apk --release` | Generates an optimized, minified production Android APK. |
| **Production Server**| *Default Client Action* | Routes directly to the live Render-hosted API: `https://localservicemarket-api.onrender.com` |

> [!NOTE]
> The live production API is hosted on Render's free tier. If the backend has been idle, it may take up to **60 seconds** to wake up on the first request. The mobile application handles this wait time using custom loading indicators.

---

### 6.3 Android Google Maps Configuration

To enable interactive Maps on Android, complete the following steps:

1. **Manifest Integration**: Set your API key inside the application manifest file at:  
   `android/app/src/main/AndroidManifest.xml`
   ```xml
   <meta-data 
       android:name="com.google.android.geo.API_KEY"
       android:value="YOUR_GOOGLE_MAPS_API_KEY_HERE"/>
   ```
2. **Key Restriction**: In your [Google Cloud Console](https://console.cloud.google.com/), restrict the API key to Android apps. Set the allowed package name to:  
   `com.localservicemarket.localservicemarket`

---

## 7. Testing & Verification Protocol

### 7.1 Pre-seeded Demo Accounts

To run functional tests and verify role-based flows, use the pre-seeded credentials below:

| Role | Username / Email | Password | Intended Test Flow |
| :--- | :--- | :--- | :--- |
| **Customer** | `customer@demo.com` | `password123` | Log in as Customer to browse categories, select providers, book time slots, make payments, chat with professionals, and submit reviews. |
| **Provider A** | `provider1@demo.com` | `password123` | Log in as **Jordan Clean Co.** to manage cleaning bookings, update service pricing, toggle availability, and reply to client messages. |
| **Provider B** | `provider2@demo.com` | `password123` | Log in as **Alex Provider** to test concurrent scheduling, service isolation, and customer-provider chat routing. |

*Note: New service providers can also register through the onboarding flow, select their work categories, and immediately appear in nearby customer search listings.*

---

### 7.2 Verification Checklist

For instructors and development teams, the following steps confirm that all system modules are integrated successfully:

1. **MySQL Server Check**: Ensure your local MySQL instance is running and has created the database named **`Local Market Place`** containing the 12 relational tables.
2. **Backend Integration**: Ensure that executing `npm run dev` initializes the server and prints:  
   `Local Services API listening on http://localhost:3000`
3. **API Sanity Check**: In your browser or Postman, load `http://localhost:3000/health`. The server should respond with:  
   `{"ok":true}`
4. **Database Population**: Open `http://localhost:3000/api/v1/categories`. It should return a JSON array listing the default categories (e.g., Cleaning, Electrical, Plumbing).
5. **Client Connection**: Start the Flutter app targeting your local backend. Register a new user, and verify that a new user record is created in the MySQL `users` table.
6. **End-to-End Booking**:
   - Log in as the test customer, browse a provider, and request a booking.
   - Confirm that the MySQL `bookings` table logs a new record marked as `PENDING`.
   - Log in as the target provider, locate the pending booking request, accept it, and confirm the status updates to `CONFIRMED`.
   - Simulate a credit card transaction to verify that the `payments` table records the transaction reference.
