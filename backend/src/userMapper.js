import { db } from './db.js';

export function mapAddress(row) {
  if (!row) return null;
  return {
    addressId: row.address_id,
    userId: row.user_id,
    label: row.label,
    street: row.street,
    city: row.city,
    state: row.state,
    country: row.country,
    postalCode: row.postal_code,
    latitude: row.latitude,
    longitude: row.longitude,
    isDefault: !!row.is_default,
  };
}

export function mapCategory(row) {
  return {
    categoryId: row.category_id,
    name: row.name,
    description: row.description,
    iconUrl: row.icon_url,
  };
}

export function mapUser(userId) {
  const row = db.prepare('SELECT * FROM users WHERE user_id = ?').get(userId);
  if (!row) return null;

  const base = {
    userId: row.user_id,
    name: row.name,
    email: row.email,
    passwordHash: row.password_hash,
    phone: row.phone,
    role: row.role,
    createdAt: row.created_at,
    updatedAt: row.updated_at,
  };

  if (row.role === 'PROVIDER') {
    const skills = db
      .prepare(
        `SELECT c.* FROM categories c
         JOIN provider_skills ps ON ps.category_id = c.category_id
         WHERE ps.provider_id = ?`,
      )
      .all(row.user_id)
      .map(mapCategory);
    return {
      ...base,
      bio: row.bio || '',
      skills,
      averageRating: row.average_rating ?? 0,
      isVerified: !!row.is_verified,
      isActive: !!row.is_active,
      latitude: row.latitude ?? 0,
      longitude: row.longitude ?? 0,
    };
  }

  const addresses = db
    .prepare('SELECT * FROM addresses WHERE user_id = ?')
    .all(row.user_id)
    .map(mapAddress);

  return {
    ...base,
    savedAddresses: addresses,
    defaultAddressId: row.default_address_id,
    loyaltyPoints: row.loyalty_points ?? 0,
  };
}

export function mapBooking(row) {
  return {
    bookingId: row.booking_id,
    customerId: row.customer_id,
    providerId: row.provider_id,
    serviceId: row.service_id,
    slotId: row.slot_id,
    scheduledTime: row.scheduled_time,
    endTime: row.end_time,
    status: row.status,
    totalPrice: row.total_price,
    addressId: row.address_id,
    notes: row.notes || '',
    serviceStartedAt: row.service_started_at,
    serviceCompletedAt: row.service_completed_at,
  };
}

export function mapSlot(row) {
  return {
    slotId: row.slot_id,
    providerId: row.provider_id,
    startTime: row.start_time,
    endTime: row.end_time,
    isAvailable: !!row.is_available,
  };
}

export function mapPayment(row) {
  return {
    paymentId: row.payment_id,
    bookingId: row.booking_id,
    amount: row.amount,
    status: row.status,
    method: row.method,
    transactionRef: row.transaction_ref,
    paidAt: row.paid_at,
  };
}

export function mapService(row) {
  return {
    serviceId: row.service_id,
    providerId: row.provider_id,
    categoryId: row.category_id,
    title: row.title,
    description: row.description,
    priceType: row.price_type,
    basePrice: row.base_price,
    isActive: !!row.is_active,
  };
}

export function haversineKm(lat1, lon1, lat2, lon2) {
  const R = 6371;
  const dLat = ((lat2 - lat1) * Math.PI) / 180;
  const dLon = ((lon2 - lon1) * Math.PI) / 180;
  const a =
    Math.sin(dLat / 2) ** 2 +
    Math.cos((lat1 * Math.PI) / 180) *
      Math.cos((lat2 * Math.PI) / 180) *
      Math.sin(dLon / 2) ** 2;
  return R * 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a));
}
