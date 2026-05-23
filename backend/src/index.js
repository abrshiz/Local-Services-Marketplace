import express from 'express';
import cors from 'cors';
import bcrypt from 'bcryptjs';
import { v4 as uuidv4 } from 'uuid';
import { db, initSchema } from './db.js';
import { requireAuth, signToken } from './middleware/auth.js';
import {
  haversineKm,
  mapBooking,
  mapCategory,
  mapPayment,
  mapService,
  mapSlot,
  mapUser,
} from './userMapper.js';

initSchema();

const userCount = db.prepare('SELECT COUNT(*) AS c FROM users').get().c;
if (userCount === 0) {
  console.log('Empty DB — run: npm run seed');
}

const app = express();
const PORT = process.env.PORT || 3000;

app.use(cors());
app.use(express.json());

app.get('/health', (_req, res) => res.json({ ok: true }));

// ——— Auth ———
app.post('/api/v1/auth/login', (req, res) => {
  const { email, password } = req.body;
  const row = db
    .prepare('SELECT * FROM users WHERE email = ?')
    .get(String(email || '').trim().toLowerCase());
  if (!row || !bcrypt.compareSync(password || '', row.password_hash)) {
    return res.status(401).json({ error: 'Invalid email or password' });
  }
  const token = signToken(row.user_id);
  res.json({ token, user: mapUser(row.user_id) });
});

app.post('/api/v1/auth/register', (req, res) => {
  const { name, email, password, phone, role, bio } = req.body;
  const normalized = String(email || '').trim().toLowerCase();
  const exists = db.prepare('SELECT 1 FROM users WHERE email = ?').get(normalized);
  if (exists) return res.status(409).json({ error: 'Email already registered' });

  const userId = uuidv4();
  const now = new Date().toISOString();
  const hash = bcrypt.hashSync(password || '', 10);
  const userRole = role === 'PROVIDER' ? 'PROVIDER' : 'CUSTOMER';

  db.prepare(`
    INSERT INTO users (user_id, name, email, password_hash, phone, role, created_at, updated_at,
      bio, average_rating, is_verified, is_active, latitude, longitude, loyalty_points)
    VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, 0, 0, 1, ?, ?, 0)
  `).run(
    userId,
    name,
    normalized,
    hash,
    phone || '',
    userRole,
    now,
    now,
    userRole === 'PROVIDER' ? bio || '' : null,
    userRole === 'PROVIDER' ? 37.7749 : null,
    userRole === 'PROVIDER' ? -122.4194 : null,
  );

  const token = signToken(userId);
  res.status(201).json({ token, user: mapUser(userId) });
});

app.get('/api/v1/auth/me', requireAuth, (req, res) => {
  const user = mapUser(req.userId);
  if (!user) return res.status(404).json({ error: 'User not found' });
  res.json(user);
});

app.post('/api/v1/auth/logout', (_req, res) => res.json({ ok: true }));

// ——— Discovery ———
app.get('/api/v1/categories', (_req, res) => {
  const rows = db.prepare('SELECT * FROM categories ORDER BY name').all();
  res.json(rows.map(mapCategory));
});

app.get('/api/v1/services', (req, res) => {
  let sql = 'SELECT * FROM services WHERE is_active = 1';
  const params = [];
  if (req.query.categoryId) {
    sql += ' AND category_id = ?';
    params.push(req.query.categoryId);
  }
  if (req.query.providerId) {
    sql += ' AND provider_id = ?';
    params.push(req.query.providerId);
  }
  const rows = db.prepare(sql).all(...params);
  res.json(rows.map(mapService));
});

app.get('/api/v1/providers/nearby', (req, res) => {
  const lat = parseFloat(req.query.latitude);
  const lng = parseFloat(req.query.longitude);
  const radiusKm = parseFloat(req.query.radiusKm || '25');
  const categoryId = req.query.categoryId;
  const minRating = parseFloat(req.query.minRating || '0');
  const priceType = req.query.priceType;
  const query = (req.query.query || '').toLowerCase();

  let providers = db
    .prepare(`SELECT * FROM users WHERE role = 'PROVIDER' AND is_active = 1`)
    .all()
    .map((row) => mapUser(row.user_id));

  if (query) {
    providers = providers.filter((p) => p.name.toLowerCase().includes(query));
  }
  if (categoryId) {
    const providerIds = new Set(
      db
        .prepare('SELECT provider_id FROM services WHERE category_id = ? AND is_active = 1')
        .all(categoryId)
        .map((r) => r.provider_id),
    );
    providers = providers.filter((p) => providerIds.has(p.userId));
  }
  if (minRating > 0) {
    providers = providers.filter((p) => p.averageRating >= minRating);
  }
  if (priceType) {
    const providerIds = new Set(
      db
        .prepare('SELECT provider_id FROM services WHERE price_type = ? AND is_active = 1')
        .all(priceType)
        .map((r) => r.provider_id),
    );
    providers = providers.filter((p) => providerIds.has(p.userId));
  }

  providers = providers
    .map((p) => ({
      ...p,
      distanceKm: haversineKm(lat, lng, p.latitude, p.longitude),
    }))
    .filter((p) => !Number.isNaN(lat) && !Number.isNaN(lng) ? p.distanceKm <= radiusKm : true)
    .sort((a, b) => a.distanceKm - b.distanceKm);

  res.json(providers);
});

// ——— Time slots ———
app.get('/api/v1/slots', (req, res) => {
  const { providerId, day } = req.query;
  if (!providerId || !day) {
    return res.status(400).json({ error: 'providerId and day required' });
  }
  const dayStart = new Date(day);
  dayStart.setHours(0, 0, 0, 0);
  const dayEnd = new Date(dayStart);
  dayEnd.setDate(dayEnd.getDate() + 1);

  const rows = db
    .prepare(
      `SELECT * FROM time_slots
       WHERE provider_id = ? AND is_available = 1
         AND start_time >= ? AND start_time < ?
       ORDER BY start_time`,
    )
    .all(providerId, dayStart.toISOString(), dayEnd.toISOString());

  res.json(rows.map(mapSlot));
});

// ——— Bookings ———
app.get('/api/v1/bookings', requireAuth, (req, res) => {
  const asProvider = req.query.asProvider === 'true';
  const status = req.query.status;
  let sql = asProvider
    ? 'SELECT * FROM bookings WHERE provider_id = ?'
    : 'SELECT * FROM bookings WHERE customer_id = ?';
  const params = [req.userId];
  if (status) {
    sql += ' AND status = ?';
    params.push(status);
  }
  sql += ' ORDER BY scheduled_time DESC';
  const rows = db.prepare(sql).all(...params);
  res.json(rows.map(mapBooking));
});

app.get('/api/v1/bookings/pending', requireAuth, (req, res) => {
  const providerId = req.query.providerId || req.userId;
  const rows = db
    .prepare(
      `SELECT * FROM bookings WHERE provider_id = ? AND status = 'PENDING' ORDER BY scheduled_time`,
    )
    .all(providerId);
  res.json(rows.map(mapBooking));
});

app.post('/api/v1/bookings', requireAuth, (req, res) => {
  const {
    providerId,
    serviceId,
    slotId,
    addressId,
    totalPrice,
    notes,
  } = req.body;

  const provider = db.prepare('SELECT * FROM users WHERE user_id = ?').get(providerId);
  if (!provider?.is_active) {
    return res.status(409).json({ error: 'Provider is currently unavailable' });
  }

  const slot = db.prepare('SELECT * FROM time_slots WHERE slot_id = ?').get(slotId);
  if (!slot || !slot.is_available) {
    return res.status(409).json({ error: 'This time slot is no longer available' });
  }

  db.prepare('UPDATE time_slots SET is_available = 0 WHERE slot_id = ?').run(slotId);

  const bookingId = uuidv4();
  db.prepare(`
    INSERT INTO bookings (booking_id, customer_id, provider_id, service_id, slot_id,
      scheduled_time, end_time, status, total_price, address_id, notes)
    VALUES (?, ?, ?, ?, ?, ?, ?, 'PENDING', ?, ?, ?)
  `).run(
    bookingId,
    req.userId,
    providerId,
    serviceId,
    slotId,
    slot.start_time,
    slot.end_time,
    totalPrice,
    addressId,
    notes || '',
  );

  db.prepare(
    `INSERT INTO notifications (id, user_id, title, body, created_at) VALUES (?, ?, ?, ?, ?)`,
  ).run(
    uuidv4(),
    providerId,
    'New booking request',
    `A customer requested a service at ${slot.start_time}`,
    new Date().toISOString(),
  );

  const booking = mapBooking(
    db.prepare('SELECT * FROM bookings WHERE booking_id = ?').get(bookingId),
  );
  res.status(201).json(booking);
});

app.patch('/api/v1/bookings/:id/status', requireAuth, (req, res) => {
  const { status } = req.body;
  const booking = db
    .prepare('SELECT * FROM bookings WHERE booking_id = ?')
    .get(req.params.id);
  if (!booking) return res.status(404).json({ error: 'Booking not found' });

  if (status === 'CANCELLED' && booking.slot_id) {
    db.prepare('UPDATE time_slots SET is_available = 1 WHERE slot_id = ?').run(
      booking.slot_id,
    );
  }

  db.prepare('UPDATE bookings SET status = ? WHERE booking_id = ?').run(
    status,
    req.params.id,
  );
  res.json(
    mapBooking(db.prepare('SELECT * FROM bookings WHERE booking_id = ?').get(req.params.id)),
  );
});

app.post('/api/v1/bookings/:id/start', requireAuth, (req, res) => {
  const now = new Date().toISOString();
  db.prepare(
    'UPDATE bookings SET service_started_at = ? WHERE booking_id = ?',
  ).run(now, req.params.id);
  const row = db.prepare('SELECT * FROM bookings WHERE booking_id = ?').get(req.params.id);
  if (!row) return res.status(404).json({ error: 'Booking not found' });
  res.json(mapBooking(row));
});

app.post('/api/v1/bookings/:id/complete', requireAuth, (req, res) => {
  const now = new Date().toISOString();
  db.prepare(
    `UPDATE bookings SET status = 'COMPLETED', service_completed_at = ? WHERE booking_id = ?`,
  ).run(now, req.params.id);
  const row = db.prepare('SELECT * FROM bookings WHERE booking_id = ?').get(req.params.id);
  if (!row) return res.status(404).json({ error: 'Booking not found' });
  res.json(mapBooking(row));
});

// ——— Payments ———
app.get('/api/v1/payments', requireAuth, (req, res) => {
  const { bookingId } = req.query;
  const row = db
    .prepare('SELECT * FROM payments WHERE booking_id = ? ORDER BY payment_id DESC LIMIT 1')
    .get(bookingId);
  res.json(row ? mapPayment(row) : null);
});

app.post('/api/v1/payments', requireAuth, (req, res) => {
  const { bookingId, amount, method } = req.body;
  const paymentId = uuidv4();
  db.prepare(`
    INSERT INTO payments (payment_id, booking_id, amount, status, method)
    VALUES (?, ?, ?, 'PENDING', ?)
  `).run(paymentId, bookingId, amount, method || 'CARD');
  const row = db.prepare('SELECT * FROM payments WHERE payment_id = ?').get(paymentId);
  res.status(201).json(mapPayment(row));
});

app.post('/api/v1/payments/:id/process', requireAuth, (req, res) => {
  const { simulateSuccess = true } = req.body;
  const payment = db
    .prepare('SELECT * FROM payments WHERE payment_id = ?')
    .get(req.params.id);
  if (!payment) return res.status(404).json({ error: 'Payment not found' });

  if (!simulateSuccess) {
    db.prepare(`UPDATE payments SET status = 'FAILED' WHERE payment_id = ?`).run(
      req.params.id,
    );
    return res.status(402).json({ error: 'Payment declined by gateway' });
  }

  const now = new Date().toISOString();
  const ref = `TX-${req.params.id.slice(0, 8).toUpperCase()}`;
  db.prepare(`
    UPDATE payments SET status = 'PAID', transaction_ref = ?, paid_at = ? WHERE payment_id = ?
  `).run(ref, now, req.params.id);

  db.prepare(`UPDATE bookings SET status = 'CONFIRMED' WHERE booking_id = ?`).run(
    payment.booking_id,
  );

  const row = db.prepare('SELECT * FROM payments WHERE payment_id = ?').get(req.params.id);
  res.json(mapPayment(row));
});

// ——— Reviews ———
app.get('/api/v1/reviews/exists', requireAuth, (req, res) => {
  const row = db
    .prepare('SELECT 1 FROM reviews WHERE booking_id = ?')
    .get(req.query.bookingId);
  res.json({ exists: !!row });
});

app.post('/api/v1/reviews', requireAuth, (req, res) => {
  const { bookingId, providerId, rating, comment } = req.body;
  const exists = db.prepare('SELECT 1 FROM reviews WHERE booking_id = ?').get(bookingId);
  if (exists) return res.status(409).json({ error: 'Review already submitted for this booking' });

  const reviewId = uuidv4();
  const now = new Date().toISOString();
  const r = Math.min(5, Math.max(1, parseInt(rating, 10)));

  db.prepare(`
    INSERT INTO reviews (review_id, booking_id, reviewer_id, provider_id, rating, comment, created_at)
    VALUES (?, ?, ?, ?, ?, ?, ?)
  `).run(reviewId, bookingId, req.userId, providerId, r, comment || '', now);

  const avg = db
    .prepare('SELECT AVG(rating) AS avg FROM reviews WHERE provider_id = ?')
    .get(providerId).avg;
  db.prepare('UPDATE users SET average_rating = ? WHERE user_id = ?').run(
    avg || 0,
    providerId,
  );

  res.status(201).json({
    reviewId,
    bookingId,
    reviewerId: req.userId,
    providerId,
    rating: r,
    comment: comment || '',
    createdAt: now,
  });
});

app.listen(PORT, () => {
  console.log(`Local Services API listening on http://localhost:${PORT}`);
});
