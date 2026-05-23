import bcrypt from 'bcryptjs';
import { v4 as uuidv4 } from 'uuid';
import { db, initSchema } from './db.js';

initSchema();

const count = db.prepare('SELECT COUNT(*) AS c FROM users').get().c;
if (count > 0) {
  console.log('Database already seeded.');
  process.exit(0);
}

const now = new Date().toISOString();
const passwordHash = bcrypt.hashSync('password123', 10);

const catCleaning = 'a1111111-1111-4111-8111-111111111101';
const catPlumbing = 'a1111111-1111-4111-8111-111111111102';
const catElectrical = 'a1111111-1111-4111-8111-111111111103';
const catGarden = 'a1111111-1111-4111-8111-111111111104';

const customerId = 'b2222222-2222-4222-8222-222222222201';
const provider1 = 'c3333333-3333-4333-8333-333333333301';
const provider2 = 'c3333333-3333-4333-8333-333333333302';
const addrId = 'd4444444-4444-4444-8444-444444444401';

const insertUser = db.prepare(`
  INSERT INTO users (user_id, name, email, password_hash, phone, role, created_at, updated_at,
    bio, average_rating, is_verified, is_active, latitude, longitude, default_address_id, loyalty_points)
  VALUES (@user_id, @name, @email, @password_hash, @phone, @role, @created_at, @updated_at,
    @bio, @average_rating, @is_verified, @is_active, @latitude, @longitude, @default_address_id, @loyalty_points)
`);

insertUser.run({
  user_id: customerId,
  name: 'Alex Customer',
  email: 'customer@demo.com',
  password_hash: passwordHash,
  phone: '+1-555-0100',
  role: 'CUSTOMER',
  created_at: now,
  updated_at: now,
  bio: null,
  average_rating: 0,
  is_verified: 0,
  is_active: 1,
  latitude: null,
  longitude: null,
  default_address_id: addrId,
  loyalty_points: 120,
});

db.prepare(`
  INSERT INTO addresses (address_id, user_id, label, street, city, state, country, postal_code, latitude, longitude, is_default)
  VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, 1)
`).run(addrId, customerId, 'Home', '123 Market St', 'San Francisco', 'CA', 'USA', '94103', 37.7749, -122.4194);

for (const c of [
  [catCleaning, 'Cleaning', 'Home & office cleaning', 'cleaning_services'],
  [catPlumbing, 'Plumbing', 'Repairs and installations', 'plumbing'],
  [catElectrical, 'Electrical', 'Wiring and fixtures', 'electrical_services'],
  [catGarden, 'Gardening', 'Lawn care and landscaping', 'yard'],
]) {
  db.prepare(
    'INSERT INTO categories (category_id, name, description, icon_url) VALUES (?, ?, ?, ?)',
  ).run(...c);
}

for (const p of [
  {
    user_id: provider1,
    name: 'Jordan Clean Co.',
    email: 'provider1@demo.com',
    bio: 'Eco-friendly cleaning with 5+ years experience.',
    rating: 4.8,
    lat: 37.781,
    lng: -122.411,
    skill: catCleaning,
  },
  {
    user_id: provider2,
    name: 'Spark Electric',
    email: 'provider2@demo.com',
    bio: 'Licensed electrician for residential jobs.',
    rating: 4.5,
    lat: 37.769,
    lng: -122.429,
    skill: catElectrical,
  },
]) {
  insertUser.run({
    user_id: p.user_id,
    name: p.name,
    email: p.email,
    password_hash: passwordHash,
    phone: '+1-555-0200',
    role: 'PROVIDER',
    created_at: now,
    updated_at: now,
    bio: p.bio,
    average_rating: p.rating,
    is_verified: 1,
    is_active: 1,
    latitude: p.lat,
    longitude: p.lng,
    default_address_id: null,
    loyalty_points: 0,
  });
  db.prepare('INSERT INTO provider_skills (provider_id, category_id) VALUES (?, ?)').run(
    p.user_id,
    p.skill,
  );
}

const insertService = db.prepare(`
  INSERT INTO services (service_id, provider_id, category_id, title, description, price_type, base_price, is_active)
  VALUES (?, ?, ?, ?, ?, ?, ?, 1)
`);
insertService.run(
  'e5555555-5555-4555-8555-555555555501',
  provider1,
  catCleaning,
  'Standard Home Clean',
  '2-hour deep clean for apartments up to 80m²',
  'FIXED',
  89,
);
insertService.run(
  'e5555555-5555-4555-8555-555555555502',
  provider1,
  catCleaning,
  'Hourly Touch-up',
  'Flexible hourly cleaning',
  'HOURLY',
  45,
);
insertService.run(
  'e5555555-5555-4555-8555-555555555503',
  provider2,
  catElectrical,
  'Outlet Installation',
  'Install or replace wall outlets',
  'FIXED',
  120,
);

const insertSlot = db.prepare(`
  INSERT INTO time_slots (slot_id, provider_id, start_time, end_time, is_available)
  VALUES (?, ?, ?, ?, 1)
`);

const base = new Date();
base.setHours(0, 0, 0, 0);

for (const pid of [provider1, provider2]) {
  for (let d = 0; d < 14; d++) {
    const day = new Date(base);
    day.setDate(day.getDate() + d);
    for (const hour of [9, 11, 14, 16]) {
      const start = new Date(day);
      start.setHours(hour, 0, 0, 0);
      if (start < new Date(Date.now() - 3600000)) continue;
      const end = new Date(start);
      end.setHours(start.getHours() + 2);
      insertSlot.run(uuidv4(), pid, start.toISOString(), end.toISOString());
    }
  }
}

console.log('Seed complete.');
console.log('Demo: customer@demo.com / provider1@demo.com — password: password123');
