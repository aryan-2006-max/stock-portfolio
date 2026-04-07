-- Smart Stock Portfolio Management System
-- Run: mysql -u root -p < database/schema.sql

CREATE DATABASE IF NOT EXISTS stock_portfolio;
USE stock_portfolio;

-- Users
CREATE TABLE IF NOT EXISTS users (
  id            INT AUTO_INCREMENT PRIMARY KEY,
  username      VARCHAR(50)  NOT NULL UNIQUE,
  email         VARCHAR(100) NOT NULL UNIQUE,
  password_hash VARCHAR(255) NOT NULL,
  created_at    TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Stocks (master list + price cache)
CREATE TABLE IF NOT EXISTS stocks (
  id            INT AUTO_INCREMENT PRIMARY KEY,
  symbol        VARCHAR(10)  NOT NULL UNIQUE,
  company_name  VARCHAR(100) NOT NULL,
  current_price DECIMAL(10,2) DEFAULT 0.00,
  last_updated  TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

-- Portfolios (one per user by default)
CREATE TABLE IF NOT EXISTS portfolios (
  id         INT AUTO_INCREMENT PRIMARY KEY,
  user_id    INT         NOT NULL,
  name       VARCHAR(100) NOT NULL DEFAULT 'My Portfolio',
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
);

-- Holdings (current position per stock)
CREATE TABLE IF NOT EXISTS holdings (
  id             INT AUTO_INCREMENT PRIMARY KEY,
  portfolio_id   INT             NOT NULL,
  stock_id       INT             NOT NULL,
  quantity       DECIMAL(10,4)   NOT NULL DEFAULT 0,
  avg_buy_price  DECIMAL(10,2)   NOT NULL DEFAULT 0.00,
  FOREIGN KEY (portfolio_id) REFERENCES portfolios(id) ON DELETE CASCADE,
  FOREIGN KEY (stock_id)     REFERENCES stocks(id)     ON DELETE CASCADE,
  UNIQUE KEY unique_holding (portfolio_id, stock_id)
);

-- Transactions (full buy/sell log)
CREATE TABLE IF NOT EXISTS transactions (
  id        INT AUTO_INCREMENT PRIMARY KEY,
  user_id   INT             NOT NULL,
  stock_id  INT             NOT NULL,
  type      ENUM('BUY','SELL') NOT NULL,
  quantity  DECIMAL(10,4)   NOT NULL,
  price     DECIMAL(10,2)   NOT NULL,
  timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (user_id)  REFERENCES users(id)  ON DELETE CASCADE,
  FOREIGN KEY (stock_id) REFERENCES stocks(id) ON DELETE CASCADE
);

-- Watchlist
CREATE TABLE IF NOT EXISTS watchlist (
  id        INT AUTO_INCREMENT PRIMARY KEY,
  user_id   INT NOT NULL,
  stock_id  INT NOT NULL,
  added_at  TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (user_id)  REFERENCES users(id)  ON DELETE CASCADE,
  FOREIGN KEY (stock_id) REFERENCES stocks(id) ON DELETE CASCADE,
  UNIQUE KEY unique_watchlist (user_id, stock_id)
);

-- ─────────────────────────────────────────────
--  Sample stock data (safe to re-run)
-- ─────────────────────────────────────────────
INSERT IGNORE INTO stocks (symbol, company_name, current_price) VALUES
('AAPL',  'Apple Inc.',               178.50),
('GOOGL', 'Alphabet Inc.',            141.80),
('MSFT',  'Microsoft Corporation',   378.85),
('AMZN',  'Amazon.com Inc.',          178.25),
('TSLA',  'Tesla Inc.',               177.90),
('NVDA',  'NVIDIA Corporation',       495.22),
('META',  'Meta Platforms Inc.',      474.99),
('NFLX',  'Netflix Inc.',             605.88),
('AMD',   'Advanced Micro Devices',   162.45),
('INTC',  'Intel Corporation',         30.12),
('DIS',   'The Walt Disney Company',   88.60),
('BABA',  'Alibaba Group',             74.30),
('PYPL',  'PayPal Holdings Inc.',      62.10),
('SQ',    'Block Inc.',                69.80),
('SPOT',  'Spotify Technology',       246.35);

