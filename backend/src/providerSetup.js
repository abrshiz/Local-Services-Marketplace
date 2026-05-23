import { v4 as uuidv4 } from 'uuid';

export function seedSlotsForProvider(db, providerId) {
  const insertSlot = db.prepare(`
    INSERT INTO time_slots (slot_id, provider_id, start_time, end_time, is_available)
    VALUES (?, ?, ?, ?, 1)
  `);
  const now = new Date();
  const base = new Date(now.getFullYear(), now.getMonth(), now.getDate());

  for (let d = 0; d < 14; d++) {
    const day = new Date(base);
    day.setDate(day.getDate() + d);
    for (const hour of [9, 11, 14, 16]) {
      const start = new Date(day);
      start.setHours(hour, 0, 0, 0);
      if (start < new Date(now.getTime() - 3600000)) continue;
      const end = new Date(start);
      end.setHours(start.getHours() + 2);
      insertSlot.run(uuidv4(), providerId, start.toISOString(), end.toISOString());
    }
  }
}

export function setupProviderCategories(db, providerId, providerName, categoryIds) {
  const getCat = db.prepare('SELECT * FROM categories WHERE category_id = ?');
  const insertSkill = db.prepare(
    'INSERT INTO provider_skills (provider_id, category_id) VALUES (?, ?)',
  );
  const insertService = db.prepare(`
    INSERT INTO services (service_id, provider_id, category_id, title, description, price_type, base_price, is_active)
    VALUES (?, ?, ?, ?, ?, 'FIXED', ?, 1)
  `);

  for (const categoryId of categoryIds) {
    const cat = getCat.get(categoryId);
    if (!cat) continue;
    insertSkill.run(providerId, categoryId);
    insertService.run(
      uuidv4(),
      providerId,
      categoryId,
      `${providerName} — ${cat.name}`,
      `Professional ${cat.name.toLowerCase()} services`,
      75 + Math.floor(Math.random() * 50),
    );
  }

  seedSlotsForProvider(db, providerId);
}
