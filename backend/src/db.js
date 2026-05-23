import Database from 'better-sqlite3';
import path from 'path';
import { fileURLToPath } from 'url';
import fs from 'fs';

const __dirname = path.dirname(fileURLToPath(import.meta.url));
const dataDir = path.join(__dirname, '..', 'data');
if (!fs.existsSync(dataDir)) fs.mkdirSync(dataDir, { recursive: true });

const dbPath = process.env.DB_PATH || path.join(dataDir, 'marketplace.db');
export const db = new Database(dbPath);

db.pragma('journal_mode = WAL');
db.pragma('foreign_keys = ON');

export function initSchema() {
  db.exec(`
    CREATE TABLE IF NOT EXISTS users (
      user_id TEXT PRIMARY KEY,
      name TEXT NOT NULL,
      email TEXT NOT NULL UNIQUE,
      password_hash TEXT NOT NULL,
      phone TEXT,
      role TEXT NOT NULL,
      created_at TEXT NOT NULL,
      updated_at TEXT NOT NULL,
      bio TEXT,
      average_rating REAL DEFAULT 0,
      is_verified INTEGER DEFAULT 0,
      is_active INTEGER DEFAULT 1,
      latitude REAL,
      longitude REAL,
      default_address_id TEXT,
      loyalty_points INTEGER DEFAULT 0
    );

    CREATE TABLE IF NOT EXISTS addresses (
      address_id TEXT PRIMARY KEY,
      user_id TEXT NOT NULL REFERENCES users(user_id) ON DELETE CASCADE,
      label TEXT,
      street TEXT,
      city TEXT,
      state TEXT,
      country TEXT,
      postal_code TEXT,
      latitude REAL,
      longitude REAL,
      is_default INTEGER DEFAULT 0
    );

    CREATE TABLE IF NOT EXISTS categories (
      category_id TEXT PRIMARY KEY,
      name TEXT NOT NULL,
      description TEXT,
      icon_url TEXT
    );

    CREATE TABLE IF NOT EXISTS provider_skills (
      provider_id TEXT NOT NULL REFERENCES users(user_id) ON DELETE CASCADE,
      category_id TEXT NOT NULL REFERENCES categories(category_id) ON DELETE CASCADE,
      PRIMARY KEY (provider_id, category_id)
    );

    CREATE TABLE IF NOT EXISTS services (
      service_id TEXT PRIMARY KEY,
      provider_id TEXT NOT NULL REFERENCES users(user_id),
      category_id TEXT NOT NULL REFERENCES categories(category_id),
      title TEXT NOT NULL,
      description TEXT,
      price_type TEXT NOT NULL,
      base_price REAL NOT NULL,
      is_active INTEGER DEFAULT 1
    );

    CREATE TABLE IF NOT EXISTS time_slots (
      slot_id TEXT PRIMARY KEY,
      provider_id TEXT NOT NULL REFERENCES users(user_id),
      start_time TEXT NOT NULL,
      end_time TEXT NOT NULL,
      is_available INTEGER DEFAULT 1
    );

    CREATE TABLE IF NOT EXISTS bookings (
      booking_id TEXT PRIMARY KEY,
      customer_id TEXT NOT NULL REFERENCES users(user_id),
      provider_id TEXT NOT NULL REFERENCES users(user_id),
      service_id TEXT NOT NULL REFERENCES services(service_id),
      slot_id TEXT REFERENCES time_slots(slot_id),
      scheduled_time TEXT NOT NULL,
      end_time TEXT NOT NULL,
      status TEXT NOT NULL,
      total_price REAL NOT NULL,
      address_id TEXT,
      notes TEXT,
      service_started_at TEXT,
      service_completed_at TEXT
    );

    CREATE TABLE IF NOT EXISTS payments (
      payment_id TEXT PRIMARY KEY,
      booking_id TEXT NOT NULL REFERENCES bookings(booking_id),
      amount REAL NOT NULL,
      status TEXT NOT NULL,
      method TEXT NOT NULL,
      transaction_ref TEXT,
      paid_at TEXT
    );

    CREATE TABLE IF NOT EXISTS reviews (
      review_id TEXT PRIMARY KEY,
      booking_id TEXT NOT NULL UNIQUE REFERENCES bookings(booking_id),
      reviewer_id TEXT NOT NULL REFERENCES users(user_id),
      provider_id TEXT NOT NULL REFERENCES users(user_id),
      rating INTEGER NOT NULL,
      comment TEXT,
      created_at TEXT NOT NULL
    );

    CREATE TABLE IF NOT EXISTS notifications (
      id TEXT PRIMARY KEY,
      user_id TEXT NOT NULL REFERENCES users(user_id),
      title TEXT,
      body TEXT,
      created_at TEXT NOT NULL
    );
  `);
}
