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
('RELIANCE', 'Reliance Industries Ltd.', 1395.10),
('HDFCBANK', 'HDFC Bank Ltd.', 840.60),
('ICICIBANK', 'ICICI Bank Ltd.', 1100.25),
('INFY', 'Infosys Ltd.', 1650.80),
('TCS', 'Tata Consultancy Services Ltd.', 3800.50),
('ITC', 'ITC Ltd.', 420.30),
('LT', 'Larsen & Toubro Ltd.', 3650.75),
('SBIN', 'State Bank of India', 780.40),
('BHARTIARTL', 'Bharti Airtel Ltd.', 1250.60),
('KOTAKBANK', 'Kotak Mahindra Bank Ltd.', 1750.20),
('HINDUNILVR', 'Hindustan Unilever Ltd.', 2085.00),
('ASIANPAINT', 'Asian Paints Ltd.', 2217.30),
('AXISBANK', 'Axis Bank Ltd.', 1125.45),
('BAJFINANCE', 'Bajaj Finance Ltd.', 7200.10),
('MARUTI', 'Maruti Suzuki India Ltd.', 10500.80),
('SUNPHARMA', 'Sun Pharmaceutical Industries Ltd.', 1450.90),
('TITAN', 'Titan Company Ltd.', 3500.25),
('ULTRACEMCO', 'UltraTech Cement Ltd.', 9500.60),
('NESTLEIND', 'Nestle India Ltd.', 1183.20),
('WIPRO', 'Wipro Ltd.', 520.75);
