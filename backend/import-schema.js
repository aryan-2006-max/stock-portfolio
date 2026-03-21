/**
 * One-time script to import database/schema.sql into a remote MySQL database.
 * Uses the mysql2 package (already a project dependency).
 *
 * Usage:
 *   node import-schema.js
 *
 * Reads connection details from environment variables or the defaults below.
 * Update the values below with your Aiven credentials before running.
 */

const fs   = require('fs');
const path = require('path');
const mysql = require('mysql2/promise');

// ──── UPDATE THESE WITH YOUR AIVEN CREDENTIALS ────
const DB_HOST     = process.env.DB_HOST     || 'mysql-23a-stockportfolio23.d.aivencloud.com';
const DB_PORT     = process.env.DB_PORT     || 11571;
const DB_USER     = process.env.DB_USER     || 'avnadmin';
const DB_PASSWORD = process.env.DB_PASSWORD || 'AVNS_re3ndc72GDPKryaPDkK';
// ───────────────────────────────────────────────────

async function main() {
  const schemaPath = path.join(__dirname, '..', 'database', 'schema.sql');
  const schema = fs.readFileSync(schemaPath, 'utf8');

  console.log('⏳ Connecting to Aiven MySQL...');

  // Connect WITHOUT specifying a database first (schema.sql creates it)
  const connection = await mysql.createConnection({
    host: DB_HOST,
    port: Number(DB_PORT),
    user: DB_USER,
    password: DB_PASSWORD,
    multipleStatements: true,   // required to run multiple SQL statements
    ssl: { rejectUnauthorized: false },
  });

  console.log('✅ Connected! Running schema.sql...');

  await connection.query(schema);

  console.log('✅ Schema imported successfully!');
  console.log('   Tables created + sample stocks seeded.');

  await connection.end();
}

main().catch(err => {
  console.error('❌ Error:', err.message);
  process.exit(1);
});
