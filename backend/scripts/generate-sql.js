const fs = require('fs');
const path = require('path');
const bcrypt = require('bcryptjs');

const outputPath = path.join(__dirname, '../src/sql/technovo_db.sql');

const esc = (str) => String(str).replace(/'/g, "''");

const randomDate = (start, end) => {
  const s = new Date(start).getTime();
  const e = new Date(end).getTime();
  return new Date(s + Math.random() * (e - s));
};

const fmtDate = (d) => d.toISOString().slice(0, 10);
const fmtDateTime = (d) => d.toISOString().slice(0, 19).replace('T', ' ');

const platforms = ['Shopee', 'Tokopedia', 'Lazada', 'TikTok Shop'];
const categories = ['Laptop', 'Chromebook'];
const brands = ['ASUS', 'Acer', 'Dell', 'Lenovo', 'HP', 'Toshiba', 'Fujitsu'];
const orderStatuses = ['pending', 'processing', 'shipped', 'delivered', 'cancelled'];
const returnStatuses = ['pending', 'approved', 'completed'];

const users = [
  { name: 'Sarif', email: 'sarif@technovo.id', role: 'LEADER' },
  { name: 'Kiki', email: 'kiki@technovo.id', role: 'ADMIN' },
  { name: 'Fifi', email: 'fifi@technovo.id', role: 'HOST' },
  { name: 'Zalla', email: 'zalla@technovo.id', role: 'HOST' },
  { name: 'Nisa', email: 'nisa@technovo.id', role: 'HOST' },
];

const passwordHash = bcrypt.hashSync('password123', 10);

let sql = `-- TECHNOVO Database Schema & Seed Data
-- Generated automatically - Import via phpMyAdmin

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
SET time_zone = "+07:00";

CREATE DATABASE IF NOT EXISTS technovo_db CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE technovo_db;

DROP TABLE IF EXISTS activity_logs;
DROP TABLE IF EXISTS stock_movements;
DROP TABLE IF EXISTS returns;
DROP TABLE IF EXISTS marketplace_order_items;
DROP TABLE IF EXISTS marketplace_orders;
DROP TABLE IF EXISTS live_sale_items;
DROP TABLE IF EXISTS live_sales;
DROP TABLE IF EXISTS live_schedules;
DROP TABLE IF EXISTS products;
DROP TABLE IF EXISTS customers;
DROP TABLE IF EXISTS bonus_rules;
DROP TABLE IF EXISTS categories;
DROP TABLE IF EXISTS platforms;
DROP TABLE IF EXISTS users;

CREATE TABLE users (
  id INT AUTO_INCREMENT PRIMARY KEY,
  name VARCHAR(100) NOT NULL,
  email VARCHAR(150) NOT NULL UNIQUE,
  password VARCHAR(255) NOT NULL,
  role ENUM('LEADER','ADMIN','HOST') NOT NULL,
  is_active TINYINT(1) DEFAULT 1,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  INDEX idx_users_role (role),
  INDEX idx_users_email (email)
) ENGINE=InnoDB;

CREATE TABLE platforms (
  id INT AUTO_INCREMENT PRIMARY KEY,
  name VARCHAR(100) NOT NULL UNIQUE,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB;

CREATE TABLE categories (
  id INT AUTO_INCREMENT PRIMARY KEY,
  name VARCHAR(100) NOT NULL UNIQUE,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB;

CREATE TABLE bonus_rules (
  id INT AUTO_INCREMENT PRIMARY KEY,
  category_id INT NOT NULL,
  bonus_amount DECIMAL(12,2) NOT NULL,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (category_id) REFERENCES categories(id) ON DELETE CASCADE,
  INDEX idx_bonus_category (category_id)
) ENGINE=InnoDB;

CREATE TABLE customers (
  id INT AUTO_INCREMENT PRIMARY KEY,
  name VARCHAR(150) NOT NULL,
  email VARCHAR(150),
  phone VARCHAR(30),
  address TEXT,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  INDEX idx_customers_name (name),
  INDEX idx_customers_email (email)
) ENGINE=InnoDB;

CREATE TABLE products (
  id INT AUTO_INCREMENT PRIMARY KEY,
  name VARCHAR(200) NOT NULL,
  sku VARCHAR(50) NOT NULL UNIQUE,
  brand VARCHAR(50) NOT NULL,
  category_id INT NOT NULL,
  price DECIMAL(12,2) NOT NULL,
  stock INT NOT NULL DEFAULT 0,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  FOREIGN KEY (category_id) REFERENCES categories(id),
  INDEX idx_products_category (category_id),
  INDEX idx_products_brand (brand),
  INDEX idx_products_sku (sku)
) ENGINE=InnoDB;

CREATE TABLE live_schedules (
  id INT AUTO_INCREMENT PRIMARY KEY,
  host_id INT NOT NULL,
  platform_id INT NOT NULL,
  title VARCHAR(200) NOT NULL,
  schedule_date DATE NOT NULL,
  start_time TIME NOT NULL,
  end_time TIME NOT NULL,
  status ENUM('scheduled','completed','cancelled') DEFAULT 'scheduled',
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  FOREIGN KEY (host_id) REFERENCES users(id),
  FOREIGN KEY (platform_id) REFERENCES platforms(id),
  INDEX idx_schedule_date (schedule_date),
  INDEX idx_schedule_host (host_id),
  INDEX idx_schedule_status (status)
) ENGINE=InnoDB;

CREATE TABLE live_sales (
  id INT AUTO_INCREMENT PRIMARY KEY,
  schedule_id INT NOT NULL,
  host_id INT NOT NULL,
  sale_date DATE NOT NULL,
  total_amount DECIMAL(14,2) NOT NULL DEFAULT 0,
  total_items INT NOT NULL DEFAULT 0,
  status ENUM('pending','completed') DEFAULT 'completed',
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (schedule_id) REFERENCES live_schedules(id),
  FOREIGN KEY (host_id) REFERENCES users(id),
  INDEX idx_live_sales_date (sale_date),
  INDEX idx_live_sales_host (host_id)
) ENGINE=InnoDB;

CREATE TABLE live_sale_items (
  id INT AUTO_INCREMENT PRIMARY KEY,
  live_sale_id INT NOT NULL,
  product_id INT NOT NULL,
  quantity INT NOT NULL,
  unit_price DECIMAL(12,2) NOT NULL,
  subtotal DECIMAL(14,2) NOT NULL,
  FOREIGN KEY (live_sale_id) REFERENCES live_sales(id) ON DELETE CASCADE,
  FOREIGN KEY (product_id) REFERENCES products(id),
  INDEX idx_live_sale_items_sale (live_sale_id)
) ENGINE=InnoDB;

CREATE TABLE marketplace_orders (
  id INT AUTO_INCREMENT PRIMARY KEY,
  order_number VARCHAR(50) NOT NULL UNIQUE,
  customer_id INT NOT NULL,
  platform_id INT NOT NULL,
  order_date DATETIME NOT NULL,
  status ENUM('pending','processing','shipped','delivered','cancelled') DEFAULT 'pending',
  total_amount DECIMAL(14,2) NOT NULL DEFAULT 0,
  created_by INT,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (customer_id) REFERENCES customers(id),
  FOREIGN KEY (platform_id) REFERENCES platforms(id),
  FOREIGN KEY (created_by) REFERENCES users(id),
  INDEX idx_orders_date (order_date),
  INDEX idx_orders_status (status),
  INDEX idx_orders_platform (platform_id)
) ENGINE=InnoDB;

CREATE TABLE marketplace_order_items (
  id INT AUTO_INCREMENT PRIMARY KEY,
  order_id INT NOT NULL,
  product_id INT NOT NULL,
  quantity INT NOT NULL,
  unit_price DECIMAL(12,2) NOT NULL,
  subtotal DECIMAL(14,2) NOT NULL,
  FOREIGN KEY (order_id) REFERENCES marketplace_orders(id) ON DELETE CASCADE,
  FOREIGN KEY (product_id) REFERENCES products(id),
  INDEX idx_order_items_order (order_id)
) ENGINE=InnoDB;

CREATE TABLE returns (
  id INT AUTO_INCREMENT PRIMARY KEY,
  order_id INT NOT NULL,
  product_id INT NOT NULL,
  quantity INT NOT NULL,
  reason TEXT,
  return_date DATE NOT NULL,
  status ENUM('pending','approved','rejected','completed') DEFAULT 'pending',
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (order_id) REFERENCES marketplace_orders(id),
  FOREIGN KEY (product_id) REFERENCES products(id),
  INDEX idx_returns_date (return_date),
  INDEX idx_returns_status (status)
) ENGINE=InnoDB;

CREATE TABLE stock_movements (
  id INT AUTO_INCREMENT PRIMARY KEY,
  product_id INT NOT NULL,
  movement_type ENUM('IN','OUT') NOT NULL,
  quantity INT NOT NULL,
  reference_type VARCHAR(50),
  reference_id INT,
  notes TEXT,
  created_by INT,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (product_id) REFERENCES products(id),
  FOREIGN KEY (created_by) REFERENCES users(id),
  INDEX idx_stock_product (product_id),
  INDEX idx_stock_type (movement_type),
  INDEX idx_stock_created (created_at)
) ENGINE=InnoDB;

CREATE TABLE activity_logs (
  id INT AUTO_INCREMENT PRIMARY KEY,
  user_id INT,
  action VARCHAR(50) NOT NULL,
  module VARCHAR(100) NOT NULL,
  description TEXT,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE SET NULL,
  INDEX idx_activity_user (user_id),
  INDEX idx_activity_module (module),
  INDEX idx_activity_created (created_at)
) ENGINE=InnoDB;

-- SEED: Users
INSERT INTO users (name, email, password, role) VALUES
`;

users.forEach((u, i) => {
  sql += `('${esc(u.name)}', '${esc(u.email)}', '${passwordHash}', '${u.role}')${i < users.length - 1 ? ',' : ';'}\n`;
});

sql += `\n-- SEED: Platforms\nINSERT INTO platforms (name) VALUES\n`;
platforms.forEach((p, i) => {
  sql += `('${p}')${i < platforms.length - 1 ? ',' : ';'}\n`;
});

sql += `\n-- SEED: Categories\nINSERT INTO categories (name) VALUES\n`;
categories.forEach((c, i) => {
  sql += `('${c}')${i < categories.length - 1 ? ',' : ';'}\n`;
});

sql += `\n-- SEED: Bonus Rules\nINSERT INTO bonus_rules (category_id, bonus_amount) VALUES (1, 10000), (2, 3000);\n`;

sql += `\n-- SEED: Products (20)\nINSERT INTO products (name, sku, brand, category_id, price, stock) VALUES\n`;
const products = [];
for (let i = 1; i <= 20; i++) {
  const catId = i <= 12 ? 1 : 2;
  const brand = brands[(i - 1) % brands.length];
  const catName = catId === 1 ? 'Laptop' : 'Chromebook';
  const price = catId === 1 ? 8000000 + i * 250000 : 4500000 + i * 150000;
  const stock = 50 + i * 3;
  products.push({ id: i, catId, brand, price, stock, name: `${brand} ${catName} Model ${i}`, sku: `TN-${catName.slice(0, 2).toUpperCase()}-${String(i).padStart(3, '0')}` });
  sql += `('${esc(products[i - 1].name)}', '${products[i - 1].sku}', '${brand}', ${catId}, ${price}, ${stock})${i < 20 ? ',' : ';'}\n`;
}

sql += `\n-- SEED: Customers (100)\nINSERT INTO customers (name, email, phone, address) VALUES\n`;
for (let i = 1; i <= 100; i++) {
  sql += `('Customer ${i}', 'customer${i}@email.com', '0812${String(1000000 + i)}', 'Jl. Technovo No. ${i}, Jakarta')${i < 100 ? ',' : ';'}\n`;
}

const hostIds = [3, 4, 5];
const startDate = new Date('2026-02-01');
const endDate = new Date('2026-05-31');

sql += `\n-- SEED: Live Schedules (360)\nINSERT INTO live_schedules (host_id, platform_id, title, schedule_date, start_time, end_time, status) VALUES\n`;
const scheduleRows = [];
for (let i = 1; i <= 360; i++) {
  const hostId = hostIds[(i - 1) % 3];
  const platformId = ((i - 1) % 4) + 1;
  const d = randomDate(startDate, endDate);
  const dateStr = fmtDate(d);
  scheduleRows.push({ id: i, hostId, platformId, dateStr });
  sql += `(${hostId}, ${platformId}, 'Live Session #${i}', '${dateStr}', '10:00:00', '12:00:00', 'completed')${i < 360 ? ',' : ';'}\n`;
}

sql += `\n-- SEED: Live Sales (360) + Items\n`;
for (let i = 1; i <= 360; i++) {
  const sch = scheduleRows[i - 1];
  const product = products[(i - 1) % 20];
  const qty = (i % 3) + 1;
  const subtotal = qty * product.price;
  sql += `INSERT INTO live_sales (schedule_id, host_id, sale_date, total_amount, total_items, status) VALUES (${i}, ${sch.hostId}, '${sch.dateStr}', ${subtotal}, ${qty}, 'completed');\n`;
  sql += `INSERT INTO live_sale_items (live_sale_id, product_id, quantity, unit_price, subtotal) VALUES (${i}, ${product.id}, ${qty}, ${product.price}, ${subtotal});\n`;
}

sql += `\n-- SEED: Marketplace Orders (1000+)\n`;
const deliveredOrderIds = [];
for (let i = 1; i <= 1050; i++) {
  const customerId = ((i - 1) % 100) + 1;
  const platformId = ((i - 1) % 4) + 1;
  const d = randomDate(startDate, endDate);
  const status = i <= 900 ? 'delivered' : orderStatuses[i % 5];
  const product = products[(i - 1) % 20];
  const qty = (i % 2) + 1;
  const total = qty * product.price;
  const orderNum = `ORD-2026-${String(i).padStart(5, '0')}`;
  sql += `INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('${orderNum}', ${customerId}, ${platformId}, '${fmtDateTime(d)}', '${status}', ${total}, 2);\n`;
  sql += `INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (${i}, ${product.id}, ${qty}, ${product.price}, ${total});\n`;
  if (status === 'delivered') deliveredOrderIds.push(i);
}

sql += `\n-- SEED: Returns (20)\n`;
for (let i = 1; i <= 20; i++) {
  const orderId = deliveredOrderIds[i * 10] || i;
  const product = products[i - 1];
  const d = randomDate(startDate, endDate);
  sql += `INSERT INTO returns (order_id, product_id, quantity, reason, return_date, status) VALUES (${orderId}, ${product.id}, 1, 'Product defect / customer request', '${fmtDate(d)}', '${returnStatuses[i % 3]}');\n`;
}

sql += `\n-- SEED: Stock Movements\n`;
for (let i = 1; i <= 20; i++) {
  const p = products[i - 1];
  sql += `INSERT INTO stock_movements (product_id, movement_type, quantity, reference_type, reference_id, notes, created_by) VALUES (${p.id}, 'IN', ${p.stock}, 'product', ${p.id}, 'Initial stock', 1);\n`;
}
for (let i = 1; i <= 50; i++) {
  const p = products[i % 20];
  const d = randomDate(startDate, endDate);
  sql += `INSERT INTO stock_movements (product_id, movement_type, quantity, reference_type, reference_id, notes, created_by, created_at) VALUES (${p.id}, 'OUT', ${(i % 3) + 1}, 'marketplace_order', ${i}, 'Auto stock out', 2, '${fmtDateTime(d)}');\n`;
}

sql += `\n-- SEED: Activity Logs\n`;
const modules = ['Auth', 'Products', 'Users', 'Live Schedules', 'Live Sales', 'Marketplace', 'Returns'];
const actions = ['LOGIN', 'CREATE', 'UPDATE', 'DELETE', 'VIEW'];
for (let i = 1; i <= 200; i++) {
  const userId = (i % 5) + 1;
  const d = randomDate(startDate, endDate);
  sql += `INSERT INTO activity_logs (user_id, action, module, description, created_at) VALUES (${userId}, '${actions[i % actions.length]}', '${modules[i % modules.length]}', 'System activity log entry #${i}', '${fmtDateTime(d)}');\n`;
}

fs.writeFileSync(outputPath, sql, 'utf8');
console.log(`SQL generated: ${outputPath}`);
console.log(`File size: ${(fs.statSync(outputPath).size / 1024 / 1024).toFixed(2)} MB`);
