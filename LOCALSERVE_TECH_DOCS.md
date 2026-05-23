# LocalServe — Local Services Marketplace
## System Technical Documentation Suite

This document serves as the official, production-ready **Technical Documentation Suite** for **LocalServe**, a modern peer-to-peer marketplace connecting Customers with trusted local Service Providers (Plumbers, Electricians, Cleaners, Painters, etc.).

---

### Project Repository & Development Team

*   **Repository URL**: `git@github.com:abrshiz/Local-Services-Marketplace.git`
*   **Prepared For**: Academic Instructor Review & Team Reference
*   **Version**: 1.0.0

#### Development Group Members

| # | Member Name | Student ID / ID |
| :--- | :--- | :--- |
| **1** | Abrham Wendesen | `DDU1600055` |
| **2** | Makbel Hailu | `DDU1600488` |
| **3** | Yeabsira Eskinder | `DDU1600747` |
| **4** | Eyob Jira | `RMD940` |
| **5** | Wegen Geremew | `DDU1601938` |

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
