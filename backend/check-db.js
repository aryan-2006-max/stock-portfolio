const mysql = require('mysql2/promise');
const fs = require('fs');

async function main() {
  const db = await mysql.createConnection({
    host: 'mysql-23a-stockportfolio23.d.aivencloud.com',
    port: 11571,
    user: 'avnadmin',
    password: 'AVNS_re3ndc72GDPKryaPDkK',
    database: 'stock_portfolio',
    ssl: { rejectUnauthorized: false },
  });

  let out = '';
  const log = (s) => { out += s + '\n'; };

  const [users] = await db.query('SELECT id, username, email, created_at FROM users');
  log('=== USERS (' + users.length + ') ===');
  users.forEach(u => log('  ID:' + u.id + ' | ' + u.username + ' | ' + u.email));

  const [stocks] = await db.query('SELECT id, symbol, company_name, current_price FROM stocks');
  log('\n=== STOCKS (' + stocks.length + ') ===');
  stocks.forEach(s => log('  ' + s.symbol + ' | ' + s.company_name + ' | $' + s.current_price));

  const [portfolios] = await db.query('SELECT * FROM portfolios');
  log('\n=== PORTFOLIOS (' + portfolios.length + ') ===');
  portfolios.forEach(p => log('  ID:' + p.id + ' | UserID:' + p.user_id + ' | ' + p.name));

  const [holdings] = await db.query('SELECT h.id, h.portfolio_id, s.symbol, h.quantity, h.avg_buy_price FROM holdings h JOIN stocks s ON h.stock_id=s.id');
  log('\n=== HOLDINGS (' + holdings.length + ') ===');
  holdings.forEach(h => log('  ' + h.symbol + ' | Qty:' + h.quantity + ' | AvgPrice:$' + h.avg_buy_price));

  const [txns] = await db.query('SELECT t.id, t.user_id, s.symbol, t.type, t.quantity, t.price, t.timestamp FROM transactions t JOIN stocks s ON t.stock_id=s.id ORDER BY t.timestamp DESC');
  log('\n=== TRANSACTIONS (' + txns.length + ') ===');
  txns.forEach(t => log('  ' + t.type + ' ' + t.quantity + ' ' + t.symbol + ' @ $' + t.price));

  const [wl] = await db.query('SELECT w.id, w.user_id, s.symbol FROM watchlist w JOIN stocks s ON w.stock_id=s.id');
  log('\n=== WATCHLIST (' + wl.length + ') ===');
  wl.forEach(w => log('  User:' + w.user_id + ' | ' + w.symbol));

  log('\n=== SUMMARY ===');
  log('  Users:' + users.length + ' | Stocks:' + stocks.length + ' | Portfolios:' + portfolios.length + ' | Holdings:' + holdings.length + ' | Txns:' + txns.length + ' | Watchlist:' + wl.length);

  fs.writeFileSync('db-report.txt', out);
  console.log(out);
  await db.end();
}
main().catch(e => console.error('Error:', e.message));
