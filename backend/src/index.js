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
import { setupProviderCategories } from './providerSetup.js';
import { seedDatabaseIfEmpty } from './seedData.js';

initSchema();
seedDatabaseIfEmpty();

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
  const { name, email, password, phone, role, bio, categoryIds } = req.body;
  const normalized = String(email || '').trim().toLowerCase();
  const exists = db.prepare('SELECT 1 FROM users WHERE email = ?').get(normalized);
  if (exists) return res.status(409).json({ error: 'Email already registered' });

  const userId = uuidv4();
  const now = new Date().toISOString();
  const hash = bcrypt.hashSync(password || '', 10);
  const userRole = role === 'PROVIDER' ? 'PROVIDER' : 'CUSTOMER';

  if (userRole === 'PROVIDER') {
    const ids = Array.isArray(categoryIds) ? categoryIds : [];
    if (ids.length === 0) {
      return res.status(400).json({ error: 'Select at least one work category' });
    }
  }

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

  if (userRole === 'PROVIDER') {
    setupProviderCategories(db, userId, name, categoryIds);
  }

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
  const radiusKm = parseFloat(req.query.radiusKm || '10000');
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
    const fromServices = db
      .prepare('SELECT provider_id FROM services WHERE category_id = ? AND is_active = 1')
      .all(categoryId)
      .map((r) => r.provider_id);
    const fromSkills = db
      .prepare('SELECT provider_id FROM provider_skills WHERE category_id = ?')
      .all(categoryId)
      .map((r) => r.provider_id);
    const providerIds = new Set([...fromServices, ...fromSkills]);
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

app.get('/api/v1/providers/:providerId', (req, res) => {
  const user = mapUser(req.params.providerId);
  if (!user || user.role !== 'PROVIDER') {
    return res.status(404).json({ error: 'Provider not found' });
  }
  const reviewCount = db
    .prepare('SELECT COUNT(*) AS c FROM reviews WHERE provider_id = ?')
    .get(req.params.providerId).c;
  const services = db
    .prepare('SELECT * FROM services WHERE provider_id = ? AND is_active = 1')
    .all(req.params.providerId)
    .map(mapService);
  res.json({ ...user, reviewCount, services });
});

app.get('/api/v1/providers/:providerId/reviews', (req, res) => {
  const rows = db
    .prepare(
      `SELECT r.*, u.name AS reviewer_name
       FROM reviews r
       JOIN users u ON u.user_id = r.reviewer_id
       WHERE r.provider_id = ?
       ORDER BY r.created_at DESC
       LIMIT 50`,
    )
    .all(req.params.providerId);
  res.json(
    rows.map((r) => ({
      reviewId: r.review_id,
      bookingId: r.booking_id,
      reviewerId: r.reviewer_id,
      reviewerName: r.reviewer_name,
      providerId: r.provider_id,
      rating: r.rating,
      comment: r.comment,
      createdAt: r.created_at,
    })),
  );
});

function mapConversationRow(row, currentUserId) {
  const isCustomer = row.customer_id === currentUserId;
  const peerId = isCustomer ? row.provider_id : row.customer_id;
  const peer = db.prepare('SELECT name, role FROM users WHERE user_id = ?').get(peerId);
  const lastMsg = db
    .prepare(
      `SELECT body, created_at, sender_id FROM messages
       WHERE conversation_id = ? ORDER BY created_at DESC LIMIT 1`,
    )
    .get(row.conversation_id);
  return {
    conversationId: row.conversation_id,
    customerId: row.customer_id,
    providerId: row.provider_id,
    peerId,
    peerName: peer?.name ?? 'User',
    peerRole: peer?.role,
    lastMessage: lastMsg?.body ?? '',
    lastMessageAt: lastMsg?.created_at ?? row.updated_at,
    unread: lastMsg && lastMsg.sender_id !== currentUserId,
  };
}

app.get('/api/v1/conversations', requireAuth, (req, res) => {
  const rows = db
    .prepare(
      `SELECT * FROM conversations
       WHERE customer_id = ? OR provider_id = ?
       ORDER BY updated_at DESC`,
    )
    .all(req.userId, req.userId);
  res.json(rows.map((r) => mapConversationRow(r, req.userId)));
});

app.post('/api/v1/conversations', requireAuth, (req, res) => {
  const { peerId } = req.body;
  if (!peerId) return res.status(400).json({ error: 'peerId required' });

  const me = db.prepare('SELECT role FROM users WHERE user_id = ?').get(req.userId);
  const peer = db.prepare('SELECT role FROM users WHERE user_id = ?').get(peerId);
  if (!me || !peer) return res.status(404).json({ error: 'User not found' });

  let customerId;
  let providerId;
  if (me.role === 'CUSTOMER' && peer.role === 'PROVIDER') {
    customerId = req.userId;
    providerId = peerId;
  } else if (me.role === 'PROVIDER' && peer.role === 'CUSTOMER') {
    customerId = peerId;
    providerId = req.userId;
  } else {
    return res.status(400).json({ error: 'Chat is only between customers and providers' });
  }

  let row = db
    .prepare(
      'SELECT * FROM conversations WHERE customer_id = ? AND provider_id = ?',
    )
    .get(customerId, providerId);

  if (!row) {
    const conversationId = uuidv4();
    const now = new Date().toISOString();
    db.prepare(
      'INSERT INTO conversations (conversation_id, customer_id, provider_id, updated_at) VALUES (?, ?, ?, ?)',
    ).run(conversationId, customerId, providerId, now);
    row = db
      .prepare('SELECT * FROM conversations WHERE conversation_id = ?')
      .get(conversationId);
  }

  res.status(201).json(mapConversationRow(row, req.userId));
});

app.get('/api/v1/conversations/:id/messages', requireAuth, (req, res) => {
  const conv = db
    .prepare('SELECT * FROM conversations WHERE conversation_id = ?')
    .get(req.params.id);
  if (!conv) return res.status(404).json({ error: 'Conversation not found' });
  if (conv.customer_id !== req.userId && conv.provider_id !== req.userId) {
    return res.status(403).json({ error: 'Forbidden' });
  }
  const rows = db
    .prepare(
      `SELECT * FROM messages WHERE conversation_id = ? ORDER BY created_at ASC`,
    )
    .all(req.params.id);
  res.json(
    rows.map((m) => ({
      messageId: m.message_id,
      conversationId: m.conversation_id,
      senderId: m.sender_id,
      body: m.body,
      createdAt: m.created_at,
      isMine: m.sender_id === req.userId,
    })),
  );
});

app.post('/api/v1/conversations/:id/messages', requireAuth, (req, res) => {
  const { body } = req.body;
  if (!body || !String(body).trim()) {
    return res.status(400).json({ error: 'Message body required' });
  }
  const conv = db
    .prepare('SELECT * FROM conversations WHERE conversation_id = ?')
    .get(req.params.id);
  if (!conv) return res.status(404).json({ error: 'Conversation not found' });
  if (conv.customer_id !== req.userId && conv.provider_id !== req.userId) {
    return res.status(403).json({ error: 'Forbidden' });
  }

  const messageId = uuidv4();
  const now = new Date().toISOString();
  db.prepare(
    'INSERT INTO messages (message_id, conversation_id, sender_id, body, created_at) VALUES (?, ?, ?, ?, ?)',
  ).run(messageId, req.params.id, req.userId, String(body).trim(), now);
  db.prepare('UPDATE conversations SET updated_at = ? WHERE conversation_id = ?').run(
    now,
    req.params.id,
  );

  res.status(201).json({
    messageId,
    conversationId: req.params.id,
    senderId: req.userId,
    body: String(body).trim(),
    createdAt: now,
    isMine: true,
  });
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
