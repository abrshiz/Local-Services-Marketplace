import { initSchema } from './db.js';
import { seedDatabaseIfEmpty } from './seedData.js';

initSchema();

if (!seedDatabaseIfEmpty()) {
  console.log('Database already seeded.');
} else {
  console.log('Seed complete.');
  console.log('Demo: customer@demo.com / provider1@demo.com — password: password123');
}
