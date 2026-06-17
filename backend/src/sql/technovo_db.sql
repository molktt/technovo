-- TECHNOVO Database Schema & Seed Data
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
  full_name VARCHAR(100) NOT NULL,
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
INSERT INTO users (full_name, email, password, role) VALUES
('Sarif', 'sarif@technovo.id', '$2a$10$O8dLISGfdJEaM8pYUeh.1u58ZSH.uGqWC9/JRWUJ665yO8sckaRK.', 'LEADER'),
('Kiki', 'kiki@technovo.id', '$2a$10$O8dLISGfdJEaM8pYUeh.1u58ZSH.uGqWC9/JRWUJ665yO8sckaRK.', 'ADMIN'),
('Fifi', 'fifi@technovo.id', '$2a$10$O8dLISGfdJEaM8pYUeh.1u58ZSH.uGqWC9/JRWUJ665yO8sckaRK.', 'HOST'),
('Zalla', 'zalla@technovo.id', '$2a$10$O8dLISGfdJEaM8pYUeh.1u58ZSH.uGqWC9/JRWUJ665yO8sckaRK.', 'HOST'),
('Nisa', 'nisa@technovo.id', '$2a$10$O8dLISGfdJEaM8pYUeh.1u58ZSH.uGqWC9/JRWUJ665yO8sckaRK.', 'HOST');

-- SEED: Platforms
INSERT INTO platforms (name) VALUES
('Shopee'),
('Tokopedia'),
('Lazada'),
('TikTok Shop');

-- SEED: Categories
INSERT INTO categories (name) VALUES
('Laptop'),
('Chromebook');

-- SEED: Bonus Rules
INSERT INTO bonus_rules (category_id, bonus_amount) VALUES (1, 10000), (2, 3000);

-- SEED: Products (20)
INSERT INTO products (name, sku, brand, category_id, price, stock) VALUES
('ASUS Laptop Model 1', 'TN-LA-001', 'ASUS', 1, 8250000, 53),
('Acer Laptop Model 2', 'TN-LA-002', 'Acer', 1, 8500000, 56),
('Dell Laptop Model 3', 'TN-LA-003', 'Dell', 1, 8750000, 59),
('Lenovo Laptop Model 4', 'TN-LA-004', 'Lenovo', 1, 9000000, 62),
('HP Laptop Model 5', 'TN-LA-005', 'HP', 1, 9250000, 65),
('Toshiba Laptop Model 6', 'TN-LA-006', 'Toshiba', 1, 9500000, 68),
('Fujitsu Laptop Model 7', 'TN-LA-007', 'Fujitsu', 1, 9750000, 71),
('ASUS Laptop Model 8', 'TN-LA-008', 'ASUS', 1, 10000000, 74),
('Acer Laptop Model 9', 'TN-LA-009', 'Acer', 1, 10250000, 77),
('Dell Laptop Model 10', 'TN-LA-010', 'Dell', 1, 10500000, 80),
('Lenovo Laptop Model 11', 'TN-LA-011', 'Lenovo', 1, 10750000, 83),
('HP Laptop Model 12', 'TN-LA-012', 'HP', 1, 11000000, 86),
('Toshiba Chromebook Model 13', 'TN-CH-013', 'Toshiba', 2, 6450000, 89),
('Fujitsu Chromebook Model 14', 'TN-CH-014', 'Fujitsu', 2, 6600000, 92),
('ASUS Chromebook Model 15', 'TN-CH-015', 'ASUS', 2, 6750000, 95),
('Acer Chromebook Model 16', 'TN-CH-016', 'Acer', 2, 6900000, 98),
('Dell Chromebook Model 17', 'TN-CH-017', 'Dell', 2, 7050000, 101),
('Lenovo Chromebook Model 18', 'TN-CH-018', 'Lenovo', 2, 7200000, 104),
('HP Chromebook Model 19', 'TN-CH-019', 'HP', 2, 7350000, 107),
('Toshiba Chromebook Model 20', 'TN-CH-020', 'Toshiba', 2, 7500000, 110);

-- SEED: Customers (100)
INSERT INTO customers (name, email, phone, address) VALUES
('Customer 1', 'customer1@email.com', '08121000001', 'Jl. Technovo No. 1, Jakarta'),
('Customer 2', 'customer2@email.com', '08121000002', 'Jl. Technovo No. 2, Jakarta'),
('Customer 3', 'customer3@email.com', '08121000003', 'Jl. Technovo No. 3, Jakarta'),
('Customer 4', 'customer4@email.com', '08121000004', 'Jl. Technovo No. 4, Jakarta'),
('Customer 5', 'customer5@email.com', '08121000005', 'Jl. Technovo No. 5, Jakarta'),
('Customer 6', 'customer6@email.com', '08121000006', 'Jl. Technovo No. 6, Jakarta'),
('Customer 7', 'customer7@email.com', '08121000007', 'Jl. Technovo No. 7, Jakarta'),
('Customer 8', 'customer8@email.com', '08121000008', 'Jl. Technovo No. 8, Jakarta'),
('Customer 9', 'customer9@email.com', '08121000009', 'Jl. Technovo No. 9, Jakarta'),
('Customer 10', 'customer10@email.com', '08121000010', 'Jl. Technovo No. 10, Jakarta'),
('Customer 11', 'customer11@email.com', '08121000011', 'Jl. Technovo No. 11, Jakarta'),
('Customer 12', 'customer12@email.com', '08121000012', 'Jl. Technovo No. 12, Jakarta'),
('Customer 13', 'customer13@email.com', '08121000013', 'Jl. Technovo No. 13, Jakarta'),
('Customer 14', 'customer14@email.com', '08121000014', 'Jl. Technovo No. 14, Jakarta'),
('Customer 15', 'customer15@email.com', '08121000015', 'Jl. Technovo No. 15, Jakarta'),
('Customer 16', 'customer16@email.com', '08121000016', 'Jl. Technovo No. 16, Jakarta'),
('Customer 17', 'customer17@email.com', '08121000017', 'Jl. Technovo No. 17, Jakarta'),
('Customer 18', 'customer18@email.com', '08121000018', 'Jl. Technovo No. 18, Jakarta'),
('Customer 19', 'customer19@email.com', '08121000019', 'Jl. Technovo No. 19, Jakarta'),
('Customer 20', 'customer20@email.com', '08121000020', 'Jl. Technovo No. 20, Jakarta'),
('Customer 21', 'customer21@email.com', '08121000021', 'Jl. Technovo No. 21, Jakarta'),
('Customer 22', 'customer22@email.com', '08121000022', 'Jl. Technovo No. 22, Jakarta'),
('Customer 23', 'customer23@email.com', '08121000023', 'Jl. Technovo No. 23, Jakarta'),
('Customer 24', 'customer24@email.com', '08121000024', 'Jl. Technovo No. 24, Jakarta'),
('Customer 25', 'customer25@email.com', '08121000025', 'Jl. Technovo No. 25, Jakarta'),
('Customer 26', 'customer26@email.com', '08121000026', 'Jl. Technovo No. 26, Jakarta'),
('Customer 27', 'customer27@email.com', '08121000027', 'Jl. Technovo No. 27, Jakarta'),
('Customer 28', 'customer28@email.com', '08121000028', 'Jl. Technovo No. 28, Jakarta'),
('Customer 29', 'customer29@email.com', '08121000029', 'Jl. Technovo No. 29, Jakarta'),
('Customer 30', 'customer30@email.com', '08121000030', 'Jl. Technovo No. 30, Jakarta'),
('Customer 31', 'customer31@email.com', '08121000031', 'Jl. Technovo No. 31, Jakarta'),
('Customer 32', 'customer32@email.com', '08121000032', 'Jl. Technovo No. 32, Jakarta'),
('Customer 33', 'customer33@email.com', '08121000033', 'Jl. Technovo No. 33, Jakarta'),
('Customer 34', 'customer34@email.com', '08121000034', 'Jl. Technovo No. 34, Jakarta'),
('Customer 35', 'customer35@email.com', '08121000035', 'Jl. Technovo No. 35, Jakarta'),
('Customer 36', 'customer36@email.com', '08121000036', 'Jl. Technovo No. 36, Jakarta'),
('Customer 37', 'customer37@email.com', '08121000037', 'Jl. Technovo No. 37, Jakarta'),
('Customer 38', 'customer38@email.com', '08121000038', 'Jl. Technovo No. 38, Jakarta'),
('Customer 39', 'customer39@email.com', '08121000039', 'Jl. Technovo No. 39, Jakarta'),
('Customer 40', 'customer40@email.com', '08121000040', 'Jl. Technovo No. 40, Jakarta'),
('Customer 41', 'customer41@email.com', '08121000041', 'Jl. Technovo No. 41, Jakarta'),
('Customer 42', 'customer42@email.com', '08121000042', 'Jl. Technovo No. 42, Jakarta'),
('Customer 43', 'customer43@email.com', '08121000043', 'Jl. Technovo No. 43, Jakarta'),
('Customer 44', 'customer44@email.com', '08121000044', 'Jl. Technovo No. 44, Jakarta'),
('Customer 45', 'customer45@email.com', '08121000045', 'Jl. Technovo No. 45, Jakarta'),
('Customer 46', 'customer46@email.com', '08121000046', 'Jl. Technovo No. 46, Jakarta'),
('Customer 47', 'customer47@email.com', '08121000047', 'Jl. Technovo No. 47, Jakarta'),
('Customer 48', 'customer48@email.com', '08121000048', 'Jl. Technovo No. 48, Jakarta'),
('Customer 49', 'customer49@email.com', '08121000049', 'Jl. Technovo No. 49, Jakarta'),
('Customer 50', 'customer50@email.com', '08121000050', 'Jl. Technovo No. 50, Jakarta'),
('Customer 51', 'customer51@email.com', '08121000051', 'Jl. Technovo No. 51, Jakarta'),
('Customer 52', 'customer52@email.com', '08121000052', 'Jl. Technovo No. 52, Jakarta'),
('Customer 53', 'customer53@email.com', '08121000053', 'Jl. Technovo No. 53, Jakarta'),
('Customer 54', 'customer54@email.com', '08121000054', 'Jl. Technovo No. 54, Jakarta'),
('Customer 55', 'customer55@email.com', '08121000055', 'Jl. Technovo No. 55, Jakarta'),
('Customer 56', 'customer56@email.com', '08121000056', 'Jl. Technovo No. 56, Jakarta'),
('Customer 57', 'customer57@email.com', '08121000057', 'Jl. Technovo No. 57, Jakarta'),
('Customer 58', 'customer58@email.com', '08121000058', 'Jl. Technovo No. 58, Jakarta'),
('Customer 59', 'customer59@email.com', '08121000059', 'Jl. Technovo No. 59, Jakarta'),
('Customer 60', 'customer60@email.com', '08121000060', 'Jl. Technovo No. 60, Jakarta'),
('Customer 61', 'customer61@email.com', '08121000061', 'Jl. Technovo No. 61, Jakarta'),
('Customer 62', 'customer62@email.com', '08121000062', 'Jl. Technovo No. 62, Jakarta'),
('Customer 63', 'customer63@email.com', '08121000063', 'Jl. Technovo No. 63, Jakarta'),
('Customer 64', 'customer64@email.com', '08121000064', 'Jl. Technovo No. 64, Jakarta'),
('Customer 65', 'customer65@email.com', '08121000065', 'Jl. Technovo No. 65, Jakarta'),
('Customer 66', 'customer66@email.com', '08121000066', 'Jl. Technovo No. 66, Jakarta'),
('Customer 67', 'customer67@email.com', '08121000067', 'Jl. Technovo No. 67, Jakarta'),
('Customer 68', 'customer68@email.com', '08121000068', 'Jl. Technovo No. 68, Jakarta'),
('Customer 69', 'customer69@email.com', '08121000069', 'Jl. Technovo No. 69, Jakarta'),
('Customer 70', 'customer70@email.com', '08121000070', 'Jl. Technovo No. 70, Jakarta'),
('Customer 71', 'customer71@email.com', '08121000071', 'Jl. Technovo No. 71, Jakarta'),
('Customer 72', 'customer72@email.com', '08121000072', 'Jl. Technovo No. 72, Jakarta'),
('Customer 73', 'customer73@email.com', '08121000073', 'Jl. Technovo No. 73, Jakarta'),
('Customer 74', 'customer74@email.com', '08121000074', 'Jl. Technovo No. 74, Jakarta'),
('Customer 75', 'customer75@email.com', '08121000075', 'Jl. Technovo No. 75, Jakarta'),
('Customer 76', 'customer76@email.com', '08121000076', 'Jl. Technovo No. 76, Jakarta'),
('Customer 77', 'customer77@email.com', '08121000077', 'Jl. Technovo No. 77, Jakarta'),
('Customer 78', 'customer78@email.com', '08121000078', 'Jl. Technovo No. 78, Jakarta'),
('Customer 79', 'customer79@email.com', '08121000079', 'Jl. Technovo No. 79, Jakarta'),
('Customer 80', 'customer80@email.com', '08121000080', 'Jl. Technovo No. 80, Jakarta'),
('Customer 81', 'customer81@email.com', '08121000081', 'Jl. Technovo No. 81, Jakarta'),
('Customer 82', 'customer82@email.com', '08121000082', 'Jl. Technovo No. 82, Jakarta'),
('Customer 83', 'customer83@email.com', '08121000083', 'Jl. Technovo No. 83, Jakarta'),
('Customer 84', 'customer84@email.com', '08121000084', 'Jl. Technovo No. 84, Jakarta'),
('Customer 85', 'customer85@email.com', '08121000085', 'Jl. Technovo No. 85, Jakarta'),
('Customer 86', 'customer86@email.com', '08121000086', 'Jl. Technovo No. 86, Jakarta'),
('Customer 87', 'customer87@email.com', '08121000087', 'Jl. Technovo No. 87, Jakarta'),
('Customer 88', 'customer88@email.com', '08121000088', 'Jl. Technovo No. 88, Jakarta'),
('Customer 89', 'customer89@email.com', '08121000089', 'Jl. Technovo No. 89, Jakarta'),
('Customer 90', 'customer90@email.com', '08121000090', 'Jl. Technovo No. 90, Jakarta'),
('Customer 91', 'customer91@email.com', '08121000091', 'Jl. Technovo No. 91, Jakarta'),
('Customer 92', 'customer92@email.com', '08121000092', 'Jl. Technovo No. 92, Jakarta'),
('Customer 93', 'customer93@email.com', '08121000093', 'Jl. Technovo No. 93, Jakarta'),
('Customer 94', 'customer94@email.com', '08121000094', 'Jl. Technovo No. 94, Jakarta'),
('Customer 95', 'customer95@email.com', '08121000095', 'Jl. Technovo No. 95, Jakarta'),
('Customer 96', 'customer96@email.com', '08121000096', 'Jl. Technovo No. 96, Jakarta'),
('Customer 97', 'customer97@email.com', '08121000097', 'Jl. Technovo No. 97, Jakarta'),
('Customer 98', 'customer98@email.com', '08121000098', 'Jl. Technovo No. 98, Jakarta'),
('Customer 99', 'customer99@email.com', '08121000099', 'Jl. Technovo No. 99, Jakarta'),
('Customer 100', 'customer100@email.com', '08121000100', 'Jl. Technovo No. 100, Jakarta');

-- SEED: Live Schedules (360)
INSERT INTO live_schedules (host_id, platform_id, title, schedule_date, start_time, end_time, status) VALUES
(3, 1, 'Live Session #1', '2026-03-17', '10:00:00', '12:00:00', 'completed'),
(4, 2, 'Live Session #2', '2026-04-27', '10:00:00', '12:00:00', 'completed'),
(5, 3, 'Live Session #3', '2026-04-01', '10:00:00', '12:00:00', 'completed'),
(3, 4, 'Live Session #4', '2026-02-21', '10:00:00', '12:00:00', 'completed'),
(4, 1, 'Live Session #5', '2026-04-04', '10:00:00', '12:00:00', 'completed'),
(5, 2, 'Live Session #6', '2026-02-24', '10:00:00', '12:00:00', 'completed'),
(3, 3, 'Live Session #7', '2026-02-22', '10:00:00', '12:00:00', 'completed'),
(4, 4, 'Live Session #8', '2026-04-27', '10:00:00', '12:00:00', 'completed'),
(5, 1, 'Live Session #9', '2026-02-10', '10:00:00', '12:00:00', 'completed'),
(3, 2, 'Live Session #10', '2026-05-15', '10:00:00', '12:00:00', 'completed'),
(4, 3, 'Live Session #11', '2026-02-16', '10:00:00', '12:00:00', 'completed'),
(5, 4, 'Live Session #12', '2026-05-30', '10:00:00', '12:00:00', 'completed'),
(3, 1, 'Live Session #13', '2026-02-10', '10:00:00', '12:00:00', 'completed'),
(4, 2, 'Live Session #14', '2026-04-07', '10:00:00', '12:00:00', 'completed'),
(5, 3, 'Live Session #15', '2026-03-09', '10:00:00', '12:00:00', 'completed'),
(3, 4, 'Live Session #16', '2026-04-26', '10:00:00', '12:00:00', 'completed'),
(4, 1, 'Live Session #17', '2026-02-02', '10:00:00', '12:00:00', 'completed'),
(5, 2, 'Live Session #18', '2026-05-05', '10:00:00', '12:00:00', 'completed'),
(3, 3, 'Live Session #19', '2026-02-15', '10:00:00', '12:00:00', 'completed'),
(4, 4, 'Live Session #20', '2026-04-04', '10:00:00', '12:00:00', 'completed'),
(5, 1, 'Live Session #21', '2026-02-13', '10:00:00', '12:00:00', 'completed'),
(3, 2, 'Live Session #22', '2026-05-19', '10:00:00', '12:00:00', 'completed'),
(4, 3, 'Live Session #23', '2026-05-20', '10:00:00', '12:00:00', 'completed'),
(5, 4, 'Live Session #24', '2026-02-06', '10:00:00', '12:00:00', 'completed'),
(3, 1, 'Live Session #25', '2026-04-16', '10:00:00', '12:00:00', 'completed'),
(4, 2, 'Live Session #26', '2026-05-24', '10:00:00', '12:00:00', 'completed'),
(5, 3, 'Live Session #27', '2026-02-27', '10:00:00', '12:00:00', 'completed'),
(3, 4, 'Live Session #28', '2026-02-14', '10:00:00', '12:00:00', 'completed'),
(4, 1, 'Live Session #29', '2026-03-08', '10:00:00', '12:00:00', 'completed'),
(5, 2, 'Live Session #30', '2026-03-31', '10:00:00', '12:00:00', 'completed'),
(3, 3, 'Live Session #31', '2026-05-30', '10:00:00', '12:00:00', 'completed'),
(4, 4, 'Live Session #32', '2026-03-07', '10:00:00', '12:00:00', 'completed'),
(5, 1, 'Live Session #33', '2026-04-20', '10:00:00', '12:00:00', 'completed'),
(3, 2, 'Live Session #34', '2026-04-29', '10:00:00', '12:00:00', 'completed'),
(4, 3, 'Live Session #35', '2026-04-05', '10:00:00', '12:00:00', 'completed'),
(5, 4, 'Live Session #36', '2026-05-12', '10:00:00', '12:00:00', 'completed'),
(3, 1, 'Live Session #37', '2026-04-27', '10:00:00', '12:00:00', 'completed'),
(4, 2, 'Live Session #38', '2026-03-07', '10:00:00', '12:00:00', 'completed'),
(5, 3, 'Live Session #39', '2026-04-14', '10:00:00', '12:00:00', 'completed'),
(3, 4, 'Live Session #40', '2026-04-01', '10:00:00', '12:00:00', 'completed'),
(4, 1, 'Live Session #41', '2026-05-18', '10:00:00', '12:00:00', 'completed'),
(5, 2, 'Live Session #42', '2026-02-02', '10:00:00', '12:00:00', 'completed'),
(3, 3, 'Live Session #43', '2026-02-09', '10:00:00', '12:00:00', 'completed'),
(4, 4, 'Live Session #44', '2026-02-21', '10:00:00', '12:00:00', 'completed'),
(5, 1, 'Live Session #45', '2026-03-19', '10:00:00', '12:00:00', 'completed'),
(3, 2, 'Live Session #46', '2026-05-11', '10:00:00', '12:00:00', 'completed'),
(4, 3, 'Live Session #47', '2026-02-05', '10:00:00', '12:00:00', 'completed'),
(5, 4, 'Live Session #48', '2026-02-02', '10:00:00', '12:00:00', 'completed'),
(3, 1, 'Live Session #49', '2026-05-12', '10:00:00', '12:00:00', 'completed'),
(4, 2, 'Live Session #50', '2026-05-18', '10:00:00', '12:00:00', 'completed'),
(5, 3, 'Live Session #51', '2026-02-11', '10:00:00', '12:00:00', 'completed'),
(3, 4, 'Live Session #52', '2026-03-10', '10:00:00', '12:00:00', 'completed'),
(4, 1, 'Live Session #53', '2026-05-13', '10:00:00', '12:00:00', 'completed'),
(5, 2, 'Live Session #54', '2026-04-12', '10:00:00', '12:00:00', 'completed'),
(3, 3, 'Live Session #55', '2026-05-26', '10:00:00', '12:00:00', 'completed'),
(4, 4, 'Live Session #56', '2026-05-07', '10:00:00', '12:00:00', 'completed'),
(5, 1, 'Live Session #57', '2026-05-03', '10:00:00', '12:00:00', 'completed'),
(3, 2, 'Live Session #58', '2026-03-05', '10:00:00', '12:00:00', 'completed'),
(4, 3, 'Live Session #59', '2026-03-11', '10:00:00', '12:00:00', 'completed'),
(5, 4, 'Live Session #60', '2026-04-15', '10:00:00', '12:00:00', 'completed'),
(3, 1, 'Live Session #61', '2026-03-05', '10:00:00', '12:00:00', 'completed'),
(4, 2, 'Live Session #62', '2026-04-29', '10:00:00', '12:00:00', 'completed'),
(5, 3, 'Live Session #63', '2026-02-15', '10:00:00', '12:00:00', 'completed'),
(3, 4, 'Live Session #64', '2026-04-12', '10:00:00', '12:00:00', 'completed'),
(4, 1, 'Live Session #65', '2026-05-15', '10:00:00', '12:00:00', 'completed'),
(5, 2, 'Live Session #66', '2026-04-11', '10:00:00', '12:00:00', 'completed'),
(3, 3, 'Live Session #67', '2026-02-27', '10:00:00', '12:00:00', 'completed'),
(4, 4, 'Live Session #68', '2026-04-15', '10:00:00', '12:00:00', 'completed'),
(5, 1, 'Live Session #69', '2026-04-08', '10:00:00', '12:00:00', 'completed'),
(3, 2, 'Live Session #70', '2026-05-30', '10:00:00', '12:00:00', 'completed'),
(4, 3, 'Live Session #71', '2026-03-02', '10:00:00', '12:00:00', 'completed'),
(5, 4, 'Live Session #72', '2026-05-09', '10:00:00', '12:00:00', 'completed'),
(3, 1, 'Live Session #73', '2026-03-10', '10:00:00', '12:00:00', 'completed'),
(4, 2, 'Live Session #74', '2026-04-01', '10:00:00', '12:00:00', 'completed'),
(5, 3, 'Live Session #75', '2026-03-17', '10:00:00', '12:00:00', 'completed'),
(3, 4, 'Live Session #76', '2026-03-09', '10:00:00', '12:00:00', 'completed'),
(4, 1, 'Live Session #77', '2026-02-27', '10:00:00', '12:00:00', 'completed'),
(5, 2, 'Live Session #78', '2026-03-19', '10:00:00', '12:00:00', 'completed'),
(3, 3, 'Live Session #79', '2026-05-15', '10:00:00', '12:00:00', 'completed'),
(4, 4, 'Live Session #80', '2026-04-14', '10:00:00', '12:00:00', 'completed'),
(5, 1, 'Live Session #81', '2026-03-05', '10:00:00', '12:00:00', 'completed'),
(3, 2, 'Live Session #82', '2026-04-24', '10:00:00', '12:00:00', 'completed'),
(4, 3, 'Live Session #83', '2026-05-09', '10:00:00', '12:00:00', 'completed'),
(5, 4, 'Live Session #84', '2026-02-16', '10:00:00', '12:00:00', 'completed'),
(3, 1, 'Live Session #85', '2026-04-13', '10:00:00', '12:00:00', 'completed'),
(4, 2, 'Live Session #86', '2026-05-10', '10:00:00', '12:00:00', 'completed'),
(5, 3, 'Live Session #87', '2026-02-01', '10:00:00', '12:00:00', 'completed'),
(3, 4, 'Live Session #88', '2026-03-12', '10:00:00', '12:00:00', 'completed'),
(4, 1, 'Live Session #89', '2026-02-27', '10:00:00', '12:00:00', 'completed'),
(5, 2, 'Live Session #90', '2026-05-13', '10:00:00', '12:00:00', 'completed'),
(3, 3, 'Live Session #91', '2026-04-07', '10:00:00', '12:00:00', 'completed'),
(4, 4, 'Live Session #92', '2026-04-06', '10:00:00', '12:00:00', 'completed'),
(5, 1, 'Live Session #93', '2026-05-12', '10:00:00', '12:00:00', 'completed'),
(3, 2, 'Live Session #94', '2026-04-23', '10:00:00', '12:00:00', 'completed'),
(4, 3, 'Live Session #95', '2026-03-24', '10:00:00', '12:00:00', 'completed'),
(5, 4, 'Live Session #96', '2026-04-26', '10:00:00', '12:00:00', 'completed'),
(3, 1, 'Live Session #97', '2026-04-28', '10:00:00', '12:00:00', 'completed'),
(4, 2, 'Live Session #98', '2026-04-16', '10:00:00', '12:00:00', 'completed'),
(5, 3, 'Live Session #99', '2026-02-06', '10:00:00', '12:00:00', 'completed'),
(3, 4, 'Live Session #100', '2026-03-22', '10:00:00', '12:00:00', 'completed'),
(4, 1, 'Live Session #101', '2026-05-06', '10:00:00', '12:00:00', 'completed'),
(5, 2, 'Live Session #102', '2026-03-22', '10:00:00', '12:00:00', 'completed'),
(3, 3, 'Live Session #103', '2026-03-05', '10:00:00', '12:00:00', 'completed'),
(4, 4, 'Live Session #104', '2026-05-30', '10:00:00', '12:00:00', 'completed'),
(5, 1, 'Live Session #105', '2026-05-20', '10:00:00', '12:00:00', 'completed'),
(3, 2, 'Live Session #106', '2026-03-09', '10:00:00', '12:00:00', 'completed'),
(4, 3, 'Live Session #107', '2026-02-21', '10:00:00', '12:00:00', 'completed'),
(5, 4, 'Live Session #108', '2026-03-23', '10:00:00', '12:00:00', 'completed'),
(3, 1, 'Live Session #109', '2026-04-23', '10:00:00', '12:00:00', 'completed'),
(4, 2, 'Live Session #110', '2026-04-28', '10:00:00', '12:00:00', 'completed'),
(5, 3, 'Live Session #111', '2026-04-05', '10:00:00', '12:00:00', 'completed'),
(3, 4, 'Live Session #112', '2026-05-20', '10:00:00', '12:00:00', 'completed'),
(4, 1, 'Live Session #113', '2026-05-19', '10:00:00', '12:00:00', 'completed'),
(5, 2, 'Live Session #114', '2026-02-09', '10:00:00', '12:00:00', 'completed'),
(3, 3, 'Live Session #115', '2026-02-11', '10:00:00', '12:00:00', 'completed'),
(4, 4, 'Live Session #116', '2026-04-30', '10:00:00', '12:00:00', 'completed'),
(5, 1, 'Live Session #117', '2026-05-24', '10:00:00', '12:00:00', 'completed'),
(3, 2, 'Live Session #118', '2026-03-30', '10:00:00', '12:00:00', 'completed'),
(4, 3, 'Live Session #119', '2026-03-31', '10:00:00', '12:00:00', 'completed'),
(5, 4, 'Live Session #120', '2026-02-01', '10:00:00', '12:00:00', 'completed'),
(3, 1, 'Live Session #121', '2026-02-18', '10:00:00', '12:00:00', 'completed'),
(4, 2, 'Live Session #122', '2026-04-24', '10:00:00', '12:00:00', 'completed'),
(5, 3, 'Live Session #123', '2026-03-28', '10:00:00', '12:00:00', 'completed'),
(3, 4, 'Live Session #124', '2026-03-22', '10:00:00', '12:00:00', 'completed'),
(4, 1, 'Live Session #125', '2026-04-27', '10:00:00', '12:00:00', 'completed'),
(5, 2, 'Live Session #126', '2026-03-16', '10:00:00', '12:00:00', 'completed'),
(3, 3, 'Live Session #127', '2026-05-09', '10:00:00', '12:00:00', 'completed'),
(4, 4, 'Live Session #128', '2026-04-24', '10:00:00', '12:00:00', 'completed'),
(5, 1, 'Live Session #129', '2026-03-30', '10:00:00', '12:00:00', 'completed'),
(3, 2, 'Live Session #130', '2026-05-06', '10:00:00', '12:00:00', 'completed'),
(4, 3, 'Live Session #131', '2026-03-09', '10:00:00', '12:00:00', 'completed'),
(5, 4, 'Live Session #132', '2026-03-24', '10:00:00', '12:00:00', 'completed'),
(3, 1, 'Live Session #133', '2026-02-16', '10:00:00', '12:00:00', 'completed'),
(4, 2, 'Live Session #134', '2026-03-19', '10:00:00', '12:00:00', 'completed'),
(5, 3, 'Live Session #135', '2026-03-04', '10:00:00', '12:00:00', 'completed'),
(3, 4, 'Live Session #136', '2026-04-09', '10:00:00', '12:00:00', 'completed'),
(4, 1, 'Live Session #137', '2026-02-25', '10:00:00', '12:00:00', 'completed'),
(5, 2, 'Live Session #138', '2026-02-13', '10:00:00', '12:00:00', 'completed'),
(3, 3, 'Live Session #139', '2026-02-08', '10:00:00', '12:00:00', 'completed'),
(4, 4, 'Live Session #140', '2026-05-18', '10:00:00', '12:00:00', 'completed'),
(5, 1, 'Live Session #141', '2026-05-12', '10:00:00', '12:00:00', 'completed'),
(3, 2, 'Live Session #142', '2026-03-15', '10:00:00', '12:00:00', 'completed'),
(4, 3, 'Live Session #143', '2026-04-05', '10:00:00', '12:00:00', 'completed'),
(5, 4, 'Live Session #144', '2026-05-10', '10:00:00', '12:00:00', 'completed'),
(3, 1, 'Live Session #145', '2026-04-24', '10:00:00', '12:00:00', 'completed'),
(4, 2, 'Live Session #146', '2026-03-03', '10:00:00', '12:00:00', 'completed'),
(5, 3, 'Live Session #147', '2026-02-02', '10:00:00', '12:00:00', 'completed'),
(3, 4, 'Live Session #148', '2026-03-30', '10:00:00', '12:00:00', 'completed'),
(4, 1, 'Live Session #149', '2026-05-05', '10:00:00', '12:00:00', 'completed'),
(5, 2, 'Live Session #150', '2026-03-06', '10:00:00', '12:00:00', 'completed'),
(3, 3, 'Live Session #151', '2026-02-07', '10:00:00', '12:00:00', 'completed'),
(4, 4, 'Live Session #152', '2026-05-16', '10:00:00', '12:00:00', 'completed'),
(5, 1, 'Live Session #153', '2026-03-11', '10:00:00', '12:00:00', 'completed'),
(3, 2, 'Live Session #154', '2026-05-30', '10:00:00', '12:00:00', 'completed'),
(4, 3, 'Live Session #155', '2026-02-25', '10:00:00', '12:00:00', 'completed'),
(5, 4, 'Live Session #156', '2026-05-28', '10:00:00', '12:00:00', 'completed'),
(3, 1, 'Live Session #157', '2026-05-04', '10:00:00', '12:00:00', 'completed'),
(4, 2, 'Live Session #158', '2026-02-14', '10:00:00', '12:00:00', 'completed'),
(5, 3, 'Live Session #159', '2026-05-20', '10:00:00', '12:00:00', 'completed'),
(3, 4, 'Live Session #160', '2026-05-05', '10:00:00', '12:00:00', 'completed'),
(4, 1, 'Live Session #161', '2026-05-08', '10:00:00', '12:00:00', 'completed'),
(5, 2, 'Live Session #162', '2026-05-30', '10:00:00', '12:00:00', 'completed'),
(3, 3, 'Live Session #163', '2026-03-30', '10:00:00', '12:00:00', 'completed'),
(4, 4, 'Live Session #164', '2026-02-11', '10:00:00', '12:00:00', 'completed'),
(5, 1, 'Live Session #165', '2026-02-23', '10:00:00', '12:00:00', 'completed'),
(3, 2, 'Live Session #166', '2026-03-05', '10:00:00', '12:00:00', 'completed'),
(4, 3, 'Live Session #167', '2026-04-24', '10:00:00', '12:00:00', 'completed'),
(5, 4, 'Live Session #168', '2026-02-16', '10:00:00', '12:00:00', 'completed'),
(3, 1, 'Live Session #169', '2026-05-21', '10:00:00', '12:00:00', 'completed'),
(4, 2, 'Live Session #170', '2026-05-29', '10:00:00', '12:00:00', 'completed'),
(5, 3, 'Live Session #171', '2026-04-12', '10:00:00', '12:00:00', 'completed'),
(3, 4, 'Live Session #172', '2026-02-05', '10:00:00', '12:00:00', 'completed'),
(4, 1, 'Live Session #173', '2026-02-20', '10:00:00', '12:00:00', 'completed'),
(5, 2, 'Live Session #174', '2026-04-24', '10:00:00', '12:00:00', 'completed'),
(3, 3, 'Live Session #175', '2026-02-01', '10:00:00', '12:00:00', 'completed'),
(4, 4, 'Live Session #176', '2026-02-19', '10:00:00', '12:00:00', 'completed'),
(5, 1, 'Live Session #177', '2026-05-25', '10:00:00', '12:00:00', 'completed'),
(3, 2, 'Live Session #178', '2026-03-03', '10:00:00', '12:00:00', 'completed'),
(4, 3, 'Live Session #179', '2026-02-03', '10:00:00', '12:00:00', 'completed'),
(5, 4, 'Live Session #180', '2026-05-21', '10:00:00', '12:00:00', 'completed'),
(3, 1, 'Live Session #181', '2026-04-16', '10:00:00', '12:00:00', 'completed'),
(4, 2, 'Live Session #182', '2026-02-07', '10:00:00', '12:00:00', 'completed'),
(5, 3, 'Live Session #183', '2026-03-10', '10:00:00', '12:00:00', 'completed'),
(3, 4, 'Live Session #184', '2026-03-24', '10:00:00', '12:00:00', 'completed'),
(4, 1, 'Live Session #185', '2026-05-18', '10:00:00', '12:00:00', 'completed'),
(5, 2, 'Live Session #186', '2026-03-20', '10:00:00', '12:00:00', 'completed'),
(3, 3, 'Live Session #187', '2026-03-24', '10:00:00', '12:00:00', 'completed'),
(4, 4, 'Live Session #188', '2026-02-07', '10:00:00', '12:00:00', 'completed'),
(5, 1, 'Live Session #189', '2026-04-29', '10:00:00', '12:00:00', 'completed'),
(3, 2, 'Live Session #190', '2026-02-06', '10:00:00', '12:00:00', 'completed'),
(4, 3, 'Live Session #191', '2026-02-25', '10:00:00', '12:00:00', 'completed'),
(5, 4, 'Live Session #192', '2026-03-13', '10:00:00', '12:00:00', 'completed'),
(3, 1, 'Live Session #193', '2026-05-07', '10:00:00', '12:00:00', 'completed'),
(4, 2, 'Live Session #194', '2026-05-11', '10:00:00', '12:00:00', 'completed'),
(5, 3, 'Live Session #195', '2026-04-11', '10:00:00', '12:00:00', 'completed'),
(3, 4, 'Live Session #196', '2026-05-15', '10:00:00', '12:00:00', 'completed'),
(4, 1, 'Live Session #197', '2026-03-21', '10:00:00', '12:00:00', 'completed'),
(5, 2, 'Live Session #198', '2026-02-05', '10:00:00', '12:00:00', 'completed'),
(3, 3, 'Live Session #199', '2026-03-09', '10:00:00', '12:00:00', 'completed'),
(4, 4, 'Live Session #200', '2026-03-22', '10:00:00', '12:00:00', 'completed'),
(5, 1, 'Live Session #201', '2026-03-17', '10:00:00', '12:00:00', 'completed'),
(3, 2, 'Live Session #202', '2026-02-15', '10:00:00', '12:00:00', 'completed'),
(4, 3, 'Live Session #203', '2026-03-18', '10:00:00', '12:00:00', 'completed'),
(5, 4, 'Live Session #204', '2026-02-11', '10:00:00', '12:00:00', 'completed'),
(3, 1, 'Live Session #205', '2026-04-29', '10:00:00', '12:00:00', 'completed'),
(4, 2, 'Live Session #206', '2026-05-17', '10:00:00', '12:00:00', 'completed'),
(5, 3, 'Live Session #207', '2026-03-27', '10:00:00', '12:00:00', 'completed'),
(3, 4, 'Live Session #208', '2026-03-11', '10:00:00', '12:00:00', 'completed'),
(4, 1, 'Live Session #209', '2026-03-15', '10:00:00', '12:00:00', 'completed'),
(5, 2, 'Live Session #210', '2026-03-22', '10:00:00', '12:00:00', 'completed'),
(3, 3, 'Live Session #211', '2026-04-04', '10:00:00', '12:00:00', 'completed'),
(4, 4, 'Live Session #212', '2026-04-20', '10:00:00', '12:00:00', 'completed'),
(5, 1, 'Live Session #213', '2026-04-25', '10:00:00', '12:00:00', 'completed'),
(3, 2, 'Live Session #214', '2026-04-17', '10:00:00', '12:00:00', 'completed'),
(4, 3, 'Live Session #215', '2026-03-20', '10:00:00', '12:00:00', 'completed'),
(5, 4, 'Live Session #216', '2026-05-03', '10:00:00', '12:00:00', 'completed'),
(3, 1, 'Live Session #217', '2026-05-30', '10:00:00', '12:00:00', 'completed'),
(4, 2, 'Live Session #218', '2026-03-10', '10:00:00', '12:00:00', 'completed'),
(5, 3, 'Live Session #219', '2026-05-18', '10:00:00', '12:00:00', 'completed'),
(3, 4, 'Live Session #220', '2026-04-10', '10:00:00', '12:00:00', 'completed'),
(4, 1, 'Live Session #221', '2026-02-15', '10:00:00', '12:00:00', 'completed'),
(5, 2, 'Live Session #222', '2026-03-01', '10:00:00', '12:00:00', 'completed'),
(3, 3, 'Live Session #223', '2026-02-06', '10:00:00', '12:00:00', 'completed'),
(4, 4, 'Live Session #224', '2026-03-13', '10:00:00', '12:00:00', 'completed'),
(5, 1, 'Live Session #225', '2026-05-10', '10:00:00', '12:00:00', 'completed'),
(3, 2, 'Live Session #226', '2026-05-11', '10:00:00', '12:00:00', 'completed'),
(4, 3, 'Live Session #227', '2026-02-10', '10:00:00', '12:00:00', 'completed'),
(5, 4, 'Live Session #228', '2026-04-14', '10:00:00', '12:00:00', 'completed'),
(3, 1, 'Live Session #229', '2026-02-14', '10:00:00', '12:00:00', 'completed'),
(4, 2, 'Live Session #230', '2026-03-25', '10:00:00', '12:00:00', 'completed'),
(5, 3, 'Live Session #231', '2026-02-01', '10:00:00', '12:00:00', 'completed'),
(3, 4, 'Live Session #232', '2026-03-29', '10:00:00', '12:00:00', 'completed'),
(4, 1, 'Live Session #233', '2026-05-10', '10:00:00', '12:00:00', 'completed'),
(5, 2, 'Live Session #234', '2026-04-13', '10:00:00', '12:00:00', 'completed'),
(3, 3, 'Live Session #235', '2026-04-25', '10:00:00', '12:00:00', 'completed'),
(4, 4, 'Live Session #236', '2026-05-21', '10:00:00', '12:00:00', 'completed'),
(5, 1, 'Live Session #237', '2026-04-18', '10:00:00', '12:00:00', 'completed'),
(3, 2, 'Live Session #238', '2026-03-28', '10:00:00', '12:00:00', 'completed'),
(4, 3, 'Live Session #239', '2026-02-02', '10:00:00', '12:00:00', 'completed'),
(5, 4, 'Live Session #240', '2026-05-26', '10:00:00', '12:00:00', 'completed'),
(3, 1, 'Live Session #241', '2026-03-23', '10:00:00', '12:00:00', 'completed'),
(4, 2, 'Live Session #242', '2026-02-22', '10:00:00', '12:00:00', 'completed'),
(5, 3, 'Live Session #243', '2026-02-17', '10:00:00', '12:00:00', 'completed'),
(3, 4, 'Live Session #244', '2026-03-29', '10:00:00', '12:00:00', 'completed'),
(4, 1, 'Live Session #245', '2026-04-23', '10:00:00', '12:00:00', 'completed'),
(5, 2, 'Live Session #246', '2026-05-04', '10:00:00', '12:00:00', 'completed'),
(3, 3, 'Live Session #247', '2026-04-24', '10:00:00', '12:00:00', 'completed'),
(4, 4, 'Live Session #248', '2026-05-20', '10:00:00', '12:00:00', 'completed'),
(5, 1, 'Live Session #249', '2026-02-25', '10:00:00', '12:00:00', 'completed'),
(3, 2, 'Live Session #250', '2026-02-06', '10:00:00', '12:00:00', 'completed'),
(4, 3, 'Live Session #251', '2026-05-26', '10:00:00', '12:00:00', 'completed'),
(5, 4, 'Live Session #252', '2026-05-28', '10:00:00', '12:00:00', 'completed'),
(3, 1, 'Live Session #253', '2026-05-19', '10:00:00', '12:00:00', 'completed'),
(4, 2, 'Live Session #254', '2026-02-18', '10:00:00', '12:00:00', 'completed'),
(5, 3, 'Live Session #255', '2026-03-13', '10:00:00', '12:00:00', 'completed'),
(3, 4, 'Live Session #256', '2026-02-11', '10:00:00', '12:00:00', 'completed'),
(4, 1, 'Live Session #257', '2026-03-02', '10:00:00', '12:00:00', 'completed'),
(5, 2, 'Live Session #258', '2026-04-26', '10:00:00', '12:00:00', 'completed'),
(3, 3, 'Live Session #259', '2026-03-01', '10:00:00', '12:00:00', 'completed'),
(4, 4, 'Live Session #260', '2026-04-30', '10:00:00', '12:00:00', 'completed'),
(5, 1, 'Live Session #261', '2026-02-10', '10:00:00', '12:00:00', 'completed'),
(3, 2, 'Live Session #262', '2026-02-25', '10:00:00', '12:00:00', 'completed'),
(4, 3, 'Live Session #263', '2026-02-22', '10:00:00', '12:00:00', 'completed'),
(5, 4, 'Live Session #264', '2026-05-17', '10:00:00', '12:00:00', 'completed'),
(3, 1, 'Live Session #265', '2026-04-03', '10:00:00', '12:00:00', 'completed'),
(4, 2, 'Live Session #266', '2026-05-01', '10:00:00', '12:00:00', 'completed'),
(5, 3, 'Live Session #267', '2026-02-12', '10:00:00', '12:00:00', 'completed'),
(3, 4, 'Live Session #268', '2026-04-09', '10:00:00', '12:00:00', 'completed'),
(4, 1, 'Live Session #269', '2026-03-20', '10:00:00', '12:00:00', 'completed'),
(5, 2, 'Live Session #270', '2026-05-22', '10:00:00', '12:00:00', 'completed'),
(3, 3, 'Live Session #271', '2026-04-01', '10:00:00', '12:00:00', 'completed'),
(4, 4, 'Live Session #272', '2026-02-26', '10:00:00', '12:00:00', 'completed'),
(5, 1, 'Live Session #273', '2026-04-04', '10:00:00', '12:00:00', 'completed'),
(3, 2, 'Live Session #274', '2026-03-28', '10:00:00', '12:00:00', 'completed'),
(4, 3, 'Live Session #275', '2026-05-22', '10:00:00', '12:00:00', 'completed'),
(5, 4, 'Live Session #276', '2026-04-01', '10:00:00', '12:00:00', 'completed'),
(3, 1, 'Live Session #277', '2026-02-26', '10:00:00', '12:00:00', 'completed'),
(4, 2, 'Live Session #278', '2026-04-11', '10:00:00', '12:00:00', 'completed'),
(5, 3, 'Live Session #279', '2026-02-13', '10:00:00', '12:00:00', 'completed'),
(3, 4, 'Live Session #280', '2026-04-05', '10:00:00', '12:00:00', 'completed'),
(4, 1, 'Live Session #281', '2026-03-30', '10:00:00', '12:00:00', 'completed'),
(5, 2, 'Live Session #282', '2026-02-06', '10:00:00', '12:00:00', 'completed'),
(3, 3, 'Live Session #283', '2026-04-11', '10:00:00', '12:00:00', 'completed'),
(4, 4, 'Live Session #284', '2026-05-28', '10:00:00', '12:00:00', 'completed'),
(5, 1, 'Live Session #285', '2026-02-28', '10:00:00', '12:00:00', 'completed'),
(3, 2, 'Live Session #286', '2026-05-28', '10:00:00', '12:00:00', 'completed'),
(4, 3, 'Live Session #287', '2026-05-04', '10:00:00', '12:00:00', 'completed'),
(5, 4, 'Live Session #288', '2026-04-15', '10:00:00', '12:00:00', 'completed'),
(3, 1, 'Live Session #289', '2026-03-29', '10:00:00', '12:00:00', 'completed'),
(4, 2, 'Live Session #290', '2026-02-08', '10:00:00', '12:00:00', 'completed'),
(5, 3, 'Live Session #291', '2026-02-02', '10:00:00', '12:00:00', 'completed'),
(3, 4, 'Live Session #292', '2026-04-28', '10:00:00', '12:00:00', 'completed'),
(4, 1, 'Live Session #293', '2026-02-19', '10:00:00', '12:00:00', 'completed'),
(5, 2, 'Live Session #294', '2026-05-05', '10:00:00', '12:00:00', 'completed'),
(3, 3, 'Live Session #295', '2026-02-19', '10:00:00', '12:00:00', 'completed'),
(4, 4, 'Live Session #296', '2026-03-29', '10:00:00', '12:00:00', 'completed'),
(5, 1, 'Live Session #297', '2026-03-01', '10:00:00', '12:00:00', 'completed'),
(3, 2, 'Live Session #298', '2026-02-09', '10:00:00', '12:00:00', 'completed'),
(4, 3, 'Live Session #299', '2026-04-14', '10:00:00', '12:00:00', 'completed'),
(5, 4, 'Live Session #300', '2026-05-04', '10:00:00', '12:00:00', 'completed'),
(3, 1, 'Live Session #301', '2026-02-01', '10:00:00', '12:00:00', 'completed'),
(4, 2, 'Live Session #302', '2026-02-03', '10:00:00', '12:00:00', 'completed'),
(5, 3, 'Live Session #303', '2026-05-11', '10:00:00', '12:00:00', 'completed'),
(3, 4, 'Live Session #304', '2026-02-10', '10:00:00', '12:00:00', 'completed'),
(4, 1, 'Live Session #305', '2026-05-15', '10:00:00', '12:00:00', 'completed'),
(5, 2, 'Live Session #306', '2026-03-01', '10:00:00', '12:00:00', 'completed'),
(3, 3, 'Live Session #307', '2026-03-15', '10:00:00', '12:00:00', 'completed'),
(4, 4, 'Live Session #308', '2026-02-17', '10:00:00', '12:00:00', 'completed'),
(5, 1, 'Live Session #309', '2026-05-20', '10:00:00', '12:00:00', 'completed'),
(3, 2, 'Live Session #310', '2026-04-15', '10:00:00', '12:00:00', 'completed'),
(4, 3, 'Live Session #311', '2026-05-29', '10:00:00', '12:00:00', 'completed'),
(5, 4, 'Live Session #312', '2026-02-24', '10:00:00', '12:00:00', 'completed'),
(3, 1, 'Live Session #313', '2026-05-28', '10:00:00', '12:00:00', 'completed'),
(4, 2, 'Live Session #314', '2026-03-03', '10:00:00', '12:00:00', 'completed'),
(5, 3, 'Live Session #315', '2026-04-22', '10:00:00', '12:00:00', 'completed'),
(3, 4, 'Live Session #316', '2026-04-01', '10:00:00', '12:00:00', 'completed'),
(4, 1, 'Live Session #317', '2026-02-07', '10:00:00', '12:00:00', 'completed'),
(5, 2, 'Live Session #318', '2026-03-11', '10:00:00', '12:00:00', 'completed'),
(3, 3, 'Live Session #319', '2026-04-12', '10:00:00', '12:00:00', 'completed'),
(4, 4, 'Live Session #320', '2026-04-13', '10:00:00', '12:00:00', 'completed'),
(5, 1, 'Live Session #321', '2026-03-27', '10:00:00', '12:00:00', 'completed'),
(3, 2, 'Live Session #322', '2026-02-15', '10:00:00', '12:00:00', 'completed'),
(4, 3, 'Live Session #323', '2026-03-11', '10:00:00', '12:00:00', 'completed'),
(5, 4, 'Live Session #324', '2026-04-14', '10:00:00', '12:00:00', 'completed'),
(3, 1, 'Live Session #325', '2026-03-20', '10:00:00', '12:00:00', 'completed'),
(4, 2, 'Live Session #326', '2026-02-12', '10:00:00', '12:00:00', 'completed'),
(5, 3, 'Live Session #327', '2026-03-04', '10:00:00', '12:00:00', 'completed'),
(3, 4, 'Live Session #328', '2026-04-08', '10:00:00', '12:00:00', 'completed'),
(4, 1, 'Live Session #329', '2026-02-07', '10:00:00', '12:00:00', 'completed'),
(5, 2, 'Live Session #330', '2026-03-25', '10:00:00', '12:00:00', 'completed'),
(3, 3, 'Live Session #331', '2026-02-20', '10:00:00', '12:00:00', 'completed'),
(4, 4, 'Live Session #332', '2026-04-20', '10:00:00', '12:00:00', 'completed'),
(5, 1, 'Live Session #333', '2026-05-14', '10:00:00', '12:00:00', 'completed'),
(3, 2, 'Live Session #334', '2026-04-18', '10:00:00', '12:00:00', 'completed'),
(4, 3, 'Live Session #335', '2026-02-09', '10:00:00', '12:00:00', 'completed'),
(5, 4, 'Live Session #336', '2026-03-20', '10:00:00', '12:00:00', 'completed'),
(3, 1, 'Live Session #337', '2026-05-16', '10:00:00', '12:00:00', 'completed'),
(4, 2, 'Live Session #338', '2026-05-08', '10:00:00', '12:00:00', 'completed'),
(5, 3, 'Live Session #339', '2026-04-07', '10:00:00', '12:00:00', 'completed'),
(3, 4, 'Live Session #340', '2026-03-01', '10:00:00', '12:00:00', 'completed'),
(4, 1, 'Live Session #341', '2026-02-06', '10:00:00', '12:00:00', 'completed'),
(5, 2, 'Live Session #342', '2026-03-13', '10:00:00', '12:00:00', 'completed'),
(3, 3, 'Live Session #343', '2026-02-11', '10:00:00', '12:00:00', 'completed'),
(4, 4, 'Live Session #344', '2026-04-17', '10:00:00', '12:00:00', 'completed'),
(5, 1, 'Live Session #345', '2026-05-12', '10:00:00', '12:00:00', 'completed'),
(3, 2, 'Live Session #346', '2026-04-20', '10:00:00', '12:00:00', 'completed'),
(4, 3, 'Live Session #347', '2026-05-12', '10:00:00', '12:00:00', 'completed'),
(5, 4, 'Live Session #348', '2026-03-28', '10:00:00', '12:00:00', 'completed'),
(3, 1, 'Live Session #349', '2026-02-25', '10:00:00', '12:00:00', 'completed'),
(4, 2, 'Live Session #350', '2026-05-27', '10:00:00', '12:00:00', 'completed'),
(5, 3, 'Live Session #351', '2026-04-18', '10:00:00', '12:00:00', 'completed'),
(3, 4, 'Live Session #352', '2026-05-11', '10:00:00', '12:00:00', 'completed'),
(4, 1, 'Live Session #353', '2026-03-04', '10:00:00', '12:00:00', 'completed'),
(5, 2, 'Live Session #354', '2026-02-06', '10:00:00', '12:00:00', 'completed'),
(3, 3, 'Live Session #355', '2026-02-20', '10:00:00', '12:00:00', 'completed'),
(4, 4, 'Live Session #356', '2026-05-19', '10:00:00', '12:00:00', 'completed'),
(5, 1, 'Live Session #357', '2026-04-24', '10:00:00', '12:00:00', 'completed'),
(3, 2, 'Live Session #358', '2026-05-11', '10:00:00', '12:00:00', 'completed'),
(4, 3, 'Live Session #359', '2026-05-20', '10:00:00', '12:00:00', 'completed'),
(5, 4, 'Live Session #360', '2026-03-01', '10:00:00', '12:00:00', 'completed');

-- SEED: Live Sales (360) + Items
INSERT INTO live_sales (schedule_id, host_id, sale_date, total_amount, total_items, status) VALUES (1, 3, '2026-03-17', 16500000, 2, 'completed');
INSERT INTO live_sale_items (live_sale_id, product_id, quantity, unit_price, subtotal) VALUES (1, 1, 2, 8250000, 16500000);
INSERT INTO live_sales (schedule_id, host_id, sale_date, total_amount, total_items, status) VALUES (2, 4, '2026-04-27', 25500000, 3, 'completed');
INSERT INTO live_sale_items (live_sale_id, product_id, quantity, unit_price, subtotal) VALUES (2, 2, 3, 8500000, 25500000);
INSERT INTO live_sales (schedule_id, host_id, sale_date, total_amount, total_items, status) VALUES (3, 5, '2026-04-01', 8750000, 1, 'completed');
INSERT INTO live_sale_items (live_sale_id, product_id, quantity, unit_price, subtotal) VALUES (3, 3, 1, 8750000, 8750000);
INSERT INTO live_sales (schedule_id, host_id, sale_date, total_amount, total_items, status) VALUES (4, 3, '2026-02-21', 18000000, 2, 'completed');
INSERT INTO live_sale_items (live_sale_id, product_id, quantity, unit_price, subtotal) VALUES (4, 4, 2, 9000000, 18000000);
INSERT INTO live_sales (schedule_id, host_id, sale_date, total_amount, total_items, status) VALUES (5, 4, '2026-04-04', 27750000, 3, 'completed');
INSERT INTO live_sale_items (live_sale_id, product_id, quantity, unit_price, subtotal) VALUES (5, 5, 3, 9250000, 27750000);
INSERT INTO live_sales (schedule_id, host_id, sale_date, total_amount, total_items, status) VALUES (6, 5, '2026-02-24', 9500000, 1, 'completed');
INSERT INTO live_sale_items (live_sale_id, product_id, quantity, unit_price, subtotal) VALUES (6, 6, 1, 9500000, 9500000);
INSERT INTO live_sales (schedule_id, host_id, sale_date, total_amount, total_items, status) VALUES (7, 3, '2026-02-22', 19500000, 2, 'completed');
INSERT INTO live_sale_items (live_sale_id, product_id, quantity, unit_price, subtotal) VALUES (7, 7, 2, 9750000, 19500000);
INSERT INTO live_sales (schedule_id, host_id, sale_date, total_amount, total_items, status) VALUES (8, 4, '2026-04-27', 30000000, 3, 'completed');
INSERT INTO live_sale_items (live_sale_id, product_id, quantity, unit_price, subtotal) VALUES (8, 8, 3, 10000000, 30000000);
INSERT INTO live_sales (schedule_id, host_id, sale_date, total_amount, total_items, status) VALUES (9, 5, '2026-02-10', 10250000, 1, 'completed');
INSERT INTO live_sale_items (live_sale_id, product_id, quantity, unit_price, subtotal) VALUES (9, 9, 1, 10250000, 10250000);
INSERT INTO live_sales (schedule_id, host_id, sale_date, total_amount, total_items, status) VALUES (10, 3, '2026-05-15', 21000000, 2, 'completed');
INSERT INTO live_sale_items (live_sale_id, product_id, quantity, unit_price, subtotal) VALUES (10, 10, 2, 10500000, 21000000);
INSERT INTO live_sales (schedule_id, host_id, sale_date, total_amount, total_items, status) VALUES (11, 4, '2026-02-16', 32250000, 3, 'completed');
INSERT INTO live_sale_items (live_sale_id, product_id, quantity, unit_price, subtotal) VALUES (11, 11, 3, 10750000, 32250000);
INSERT INTO live_sales (schedule_id, host_id, sale_date, total_amount, total_items, status) VALUES (12, 5, '2026-05-30', 11000000, 1, 'completed');
INSERT INTO live_sale_items (live_sale_id, product_id, quantity, unit_price, subtotal) VALUES (12, 12, 1, 11000000, 11000000);
INSERT INTO live_sales (schedule_id, host_id, sale_date, total_amount, total_items, status) VALUES (13, 3, '2026-02-10', 12900000, 2, 'completed');
INSERT INTO live_sale_items (live_sale_id, product_id, quantity, unit_price, subtotal) VALUES (13, 13, 2, 6450000, 12900000);
INSERT INTO live_sales (schedule_id, host_id, sale_date, total_amount, total_items, status) VALUES (14, 4, '2026-04-07', 19800000, 3, 'completed');
INSERT INTO live_sale_items (live_sale_id, product_id, quantity, unit_price, subtotal) VALUES (14, 14, 3, 6600000, 19800000);
INSERT INTO live_sales (schedule_id, host_id, sale_date, total_amount, total_items, status) VALUES (15, 5, '2026-03-09', 6750000, 1, 'completed');
INSERT INTO live_sale_items (live_sale_id, product_id, quantity, unit_price, subtotal) VALUES (15, 15, 1, 6750000, 6750000);
INSERT INTO live_sales (schedule_id, host_id, sale_date, total_amount, total_items, status) VALUES (16, 3, '2026-04-26', 13800000, 2, 'completed');
INSERT INTO live_sale_items (live_sale_id, product_id, quantity, unit_price, subtotal) VALUES (16, 16, 2, 6900000, 13800000);
INSERT INTO live_sales (schedule_id, host_id, sale_date, total_amount, total_items, status) VALUES (17, 4, '2026-02-02', 21150000, 3, 'completed');
INSERT INTO live_sale_items (live_sale_id, product_id, quantity, unit_price, subtotal) VALUES (17, 17, 3, 7050000, 21150000);
INSERT INTO live_sales (schedule_id, host_id, sale_date, total_amount, total_items, status) VALUES (18, 5, '2026-05-05', 7200000, 1, 'completed');
INSERT INTO live_sale_items (live_sale_id, product_id, quantity, unit_price, subtotal) VALUES (18, 18, 1, 7200000, 7200000);
INSERT INTO live_sales (schedule_id, host_id, sale_date, total_amount, total_items, status) VALUES (19, 3, '2026-02-15', 14700000, 2, 'completed');
INSERT INTO live_sale_items (live_sale_id, product_id, quantity, unit_price, subtotal) VALUES (19, 19, 2, 7350000, 14700000);
INSERT INTO live_sales (schedule_id, host_id, sale_date, total_amount, total_items, status) VALUES (20, 4, '2026-04-04', 22500000, 3, 'completed');
INSERT INTO live_sale_items (live_sale_id, product_id, quantity, unit_price, subtotal) VALUES (20, 20, 3, 7500000, 22500000);
INSERT INTO live_sales (schedule_id, host_id, sale_date, total_amount, total_items, status) VALUES (21, 5, '2026-02-13', 8250000, 1, 'completed');
INSERT INTO live_sale_items (live_sale_id, product_id, quantity, unit_price, subtotal) VALUES (21, 1, 1, 8250000, 8250000);
INSERT INTO live_sales (schedule_id, host_id, sale_date, total_amount, total_items, status) VALUES (22, 3, '2026-05-19', 17000000, 2, 'completed');
INSERT INTO live_sale_items (live_sale_id, product_id, quantity, unit_price, subtotal) VALUES (22, 2, 2, 8500000, 17000000);
INSERT INTO live_sales (schedule_id, host_id, sale_date, total_amount, total_items, status) VALUES (23, 4, '2026-05-20', 26250000, 3, 'completed');
INSERT INTO live_sale_items (live_sale_id, product_id, quantity, unit_price, subtotal) VALUES (23, 3, 3, 8750000, 26250000);
INSERT INTO live_sales (schedule_id, host_id, sale_date, total_amount, total_items, status) VALUES (24, 5, '2026-02-06', 9000000, 1, 'completed');
INSERT INTO live_sale_items (live_sale_id, product_id, quantity, unit_price, subtotal) VALUES (24, 4, 1, 9000000, 9000000);
INSERT INTO live_sales (schedule_id, host_id, sale_date, total_amount, total_items, status) VALUES (25, 3, '2026-04-16', 18500000, 2, 'completed');
INSERT INTO live_sale_items (live_sale_id, product_id, quantity, unit_price, subtotal) VALUES (25, 5, 2, 9250000, 18500000);
INSERT INTO live_sales (schedule_id, host_id, sale_date, total_amount, total_items, status) VALUES (26, 4, '2026-05-24', 28500000, 3, 'completed');
INSERT INTO live_sale_items (live_sale_id, product_id, quantity, unit_price, subtotal) VALUES (26, 6, 3, 9500000, 28500000);
INSERT INTO live_sales (schedule_id, host_id, sale_date, total_amount, total_items, status) VALUES (27, 5, '2026-02-27', 9750000, 1, 'completed');
INSERT INTO live_sale_items (live_sale_id, product_id, quantity, unit_price, subtotal) VALUES (27, 7, 1, 9750000, 9750000);
INSERT INTO live_sales (schedule_id, host_id, sale_date, total_amount, total_items, status) VALUES (28, 3, '2026-02-14', 20000000, 2, 'completed');
INSERT INTO live_sale_items (live_sale_id, product_id, quantity, unit_price, subtotal) VALUES (28, 8, 2, 10000000, 20000000);
INSERT INTO live_sales (schedule_id, host_id, sale_date, total_amount, total_items, status) VALUES (29, 4, '2026-03-08', 30750000, 3, 'completed');
INSERT INTO live_sale_items (live_sale_id, product_id, quantity, unit_price, subtotal) VALUES (29, 9, 3, 10250000, 30750000);
INSERT INTO live_sales (schedule_id, host_id, sale_date, total_amount, total_items, status) VALUES (30, 5, '2026-03-31', 10500000, 1, 'completed');
INSERT INTO live_sale_items (live_sale_id, product_id, quantity, unit_price, subtotal) VALUES (30, 10, 1, 10500000, 10500000);
INSERT INTO live_sales (schedule_id, host_id, sale_date, total_amount, total_items, status) VALUES (31, 3, '2026-05-30', 21500000, 2, 'completed');
INSERT INTO live_sale_items (live_sale_id, product_id, quantity, unit_price, subtotal) VALUES (31, 11, 2, 10750000, 21500000);
INSERT INTO live_sales (schedule_id, host_id, sale_date, total_amount, total_items, status) VALUES (32, 4, '2026-03-07', 33000000, 3, 'completed');
INSERT INTO live_sale_items (live_sale_id, product_id, quantity, unit_price, subtotal) VALUES (32, 12, 3, 11000000, 33000000);
INSERT INTO live_sales (schedule_id, host_id, sale_date, total_amount, total_items, status) VALUES (33, 5, '2026-04-20', 6450000, 1, 'completed');
INSERT INTO live_sale_items (live_sale_id, product_id, quantity, unit_price, subtotal) VALUES (33, 13, 1, 6450000, 6450000);
INSERT INTO live_sales (schedule_id, host_id, sale_date, total_amount, total_items, status) VALUES (34, 3, '2026-04-29', 13200000, 2, 'completed');
INSERT INTO live_sale_items (live_sale_id, product_id, quantity, unit_price, subtotal) VALUES (34, 14, 2, 6600000, 13200000);
INSERT INTO live_sales (schedule_id, host_id, sale_date, total_amount, total_items, status) VALUES (35, 4, '2026-04-05', 20250000, 3, 'completed');
INSERT INTO live_sale_items (live_sale_id, product_id, quantity, unit_price, subtotal) VALUES (35, 15, 3, 6750000, 20250000);
INSERT INTO live_sales (schedule_id, host_id, sale_date, total_amount, total_items, status) VALUES (36, 5, '2026-05-12', 6900000, 1, 'completed');
INSERT INTO live_sale_items (live_sale_id, product_id, quantity, unit_price, subtotal) VALUES (36, 16, 1, 6900000, 6900000);
INSERT INTO live_sales (schedule_id, host_id, sale_date, total_amount, total_items, status) VALUES (37, 3, '2026-04-27', 14100000, 2, 'completed');
INSERT INTO live_sale_items (live_sale_id, product_id, quantity, unit_price, subtotal) VALUES (37, 17, 2, 7050000, 14100000);
INSERT INTO live_sales (schedule_id, host_id, sale_date, total_amount, total_items, status) VALUES (38, 4, '2026-03-07', 21600000, 3, 'completed');
INSERT INTO live_sale_items (live_sale_id, product_id, quantity, unit_price, subtotal) VALUES (38, 18, 3, 7200000, 21600000);
INSERT INTO live_sales (schedule_id, host_id, sale_date, total_amount, total_items, status) VALUES (39, 5, '2026-04-14', 7350000, 1, 'completed');
INSERT INTO live_sale_items (live_sale_id, product_id, quantity, unit_price, subtotal) VALUES (39, 19, 1, 7350000, 7350000);
INSERT INTO live_sales (schedule_id, host_id, sale_date, total_amount, total_items, status) VALUES (40, 3, '2026-04-01', 15000000, 2, 'completed');
INSERT INTO live_sale_items (live_sale_id, product_id, quantity, unit_price, subtotal) VALUES (40, 20, 2, 7500000, 15000000);
INSERT INTO live_sales (schedule_id, host_id, sale_date, total_amount, total_items, status) VALUES (41, 4, '2026-05-18', 24750000, 3, 'completed');
INSERT INTO live_sale_items (live_sale_id, product_id, quantity, unit_price, subtotal) VALUES (41, 1, 3, 8250000, 24750000);
INSERT INTO live_sales (schedule_id, host_id, sale_date, total_amount, total_items, status) VALUES (42, 5, '2026-02-02', 8500000, 1, 'completed');
INSERT INTO live_sale_items (live_sale_id, product_id, quantity, unit_price, subtotal) VALUES (42, 2, 1, 8500000, 8500000);
INSERT INTO live_sales (schedule_id, host_id, sale_date, total_amount, total_items, status) VALUES (43, 3, '2026-02-09', 17500000, 2, 'completed');
INSERT INTO live_sale_items (live_sale_id, product_id, quantity, unit_price, subtotal) VALUES (43, 3, 2, 8750000, 17500000);
INSERT INTO live_sales (schedule_id, host_id, sale_date, total_amount, total_items, status) VALUES (44, 4, '2026-02-21', 27000000, 3, 'completed');
INSERT INTO live_sale_items (live_sale_id, product_id, quantity, unit_price, subtotal) VALUES (44, 4, 3, 9000000, 27000000);
INSERT INTO live_sales (schedule_id, host_id, sale_date, total_amount, total_items, status) VALUES (45, 5, '2026-03-19', 9250000, 1, 'completed');
INSERT INTO live_sale_items (live_sale_id, product_id, quantity, unit_price, subtotal) VALUES (45, 5, 1, 9250000, 9250000);
INSERT INTO live_sales (schedule_id, host_id, sale_date, total_amount, total_items, status) VALUES (46, 3, '2026-05-11', 19000000, 2, 'completed');
INSERT INTO live_sale_items (live_sale_id, product_id, quantity, unit_price, subtotal) VALUES (46, 6, 2, 9500000, 19000000);
INSERT INTO live_sales (schedule_id, host_id, sale_date, total_amount, total_items, status) VALUES (47, 4, '2026-02-05', 29250000, 3, 'completed');
INSERT INTO live_sale_items (live_sale_id, product_id, quantity, unit_price, subtotal) VALUES (47, 7, 3, 9750000, 29250000);
INSERT INTO live_sales (schedule_id, host_id, sale_date, total_amount, total_items, status) VALUES (48, 5, '2026-02-02', 10000000, 1, 'completed');
INSERT INTO live_sale_items (live_sale_id, product_id, quantity, unit_price, subtotal) VALUES (48, 8, 1, 10000000, 10000000);
INSERT INTO live_sales (schedule_id, host_id, sale_date, total_amount, total_items, status) VALUES (49, 3, '2026-05-12', 20500000, 2, 'completed');
INSERT INTO live_sale_items (live_sale_id, product_id, quantity, unit_price, subtotal) VALUES (49, 9, 2, 10250000, 20500000);
INSERT INTO live_sales (schedule_id, host_id, sale_date, total_amount, total_items, status) VALUES (50, 4, '2026-05-18', 31500000, 3, 'completed');
INSERT INTO live_sale_items (live_sale_id, product_id, quantity, unit_price, subtotal) VALUES (50, 10, 3, 10500000, 31500000);
INSERT INTO live_sales (schedule_id, host_id, sale_date, total_amount, total_items, status) VALUES (51, 5, '2026-02-11', 10750000, 1, 'completed');
INSERT INTO live_sale_items (live_sale_id, product_id, quantity, unit_price, subtotal) VALUES (51, 11, 1, 10750000, 10750000);
INSERT INTO live_sales (schedule_id, host_id, sale_date, total_amount, total_items, status) VALUES (52, 3, '2026-03-10', 22000000, 2, 'completed');
INSERT INTO live_sale_items (live_sale_id, product_id, quantity, unit_price, subtotal) VALUES (52, 12, 2, 11000000, 22000000);
INSERT INTO live_sales (schedule_id, host_id, sale_date, total_amount, total_items, status) VALUES (53, 4, '2026-05-13', 19350000, 3, 'completed');
INSERT INTO live_sale_items (live_sale_id, product_id, quantity, unit_price, subtotal) VALUES (53, 13, 3, 6450000, 19350000);
INSERT INTO live_sales (schedule_id, host_id, sale_date, total_amount, total_items, status) VALUES (54, 5, '2026-04-12', 6600000, 1, 'completed');
INSERT INTO live_sale_items (live_sale_id, product_id, quantity, unit_price, subtotal) VALUES (54, 14, 1, 6600000, 6600000);
INSERT INTO live_sales (schedule_id, host_id, sale_date, total_amount, total_items, status) VALUES (55, 3, '2026-05-26', 13500000, 2, 'completed');
INSERT INTO live_sale_items (live_sale_id, product_id, quantity, unit_price, subtotal) VALUES (55, 15, 2, 6750000, 13500000);
INSERT INTO live_sales (schedule_id, host_id, sale_date, total_amount, total_items, status) VALUES (56, 4, '2026-05-07', 20700000, 3, 'completed');
INSERT INTO live_sale_items (live_sale_id, product_id, quantity, unit_price, subtotal) VALUES (56, 16, 3, 6900000, 20700000);
INSERT INTO live_sales (schedule_id, host_id, sale_date, total_amount, total_items, status) VALUES (57, 5, '2026-05-03', 7050000, 1, 'completed');
INSERT INTO live_sale_items (live_sale_id, product_id, quantity, unit_price, subtotal) VALUES (57, 17, 1, 7050000, 7050000);
INSERT INTO live_sales (schedule_id, host_id, sale_date, total_amount, total_items, status) VALUES (58, 3, '2026-03-05', 14400000, 2, 'completed');
INSERT INTO live_sale_items (live_sale_id, product_id, quantity, unit_price, subtotal) VALUES (58, 18, 2, 7200000, 14400000);
INSERT INTO live_sales (schedule_id, host_id, sale_date, total_amount, total_items, status) VALUES (59, 4, '2026-03-11', 22050000, 3, 'completed');
INSERT INTO live_sale_items (live_sale_id, product_id, quantity, unit_price, subtotal) VALUES (59, 19, 3, 7350000, 22050000);
INSERT INTO live_sales (schedule_id, host_id, sale_date, total_amount, total_items, status) VALUES (60, 5, '2026-04-15', 7500000, 1, 'completed');
INSERT INTO live_sale_items (live_sale_id, product_id, quantity, unit_price, subtotal) VALUES (60, 20, 1, 7500000, 7500000);
INSERT INTO live_sales (schedule_id, host_id, sale_date, total_amount, total_items, status) VALUES (61, 3, '2026-03-05', 16500000, 2, 'completed');
INSERT INTO live_sale_items (live_sale_id, product_id, quantity, unit_price, subtotal) VALUES (61, 1, 2, 8250000, 16500000);
INSERT INTO live_sales (schedule_id, host_id, sale_date, total_amount, total_items, status) VALUES (62, 4, '2026-04-29', 25500000, 3, 'completed');
INSERT INTO live_sale_items (live_sale_id, product_id, quantity, unit_price, subtotal) VALUES (62, 2, 3, 8500000, 25500000);
INSERT INTO live_sales (schedule_id, host_id, sale_date, total_amount, total_items, status) VALUES (63, 5, '2026-02-15', 8750000, 1, 'completed');
INSERT INTO live_sale_items (live_sale_id, product_id, quantity, unit_price, subtotal) VALUES (63, 3, 1, 8750000, 8750000);
INSERT INTO live_sales (schedule_id, host_id, sale_date, total_amount, total_items, status) VALUES (64, 3, '2026-04-12', 18000000, 2, 'completed');
INSERT INTO live_sale_items (live_sale_id, product_id, quantity, unit_price, subtotal) VALUES (64, 4, 2, 9000000, 18000000);
INSERT INTO live_sales (schedule_id, host_id, sale_date, total_amount, total_items, status) VALUES (65, 4, '2026-05-15', 27750000, 3, 'completed');
INSERT INTO live_sale_items (live_sale_id, product_id, quantity, unit_price, subtotal) VALUES (65, 5, 3, 9250000, 27750000);
INSERT INTO live_sales (schedule_id, host_id, sale_date, total_amount, total_items, status) VALUES (66, 5, '2026-04-11', 9500000, 1, 'completed');
INSERT INTO live_sale_items (live_sale_id, product_id, quantity, unit_price, subtotal) VALUES (66, 6, 1, 9500000, 9500000);
INSERT INTO live_sales (schedule_id, host_id, sale_date, total_amount, total_items, status) VALUES (67, 3, '2026-02-27', 19500000, 2, 'completed');
INSERT INTO live_sale_items (live_sale_id, product_id, quantity, unit_price, subtotal) VALUES (67, 7, 2, 9750000, 19500000);
INSERT INTO live_sales (schedule_id, host_id, sale_date, total_amount, total_items, status) VALUES (68, 4, '2026-04-15', 30000000, 3, 'completed');
INSERT INTO live_sale_items (live_sale_id, product_id, quantity, unit_price, subtotal) VALUES (68, 8, 3, 10000000, 30000000);
INSERT INTO live_sales (schedule_id, host_id, sale_date, total_amount, total_items, status) VALUES (69, 5, '2026-04-08', 10250000, 1, 'completed');
INSERT INTO live_sale_items (live_sale_id, product_id, quantity, unit_price, subtotal) VALUES (69, 9, 1, 10250000, 10250000);
INSERT INTO live_sales (schedule_id, host_id, sale_date, total_amount, total_items, status) VALUES (70, 3, '2026-05-30', 21000000, 2, 'completed');
INSERT INTO live_sale_items (live_sale_id, product_id, quantity, unit_price, subtotal) VALUES (70, 10, 2, 10500000, 21000000);
INSERT INTO live_sales (schedule_id, host_id, sale_date, total_amount, total_items, status) VALUES (71, 4, '2026-03-02', 32250000, 3, 'completed');
INSERT INTO live_sale_items (live_sale_id, product_id, quantity, unit_price, subtotal) VALUES (71, 11, 3, 10750000, 32250000);
INSERT INTO live_sales (schedule_id, host_id, sale_date, total_amount, total_items, status) VALUES (72, 5, '2026-05-09', 11000000, 1, 'completed');
INSERT INTO live_sale_items (live_sale_id, product_id, quantity, unit_price, subtotal) VALUES (72, 12, 1, 11000000, 11000000);
INSERT INTO live_sales (schedule_id, host_id, sale_date, total_amount, total_items, status) VALUES (73, 3, '2026-03-10', 12900000, 2, 'completed');
INSERT INTO live_sale_items (live_sale_id, product_id, quantity, unit_price, subtotal) VALUES (73, 13, 2, 6450000, 12900000);
INSERT INTO live_sales (schedule_id, host_id, sale_date, total_amount, total_items, status) VALUES (74, 4, '2026-04-01', 19800000, 3, 'completed');
INSERT INTO live_sale_items (live_sale_id, product_id, quantity, unit_price, subtotal) VALUES (74, 14, 3, 6600000, 19800000);
INSERT INTO live_sales (schedule_id, host_id, sale_date, total_amount, total_items, status) VALUES (75, 5, '2026-03-17', 6750000, 1, 'completed');
INSERT INTO live_sale_items (live_sale_id, product_id, quantity, unit_price, subtotal) VALUES (75, 15, 1, 6750000, 6750000);
INSERT INTO live_sales (schedule_id, host_id, sale_date, total_amount, total_items, status) VALUES (76, 3, '2026-03-09', 13800000, 2, 'completed');
INSERT INTO live_sale_items (live_sale_id, product_id, quantity, unit_price, subtotal) VALUES (76, 16, 2, 6900000, 13800000);
INSERT INTO live_sales (schedule_id, host_id, sale_date, total_amount, total_items, status) VALUES (77, 4, '2026-02-27', 21150000, 3, 'completed');
INSERT INTO live_sale_items (live_sale_id, product_id, quantity, unit_price, subtotal) VALUES (77, 17, 3, 7050000, 21150000);
INSERT INTO live_sales (schedule_id, host_id, sale_date, total_amount, total_items, status) VALUES (78, 5, '2026-03-19', 7200000, 1, 'completed');
INSERT INTO live_sale_items (live_sale_id, product_id, quantity, unit_price, subtotal) VALUES (78, 18, 1, 7200000, 7200000);
INSERT INTO live_sales (schedule_id, host_id, sale_date, total_amount, total_items, status) VALUES (79, 3, '2026-05-15', 14700000, 2, 'completed');
INSERT INTO live_sale_items (live_sale_id, product_id, quantity, unit_price, subtotal) VALUES (79, 19, 2, 7350000, 14700000);
INSERT INTO live_sales (schedule_id, host_id, sale_date, total_amount, total_items, status) VALUES (80, 4, '2026-04-14', 22500000, 3, 'completed');
INSERT INTO live_sale_items (live_sale_id, product_id, quantity, unit_price, subtotal) VALUES (80, 20, 3, 7500000, 22500000);
INSERT INTO live_sales (schedule_id, host_id, sale_date, total_amount, total_items, status) VALUES (81, 5, '2026-03-05', 8250000, 1, 'completed');
INSERT INTO live_sale_items (live_sale_id, product_id, quantity, unit_price, subtotal) VALUES (81, 1, 1, 8250000, 8250000);
INSERT INTO live_sales (schedule_id, host_id, sale_date, total_amount, total_items, status) VALUES (82, 3, '2026-04-24', 17000000, 2, 'completed');
INSERT INTO live_sale_items (live_sale_id, product_id, quantity, unit_price, subtotal) VALUES (82, 2, 2, 8500000, 17000000);
INSERT INTO live_sales (schedule_id, host_id, sale_date, total_amount, total_items, status) VALUES (83, 4, '2026-05-09', 26250000, 3, 'completed');
INSERT INTO live_sale_items (live_sale_id, product_id, quantity, unit_price, subtotal) VALUES (83, 3, 3, 8750000, 26250000);
INSERT INTO live_sales (schedule_id, host_id, sale_date, total_amount, total_items, status) VALUES (84, 5, '2026-02-16', 9000000, 1, 'completed');
INSERT INTO live_sale_items (live_sale_id, product_id, quantity, unit_price, subtotal) VALUES (84, 4, 1, 9000000, 9000000);
INSERT INTO live_sales (schedule_id, host_id, sale_date, total_amount, total_items, status) VALUES (85, 3, '2026-04-13', 18500000, 2, 'completed');
INSERT INTO live_sale_items (live_sale_id, product_id, quantity, unit_price, subtotal) VALUES (85, 5, 2, 9250000, 18500000);
INSERT INTO live_sales (schedule_id, host_id, sale_date, total_amount, total_items, status) VALUES (86, 4, '2026-05-10', 28500000, 3, 'completed');
INSERT INTO live_sale_items (live_sale_id, product_id, quantity, unit_price, subtotal) VALUES (86, 6, 3, 9500000, 28500000);
INSERT INTO live_sales (schedule_id, host_id, sale_date, total_amount, total_items, status) VALUES (87, 5, '2026-02-01', 9750000, 1, 'completed');
INSERT INTO live_sale_items (live_sale_id, product_id, quantity, unit_price, subtotal) VALUES (87, 7, 1, 9750000, 9750000);
INSERT INTO live_sales (schedule_id, host_id, sale_date, total_amount, total_items, status) VALUES (88, 3, '2026-03-12', 20000000, 2, 'completed');
INSERT INTO live_sale_items (live_sale_id, product_id, quantity, unit_price, subtotal) VALUES (88, 8, 2, 10000000, 20000000);
INSERT INTO live_sales (schedule_id, host_id, sale_date, total_amount, total_items, status) VALUES (89, 4, '2026-02-27', 30750000, 3, 'completed');
INSERT INTO live_sale_items (live_sale_id, product_id, quantity, unit_price, subtotal) VALUES (89, 9, 3, 10250000, 30750000);
INSERT INTO live_sales (schedule_id, host_id, sale_date, total_amount, total_items, status) VALUES (90, 5, '2026-05-13', 10500000, 1, 'completed');
INSERT INTO live_sale_items (live_sale_id, product_id, quantity, unit_price, subtotal) VALUES (90, 10, 1, 10500000, 10500000);
INSERT INTO live_sales (schedule_id, host_id, sale_date, total_amount, total_items, status) VALUES (91, 3, '2026-04-07', 21500000, 2, 'completed');
INSERT INTO live_sale_items (live_sale_id, product_id, quantity, unit_price, subtotal) VALUES (91, 11, 2, 10750000, 21500000);
INSERT INTO live_sales (schedule_id, host_id, sale_date, total_amount, total_items, status) VALUES (92, 4, '2026-04-06', 33000000, 3, 'completed');
INSERT INTO live_sale_items (live_sale_id, product_id, quantity, unit_price, subtotal) VALUES (92, 12, 3, 11000000, 33000000);
INSERT INTO live_sales (schedule_id, host_id, sale_date, total_amount, total_items, status) VALUES (93, 5, '2026-05-12', 6450000, 1, 'completed');
INSERT INTO live_sale_items (live_sale_id, product_id, quantity, unit_price, subtotal) VALUES (93, 13, 1, 6450000, 6450000);
INSERT INTO live_sales (schedule_id, host_id, sale_date, total_amount, total_items, status) VALUES (94, 3, '2026-04-23', 13200000, 2, 'completed');
INSERT INTO live_sale_items (live_sale_id, product_id, quantity, unit_price, subtotal) VALUES (94, 14, 2, 6600000, 13200000);
INSERT INTO live_sales (schedule_id, host_id, sale_date, total_amount, total_items, status) VALUES (95, 4, '2026-03-24', 20250000, 3, 'completed');
INSERT INTO live_sale_items (live_sale_id, product_id, quantity, unit_price, subtotal) VALUES (95, 15, 3, 6750000, 20250000);
INSERT INTO live_sales (schedule_id, host_id, sale_date, total_amount, total_items, status) VALUES (96, 5, '2026-04-26', 6900000, 1, 'completed');
INSERT INTO live_sale_items (live_sale_id, product_id, quantity, unit_price, subtotal) VALUES (96, 16, 1, 6900000, 6900000);
INSERT INTO live_sales (schedule_id, host_id, sale_date, total_amount, total_items, status) VALUES (97, 3, '2026-04-28', 14100000, 2, 'completed');
INSERT INTO live_sale_items (live_sale_id, product_id, quantity, unit_price, subtotal) VALUES (97, 17, 2, 7050000, 14100000);
INSERT INTO live_sales (schedule_id, host_id, sale_date, total_amount, total_items, status) VALUES (98, 4, '2026-04-16', 21600000, 3, 'completed');
INSERT INTO live_sale_items (live_sale_id, product_id, quantity, unit_price, subtotal) VALUES (98, 18, 3, 7200000, 21600000);
INSERT INTO live_sales (schedule_id, host_id, sale_date, total_amount, total_items, status) VALUES (99, 5, '2026-02-06', 7350000, 1, 'completed');
INSERT INTO live_sale_items (live_sale_id, product_id, quantity, unit_price, subtotal) VALUES (99, 19, 1, 7350000, 7350000);
INSERT INTO live_sales (schedule_id, host_id, sale_date, total_amount, total_items, status) VALUES (100, 3, '2026-03-22', 15000000, 2, 'completed');
INSERT INTO live_sale_items (live_sale_id, product_id, quantity, unit_price, subtotal) VALUES (100, 20, 2, 7500000, 15000000);
INSERT INTO live_sales (schedule_id, host_id, sale_date, total_amount, total_items, status) VALUES (101, 4, '2026-05-06', 24750000, 3, 'completed');
INSERT INTO live_sale_items (live_sale_id, product_id, quantity, unit_price, subtotal) VALUES (101, 1, 3, 8250000, 24750000);
INSERT INTO live_sales (schedule_id, host_id, sale_date, total_amount, total_items, status) VALUES (102, 5, '2026-03-22', 8500000, 1, 'completed');
INSERT INTO live_sale_items (live_sale_id, product_id, quantity, unit_price, subtotal) VALUES (102, 2, 1, 8500000, 8500000);
INSERT INTO live_sales (schedule_id, host_id, sale_date, total_amount, total_items, status) VALUES (103, 3, '2026-03-05', 17500000, 2, 'completed');
INSERT INTO live_sale_items (live_sale_id, product_id, quantity, unit_price, subtotal) VALUES (103, 3, 2, 8750000, 17500000);
INSERT INTO live_sales (schedule_id, host_id, sale_date, total_amount, total_items, status) VALUES (104, 4, '2026-05-30', 27000000, 3, 'completed');
INSERT INTO live_sale_items (live_sale_id, product_id, quantity, unit_price, subtotal) VALUES (104, 4, 3, 9000000, 27000000);
INSERT INTO live_sales (schedule_id, host_id, sale_date, total_amount, total_items, status) VALUES (105, 5, '2026-05-20', 9250000, 1, 'completed');
INSERT INTO live_sale_items (live_sale_id, product_id, quantity, unit_price, subtotal) VALUES (105, 5, 1, 9250000, 9250000);
INSERT INTO live_sales (schedule_id, host_id, sale_date, total_amount, total_items, status) VALUES (106, 3, '2026-03-09', 19000000, 2, 'completed');
INSERT INTO live_sale_items (live_sale_id, product_id, quantity, unit_price, subtotal) VALUES (106, 6, 2, 9500000, 19000000);
INSERT INTO live_sales (schedule_id, host_id, sale_date, total_amount, total_items, status) VALUES (107, 4, '2026-02-21', 29250000, 3, 'completed');
INSERT INTO live_sale_items (live_sale_id, product_id, quantity, unit_price, subtotal) VALUES (107, 7, 3, 9750000, 29250000);
INSERT INTO live_sales (schedule_id, host_id, sale_date, total_amount, total_items, status) VALUES (108, 5, '2026-03-23', 10000000, 1, 'completed');
INSERT INTO live_sale_items (live_sale_id, product_id, quantity, unit_price, subtotal) VALUES (108, 8, 1, 10000000, 10000000);
INSERT INTO live_sales (schedule_id, host_id, sale_date, total_amount, total_items, status) VALUES (109, 3, '2026-04-23', 20500000, 2, 'completed');
INSERT INTO live_sale_items (live_sale_id, product_id, quantity, unit_price, subtotal) VALUES (109, 9, 2, 10250000, 20500000);
INSERT INTO live_sales (schedule_id, host_id, sale_date, total_amount, total_items, status) VALUES (110, 4, '2026-04-28', 31500000, 3, 'completed');
INSERT INTO live_sale_items (live_sale_id, product_id, quantity, unit_price, subtotal) VALUES (110, 10, 3, 10500000, 31500000);
INSERT INTO live_sales (schedule_id, host_id, sale_date, total_amount, total_items, status) VALUES (111, 5, '2026-04-05', 10750000, 1, 'completed');
INSERT INTO live_sale_items (live_sale_id, product_id, quantity, unit_price, subtotal) VALUES (111, 11, 1, 10750000, 10750000);
INSERT INTO live_sales (schedule_id, host_id, sale_date, total_amount, total_items, status) VALUES (112, 3, '2026-05-20', 22000000, 2, 'completed');
INSERT INTO live_sale_items (live_sale_id, product_id, quantity, unit_price, subtotal) VALUES (112, 12, 2, 11000000, 22000000);
INSERT INTO live_sales (schedule_id, host_id, sale_date, total_amount, total_items, status) VALUES (113, 4, '2026-05-19', 19350000, 3, 'completed');
INSERT INTO live_sale_items (live_sale_id, product_id, quantity, unit_price, subtotal) VALUES (113, 13, 3, 6450000, 19350000);
INSERT INTO live_sales (schedule_id, host_id, sale_date, total_amount, total_items, status) VALUES (114, 5, '2026-02-09', 6600000, 1, 'completed');
INSERT INTO live_sale_items (live_sale_id, product_id, quantity, unit_price, subtotal) VALUES (114, 14, 1, 6600000, 6600000);
INSERT INTO live_sales (schedule_id, host_id, sale_date, total_amount, total_items, status) VALUES (115, 3, '2026-02-11', 13500000, 2, 'completed');
INSERT INTO live_sale_items (live_sale_id, product_id, quantity, unit_price, subtotal) VALUES (115, 15, 2, 6750000, 13500000);
INSERT INTO live_sales (schedule_id, host_id, sale_date, total_amount, total_items, status) VALUES (116, 4, '2026-04-30', 20700000, 3, 'completed');
INSERT INTO live_sale_items (live_sale_id, product_id, quantity, unit_price, subtotal) VALUES (116, 16, 3, 6900000, 20700000);
INSERT INTO live_sales (schedule_id, host_id, sale_date, total_amount, total_items, status) VALUES (117, 5, '2026-05-24', 7050000, 1, 'completed');
INSERT INTO live_sale_items (live_sale_id, product_id, quantity, unit_price, subtotal) VALUES (117, 17, 1, 7050000, 7050000);
INSERT INTO live_sales (schedule_id, host_id, sale_date, total_amount, total_items, status) VALUES (118, 3, '2026-03-30', 14400000, 2, 'completed');
INSERT INTO live_sale_items (live_sale_id, product_id, quantity, unit_price, subtotal) VALUES (118, 18, 2, 7200000, 14400000);
INSERT INTO live_sales (schedule_id, host_id, sale_date, total_amount, total_items, status) VALUES (119, 4, '2026-03-31', 22050000, 3, 'completed');
INSERT INTO live_sale_items (live_sale_id, product_id, quantity, unit_price, subtotal) VALUES (119, 19, 3, 7350000, 22050000);
INSERT INTO live_sales (schedule_id, host_id, sale_date, total_amount, total_items, status) VALUES (120, 5, '2026-02-01', 7500000, 1, 'completed');
INSERT INTO live_sale_items (live_sale_id, product_id, quantity, unit_price, subtotal) VALUES (120, 20, 1, 7500000, 7500000);
INSERT INTO live_sales (schedule_id, host_id, sale_date, total_amount, total_items, status) VALUES (121, 3, '2026-02-18', 16500000, 2, 'completed');
INSERT INTO live_sale_items (live_sale_id, product_id, quantity, unit_price, subtotal) VALUES (121, 1, 2, 8250000, 16500000);
INSERT INTO live_sales (schedule_id, host_id, sale_date, total_amount, total_items, status) VALUES (122, 4, '2026-04-24', 25500000, 3, 'completed');
INSERT INTO live_sale_items (live_sale_id, product_id, quantity, unit_price, subtotal) VALUES (122, 2, 3, 8500000, 25500000);
INSERT INTO live_sales (schedule_id, host_id, sale_date, total_amount, total_items, status) VALUES (123, 5, '2026-03-28', 8750000, 1, 'completed');
INSERT INTO live_sale_items (live_sale_id, product_id, quantity, unit_price, subtotal) VALUES (123, 3, 1, 8750000, 8750000);
INSERT INTO live_sales (schedule_id, host_id, sale_date, total_amount, total_items, status) VALUES (124, 3, '2026-03-22', 18000000, 2, 'completed');
INSERT INTO live_sale_items (live_sale_id, product_id, quantity, unit_price, subtotal) VALUES (124, 4, 2, 9000000, 18000000);
INSERT INTO live_sales (schedule_id, host_id, sale_date, total_amount, total_items, status) VALUES (125, 4, '2026-04-27', 27750000, 3, 'completed');
INSERT INTO live_sale_items (live_sale_id, product_id, quantity, unit_price, subtotal) VALUES (125, 5, 3, 9250000, 27750000);
INSERT INTO live_sales (schedule_id, host_id, sale_date, total_amount, total_items, status) VALUES (126, 5, '2026-03-16', 9500000, 1, 'completed');
INSERT INTO live_sale_items (live_sale_id, product_id, quantity, unit_price, subtotal) VALUES (126, 6, 1, 9500000, 9500000);
INSERT INTO live_sales (schedule_id, host_id, sale_date, total_amount, total_items, status) VALUES (127, 3, '2026-05-09', 19500000, 2, 'completed');
INSERT INTO live_sale_items (live_sale_id, product_id, quantity, unit_price, subtotal) VALUES (127, 7, 2, 9750000, 19500000);
INSERT INTO live_sales (schedule_id, host_id, sale_date, total_amount, total_items, status) VALUES (128, 4, '2026-04-24', 30000000, 3, 'completed');
INSERT INTO live_sale_items (live_sale_id, product_id, quantity, unit_price, subtotal) VALUES (128, 8, 3, 10000000, 30000000);
INSERT INTO live_sales (schedule_id, host_id, sale_date, total_amount, total_items, status) VALUES (129, 5, '2026-03-30', 10250000, 1, 'completed');
INSERT INTO live_sale_items (live_sale_id, product_id, quantity, unit_price, subtotal) VALUES (129, 9, 1, 10250000, 10250000);
INSERT INTO live_sales (schedule_id, host_id, sale_date, total_amount, total_items, status) VALUES (130, 3, '2026-05-06', 21000000, 2, 'completed');
INSERT INTO live_sale_items (live_sale_id, product_id, quantity, unit_price, subtotal) VALUES (130, 10, 2, 10500000, 21000000);
INSERT INTO live_sales (schedule_id, host_id, sale_date, total_amount, total_items, status) VALUES (131, 4, '2026-03-09', 32250000, 3, 'completed');
INSERT INTO live_sale_items (live_sale_id, product_id, quantity, unit_price, subtotal) VALUES (131, 11, 3, 10750000, 32250000);
INSERT INTO live_sales (schedule_id, host_id, sale_date, total_amount, total_items, status) VALUES (132, 5, '2026-03-24', 11000000, 1, 'completed');
INSERT INTO live_sale_items (live_sale_id, product_id, quantity, unit_price, subtotal) VALUES (132, 12, 1, 11000000, 11000000);
INSERT INTO live_sales (schedule_id, host_id, sale_date, total_amount, total_items, status) VALUES (133, 3, '2026-02-16', 12900000, 2, 'completed');
INSERT INTO live_sale_items (live_sale_id, product_id, quantity, unit_price, subtotal) VALUES (133, 13, 2, 6450000, 12900000);
INSERT INTO live_sales (schedule_id, host_id, sale_date, total_amount, total_items, status) VALUES (134, 4, '2026-03-19', 19800000, 3, 'completed');
INSERT INTO live_sale_items (live_sale_id, product_id, quantity, unit_price, subtotal) VALUES (134, 14, 3, 6600000, 19800000);
INSERT INTO live_sales (schedule_id, host_id, sale_date, total_amount, total_items, status) VALUES (135, 5, '2026-03-04', 6750000, 1, 'completed');
INSERT INTO live_sale_items (live_sale_id, product_id, quantity, unit_price, subtotal) VALUES (135, 15, 1, 6750000, 6750000);
INSERT INTO live_sales (schedule_id, host_id, sale_date, total_amount, total_items, status) VALUES (136, 3, '2026-04-09', 13800000, 2, 'completed');
INSERT INTO live_sale_items (live_sale_id, product_id, quantity, unit_price, subtotal) VALUES (136, 16, 2, 6900000, 13800000);
INSERT INTO live_sales (schedule_id, host_id, sale_date, total_amount, total_items, status) VALUES (137, 4, '2026-02-25', 21150000, 3, 'completed');
INSERT INTO live_sale_items (live_sale_id, product_id, quantity, unit_price, subtotal) VALUES (137, 17, 3, 7050000, 21150000);
INSERT INTO live_sales (schedule_id, host_id, sale_date, total_amount, total_items, status) VALUES (138, 5, '2026-02-13', 7200000, 1, 'completed');
INSERT INTO live_sale_items (live_sale_id, product_id, quantity, unit_price, subtotal) VALUES (138, 18, 1, 7200000, 7200000);
INSERT INTO live_sales (schedule_id, host_id, sale_date, total_amount, total_items, status) VALUES (139, 3, '2026-02-08', 14700000, 2, 'completed');
INSERT INTO live_sale_items (live_sale_id, product_id, quantity, unit_price, subtotal) VALUES (139, 19, 2, 7350000, 14700000);
INSERT INTO live_sales (schedule_id, host_id, sale_date, total_amount, total_items, status) VALUES (140, 4, '2026-05-18', 22500000, 3, 'completed');
INSERT INTO live_sale_items (live_sale_id, product_id, quantity, unit_price, subtotal) VALUES (140, 20, 3, 7500000, 22500000);
INSERT INTO live_sales (schedule_id, host_id, sale_date, total_amount, total_items, status) VALUES (141, 5, '2026-05-12', 8250000, 1, 'completed');
INSERT INTO live_sale_items (live_sale_id, product_id, quantity, unit_price, subtotal) VALUES (141, 1, 1, 8250000, 8250000);
INSERT INTO live_sales (schedule_id, host_id, sale_date, total_amount, total_items, status) VALUES (142, 3, '2026-03-15', 17000000, 2, 'completed');
INSERT INTO live_sale_items (live_sale_id, product_id, quantity, unit_price, subtotal) VALUES (142, 2, 2, 8500000, 17000000);
INSERT INTO live_sales (schedule_id, host_id, sale_date, total_amount, total_items, status) VALUES (143, 4, '2026-04-05', 26250000, 3, 'completed');
INSERT INTO live_sale_items (live_sale_id, product_id, quantity, unit_price, subtotal) VALUES (143, 3, 3, 8750000, 26250000);
INSERT INTO live_sales (schedule_id, host_id, sale_date, total_amount, total_items, status) VALUES (144, 5, '2026-05-10', 9000000, 1, 'completed');
INSERT INTO live_sale_items (live_sale_id, product_id, quantity, unit_price, subtotal) VALUES (144, 4, 1, 9000000, 9000000);
INSERT INTO live_sales (schedule_id, host_id, sale_date, total_amount, total_items, status) VALUES (145, 3, '2026-04-24', 18500000, 2, 'completed');
INSERT INTO live_sale_items (live_sale_id, product_id, quantity, unit_price, subtotal) VALUES (145, 5, 2, 9250000, 18500000);
INSERT INTO live_sales (schedule_id, host_id, sale_date, total_amount, total_items, status) VALUES (146, 4, '2026-03-03', 28500000, 3, 'completed');
INSERT INTO live_sale_items (live_sale_id, product_id, quantity, unit_price, subtotal) VALUES (146, 6, 3, 9500000, 28500000);
INSERT INTO live_sales (schedule_id, host_id, sale_date, total_amount, total_items, status) VALUES (147, 5, '2026-02-02', 9750000, 1, 'completed');
INSERT INTO live_sale_items (live_sale_id, product_id, quantity, unit_price, subtotal) VALUES (147, 7, 1, 9750000, 9750000);
INSERT INTO live_sales (schedule_id, host_id, sale_date, total_amount, total_items, status) VALUES (148, 3, '2026-03-30', 20000000, 2, 'completed');
INSERT INTO live_sale_items (live_sale_id, product_id, quantity, unit_price, subtotal) VALUES (148, 8, 2, 10000000, 20000000);
INSERT INTO live_sales (schedule_id, host_id, sale_date, total_amount, total_items, status) VALUES (149, 4, '2026-05-05', 30750000, 3, 'completed');
INSERT INTO live_sale_items (live_sale_id, product_id, quantity, unit_price, subtotal) VALUES (149, 9, 3, 10250000, 30750000);
INSERT INTO live_sales (schedule_id, host_id, sale_date, total_amount, total_items, status) VALUES (150, 5, '2026-03-06', 10500000, 1, 'completed');
INSERT INTO live_sale_items (live_sale_id, product_id, quantity, unit_price, subtotal) VALUES (150, 10, 1, 10500000, 10500000);
INSERT INTO live_sales (schedule_id, host_id, sale_date, total_amount, total_items, status) VALUES (151, 3, '2026-02-07', 21500000, 2, 'completed');
INSERT INTO live_sale_items (live_sale_id, product_id, quantity, unit_price, subtotal) VALUES (151, 11, 2, 10750000, 21500000);
INSERT INTO live_sales (schedule_id, host_id, sale_date, total_amount, total_items, status) VALUES (152, 4, '2026-05-16', 33000000, 3, 'completed');
INSERT INTO live_sale_items (live_sale_id, product_id, quantity, unit_price, subtotal) VALUES (152, 12, 3, 11000000, 33000000);
INSERT INTO live_sales (schedule_id, host_id, sale_date, total_amount, total_items, status) VALUES (153, 5, '2026-03-11', 6450000, 1, 'completed');
INSERT INTO live_sale_items (live_sale_id, product_id, quantity, unit_price, subtotal) VALUES (153, 13, 1, 6450000, 6450000);
INSERT INTO live_sales (schedule_id, host_id, sale_date, total_amount, total_items, status) VALUES (154, 3, '2026-05-30', 13200000, 2, 'completed');
INSERT INTO live_sale_items (live_sale_id, product_id, quantity, unit_price, subtotal) VALUES (154, 14, 2, 6600000, 13200000);
INSERT INTO live_sales (schedule_id, host_id, sale_date, total_amount, total_items, status) VALUES (155, 4, '2026-02-25', 20250000, 3, 'completed');
INSERT INTO live_sale_items (live_sale_id, product_id, quantity, unit_price, subtotal) VALUES (155, 15, 3, 6750000, 20250000);
INSERT INTO live_sales (schedule_id, host_id, sale_date, total_amount, total_items, status) VALUES (156, 5, '2026-05-28', 6900000, 1, 'completed');
INSERT INTO live_sale_items (live_sale_id, product_id, quantity, unit_price, subtotal) VALUES (156, 16, 1, 6900000, 6900000);
INSERT INTO live_sales (schedule_id, host_id, sale_date, total_amount, total_items, status) VALUES (157, 3, '2026-05-04', 14100000, 2, 'completed');
INSERT INTO live_sale_items (live_sale_id, product_id, quantity, unit_price, subtotal) VALUES (157, 17, 2, 7050000, 14100000);
INSERT INTO live_sales (schedule_id, host_id, sale_date, total_amount, total_items, status) VALUES (158, 4, '2026-02-14', 21600000, 3, 'completed');
INSERT INTO live_sale_items (live_sale_id, product_id, quantity, unit_price, subtotal) VALUES (158, 18, 3, 7200000, 21600000);
INSERT INTO live_sales (schedule_id, host_id, sale_date, total_amount, total_items, status) VALUES (159, 5, '2026-05-20', 7350000, 1, 'completed');
INSERT INTO live_sale_items (live_sale_id, product_id, quantity, unit_price, subtotal) VALUES (159, 19, 1, 7350000, 7350000);
INSERT INTO live_sales (schedule_id, host_id, sale_date, total_amount, total_items, status) VALUES (160, 3, '2026-05-05', 15000000, 2, 'completed');
INSERT INTO live_sale_items (live_sale_id, product_id, quantity, unit_price, subtotal) VALUES (160, 20, 2, 7500000, 15000000);
INSERT INTO live_sales (schedule_id, host_id, sale_date, total_amount, total_items, status) VALUES (161, 4, '2026-05-08', 24750000, 3, 'completed');
INSERT INTO live_sale_items (live_sale_id, product_id, quantity, unit_price, subtotal) VALUES (161, 1, 3, 8250000, 24750000);
INSERT INTO live_sales (schedule_id, host_id, sale_date, total_amount, total_items, status) VALUES (162, 5, '2026-05-30', 8500000, 1, 'completed');
INSERT INTO live_sale_items (live_sale_id, product_id, quantity, unit_price, subtotal) VALUES (162, 2, 1, 8500000, 8500000);
INSERT INTO live_sales (schedule_id, host_id, sale_date, total_amount, total_items, status) VALUES (163, 3, '2026-03-30', 17500000, 2, 'completed');
INSERT INTO live_sale_items (live_sale_id, product_id, quantity, unit_price, subtotal) VALUES (163, 3, 2, 8750000, 17500000);
INSERT INTO live_sales (schedule_id, host_id, sale_date, total_amount, total_items, status) VALUES (164, 4, '2026-02-11', 27000000, 3, 'completed');
INSERT INTO live_sale_items (live_sale_id, product_id, quantity, unit_price, subtotal) VALUES (164, 4, 3, 9000000, 27000000);
INSERT INTO live_sales (schedule_id, host_id, sale_date, total_amount, total_items, status) VALUES (165, 5, '2026-02-23', 9250000, 1, 'completed');
INSERT INTO live_sale_items (live_sale_id, product_id, quantity, unit_price, subtotal) VALUES (165, 5, 1, 9250000, 9250000);
INSERT INTO live_sales (schedule_id, host_id, sale_date, total_amount, total_items, status) VALUES (166, 3, '2026-03-05', 19000000, 2, 'completed');
INSERT INTO live_sale_items (live_sale_id, product_id, quantity, unit_price, subtotal) VALUES (166, 6, 2, 9500000, 19000000);
INSERT INTO live_sales (schedule_id, host_id, sale_date, total_amount, total_items, status) VALUES (167, 4, '2026-04-24', 29250000, 3, 'completed');
INSERT INTO live_sale_items (live_sale_id, product_id, quantity, unit_price, subtotal) VALUES (167, 7, 3, 9750000, 29250000);
INSERT INTO live_sales (schedule_id, host_id, sale_date, total_amount, total_items, status) VALUES (168, 5, '2026-02-16', 10000000, 1, 'completed');
INSERT INTO live_sale_items (live_sale_id, product_id, quantity, unit_price, subtotal) VALUES (168, 8, 1, 10000000, 10000000);
INSERT INTO live_sales (schedule_id, host_id, sale_date, total_amount, total_items, status) VALUES (169, 3, '2026-05-21', 20500000, 2, 'completed');
INSERT INTO live_sale_items (live_sale_id, product_id, quantity, unit_price, subtotal) VALUES (169, 9, 2, 10250000, 20500000);
INSERT INTO live_sales (schedule_id, host_id, sale_date, total_amount, total_items, status) VALUES (170, 4, '2026-05-29', 31500000, 3, 'completed');
INSERT INTO live_sale_items (live_sale_id, product_id, quantity, unit_price, subtotal) VALUES (170, 10, 3, 10500000, 31500000);
INSERT INTO live_sales (schedule_id, host_id, sale_date, total_amount, total_items, status) VALUES (171, 5, '2026-04-12', 10750000, 1, 'completed');
INSERT INTO live_sale_items (live_sale_id, product_id, quantity, unit_price, subtotal) VALUES (171, 11, 1, 10750000, 10750000);
INSERT INTO live_sales (schedule_id, host_id, sale_date, total_amount, total_items, status) VALUES (172, 3, '2026-02-05', 22000000, 2, 'completed');
INSERT INTO live_sale_items (live_sale_id, product_id, quantity, unit_price, subtotal) VALUES (172, 12, 2, 11000000, 22000000);
INSERT INTO live_sales (schedule_id, host_id, sale_date, total_amount, total_items, status) VALUES (173, 4, '2026-02-20', 19350000, 3, 'completed');
INSERT INTO live_sale_items (live_sale_id, product_id, quantity, unit_price, subtotal) VALUES (173, 13, 3, 6450000, 19350000);
INSERT INTO live_sales (schedule_id, host_id, sale_date, total_amount, total_items, status) VALUES (174, 5, '2026-04-24', 6600000, 1, 'completed');
INSERT INTO live_sale_items (live_sale_id, product_id, quantity, unit_price, subtotal) VALUES (174, 14, 1, 6600000, 6600000);
INSERT INTO live_sales (schedule_id, host_id, sale_date, total_amount, total_items, status) VALUES (175, 3, '2026-02-01', 13500000, 2, 'completed');
INSERT INTO live_sale_items (live_sale_id, product_id, quantity, unit_price, subtotal) VALUES (175, 15, 2, 6750000, 13500000);
INSERT INTO live_sales (schedule_id, host_id, sale_date, total_amount, total_items, status) VALUES (176, 4, '2026-02-19', 20700000, 3, 'completed');
INSERT INTO live_sale_items (live_sale_id, product_id, quantity, unit_price, subtotal) VALUES (176, 16, 3, 6900000, 20700000);
INSERT INTO live_sales (schedule_id, host_id, sale_date, total_amount, total_items, status) VALUES (177, 5, '2026-05-25', 7050000, 1, 'completed');
INSERT INTO live_sale_items (live_sale_id, product_id, quantity, unit_price, subtotal) VALUES (177, 17, 1, 7050000, 7050000);
INSERT INTO live_sales (schedule_id, host_id, sale_date, total_amount, total_items, status) VALUES (178, 3, '2026-03-03', 14400000, 2, 'completed');
INSERT INTO live_sale_items (live_sale_id, product_id, quantity, unit_price, subtotal) VALUES (178, 18, 2, 7200000, 14400000);
INSERT INTO live_sales (schedule_id, host_id, sale_date, total_amount, total_items, status) VALUES (179, 4, '2026-02-03', 22050000, 3, 'completed');
INSERT INTO live_sale_items (live_sale_id, product_id, quantity, unit_price, subtotal) VALUES (179, 19, 3, 7350000, 22050000);
INSERT INTO live_sales (schedule_id, host_id, sale_date, total_amount, total_items, status) VALUES (180, 5, '2026-05-21', 7500000, 1, 'completed');
INSERT INTO live_sale_items (live_sale_id, product_id, quantity, unit_price, subtotal) VALUES (180, 20, 1, 7500000, 7500000);
INSERT INTO live_sales (schedule_id, host_id, sale_date, total_amount, total_items, status) VALUES (181, 3, '2026-04-16', 16500000, 2, 'completed');
INSERT INTO live_sale_items (live_sale_id, product_id, quantity, unit_price, subtotal) VALUES (181, 1, 2, 8250000, 16500000);
INSERT INTO live_sales (schedule_id, host_id, sale_date, total_amount, total_items, status) VALUES (182, 4, '2026-02-07', 25500000, 3, 'completed');
INSERT INTO live_sale_items (live_sale_id, product_id, quantity, unit_price, subtotal) VALUES (182, 2, 3, 8500000, 25500000);
INSERT INTO live_sales (schedule_id, host_id, sale_date, total_amount, total_items, status) VALUES (183, 5, '2026-03-10', 8750000, 1, 'completed');
INSERT INTO live_sale_items (live_sale_id, product_id, quantity, unit_price, subtotal) VALUES (183, 3, 1, 8750000, 8750000);
INSERT INTO live_sales (schedule_id, host_id, sale_date, total_amount, total_items, status) VALUES (184, 3, '2026-03-24', 18000000, 2, 'completed');
INSERT INTO live_sale_items (live_sale_id, product_id, quantity, unit_price, subtotal) VALUES (184, 4, 2, 9000000, 18000000);
INSERT INTO live_sales (schedule_id, host_id, sale_date, total_amount, total_items, status) VALUES (185, 4, '2026-05-18', 27750000, 3, 'completed');
INSERT INTO live_sale_items (live_sale_id, product_id, quantity, unit_price, subtotal) VALUES (185, 5, 3, 9250000, 27750000);
INSERT INTO live_sales (schedule_id, host_id, sale_date, total_amount, total_items, status) VALUES (186, 5, '2026-03-20', 9500000, 1, 'completed');
INSERT INTO live_sale_items (live_sale_id, product_id, quantity, unit_price, subtotal) VALUES (186, 6, 1, 9500000, 9500000);
INSERT INTO live_sales (schedule_id, host_id, sale_date, total_amount, total_items, status) VALUES (187, 3, '2026-03-24', 19500000, 2, 'completed');
INSERT INTO live_sale_items (live_sale_id, product_id, quantity, unit_price, subtotal) VALUES (187, 7, 2, 9750000, 19500000);
INSERT INTO live_sales (schedule_id, host_id, sale_date, total_amount, total_items, status) VALUES (188, 4, '2026-02-07', 30000000, 3, 'completed');
INSERT INTO live_sale_items (live_sale_id, product_id, quantity, unit_price, subtotal) VALUES (188, 8, 3, 10000000, 30000000);
INSERT INTO live_sales (schedule_id, host_id, sale_date, total_amount, total_items, status) VALUES (189, 5, '2026-04-29', 10250000, 1, 'completed');
INSERT INTO live_sale_items (live_sale_id, product_id, quantity, unit_price, subtotal) VALUES (189, 9, 1, 10250000, 10250000);
INSERT INTO live_sales (schedule_id, host_id, sale_date, total_amount, total_items, status) VALUES (190, 3, '2026-02-06', 21000000, 2, 'completed');
INSERT INTO live_sale_items (live_sale_id, product_id, quantity, unit_price, subtotal) VALUES (190, 10, 2, 10500000, 21000000);
INSERT INTO live_sales (schedule_id, host_id, sale_date, total_amount, total_items, status) VALUES (191, 4, '2026-02-25', 32250000, 3, 'completed');
INSERT INTO live_sale_items (live_sale_id, product_id, quantity, unit_price, subtotal) VALUES (191, 11, 3, 10750000, 32250000);
INSERT INTO live_sales (schedule_id, host_id, sale_date, total_amount, total_items, status) VALUES (192, 5, '2026-03-13', 11000000, 1, 'completed');
INSERT INTO live_sale_items (live_sale_id, product_id, quantity, unit_price, subtotal) VALUES (192, 12, 1, 11000000, 11000000);
INSERT INTO live_sales (schedule_id, host_id, sale_date, total_amount, total_items, status) VALUES (193, 3, '2026-05-07', 12900000, 2, 'completed');
INSERT INTO live_sale_items (live_sale_id, product_id, quantity, unit_price, subtotal) VALUES (193, 13, 2, 6450000, 12900000);
INSERT INTO live_sales (schedule_id, host_id, sale_date, total_amount, total_items, status) VALUES (194, 4, '2026-05-11', 19800000, 3, 'completed');
INSERT INTO live_sale_items (live_sale_id, product_id, quantity, unit_price, subtotal) VALUES (194, 14, 3, 6600000, 19800000);
INSERT INTO live_sales (schedule_id, host_id, sale_date, total_amount, total_items, status) VALUES (195, 5, '2026-04-11', 6750000, 1, 'completed');
INSERT INTO live_sale_items (live_sale_id, product_id, quantity, unit_price, subtotal) VALUES (195, 15, 1, 6750000, 6750000);
INSERT INTO live_sales (schedule_id, host_id, sale_date, total_amount, total_items, status) VALUES (196, 3, '2026-05-15', 13800000, 2, 'completed');
INSERT INTO live_sale_items (live_sale_id, product_id, quantity, unit_price, subtotal) VALUES (196, 16, 2, 6900000, 13800000);
INSERT INTO live_sales (schedule_id, host_id, sale_date, total_amount, total_items, status) VALUES (197, 4, '2026-03-21', 21150000, 3, 'completed');
INSERT INTO live_sale_items (live_sale_id, product_id, quantity, unit_price, subtotal) VALUES (197, 17, 3, 7050000, 21150000);
INSERT INTO live_sales (schedule_id, host_id, sale_date, total_amount, total_items, status) VALUES (198, 5, '2026-02-05', 7200000, 1, 'completed');
INSERT INTO live_sale_items (live_sale_id, product_id, quantity, unit_price, subtotal) VALUES (198, 18, 1, 7200000, 7200000);
INSERT INTO live_sales (schedule_id, host_id, sale_date, total_amount, total_items, status) VALUES (199, 3, '2026-03-09', 14700000, 2, 'completed');
INSERT INTO live_sale_items (live_sale_id, product_id, quantity, unit_price, subtotal) VALUES (199, 19, 2, 7350000, 14700000);
INSERT INTO live_sales (schedule_id, host_id, sale_date, total_amount, total_items, status) VALUES (200, 4, '2026-03-22', 22500000, 3, 'completed');
INSERT INTO live_sale_items (live_sale_id, product_id, quantity, unit_price, subtotal) VALUES (200, 20, 3, 7500000, 22500000);
INSERT INTO live_sales (schedule_id, host_id, sale_date, total_amount, total_items, status) VALUES (201, 5, '2026-03-17', 8250000, 1, 'completed');
INSERT INTO live_sale_items (live_sale_id, product_id, quantity, unit_price, subtotal) VALUES (201, 1, 1, 8250000, 8250000);
INSERT INTO live_sales (schedule_id, host_id, sale_date, total_amount, total_items, status) VALUES (202, 3, '2026-02-15', 17000000, 2, 'completed');
INSERT INTO live_sale_items (live_sale_id, product_id, quantity, unit_price, subtotal) VALUES (202, 2, 2, 8500000, 17000000);
INSERT INTO live_sales (schedule_id, host_id, sale_date, total_amount, total_items, status) VALUES (203, 4, '2026-03-18', 26250000, 3, 'completed');
INSERT INTO live_sale_items (live_sale_id, product_id, quantity, unit_price, subtotal) VALUES (203, 3, 3, 8750000, 26250000);
INSERT INTO live_sales (schedule_id, host_id, sale_date, total_amount, total_items, status) VALUES (204, 5, '2026-02-11', 9000000, 1, 'completed');
INSERT INTO live_sale_items (live_sale_id, product_id, quantity, unit_price, subtotal) VALUES (204, 4, 1, 9000000, 9000000);
INSERT INTO live_sales (schedule_id, host_id, sale_date, total_amount, total_items, status) VALUES (205, 3, '2026-04-29', 18500000, 2, 'completed');
INSERT INTO live_sale_items (live_sale_id, product_id, quantity, unit_price, subtotal) VALUES (205, 5, 2, 9250000, 18500000);
INSERT INTO live_sales (schedule_id, host_id, sale_date, total_amount, total_items, status) VALUES (206, 4, '2026-05-17', 28500000, 3, 'completed');
INSERT INTO live_sale_items (live_sale_id, product_id, quantity, unit_price, subtotal) VALUES (206, 6, 3, 9500000, 28500000);
INSERT INTO live_sales (schedule_id, host_id, sale_date, total_amount, total_items, status) VALUES (207, 5, '2026-03-27', 9750000, 1, 'completed');
INSERT INTO live_sale_items (live_sale_id, product_id, quantity, unit_price, subtotal) VALUES (207, 7, 1, 9750000, 9750000);
INSERT INTO live_sales (schedule_id, host_id, sale_date, total_amount, total_items, status) VALUES (208, 3, '2026-03-11', 20000000, 2, 'completed');
INSERT INTO live_sale_items (live_sale_id, product_id, quantity, unit_price, subtotal) VALUES (208, 8, 2, 10000000, 20000000);
INSERT INTO live_sales (schedule_id, host_id, sale_date, total_amount, total_items, status) VALUES (209, 4, '2026-03-15', 30750000, 3, 'completed');
INSERT INTO live_sale_items (live_sale_id, product_id, quantity, unit_price, subtotal) VALUES (209, 9, 3, 10250000, 30750000);
INSERT INTO live_sales (schedule_id, host_id, sale_date, total_amount, total_items, status) VALUES (210, 5, '2026-03-22', 10500000, 1, 'completed');
INSERT INTO live_sale_items (live_sale_id, product_id, quantity, unit_price, subtotal) VALUES (210, 10, 1, 10500000, 10500000);
INSERT INTO live_sales (schedule_id, host_id, sale_date, total_amount, total_items, status) VALUES (211, 3, '2026-04-04', 21500000, 2, 'completed');
INSERT INTO live_sale_items (live_sale_id, product_id, quantity, unit_price, subtotal) VALUES (211, 11, 2, 10750000, 21500000);
INSERT INTO live_sales (schedule_id, host_id, sale_date, total_amount, total_items, status) VALUES (212, 4, '2026-04-20', 33000000, 3, 'completed');
INSERT INTO live_sale_items (live_sale_id, product_id, quantity, unit_price, subtotal) VALUES (212, 12, 3, 11000000, 33000000);
INSERT INTO live_sales (schedule_id, host_id, sale_date, total_amount, total_items, status) VALUES (213, 5, '2026-04-25', 6450000, 1, 'completed');
INSERT INTO live_sale_items (live_sale_id, product_id, quantity, unit_price, subtotal) VALUES (213, 13, 1, 6450000, 6450000);
INSERT INTO live_sales (schedule_id, host_id, sale_date, total_amount, total_items, status) VALUES (214, 3, '2026-04-17', 13200000, 2, 'completed');
INSERT INTO live_sale_items (live_sale_id, product_id, quantity, unit_price, subtotal) VALUES (214, 14, 2, 6600000, 13200000);
INSERT INTO live_sales (schedule_id, host_id, sale_date, total_amount, total_items, status) VALUES (215, 4, '2026-03-20', 20250000, 3, 'completed');
INSERT INTO live_sale_items (live_sale_id, product_id, quantity, unit_price, subtotal) VALUES (215, 15, 3, 6750000, 20250000);
INSERT INTO live_sales (schedule_id, host_id, sale_date, total_amount, total_items, status) VALUES (216, 5, '2026-05-03', 6900000, 1, 'completed');
INSERT INTO live_sale_items (live_sale_id, product_id, quantity, unit_price, subtotal) VALUES (216, 16, 1, 6900000, 6900000);
INSERT INTO live_sales (schedule_id, host_id, sale_date, total_amount, total_items, status) VALUES (217, 3, '2026-05-30', 14100000, 2, 'completed');
INSERT INTO live_sale_items (live_sale_id, product_id, quantity, unit_price, subtotal) VALUES (217, 17, 2, 7050000, 14100000);
INSERT INTO live_sales (schedule_id, host_id, sale_date, total_amount, total_items, status) VALUES (218, 4, '2026-03-10', 21600000, 3, 'completed');
INSERT INTO live_sale_items (live_sale_id, product_id, quantity, unit_price, subtotal) VALUES (218, 18, 3, 7200000, 21600000);
INSERT INTO live_sales (schedule_id, host_id, sale_date, total_amount, total_items, status) VALUES (219, 5, '2026-05-18', 7350000, 1, 'completed');
INSERT INTO live_sale_items (live_sale_id, product_id, quantity, unit_price, subtotal) VALUES (219, 19, 1, 7350000, 7350000);
INSERT INTO live_sales (schedule_id, host_id, sale_date, total_amount, total_items, status) VALUES (220, 3, '2026-04-10', 15000000, 2, 'completed');
INSERT INTO live_sale_items (live_sale_id, product_id, quantity, unit_price, subtotal) VALUES (220, 20, 2, 7500000, 15000000);
INSERT INTO live_sales (schedule_id, host_id, sale_date, total_amount, total_items, status) VALUES (221, 4, '2026-02-15', 24750000, 3, 'completed');
INSERT INTO live_sale_items (live_sale_id, product_id, quantity, unit_price, subtotal) VALUES (221, 1, 3, 8250000, 24750000);
INSERT INTO live_sales (schedule_id, host_id, sale_date, total_amount, total_items, status) VALUES (222, 5, '2026-03-01', 8500000, 1, 'completed');
INSERT INTO live_sale_items (live_sale_id, product_id, quantity, unit_price, subtotal) VALUES (222, 2, 1, 8500000, 8500000);
INSERT INTO live_sales (schedule_id, host_id, sale_date, total_amount, total_items, status) VALUES (223, 3, '2026-02-06', 17500000, 2, 'completed');
INSERT INTO live_sale_items (live_sale_id, product_id, quantity, unit_price, subtotal) VALUES (223, 3, 2, 8750000, 17500000);
INSERT INTO live_sales (schedule_id, host_id, sale_date, total_amount, total_items, status) VALUES (224, 4, '2026-03-13', 27000000, 3, 'completed');
INSERT INTO live_sale_items (live_sale_id, product_id, quantity, unit_price, subtotal) VALUES (224, 4, 3, 9000000, 27000000);
INSERT INTO live_sales (schedule_id, host_id, sale_date, total_amount, total_items, status) VALUES (225, 5, '2026-05-10', 9250000, 1, 'completed');
INSERT INTO live_sale_items (live_sale_id, product_id, quantity, unit_price, subtotal) VALUES (225, 5, 1, 9250000, 9250000);
INSERT INTO live_sales (schedule_id, host_id, sale_date, total_amount, total_items, status) VALUES (226, 3, '2026-05-11', 19000000, 2, 'completed');
INSERT INTO live_sale_items (live_sale_id, product_id, quantity, unit_price, subtotal) VALUES (226, 6, 2, 9500000, 19000000);
INSERT INTO live_sales (schedule_id, host_id, sale_date, total_amount, total_items, status) VALUES (227, 4, '2026-02-10', 29250000, 3, 'completed');
INSERT INTO live_sale_items (live_sale_id, product_id, quantity, unit_price, subtotal) VALUES (227, 7, 3, 9750000, 29250000);
INSERT INTO live_sales (schedule_id, host_id, sale_date, total_amount, total_items, status) VALUES (228, 5, '2026-04-14', 10000000, 1, 'completed');
INSERT INTO live_sale_items (live_sale_id, product_id, quantity, unit_price, subtotal) VALUES (228, 8, 1, 10000000, 10000000);
INSERT INTO live_sales (schedule_id, host_id, sale_date, total_amount, total_items, status) VALUES (229, 3, '2026-02-14', 20500000, 2, 'completed');
INSERT INTO live_sale_items (live_sale_id, product_id, quantity, unit_price, subtotal) VALUES (229, 9, 2, 10250000, 20500000);
INSERT INTO live_sales (schedule_id, host_id, sale_date, total_amount, total_items, status) VALUES (230, 4, '2026-03-25', 31500000, 3, 'completed');
INSERT INTO live_sale_items (live_sale_id, product_id, quantity, unit_price, subtotal) VALUES (230, 10, 3, 10500000, 31500000);
INSERT INTO live_sales (schedule_id, host_id, sale_date, total_amount, total_items, status) VALUES (231, 5, '2026-02-01', 10750000, 1, 'completed');
INSERT INTO live_sale_items (live_sale_id, product_id, quantity, unit_price, subtotal) VALUES (231, 11, 1, 10750000, 10750000);
INSERT INTO live_sales (schedule_id, host_id, sale_date, total_amount, total_items, status) VALUES (232, 3, '2026-03-29', 22000000, 2, 'completed');
INSERT INTO live_sale_items (live_sale_id, product_id, quantity, unit_price, subtotal) VALUES (232, 12, 2, 11000000, 22000000);
INSERT INTO live_sales (schedule_id, host_id, sale_date, total_amount, total_items, status) VALUES (233, 4, '2026-05-10', 19350000, 3, 'completed');
INSERT INTO live_sale_items (live_sale_id, product_id, quantity, unit_price, subtotal) VALUES (233, 13, 3, 6450000, 19350000);
INSERT INTO live_sales (schedule_id, host_id, sale_date, total_amount, total_items, status) VALUES (234, 5, '2026-04-13', 6600000, 1, 'completed');
INSERT INTO live_sale_items (live_sale_id, product_id, quantity, unit_price, subtotal) VALUES (234, 14, 1, 6600000, 6600000);
INSERT INTO live_sales (schedule_id, host_id, sale_date, total_amount, total_items, status) VALUES (235, 3, '2026-04-25', 13500000, 2, 'completed');
INSERT INTO live_sale_items (live_sale_id, product_id, quantity, unit_price, subtotal) VALUES (235, 15, 2, 6750000, 13500000);
INSERT INTO live_sales (schedule_id, host_id, sale_date, total_amount, total_items, status) VALUES (236, 4, '2026-05-21', 20700000, 3, 'completed');
INSERT INTO live_sale_items (live_sale_id, product_id, quantity, unit_price, subtotal) VALUES (236, 16, 3, 6900000, 20700000);
INSERT INTO live_sales (schedule_id, host_id, sale_date, total_amount, total_items, status) VALUES (237, 5, '2026-04-18', 7050000, 1, 'completed');
INSERT INTO live_sale_items (live_sale_id, product_id, quantity, unit_price, subtotal) VALUES (237, 17, 1, 7050000, 7050000);
INSERT INTO live_sales (schedule_id, host_id, sale_date, total_amount, total_items, status) VALUES (238, 3, '2026-03-28', 14400000, 2, 'completed');
INSERT INTO live_sale_items (live_sale_id, product_id, quantity, unit_price, subtotal) VALUES (238, 18, 2, 7200000, 14400000);
INSERT INTO live_sales (schedule_id, host_id, sale_date, total_amount, total_items, status) VALUES (239, 4, '2026-02-02', 22050000, 3, 'completed');
INSERT INTO live_sale_items (live_sale_id, product_id, quantity, unit_price, subtotal) VALUES (239, 19, 3, 7350000, 22050000);
INSERT INTO live_sales (schedule_id, host_id, sale_date, total_amount, total_items, status) VALUES (240, 5, '2026-05-26', 7500000, 1, 'completed');
INSERT INTO live_sale_items (live_sale_id, product_id, quantity, unit_price, subtotal) VALUES (240, 20, 1, 7500000, 7500000);
INSERT INTO live_sales (schedule_id, host_id, sale_date, total_amount, total_items, status) VALUES (241, 3, '2026-03-23', 16500000, 2, 'completed');
INSERT INTO live_sale_items (live_sale_id, product_id, quantity, unit_price, subtotal) VALUES (241, 1, 2, 8250000, 16500000);
INSERT INTO live_sales (schedule_id, host_id, sale_date, total_amount, total_items, status) VALUES (242, 4, '2026-02-22', 25500000, 3, 'completed');
INSERT INTO live_sale_items (live_sale_id, product_id, quantity, unit_price, subtotal) VALUES (242, 2, 3, 8500000, 25500000);
INSERT INTO live_sales (schedule_id, host_id, sale_date, total_amount, total_items, status) VALUES (243, 5, '2026-02-17', 8750000, 1, 'completed');
INSERT INTO live_sale_items (live_sale_id, product_id, quantity, unit_price, subtotal) VALUES (243, 3, 1, 8750000, 8750000);
INSERT INTO live_sales (schedule_id, host_id, sale_date, total_amount, total_items, status) VALUES (244, 3, '2026-03-29', 18000000, 2, 'completed');
INSERT INTO live_sale_items (live_sale_id, product_id, quantity, unit_price, subtotal) VALUES (244, 4, 2, 9000000, 18000000);
INSERT INTO live_sales (schedule_id, host_id, sale_date, total_amount, total_items, status) VALUES (245, 4, '2026-04-23', 27750000, 3, 'completed');
INSERT INTO live_sale_items (live_sale_id, product_id, quantity, unit_price, subtotal) VALUES (245, 5, 3, 9250000, 27750000);
INSERT INTO live_sales (schedule_id, host_id, sale_date, total_amount, total_items, status) VALUES (246, 5, '2026-05-04', 9500000, 1, 'completed');
INSERT INTO live_sale_items (live_sale_id, product_id, quantity, unit_price, subtotal) VALUES (246, 6, 1, 9500000, 9500000);
INSERT INTO live_sales (schedule_id, host_id, sale_date, total_amount, total_items, status) VALUES (247, 3, '2026-04-24', 19500000, 2, 'completed');
INSERT INTO live_sale_items (live_sale_id, product_id, quantity, unit_price, subtotal) VALUES (247, 7, 2, 9750000, 19500000);
INSERT INTO live_sales (schedule_id, host_id, sale_date, total_amount, total_items, status) VALUES (248, 4, '2026-05-20', 30000000, 3, 'completed');
INSERT INTO live_sale_items (live_sale_id, product_id, quantity, unit_price, subtotal) VALUES (248, 8, 3, 10000000, 30000000);
INSERT INTO live_sales (schedule_id, host_id, sale_date, total_amount, total_items, status) VALUES (249, 5, '2026-02-25', 10250000, 1, 'completed');
INSERT INTO live_sale_items (live_sale_id, product_id, quantity, unit_price, subtotal) VALUES (249, 9, 1, 10250000, 10250000);
INSERT INTO live_sales (schedule_id, host_id, sale_date, total_amount, total_items, status) VALUES (250, 3, '2026-02-06', 21000000, 2, 'completed');
INSERT INTO live_sale_items (live_sale_id, product_id, quantity, unit_price, subtotal) VALUES (250, 10, 2, 10500000, 21000000);
INSERT INTO live_sales (schedule_id, host_id, sale_date, total_amount, total_items, status) VALUES (251, 4, '2026-05-26', 32250000, 3, 'completed');
INSERT INTO live_sale_items (live_sale_id, product_id, quantity, unit_price, subtotal) VALUES (251, 11, 3, 10750000, 32250000);
INSERT INTO live_sales (schedule_id, host_id, sale_date, total_amount, total_items, status) VALUES (252, 5, '2026-05-28', 11000000, 1, 'completed');
INSERT INTO live_sale_items (live_sale_id, product_id, quantity, unit_price, subtotal) VALUES (252, 12, 1, 11000000, 11000000);
INSERT INTO live_sales (schedule_id, host_id, sale_date, total_amount, total_items, status) VALUES (253, 3, '2026-05-19', 12900000, 2, 'completed');
INSERT INTO live_sale_items (live_sale_id, product_id, quantity, unit_price, subtotal) VALUES (253, 13, 2, 6450000, 12900000);
INSERT INTO live_sales (schedule_id, host_id, sale_date, total_amount, total_items, status) VALUES (254, 4, '2026-02-18', 19800000, 3, 'completed');
INSERT INTO live_sale_items (live_sale_id, product_id, quantity, unit_price, subtotal) VALUES (254, 14, 3, 6600000, 19800000);
INSERT INTO live_sales (schedule_id, host_id, sale_date, total_amount, total_items, status) VALUES (255, 5, '2026-03-13', 6750000, 1, 'completed');
INSERT INTO live_sale_items (live_sale_id, product_id, quantity, unit_price, subtotal) VALUES (255, 15, 1, 6750000, 6750000);
INSERT INTO live_sales (schedule_id, host_id, sale_date, total_amount, total_items, status) VALUES (256, 3, '2026-02-11', 13800000, 2, 'completed');
INSERT INTO live_sale_items (live_sale_id, product_id, quantity, unit_price, subtotal) VALUES (256, 16, 2, 6900000, 13800000);
INSERT INTO live_sales (schedule_id, host_id, sale_date, total_amount, total_items, status) VALUES (257, 4, '2026-03-02', 21150000, 3, 'completed');
INSERT INTO live_sale_items (live_sale_id, product_id, quantity, unit_price, subtotal) VALUES (257, 17, 3, 7050000, 21150000);
INSERT INTO live_sales (schedule_id, host_id, sale_date, total_amount, total_items, status) VALUES (258, 5, '2026-04-26', 7200000, 1, 'completed');
INSERT INTO live_sale_items (live_sale_id, product_id, quantity, unit_price, subtotal) VALUES (258, 18, 1, 7200000, 7200000);
INSERT INTO live_sales (schedule_id, host_id, sale_date, total_amount, total_items, status) VALUES (259, 3, '2026-03-01', 14700000, 2, 'completed');
INSERT INTO live_sale_items (live_sale_id, product_id, quantity, unit_price, subtotal) VALUES (259, 19, 2, 7350000, 14700000);
INSERT INTO live_sales (schedule_id, host_id, sale_date, total_amount, total_items, status) VALUES (260, 4, '2026-04-30', 22500000, 3, 'completed');
INSERT INTO live_sale_items (live_sale_id, product_id, quantity, unit_price, subtotal) VALUES (260, 20, 3, 7500000, 22500000);
INSERT INTO live_sales (schedule_id, host_id, sale_date, total_amount, total_items, status) VALUES (261, 5, '2026-02-10', 8250000, 1, 'completed');
INSERT INTO live_sale_items (live_sale_id, product_id, quantity, unit_price, subtotal) VALUES (261, 1, 1, 8250000, 8250000);
INSERT INTO live_sales (schedule_id, host_id, sale_date, total_amount, total_items, status) VALUES (262, 3, '2026-02-25', 17000000, 2, 'completed');
INSERT INTO live_sale_items (live_sale_id, product_id, quantity, unit_price, subtotal) VALUES (262, 2, 2, 8500000, 17000000);
INSERT INTO live_sales (schedule_id, host_id, sale_date, total_amount, total_items, status) VALUES (263, 4, '2026-02-22', 26250000, 3, 'completed');
INSERT INTO live_sale_items (live_sale_id, product_id, quantity, unit_price, subtotal) VALUES (263, 3, 3, 8750000, 26250000);
INSERT INTO live_sales (schedule_id, host_id, sale_date, total_amount, total_items, status) VALUES (264, 5, '2026-05-17', 9000000, 1, 'completed');
INSERT INTO live_sale_items (live_sale_id, product_id, quantity, unit_price, subtotal) VALUES (264, 4, 1, 9000000, 9000000);
INSERT INTO live_sales (schedule_id, host_id, sale_date, total_amount, total_items, status) VALUES (265, 3, '2026-04-03', 18500000, 2, 'completed');
INSERT INTO live_sale_items (live_sale_id, product_id, quantity, unit_price, subtotal) VALUES (265, 5, 2, 9250000, 18500000);
INSERT INTO live_sales (schedule_id, host_id, sale_date, total_amount, total_items, status) VALUES (266, 4, '2026-05-01', 28500000, 3, 'completed');
INSERT INTO live_sale_items (live_sale_id, product_id, quantity, unit_price, subtotal) VALUES (266, 6, 3, 9500000, 28500000);
INSERT INTO live_sales (schedule_id, host_id, sale_date, total_amount, total_items, status) VALUES (267, 5, '2026-02-12', 9750000, 1, 'completed');
INSERT INTO live_sale_items (live_sale_id, product_id, quantity, unit_price, subtotal) VALUES (267, 7, 1, 9750000, 9750000);
INSERT INTO live_sales (schedule_id, host_id, sale_date, total_amount, total_items, status) VALUES (268, 3, '2026-04-09', 20000000, 2, 'completed');
INSERT INTO live_sale_items (live_sale_id, product_id, quantity, unit_price, subtotal) VALUES (268, 8, 2, 10000000, 20000000);
INSERT INTO live_sales (schedule_id, host_id, sale_date, total_amount, total_items, status) VALUES (269, 4, '2026-03-20', 30750000, 3, 'completed');
INSERT INTO live_sale_items (live_sale_id, product_id, quantity, unit_price, subtotal) VALUES (269, 9, 3, 10250000, 30750000);
INSERT INTO live_sales (schedule_id, host_id, sale_date, total_amount, total_items, status) VALUES (270, 5, '2026-05-22', 10500000, 1, 'completed');
INSERT INTO live_sale_items (live_sale_id, product_id, quantity, unit_price, subtotal) VALUES (270, 10, 1, 10500000, 10500000);
INSERT INTO live_sales (schedule_id, host_id, sale_date, total_amount, total_items, status) VALUES (271, 3, '2026-04-01', 21500000, 2, 'completed');
INSERT INTO live_sale_items (live_sale_id, product_id, quantity, unit_price, subtotal) VALUES (271, 11, 2, 10750000, 21500000);
INSERT INTO live_sales (schedule_id, host_id, sale_date, total_amount, total_items, status) VALUES (272, 4, '2026-02-26', 33000000, 3, 'completed');
INSERT INTO live_sale_items (live_sale_id, product_id, quantity, unit_price, subtotal) VALUES (272, 12, 3, 11000000, 33000000);
INSERT INTO live_sales (schedule_id, host_id, sale_date, total_amount, total_items, status) VALUES (273, 5, '2026-04-04', 6450000, 1, 'completed');
INSERT INTO live_sale_items (live_sale_id, product_id, quantity, unit_price, subtotal) VALUES (273, 13, 1, 6450000, 6450000);
INSERT INTO live_sales (schedule_id, host_id, sale_date, total_amount, total_items, status) VALUES (274, 3, '2026-03-28', 13200000, 2, 'completed');
INSERT INTO live_sale_items (live_sale_id, product_id, quantity, unit_price, subtotal) VALUES (274, 14, 2, 6600000, 13200000);
INSERT INTO live_sales (schedule_id, host_id, sale_date, total_amount, total_items, status) VALUES (275, 4, '2026-05-22', 20250000, 3, 'completed');
INSERT INTO live_sale_items (live_sale_id, product_id, quantity, unit_price, subtotal) VALUES (275, 15, 3, 6750000, 20250000);
INSERT INTO live_sales (schedule_id, host_id, sale_date, total_amount, total_items, status) VALUES (276, 5, '2026-04-01', 6900000, 1, 'completed');
INSERT INTO live_sale_items (live_sale_id, product_id, quantity, unit_price, subtotal) VALUES (276, 16, 1, 6900000, 6900000);
INSERT INTO live_sales (schedule_id, host_id, sale_date, total_amount, total_items, status) VALUES (277, 3, '2026-02-26', 14100000, 2, 'completed');
INSERT INTO live_sale_items (live_sale_id, product_id, quantity, unit_price, subtotal) VALUES (277, 17, 2, 7050000, 14100000);
INSERT INTO live_sales (schedule_id, host_id, sale_date, total_amount, total_items, status) VALUES (278, 4, '2026-04-11', 21600000, 3, 'completed');
INSERT INTO live_sale_items (live_sale_id, product_id, quantity, unit_price, subtotal) VALUES (278, 18, 3, 7200000, 21600000);
INSERT INTO live_sales (schedule_id, host_id, sale_date, total_amount, total_items, status) VALUES (279, 5, '2026-02-13', 7350000, 1, 'completed');
INSERT INTO live_sale_items (live_sale_id, product_id, quantity, unit_price, subtotal) VALUES (279, 19, 1, 7350000, 7350000);
INSERT INTO live_sales (schedule_id, host_id, sale_date, total_amount, total_items, status) VALUES (280, 3, '2026-04-05', 15000000, 2, 'completed');
INSERT INTO live_sale_items (live_sale_id, product_id, quantity, unit_price, subtotal) VALUES (280, 20, 2, 7500000, 15000000);
INSERT INTO live_sales (schedule_id, host_id, sale_date, total_amount, total_items, status) VALUES (281, 4, '2026-03-30', 24750000, 3, 'completed');
INSERT INTO live_sale_items (live_sale_id, product_id, quantity, unit_price, subtotal) VALUES (281, 1, 3, 8250000, 24750000);
INSERT INTO live_sales (schedule_id, host_id, sale_date, total_amount, total_items, status) VALUES (282, 5, '2026-02-06', 8500000, 1, 'completed');
INSERT INTO live_sale_items (live_sale_id, product_id, quantity, unit_price, subtotal) VALUES (282, 2, 1, 8500000, 8500000);
INSERT INTO live_sales (schedule_id, host_id, sale_date, total_amount, total_items, status) VALUES (283, 3, '2026-04-11', 17500000, 2, 'completed');
INSERT INTO live_sale_items (live_sale_id, product_id, quantity, unit_price, subtotal) VALUES (283, 3, 2, 8750000, 17500000);
INSERT INTO live_sales (schedule_id, host_id, sale_date, total_amount, total_items, status) VALUES (284, 4, '2026-05-28', 27000000, 3, 'completed');
INSERT INTO live_sale_items (live_sale_id, product_id, quantity, unit_price, subtotal) VALUES (284, 4, 3, 9000000, 27000000);
INSERT INTO live_sales (schedule_id, host_id, sale_date, total_amount, total_items, status) VALUES (285, 5, '2026-02-28', 9250000, 1, 'completed');
INSERT INTO live_sale_items (live_sale_id, product_id, quantity, unit_price, subtotal) VALUES (285, 5, 1, 9250000, 9250000);
INSERT INTO live_sales (schedule_id, host_id, sale_date, total_amount, total_items, status) VALUES (286, 3, '2026-05-28', 19000000, 2, 'completed');
INSERT INTO live_sale_items (live_sale_id, product_id, quantity, unit_price, subtotal) VALUES (286, 6, 2, 9500000, 19000000);
INSERT INTO live_sales (schedule_id, host_id, sale_date, total_amount, total_items, status) VALUES (287, 4, '2026-05-04', 29250000, 3, 'completed');
INSERT INTO live_sale_items (live_sale_id, product_id, quantity, unit_price, subtotal) VALUES (287, 7, 3, 9750000, 29250000);
INSERT INTO live_sales (schedule_id, host_id, sale_date, total_amount, total_items, status) VALUES (288, 5, '2026-04-15', 10000000, 1, 'completed');
INSERT INTO live_sale_items (live_sale_id, product_id, quantity, unit_price, subtotal) VALUES (288, 8, 1, 10000000, 10000000);
INSERT INTO live_sales (schedule_id, host_id, sale_date, total_amount, total_items, status) VALUES (289, 3, '2026-03-29', 20500000, 2, 'completed');
INSERT INTO live_sale_items (live_sale_id, product_id, quantity, unit_price, subtotal) VALUES (289, 9, 2, 10250000, 20500000);
INSERT INTO live_sales (schedule_id, host_id, sale_date, total_amount, total_items, status) VALUES (290, 4, '2026-02-08', 31500000, 3, 'completed');
INSERT INTO live_sale_items (live_sale_id, product_id, quantity, unit_price, subtotal) VALUES (290, 10, 3, 10500000, 31500000);
INSERT INTO live_sales (schedule_id, host_id, sale_date, total_amount, total_items, status) VALUES (291, 5, '2026-02-02', 10750000, 1, 'completed');
INSERT INTO live_sale_items (live_sale_id, product_id, quantity, unit_price, subtotal) VALUES (291, 11, 1, 10750000, 10750000);
INSERT INTO live_sales (schedule_id, host_id, sale_date, total_amount, total_items, status) VALUES (292, 3, '2026-04-28', 22000000, 2, 'completed');
INSERT INTO live_sale_items (live_sale_id, product_id, quantity, unit_price, subtotal) VALUES (292, 12, 2, 11000000, 22000000);
INSERT INTO live_sales (schedule_id, host_id, sale_date, total_amount, total_items, status) VALUES (293, 4, '2026-02-19', 19350000, 3, 'completed');
INSERT INTO live_sale_items (live_sale_id, product_id, quantity, unit_price, subtotal) VALUES (293, 13, 3, 6450000, 19350000);
INSERT INTO live_sales (schedule_id, host_id, sale_date, total_amount, total_items, status) VALUES (294, 5, '2026-05-05', 6600000, 1, 'completed');
INSERT INTO live_sale_items (live_sale_id, product_id, quantity, unit_price, subtotal) VALUES (294, 14, 1, 6600000, 6600000);
INSERT INTO live_sales (schedule_id, host_id, sale_date, total_amount, total_items, status) VALUES (295, 3, '2026-02-19', 13500000, 2, 'completed');
INSERT INTO live_sale_items (live_sale_id, product_id, quantity, unit_price, subtotal) VALUES (295, 15, 2, 6750000, 13500000);
INSERT INTO live_sales (schedule_id, host_id, sale_date, total_amount, total_items, status) VALUES (296, 4, '2026-03-29', 20700000, 3, 'completed');
INSERT INTO live_sale_items (live_sale_id, product_id, quantity, unit_price, subtotal) VALUES (296, 16, 3, 6900000, 20700000);
INSERT INTO live_sales (schedule_id, host_id, sale_date, total_amount, total_items, status) VALUES (297, 5, '2026-03-01', 7050000, 1, 'completed');
INSERT INTO live_sale_items (live_sale_id, product_id, quantity, unit_price, subtotal) VALUES (297, 17, 1, 7050000, 7050000);
INSERT INTO live_sales (schedule_id, host_id, sale_date, total_amount, total_items, status) VALUES (298, 3, '2026-02-09', 14400000, 2, 'completed');
INSERT INTO live_sale_items (live_sale_id, product_id, quantity, unit_price, subtotal) VALUES (298, 18, 2, 7200000, 14400000);
INSERT INTO live_sales (schedule_id, host_id, sale_date, total_amount, total_items, status) VALUES (299, 4, '2026-04-14', 22050000, 3, 'completed');
INSERT INTO live_sale_items (live_sale_id, product_id, quantity, unit_price, subtotal) VALUES (299, 19, 3, 7350000, 22050000);
INSERT INTO live_sales (schedule_id, host_id, sale_date, total_amount, total_items, status) VALUES (300, 5, '2026-05-04', 7500000, 1, 'completed');
INSERT INTO live_sale_items (live_sale_id, product_id, quantity, unit_price, subtotal) VALUES (300, 20, 1, 7500000, 7500000);
INSERT INTO live_sales (schedule_id, host_id, sale_date, total_amount, total_items, status) VALUES (301, 3, '2026-02-01', 16500000, 2, 'completed');
INSERT INTO live_sale_items (live_sale_id, product_id, quantity, unit_price, subtotal) VALUES (301, 1, 2, 8250000, 16500000);
INSERT INTO live_sales (schedule_id, host_id, sale_date, total_amount, total_items, status) VALUES (302, 4, '2026-02-03', 25500000, 3, 'completed');
INSERT INTO live_sale_items (live_sale_id, product_id, quantity, unit_price, subtotal) VALUES (302, 2, 3, 8500000, 25500000);
INSERT INTO live_sales (schedule_id, host_id, sale_date, total_amount, total_items, status) VALUES (303, 5, '2026-05-11', 8750000, 1, 'completed');
INSERT INTO live_sale_items (live_sale_id, product_id, quantity, unit_price, subtotal) VALUES (303, 3, 1, 8750000, 8750000);
INSERT INTO live_sales (schedule_id, host_id, sale_date, total_amount, total_items, status) VALUES (304, 3, '2026-02-10', 18000000, 2, 'completed');
INSERT INTO live_sale_items (live_sale_id, product_id, quantity, unit_price, subtotal) VALUES (304, 4, 2, 9000000, 18000000);
INSERT INTO live_sales (schedule_id, host_id, sale_date, total_amount, total_items, status) VALUES (305, 4, '2026-05-15', 27750000, 3, 'completed');
INSERT INTO live_sale_items (live_sale_id, product_id, quantity, unit_price, subtotal) VALUES (305, 5, 3, 9250000, 27750000);
INSERT INTO live_sales (schedule_id, host_id, sale_date, total_amount, total_items, status) VALUES (306, 5, '2026-03-01', 9500000, 1, 'completed');
INSERT INTO live_sale_items (live_sale_id, product_id, quantity, unit_price, subtotal) VALUES (306, 6, 1, 9500000, 9500000);
INSERT INTO live_sales (schedule_id, host_id, sale_date, total_amount, total_items, status) VALUES (307, 3, '2026-03-15', 19500000, 2, 'completed');
INSERT INTO live_sale_items (live_sale_id, product_id, quantity, unit_price, subtotal) VALUES (307, 7, 2, 9750000, 19500000);
INSERT INTO live_sales (schedule_id, host_id, sale_date, total_amount, total_items, status) VALUES (308, 4, '2026-02-17', 30000000, 3, 'completed');
INSERT INTO live_sale_items (live_sale_id, product_id, quantity, unit_price, subtotal) VALUES (308, 8, 3, 10000000, 30000000);
INSERT INTO live_sales (schedule_id, host_id, sale_date, total_amount, total_items, status) VALUES (309, 5, '2026-05-20', 10250000, 1, 'completed');
INSERT INTO live_sale_items (live_sale_id, product_id, quantity, unit_price, subtotal) VALUES (309, 9, 1, 10250000, 10250000);
INSERT INTO live_sales (schedule_id, host_id, sale_date, total_amount, total_items, status) VALUES (310, 3, '2026-04-15', 21000000, 2, 'completed');
INSERT INTO live_sale_items (live_sale_id, product_id, quantity, unit_price, subtotal) VALUES (310, 10, 2, 10500000, 21000000);
INSERT INTO live_sales (schedule_id, host_id, sale_date, total_amount, total_items, status) VALUES (311, 4, '2026-05-29', 32250000, 3, 'completed');
INSERT INTO live_sale_items (live_sale_id, product_id, quantity, unit_price, subtotal) VALUES (311, 11, 3, 10750000, 32250000);
INSERT INTO live_sales (schedule_id, host_id, sale_date, total_amount, total_items, status) VALUES (312, 5, '2026-02-24', 11000000, 1, 'completed');
INSERT INTO live_sale_items (live_sale_id, product_id, quantity, unit_price, subtotal) VALUES (312, 12, 1, 11000000, 11000000);
INSERT INTO live_sales (schedule_id, host_id, sale_date, total_amount, total_items, status) VALUES (313, 3, '2026-05-28', 12900000, 2, 'completed');
INSERT INTO live_sale_items (live_sale_id, product_id, quantity, unit_price, subtotal) VALUES (313, 13, 2, 6450000, 12900000);
INSERT INTO live_sales (schedule_id, host_id, sale_date, total_amount, total_items, status) VALUES (314, 4, '2026-03-03', 19800000, 3, 'completed');
INSERT INTO live_sale_items (live_sale_id, product_id, quantity, unit_price, subtotal) VALUES (314, 14, 3, 6600000, 19800000);
INSERT INTO live_sales (schedule_id, host_id, sale_date, total_amount, total_items, status) VALUES (315, 5, '2026-04-22', 6750000, 1, 'completed');
INSERT INTO live_sale_items (live_sale_id, product_id, quantity, unit_price, subtotal) VALUES (315, 15, 1, 6750000, 6750000);
INSERT INTO live_sales (schedule_id, host_id, sale_date, total_amount, total_items, status) VALUES (316, 3, '2026-04-01', 13800000, 2, 'completed');
INSERT INTO live_sale_items (live_sale_id, product_id, quantity, unit_price, subtotal) VALUES (316, 16, 2, 6900000, 13800000);
INSERT INTO live_sales (schedule_id, host_id, sale_date, total_amount, total_items, status) VALUES (317, 4, '2026-02-07', 21150000, 3, 'completed');
INSERT INTO live_sale_items (live_sale_id, product_id, quantity, unit_price, subtotal) VALUES (317, 17, 3, 7050000, 21150000);
INSERT INTO live_sales (schedule_id, host_id, sale_date, total_amount, total_items, status) VALUES (318, 5, '2026-03-11', 7200000, 1, 'completed');
INSERT INTO live_sale_items (live_sale_id, product_id, quantity, unit_price, subtotal) VALUES (318, 18, 1, 7200000, 7200000);
INSERT INTO live_sales (schedule_id, host_id, sale_date, total_amount, total_items, status) VALUES (319, 3, '2026-04-12', 14700000, 2, 'completed');
INSERT INTO live_sale_items (live_sale_id, product_id, quantity, unit_price, subtotal) VALUES (319, 19, 2, 7350000, 14700000);
INSERT INTO live_sales (schedule_id, host_id, sale_date, total_amount, total_items, status) VALUES (320, 4, '2026-04-13', 22500000, 3, 'completed');
INSERT INTO live_sale_items (live_sale_id, product_id, quantity, unit_price, subtotal) VALUES (320, 20, 3, 7500000, 22500000);
INSERT INTO live_sales (schedule_id, host_id, sale_date, total_amount, total_items, status) VALUES (321, 5, '2026-03-27', 8250000, 1, 'completed');
INSERT INTO live_sale_items (live_sale_id, product_id, quantity, unit_price, subtotal) VALUES (321, 1, 1, 8250000, 8250000);
INSERT INTO live_sales (schedule_id, host_id, sale_date, total_amount, total_items, status) VALUES (322, 3, '2026-02-15', 17000000, 2, 'completed');
INSERT INTO live_sale_items (live_sale_id, product_id, quantity, unit_price, subtotal) VALUES (322, 2, 2, 8500000, 17000000);
INSERT INTO live_sales (schedule_id, host_id, sale_date, total_amount, total_items, status) VALUES (323, 4, '2026-03-11', 26250000, 3, 'completed');
INSERT INTO live_sale_items (live_sale_id, product_id, quantity, unit_price, subtotal) VALUES (323, 3, 3, 8750000, 26250000);
INSERT INTO live_sales (schedule_id, host_id, sale_date, total_amount, total_items, status) VALUES (324, 5, '2026-04-14', 9000000, 1, 'completed');
INSERT INTO live_sale_items (live_sale_id, product_id, quantity, unit_price, subtotal) VALUES (324, 4, 1, 9000000, 9000000);
INSERT INTO live_sales (schedule_id, host_id, sale_date, total_amount, total_items, status) VALUES (325, 3, '2026-03-20', 18500000, 2, 'completed');
INSERT INTO live_sale_items (live_sale_id, product_id, quantity, unit_price, subtotal) VALUES (325, 5, 2, 9250000, 18500000);
INSERT INTO live_sales (schedule_id, host_id, sale_date, total_amount, total_items, status) VALUES (326, 4, '2026-02-12', 28500000, 3, 'completed');
INSERT INTO live_sale_items (live_sale_id, product_id, quantity, unit_price, subtotal) VALUES (326, 6, 3, 9500000, 28500000);
INSERT INTO live_sales (schedule_id, host_id, sale_date, total_amount, total_items, status) VALUES (327, 5, '2026-03-04', 9750000, 1, 'completed');
INSERT INTO live_sale_items (live_sale_id, product_id, quantity, unit_price, subtotal) VALUES (327, 7, 1, 9750000, 9750000);
INSERT INTO live_sales (schedule_id, host_id, sale_date, total_amount, total_items, status) VALUES (328, 3, '2026-04-08', 20000000, 2, 'completed');
INSERT INTO live_sale_items (live_sale_id, product_id, quantity, unit_price, subtotal) VALUES (328, 8, 2, 10000000, 20000000);
INSERT INTO live_sales (schedule_id, host_id, sale_date, total_amount, total_items, status) VALUES (329, 4, '2026-02-07', 30750000, 3, 'completed');
INSERT INTO live_sale_items (live_sale_id, product_id, quantity, unit_price, subtotal) VALUES (329, 9, 3, 10250000, 30750000);
INSERT INTO live_sales (schedule_id, host_id, sale_date, total_amount, total_items, status) VALUES (330, 5, '2026-03-25', 10500000, 1, 'completed');
INSERT INTO live_sale_items (live_sale_id, product_id, quantity, unit_price, subtotal) VALUES (330, 10, 1, 10500000, 10500000);
INSERT INTO live_sales (schedule_id, host_id, sale_date, total_amount, total_items, status) VALUES (331, 3, '2026-02-20', 21500000, 2, 'completed');
INSERT INTO live_sale_items (live_sale_id, product_id, quantity, unit_price, subtotal) VALUES (331, 11, 2, 10750000, 21500000);
INSERT INTO live_sales (schedule_id, host_id, sale_date, total_amount, total_items, status) VALUES (332, 4, '2026-04-20', 33000000, 3, 'completed');
INSERT INTO live_sale_items (live_sale_id, product_id, quantity, unit_price, subtotal) VALUES (332, 12, 3, 11000000, 33000000);
INSERT INTO live_sales (schedule_id, host_id, sale_date, total_amount, total_items, status) VALUES (333, 5, '2026-05-14', 6450000, 1, 'completed');
INSERT INTO live_sale_items (live_sale_id, product_id, quantity, unit_price, subtotal) VALUES (333, 13, 1, 6450000, 6450000);
INSERT INTO live_sales (schedule_id, host_id, sale_date, total_amount, total_items, status) VALUES (334, 3, '2026-04-18', 13200000, 2, 'completed');
INSERT INTO live_sale_items (live_sale_id, product_id, quantity, unit_price, subtotal) VALUES (334, 14, 2, 6600000, 13200000);
INSERT INTO live_sales (schedule_id, host_id, sale_date, total_amount, total_items, status) VALUES (335, 4, '2026-02-09', 20250000, 3, 'completed');
INSERT INTO live_sale_items (live_sale_id, product_id, quantity, unit_price, subtotal) VALUES (335, 15, 3, 6750000, 20250000);
INSERT INTO live_sales (schedule_id, host_id, sale_date, total_amount, total_items, status) VALUES (336, 5, '2026-03-20', 6900000, 1, 'completed');
INSERT INTO live_sale_items (live_sale_id, product_id, quantity, unit_price, subtotal) VALUES (336, 16, 1, 6900000, 6900000);
INSERT INTO live_sales (schedule_id, host_id, sale_date, total_amount, total_items, status) VALUES (337, 3, '2026-05-16', 14100000, 2, 'completed');
INSERT INTO live_sale_items (live_sale_id, product_id, quantity, unit_price, subtotal) VALUES (337, 17, 2, 7050000, 14100000);
INSERT INTO live_sales (schedule_id, host_id, sale_date, total_amount, total_items, status) VALUES (338, 4, '2026-05-08', 21600000, 3, 'completed');
INSERT INTO live_sale_items (live_sale_id, product_id, quantity, unit_price, subtotal) VALUES (338, 18, 3, 7200000, 21600000);
INSERT INTO live_sales (schedule_id, host_id, sale_date, total_amount, total_items, status) VALUES (339, 5, '2026-04-07', 7350000, 1, 'completed');
INSERT INTO live_sale_items (live_sale_id, product_id, quantity, unit_price, subtotal) VALUES (339, 19, 1, 7350000, 7350000);
INSERT INTO live_sales (schedule_id, host_id, sale_date, total_amount, total_items, status) VALUES (340, 3, '2026-03-01', 15000000, 2, 'completed');
INSERT INTO live_sale_items (live_sale_id, product_id, quantity, unit_price, subtotal) VALUES (340, 20, 2, 7500000, 15000000);
INSERT INTO live_sales (schedule_id, host_id, sale_date, total_amount, total_items, status) VALUES (341, 4, '2026-02-06', 24750000, 3, 'completed');
INSERT INTO live_sale_items (live_sale_id, product_id, quantity, unit_price, subtotal) VALUES (341, 1, 3, 8250000, 24750000);
INSERT INTO live_sales (schedule_id, host_id, sale_date, total_amount, total_items, status) VALUES (342, 5, '2026-03-13', 8500000, 1, 'completed');
INSERT INTO live_sale_items (live_sale_id, product_id, quantity, unit_price, subtotal) VALUES (342, 2, 1, 8500000, 8500000);
INSERT INTO live_sales (schedule_id, host_id, sale_date, total_amount, total_items, status) VALUES (343, 3, '2026-02-11', 17500000, 2, 'completed');
INSERT INTO live_sale_items (live_sale_id, product_id, quantity, unit_price, subtotal) VALUES (343, 3, 2, 8750000, 17500000);
INSERT INTO live_sales (schedule_id, host_id, sale_date, total_amount, total_items, status) VALUES (344, 4, '2026-04-17', 27000000, 3, 'completed');
INSERT INTO live_sale_items (live_sale_id, product_id, quantity, unit_price, subtotal) VALUES (344, 4, 3, 9000000, 27000000);
INSERT INTO live_sales (schedule_id, host_id, sale_date, total_amount, total_items, status) VALUES (345, 5, '2026-05-12', 9250000, 1, 'completed');
INSERT INTO live_sale_items (live_sale_id, product_id, quantity, unit_price, subtotal) VALUES (345, 5, 1, 9250000, 9250000);
INSERT INTO live_sales (schedule_id, host_id, sale_date, total_amount, total_items, status) VALUES (346, 3, '2026-04-20', 19000000, 2, 'completed');
INSERT INTO live_sale_items (live_sale_id, product_id, quantity, unit_price, subtotal) VALUES (346, 6, 2, 9500000, 19000000);
INSERT INTO live_sales (schedule_id, host_id, sale_date, total_amount, total_items, status) VALUES (347, 4, '2026-05-12', 29250000, 3, 'completed');
INSERT INTO live_sale_items (live_sale_id, product_id, quantity, unit_price, subtotal) VALUES (347, 7, 3, 9750000, 29250000);
INSERT INTO live_sales (schedule_id, host_id, sale_date, total_amount, total_items, status) VALUES (348, 5, '2026-03-28', 10000000, 1, 'completed');
INSERT INTO live_sale_items (live_sale_id, product_id, quantity, unit_price, subtotal) VALUES (348, 8, 1, 10000000, 10000000);
INSERT INTO live_sales (schedule_id, host_id, sale_date, total_amount, total_items, status) VALUES (349, 3, '2026-02-25', 20500000, 2, 'completed');
INSERT INTO live_sale_items (live_sale_id, product_id, quantity, unit_price, subtotal) VALUES (349, 9, 2, 10250000, 20500000);
INSERT INTO live_sales (schedule_id, host_id, sale_date, total_amount, total_items, status) VALUES (350, 4, '2026-05-27', 31500000, 3, 'completed');
INSERT INTO live_sale_items (live_sale_id, product_id, quantity, unit_price, subtotal) VALUES (350, 10, 3, 10500000, 31500000);
INSERT INTO live_sales (schedule_id, host_id, sale_date, total_amount, total_items, status) VALUES (351, 5, '2026-04-18', 10750000, 1, 'completed');
INSERT INTO live_sale_items (live_sale_id, product_id, quantity, unit_price, subtotal) VALUES (351, 11, 1, 10750000, 10750000);
INSERT INTO live_sales (schedule_id, host_id, sale_date, total_amount, total_items, status) VALUES (352, 3, '2026-05-11', 22000000, 2, 'completed');
INSERT INTO live_sale_items (live_sale_id, product_id, quantity, unit_price, subtotal) VALUES (352, 12, 2, 11000000, 22000000);
INSERT INTO live_sales (schedule_id, host_id, sale_date, total_amount, total_items, status) VALUES (353, 4, '2026-03-04', 19350000, 3, 'completed');
INSERT INTO live_sale_items (live_sale_id, product_id, quantity, unit_price, subtotal) VALUES (353, 13, 3, 6450000, 19350000);
INSERT INTO live_sales (schedule_id, host_id, sale_date, total_amount, total_items, status) VALUES (354, 5, '2026-02-06', 6600000, 1, 'completed');
INSERT INTO live_sale_items (live_sale_id, product_id, quantity, unit_price, subtotal) VALUES (354, 14, 1, 6600000, 6600000);
INSERT INTO live_sales (schedule_id, host_id, sale_date, total_amount, total_items, status) VALUES (355, 3, '2026-02-20', 13500000, 2, 'completed');
INSERT INTO live_sale_items (live_sale_id, product_id, quantity, unit_price, subtotal) VALUES (355, 15, 2, 6750000, 13500000);
INSERT INTO live_sales (schedule_id, host_id, sale_date, total_amount, total_items, status) VALUES (356, 4, '2026-05-19', 20700000, 3, 'completed');
INSERT INTO live_sale_items (live_sale_id, product_id, quantity, unit_price, subtotal) VALUES (356, 16, 3, 6900000, 20700000);
INSERT INTO live_sales (schedule_id, host_id, sale_date, total_amount, total_items, status) VALUES (357, 5, '2026-04-24', 7050000, 1, 'completed');
INSERT INTO live_sale_items (live_sale_id, product_id, quantity, unit_price, subtotal) VALUES (357, 17, 1, 7050000, 7050000);
INSERT INTO live_sales (schedule_id, host_id, sale_date, total_amount, total_items, status) VALUES (358, 3, '2026-05-11', 14400000, 2, 'completed');
INSERT INTO live_sale_items (live_sale_id, product_id, quantity, unit_price, subtotal) VALUES (358, 18, 2, 7200000, 14400000);
INSERT INTO live_sales (schedule_id, host_id, sale_date, total_amount, total_items, status) VALUES (359, 4, '2026-05-20', 22050000, 3, 'completed');
INSERT INTO live_sale_items (live_sale_id, product_id, quantity, unit_price, subtotal) VALUES (359, 19, 3, 7350000, 22050000);
INSERT INTO live_sales (schedule_id, host_id, sale_date, total_amount, total_items, status) VALUES (360, 5, '2026-03-01', 7500000, 1, 'completed');
INSERT INTO live_sale_items (live_sale_id, product_id, quantity, unit_price, subtotal) VALUES (360, 20, 1, 7500000, 7500000);

-- SEED: Marketplace Orders (1000+)
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00001', 1, 1, '2026-04-14 09:57:14', 'delivered', 16500000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (1, 1, 2, 8250000, 16500000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00002', 2, 2, '2026-05-11 13:30:15', 'delivered', 8500000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (2, 2, 1, 8500000, 8500000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00003', 3, 3, '2026-04-07 15:08:52', 'delivered', 17500000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (3, 3, 2, 8750000, 17500000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00004', 4, 4, '2026-04-29 23:32:57', 'delivered', 9000000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (4, 4, 1, 9000000, 9000000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00005', 5, 1, '2026-02-05 09:24:33', 'delivered', 18500000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (5, 5, 2, 9250000, 18500000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00006', 6, 2, '2026-05-25 10:29:35', 'delivered', 9500000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (6, 6, 1, 9500000, 9500000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00007', 7, 3, '2026-02-19 23:22:38', 'delivered', 19500000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (7, 7, 2, 9750000, 19500000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00008', 8, 4, '2026-04-21 11:23:33', 'delivered', 10000000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (8, 8, 1, 10000000, 10000000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00009', 9, 1, '2026-05-17 02:18:34', 'delivered', 20500000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (9, 9, 2, 10250000, 20500000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00010', 10, 2, '2026-04-06 06:42:35', 'delivered', 10500000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (10, 10, 1, 10500000, 10500000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00011', 11, 3, '2026-05-16 17:44:39', 'delivered', 21500000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (11, 11, 2, 10750000, 21500000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00012', 12, 4, '2026-02-23 13:46:47', 'delivered', 11000000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (12, 12, 1, 11000000, 11000000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00013', 13, 1, '2026-03-01 21:03:45', 'delivered', 12900000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (13, 13, 2, 6450000, 12900000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00014', 14, 2, '2026-03-16 20:41:48', 'delivered', 6600000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (14, 14, 1, 6600000, 6600000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00015', 15, 3, '2026-05-08 12:45:21', 'delivered', 13500000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (15, 15, 2, 6750000, 13500000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00016', 16, 4, '2026-05-02 07:01:57', 'delivered', 6900000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (16, 16, 1, 6900000, 6900000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00017', 17, 1, '2026-04-29 06:42:08', 'delivered', 14100000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (17, 17, 2, 7050000, 14100000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00018', 18, 2, '2026-05-06 10:39:35', 'delivered', 7200000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (18, 18, 1, 7200000, 7200000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00019', 19, 3, '2026-03-25 21:01:23', 'delivered', 14700000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (19, 19, 2, 7350000, 14700000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00020', 20, 4, '2026-02-03 06:25:16', 'delivered', 7500000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (20, 20, 1, 7500000, 7500000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00021', 21, 1, '2026-04-26 10:51:35', 'delivered', 16500000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (21, 1, 2, 8250000, 16500000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00022', 22, 2, '2026-04-20 00:11:06', 'delivered', 8500000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (22, 2, 1, 8500000, 8500000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00023', 23, 3, '2026-05-13 11:41:35', 'delivered', 17500000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (23, 3, 2, 8750000, 17500000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00024', 24, 4, '2026-05-12 21:27:04', 'delivered', 9000000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (24, 4, 1, 9000000, 9000000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00025', 25, 1, '2026-03-11 05:50:54', 'delivered', 18500000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (25, 5, 2, 9250000, 18500000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00026', 26, 2, '2026-05-22 13:54:12', 'delivered', 9500000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (26, 6, 1, 9500000, 9500000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00027', 27, 3, '2026-03-21 23:30:27', 'delivered', 19500000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (27, 7, 2, 9750000, 19500000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00028', 28, 4, '2026-05-03 00:16:00', 'delivered', 10000000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (28, 8, 1, 10000000, 10000000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00029', 29, 1, '2026-05-17 11:08:36', 'delivered', 20500000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (29, 9, 2, 10250000, 20500000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00030', 30, 2, '2026-05-29 20:05:47', 'delivered', 10500000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (30, 10, 1, 10500000, 10500000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00031', 31, 3, '2026-04-20 05:08:53', 'delivered', 21500000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (31, 11, 2, 10750000, 21500000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00032', 32, 4, '2026-03-16 11:25:58', 'delivered', 11000000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (32, 12, 1, 11000000, 11000000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00033', 33, 1, '2026-04-01 03:02:05', 'delivered', 12900000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (33, 13, 2, 6450000, 12900000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00034', 34, 2, '2026-03-01 02:01:41', 'delivered', 6600000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (34, 14, 1, 6600000, 6600000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00035', 35, 3, '2026-03-28 09:12:55', 'delivered', 13500000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (35, 15, 2, 6750000, 13500000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00036', 36, 4, '2026-03-29 09:35:01', 'delivered', 6900000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (36, 16, 1, 6900000, 6900000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00037', 37, 1, '2026-03-09 22:01:35', 'delivered', 14100000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (37, 17, 2, 7050000, 14100000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00038', 38, 2, '2026-05-09 08:54:33', 'delivered', 7200000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (38, 18, 1, 7200000, 7200000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00039', 39, 3, '2026-05-14 00:59:52', 'delivered', 14700000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (39, 19, 2, 7350000, 14700000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00040', 40, 4, '2026-02-02 04:07:35', 'delivered', 7500000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (40, 20, 1, 7500000, 7500000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00041', 41, 1, '2026-03-25 02:46:51', 'delivered', 16500000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (41, 1, 2, 8250000, 16500000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00042', 42, 2, '2026-05-15 06:11:44', 'delivered', 8500000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (42, 2, 1, 8500000, 8500000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00043', 43, 3, '2026-05-20 09:07:20', 'delivered', 17500000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (43, 3, 2, 8750000, 17500000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00044', 44, 4, '2026-04-03 19:39:33', 'delivered', 9000000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (44, 4, 1, 9000000, 9000000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00045', 45, 1, '2026-02-16 23:50:51', 'delivered', 18500000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (45, 5, 2, 9250000, 18500000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00046', 46, 2, '2026-05-29 20:30:02', 'delivered', 9500000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (46, 6, 1, 9500000, 9500000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00047', 47, 3, '2026-04-10 11:07:19', 'delivered', 19500000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (47, 7, 2, 9750000, 19500000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00048', 48, 4, '2026-05-11 05:41:57', 'delivered', 10000000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (48, 8, 1, 10000000, 10000000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00049', 49, 1, '2026-04-07 02:15:31', 'delivered', 20500000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (49, 9, 2, 10250000, 20500000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00050', 50, 2, '2026-03-11 11:08:23', 'delivered', 10500000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (50, 10, 1, 10500000, 10500000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00051', 51, 3, '2026-05-11 17:32:38', 'delivered', 21500000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (51, 11, 2, 10750000, 21500000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00052', 52, 4, '2026-04-27 06:46:53', 'delivered', 11000000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (52, 12, 1, 11000000, 11000000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00053', 53, 1, '2026-02-05 14:16:32', 'delivered', 12900000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (53, 13, 2, 6450000, 12900000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00054', 54, 2, '2026-02-13 21:37:47', 'delivered', 6600000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (54, 14, 1, 6600000, 6600000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00055', 55, 3, '2026-04-14 01:21:35', 'delivered', 13500000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (55, 15, 2, 6750000, 13500000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00056', 56, 4, '2026-02-20 02:32:59', 'delivered', 6900000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (56, 16, 1, 6900000, 6900000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00057', 57, 1, '2026-03-09 11:13:17', 'delivered', 14100000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (57, 17, 2, 7050000, 14100000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00058', 58, 2, '2026-04-16 16:13:46', 'delivered', 7200000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (58, 18, 1, 7200000, 7200000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00059', 59, 3, '2026-05-01 03:05:00', 'delivered', 14700000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (59, 19, 2, 7350000, 14700000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00060', 60, 4, '2026-02-17 11:19:12', 'delivered', 7500000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (60, 20, 1, 7500000, 7500000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00061', 61, 1, '2026-02-20 16:06:33', 'delivered', 16500000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (61, 1, 2, 8250000, 16500000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00062', 62, 2, '2026-03-19 04:18:12', 'delivered', 8500000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (62, 2, 1, 8500000, 8500000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00063', 63, 3, '2026-03-02 15:39:13', 'delivered', 17500000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (63, 3, 2, 8750000, 17500000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00064', 64, 4, '2026-04-21 15:51:27', 'delivered', 9000000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (64, 4, 1, 9000000, 9000000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00065', 65, 1, '2026-05-04 18:01:21', 'delivered', 18500000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (65, 5, 2, 9250000, 18500000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00066', 66, 2, '2026-03-18 02:11:30', 'delivered', 9500000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (66, 6, 1, 9500000, 9500000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00067', 67, 3, '2026-02-02 17:21:09', 'delivered', 19500000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (67, 7, 2, 9750000, 19500000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00068', 68, 4, '2026-03-05 07:49:22', 'delivered', 10000000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (68, 8, 1, 10000000, 10000000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00069', 69, 1, '2026-03-15 04:36:05', 'delivered', 20500000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (69, 9, 2, 10250000, 20500000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00070', 70, 2, '2026-03-13 02:18:30', 'delivered', 10500000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (70, 10, 1, 10500000, 10500000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00071', 71, 3, '2026-02-18 16:03:18', 'delivered', 21500000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (71, 11, 2, 10750000, 21500000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00072', 72, 4, '2026-02-27 09:07:20', 'delivered', 11000000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (72, 12, 1, 11000000, 11000000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00073', 73, 1, '2026-02-17 23:28:07', 'delivered', 12900000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (73, 13, 2, 6450000, 12900000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00074', 74, 2, '2026-05-13 01:53:40', 'delivered', 6600000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (74, 14, 1, 6600000, 6600000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00075', 75, 3, '2026-02-04 13:43:27', 'delivered', 13500000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (75, 15, 2, 6750000, 13500000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00076', 76, 4, '2026-05-15 15:30:31', 'delivered', 6900000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (76, 16, 1, 6900000, 6900000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00077', 77, 1, '2026-04-14 14:06:08', 'delivered', 14100000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (77, 17, 2, 7050000, 14100000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00078', 78, 2, '2026-04-29 06:54:47', 'delivered', 7200000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (78, 18, 1, 7200000, 7200000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00079', 79, 3, '2026-03-05 12:38:27', 'delivered', 14700000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (79, 19, 2, 7350000, 14700000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00080', 80, 4, '2026-05-18 00:35:33', 'delivered', 7500000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (80, 20, 1, 7500000, 7500000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00081', 81, 1, '2026-02-09 22:47:09', 'delivered', 16500000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (81, 1, 2, 8250000, 16500000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00082', 82, 2, '2026-04-16 18:09:51', 'delivered', 8500000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (82, 2, 1, 8500000, 8500000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00083', 83, 3, '2026-05-22 23:40:52', 'delivered', 17500000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (83, 3, 2, 8750000, 17500000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00084', 84, 4, '2026-02-14 12:14:50', 'delivered', 9000000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (84, 4, 1, 9000000, 9000000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00085', 85, 1, '2026-02-28 17:51:54', 'delivered', 18500000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (85, 5, 2, 9250000, 18500000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00086', 86, 2, '2026-03-10 01:48:51', 'delivered', 9500000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (86, 6, 1, 9500000, 9500000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00087', 87, 3, '2026-04-23 00:26:52', 'delivered', 19500000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (87, 7, 2, 9750000, 19500000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00088', 88, 4, '2026-02-18 19:02:43', 'delivered', 10000000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (88, 8, 1, 10000000, 10000000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00089', 89, 1, '2026-02-03 19:37:38', 'delivered', 20500000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (89, 9, 2, 10250000, 20500000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00090', 90, 2, '2026-03-28 18:09:14', 'delivered', 10500000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (90, 10, 1, 10500000, 10500000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00091', 91, 3, '2026-03-16 03:46:14', 'delivered', 21500000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (91, 11, 2, 10750000, 21500000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00092', 92, 4, '2026-04-16 13:12:51', 'delivered', 11000000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (92, 12, 1, 11000000, 11000000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00093', 93, 1, '2026-03-27 22:03:42', 'delivered', 12900000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (93, 13, 2, 6450000, 12900000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00094', 94, 2, '2026-03-06 11:46:23', 'delivered', 6600000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (94, 14, 1, 6600000, 6600000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00095', 95, 3, '2026-03-08 10:51:16', 'delivered', 13500000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (95, 15, 2, 6750000, 13500000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00096', 96, 4, '2026-02-11 13:27:52', 'delivered', 6900000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (96, 16, 1, 6900000, 6900000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00097', 97, 1, '2026-05-25 08:07:15', 'delivered', 14100000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (97, 17, 2, 7050000, 14100000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00098', 98, 2, '2026-03-26 15:11:16', 'delivered', 7200000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (98, 18, 1, 7200000, 7200000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00099', 99, 3, '2026-05-20 15:59:03', 'delivered', 14700000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (99, 19, 2, 7350000, 14700000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00100', 100, 4, '2026-03-27 06:35:07', 'delivered', 7500000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (100, 20, 1, 7500000, 7500000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00101', 1, 1, '2026-04-24 05:29:19', 'delivered', 16500000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (101, 1, 2, 8250000, 16500000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00102', 2, 2, '2026-02-21 10:55:23', 'delivered', 8500000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (102, 2, 1, 8500000, 8500000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00103', 3, 3, '2026-03-16 20:25:45', 'delivered', 17500000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (103, 3, 2, 8750000, 17500000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00104', 4, 4, '2026-02-05 07:19:02', 'delivered', 9000000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (104, 4, 1, 9000000, 9000000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00105', 5, 1, '2026-03-03 15:52:46', 'delivered', 18500000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (105, 5, 2, 9250000, 18500000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00106', 6, 2, '2026-04-14 09:03:51', 'delivered', 9500000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (106, 6, 1, 9500000, 9500000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00107', 7, 3, '2026-04-10 19:10:53', 'delivered', 19500000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (107, 7, 2, 9750000, 19500000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00108', 8, 4, '2026-04-10 12:20:33', 'delivered', 10000000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (108, 8, 1, 10000000, 10000000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00109', 9, 1, '2026-03-12 20:55:06', 'delivered', 20500000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (109, 9, 2, 10250000, 20500000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00110', 10, 2, '2026-02-19 09:40:35', 'delivered', 10500000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (110, 10, 1, 10500000, 10500000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00111', 11, 3, '2026-04-02 14:38:30', 'delivered', 21500000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (111, 11, 2, 10750000, 21500000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00112', 12, 4, '2026-05-21 12:03:41', 'delivered', 11000000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (112, 12, 1, 11000000, 11000000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00113', 13, 1, '2026-03-29 07:00:06', 'delivered', 12900000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (113, 13, 2, 6450000, 12900000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00114', 14, 2, '2026-02-28 11:30:07', 'delivered', 6600000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (114, 14, 1, 6600000, 6600000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00115', 15, 3, '2026-02-14 15:26:51', 'delivered', 13500000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (115, 15, 2, 6750000, 13500000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00116', 16, 4, '2026-04-01 18:21:53', 'delivered', 6900000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (116, 16, 1, 6900000, 6900000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00117', 17, 1, '2026-04-23 10:19:02', 'delivered', 14100000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (117, 17, 2, 7050000, 14100000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00118', 18, 2, '2026-02-06 20:46:03', 'delivered', 7200000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (118, 18, 1, 7200000, 7200000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00119', 19, 3, '2026-02-27 22:29:30', 'delivered', 14700000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (119, 19, 2, 7350000, 14700000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00120', 20, 4, '2026-05-09 19:57:30', 'delivered', 7500000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (120, 20, 1, 7500000, 7500000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00121', 21, 1, '2026-05-12 20:50:38', 'delivered', 16500000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (121, 1, 2, 8250000, 16500000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00122', 22, 2, '2026-04-17 00:50:18', 'delivered', 8500000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (122, 2, 1, 8500000, 8500000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00123', 23, 3, '2026-04-04 07:16:13', 'delivered', 17500000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (123, 3, 2, 8750000, 17500000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00124', 24, 4, '2026-04-27 09:57:32', 'delivered', 9000000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (124, 4, 1, 9000000, 9000000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00125', 25, 1, '2026-04-03 11:54:47', 'delivered', 18500000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (125, 5, 2, 9250000, 18500000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00126', 26, 2, '2026-03-04 07:40:44', 'delivered', 9500000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (126, 6, 1, 9500000, 9500000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00127', 27, 3, '2026-05-22 21:43:48', 'delivered', 19500000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (127, 7, 2, 9750000, 19500000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00128', 28, 4, '2026-03-28 13:58:20', 'delivered', 10000000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (128, 8, 1, 10000000, 10000000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00129', 29, 1, '2026-02-28 10:05:15', 'delivered', 20500000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (129, 9, 2, 10250000, 20500000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00130', 30, 2, '2026-02-12 04:39:45', 'delivered', 10500000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (130, 10, 1, 10500000, 10500000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00131', 31, 3, '2026-05-20 16:05:39', 'delivered', 21500000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (131, 11, 2, 10750000, 21500000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00132', 32, 4, '2026-05-07 15:00:53', 'delivered', 11000000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (132, 12, 1, 11000000, 11000000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00133', 33, 1, '2026-02-04 03:30:05', 'delivered', 12900000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (133, 13, 2, 6450000, 12900000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00134', 34, 2, '2026-05-20 11:57:34', 'delivered', 6600000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (134, 14, 1, 6600000, 6600000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00135', 35, 3, '2026-03-05 08:24:07', 'delivered', 13500000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (135, 15, 2, 6750000, 13500000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00136', 36, 4, '2026-04-17 11:23:38', 'delivered', 6900000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (136, 16, 1, 6900000, 6900000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00137', 37, 1, '2026-03-17 02:17:37', 'delivered', 14100000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (137, 17, 2, 7050000, 14100000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00138', 38, 2, '2026-05-14 21:19:28', 'delivered', 7200000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (138, 18, 1, 7200000, 7200000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00139', 39, 3, '2026-02-04 18:44:13', 'delivered', 14700000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (139, 19, 2, 7350000, 14700000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00140', 40, 4, '2026-02-06 20:22:11', 'delivered', 7500000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (140, 20, 1, 7500000, 7500000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00141', 41, 1, '2026-04-18 04:53:46', 'delivered', 16500000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (141, 1, 2, 8250000, 16500000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00142', 42, 2, '2026-04-06 00:19:02', 'delivered', 8500000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (142, 2, 1, 8500000, 8500000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00143', 43, 3, '2026-03-20 17:00:55', 'delivered', 17500000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (143, 3, 2, 8750000, 17500000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00144', 44, 4, '2026-05-29 07:40:27', 'delivered', 9000000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (144, 4, 1, 9000000, 9000000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00145', 45, 1, '2026-02-13 08:42:19', 'delivered', 18500000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (145, 5, 2, 9250000, 18500000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00146', 46, 2, '2026-03-08 17:23:41', 'delivered', 9500000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (146, 6, 1, 9500000, 9500000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00147', 47, 3, '2026-05-30 16:12:41', 'delivered', 19500000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (147, 7, 2, 9750000, 19500000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00148', 48, 4, '2026-05-19 02:11:59', 'delivered', 10000000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (148, 8, 1, 10000000, 10000000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00149', 49, 1, '2026-02-21 01:15:14', 'delivered', 20500000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (149, 9, 2, 10250000, 20500000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00150', 50, 2, '2026-05-17 09:06:37', 'delivered', 10500000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (150, 10, 1, 10500000, 10500000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00151', 51, 3, '2026-03-16 16:08:13', 'delivered', 21500000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (151, 11, 2, 10750000, 21500000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00152', 52, 4, '2026-05-11 08:55:10', 'delivered', 11000000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (152, 12, 1, 11000000, 11000000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00153', 53, 1, '2026-05-18 20:45:09', 'delivered', 12900000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (153, 13, 2, 6450000, 12900000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00154', 54, 2, '2026-05-04 14:26:03', 'delivered', 6600000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (154, 14, 1, 6600000, 6600000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00155', 55, 3, '2026-05-08 17:04:00', 'delivered', 13500000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (155, 15, 2, 6750000, 13500000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00156', 56, 4, '2026-05-09 06:09:36', 'delivered', 6900000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (156, 16, 1, 6900000, 6900000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00157', 57, 1, '2026-03-04 11:37:17', 'delivered', 14100000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (157, 17, 2, 7050000, 14100000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00158', 58, 2, '2026-03-08 15:18:53', 'delivered', 7200000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (158, 18, 1, 7200000, 7200000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00159', 59, 3, '2026-04-16 13:02:53', 'delivered', 14700000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (159, 19, 2, 7350000, 14700000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00160', 60, 4, '2026-05-10 17:57:11', 'delivered', 7500000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (160, 20, 1, 7500000, 7500000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00161', 61, 1, '2026-04-29 07:40:14', 'delivered', 16500000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (161, 1, 2, 8250000, 16500000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00162', 62, 2, '2026-02-11 07:24:12', 'delivered', 8500000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (162, 2, 1, 8500000, 8500000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00163', 63, 3, '2026-05-19 05:53:03', 'delivered', 17500000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (163, 3, 2, 8750000, 17500000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00164', 64, 4, '2026-04-12 13:52:34', 'delivered', 9000000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (164, 4, 1, 9000000, 9000000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00165', 65, 1, '2026-03-31 05:21:08', 'delivered', 18500000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (165, 5, 2, 9250000, 18500000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00166', 66, 2, '2026-04-02 18:41:44', 'delivered', 9500000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (166, 6, 1, 9500000, 9500000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00167', 67, 3, '2026-03-06 02:08:44', 'delivered', 19500000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (167, 7, 2, 9750000, 19500000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00168', 68, 4, '2026-03-03 05:11:23', 'delivered', 10000000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (168, 8, 1, 10000000, 10000000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00169', 69, 1, '2026-02-04 12:29:10', 'delivered', 20500000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (169, 9, 2, 10250000, 20500000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00170', 70, 2, '2026-04-25 14:05:35', 'delivered', 10500000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (170, 10, 1, 10500000, 10500000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00171', 71, 3, '2026-03-06 17:40:09', 'delivered', 21500000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (171, 11, 2, 10750000, 21500000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00172', 72, 4, '2026-02-19 20:35:46', 'delivered', 11000000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (172, 12, 1, 11000000, 11000000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00173', 73, 1, '2026-02-12 01:25:53', 'delivered', 12900000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (173, 13, 2, 6450000, 12900000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00174', 74, 2, '2026-05-10 05:38:17', 'delivered', 6600000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (174, 14, 1, 6600000, 6600000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00175', 75, 3, '2026-02-14 10:38:32', 'delivered', 13500000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (175, 15, 2, 6750000, 13500000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00176', 76, 4, '2026-03-23 04:45:43', 'delivered', 6900000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (176, 16, 1, 6900000, 6900000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00177', 77, 1, '2026-03-23 04:33:49', 'delivered', 14100000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (177, 17, 2, 7050000, 14100000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00178', 78, 2, '2026-04-07 11:17:21', 'delivered', 7200000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (178, 18, 1, 7200000, 7200000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00179', 79, 3, '2026-02-23 06:44:00', 'delivered', 14700000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (179, 19, 2, 7350000, 14700000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00180', 80, 4, '2026-02-11 19:21:44', 'delivered', 7500000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (180, 20, 1, 7500000, 7500000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00181', 81, 1, '2026-02-20 14:06:13', 'delivered', 16500000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (181, 1, 2, 8250000, 16500000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00182', 82, 2, '2026-03-29 02:06:59', 'delivered', 8500000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (182, 2, 1, 8500000, 8500000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00183', 83, 3, '2026-03-07 11:26:50', 'delivered', 17500000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (183, 3, 2, 8750000, 17500000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00184', 84, 4, '2026-04-27 05:38:38', 'delivered', 9000000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (184, 4, 1, 9000000, 9000000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00185', 85, 1, '2026-02-23 20:20:25', 'delivered', 18500000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (185, 5, 2, 9250000, 18500000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00186', 86, 2, '2026-02-22 12:36:52', 'delivered', 9500000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (186, 6, 1, 9500000, 9500000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00187', 87, 3, '2026-02-12 20:13:01', 'delivered', 19500000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (187, 7, 2, 9750000, 19500000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00188', 88, 4, '2026-03-06 05:22:48', 'delivered', 10000000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (188, 8, 1, 10000000, 10000000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00189', 89, 1, '2026-03-04 20:07:50', 'delivered', 20500000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (189, 9, 2, 10250000, 20500000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00190', 90, 2, '2026-05-20 08:35:00', 'delivered', 10500000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (190, 10, 1, 10500000, 10500000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00191', 91, 3, '2026-04-06 02:54:38', 'delivered', 21500000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (191, 11, 2, 10750000, 21500000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00192', 92, 4, '2026-04-26 21:27:09', 'delivered', 11000000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (192, 12, 1, 11000000, 11000000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00193', 93, 1, '2026-02-20 18:00:56', 'delivered', 12900000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (193, 13, 2, 6450000, 12900000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00194', 94, 2, '2026-02-05 17:38:40', 'delivered', 6600000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (194, 14, 1, 6600000, 6600000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00195', 95, 3, '2026-02-08 07:50:06', 'delivered', 13500000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (195, 15, 2, 6750000, 13500000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00196', 96, 4, '2026-03-07 17:44:15', 'delivered', 6900000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (196, 16, 1, 6900000, 6900000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00197', 97, 1, '2026-02-28 22:22:58', 'delivered', 14100000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (197, 17, 2, 7050000, 14100000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00198', 98, 2, '2026-04-05 00:14:07', 'delivered', 7200000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (198, 18, 1, 7200000, 7200000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00199', 99, 3, '2026-04-20 03:23:16', 'delivered', 14700000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (199, 19, 2, 7350000, 14700000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00200', 100, 4, '2026-04-01 04:38:54', 'delivered', 7500000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (200, 20, 1, 7500000, 7500000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00201', 1, 1, '2026-03-27 04:28:33', 'delivered', 16500000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (201, 1, 2, 8250000, 16500000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00202', 2, 2, '2026-05-02 00:34:19', 'delivered', 8500000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (202, 2, 1, 8500000, 8500000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00203', 3, 3, '2026-02-10 12:59:55', 'delivered', 17500000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (203, 3, 2, 8750000, 17500000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00204', 4, 4, '2026-04-17 20:16:14', 'delivered', 9000000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (204, 4, 1, 9000000, 9000000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00205', 5, 1, '2026-05-08 18:54:51', 'delivered', 18500000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (205, 5, 2, 9250000, 18500000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00206', 6, 2, '2026-05-08 02:22:40', 'delivered', 9500000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (206, 6, 1, 9500000, 9500000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00207', 7, 3, '2026-03-19 22:29:21', 'delivered', 19500000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (207, 7, 2, 9750000, 19500000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00208', 8, 4, '2026-04-20 10:12:20', 'delivered', 10000000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (208, 8, 1, 10000000, 10000000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00209', 9, 1, '2026-04-08 03:01:07', 'delivered', 20500000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (209, 9, 2, 10250000, 20500000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00210', 10, 2, '2026-02-07 11:54:09', 'delivered', 10500000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (210, 10, 1, 10500000, 10500000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00211', 11, 3, '2026-02-20 00:22:44', 'delivered', 21500000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (211, 11, 2, 10750000, 21500000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00212', 12, 4, '2026-04-14 03:33:14', 'delivered', 11000000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (212, 12, 1, 11000000, 11000000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00213', 13, 1, '2026-02-12 16:37:52', 'delivered', 12900000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (213, 13, 2, 6450000, 12900000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00214', 14, 2, '2026-04-28 11:22:53', 'delivered', 6600000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (214, 14, 1, 6600000, 6600000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00215', 15, 3, '2026-03-15 16:07:49', 'delivered', 13500000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (215, 15, 2, 6750000, 13500000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00216', 16, 4, '2026-05-07 00:51:06', 'delivered', 6900000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (216, 16, 1, 6900000, 6900000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00217', 17, 1, '2026-05-10 21:00:45', 'delivered', 14100000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (217, 17, 2, 7050000, 14100000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00218', 18, 2, '2026-05-21 14:57:25', 'delivered', 7200000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (218, 18, 1, 7200000, 7200000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00219', 19, 3, '2026-04-22 14:43:42', 'delivered', 14700000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (219, 19, 2, 7350000, 14700000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00220', 20, 4, '2026-05-18 22:07:17', 'delivered', 7500000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (220, 20, 1, 7500000, 7500000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00221', 21, 1, '2026-03-03 15:07:40', 'delivered', 16500000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (221, 1, 2, 8250000, 16500000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00222', 22, 2, '2026-03-25 03:52:54', 'delivered', 8500000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (222, 2, 1, 8500000, 8500000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00223', 23, 3, '2026-03-24 05:23:09', 'delivered', 17500000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (223, 3, 2, 8750000, 17500000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00224', 24, 4, '2026-03-27 13:22:53', 'delivered', 9000000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (224, 4, 1, 9000000, 9000000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00225', 25, 1, '2026-03-03 20:52:04', 'delivered', 18500000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (225, 5, 2, 9250000, 18500000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00226', 26, 2, '2026-03-25 08:44:04', 'delivered', 9500000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (226, 6, 1, 9500000, 9500000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00227', 27, 3, '2026-03-28 20:30:37', 'delivered', 19500000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (227, 7, 2, 9750000, 19500000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00228', 28, 4, '2026-03-04 04:57:10', 'delivered', 10000000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (228, 8, 1, 10000000, 10000000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00229', 29, 1, '2026-03-28 02:16:42', 'delivered', 20500000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (229, 9, 2, 10250000, 20500000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00230', 30, 2, '2026-03-08 12:09:23', 'delivered', 10500000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (230, 10, 1, 10500000, 10500000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00231', 31, 3, '2026-05-29 05:08:55', 'delivered', 21500000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (231, 11, 2, 10750000, 21500000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00232', 32, 4, '2026-05-22 16:48:59', 'delivered', 11000000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (232, 12, 1, 11000000, 11000000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00233', 33, 1, '2026-02-25 23:50:55', 'delivered', 12900000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (233, 13, 2, 6450000, 12900000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00234', 34, 2, '2026-05-06 10:26:15', 'delivered', 6600000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (234, 14, 1, 6600000, 6600000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00235', 35, 3, '2026-03-17 10:09:19', 'delivered', 13500000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (235, 15, 2, 6750000, 13500000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00236', 36, 4, '2026-02-12 07:36:01', 'delivered', 6900000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (236, 16, 1, 6900000, 6900000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00237', 37, 1, '2026-02-20 05:43:52', 'delivered', 14100000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (237, 17, 2, 7050000, 14100000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00238', 38, 2, '2026-04-24 16:06:33', 'delivered', 7200000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (238, 18, 1, 7200000, 7200000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00239', 39, 3, '2026-05-01 08:00:03', 'delivered', 14700000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (239, 19, 2, 7350000, 14700000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00240', 40, 4, '2026-04-08 12:02:27', 'delivered', 7500000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (240, 20, 1, 7500000, 7500000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00241', 41, 1, '2026-05-02 07:21:51', 'delivered', 16500000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (241, 1, 2, 8250000, 16500000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00242', 42, 2, '2026-05-14 12:34:17', 'delivered', 8500000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (242, 2, 1, 8500000, 8500000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00243', 43, 3, '2026-04-22 08:34:55', 'delivered', 17500000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (243, 3, 2, 8750000, 17500000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00244', 44, 4, '2026-04-10 07:21:46', 'delivered', 9000000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (244, 4, 1, 9000000, 9000000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00245', 45, 1, '2026-05-14 21:01:37', 'delivered', 18500000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (245, 5, 2, 9250000, 18500000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00246', 46, 2, '2026-04-12 02:33:37', 'delivered', 9500000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (246, 6, 1, 9500000, 9500000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00247', 47, 3, '2026-05-12 11:54:42', 'delivered', 19500000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (247, 7, 2, 9750000, 19500000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00248', 48, 4, '2026-02-13 02:27:44', 'delivered', 10000000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (248, 8, 1, 10000000, 10000000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00249', 49, 1, '2026-02-23 05:16:09', 'delivered', 20500000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (249, 9, 2, 10250000, 20500000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00250', 50, 2, '2026-03-29 13:08:40', 'delivered', 10500000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (250, 10, 1, 10500000, 10500000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00251', 51, 3, '2026-05-06 06:44:27', 'delivered', 21500000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (251, 11, 2, 10750000, 21500000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00252', 52, 4, '2026-03-25 09:48:49', 'delivered', 11000000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (252, 12, 1, 11000000, 11000000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00253', 53, 1, '2026-05-08 00:49:21', 'delivered', 12900000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (253, 13, 2, 6450000, 12900000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00254', 54, 2, '2026-02-20 01:19:26', 'delivered', 6600000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (254, 14, 1, 6600000, 6600000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00255', 55, 3, '2026-05-21 07:32:27', 'delivered', 13500000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (255, 15, 2, 6750000, 13500000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00256', 56, 4, '2026-04-26 07:22:14', 'delivered', 6900000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (256, 16, 1, 6900000, 6900000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00257', 57, 1, '2026-04-23 16:13:43', 'delivered', 14100000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (257, 17, 2, 7050000, 14100000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00258', 58, 2, '2026-05-25 14:04:09', 'delivered', 7200000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (258, 18, 1, 7200000, 7200000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00259', 59, 3, '2026-05-16 19:47:37', 'delivered', 14700000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (259, 19, 2, 7350000, 14700000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00260', 60, 4, '2026-05-29 09:32:35', 'delivered', 7500000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (260, 20, 1, 7500000, 7500000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00261', 61, 1, '2026-05-30 17:36:05', 'delivered', 16500000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (261, 1, 2, 8250000, 16500000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00262', 62, 2, '2026-02-25 17:27:16', 'delivered', 8500000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (262, 2, 1, 8500000, 8500000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00263', 63, 3, '2026-02-09 16:21:47', 'delivered', 17500000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (263, 3, 2, 8750000, 17500000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00264', 64, 4, '2026-04-04 02:13:59', 'delivered', 9000000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (264, 4, 1, 9000000, 9000000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00265', 65, 1, '2026-05-09 07:05:56', 'delivered', 18500000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (265, 5, 2, 9250000, 18500000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00266', 66, 2, '2026-05-27 07:09:34', 'delivered', 9500000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (266, 6, 1, 9500000, 9500000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00267', 67, 3, '2026-03-10 11:15:22', 'delivered', 19500000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (267, 7, 2, 9750000, 19500000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00268', 68, 4, '2026-04-02 00:19:37', 'delivered', 10000000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (268, 8, 1, 10000000, 10000000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00269', 69, 1, '2026-02-14 11:37:32', 'delivered', 20500000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (269, 9, 2, 10250000, 20500000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00270', 70, 2, '2026-05-13 19:05:14', 'delivered', 10500000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (270, 10, 1, 10500000, 10500000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00271', 71, 3, '2026-04-08 00:59:46', 'delivered', 21500000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (271, 11, 2, 10750000, 21500000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00272', 72, 4, '2026-03-09 12:50:23', 'delivered', 11000000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (272, 12, 1, 11000000, 11000000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00273', 73, 1, '2026-05-26 05:17:42', 'delivered', 12900000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (273, 13, 2, 6450000, 12900000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00274', 74, 2, '2026-05-29 02:26:24', 'delivered', 6600000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (274, 14, 1, 6600000, 6600000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00275', 75, 3, '2026-04-28 23:55:05', 'delivered', 13500000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (275, 15, 2, 6750000, 13500000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00276', 76, 4, '2026-05-19 03:17:36', 'delivered', 6900000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (276, 16, 1, 6900000, 6900000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00277', 77, 1, '2026-03-09 02:35:52', 'delivered', 14100000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (277, 17, 2, 7050000, 14100000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00278', 78, 2, '2026-03-25 21:56:39', 'delivered', 7200000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (278, 18, 1, 7200000, 7200000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00279', 79, 3, '2026-04-15 16:35:23', 'delivered', 14700000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (279, 19, 2, 7350000, 14700000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00280', 80, 4, '2026-03-05 09:45:29', 'delivered', 7500000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (280, 20, 1, 7500000, 7500000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00281', 81, 1, '2026-04-17 16:31:04', 'delivered', 16500000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (281, 1, 2, 8250000, 16500000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00282', 82, 2, '2026-02-24 05:41:21', 'delivered', 8500000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (282, 2, 1, 8500000, 8500000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00283', 83, 3, '2026-02-23 15:29:58', 'delivered', 17500000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (283, 3, 2, 8750000, 17500000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00284', 84, 4, '2026-04-20 21:21:29', 'delivered', 9000000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (284, 4, 1, 9000000, 9000000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00285', 85, 1, '2026-04-29 16:10:29', 'delivered', 18500000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (285, 5, 2, 9250000, 18500000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00286', 86, 2, '2026-04-14 04:17:26', 'delivered', 9500000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (286, 6, 1, 9500000, 9500000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00287', 87, 3, '2026-02-14 17:08:53', 'delivered', 19500000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (287, 7, 2, 9750000, 19500000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00288', 88, 4, '2026-03-18 11:57:42', 'delivered', 10000000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (288, 8, 1, 10000000, 10000000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00289', 89, 1, '2026-03-25 13:42:50', 'delivered', 20500000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (289, 9, 2, 10250000, 20500000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00290', 90, 2, '2026-02-03 13:47:30', 'delivered', 10500000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (290, 10, 1, 10500000, 10500000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00291', 91, 3, '2026-04-27 01:06:20', 'delivered', 21500000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (291, 11, 2, 10750000, 21500000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00292', 92, 4, '2026-05-16 15:16:52', 'delivered', 11000000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (292, 12, 1, 11000000, 11000000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00293', 93, 1, '2026-03-04 07:26:44', 'delivered', 12900000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (293, 13, 2, 6450000, 12900000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00294', 94, 2, '2026-05-25 06:05:14', 'delivered', 6600000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (294, 14, 1, 6600000, 6600000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00295', 95, 3, '2026-05-30 13:19:55', 'delivered', 13500000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (295, 15, 2, 6750000, 13500000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00296', 96, 4, '2026-02-24 03:43:46', 'delivered', 6900000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (296, 16, 1, 6900000, 6900000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00297', 97, 1, '2026-05-22 09:32:23', 'delivered', 14100000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (297, 17, 2, 7050000, 14100000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00298', 98, 2, '2026-04-27 23:39:17', 'delivered', 7200000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (298, 18, 1, 7200000, 7200000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00299', 99, 3, '2026-02-12 21:09:16', 'delivered', 14700000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (299, 19, 2, 7350000, 14700000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00300', 100, 4, '2026-03-19 18:16:23', 'delivered', 7500000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (300, 20, 1, 7500000, 7500000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00301', 1, 1, '2026-04-06 17:57:14', 'delivered', 16500000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (301, 1, 2, 8250000, 16500000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00302', 2, 2, '2026-05-27 10:49:30', 'delivered', 8500000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (302, 2, 1, 8500000, 8500000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00303', 3, 3, '2026-03-11 22:31:16', 'delivered', 17500000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (303, 3, 2, 8750000, 17500000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00304', 4, 4, '2026-03-31 21:40:54', 'delivered', 9000000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (304, 4, 1, 9000000, 9000000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00305', 5, 1, '2026-02-28 23:48:51', 'delivered', 18500000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (305, 5, 2, 9250000, 18500000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00306', 6, 2, '2026-05-06 11:17:03', 'delivered', 9500000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (306, 6, 1, 9500000, 9500000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00307', 7, 3, '2026-04-21 08:40:13', 'delivered', 19500000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (307, 7, 2, 9750000, 19500000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00308', 8, 4, '2026-04-19 14:55:23', 'delivered', 10000000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (308, 8, 1, 10000000, 10000000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00309', 9, 1, '2026-03-13 06:44:07', 'delivered', 20500000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (309, 9, 2, 10250000, 20500000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00310', 10, 2, '2026-05-13 08:25:06', 'delivered', 10500000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (310, 10, 1, 10500000, 10500000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00311', 11, 3, '2026-02-05 15:38:43', 'delivered', 21500000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (311, 11, 2, 10750000, 21500000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00312', 12, 4, '2026-04-12 09:03:39', 'delivered', 11000000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (312, 12, 1, 11000000, 11000000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00313', 13, 1, '2026-04-20 10:32:49', 'delivered', 12900000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (313, 13, 2, 6450000, 12900000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00314', 14, 2, '2026-05-12 15:25:08', 'delivered', 6600000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (314, 14, 1, 6600000, 6600000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00315', 15, 3, '2026-04-03 06:25:34', 'delivered', 13500000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (315, 15, 2, 6750000, 13500000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00316', 16, 4, '2026-04-30 09:24:36', 'delivered', 6900000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (316, 16, 1, 6900000, 6900000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00317', 17, 1, '2026-05-06 18:03:45', 'delivered', 14100000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (317, 17, 2, 7050000, 14100000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00318', 18, 2, '2026-04-25 18:13:28', 'delivered', 7200000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (318, 18, 1, 7200000, 7200000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00319', 19, 3, '2026-03-30 16:41:45', 'delivered', 14700000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (319, 19, 2, 7350000, 14700000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00320', 20, 4, '2026-05-22 14:41:31', 'delivered', 7500000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (320, 20, 1, 7500000, 7500000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00321', 21, 1, '2026-04-01 14:10:23', 'delivered', 16500000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (321, 1, 2, 8250000, 16500000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00322', 22, 2, '2026-03-01 08:10:21', 'delivered', 8500000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (322, 2, 1, 8500000, 8500000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00323', 23, 3, '2026-03-23 16:08:13', 'delivered', 17500000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (323, 3, 2, 8750000, 17500000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00324', 24, 4, '2026-05-11 01:27:00', 'delivered', 9000000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (324, 4, 1, 9000000, 9000000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00325', 25, 1, '2026-04-01 00:06:34', 'delivered', 18500000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (325, 5, 2, 9250000, 18500000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00326', 26, 2, '2026-04-25 08:32:38', 'delivered', 9500000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (326, 6, 1, 9500000, 9500000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00327', 27, 3, '2026-02-25 11:57:25', 'delivered', 19500000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (327, 7, 2, 9750000, 19500000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00328', 28, 4, '2026-05-02 01:51:11', 'delivered', 10000000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (328, 8, 1, 10000000, 10000000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00329', 29, 1, '2026-04-02 04:02:14', 'delivered', 20500000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (329, 9, 2, 10250000, 20500000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00330', 30, 2, '2026-03-24 11:32:01', 'delivered', 10500000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (330, 10, 1, 10500000, 10500000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00331', 31, 3, '2026-04-20 02:57:24', 'delivered', 21500000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (331, 11, 2, 10750000, 21500000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00332', 32, 4, '2026-04-10 17:49:50', 'delivered', 11000000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (332, 12, 1, 11000000, 11000000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00333', 33, 1, '2026-03-25 19:46:17', 'delivered', 12900000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (333, 13, 2, 6450000, 12900000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00334', 34, 2, '2026-03-19 08:15:20', 'delivered', 6600000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (334, 14, 1, 6600000, 6600000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00335', 35, 3, '2026-05-29 03:23:38', 'delivered', 13500000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (335, 15, 2, 6750000, 13500000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00336', 36, 4, '2026-03-19 10:55:15', 'delivered', 6900000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (336, 16, 1, 6900000, 6900000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00337', 37, 1, '2026-04-29 06:31:38', 'delivered', 14100000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (337, 17, 2, 7050000, 14100000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00338', 38, 2, '2026-05-20 09:15:57', 'delivered', 7200000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (338, 18, 1, 7200000, 7200000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00339', 39, 3, '2026-03-11 18:04:42', 'delivered', 14700000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (339, 19, 2, 7350000, 14700000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00340', 40, 4, '2026-03-05 15:53:20', 'delivered', 7500000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (340, 20, 1, 7500000, 7500000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00341', 41, 1, '2026-03-16 09:00:57', 'delivered', 16500000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (341, 1, 2, 8250000, 16500000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00342', 42, 2, '2026-04-12 16:36:08', 'delivered', 8500000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (342, 2, 1, 8500000, 8500000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00343', 43, 3, '2026-03-24 02:33:07', 'delivered', 17500000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (343, 3, 2, 8750000, 17500000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00344', 44, 4, '2026-03-23 12:44:08', 'delivered', 9000000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (344, 4, 1, 9000000, 9000000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00345', 45, 1, '2026-02-15 23:12:54', 'delivered', 18500000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (345, 5, 2, 9250000, 18500000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00346', 46, 2, '2026-05-01 05:15:53', 'delivered', 9500000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (346, 6, 1, 9500000, 9500000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00347', 47, 3, '2026-05-02 15:15:03', 'delivered', 19500000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (347, 7, 2, 9750000, 19500000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00348', 48, 4, '2026-02-01 05:35:45', 'delivered', 10000000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (348, 8, 1, 10000000, 10000000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00349', 49, 1, '2026-02-24 19:53:33', 'delivered', 20500000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (349, 9, 2, 10250000, 20500000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00350', 50, 2, '2026-05-28 14:06:29', 'delivered', 10500000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (350, 10, 1, 10500000, 10500000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00351', 51, 3, '2026-03-31 12:15:53', 'delivered', 21500000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (351, 11, 2, 10750000, 21500000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00352', 52, 4, '2026-03-27 19:57:24', 'delivered', 11000000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (352, 12, 1, 11000000, 11000000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00353', 53, 1, '2026-02-27 05:34:45', 'delivered', 12900000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (353, 13, 2, 6450000, 12900000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00354', 54, 2, '2026-02-10 19:24:20', 'delivered', 6600000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (354, 14, 1, 6600000, 6600000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00355', 55, 3, '2026-04-24 07:13:00', 'delivered', 13500000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (355, 15, 2, 6750000, 13500000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00356', 56, 4, '2026-02-09 11:21:28', 'delivered', 6900000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (356, 16, 1, 6900000, 6900000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00357', 57, 1, '2026-03-25 07:56:44', 'delivered', 14100000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (357, 17, 2, 7050000, 14100000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00358', 58, 2, '2026-05-25 03:45:51', 'delivered', 7200000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (358, 18, 1, 7200000, 7200000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00359', 59, 3, '2026-02-22 04:36:49', 'delivered', 14700000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (359, 19, 2, 7350000, 14700000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00360', 60, 4, '2026-04-17 21:22:58', 'delivered', 7500000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (360, 20, 1, 7500000, 7500000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00361', 61, 1, '2026-03-10 06:44:24', 'delivered', 16500000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (361, 1, 2, 8250000, 16500000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00362', 62, 2, '2026-05-17 07:09:18', 'delivered', 8500000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (362, 2, 1, 8500000, 8500000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00363', 63, 3, '2026-04-18 14:42:34', 'delivered', 17500000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (363, 3, 2, 8750000, 17500000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00364', 64, 4, '2026-02-05 03:04:39', 'delivered', 9000000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (364, 4, 1, 9000000, 9000000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00365', 65, 1, '2026-02-12 20:32:04', 'delivered', 18500000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (365, 5, 2, 9250000, 18500000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00366', 66, 2, '2026-05-20 07:23:19', 'delivered', 9500000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (366, 6, 1, 9500000, 9500000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00367', 67, 3, '2026-03-29 07:38:59', 'delivered', 19500000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (367, 7, 2, 9750000, 19500000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00368', 68, 4, '2026-04-24 23:55:51', 'delivered', 10000000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (368, 8, 1, 10000000, 10000000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00369', 69, 1, '2026-03-03 18:31:01', 'delivered', 20500000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (369, 9, 2, 10250000, 20500000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00370', 70, 2, '2026-04-25 09:12:23', 'delivered', 10500000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (370, 10, 1, 10500000, 10500000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00371', 71, 3, '2026-04-26 20:56:41', 'delivered', 21500000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (371, 11, 2, 10750000, 21500000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00372', 72, 4, '2026-04-27 04:00:49', 'delivered', 11000000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (372, 12, 1, 11000000, 11000000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00373', 73, 1, '2026-02-28 11:35:35', 'delivered', 12900000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (373, 13, 2, 6450000, 12900000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00374', 74, 2, '2026-04-02 03:44:43', 'delivered', 6600000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (374, 14, 1, 6600000, 6600000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00375', 75, 3, '2026-03-05 10:27:46', 'delivered', 13500000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (375, 15, 2, 6750000, 13500000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00376', 76, 4, '2026-05-10 21:08:35', 'delivered', 6900000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (376, 16, 1, 6900000, 6900000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00377', 77, 1, '2026-02-12 23:28:30', 'delivered', 14100000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (377, 17, 2, 7050000, 14100000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00378', 78, 2, '2026-02-22 04:17:12', 'delivered', 7200000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (378, 18, 1, 7200000, 7200000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00379', 79, 3, '2026-02-28 23:58:31', 'delivered', 14700000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (379, 19, 2, 7350000, 14700000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00380', 80, 4, '2026-04-02 15:49:24', 'delivered', 7500000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (380, 20, 1, 7500000, 7500000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00381', 81, 1, '2026-02-25 15:32:35', 'delivered', 16500000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (381, 1, 2, 8250000, 16500000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00382', 82, 2, '2026-05-08 01:51:38', 'delivered', 8500000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (382, 2, 1, 8500000, 8500000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00383', 83, 3, '2026-03-08 06:14:01', 'delivered', 17500000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (383, 3, 2, 8750000, 17500000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00384', 84, 4, '2026-05-24 10:06:49', 'delivered', 9000000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (384, 4, 1, 9000000, 9000000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00385', 85, 1, '2026-04-01 01:55:17', 'delivered', 18500000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (385, 5, 2, 9250000, 18500000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00386', 86, 2, '2026-05-03 13:02:44', 'delivered', 9500000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (386, 6, 1, 9500000, 9500000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00387', 87, 3, '2026-03-28 00:44:25', 'delivered', 19500000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (387, 7, 2, 9750000, 19500000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00388', 88, 4, '2026-02-16 04:58:07', 'delivered', 10000000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (388, 8, 1, 10000000, 10000000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00389', 89, 1, '2026-04-30 21:25:36', 'delivered', 20500000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (389, 9, 2, 10250000, 20500000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00390', 90, 2, '2026-02-17 09:15:42', 'delivered', 10500000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (390, 10, 1, 10500000, 10500000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00391', 91, 3, '2026-03-26 20:32:37', 'delivered', 21500000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (391, 11, 2, 10750000, 21500000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00392', 92, 4, '2026-02-27 03:05:22', 'delivered', 11000000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (392, 12, 1, 11000000, 11000000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00393', 93, 1, '2026-04-08 20:11:21', 'delivered', 12900000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (393, 13, 2, 6450000, 12900000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00394', 94, 2, '2026-03-23 16:58:16', 'delivered', 6600000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (394, 14, 1, 6600000, 6600000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00395', 95, 3, '2026-03-10 10:02:24', 'delivered', 13500000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (395, 15, 2, 6750000, 13500000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00396', 96, 4, '2026-04-19 06:21:53', 'delivered', 6900000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (396, 16, 1, 6900000, 6900000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00397', 97, 1, '2026-02-15 20:46:05', 'delivered', 14100000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (397, 17, 2, 7050000, 14100000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00398', 98, 2, '2026-02-10 02:37:41', 'delivered', 7200000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (398, 18, 1, 7200000, 7200000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00399', 99, 3, '2026-02-07 12:02:59', 'delivered', 14700000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (399, 19, 2, 7350000, 14700000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00400', 100, 4, '2026-04-01 23:50:59', 'delivered', 7500000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (400, 20, 1, 7500000, 7500000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00401', 1, 1, '2026-05-29 02:17:26', 'delivered', 16500000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (401, 1, 2, 8250000, 16500000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00402', 2, 2, '2026-05-29 07:55:57', 'delivered', 8500000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (402, 2, 1, 8500000, 8500000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00403', 3, 3, '2026-02-20 20:57:31', 'delivered', 17500000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (403, 3, 2, 8750000, 17500000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00404', 4, 4, '2026-04-29 10:38:17', 'delivered', 9000000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (404, 4, 1, 9000000, 9000000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00405', 5, 1, '2026-02-22 05:38:45', 'delivered', 18500000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (405, 5, 2, 9250000, 18500000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00406', 6, 2, '2026-04-08 23:27:37', 'delivered', 9500000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (406, 6, 1, 9500000, 9500000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00407', 7, 3, '2026-04-04 05:18:01', 'delivered', 19500000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (407, 7, 2, 9750000, 19500000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00408', 8, 4, '2026-03-28 06:28:24', 'delivered', 10000000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (408, 8, 1, 10000000, 10000000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00409', 9, 1, '2026-04-23 05:38:21', 'delivered', 20500000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (409, 9, 2, 10250000, 20500000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00410', 10, 2, '2026-05-28 04:52:09', 'delivered', 10500000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (410, 10, 1, 10500000, 10500000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00411', 11, 3, '2026-04-16 09:00:02', 'delivered', 21500000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (411, 11, 2, 10750000, 21500000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00412', 12, 4, '2026-05-02 12:49:43', 'delivered', 11000000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (412, 12, 1, 11000000, 11000000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00413', 13, 1, '2026-05-07 22:51:08', 'delivered', 12900000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (413, 13, 2, 6450000, 12900000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00414', 14, 2, '2026-04-03 18:28:27', 'delivered', 6600000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (414, 14, 1, 6600000, 6600000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00415', 15, 3, '2026-04-03 17:42:51', 'delivered', 13500000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (415, 15, 2, 6750000, 13500000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00416', 16, 4, '2026-02-14 10:49:55', 'delivered', 6900000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (416, 16, 1, 6900000, 6900000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00417', 17, 1, '2026-04-23 10:51:19', 'delivered', 14100000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (417, 17, 2, 7050000, 14100000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00418', 18, 2, '2026-02-15 03:00:38', 'delivered', 7200000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (418, 18, 1, 7200000, 7200000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00419', 19, 3, '2026-02-26 20:01:56', 'delivered', 14700000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (419, 19, 2, 7350000, 14700000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00420', 20, 4, '2026-05-07 13:02:51', 'delivered', 7500000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (420, 20, 1, 7500000, 7500000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00421', 21, 1, '2026-03-30 08:41:19', 'delivered', 16500000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (421, 1, 2, 8250000, 16500000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00422', 22, 2, '2026-05-05 03:13:30', 'delivered', 8500000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (422, 2, 1, 8500000, 8500000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00423', 23, 3, '2026-03-07 04:02:01', 'delivered', 17500000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (423, 3, 2, 8750000, 17500000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00424', 24, 4, '2026-05-24 16:45:12', 'delivered', 9000000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (424, 4, 1, 9000000, 9000000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00425', 25, 1, '2026-03-11 07:06:47', 'delivered', 18500000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (425, 5, 2, 9250000, 18500000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00426', 26, 2, '2026-05-19 20:05:53', 'delivered', 9500000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (426, 6, 1, 9500000, 9500000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00427', 27, 3, '2026-03-01 23:31:42', 'delivered', 19500000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (427, 7, 2, 9750000, 19500000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00428', 28, 4, '2026-03-26 17:10:57', 'delivered', 10000000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (428, 8, 1, 10000000, 10000000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00429', 29, 1, '2026-04-28 20:18:26', 'delivered', 20500000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (429, 9, 2, 10250000, 20500000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00430', 30, 2, '2026-04-01 02:25:19', 'delivered', 10500000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (430, 10, 1, 10500000, 10500000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00431', 31, 3, '2026-02-19 07:48:00', 'delivered', 21500000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (431, 11, 2, 10750000, 21500000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00432', 32, 4, '2026-03-18 02:29:50', 'delivered', 11000000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (432, 12, 1, 11000000, 11000000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00433', 33, 1, '2026-05-13 22:29:02', 'delivered', 12900000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (433, 13, 2, 6450000, 12900000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00434', 34, 2, '2026-05-27 23:24:25', 'delivered', 6600000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (434, 14, 1, 6600000, 6600000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00435', 35, 3, '2026-03-29 18:00:15', 'delivered', 13500000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (435, 15, 2, 6750000, 13500000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00436', 36, 4, '2026-03-13 19:55:05', 'delivered', 6900000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (436, 16, 1, 6900000, 6900000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00437', 37, 1, '2026-02-24 02:27:55', 'delivered', 14100000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (437, 17, 2, 7050000, 14100000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00438', 38, 2, '2026-02-24 17:50:47', 'delivered', 7200000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (438, 18, 1, 7200000, 7200000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00439', 39, 3, '2026-05-23 04:07:09', 'delivered', 14700000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (439, 19, 2, 7350000, 14700000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00440', 40, 4, '2026-02-21 09:15:53', 'delivered', 7500000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (440, 20, 1, 7500000, 7500000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00441', 41, 1, '2026-04-12 03:42:32', 'delivered', 16500000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (441, 1, 2, 8250000, 16500000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00442', 42, 2, '2026-04-04 17:25:35', 'delivered', 8500000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (442, 2, 1, 8500000, 8500000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00443', 43, 3, '2026-02-19 21:25:18', 'delivered', 17500000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (443, 3, 2, 8750000, 17500000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00444', 44, 4, '2026-03-02 18:44:12', 'delivered', 9000000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (444, 4, 1, 9000000, 9000000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00445', 45, 1, '2026-02-18 21:51:40', 'delivered', 18500000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (445, 5, 2, 9250000, 18500000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00446', 46, 2, '2026-02-10 12:43:26', 'delivered', 9500000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (446, 6, 1, 9500000, 9500000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00447', 47, 3, '2026-02-27 04:40:11', 'delivered', 19500000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (447, 7, 2, 9750000, 19500000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00448', 48, 4, '2026-05-06 16:06:16', 'delivered', 10000000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (448, 8, 1, 10000000, 10000000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00449', 49, 1, '2026-03-05 10:33:45', 'delivered', 20500000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (449, 9, 2, 10250000, 20500000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00450', 50, 2, '2026-03-02 01:23:42', 'delivered', 10500000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (450, 10, 1, 10500000, 10500000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00451', 51, 3, '2026-02-04 10:54:37', 'delivered', 21500000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (451, 11, 2, 10750000, 21500000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00452', 52, 4, '2026-05-25 01:32:52', 'delivered', 11000000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (452, 12, 1, 11000000, 11000000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00453', 53, 1, '2026-02-13 10:07:53', 'delivered', 12900000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (453, 13, 2, 6450000, 12900000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00454', 54, 2, '2026-02-01 18:37:50', 'delivered', 6600000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (454, 14, 1, 6600000, 6600000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00455', 55, 3, '2026-04-08 01:26:17', 'delivered', 13500000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (455, 15, 2, 6750000, 13500000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00456', 56, 4, '2026-04-06 12:31:07', 'delivered', 6900000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (456, 16, 1, 6900000, 6900000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00457', 57, 1, '2026-03-29 17:29:48', 'delivered', 14100000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (457, 17, 2, 7050000, 14100000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00458', 58, 2, '2026-05-22 08:49:53', 'delivered', 7200000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (458, 18, 1, 7200000, 7200000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00459', 59, 3, '2026-02-07 16:38:58', 'delivered', 14700000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (459, 19, 2, 7350000, 14700000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00460', 60, 4, '2026-02-21 08:03:21', 'delivered', 7500000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (460, 20, 1, 7500000, 7500000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00461', 61, 1, '2026-05-21 18:01:50', 'delivered', 16500000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (461, 1, 2, 8250000, 16500000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00462', 62, 2, '2026-03-21 18:28:11', 'delivered', 8500000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (462, 2, 1, 8500000, 8500000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00463', 63, 3, '2026-04-27 04:13:38', 'delivered', 17500000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (463, 3, 2, 8750000, 17500000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00464', 64, 4, '2026-04-06 03:17:15', 'delivered', 9000000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (464, 4, 1, 9000000, 9000000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00465', 65, 1, '2026-05-11 23:39:49', 'delivered', 18500000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (465, 5, 2, 9250000, 18500000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00466', 66, 2, '2026-05-07 22:56:46', 'delivered', 9500000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (466, 6, 1, 9500000, 9500000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00467', 67, 3, '2026-05-06 10:32:41', 'delivered', 19500000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (467, 7, 2, 9750000, 19500000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00468', 68, 4, '2026-04-27 10:21:28', 'delivered', 10000000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (468, 8, 1, 10000000, 10000000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00469', 69, 1, '2026-03-12 12:57:03', 'delivered', 20500000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (469, 9, 2, 10250000, 20500000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00470', 70, 2, '2026-05-21 15:42:51', 'delivered', 10500000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (470, 10, 1, 10500000, 10500000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00471', 71, 3, '2026-03-17 10:18:16', 'delivered', 21500000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (471, 11, 2, 10750000, 21500000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00472', 72, 4, '2026-05-19 11:22:58', 'delivered', 11000000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (472, 12, 1, 11000000, 11000000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00473', 73, 1, '2026-02-02 21:29:34', 'delivered', 12900000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (473, 13, 2, 6450000, 12900000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00474', 74, 2, '2026-03-28 16:29:59', 'delivered', 6600000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (474, 14, 1, 6600000, 6600000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00475', 75, 3, '2026-04-29 00:18:05', 'delivered', 13500000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (475, 15, 2, 6750000, 13500000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00476', 76, 4, '2026-04-28 20:27:55', 'delivered', 6900000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (476, 16, 1, 6900000, 6900000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00477', 77, 1, '2026-05-13 17:13:58', 'delivered', 14100000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (477, 17, 2, 7050000, 14100000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00478', 78, 2, '2026-04-21 01:41:59', 'delivered', 7200000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (478, 18, 1, 7200000, 7200000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00479', 79, 3, '2026-02-26 14:02:59', 'delivered', 14700000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (479, 19, 2, 7350000, 14700000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00480', 80, 4, '2026-05-28 20:30:32', 'delivered', 7500000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (480, 20, 1, 7500000, 7500000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00481', 81, 1, '2026-02-22 05:38:23', 'delivered', 16500000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (481, 1, 2, 8250000, 16500000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00482', 82, 2, '2026-04-30 20:38:11', 'delivered', 8500000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (482, 2, 1, 8500000, 8500000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00483', 83, 3, '2026-04-09 22:11:25', 'delivered', 17500000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (483, 3, 2, 8750000, 17500000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00484', 84, 4, '2026-02-27 11:51:13', 'delivered', 9000000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (484, 4, 1, 9000000, 9000000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00485', 85, 1, '2026-03-15 20:11:49', 'delivered', 18500000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (485, 5, 2, 9250000, 18500000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00486', 86, 2, '2026-03-22 13:41:20', 'delivered', 9500000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (486, 6, 1, 9500000, 9500000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00487', 87, 3, '2026-04-23 19:58:01', 'delivered', 19500000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (487, 7, 2, 9750000, 19500000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00488', 88, 4, '2026-04-25 21:36:26', 'delivered', 10000000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (488, 8, 1, 10000000, 10000000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00489', 89, 1, '2026-03-17 18:23:20', 'delivered', 20500000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (489, 9, 2, 10250000, 20500000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00490', 90, 2, '2026-05-23 22:07:01', 'delivered', 10500000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (490, 10, 1, 10500000, 10500000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00491', 91, 3, '2026-04-27 01:41:07', 'delivered', 21500000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (491, 11, 2, 10750000, 21500000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00492', 92, 4, '2026-03-23 23:06:07', 'delivered', 11000000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (492, 12, 1, 11000000, 11000000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00493', 93, 1, '2026-05-27 00:20:01', 'delivered', 12900000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (493, 13, 2, 6450000, 12900000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00494', 94, 2, '2026-04-03 05:47:24', 'delivered', 6600000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (494, 14, 1, 6600000, 6600000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00495', 95, 3, '2026-03-19 08:07:51', 'delivered', 13500000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (495, 15, 2, 6750000, 13500000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00496', 96, 4, '2026-05-28 20:41:54', 'delivered', 6900000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (496, 16, 1, 6900000, 6900000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00497', 97, 1, '2026-02-21 16:09:08', 'delivered', 14100000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (497, 17, 2, 7050000, 14100000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00498', 98, 2, '2026-05-07 08:45:46', 'delivered', 7200000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (498, 18, 1, 7200000, 7200000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00499', 99, 3, '2026-02-04 05:20:09', 'delivered', 14700000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (499, 19, 2, 7350000, 14700000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00500', 100, 4, '2026-05-05 19:14:07', 'delivered', 7500000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (500, 20, 1, 7500000, 7500000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00501', 1, 1, '2026-02-25 04:49:16', 'delivered', 16500000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (501, 1, 2, 8250000, 16500000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00502', 2, 2, '2026-04-10 22:35:04', 'delivered', 8500000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (502, 2, 1, 8500000, 8500000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00503', 3, 3, '2026-02-24 06:04:35', 'delivered', 17500000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (503, 3, 2, 8750000, 17500000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00504', 4, 4, '2026-02-22 09:37:15', 'delivered', 9000000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (504, 4, 1, 9000000, 9000000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00505', 5, 1, '2026-05-13 08:37:51', 'delivered', 18500000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (505, 5, 2, 9250000, 18500000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00506', 6, 2, '2026-02-22 04:24:54', 'delivered', 9500000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (506, 6, 1, 9500000, 9500000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00507', 7, 3, '2026-05-30 18:50:44', 'delivered', 19500000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (507, 7, 2, 9750000, 19500000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00508', 8, 4, '2026-03-20 03:48:06', 'delivered', 10000000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (508, 8, 1, 10000000, 10000000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00509', 9, 1, '2026-04-10 11:00:38', 'delivered', 20500000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (509, 9, 2, 10250000, 20500000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00510', 10, 2, '2026-04-06 14:33:57', 'delivered', 10500000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (510, 10, 1, 10500000, 10500000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00511', 11, 3, '2026-02-25 06:16:58', 'delivered', 21500000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (511, 11, 2, 10750000, 21500000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00512', 12, 4, '2026-03-09 13:32:10', 'delivered', 11000000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (512, 12, 1, 11000000, 11000000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00513', 13, 1, '2026-04-28 15:41:00', 'delivered', 12900000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (513, 13, 2, 6450000, 12900000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00514', 14, 2, '2026-02-03 18:59:00', 'delivered', 6600000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (514, 14, 1, 6600000, 6600000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00515', 15, 3, '2026-02-10 14:33:39', 'delivered', 13500000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (515, 15, 2, 6750000, 13500000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00516', 16, 4, '2026-02-07 23:32:11', 'delivered', 6900000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (516, 16, 1, 6900000, 6900000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00517', 17, 1, '2026-02-19 11:06:15', 'delivered', 14100000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (517, 17, 2, 7050000, 14100000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00518', 18, 2, '2026-05-01 15:58:56', 'delivered', 7200000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (518, 18, 1, 7200000, 7200000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00519', 19, 3, '2026-04-30 13:10:36', 'delivered', 14700000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (519, 19, 2, 7350000, 14700000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00520', 20, 4, '2026-04-11 04:57:50', 'delivered', 7500000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (520, 20, 1, 7500000, 7500000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00521', 21, 1, '2026-03-22 15:00:24', 'delivered', 16500000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (521, 1, 2, 8250000, 16500000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00522', 22, 2, '2026-05-22 15:00:37', 'delivered', 8500000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (522, 2, 1, 8500000, 8500000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00523', 23, 3, '2026-03-13 10:13:47', 'delivered', 17500000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (523, 3, 2, 8750000, 17500000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00524', 24, 4, '2026-03-27 15:06:19', 'delivered', 9000000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (524, 4, 1, 9000000, 9000000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00525', 25, 1, '2026-04-01 10:02:18', 'delivered', 18500000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (525, 5, 2, 9250000, 18500000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00526', 26, 2, '2026-04-14 15:58:56', 'delivered', 9500000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (526, 6, 1, 9500000, 9500000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00527', 27, 3, '2026-05-20 04:37:36', 'delivered', 19500000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (527, 7, 2, 9750000, 19500000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00528', 28, 4, '2026-05-04 03:57:15', 'delivered', 10000000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (528, 8, 1, 10000000, 10000000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00529', 29, 1, '2026-04-13 15:52:54', 'delivered', 20500000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (529, 9, 2, 10250000, 20500000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00530', 30, 2, '2026-04-03 02:45:18', 'delivered', 10500000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (530, 10, 1, 10500000, 10500000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00531', 31, 3, '2026-03-26 06:06:42', 'delivered', 21500000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (531, 11, 2, 10750000, 21500000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00532', 32, 4, '2026-03-11 15:47:36', 'delivered', 11000000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (532, 12, 1, 11000000, 11000000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00533', 33, 1, '2026-02-10 03:25:11', 'delivered', 12900000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (533, 13, 2, 6450000, 12900000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00534', 34, 2, '2026-02-23 11:38:41', 'delivered', 6600000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (534, 14, 1, 6600000, 6600000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00535', 35, 3, '2026-03-21 04:39:41', 'delivered', 13500000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (535, 15, 2, 6750000, 13500000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00536', 36, 4, '2026-02-09 02:36:57', 'delivered', 6900000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (536, 16, 1, 6900000, 6900000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00537', 37, 1, '2026-04-21 12:13:20', 'delivered', 14100000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (537, 17, 2, 7050000, 14100000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00538', 38, 2, '2026-04-01 15:28:44', 'delivered', 7200000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (538, 18, 1, 7200000, 7200000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00539', 39, 3, '2026-03-29 04:41:12', 'delivered', 14700000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (539, 19, 2, 7350000, 14700000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00540', 40, 4, '2026-04-15 18:11:47', 'delivered', 7500000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (540, 20, 1, 7500000, 7500000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00541', 41, 1, '2026-02-18 05:19:35', 'delivered', 16500000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (541, 1, 2, 8250000, 16500000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00542', 42, 2, '2026-03-23 10:05:35', 'delivered', 8500000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (542, 2, 1, 8500000, 8500000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00543', 43, 3, '2026-05-06 14:27:52', 'delivered', 17500000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (543, 3, 2, 8750000, 17500000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00544', 44, 4, '2026-04-05 20:17:01', 'delivered', 9000000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (544, 4, 1, 9000000, 9000000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00545', 45, 1, '2026-03-14 14:54:07', 'delivered', 18500000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (545, 5, 2, 9250000, 18500000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00546', 46, 2, '2026-04-11 14:31:29', 'delivered', 9500000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (546, 6, 1, 9500000, 9500000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00547', 47, 3, '2026-02-11 02:55:38', 'delivered', 19500000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (547, 7, 2, 9750000, 19500000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00548', 48, 4, '2026-04-26 07:50:57', 'delivered', 10000000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (548, 8, 1, 10000000, 10000000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00549', 49, 1, '2026-02-04 07:46:12', 'delivered', 20500000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (549, 9, 2, 10250000, 20500000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00550', 50, 2, '2026-03-27 07:24:26', 'delivered', 10500000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (550, 10, 1, 10500000, 10500000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00551', 51, 3, '2026-03-17 17:14:32', 'delivered', 21500000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (551, 11, 2, 10750000, 21500000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00552', 52, 4, '2026-05-15 14:56:37', 'delivered', 11000000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (552, 12, 1, 11000000, 11000000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00553', 53, 1, '2026-05-28 15:38:27', 'delivered', 12900000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (553, 13, 2, 6450000, 12900000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00554', 54, 2, '2026-04-01 15:20:39', 'delivered', 6600000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (554, 14, 1, 6600000, 6600000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00555', 55, 3, '2026-02-06 23:07:30', 'delivered', 13500000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (555, 15, 2, 6750000, 13500000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00556', 56, 4, '2026-02-23 06:38:21', 'delivered', 6900000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (556, 16, 1, 6900000, 6900000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00557', 57, 1, '2026-02-05 02:57:05', 'delivered', 14100000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (557, 17, 2, 7050000, 14100000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00558', 58, 2, '2026-04-22 18:55:11', 'delivered', 7200000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (558, 18, 1, 7200000, 7200000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00559', 59, 3, '2026-04-18 21:30:40', 'delivered', 14700000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (559, 19, 2, 7350000, 14700000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00560', 60, 4, '2026-05-15 02:59:21', 'delivered', 7500000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (560, 20, 1, 7500000, 7500000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00561', 61, 1, '2026-04-04 17:28:12', 'delivered', 16500000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (561, 1, 2, 8250000, 16500000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00562', 62, 2, '2026-03-15 12:25:59', 'delivered', 8500000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (562, 2, 1, 8500000, 8500000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00563', 63, 3, '2026-02-15 04:56:50', 'delivered', 17500000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (563, 3, 2, 8750000, 17500000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00564', 64, 4, '2026-04-19 07:54:34', 'delivered', 9000000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (564, 4, 1, 9000000, 9000000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00565', 65, 1, '2026-04-28 17:39:12', 'delivered', 18500000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (565, 5, 2, 9250000, 18500000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00566', 66, 2, '2026-02-06 00:45:22', 'delivered', 9500000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (566, 6, 1, 9500000, 9500000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00567', 67, 3, '2026-05-30 06:30:57', 'delivered', 19500000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (567, 7, 2, 9750000, 19500000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00568', 68, 4, '2026-05-26 14:12:20', 'delivered', 10000000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (568, 8, 1, 10000000, 10000000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00569', 69, 1, '2026-04-13 13:13:51', 'delivered', 20500000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (569, 9, 2, 10250000, 20500000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00570', 70, 2, '2026-04-14 14:27:00', 'delivered', 10500000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (570, 10, 1, 10500000, 10500000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00571', 71, 3, '2026-05-07 05:01:58', 'delivered', 21500000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (571, 11, 2, 10750000, 21500000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00572', 72, 4, '2026-03-16 17:49:27', 'delivered', 11000000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (572, 12, 1, 11000000, 11000000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00573', 73, 1, '2026-05-15 01:18:07', 'delivered', 12900000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (573, 13, 2, 6450000, 12900000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00574', 74, 2, '2026-02-10 06:58:16', 'delivered', 6600000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (574, 14, 1, 6600000, 6600000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00575', 75, 3, '2026-04-25 07:21:48', 'delivered', 13500000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (575, 15, 2, 6750000, 13500000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00576', 76, 4, '2026-02-20 16:54:16', 'delivered', 6900000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (576, 16, 1, 6900000, 6900000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00577', 77, 1, '2026-04-05 22:34:20', 'delivered', 14100000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (577, 17, 2, 7050000, 14100000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00578', 78, 2, '2026-05-29 21:35:28', 'delivered', 7200000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (578, 18, 1, 7200000, 7200000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00579', 79, 3, '2026-02-01 09:30:44', 'delivered', 14700000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (579, 19, 2, 7350000, 14700000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00580', 80, 4, '2026-05-07 05:34:58', 'delivered', 7500000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (580, 20, 1, 7500000, 7500000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00581', 81, 1, '2026-05-01 12:10:26', 'delivered', 16500000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (581, 1, 2, 8250000, 16500000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00582', 82, 2, '2026-04-09 11:55:15', 'delivered', 8500000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (582, 2, 1, 8500000, 8500000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00583', 83, 3, '2026-02-19 07:43:13', 'delivered', 17500000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (583, 3, 2, 8750000, 17500000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00584', 84, 4, '2026-02-12 22:54:10', 'delivered', 9000000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (584, 4, 1, 9000000, 9000000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00585', 85, 1, '2026-04-30 02:53:29', 'delivered', 18500000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (585, 5, 2, 9250000, 18500000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00586', 86, 2, '2026-02-26 22:55:06', 'delivered', 9500000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (586, 6, 1, 9500000, 9500000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00587', 87, 3, '2026-02-03 14:11:02', 'delivered', 19500000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (587, 7, 2, 9750000, 19500000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00588', 88, 4, '2026-04-09 21:57:35', 'delivered', 10000000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (588, 8, 1, 10000000, 10000000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00589', 89, 1, '2026-04-18 11:36:49', 'delivered', 20500000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (589, 9, 2, 10250000, 20500000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00590', 90, 2, '2026-05-10 04:15:43', 'delivered', 10500000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (590, 10, 1, 10500000, 10500000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00591', 91, 3, '2026-03-24 06:10:46', 'delivered', 21500000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (591, 11, 2, 10750000, 21500000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00592', 92, 4, '2026-02-06 15:52:37', 'delivered', 11000000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (592, 12, 1, 11000000, 11000000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00593', 93, 1, '2026-04-30 23:54:30', 'delivered', 12900000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (593, 13, 2, 6450000, 12900000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00594', 94, 2, '2026-05-18 20:37:14', 'delivered', 6600000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (594, 14, 1, 6600000, 6600000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00595', 95, 3, '2026-03-23 08:28:48', 'delivered', 13500000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (595, 15, 2, 6750000, 13500000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00596', 96, 4, '2026-04-16 05:36:21', 'delivered', 6900000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (596, 16, 1, 6900000, 6900000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00597', 97, 1, '2026-02-04 22:00:37', 'delivered', 14100000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (597, 17, 2, 7050000, 14100000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00598', 98, 2, '2026-05-02 15:23:39', 'delivered', 7200000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (598, 18, 1, 7200000, 7200000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00599', 99, 3, '2026-04-02 04:04:25', 'delivered', 14700000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (599, 19, 2, 7350000, 14700000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00600', 100, 4, '2026-04-01 23:04:03', 'delivered', 7500000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (600, 20, 1, 7500000, 7500000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00601', 1, 1, '2026-04-24 17:49:55', 'delivered', 16500000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (601, 1, 2, 8250000, 16500000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00602', 2, 2, '2026-05-29 10:27:56', 'delivered', 8500000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (602, 2, 1, 8500000, 8500000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00603', 3, 3, '2026-02-10 10:12:55', 'delivered', 17500000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (603, 3, 2, 8750000, 17500000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00604', 4, 4, '2026-05-18 21:43:05', 'delivered', 9000000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (604, 4, 1, 9000000, 9000000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00605', 5, 1, '2026-04-22 09:38:58', 'delivered', 18500000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (605, 5, 2, 9250000, 18500000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00606', 6, 2, '2026-02-11 11:40:11', 'delivered', 9500000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (606, 6, 1, 9500000, 9500000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00607', 7, 3, '2026-04-23 15:49:38', 'delivered', 19500000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (607, 7, 2, 9750000, 19500000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00608', 8, 4, '2026-03-29 02:27:31', 'delivered', 10000000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (608, 8, 1, 10000000, 10000000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00609', 9, 1, '2026-05-05 13:06:27', 'delivered', 20500000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (609, 9, 2, 10250000, 20500000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00610', 10, 2, '2026-03-26 00:48:35', 'delivered', 10500000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (610, 10, 1, 10500000, 10500000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00611', 11, 3, '2026-04-25 20:11:14', 'delivered', 21500000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (611, 11, 2, 10750000, 21500000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00612', 12, 4, '2026-03-16 08:09:08', 'delivered', 11000000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (612, 12, 1, 11000000, 11000000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00613', 13, 1, '2026-03-06 03:48:18', 'delivered', 12900000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (613, 13, 2, 6450000, 12900000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00614', 14, 2, '2026-03-21 10:51:40', 'delivered', 6600000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (614, 14, 1, 6600000, 6600000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00615', 15, 3, '2026-04-02 18:17:19', 'delivered', 13500000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (615, 15, 2, 6750000, 13500000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00616', 16, 4, '2026-05-01 00:28:29', 'delivered', 6900000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (616, 16, 1, 6900000, 6900000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00617', 17, 1, '2026-05-01 07:28:38', 'delivered', 14100000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (617, 17, 2, 7050000, 14100000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00618', 18, 2, '2026-02-11 18:52:29', 'delivered', 7200000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (618, 18, 1, 7200000, 7200000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00619', 19, 3, '2026-05-17 12:53:04', 'delivered', 14700000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (619, 19, 2, 7350000, 14700000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00620', 20, 4, '2026-04-21 17:16:44', 'delivered', 7500000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (620, 20, 1, 7500000, 7500000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00621', 21, 1, '2026-05-12 21:05:44', 'delivered', 16500000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (621, 1, 2, 8250000, 16500000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00622', 22, 2, '2026-04-25 03:56:45', 'delivered', 8500000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (622, 2, 1, 8500000, 8500000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00623', 23, 3, '2026-05-27 01:00:23', 'delivered', 17500000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (623, 3, 2, 8750000, 17500000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00624', 24, 4, '2026-03-21 15:34:42', 'delivered', 9000000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (624, 4, 1, 9000000, 9000000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00625', 25, 1, '2026-02-24 10:34:37', 'delivered', 18500000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (625, 5, 2, 9250000, 18500000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00626', 26, 2, '2026-02-23 20:38:38', 'delivered', 9500000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (626, 6, 1, 9500000, 9500000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00627', 27, 3, '2026-03-28 13:30:30', 'delivered', 19500000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (627, 7, 2, 9750000, 19500000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00628', 28, 4, '2026-04-14 14:59:35', 'delivered', 10000000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (628, 8, 1, 10000000, 10000000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00629', 29, 1, '2026-03-09 15:20:31', 'delivered', 20500000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (629, 9, 2, 10250000, 20500000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00630', 30, 2, '2026-05-25 06:06:29', 'delivered', 10500000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (630, 10, 1, 10500000, 10500000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00631', 31, 3, '2026-04-20 07:05:05', 'delivered', 21500000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (631, 11, 2, 10750000, 21500000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00632', 32, 4, '2026-02-10 05:02:25', 'delivered', 11000000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (632, 12, 1, 11000000, 11000000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00633', 33, 1, '2026-05-14 17:52:57', 'delivered', 12900000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (633, 13, 2, 6450000, 12900000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00634', 34, 2, '2026-05-05 21:38:45', 'delivered', 6600000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (634, 14, 1, 6600000, 6600000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00635', 35, 3, '2026-02-06 10:51:17', 'delivered', 13500000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (635, 15, 2, 6750000, 13500000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00636', 36, 4, '2026-03-04 06:07:18', 'delivered', 6900000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (636, 16, 1, 6900000, 6900000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00637', 37, 1, '2026-03-08 09:04:10', 'delivered', 14100000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (637, 17, 2, 7050000, 14100000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00638', 38, 2, '2026-02-23 23:20:31', 'delivered', 7200000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (638, 18, 1, 7200000, 7200000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00639', 39, 3, '2026-04-02 22:54:28', 'delivered', 14700000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (639, 19, 2, 7350000, 14700000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00640', 40, 4, '2026-05-28 07:27:37', 'delivered', 7500000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (640, 20, 1, 7500000, 7500000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00641', 41, 1, '2026-03-10 21:56:54', 'delivered', 16500000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (641, 1, 2, 8250000, 16500000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00642', 42, 2, '2026-02-01 23:03:10', 'delivered', 8500000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (642, 2, 1, 8500000, 8500000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00643', 43, 3, '2026-03-17 00:38:31', 'delivered', 17500000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (643, 3, 2, 8750000, 17500000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00644', 44, 4, '2026-04-22 14:22:00', 'delivered', 9000000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (644, 4, 1, 9000000, 9000000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00645', 45, 1, '2026-03-05 10:19:15', 'delivered', 18500000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (645, 5, 2, 9250000, 18500000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00646', 46, 2, '2026-05-09 09:04:40', 'delivered', 9500000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (646, 6, 1, 9500000, 9500000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00647', 47, 3, '2026-05-12 22:00:10', 'delivered', 19500000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (647, 7, 2, 9750000, 19500000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00648', 48, 4, '2026-05-29 12:53:44', 'delivered', 10000000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (648, 8, 1, 10000000, 10000000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00649', 49, 1, '2026-03-23 08:58:40', 'delivered', 20500000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (649, 9, 2, 10250000, 20500000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00650', 50, 2, '2026-02-15 05:14:54', 'delivered', 10500000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (650, 10, 1, 10500000, 10500000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00651', 51, 3, '2026-05-06 13:14:27', 'delivered', 21500000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (651, 11, 2, 10750000, 21500000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00652', 52, 4, '2026-04-19 07:31:48', 'delivered', 11000000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (652, 12, 1, 11000000, 11000000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00653', 53, 1, '2026-05-27 03:04:43', 'delivered', 12900000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (653, 13, 2, 6450000, 12900000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00654', 54, 2, '2026-04-05 11:24:52', 'delivered', 6600000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (654, 14, 1, 6600000, 6600000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00655', 55, 3, '2026-02-23 15:53:24', 'delivered', 13500000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (655, 15, 2, 6750000, 13500000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00656', 56, 4, '2026-02-22 14:28:36', 'delivered', 6900000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (656, 16, 1, 6900000, 6900000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00657', 57, 1, '2026-05-03 18:16:07', 'delivered', 14100000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (657, 17, 2, 7050000, 14100000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00658', 58, 2, '2026-05-24 14:54:39', 'delivered', 7200000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (658, 18, 1, 7200000, 7200000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00659', 59, 3, '2026-04-08 07:21:17', 'delivered', 14700000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (659, 19, 2, 7350000, 14700000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00660', 60, 4, '2026-05-10 08:20:51', 'delivered', 7500000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (660, 20, 1, 7500000, 7500000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00661', 61, 1, '2026-02-17 13:21:04', 'delivered', 16500000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (661, 1, 2, 8250000, 16500000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00662', 62, 2, '2026-03-05 16:19:29', 'delivered', 8500000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (662, 2, 1, 8500000, 8500000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00663', 63, 3, '2026-02-26 12:37:37', 'delivered', 17500000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (663, 3, 2, 8750000, 17500000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00664', 64, 4, '2026-04-14 11:37:29', 'delivered', 9000000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (664, 4, 1, 9000000, 9000000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00665', 65, 1, '2026-03-07 23:30:49', 'delivered', 18500000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (665, 5, 2, 9250000, 18500000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00666', 66, 2, '2026-04-09 05:43:34', 'delivered', 9500000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (666, 6, 1, 9500000, 9500000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00667', 67, 3, '2026-04-11 21:22:27', 'delivered', 19500000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (667, 7, 2, 9750000, 19500000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00668', 68, 4, '2026-03-20 13:48:58', 'delivered', 10000000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (668, 8, 1, 10000000, 10000000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00669', 69, 1, '2026-05-20 04:40:29', 'delivered', 20500000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (669, 9, 2, 10250000, 20500000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00670', 70, 2, '2026-02-18 23:58:23', 'delivered', 10500000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (670, 10, 1, 10500000, 10500000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00671', 71, 3, '2026-03-30 13:46:27', 'delivered', 21500000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (671, 11, 2, 10750000, 21500000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00672', 72, 4, '2026-02-28 19:51:22', 'delivered', 11000000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (672, 12, 1, 11000000, 11000000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00673', 73, 1, '2026-02-26 21:51:37', 'delivered', 12900000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (673, 13, 2, 6450000, 12900000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00674', 74, 2, '2026-03-27 21:16:31', 'delivered', 6600000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (674, 14, 1, 6600000, 6600000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00675', 75, 3, '2026-03-29 11:59:27', 'delivered', 13500000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (675, 15, 2, 6750000, 13500000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00676', 76, 4, '2026-03-13 09:03:05', 'delivered', 6900000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (676, 16, 1, 6900000, 6900000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00677', 77, 1, '2026-03-19 18:33:42', 'delivered', 14100000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (677, 17, 2, 7050000, 14100000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00678', 78, 2, '2026-05-08 06:30:42', 'delivered', 7200000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (678, 18, 1, 7200000, 7200000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00679', 79, 3, '2026-02-28 20:05:07', 'delivered', 14700000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (679, 19, 2, 7350000, 14700000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00680', 80, 4, '2026-04-02 10:25:57', 'delivered', 7500000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (680, 20, 1, 7500000, 7500000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00681', 81, 1, '2026-03-31 03:55:19', 'delivered', 16500000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (681, 1, 2, 8250000, 16500000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00682', 82, 2, '2026-05-05 12:34:40', 'delivered', 8500000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (682, 2, 1, 8500000, 8500000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00683', 83, 3, '2026-02-08 02:56:52', 'delivered', 17500000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (683, 3, 2, 8750000, 17500000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00684', 84, 4, '2026-05-21 22:12:17', 'delivered', 9000000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (684, 4, 1, 9000000, 9000000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00685', 85, 1, '2026-04-12 12:09:51', 'delivered', 18500000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (685, 5, 2, 9250000, 18500000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00686', 86, 2, '2026-02-18 18:21:40', 'delivered', 9500000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (686, 6, 1, 9500000, 9500000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00687', 87, 3, '2026-02-04 18:38:46', 'delivered', 19500000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (687, 7, 2, 9750000, 19500000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00688', 88, 4, '2026-05-16 13:04:12', 'delivered', 10000000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (688, 8, 1, 10000000, 10000000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00689', 89, 1, '2026-03-27 00:30:42', 'delivered', 20500000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (689, 9, 2, 10250000, 20500000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00690', 90, 2, '2026-05-30 20:11:57', 'delivered', 10500000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (690, 10, 1, 10500000, 10500000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00691', 91, 3, '2026-02-26 13:44:32', 'delivered', 21500000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (691, 11, 2, 10750000, 21500000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00692', 92, 4, '2026-05-20 12:56:46', 'delivered', 11000000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (692, 12, 1, 11000000, 11000000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00693', 93, 1, '2026-03-28 13:56:09', 'delivered', 12900000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (693, 13, 2, 6450000, 12900000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00694', 94, 2, '2026-02-04 03:05:53', 'delivered', 6600000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (694, 14, 1, 6600000, 6600000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00695', 95, 3, '2026-05-15 11:42:41', 'delivered', 13500000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (695, 15, 2, 6750000, 13500000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00696', 96, 4, '2026-05-25 17:37:58', 'delivered', 6900000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (696, 16, 1, 6900000, 6900000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00697', 97, 1, '2026-05-15 05:22:47', 'delivered', 14100000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (697, 17, 2, 7050000, 14100000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00698', 98, 2, '2026-03-27 18:40:10', 'delivered', 7200000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (698, 18, 1, 7200000, 7200000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00699', 99, 3, '2026-02-24 22:06:19', 'delivered', 14700000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (699, 19, 2, 7350000, 14700000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00700', 100, 4, '2026-03-21 07:20:11', 'delivered', 7500000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (700, 20, 1, 7500000, 7500000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00701', 1, 1, '2026-03-06 17:36:10', 'delivered', 16500000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (701, 1, 2, 8250000, 16500000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00702', 2, 2, '2026-02-27 07:05:20', 'delivered', 8500000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (702, 2, 1, 8500000, 8500000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00703', 3, 3, '2026-03-14 00:49:56', 'delivered', 17500000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (703, 3, 2, 8750000, 17500000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00704', 4, 4, '2026-03-08 02:49:43', 'delivered', 9000000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (704, 4, 1, 9000000, 9000000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00705', 5, 1, '2026-04-10 14:54:36', 'delivered', 18500000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (705, 5, 2, 9250000, 18500000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00706', 6, 2, '2026-05-05 14:08:15', 'delivered', 9500000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (706, 6, 1, 9500000, 9500000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00707', 7, 3, '2026-02-10 09:34:06', 'delivered', 19500000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (707, 7, 2, 9750000, 19500000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00708', 8, 4, '2026-04-29 02:54:09', 'delivered', 10000000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (708, 8, 1, 10000000, 10000000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00709', 9, 1, '2026-02-20 04:30:53', 'delivered', 20500000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (709, 9, 2, 10250000, 20500000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00710', 10, 2, '2026-02-20 03:12:47', 'delivered', 10500000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (710, 10, 1, 10500000, 10500000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00711', 11, 3, '2026-02-02 19:33:10', 'delivered', 21500000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (711, 11, 2, 10750000, 21500000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00712', 12, 4, '2026-03-21 16:02:18', 'delivered', 11000000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (712, 12, 1, 11000000, 11000000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00713', 13, 1, '2026-03-27 19:11:09', 'delivered', 12900000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (713, 13, 2, 6450000, 12900000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00714', 14, 2, '2026-05-10 22:14:45', 'delivered', 6600000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (714, 14, 1, 6600000, 6600000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00715', 15, 3, '2026-04-16 04:59:14', 'delivered', 13500000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (715, 15, 2, 6750000, 13500000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00716', 16, 4, '2026-05-11 08:38:01', 'delivered', 6900000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (716, 16, 1, 6900000, 6900000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00717', 17, 1, '2026-04-02 07:54:36', 'delivered', 14100000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (717, 17, 2, 7050000, 14100000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00718', 18, 2, '2026-04-13 00:01:08', 'delivered', 7200000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (718, 18, 1, 7200000, 7200000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00719', 19, 3, '2026-04-15 22:52:25', 'delivered', 14700000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (719, 19, 2, 7350000, 14700000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00720', 20, 4, '2026-02-21 20:54:51', 'delivered', 7500000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (720, 20, 1, 7500000, 7500000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00721', 21, 1, '2026-03-19 02:17:24', 'delivered', 16500000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (721, 1, 2, 8250000, 16500000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00722', 22, 2, '2026-05-20 20:34:25', 'delivered', 8500000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (722, 2, 1, 8500000, 8500000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00723', 23, 3, '2026-04-10 22:57:37', 'delivered', 17500000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (723, 3, 2, 8750000, 17500000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00724', 24, 4, '2026-02-10 03:46:09', 'delivered', 9000000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (724, 4, 1, 9000000, 9000000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00725', 25, 1, '2026-04-14 13:34:10', 'delivered', 18500000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (725, 5, 2, 9250000, 18500000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00726', 26, 2, '2026-04-13 19:16:56', 'delivered', 9500000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (726, 6, 1, 9500000, 9500000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00727', 27, 3, '2026-04-13 07:38:17', 'delivered', 19500000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (727, 7, 2, 9750000, 19500000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00728', 28, 4, '2026-03-05 09:23:17', 'delivered', 10000000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (728, 8, 1, 10000000, 10000000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00729', 29, 1, '2026-03-22 23:12:33', 'delivered', 20500000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (729, 9, 2, 10250000, 20500000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00730', 30, 2, '2026-02-26 13:56:27', 'delivered', 10500000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (730, 10, 1, 10500000, 10500000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00731', 31, 3, '2026-03-01 17:00:42', 'delivered', 21500000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (731, 11, 2, 10750000, 21500000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00732', 32, 4, '2026-03-27 04:28:54', 'delivered', 11000000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (732, 12, 1, 11000000, 11000000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00733', 33, 1, '2026-02-26 06:22:43', 'delivered', 12900000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (733, 13, 2, 6450000, 12900000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00734', 34, 2, '2026-02-08 00:30:25', 'delivered', 6600000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (734, 14, 1, 6600000, 6600000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00735', 35, 3, '2026-03-26 08:51:31', 'delivered', 13500000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (735, 15, 2, 6750000, 13500000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00736', 36, 4, '2026-05-05 17:54:28', 'delivered', 6900000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (736, 16, 1, 6900000, 6900000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00737', 37, 1, '2026-05-14 08:38:28', 'delivered', 14100000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (737, 17, 2, 7050000, 14100000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00738', 38, 2, '2026-04-08 11:40:03', 'delivered', 7200000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (738, 18, 1, 7200000, 7200000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00739', 39, 3, '2026-05-10 10:17:07', 'delivered', 14700000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (739, 19, 2, 7350000, 14700000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00740', 40, 4, '2026-02-11 14:06:42', 'delivered', 7500000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (740, 20, 1, 7500000, 7500000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00741', 41, 1, '2026-05-08 06:07:16', 'delivered', 16500000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (741, 1, 2, 8250000, 16500000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00742', 42, 2, '2026-04-13 15:46:12', 'delivered', 8500000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (742, 2, 1, 8500000, 8500000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00743', 43, 3, '2026-04-02 22:57:05', 'delivered', 17500000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (743, 3, 2, 8750000, 17500000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00744', 44, 4, '2026-02-13 23:02:51', 'delivered', 9000000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (744, 4, 1, 9000000, 9000000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00745', 45, 1, '2026-02-04 12:56:01', 'delivered', 18500000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (745, 5, 2, 9250000, 18500000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00746', 46, 2, '2026-05-26 15:14:42', 'delivered', 9500000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (746, 6, 1, 9500000, 9500000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00747', 47, 3, '2026-03-06 02:15:18', 'delivered', 19500000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (747, 7, 2, 9750000, 19500000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00748', 48, 4, '2026-03-02 11:57:10', 'delivered', 10000000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (748, 8, 1, 10000000, 10000000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00749', 49, 1, '2026-02-17 06:52:58', 'delivered', 20500000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (749, 9, 2, 10250000, 20500000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00750', 50, 2, '2026-04-21 13:57:40', 'delivered', 10500000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (750, 10, 1, 10500000, 10500000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00751', 51, 3, '2026-05-12 07:47:16', 'delivered', 21500000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (751, 11, 2, 10750000, 21500000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00752', 52, 4, '2026-03-03 04:47:12', 'delivered', 11000000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (752, 12, 1, 11000000, 11000000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00753', 53, 1, '2026-04-19 19:03:20', 'delivered', 12900000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (753, 13, 2, 6450000, 12900000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00754', 54, 2, '2026-02-19 11:30:26', 'delivered', 6600000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (754, 14, 1, 6600000, 6600000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00755', 55, 3, '2026-03-22 14:11:02', 'delivered', 13500000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (755, 15, 2, 6750000, 13500000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00756', 56, 4, '2026-02-27 13:30:48', 'delivered', 6900000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (756, 16, 1, 6900000, 6900000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00757', 57, 1, '2026-05-17 04:13:01', 'delivered', 14100000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (757, 17, 2, 7050000, 14100000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00758', 58, 2, '2026-04-01 11:16:16', 'delivered', 7200000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (758, 18, 1, 7200000, 7200000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00759', 59, 3, '2026-04-03 06:52:33', 'delivered', 14700000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (759, 19, 2, 7350000, 14700000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00760', 60, 4, '2026-03-15 20:26:14', 'delivered', 7500000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (760, 20, 1, 7500000, 7500000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00761', 61, 1, '2026-03-02 06:56:16', 'delivered', 16500000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (761, 1, 2, 8250000, 16500000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00762', 62, 2, '2026-05-06 10:04:44', 'delivered', 8500000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (762, 2, 1, 8500000, 8500000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00763', 63, 3, '2026-05-18 01:43:18', 'delivered', 17500000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (763, 3, 2, 8750000, 17500000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00764', 64, 4, '2026-02-10 22:33:14', 'delivered', 9000000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (764, 4, 1, 9000000, 9000000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00765', 65, 1, '2026-03-08 09:26:55', 'delivered', 18500000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (765, 5, 2, 9250000, 18500000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00766', 66, 2, '2026-02-05 13:10:48', 'delivered', 9500000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (766, 6, 1, 9500000, 9500000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00767', 67, 3, '2026-02-23 10:34:33', 'delivered', 19500000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (767, 7, 2, 9750000, 19500000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00768', 68, 4, '2026-03-23 12:48:57', 'delivered', 10000000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (768, 8, 1, 10000000, 10000000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00769', 69, 1, '2026-03-29 13:48:31', 'delivered', 20500000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (769, 9, 2, 10250000, 20500000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00770', 70, 2, '2026-04-06 18:38:47', 'delivered', 10500000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (770, 10, 1, 10500000, 10500000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00771', 71, 3, '2026-02-04 19:10:54', 'delivered', 21500000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (771, 11, 2, 10750000, 21500000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00772', 72, 4, '2026-03-07 13:12:03', 'delivered', 11000000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (772, 12, 1, 11000000, 11000000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00773', 73, 1, '2026-05-30 19:45:24', 'delivered', 12900000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (773, 13, 2, 6450000, 12900000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00774', 74, 2, '2026-05-04 03:05:00', 'delivered', 6600000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (774, 14, 1, 6600000, 6600000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00775', 75, 3, '2026-03-13 12:52:03', 'delivered', 13500000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (775, 15, 2, 6750000, 13500000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00776', 76, 4, '2026-02-04 14:41:05', 'delivered', 6900000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (776, 16, 1, 6900000, 6900000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00777', 77, 1, '2026-04-08 20:26:22', 'delivered', 14100000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (777, 17, 2, 7050000, 14100000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00778', 78, 2, '2026-02-22 17:07:08', 'delivered', 7200000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (778, 18, 1, 7200000, 7200000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00779', 79, 3, '2026-02-06 03:57:32', 'delivered', 14700000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (779, 19, 2, 7350000, 14700000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00780', 80, 4, '2026-04-21 14:35:57', 'delivered', 7500000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (780, 20, 1, 7500000, 7500000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00781', 81, 1, '2026-05-22 01:27:36', 'delivered', 16500000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (781, 1, 2, 8250000, 16500000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00782', 82, 2, '2026-03-29 20:21:13', 'delivered', 8500000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (782, 2, 1, 8500000, 8500000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00783', 83, 3, '2026-02-22 20:05:08', 'delivered', 17500000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (783, 3, 2, 8750000, 17500000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00784', 84, 4, '2026-04-21 19:51:31', 'delivered', 9000000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (784, 4, 1, 9000000, 9000000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00785', 85, 1, '2026-04-19 02:58:28', 'delivered', 18500000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (785, 5, 2, 9250000, 18500000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00786', 86, 2, '2026-03-10 23:24:00', 'delivered', 9500000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (786, 6, 1, 9500000, 9500000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00787', 87, 3, '2026-03-04 04:38:06', 'delivered', 19500000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (787, 7, 2, 9750000, 19500000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00788', 88, 4, '2026-03-01 09:54:45', 'delivered', 10000000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (788, 8, 1, 10000000, 10000000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00789', 89, 1, '2026-03-27 20:24:35', 'delivered', 20500000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (789, 9, 2, 10250000, 20500000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00790', 90, 2, '2026-03-30 12:53:57', 'delivered', 10500000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (790, 10, 1, 10500000, 10500000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00791', 91, 3, '2026-05-20 20:39:12', 'delivered', 21500000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (791, 11, 2, 10750000, 21500000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00792', 92, 4, '2026-05-25 11:31:58', 'delivered', 11000000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (792, 12, 1, 11000000, 11000000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00793', 93, 1, '2026-04-29 17:16:00', 'delivered', 12900000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (793, 13, 2, 6450000, 12900000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00794', 94, 2, '2026-03-11 19:33:11', 'delivered', 6600000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (794, 14, 1, 6600000, 6600000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00795', 95, 3, '2026-02-08 07:27:06', 'delivered', 13500000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (795, 15, 2, 6750000, 13500000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00796', 96, 4, '2026-03-09 05:41:02', 'delivered', 6900000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (796, 16, 1, 6900000, 6900000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00797', 97, 1, '2026-04-28 12:50:33', 'delivered', 14100000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (797, 17, 2, 7050000, 14100000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00798', 98, 2, '2026-02-27 12:27:02', 'delivered', 7200000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (798, 18, 1, 7200000, 7200000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00799', 99, 3, '2026-05-15 03:22:07', 'delivered', 14700000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (799, 19, 2, 7350000, 14700000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00800', 100, 4, '2026-05-08 14:35:21', 'delivered', 7500000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (800, 20, 1, 7500000, 7500000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00801', 1, 1, '2026-02-10 06:08:26', 'delivered', 16500000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (801, 1, 2, 8250000, 16500000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00802', 2, 2, '2026-05-10 15:55:28', 'delivered', 8500000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (802, 2, 1, 8500000, 8500000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00803', 3, 3, '2026-03-07 07:45:39', 'delivered', 17500000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (803, 3, 2, 8750000, 17500000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00804', 4, 4, '2026-02-14 21:43:36', 'delivered', 9000000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (804, 4, 1, 9000000, 9000000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00805', 5, 1, '2026-04-03 05:33:06', 'delivered', 18500000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (805, 5, 2, 9250000, 18500000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00806', 6, 2, '2026-04-19 21:23:50', 'delivered', 9500000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (806, 6, 1, 9500000, 9500000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00807', 7, 3, '2026-04-30 04:11:30', 'delivered', 19500000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (807, 7, 2, 9750000, 19500000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00808', 8, 4, '2026-02-27 10:15:24', 'delivered', 10000000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (808, 8, 1, 10000000, 10000000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00809', 9, 1, '2026-02-26 18:07:50', 'delivered', 20500000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (809, 9, 2, 10250000, 20500000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00810', 10, 2, '2026-02-21 16:10:05', 'delivered', 10500000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (810, 10, 1, 10500000, 10500000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00811', 11, 3, '2026-02-18 07:55:25', 'delivered', 21500000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (811, 11, 2, 10750000, 21500000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00812', 12, 4, '2026-05-25 17:58:43', 'delivered', 11000000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (812, 12, 1, 11000000, 11000000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00813', 13, 1, '2026-03-15 20:47:27', 'delivered', 12900000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (813, 13, 2, 6450000, 12900000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00814', 14, 2, '2026-04-19 07:07:03', 'delivered', 6600000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (814, 14, 1, 6600000, 6600000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00815', 15, 3, '2026-02-18 02:52:23', 'delivered', 13500000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (815, 15, 2, 6750000, 13500000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00816', 16, 4, '2026-05-30 20:24:33', 'delivered', 6900000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (816, 16, 1, 6900000, 6900000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00817', 17, 1, '2026-03-07 02:42:47', 'delivered', 14100000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (817, 17, 2, 7050000, 14100000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00818', 18, 2, '2026-03-02 12:23:05', 'delivered', 7200000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (818, 18, 1, 7200000, 7200000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00819', 19, 3, '2026-03-31 11:18:48', 'delivered', 14700000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (819, 19, 2, 7350000, 14700000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00820', 20, 4, '2026-03-10 09:43:24', 'delivered', 7500000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (820, 20, 1, 7500000, 7500000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00821', 21, 1, '2026-02-09 20:13:25', 'delivered', 16500000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (821, 1, 2, 8250000, 16500000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00822', 22, 2, '2026-05-02 08:18:28', 'delivered', 8500000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (822, 2, 1, 8500000, 8500000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00823', 23, 3, '2026-05-26 21:21:40', 'delivered', 17500000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (823, 3, 2, 8750000, 17500000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00824', 24, 4, '2026-05-07 00:17:56', 'delivered', 9000000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (824, 4, 1, 9000000, 9000000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00825', 25, 1, '2026-04-24 14:03:14', 'delivered', 18500000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (825, 5, 2, 9250000, 18500000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00826', 26, 2, '2026-03-09 22:13:52', 'delivered', 9500000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (826, 6, 1, 9500000, 9500000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00827', 27, 3, '2026-05-08 20:14:25', 'delivered', 19500000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (827, 7, 2, 9750000, 19500000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00828', 28, 4, '2026-05-07 17:18:51', 'delivered', 10000000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (828, 8, 1, 10000000, 10000000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00829', 29, 1, '2026-03-12 04:25:44', 'delivered', 20500000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (829, 9, 2, 10250000, 20500000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00830', 30, 2, '2026-03-16 07:39:37', 'delivered', 10500000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (830, 10, 1, 10500000, 10500000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00831', 31, 3, '2026-04-12 10:06:16', 'delivered', 21500000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (831, 11, 2, 10750000, 21500000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00832', 32, 4, '2026-03-07 23:34:44', 'delivered', 11000000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (832, 12, 1, 11000000, 11000000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00833', 33, 1, '2026-04-06 07:30:34', 'delivered', 12900000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (833, 13, 2, 6450000, 12900000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00834', 34, 2, '2026-03-04 07:18:13', 'delivered', 6600000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (834, 14, 1, 6600000, 6600000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00835', 35, 3, '2026-02-25 12:50:29', 'delivered', 13500000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (835, 15, 2, 6750000, 13500000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00836', 36, 4, '2026-05-24 00:42:50', 'delivered', 6900000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (836, 16, 1, 6900000, 6900000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00837', 37, 1, '2026-03-12 16:01:52', 'delivered', 14100000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (837, 17, 2, 7050000, 14100000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00838', 38, 2, '2026-04-28 20:51:42', 'delivered', 7200000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (838, 18, 1, 7200000, 7200000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00839', 39, 3, '2026-05-30 19:25:12', 'delivered', 14700000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (839, 19, 2, 7350000, 14700000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00840', 40, 4, '2026-05-01 11:52:51', 'delivered', 7500000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (840, 20, 1, 7500000, 7500000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00841', 41, 1, '2026-04-14 10:32:53', 'delivered', 16500000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (841, 1, 2, 8250000, 16500000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00842', 42, 2, '2026-03-11 03:32:41', 'delivered', 8500000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (842, 2, 1, 8500000, 8500000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00843', 43, 3, '2026-03-20 12:57:34', 'delivered', 17500000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (843, 3, 2, 8750000, 17500000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00844', 44, 4, '2026-03-11 04:09:25', 'delivered', 9000000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (844, 4, 1, 9000000, 9000000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00845', 45, 1, '2026-04-26 19:31:07', 'delivered', 18500000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (845, 5, 2, 9250000, 18500000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00846', 46, 2, '2026-02-13 21:45:38', 'delivered', 9500000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (846, 6, 1, 9500000, 9500000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00847', 47, 3, '2026-03-11 11:42:04', 'delivered', 19500000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (847, 7, 2, 9750000, 19500000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00848', 48, 4, '2026-05-14 01:42:44', 'delivered', 10000000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (848, 8, 1, 10000000, 10000000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00849', 49, 1, '2026-05-02 22:04:40', 'delivered', 20500000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (849, 9, 2, 10250000, 20500000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00850', 50, 2, '2026-05-03 00:32:34', 'delivered', 10500000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (850, 10, 1, 10500000, 10500000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00851', 51, 3, '2026-03-11 07:19:00', 'delivered', 21500000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (851, 11, 2, 10750000, 21500000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00852', 52, 4, '2026-05-27 18:21:30', 'delivered', 11000000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (852, 12, 1, 11000000, 11000000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00853', 53, 1, '2026-04-22 14:05:18', 'delivered', 12900000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (853, 13, 2, 6450000, 12900000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00854', 54, 2, '2026-03-14 07:07:45', 'delivered', 6600000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (854, 14, 1, 6600000, 6600000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00855', 55, 3, '2026-03-18 19:40:03', 'delivered', 13500000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (855, 15, 2, 6750000, 13500000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00856', 56, 4, '2026-03-20 07:58:24', 'delivered', 6900000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (856, 16, 1, 6900000, 6900000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00857', 57, 1, '2026-05-16 10:59:55', 'delivered', 14100000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (857, 17, 2, 7050000, 14100000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00858', 58, 2, '2026-05-10 14:25:45', 'delivered', 7200000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (858, 18, 1, 7200000, 7200000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00859', 59, 3, '2026-04-14 13:00:57', 'delivered', 14700000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (859, 19, 2, 7350000, 14700000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00860', 60, 4, '2026-02-12 19:16:15', 'delivered', 7500000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (860, 20, 1, 7500000, 7500000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00861', 61, 1, '2026-02-08 07:52:41', 'delivered', 16500000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (861, 1, 2, 8250000, 16500000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00862', 62, 2, '2026-02-05 14:48:24', 'delivered', 8500000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (862, 2, 1, 8500000, 8500000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00863', 63, 3, '2026-03-01 03:57:11', 'delivered', 17500000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (863, 3, 2, 8750000, 17500000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00864', 64, 4, '2026-02-28 21:04:03', 'delivered', 9000000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (864, 4, 1, 9000000, 9000000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00865', 65, 1, '2026-04-20 08:07:33', 'delivered', 18500000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (865, 5, 2, 9250000, 18500000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00866', 66, 2, '2026-03-17 20:29:50', 'delivered', 9500000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (866, 6, 1, 9500000, 9500000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00867', 67, 3, '2026-04-12 05:12:49', 'delivered', 19500000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (867, 7, 2, 9750000, 19500000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00868', 68, 4, '2026-02-10 16:21:44', 'delivered', 10000000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (868, 8, 1, 10000000, 10000000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00869', 69, 1, '2026-03-23 21:50:05', 'delivered', 20500000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (869, 9, 2, 10250000, 20500000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00870', 70, 2, '2026-05-06 18:12:45', 'delivered', 10500000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (870, 10, 1, 10500000, 10500000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00871', 71, 3, '2026-02-17 07:17:36', 'delivered', 21500000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (871, 11, 2, 10750000, 21500000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00872', 72, 4, '2026-05-11 03:39:57', 'delivered', 11000000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (872, 12, 1, 11000000, 11000000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00873', 73, 1, '2026-03-19 22:38:55', 'delivered', 12900000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (873, 13, 2, 6450000, 12900000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00874', 74, 2, '2026-03-07 00:31:30', 'delivered', 6600000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (874, 14, 1, 6600000, 6600000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00875', 75, 3, '2026-03-12 05:25:36', 'delivered', 13500000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (875, 15, 2, 6750000, 13500000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00876', 76, 4, '2026-02-27 14:22:14', 'delivered', 6900000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (876, 16, 1, 6900000, 6900000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00877', 77, 1, '2026-02-23 00:30:16', 'delivered', 14100000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (877, 17, 2, 7050000, 14100000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00878', 78, 2, '2026-03-24 21:46:57', 'delivered', 7200000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (878, 18, 1, 7200000, 7200000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00879', 79, 3, '2026-03-29 00:26:14', 'delivered', 14700000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (879, 19, 2, 7350000, 14700000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00880', 80, 4, '2026-02-21 23:50:30', 'delivered', 7500000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (880, 20, 1, 7500000, 7500000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00881', 81, 1, '2026-02-25 13:17:53', 'delivered', 16500000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (881, 1, 2, 8250000, 16500000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00882', 82, 2, '2026-04-17 21:24:45', 'delivered', 8500000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (882, 2, 1, 8500000, 8500000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00883', 83, 3, '2026-02-08 00:14:07', 'delivered', 17500000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (883, 3, 2, 8750000, 17500000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00884', 84, 4, '2026-03-24 11:29:24', 'delivered', 9000000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (884, 4, 1, 9000000, 9000000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00885', 85, 1, '2026-02-01 18:33:38', 'delivered', 18500000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (885, 5, 2, 9250000, 18500000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00886', 86, 2, '2026-05-23 09:40:47', 'delivered', 9500000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (886, 6, 1, 9500000, 9500000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00887', 87, 3, '2026-02-11 20:25:20', 'delivered', 19500000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (887, 7, 2, 9750000, 19500000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00888', 88, 4, '2026-04-01 02:16:09', 'delivered', 10000000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (888, 8, 1, 10000000, 10000000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00889', 89, 1, '2026-02-14 17:25:59', 'delivered', 20500000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (889, 9, 2, 10250000, 20500000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00890', 90, 2, '2026-02-11 21:58:48', 'delivered', 10500000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (890, 10, 1, 10500000, 10500000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00891', 91, 3, '2026-03-26 07:31:10', 'delivered', 21500000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (891, 11, 2, 10750000, 21500000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00892', 92, 4, '2026-02-10 21:35:42', 'delivered', 11000000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (892, 12, 1, 11000000, 11000000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00893', 93, 1, '2026-04-22 22:00:23', 'delivered', 12900000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (893, 13, 2, 6450000, 12900000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00894', 94, 2, '2026-04-04 21:24:07', 'delivered', 6600000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (894, 14, 1, 6600000, 6600000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00895', 95, 3, '2026-04-09 20:25:22', 'delivered', 13500000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (895, 15, 2, 6750000, 13500000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00896', 96, 4, '2026-05-28 21:14:47', 'delivered', 6900000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (896, 16, 1, 6900000, 6900000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00897', 97, 1, '2026-03-20 10:34:39', 'delivered', 14100000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (897, 17, 2, 7050000, 14100000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00898', 98, 2, '2026-04-19 13:18:31', 'delivered', 7200000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (898, 18, 1, 7200000, 7200000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00899', 99, 3, '2026-04-01 11:59:30', 'delivered', 14700000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (899, 19, 2, 7350000, 14700000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00900', 100, 4, '2026-04-13 16:11:22', 'delivered', 7500000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (900, 20, 1, 7500000, 7500000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00901', 1, 1, '2026-04-09 07:20:22', 'processing', 16500000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (901, 1, 2, 8250000, 16500000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00902', 2, 2, '2026-02-26 00:11:01', 'shipped', 8500000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (902, 2, 1, 8500000, 8500000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00903', 3, 3, '2026-02-22 04:24:08', 'delivered', 17500000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (903, 3, 2, 8750000, 17500000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00904', 4, 4, '2026-05-08 11:53:35', 'cancelled', 9000000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (904, 4, 1, 9000000, 9000000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00905', 5, 1, '2026-04-18 00:12:17', 'pending', 18500000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (905, 5, 2, 9250000, 18500000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00906', 6, 2, '2026-05-03 14:18:13', 'processing', 9500000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (906, 6, 1, 9500000, 9500000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00907', 7, 3, '2026-05-01 18:39:26', 'shipped', 19500000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (907, 7, 2, 9750000, 19500000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00908', 8, 4, '2026-05-21 06:22:52', 'delivered', 10000000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (908, 8, 1, 10000000, 10000000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00909', 9, 1, '2026-03-18 02:30:15', 'cancelled', 20500000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (909, 9, 2, 10250000, 20500000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00910', 10, 2, '2026-04-07 10:03:58', 'pending', 10500000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (910, 10, 1, 10500000, 10500000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00911', 11, 3, '2026-05-02 17:55:59', 'processing', 21500000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (911, 11, 2, 10750000, 21500000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00912', 12, 4, '2026-03-07 09:36:46', 'shipped', 11000000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (912, 12, 1, 11000000, 11000000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00913', 13, 1, '2026-04-17 12:59:52', 'delivered', 12900000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (913, 13, 2, 6450000, 12900000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00914', 14, 2, '2026-04-22 11:25:00', 'cancelled', 6600000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (914, 14, 1, 6600000, 6600000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00915', 15, 3, '2026-02-13 01:19:14', 'pending', 13500000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (915, 15, 2, 6750000, 13500000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00916', 16, 4, '2026-04-07 14:33:44', 'processing', 6900000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (916, 16, 1, 6900000, 6900000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00917', 17, 1, '2026-02-27 13:58:30', 'shipped', 14100000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (917, 17, 2, 7050000, 14100000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00918', 18, 2, '2026-03-03 07:50:53', 'delivered', 7200000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (918, 18, 1, 7200000, 7200000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00919', 19, 3, '2026-04-17 11:52:37', 'cancelled', 14700000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (919, 19, 2, 7350000, 14700000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00920', 20, 4, '2026-04-22 03:52:42', 'pending', 7500000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (920, 20, 1, 7500000, 7500000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00921', 21, 1, '2026-05-11 12:23:34', 'processing', 16500000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (921, 1, 2, 8250000, 16500000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00922', 22, 2, '2026-03-02 14:32:51', 'shipped', 8500000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (922, 2, 1, 8500000, 8500000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00923', 23, 3, '2026-03-21 22:06:44', 'delivered', 17500000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (923, 3, 2, 8750000, 17500000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00924', 24, 4, '2026-03-07 22:58:50', 'cancelled', 9000000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (924, 4, 1, 9000000, 9000000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00925', 25, 1, '2026-05-13 04:49:05', 'pending', 18500000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (925, 5, 2, 9250000, 18500000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00926', 26, 2, '2026-05-16 09:17:57', 'processing', 9500000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (926, 6, 1, 9500000, 9500000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00927', 27, 3, '2026-05-12 02:43:51', 'shipped', 19500000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (927, 7, 2, 9750000, 19500000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00928', 28, 4, '2026-05-18 11:56:57', 'delivered', 10000000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (928, 8, 1, 10000000, 10000000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00929', 29, 1, '2026-04-07 11:42:45', 'cancelled', 20500000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (929, 9, 2, 10250000, 20500000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00930', 30, 2, '2026-05-13 13:22:06', 'pending', 10500000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (930, 10, 1, 10500000, 10500000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00931', 31, 3, '2026-03-10 15:10:29', 'processing', 21500000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (931, 11, 2, 10750000, 21500000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00932', 32, 4, '2026-05-28 21:00:49', 'shipped', 11000000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (932, 12, 1, 11000000, 11000000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00933', 33, 1, '2026-02-02 01:24:56', 'delivered', 12900000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (933, 13, 2, 6450000, 12900000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00934', 34, 2, '2026-05-29 21:20:28', 'cancelled', 6600000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (934, 14, 1, 6600000, 6600000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00935', 35, 3, '2026-03-08 13:25:51', 'pending', 13500000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (935, 15, 2, 6750000, 13500000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00936', 36, 4, '2026-03-10 18:26:56', 'processing', 6900000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (936, 16, 1, 6900000, 6900000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00937', 37, 1, '2026-02-28 11:56:09', 'shipped', 14100000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (937, 17, 2, 7050000, 14100000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00938', 38, 2, '2026-04-18 03:22:03', 'delivered', 7200000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (938, 18, 1, 7200000, 7200000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00939', 39, 3, '2026-04-02 14:23:55', 'cancelled', 14700000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (939, 19, 2, 7350000, 14700000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00940', 40, 4, '2026-03-04 14:56:10', 'pending', 7500000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (940, 20, 1, 7500000, 7500000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00941', 41, 1, '2026-02-24 15:59:22', 'processing', 16500000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (941, 1, 2, 8250000, 16500000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00942', 42, 2, '2026-05-03 03:31:02', 'shipped', 8500000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (942, 2, 1, 8500000, 8500000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00943', 43, 3, '2026-03-17 16:06:20', 'delivered', 17500000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (943, 3, 2, 8750000, 17500000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00944', 44, 4, '2026-03-05 01:32:20', 'cancelled', 9000000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (944, 4, 1, 9000000, 9000000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00945', 45, 1, '2026-03-11 10:16:01', 'pending', 18500000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (945, 5, 2, 9250000, 18500000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00946', 46, 2, '2026-02-18 19:02:17', 'processing', 9500000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (946, 6, 1, 9500000, 9500000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00947', 47, 3, '2026-02-04 09:56:48', 'shipped', 19500000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (947, 7, 2, 9750000, 19500000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00948', 48, 4, '2026-04-15 21:34:52', 'delivered', 10000000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (948, 8, 1, 10000000, 10000000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00949', 49, 1, '2026-05-26 13:39:06', 'cancelled', 20500000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (949, 9, 2, 10250000, 20500000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00950', 50, 2, '2026-05-09 19:49:59', 'pending', 10500000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (950, 10, 1, 10500000, 10500000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00951', 51, 3, '2026-04-18 04:20:06', 'processing', 21500000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (951, 11, 2, 10750000, 21500000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00952', 52, 4, '2026-02-14 14:14:34', 'shipped', 11000000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (952, 12, 1, 11000000, 11000000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00953', 53, 1, '2026-05-30 12:54:11', 'delivered', 12900000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (953, 13, 2, 6450000, 12900000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00954', 54, 2, '2026-05-29 16:27:23', 'cancelled', 6600000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (954, 14, 1, 6600000, 6600000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00955', 55, 3, '2026-02-13 05:29:32', 'pending', 13500000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (955, 15, 2, 6750000, 13500000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00956', 56, 4, '2026-02-19 16:11:10', 'processing', 6900000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (956, 16, 1, 6900000, 6900000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00957', 57, 1, '2026-05-04 08:36:53', 'shipped', 14100000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (957, 17, 2, 7050000, 14100000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00958', 58, 2, '2026-03-21 11:37:53', 'delivered', 7200000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (958, 18, 1, 7200000, 7200000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00959', 59, 3, '2026-03-16 21:28:46', 'cancelled', 14700000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (959, 19, 2, 7350000, 14700000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00960', 60, 4, '2026-05-06 16:03:49', 'pending', 7500000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (960, 20, 1, 7500000, 7500000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00961', 61, 1, '2026-03-02 13:43:03', 'processing', 16500000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (961, 1, 2, 8250000, 16500000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00962', 62, 2, '2026-04-04 20:23:53', 'shipped', 8500000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (962, 2, 1, 8500000, 8500000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00963', 63, 3, '2026-03-08 04:17:35', 'delivered', 17500000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (963, 3, 2, 8750000, 17500000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00964', 64, 4, '2026-03-23 04:15:56', 'cancelled', 9000000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (964, 4, 1, 9000000, 9000000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00965', 65, 1, '2026-04-14 03:56:28', 'pending', 18500000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (965, 5, 2, 9250000, 18500000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00966', 66, 2, '2026-04-29 21:05:09', 'processing', 9500000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (966, 6, 1, 9500000, 9500000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00967', 67, 3, '2026-02-06 05:17:50', 'shipped', 19500000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (967, 7, 2, 9750000, 19500000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00968', 68, 4, '2026-04-28 06:05:57', 'delivered', 10000000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (968, 8, 1, 10000000, 10000000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00969', 69, 1, '2026-03-31 15:27:15', 'cancelled', 20500000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (969, 9, 2, 10250000, 20500000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00970', 70, 2, '2026-04-29 06:54:49', 'pending', 10500000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (970, 10, 1, 10500000, 10500000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00971', 71, 3, '2026-03-08 13:38:38', 'processing', 21500000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (971, 11, 2, 10750000, 21500000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00972', 72, 4, '2026-05-12 23:50:47', 'shipped', 11000000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (972, 12, 1, 11000000, 11000000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00973', 73, 1, '2026-05-23 02:24:23', 'delivered', 12900000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (973, 13, 2, 6450000, 12900000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00974', 74, 2, '2026-03-01 09:28:57', 'cancelled', 6600000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (974, 14, 1, 6600000, 6600000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00975', 75, 3, '2026-05-03 22:59:40', 'pending', 13500000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (975, 15, 2, 6750000, 13500000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00976', 76, 4, '2026-03-02 09:04:11', 'processing', 6900000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (976, 16, 1, 6900000, 6900000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00977', 77, 1, '2026-02-22 12:29:04', 'shipped', 14100000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (977, 17, 2, 7050000, 14100000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00978', 78, 2, '2026-03-04 16:34:06', 'delivered', 7200000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (978, 18, 1, 7200000, 7200000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00979', 79, 3, '2026-03-29 03:08:33', 'cancelled', 14700000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (979, 19, 2, 7350000, 14700000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00980', 80, 4, '2026-05-05 13:13:05', 'pending', 7500000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (980, 20, 1, 7500000, 7500000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00981', 81, 1, '2026-03-29 07:53:38', 'processing', 16500000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (981, 1, 2, 8250000, 16500000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00982', 82, 2, '2026-05-07 17:14:06', 'shipped', 8500000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (982, 2, 1, 8500000, 8500000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00983', 83, 3, '2026-03-02 14:55:56', 'delivered', 17500000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (983, 3, 2, 8750000, 17500000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00984', 84, 4, '2026-02-13 21:51:07', 'cancelled', 9000000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (984, 4, 1, 9000000, 9000000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00985', 85, 1, '2026-04-13 09:39:39', 'pending', 18500000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (985, 5, 2, 9250000, 18500000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00986', 86, 2, '2026-05-13 23:14:25', 'processing', 9500000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (986, 6, 1, 9500000, 9500000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00987', 87, 3, '2026-05-01 23:54:28', 'shipped', 19500000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (987, 7, 2, 9750000, 19500000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00988', 88, 4, '2026-02-19 09:27:37', 'delivered', 10000000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (988, 8, 1, 10000000, 10000000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00989', 89, 1, '2026-04-14 19:33:28', 'cancelled', 20500000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (989, 9, 2, 10250000, 20500000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00990', 90, 2, '2026-04-03 02:33:06', 'pending', 10500000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (990, 10, 1, 10500000, 10500000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00991', 91, 3, '2026-04-28 11:51:43', 'processing', 21500000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (991, 11, 2, 10750000, 21500000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00992', 92, 4, '2026-02-02 09:27:38', 'shipped', 11000000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (992, 12, 1, 11000000, 11000000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00993', 93, 1, '2026-04-22 12:45:44', 'delivered', 12900000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (993, 13, 2, 6450000, 12900000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00994', 94, 2, '2026-02-11 19:32:58', 'cancelled', 6600000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (994, 14, 1, 6600000, 6600000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00995', 95, 3, '2026-03-03 19:15:15', 'pending', 13500000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (995, 15, 2, 6750000, 13500000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00996', 96, 4, '2026-05-02 21:34:25', 'processing', 6900000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (996, 16, 1, 6900000, 6900000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00997', 97, 1, '2026-05-22 06:12:53', 'shipped', 14100000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (997, 17, 2, 7050000, 14100000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00998', 98, 2, '2026-02-19 20:22:40', 'delivered', 7200000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (998, 18, 1, 7200000, 7200000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-00999', 99, 3, '2026-02-13 17:29:20', 'cancelled', 14700000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (999, 19, 2, 7350000, 14700000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-01000', 100, 4, '2026-03-25 01:24:52', 'pending', 7500000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (1000, 20, 1, 7500000, 7500000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-01001', 1, 1, '2026-05-18 17:21:34', 'processing', 16500000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (1001, 1, 2, 8250000, 16500000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-01002', 2, 2, '2026-03-13 12:17:02', 'shipped', 8500000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (1002, 2, 1, 8500000, 8500000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-01003', 3, 3, '2026-05-02 09:40:24', 'delivered', 17500000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (1003, 3, 2, 8750000, 17500000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-01004', 4, 4, '2026-04-16 05:47:12', 'cancelled', 9000000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (1004, 4, 1, 9000000, 9000000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-01005', 5, 1, '2026-05-12 02:19:59', 'pending', 18500000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (1005, 5, 2, 9250000, 18500000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-01006', 6, 2, '2026-05-30 13:45:55', 'processing', 9500000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (1006, 6, 1, 9500000, 9500000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-01007', 7, 3, '2026-03-20 02:40:39', 'shipped', 19500000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (1007, 7, 2, 9750000, 19500000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-01008', 8, 4, '2026-03-09 00:51:38', 'delivered', 10000000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (1008, 8, 1, 10000000, 10000000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-01009', 9, 1, '2026-03-21 13:54:55', 'cancelled', 20500000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (1009, 9, 2, 10250000, 20500000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-01010', 10, 2, '2026-03-30 17:46:58', 'pending', 10500000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (1010, 10, 1, 10500000, 10500000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-01011', 11, 3, '2026-04-22 09:13:40', 'processing', 21500000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (1011, 11, 2, 10750000, 21500000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-01012', 12, 4, '2026-04-10 05:45:06', 'shipped', 11000000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (1012, 12, 1, 11000000, 11000000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-01013', 13, 1, '2026-03-15 03:13:08', 'delivered', 12900000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (1013, 13, 2, 6450000, 12900000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-01014', 14, 2, '2026-02-09 05:20:42', 'cancelled', 6600000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (1014, 14, 1, 6600000, 6600000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-01015', 15, 3, '2026-04-30 01:17:37', 'pending', 13500000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (1015, 15, 2, 6750000, 13500000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-01016', 16, 4, '2026-03-22 23:53:40', 'processing', 6900000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (1016, 16, 1, 6900000, 6900000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-01017', 17, 1, '2026-03-25 22:11:32', 'shipped', 14100000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (1017, 17, 2, 7050000, 14100000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-01018', 18, 2, '2026-05-14 12:49:38', 'delivered', 7200000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (1018, 18, 1, 7200000, 7200000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-01019', 19, 3, '2026-02-08 11:46:19', 'cancelled', 14700000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (1019, 19, 2, 7350000, 14700000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-01020', 20, 4, '2026-05-12 14:00:04', 'pending', 7500000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (1020, 20, 1, 7500000, 7500000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-01021', 21, 1, '2026-03-01 05:17:54', 'processing', 16500000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (1021, 1, 2, 8250000, 16500000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-01022', 22, 2, '2026-04-09 16:16:31', 'shipped', 8500000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (1022, 2, 1, 8500000, 8500000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-01023', 23, 3, '2026-03-24 06:22:37', 'delivered', 17500000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (1023, 3, 2, 8750000, 17500000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-01024', 24, 4, '2026-02-04 05:09:19', 'cancelled', 9000000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (1024, 4, 1, 9000000, 9000000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-01025', 25, 1, '2026-03-02 12:20:01', 'pending', 18500000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (1025, 5, 2, 9250000, 18500000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-01026', 26, 2, '2026-04-12 05:22:18', 'processing', 9500000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (1026, 6, 1, 9500000, 9500000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-01027', 27, 3, '2026-05-17 13:42:31', 'shipped', 19500000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (1027, 7, 2, 9750000, 19500000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-01028', 28, 4, '2026-04-17 07:53:51', 'delivered', 10000000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (1028, 8, 1, 10000000, 10000000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-01029', 29, 1, '2026-04-15 13:42:26', 'cancelled', 20500000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (1029, 9, 2, 10250000, 20500000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-01030', 30, 2, '2026-04-11 10:34:05', 'pending', 10500000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (1030, 10, 1, 10500000, 10500000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-01031', 31, 3, '2026-04-18 17:00:51', 'processing', 21500000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (1031, 11, 2, 10750000, 21500000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-01032', 32, 4, '2026-04-11 23:01:15', 'shipped', 11000000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (1032, 12, 1, 11000000, 11000000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-01033', 33, 1, '2026-03-04 03:55:59', 'delivered', 12900000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (1033, 13, 2, 6450000, 12900000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-01034', 34, 2, '2026-05-23 12:06:00', 'cancelled', 6600000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (1034, 14, 1, 6600000, 6600000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-01035', 35, 3, '2026-03-16 11:02:15', 'pending', 13500000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (1035, 15, 2, 6750000, 13500000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-01036', 36, 4, '2026-03-15 18:07:51', 'processing', 6900000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (1036, 16, 1, 6900000, 6900000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-01037', 37, 1, '2026-03-15 13:01:18', 'shipped', 14100000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (1037, 17, 2, 7050000, 14100000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-01038', 38, 2, '2026-03-30 10:20:56', 'delivered', 7200000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (1038, 18, 1, 7200000, 7200000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-01039', 39, 3, '2026-03-22 05:30:41', 'cancelled', 14700000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (1039, 19, 2, 7350000, 14700000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-01040', 40, 4, '2026-03-15 17:27:30', 'pending', 7500000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (1040, 20, 1, 7500000, 7500000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-01041', 41, 1, '2026-04-20 19:06:25', 'processing', 16500000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (1041, 1, 2, 8250000, 16500000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-01042', 42, 2, '2026-02-05 05:30:33', 'shipped', 8500000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (1042, 2, 1, 8500000, 8500000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-01043', 43, 3, '2026-03-20 18:51:43', 'delivered', 17500000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (1043, 3, 2, 8750000, 17500000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-01044', 44, 4, '2026-02-23 11:15:03', 'cancelled', 9000000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (1044, 4, 1, 9000000, 9000000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-01045', 45, 1, '2026-02-04 06:03:46', 'pending', 18500000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (1045, 5, 2, 9250000, 18500000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-01046', 46, 2, '2026-04-09 16:06:02', 'processing', 9500000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (1046, 6, 1, 9500000, 9500000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-01047', 47, 3, '2026-03-04 12:43:23', 'shipped', 19500000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (1047, 7, 2, 9750000, 19500000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-01048', 48, 4, '2026-05-20 12:46:31', 'delivered', 10000000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (1048, 8, 1, 10000000, 10000000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-01049', 49, 1, '2026-05-11 14:11:38', 'cancelled', 20500000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (1049, 9, 2, 10250000, 20500000);
INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by) VALUES ('ORD-2026-01050', 50, 2, '2026-05-10 10:56:00', 'pending', 10500000, 2);
INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (1050, 10, 1, 10500000, 10500000);

-- SEED: Returns (20)
INSERT INTO returns (order_id, product_id, quantity, reason, return_date, status) VALUES (11, 1, 1, 'Product defect / customer request', '2026-03-24', 'approved');
INSERT INTO returns (order_id, product_id, quantity, reason, return_date, status) VALUES (21, 2, 1, 'Product defect / customer request', '2026-05-05', 'completed');
INSERT INTO returns (order_id, product_id, quantity, reason, return_date, status) VALUES (31, 3, 1, 'Product defect / customer request', '2026-03-09', 'pending');
INSERT INTO returns (order_id, product_id, quantity, reason, return_date, status) VALUES (41, 4, 1, 'Product defect / customer request', '2026-05-03', 'approved');
INSERT INTO returns (order_id, product_id, quantity, reason, return_date, status) VALUES (51, 5, 1, 'Product defect / customer request', '2026-03-09', 'completed');
INSERT INTO returns (order_id, product_id, quantity, reason, return_date, status) VALUES (61, 6, 1, 'Product defect / customer request', '2026-05-03', 'pending');
INSERT INTO returns (order_id, product_id, quantity, reason, return_date, status) VALUES (71, 7, 1, 'Product defect / customer request', '2026-04-11', 'approved');
INSERT INTO returns (order_id, product_id, quantity, reason, return_date, status) VALUES (81, 8, 1, 'Product defect / customer request', '2026-04-18', 'completed');
INSERT INTO returns (order_id, product_id, quantity, reason, return_date, status) VALUES (91, 9, 1, 'Product defect / customer request', '2026-02-01', 'pending');
INSERT INTO returns (order_id, product_id, quantity, reason, return_date, status) VALUES (101, 10, 1, 'Product defect / customer request', '2026-05-14', 'approved');
INSERT INTO returns (order_id, product_id, quantity, reason, return_date, status) VALUES (111, 11, 1, 'Product defect / customer request', '2026-04-23', 'completed');
INSERT INTO returns (order_id, product_id, quantity, reason, return_date, status) VALUES (121, 12, 1, 'Product defect / customer request', '2026-04-19', 'pending');
INSERT INTO returns (order_id, product_id, quantity, reason, return_date, status) VALUES (131, 13, 1, 'Product defect / customer request', '2026-02-08', 'approved');
INSERT INTO returns (order_id, product_id, quantity, reason, return_date, status) VALUES (141, 14, 1, 'Product defect / customer request', '2026-03-11', 'completed');
INSERT INTO returns (order_id, product_id, quantity, reason, return_date, status) VALUES (151, 15, 1, 'Product defect / customer request', '2026-04-10', 'pending');
INSERT INTO returns (order_id, product_id, quantity, reason, return_date, status) VALUES (161, 16, 1, 'Product defect / customer request', '2026-03-24', 'approved');
INSERT INTO returns (order_id, product_id, quantity, reason, return_date, status) VALUES (171, 17, 1, 'Product defect / customer request', '2026-04-06', 'completed');
INSERT INTO returns (order_id, product_id, quantity, reason, return_date, status) VALUES (181, 18, 1, 'Product defect / customer request', '2026-04-27', 'pending');
INSERT INTO returns (order_id, product_id, quantity, reason, return_date, status) VALUES (191, 19, 1, 'Product defect / customer request', '2026-05-24', 'approved');
INSERT INTO returns (order_id, product_id, quantity, reason, return_date, status) VALUES (201, 20, 1, 'Product defect / customer request', '2026-03-13', 'completed');

-- SEED: Stock Movements
INSERT INTO stock_movements (product_id, movement_type, quantity, reference_type, reference_id, notes, created_by) VALUES (1, 'IN', 53, 'product', 1, 'Initial stock', 1);
INSERT INTO stock_movements (product_id, movement_type, quantity, reference_type, reference_id, notes, created_by) VALUES (2, 'IN', 56, 'product', 2, 'Initial stock', 1);
INSERT INTO stock_movements (product_id, movement_type, quantity, reference_type, reference_id, notes, created_by) VALUES (3, 'IN', 59, 'product', 3, 'Initial stock', 1);
INSERT INTO stock_movements (product_id, movement_type, quantity, reference_type, reference_id, notes, created_by) VALUES (4, 'IN', 62, 'product', 4, 'Initial stock', 1);
INSERT INTO stock_movements (product_id, movement_type, quantity, reference_type, reference_id, notes, created_by) VALUES (5, 'IN', 65, 'product', 5, 'Initial stock', 1);
INSERT INTO stock_movements (product_id, movement_type, quantity, reference_type, reference_id, notes, created_by) VALUES (6, 'IN', 68, 'product', 6, 'Initial stock', 1);
INSERT INTO stock_movements (product_id, movement_type, quantity, reference_type, reference_id, notes, created_by) VALUES (7, 'IN', 71, 'product', 7, 'Initial stock', 1);
INSERT INTO stock_movements (product_id, movement_type, quantity, reference_type, reference_id, notes, created_by) VALUES (8, 'IN', 74, 'product', 8, 'Initial stock', 1);
INSERT INTO stock_movements (product_id, movement_type, quantity, reference_type, reference_id, notes, created_by) VALUES (9, 'IN', 77, 'product', 9, 'Initial stock', 1);
INSERT INTO stock_movements (product_id, movement_type, quantity, reference_type, reference_id, notes, created_by) VALUES (10, 'IN', 80, 'product', 10, 'Initial stock', 1);
INSERT INTO stock_movements (product_id, movement_type, quantity, reference_type, reference_id, notes, created_by) VALUES (11, 'IN', 83, 'product', 11, 'Initial stock', 1);
INSERT INTO stock_movements (product_id, movement_type, quantity, reference_type, reference_id, notes, created_by) VALUES (12, 'IN', 86, 'product', 12, 'Initial stock', 1);
INSERT INTO stock_movements (product_id, movement_type, quantity, reference_type, reference_id, notes, created_by) VALUES (13, 'IN', 89, 'product', 13, 'Initial stock', 1);
INSERT INTO stock_movements (product_id, movement_type, quantity, reference_type, reference_id, notes, created_by) VALUES (14, 'IN', 92, 'product', 14, 'Initial stock', 1);
INSERT INTO stock_movements (product_id, movement_type, quantity, reference_type, reference_id, notes, created_by) VALUES (15, 'IN', 95, 'product', 15, 'Initial stock', 1);
INSERT INTO stock_movements (product_id, movement_type, quantity, reference_type, reference_id, notes, created_by) VALUES (16, 'IN', 98, 'product', 16, 'Initial stock', 1);
INSERT INTO stock_movements (product_id, movement_type, quantity, reference_type, reference_id, notes, created_by) VALUES (17, 'IN', 101, 'product', 17, 'Initial stock', 1);
INSERT INTO stock_movements (product_id, movement_type, quantity, reference_type, reference_id, notes, created_by) VALUES (18, 'IN', 104, 'product', 18, 'Initial stock', 1);
INSERT INTO stock_movements (product_id, movement_type, quantity, reference_type, reference_id, notes, created_by) VALUES (19, 'IN', 107, 'product', 19, 'Initial stock', 1);
INSERT INTO stock_movements (product_id, movement_type, quantity, reference_type, reference_id, notes, created_by) VALUES (20, 'IN', 110, 'product', 20, 'Initial stock', 1);
INSERT INTO stock_movements (product_id, movement_type, quantity, reference_type, reference_id, notes, created_by, created_at) VALUES (2, 'OUT', 2, 'marketplace_order', 1, 'Auto stock out', 2, '2026-04-12 00:45:23');
INSERT INTO stock_movements (product_id, movement_type, quantity, reference_type, reference_id, notes, created_by, created_at) VALUES (3, 'OUT', 3, 'marketplace_order', 2, 'Auto stock out', 2, '2026-02-03 08:55:58');
INSERT INTO stock_movements (product_id, movement_type, quantity, reference_type, reference_id, notes, created_by, created_at) VALUES (4, 'OUT', 1, 'marketplace_order', 3, 'Auto stock out', 2, '2026-03-15 04:36:50');
INSERT INTO stock_movements (product_id, movement_type, quantity, reference_type, reference_id, notes, created_by, created_at) VALUES (5, 'OUT', 2, 'marketplace_order', 4, 'Auto stock out', 2, '2026-02-12 08:43:45');
INSERT INTO stock_movements (product_id, movement_type, quantity, reference_type, reference_id, notes, created_by, created_at) VALUES (6, 'OUT', 3, 'marketplace_order', 5, 'Auto stock out', 2, '2026-03-02 05:35:41');
INSERT INTO stock_movements (product_id, movement_type, quantity, reference_type, reference_id, notes, created_by, created_at) VALUES (7, 'OUT', 1, 'marketplace_order', 6, 'Auto stock out', 2, '2026-02-17 02:04:14');
INSERT INTO stock_movements (product_id, movement_type, quantity, reference_type, reference_id, notes, created_by, created_at) VALUES (8, 'OUT', 2, 'marketplace_order', 7, 'Auto stock out', 2, '2026-03-29 08:51:33');
INSERT INTO stock_movements (product_id, movement_type, quantity, reference_type, reference_id, notes, created_by, created_at) VALUES (9, 'OUT', 3, 'marketplace_order', 8, 'Auto stock out', 2, '2026-03-31 11:58:09');
INSERT INTO stock_movements (product_id, movement_type, quantity, reference_type, reference_id, notes, created_by, created_at) VALUES (10, 'OUT', 1, 'marketplace_order', 9, 'Auto stock out', 2, '2026-03-20 11:10:57');
INSERT INTO stock_movements (product_id, movement_type, quantity, reference_type, reference_id, notes, created_by, created_at) VALUES (11, 'OUT', 2, 'marketplace_order', 10, 'Auto stock out', 2, '2026-03-22 06:30:15');
INSERT INTO stock_movements (product_id, movement_type, quantity, reference_type, reference_id, notes, created_by, created_at) VALUES (12, 'OUT', 3, 'marketplace_order', 11, 'Auto stock out', 2, '2026-05-03 06:23:40');
INSERT INTO stock_movements (product_id, movement_type, quantity, reference_type, reference_id, notes, created_by, created_at) VALUES (13, 'OUT', 1, 'marketplace_order', 12, 'Auto stock out', 2, '2026-04-25 05:32:54');
INSERT INTO stock_movements (product_id, movement_type, quantity, reference_type, reference_id, notes, created_by, created_at) VALUES (14, 'OUT', 2, 'marketplace_order', 13, 'Auto stock out', 2, '2026-02-11 13:02:53');
INSERT INTO stock_movements (product_id, movement_type, quantity, reference_type, reference_id, notes, created_by, created_at) VALUES (15, 'OUT', 3, 'marketplace_order', 14, 'Auto stock out', 2, '2026-02-04 15:50:43');
INSERT INTO stock_movements (product_id, movement_type, quantity, reference_type, reference_id, notes, created_by, created_at) VALUES (16, 'OUT', 1, 'marketplace_order', 15, 'Auto stock out', 2, '2026-05-10 06:07:19');
INSERT INTO stock_movements (product_id, movement_type, quantity, reference_type, reference_id, notes, created_by, created_at) VALUES (17, 'OUT', 2, 'marketplace_order', 16, 'Auto stock out', 2, '2026-03-01 03:46:51');
INSERT INTO stock_movements (product_id, movement_type, quantity, reference_type, reference_id, notes, created_by, created_at) VALUES (18, 'OUT', 3, 'marketplace_order', 17, 'Auto stock out', 2, '2026-04-11 03:49:16');
INSERT INTO stock_movements (product_id, movement_type, quantity, reference_type, reference_id, notes, created_by, created_at) VALUES (19, 'OUT', 1, 'marketplace_order', 18, 'Auto stock out', 2, '2026-05-11 15:38:39');
INSERT INTO stock_movements (product_id, movement_type, quantity, reference_type, reference_id, notes, created_by, created_at) VALUES (20, 'OUT', 2, 'marketplace_order', 19, 'Auto stock out', 2, '2026-04-28 20:32:33');
INSERT INTO stock_movements (product_id, movement_type, quantity, reference_type, reference_id, notes, created_by, created_at) VALUES (1, 'OUT', 3, 'marketplace_order', 20, 'Auto stock out', 2, '2026-03-02 08:36:47');
INSERT INTO stock_movements (product_id, movement_type, quantity, reference_type, reference_id, notes, created_by, created_at) VALUES (2, 'OUT', 1, 'marketplace_order', 21, 'Auto stock out', 2, '2026-03-07 18:26:57');
INSERT INTO stock_movements (product_id, movement_type, quantity, reference_type, reference_id, notes, created_by, created_at) VALUES (3, 'OUT', 2, 'marketplace_order', 22, 'Auto stock out', 2, '2026-04-13 21:31:06');
INSERT INTO stock_movements (product_id, movement_type, quantity, reference_type, reference_id, notes, created_by, created_at) VALUES (4, 'OUT', 3, 'marketplace_order', 23, 'Auto stock out', 2, '2026-03-15 08:45:20');
INSERT INTO stock_movements (product_id, movement_type, quantity, reference_type, reference_id, notes, created_by, created_at) VALUES (5, 'OUT', 1, 'marketplace_order', 24, 'Auto stock out', 2, '2026-03-21 02:04:32');
INSERT INTO stock_movements (product_id, movement_type, quantity, reference_type, reference_id, notes, created_by, created_at) VALUES (6, 'OUT', 2, 'marketplace_order', 25, 'Auto stock out', 2, '2026-03-11 15:11:06');
INSERT INTO stock_movements (product_id, movement_type, quantity, reference_type, reference_id, notes, created_by, created_at) VALUES (7, 'OUT', 3, 'marketplace_order', 26, 'Auto stock out', 2, '2026-05-30 15:20:50');
INSERT INTO stock_movements (product_id, movement_type, quantity, reference_type, reference_id, notes, created_by, created_at) VALUES (8, 'OUT', 1, 'marketplace_order', 27, 'Auto stock out', 2, '2026-04-29 22:04:46');
INSERT INTO stock_movements (product_id, movement_type, quantity, reference_type, reference_id, notes, created_by, created_at) VALUES (9, 'OUT', 2, 'marketplace_order', 28, 'Auto stock out', 2, '2026-05-21 06:17:23');
INSERT INTO stock_movements (product_id, movement_type, quantity, reference_type, reference_id, notes, created_by, created_at) VALUES (10, 'OUT', 3, 'marketplace_order', 29, 'Auto stock out', 2, '2026-02-28 15:55:05');
INSERT INTO stock_movements (product_id, movement_type, quantity, reference_type, reference_id, notes, created_by, created_at) VALUES (11, 'OUT', 1, 'marketplace_order', 30, 'Auto stock out', 2, '2026-02-10 23:32:58');
INSERT INTO stock_movements (product_id, movement_type, quantity, reference_type, reference_id, notes, created_by, created_at) VALUES (12, 'OUT', 2, 'marketplace_order', 31, 'Auto stock out', 2, '2026-03-29 20:51:54');
INSERT INTO stock_movements (product_id, movement_type, quantity, reference_type, reference_id, notes, created_by, created_at) VALUES (13, 'OUT', 3, 'marketplace_order', 32, 'Auto stock out', 2, '2026-02-04 18:03:14');
INSERT INTO stock_movements (product_id, movement_type, quantity, reference_type, reference_id, notes, created_by, created_at) VALUES (14, 'OUT', 1, 'marketplace_order', 33, 'Auto stock out', 2, '2026-03-30 07:35:53');
INSERT INTO stock_movements (product_id, movement_type, quantity, reference_type, reference_id, notes, created_by, created_at) VALUES (15, 'OUT', 2, 'marketplace_order', 34, 'Auto stock out', 2, '2026-02-26 19:14:21');
INSERT INTO stock_movements (product_id, movement_type, quantity, reference_type, reference_id, notes, created_by, created_at) VALUES (16, 'OUT', 3, 'marketplace_order', 35, 'Auto stock out', 2, '2026-04-23 08:28:51');
INSERT INTO stock_movements (product_id, movement_type, quantity, reference_type, reference_id, notes, created_by, created_at) VALUES (17, 'OUT', 1, 'marketplace_order', 36, 'Auto stock out', 2, '2026-04-22 12:30:55');
INSERT INTO stock_movements (product_id, movement_type, quantity, reference_type, reference_id, notes, created_by, created_at) VALUES (18, 'OUT', 2, 'marketplace_order', 37, 'Auto stock out', 2, '2026-02-17 11:53:03');
INSERT INTO stock_movements (product_id, movement_type, quantity, reference_type, reference_id, notes, created_by, created_at) VALUES (19, 'OUT', 3, 'marketplace_order', 38, 'Auto stock out', 2, '2026-05-25 20:01:51');
INSERT INTO stock_movements (product_id, movement_type, quantity, reference_type, reference_id, notes, created_by, created_at) VALUES (20, 'OUT', 1, 'marketplace_order', 39, 'Auto stock out', 2, '2026-04-18 05:45:13');
INSERT INTO stock_movements (product_id, movement_type, quantity, reference_type, reference_id, notes, created_by, created_at) VALUES (1, 'OUT', 2, 'marketplace_order', 40, 'Auto stock out', 2, '2026-03-20 18:31:25');
INSERT INTO stock_movements (product_id, movement_type, quantity, reference_type, reference_id, notes, created_by, created_at) VALUES (2, 'OUT', 3, 'marketplace_order', 41, 'Auto stock out', 2, '2026-04-30 19:40:27');
INSERT INTO stock_movements (product_id, movement_type, quantity, reference_type, reference_id, notes, created_by, created_at) VALUES (3, 'OUT', 1, 'marketplace_order', 42, 'Auto stock out', 2, '2026-05-21 12:07:05');
INSERT INTO stock_movements (product_id, movement_type, quantity, reference_type, reference_id, notes, created_by, created_at) VALUES (4, 'OUT', 2, 'marketplace_order', 43, 'Auto stock out', 2, '2026-03-13 03:08:34');
INSERT INTO stock_movements (product_id, movement_type, quantity, reference_type, reference_id, notes, created_by, created_at) VALUES (5, 'OUT', 3, 'marketplace_order', 44, 'Auto stock out', 2, '2026-03-27 14:46:20');
INSERT INTO stock_movements (product_id, movement_type, quantity, reference_type, reference_id, notes, created_by, created_at) VALUES (6, 'OUT', 1, 'marketplace_order', 45, 'Auto stock out', 2, '2026-02-10 22:54:17');
INSERT INTO stock_movements (product_id, movement_type, quantity, reference_type, reference_id, notes, created_by, created_at) VALUES (7, 'OUT', 2, 'marketplace_order', 46, 'Auto stock out', 2, '2026-03-06 00:26:53');
INSERT INTO stock_movements (product_id, movement_type, quantity, reference_type, reference_id, notes, created_by, created_at) VALUES (8, 'OUT', 3, 'marketplace_order', 47, 'Auto stock out', 2, '2026-02-03 17:53:41');
INSERT INTO stock_movements (product_id, movement_type, quantity, reference_type, reference_id, notes, created_by, created_at) VALUES (9, 'OUT', 1, 'marketplace_order', 48, 'Auto stock out', 2, '2026-05-12 21:21:48');
INSERT INTO stock_movements (product_id, movement_type, quantity, reference_type, reference_id, notes, created_by, created_at) VALUES (10, 'OUT', 2, 'marketplace_order', 49, 'Auto stock out', 2, '2026-04-11 11:42:37');
INSERT INTO stock_movements (product_id, movement_type, quantity, reference_type, reference_id, notes, created_by, created_at) VALUES (11, 'OUT', 3, 'marketplace_order', 50, 'Auto stock out', 2, '2026-03-28 14:07:56');

-- SEED: Activity Logs
INSERT INTO activity_logs (user_id, action, module, description, created_at) VALUES (2, 'CREATE', 'Products', 'System activity log entry #1', '2026-03-09 13:37:21');
INSERT INTO activity_logs (user_id, action, module, description, created_at) VALUES (3, 'UPDATE', 'Users', 'System activity log entry #2', '2026-05-18 09:22:37');
INSERT INTO activity_logs (user_id, action, module, description, created_at) VALUES (4, 'DELETE', 'Live Schedules', 'System activity log entry #3', '2026-03-14 17:12:59');
INSERT INTO activity_logs (user_id, action, module, description, created_at) VALUES (5, 'VIEW', 'Live Sales', 'System activity log entry #4', '2026-04-03 09:17:14');
INSERT INTO activity_logs (user_id, action, module, description, created_at) VALUES (1, 'LOGIN', 'Marketplace', 'System activity log entry #5', '2026-04-14 18:36:17');
INSERT INTO activity_logs (user_id, action, module, description, created_at) VALUES (2, 'CREATE', 'Returns', 'System activity log entry #6', '2026-03-04 23:45:09');
INSERT INTO activity_logs (user_id, action, module, description, created_at) VALUES (3, 'UPDATE', 'Auth', 'System activity log entry #7', '2026-04-10 03:35:43');
INSERT INTO activity_logs (user_id, action, module, description, created_at) VALUES (4, 'DELETE', 'Products', 'System activity log entry #8', '2026-05-07 00:06:39');
INSERT INTO activity_logs (user_id, action, module, description, created_at) VALUES (5, 'VIEW', 'Users', 'System activity log entry #9', '2026-05-15 04:34:26');
INSERT INTO activity_logs (user_id, action, module, description, created_at) VALUES (1, 'LOGIN', 'Live Schedules', 'System activity log entry #10', '2026-03-01 14:55:47');
INSERT INTO activity_logs (user_id, action, module, description, created_at) VALUES (2, 'CREATE', 'Live Sales', 'System activity log entry #11', '2026-03-29 08:01:24');
INSERT INTO activity_logs (user_id, action, module, description, created_at) VALUES (3, 'UPDATE', 'Marketplace', 'System activity log entry #12', '2026-05-14 20:01:15');
INSERT INTO activity_logs (user_id, action, module, description, created_at) VALUES (4, 'DELETE', 'Returns', 'System activity log entry #13', '2026-05-05 20:51:30');
INSERT INTO activity_logs (user_id, action, module, description, created_at) VALUES (5, 'VIEW', 'Auth', 'System activity log entry #14', '2026-02-01 11:20:44');
INSERT INTO activity_logs (user_id, action, module, description, created_at) VALUES (1, 'LOGIN', 'Products', 'System activity log entry #15', '2026-02-05 17:00:19');
INSERT INTO activity_logs (user_id, action, module, description, created_at) VALUES (2, 'CREATE', 'Users', 'System activity log entry #16', '2026-02-16 19:37:02');
INSERT INTO activity_logs (user_id, action, module, description, created_at) VALUES (3, 'UPDATE', 'Live Schedules', 'System activity log entry #17', '2026-02-04 18:52:00');
INSERT INTO activity_logs (user_id, action, module, description, created_at) VALUES (4, 'DELETE', 'Live Sales', 'System activity log entry #18', '2026-05-05 09:40:35');
INSERT INTO activity_logs (user_id, action, module, description, created_at) VALUES (5, 'VIEW', 'Marketplace', 'System activity log entry #19', '2026-05-04 10:34:43');
INSERT INTO activity_logs (user_id, action, module, description, created_at) VALUES (1, 'LOGIN', 'Returns', 'System activity log entry #20', '2026-02-10 13:53:37');
INSERT INTO activity_logs (user_id, action, module, description, created_at) VALUES (2, 'CREATE', 'Auth', 'System activity log entry #21', '2026-02-08 20:22:57');
INSERT INTO activity_logs (user_id, action, module, description, created_at) VALUES (3, 'UPDATE', 'Products', 'System activity log entry #22', '2026-04-17 10:53:12');
INSERT INTO activity_logs (user_id, action, module, description, created_at) VALUES (4, 'DELETE', 'Users', 'System activity log entry #23', '2026-02-21 23:22:00');
INSERT INTO activity_logs (user_id, action, module, description, created_at) VALUES (5, 'VIEW', 'Live Schedules', 'System activity log entry #24', '2026-05-11 04:05:25');
INSERT INTO activity_logs (user_id, action, module, description, created_at) VALUES (1, 'LOGIN', 'Live Sales', 'System activity log entry #25', '2026-02-10 18:13:03');
INSERT INTO activity_logs (user_id, action, module, description, created_at) VALUES (2, 'CREATE', 'Marketplace', 'System activity log entry #26', '2026-04-02 15:06:27');
INSERT INTO activity_logs (user_id, action, module, description, created_at) VALUES (3, 'UPDATE', 'Returns', 'System activity log entry #27', '2026-03-29 20:12:34');
INSERT INTO activity_logs (user_id, action, module, description, created_at) VALUES (4, 'DELETE', 'Auth', 'System activity log entry #28', '2026-02-26 19:57:06');
INSERT INTO activity_logs (user_id, action, module, description, created_at) VALUES (5, 'VIEW', 'Products', 'System activity log entry #29', '2026-02-22 14:32:48');
INSERT INTO activity_logs (user_id, action, module, description, created_at) VALUES (1, 'LOGIN', 'Users', 'System activity log entry #30', '2026-05-27 00:42:59');
INSERT INTO activity_logs (user_id, action, module, description, created_at) VALUES (2, 'CREATE', 'Live Schedules', 'System activity log entry #31', '2026-05-14 11:40:22');
INSERT INTO activity_logs (user_id, action, module, description, created_at) VALUES (3, 'UPDATE', 'Live Sales', 'System activity log entry #32', '2026-02-05 07:39:43');
INSERT INTO activity_logs (user_id, action, module, description, created_at) VALUES (4, 'DELETE', 'Marketplace', 'System activity log entry #33', '2026-04-22 13:01:14');
INSERT INTO activity_logs (user_id, action, module, description, created_at) VALUES (5, 'VIEW', 'Returns', 'System activity log entry #34', '2026-03-20 00:51:26');
INSERT INTO activity_logs (user_id, action, module, description, created_at) VALUES (1, 'LOGIN', 'Auth', 'System activity log entry #35', '2026-02-05 15:23:11');
INSERT INTO activity_logs (user_id, action, module, description, created_at) VALUES (2, 'CREATE', 'Products', 'System activity log entry #36', '2026-05-04 05:27:22');
INSERT INTO activity_logs (user_id, action, module, description, created_at) VALUES (3, 'UPDATE', 'Users', 'System activity log entry #37', '2026-04-04 22:52:18');
INSERT INTO activity_logs (user_id, action, module, description, created_at) VALUES (4, 'DELETE', 'Live Schedules', 'System activity log entry #38', '2026-05-24 19:16:01');
INSERT INTO activity_logs (user_id, action, module, description, created_at) VALUES (5, 'VIEW', 'Live Sales', 'System activity log entry #39', '2026-05-16 12:55:34');
INSERT INTO activity_logs (user_id, action, module, description, created_at) VALUES (1, 'LOGIN', 'Marketplace', 'System activity log entry #40', '2026-05-16 06:37:41');
INSERT INTO activity_logs (user_id, action, module, description, created_at) VALUES (2, 'CREATE', 'Returns', 'System activity log entry #41', '2026-05-12 05:04:06');
INSERT INTO activity_logs (user_id, action, module, description, created_at) VALUES (3, 'UPDATE', 'Auth', 'System activity log entry #42', '2026-04-11 20:31:39');
INSERT INTO activity_logs (user_id, action, module, description, created_at) VALUES (4, 'DELETE', 'Products', 'System activity log entry #43', '2026-02-10 10:32:42');
INSERT INTO activity_logs (user_id, action, module, description, created_at) VALUES (5, 'VIEW', 'Users', 'System activity log entry #44', '2026-03-17 02:25:23');
INSERT INTO activity_logs (user_id, action, module, description, created_at) VALUES (1, 'LOGIN', 'Live Schedules', 'System activity log entry #45', '2026-03-08 23:11:46');
INSERT INTO activity_logs (user_id, action, module, description, created_at) VALUES (2, 'CREATE', 'Live Sales', 'System activity log entry #46', '2026-02-21 10:07:28');
INSERT INTO activity_logs (user_id, action, module, description, created_at) VALUES (3, 'UPDATE', 'Marketplace', 'System activity log entry #47', '2026-05-29 15:02:19');
INSERT INTO activity_logs (user_id, action, module, description, created_at) VALUES (4, 'DELETE', 'Returns', 'System activity log entry #48', '2026-05-06 02:57:24');
INSERT INTO activity_logs (user_id, action, module, description, created_at) VALUES (5, 'VIEW', 'Auth', 'System activity log entry #49', '2026-04-01 08:43:41');
INSERT INTO activity_logs (user_id, action, module, description, created_at) VALUES (1, 'LOGIN', 'Products', 'System activity log entry #50', '2026-03-15 11:53:55');
INSERT INTO activity_logs (user_id, action, module, description, created_at) VALUES (2, 'CREATE', 'Users', 'System activity log entry #51', '2026-05-25 23:15:08');
INSERT INTO activity_logs (user_id, action, module, description, created_at) VALUES (3, 'UPDATE', 'Live Schedules', 'System activity log entry #52', '2026-02-26 02:02:10');
INSERT INTO activity_logs (user_id, action, module, description, created_at) VALUES (4, 'DELETE', 'Live Sales', 'System activity log entry #53', '2026-05-23 05:40:52');
INSERT INTO activity_logs (user_id, action, module, description, created_at) VALUES (5, 'VIEW', 'Marketplace', 'System activity log entry #54', '2026-02-11 14:35:03');
INSERT INTO activity_logs (user_id, action, module, description, created_at) VALUES (1, 'LOGIN', 'Returns', 'System activity log entry #55', '2026-03-03 15:58:50');
INSERT INTO activity_logs (user_id, action, module, description, created_at) VALUES (2, 'CREATE', 'Auth', 'System activity log entry #56', '2026-04-26 09:26:55');
INSERT INTO activity_logs (user_id, action, module, description, created_at) VALUES (3, 'UPDATE', 'Products', 'System activity log entry #57', '2026-04-13 05:15:08');
INSERT INTO activity_logs (user_id, action, module, description, created_at) VALUES (4, 'DELETE', 'Users', 'System activity log entry #58', '2026-04-30 17:29:31');
INSERT INTO activity_logs (user_id, action, module, description, created_at) VALUES (5, 'VIEW', 'Live Schedules', 'System activity log entry #59', '2026-05-17 01:25:16');
INSERT INTO activity_logs (user_id, action, module, description, created_at) VALUES (1, 'LOGIN', 'Live Sales', 'System activity log entry #60', '2026-05-25 18:46:39');
INSERT INTO activity_logs (user_id, action, module, description, created_at) VALUES (2, 'CREATE', 'Marketplace', 'System activity log entry #61', '2026-04-29 22:43:44');
INSERT INTO activity_logs (user_id, action, module, description, created_at) VALUES (3, 'UPDATE', 'Returns', 'System activity log entry #62', '2026-03-28 12:48:14');
INSERT INTO activity_logs (user_id, action, module, description, created_at) VALUES (4, 'DELETE', 'Auth', 'System activity log entry #63', '2026-04-19 20:40:47');
INSERT INTO activity_logs (user_id, action, module, description, created_at) VALUES (5, 'VIEW', 'Products', 'System activity log entry #64', '2026-05-19 06:30:14');
INSERT INTO activity_logs (user_id, action, module, description, created_at) VALUES (1, 'LOGIN', 'Users', 'System activity log entry #65', '2026-05-12 16:27:33');
INSERT INTO activity_logs (user_id, action, module, description, created_at) VALUES (2, 'CREATE', 'Live Schedules', 'System activity log entry #66', '2026-03-20 05:48:52');
INSERT INTO activity_logs (user_id, action, module, description, created_at) VALUES (3, 'UPDATE', 'Live Sales', 'System activity log entry #67', '2026-04-20 11:09:56');
INSERT INTO activity_logs (user_id, action, module, description, created_at) VALUES (4, 'DELETE', 'Marketplace', 'System activity log entry #68', '2026-03-17 10:48:21');
INSERT INTO activity_logs (user_id, action, module, description, created_at) VALUES (5, 'VIEW', 'Returns', 'System activity log entry #69', '2026-04-11 11:14:50');
INSERT INTO activity_logs (user_id, action, module, description, created_at) VALUES (1, 'LOGIN', 'Auth', 'System activity log entry #70', '2026-02-07 05:07:08');
INSERT INTO activity_logs (user_id, action, module, description, created_at) VALUES (2, 'CREATE', 'Products', 'System activity log entry #71', '2026-04-02 13:54:07');
INSERT INTO activity_logs (user_id, action, module, description, created_at) VALUES (3, 'UPDATE', 'Users', 'System activity log entry #72', '2026-05-11 06:25:21');
INSERT INTO activity_logs (user_id, action, module, description, created_at) VALUES (4, 'DELETE', 'Live Schedules', 'System activity log entry #73', '2026-04-21 05:53:25');
INSERT INTO activity_logs (user_id, action, module, description, created_at) VALUES (5, 'VIEW', 'Live Sales', 'System activity log entry #74', '2026-05-12 11:56:02');
INSERT INTO activity_logs (user_id, action, module, description, created_at) VALUES (1, 'LOGIN', 'Marketplace', 'System activity log entry #75', '2026-02-09 12:34:31');
INSERT INTO activity_logs (user_id, action, module, description, created_at) VALUES (2, 'CREATE', 'Returns', 'System activity log entry #76', '2026-03-21 02:50:01');
INSERT INTO activity_logs (user_id, action, module, description, created_at) VALUES (3, 'UPDATE', 'Auth', 'System activity log entry #77', '2026-05-20 09:15:41');
INSERT INTO activity_logs (user_id, action, module, description, created_at) VALUES (4, 'DELETE', 'Products', 'System activity log entry #78', '2026-03-30 15:22:12');
INSERT INTO activity_logs (user_id, action, module, description, created_at) VALUES (5, 'VIEW', 'Users', 'System activity log entry #79', '2026-05-02 07:15:01');
INSERT INTO activity_logs (user_id, action, module, description, created_at) VALUES (1, 'LOGIN', 'Live Schedules', 'System activity log entry #80', '2026-04-15 14:41:10');
INSERT INTO activity_logs (user_id, action, module, description, created_at) VALUES (2, 'CREATE', 'Live Sales', 'System activity log entry #81', '2026-05-06 06:17:28');
INSERT INTO activity_logs (user_id, action, module, description, created_at) VALUES (3, 'UPDATE', 'Marketplace', 'System activity log entry #82', '2026-03-07 13:32:53');
INSERT INTO activity_logs (user_id, action, module, description, created_at) VALUES (4, 'DELETE', 'Returns', 'System activity log entry #83', '2026-03-04 12:18:31');
INSERT INTO activity_logs (user_id, action, module, description, created_at) VALUES (5, 'VIEW', 'Auth', 'System activity log entry #84', '2026-04-25 20:17:28');
INSERT INTO activity_logs (user_id, action, module, description, created_at) VALUES (1, 'LOGIN', 'Products', 'System activity log entry #85', '2026-05-10 05:26:53');
INSERT INTO activity_logs (user_id, action, module, description, created_at) VALUES (2, 'CREATE', 'Users', 'System activity log entry #86', '2026-05-13 00:14:21');
INSERT INTO activity_logs (user_id, action, module, description, created_at) VALUES (3, 'UPDATE', 'Live Schedules', 'System activity log entry #87', '2026-04-30 02:12:28');
INSERT INTO activity_logs (user_id, action, module, description, created_at) VALUES (4, 'DELETE', 'Live Sales', 'System activity log entry #88', '2026-03-08 06:47:42');
INSERT INTO activity_logs (user_id, action, module, description, created_at) VALUES (5, 'VIEW', 'Marketplace', 'System activity log entry #89', '2026-05-20 19:37:02');
INSERT INTO activity_logs (user_id, action, module, description, created_at) VALUES (1, 'LOGIN', 'Returns', 'System activity log entry #90', '2026-05-11 06:48:58');
INSERT INTO activity_logs (user_id, action, module, description, created_at) VALUES (2, 'CREATE', 'Auth', 'System activity log entry #91', '2026-04-18 18:40:30');
INSERT INTO activity_logs (user_id, action, module, description, created_at) VALUES (3, 'UPDATE', 'Products', 'System activity log entry #92', '2026-04-20 15:35:45');
INSERT INTO activity_logs (user_id, action, module, description, created_at) VALUES (4, 'DELETE', 'Users', 'System activity log entry #93', '2026-04-27 08:14:31');
INSERT INTO activity_logs (user_id, action, module, description, created_at) VALUES (5, 'VIEW', 'Live Schedules', 'System activity log entry #94', '2026-03-04 19:32:21');
INSERT INTO activity_logs (user_id, action, module, description, created_at) VALUES (1, 'LOGIN', 'Live Sales', 'System activity log entry #95', '2026-02-24 10:55:36');
INSERT INTO activity_logs (user_id, action, module, description, created_at) VALUES (2, 'CREATE', 'Marketplace', 'System activity log entry #96', '2026-04-14 20:15:19');
INSERT INTO activity_logs (user_id, action, module, description, created_at) VALUES (3, 'UPDATE', 'Returns', 'System activity log entry #97', '2026-02-06 20:48:33');
INSERT INTO activity_logs (user_id, action, module, description, created_at) VALUES (4, 'DELETE', 'Auth', 'System activity log entry #98', '2026-02-14 10:13:56');
INSERT INTO activity_logs (user_id, action, module, description, created_at) VALUES (5, 'VIEW', 'Products', 'System activity log entry #99', '2026-03-05 21:47:49');
INSERT INTO activity_logs (user_id, action, module, description, created_at) VALUES (1, 'LOGIN', 'Users', 'System activity log entry #100', '2026-03-17 04:20:47');
INSERT INTO activity_logs (user_id, action, module, description, created_at) VALUES (2, 'CREATE', 'Live Schedules', 'System activity log entry #101', '2026-04-28 09:03:47');
INSERT INTO activity_logs (user_id, action, module, description, created_at) VALUES (3, 'UPDATE', 'Live Sales', 'System activity log entry #102', '2026-05-16 01:31:30');
INSERT INTO activity_logs (user_id, action, module, description, created_at) VALUES (4, 'DELETE', 'Marketplace', 'System activity log entry #103', '2026-02-22 10:06:25');
INSERT INTO activity_logs (user_id, action, module, description, created_at) VALUES (5, 'VIEW', 'Returns', 'System activity log entry #104', '2026-04-21 00:14:05');
INSERT INTO activity_logs (user_id, action, module, description, created_at) VALUES (1, 'LOGIN', 'Auth', 'System activity log entry #105', '2026-03-11 03:15:31');
INSERT INTO activity_logs (user_id, action, module, description, created_at) VALUES (2, 'CREATE', 'Products', 'System activity log entry #106', '2026-05-20 09:06:49');
INSERT INTO activity_logs (user_id, action, module, description, created_at) VALUES (3, 'UPDATE', 'Users', 'System activity log entry #107', '2026-03-15 08:35:15');
INSERT INTO activity_logs (user_id, action, module, description, created_at) VALUES (4, 'DELETE', 'Live Schedules', 'System activity log entry #108', '2026-02-16 17:49:47');
INSERT INTO activity_logs (user_id, action, module, description, created_at) VALUES (5, 'VIEW', 'Live Sales', 'System activity log entry #109', '2026-05-06 09:24:48');
INSERT INTO activity_logs (user_id, action, module, description, created_at) VALUES (1, 'LOGIN', 'Marketplace', 'System activity log entry #110', '2026-02-10 12:04:54');
INSERT INTO activity_logs (user_id, action, module, description, created_at) VALUES (2, 'CREATE', 'Returns', 'System activity log entry #111', '2026-02-08 00:57:23');
INSERT INTO activity_logs (user_id, action, module, description, created_at) VALUES (3, 'UPDATE', 'Auth', 'System activity log entry #112', '2026-03-04 16:18:17');
INSERT INTO activity_logs (user_id, action, module, description, created_at) VALUES (4, 'DELETE', 'Products', 'System activity log entry #113', '2026-05-24 02:03:06');
INSERT INTO activity_logs (user_id, action, module, description, created_at) VALUES (5, 'VIEW', 'Users', 'System activity log entry #114', '2026-04-24 06:15:29');
INSERT INTO activity_logs (user_id, action, module, description, created_at) VALUES (1, 'LOGIN', 'Live Schedules', 'System activity log entry #115', '2026-02-17 13:55:43');
INSERT INTO activity_logs (user_id, action, module, description, created_at) VALUES (2, 'CREATE', 'Live Sales', 'System activity log entry #116', '2026-05-23 02:26:10');
INSERT INTO activity_logs (user_id, action, module, description, created_at) VALUES (3, 'UPDATE', 'Marketplace', 'System activity log entry #117', '2026-02-12 21:40:50');
INSERT INTO activity_logs (user_id, action, module, description, created_at) VALUES (4, 'DELETE', 'Returns', 'System activity log entry #118', '2026-05-24 18:11:46');
INSERT INTO activity_logs (user_id, action, module, description, created_at) VALUES (5, 'VIEW', 'Auth', 'System activity log entry #119', '2026-04-16 02:27:06');
INSERT INTO activity_logs (user_id, action, module, description, created_at) VALUES (1, 'LOGIN', 'Products', 'System activity log entry #120', '2026-04-09 15:47:46');
INSERT INTO activity_logs (user_id, action, module, description, created_at) VALUES (2, 'CREATE', 'Users', 'System activity log entry #121', '2026-03-14 06:47:10');
INSERT INTO activity_logs (user_id, action, module, description, created_at) VALUES (3, 'UPDATE', 'Live Schedules', 'System activity log entry #122', '2026-03-30 06:35:12');
INSERT INTO activity_logs (user_id, action, module, description, created_at) VALUES (4, 'DELETE', 'Live Sales', 'System activity log entry #123', '2026-03-21 10:26:54');
INSERT INTO activity_logs (user_id, action, module, description, created_at) VALUES (5, 'VIEW', 'Marketplace', 'System activity log entry #124', '2026-02-14 08:57:38');
INSERT INTO activity_logs (user_id, action, module, description, created_at) VALUES (1, 'LOGIN', 'Returns', 'System activity log entry #125', '2026-04-19 16:58:18');
INSERT INTO activity_logs (user_id, action, module, description, created_at) VALUES (2, 'CREATE', 'Auth', 'System activity log entry #126', '2026-03-13 00:53:16');
INSERT INTO activity_logs (user_id, action, module, description, created_at) VALUES (3, 'UPDATE', 'Products', 'System activity log entry #127', '2026-02-13 07:59:07');
INSERT INTO activity_logs (user_id, action, module, description, created_at) VALUES (4, 'DELETE', 'Users', 'System activity log entry #128', '2026-04-09 22:01:45');
INSERT INTO activity_logs (user_id, action, module, description, created_at) VALUES (5, 'VIEW', 'Live Schedules', 'System activity log entry #129', '2026-03-04 18:57:55');
INSERT INTO activity_logs (user_id, action, module, description, created_at) VALUES (1, 'LOGIN', 'Live Sales', 'System activity log entry #130', '2026-05-04 18:55:41');
INSERT INTO activity_logs (user_id, action, module, description, created_at) VALUES (2, 'CREATE', 'Marketplace', 'System activity log entry #131', '2026-02-19 22:28:08');
INSERT INTO activity_logs (user_id, action, module, description, created_at) VALUES (3, 'UPDATE', 'Returns', 'System activity log entry #132', '2026-05-18 23:57:17');
INSERT INTO activity_logs (user_id, action, module, description, created_at) VALUES (4, 'DELETE', 'Auth', 'System activity log entry #133', '2026-02-09 20:14:02');
INSERT INTO activity_logs (user_id, action, module, description, created_at) VALUES (5, 'VIEW', 'Products', 'System activity log entry #134', '2026-04-27 09:55:37');
INSERT INTO activity_logs (user_id, action, module, description, created_at) VALUES (1, 'LOGIN', 'Users', 'System activity log entry #135', '2026-03-28 23:58:41');
INSERT INTO activity_logs (user_id, action, module, description, created_at) VALUES (2, 'CREATE', 'Live Schedules', 'System activity log entry #136', '2026-04-22 15:25:58');
INSERT INTO activity_logs (user_id, action, module, description, created_at) VALUES (3, 'UPDATE', 'Live Sales', 'System activity log entry #137', '2026-03-14 13:43:12');
INSERT INTO activity_logs (user_id, action, module, description, created_at) VALUES (4, 'DELETE', 'Marketplace', 'System activity log entry #138', '2026-02-16 03:59:42');
INSERT INTO activity_logs (user_id, action, module, description, created_at) VALUES (5, 'VIEW', 'Returns', 'System activity log entry #139', '2026-05-16 13:18:49');
INSERT INTO activity_logs (user_id, action, module, description, created_at) VALUES (1, 'LOGIN', 'Auth', 'System activity log entry #140', '2026-02-11 02:37:18');
INSERT INTO activity_logs (user_id, action, module, description, created_at) VALUES (2, 'CREATE', 'Products', 'System activity log entry #141', '2026-03-13 08:43:28');
INSERT INTO activity_logs (user_id, action, module, description, created_at) VALUES (3, 'UPDATE', 'Users', 'System activity log entry #142', '2026-05-24 01:43:13');
INSERT INTO activity_logs (user_id, action, module, description, created_at) VALUES (4, 'DELETE', 'Live Schedules', 'System activity log entry #143', '2026-03-21 02:45:00');
INSERT INTO activity_logs (user_id, action, module, description, created_at) VALUES (5, 'VIEW', 'Live Sales', 'System activity log entry #144', '2026-05-25 07:18:34');
INSERT INTO activity_logs (user_id, action, module, description, created_at) VALUES (1, 'LOGIN', 'Marketplace', 'System activity log entry #145', '2026-05-03 05:55:27');
INSERT INTO activity_logs (user_id, action, module, description, created_at) VALUES (2, 'CREATE', 'Returns', 'System activity log entry #146', '2026-05-07 21:01:19');
INSERT INTO activity_logs (user_id, action, module, description, created_at) VALUES (3, 'UPDATE', 'Auth', 'System activity log entry #147', '2026-05-17 19:16:52');
INSERT INTO activity_logs (user_id, action, module, description, created_at) VALUES (4, 'DELETE', 'Products', 'System activity log entry #148', '2026-03-14 11:58:14');
INSERT INTO activity_logs (user_id, action, module, description, created_at) VALUES (5, 'VIEW', 'Users', 'System activity log entry #149', '2026-03-23 15:41:29');
INSERT INTO activity_logs (user_id, action, module, description, created_at) VALUES (1, 'LOGIN', 'Live Schedules', 'System activity log entry #150', '2026-02-12 12:48:00');
INSERT INTO activity_logs (user_id, action, module, description, created_at) VALUES (2, 'CREATE', 'Live Sales', 'System activity log entry #151', '2026-02-26 21:11:26');
INSERT INTO activity_logs (user_id, action, module, description, created_at) VALUES (3, 'UPDATE', 'Marketplace', 'System activity log entry #152', '2026-05-26 01:54:57');
INSERT INTO activity_logs (user_id, action, module, description, created_at) VALUES (4, 'DELETE', 'Returns', 'System activity log entry #153', '2026-02-28 05:30:03');
INSERT INTO activity_logs (user_id, action, module, description, created_at) VALUES (5, 'VIEW', 'Auth', 'System activity log entry #154', '2026-04-25 18:46:20');
INSERT INTO activity_logs (user_id, action, module, description, created_at) VALUES (1, 'LOGIN', 'Products', 'System activity log entry #155', '2026-04-01 21:10:47');
INSERT INTO activity_logs (user_id, action, module, description, created_at) VALUES (2, 'CREATE', 'Users', 'System activity log entry #156', '2026-02-10 02:37:55');
INSERT INTO activity_logs (user_id, action, module, description, created_at) VALUES (3, 'UPDATE', 'Live Schedules', 'System activity log entry #157', '2026-02-27 13:45:19');
INSERT INTO activity_logs (user_id, action, module, description, created_at) VALUES (4, 'DELETE', 'Live Sales', 'System activity log entry #158', '2026-03-28 02:51:55');
INSERT INTO activity_logs (user_id, action, module, description, created_at) VALUES (5, 'VIEW', 'Marketplace', 'System activity log entry #159', '2026-05-02 23:16:54');
INSERT INTO activity_logs (user_id, action, module, description, created_at) VALUES (1, 'LOGIN', 'Returns', 'System activity log entry #160', '2026-03-15 04:56:15');
INSERT INTO activity_logs (user_id, action, module, description, created_at) VALUES (2, 'CREATE', 'Auth', 'System activity log entry #161', '2026-04-03 02:49:00');
INSERT INTO activity_logs (user_id, action, module, description, created_at) VALUES (3, 'UPDATE', 'Products', 'System activity log entry #162', '2026-05-19 03:42:51');
INSERT INTO activity_logs (user_id, action, module, description, created_at) VALUES (4, 'DELETE', 'Users', 'System activity log entry #163', '2026-05-04 18:39:19');
INSERT INTO activity_logs (user_id, action, module, description, created_at) VALUES (5, 'VIEW', 'Live Schedules', 'System activity log entry #164', '2026-05-22 09:47:53');
INSERT INTO activity_logs (user_id, action, module, description, created_at) VALUES (1, 'LOGIN', 'Live Sales', 'System activity log entry #165', '2026-04-10 10:49:13');
INSERT INTO activity_logs (user_id, action, module, description, created_at) VALUES (2, 'CREATE', 'Marketplace', 'System activity log entry #166', '2026-04-19 17:34:25');
INSERT INTO activity_logs (user_id, action, module, description, created_at) VALUES (3, 'UPDATE', 'Returns', 'System activity log entry #167', '2026-05-23 09:56:39');
INSERT INTO activity_logs (user_id, action, module, description, created_at) VALUES (4, 'DELETE', 'Auth', 'System activity log entry #168', '2026-02-20 20:56:47');
INSERT INTO activity_logs (user_id, action, module, description, created_at) VALUES (5, 'VIEW', 'Products', 'System activity log entry #169', '2026-02-26 19:45:24');
INSERT INTO activity_logs (user_id, action, module, description, created_at) VALUES (1, 'LOGIN', 'Users', 'System activity log entry #170', '2026-03-22 17:17:39');
INSERT INTO activity_logs (user_id, action, module, description, created_at) VALUES (2, 'CREATE', 'Live Schedules', 'System activity log entry #171', '2026-04-25 11:05:57');
INSERT INTO activity_logs (user_id, action, module, description, created_at) VALUES (3, 'UPDATE', 'Live Sales', 'System activity log entry #172', '2026-02-27 09:57:32');
INSERT INTO activity_logs (user_id, action, module, description, created_at) VALUES (4, 'DELETE', 'Marketplace', 'System activity log entry #173', '2026-04-21 04:31:44');
INSERT INTO activity_logs (user_id, action, module, description, created_at) VALUES (5, 'VIEW', 'Returns', 'System activity log entry #174', '2026-04-12 11:29:09');
INSERT INTO activity_logs (user_id, action, module, description, created_at) VALUES (1, 'LOGIN', 'Auth', 'System activity log entry #175', '2026-04-15 09:38:47');
INSERT INTO activity_logs (user_id, action, module, description, created_at) VALUES (2, 'CREATE', 'Products', 'System activity log entry #176', '2026-04-17 13:28:03');
INSERT INTO activity_logs (user_id, action, module, description, created_at) VALUES (3, 'UPDATE', 'Users', 'System activity log entry #177', '2026-02-27 21:24:38');
INSERT INTO activity_logs (user_id, action, module, description, created_at) VALUES (4, 'DELETE', 'Live Schedules', 'System activity log entry #178', '2026-02-07 22:55:46');
INSERT INTO activity_logs (user_id, action, module, description, created_at) VALUES (5, 'VIEW', 'Live Sales', 'System activity log entry #179', '2026-05-02 01:32:32');
INSERT INTO activity_logs (user_id, action, module, description, created_at) VALUES (1, 'LOGIN', 'Marketplace', 'System activity log entry #180', '2026-03-30 04:13:30');
INSERT INTO activity_logs (user_id, action, module, description, created_at) VALUES (2, 'CREATE', 'Returns', 'System activity log entry #181', '2026-05-10 12:54:13');
INSERT INTO activity_logs (user_id, action, module, description, created_at) VALUES (3, 'UPDATE', 'Auth', 'System activity log entry #182', '2026-04-01 05:45:00');
INSERT INTO activity_logs (user_id, action, module, description, created_at) VALUES (4, 'DELETE', 'Products', 'System activity log entry #183', '2026-02-20 15:19:51');
INSERT INTO activity_logs (user_id, action, module, description, created_at) VALUES (5, 'VIEW', 'Users', 'System activity log entry #184', '2026-05-25 15:55:42');
INSERT INTO activity_logs (user_id, action, module, description, created_at) VALUES (1, 'LOGIN', 'Live Schedules', 'System activity log entry #185', '2026-02-09 12:16:57');
INSERT INTO activity_logs (user_id, action, module, description, created_at) VALUES (2, 'CREATE', 'Live Sales', 'System activity log entry #186', '2026-04-06 19:34:58');
INSERT INTO activity_logs (user_id, action, module, description, created_at) VALUES (3, 'UPDATE', 'Marketplace', 'System activity log entry #187', '2026-04-29 01:17:30');
INSERT INTO activity_logs (user_id, action, module, description, created_at) VALUES (4, 'DELETE', 'Returns', 'System activity log entry #188', '2026-05-28 07:54:26');
INSERT INTO activity_logs (user_id, action, module, description, created_at) VALUES (5, 'VIEW', 'Auth', 'System activity log entry #189', '2026-02-15 01:23:03');
INSERT INTO activity_logs (user_id, action, module, description, created_at) VALUES (1, 'LOGIN', 'Products', 'System activity log entry #190', '2026-04-23 09:23:47');
INSERT INTO activity_logs (user_id, action, module, description, created_at) VALUES (2, 'CREATE', 'Users', 'System activity log entry #191', '2026-03-23 21:55:00');
INSERT INTO activity_logs (user_id, action, module, description, created_at) VALUES (3, 'UPDATE', 'Live Schedules', 'System activity log entry #192', '2026-02-13 23:52:03');
INSERT INTO activity_logs (user_id, action, module, description, created_at) VALUES (4, 'DELETE', 'Live Sales', 'System activity log entry #193', '2026-04-29 15:51:14');
INSERT INTO activity_logs (user_id, action, module, description, created_at) VALUES (5, 'VIEW', 'Marketplace', 'System activity log entry #194', '2026-03-30 14:12:34');
INSERT INTO activity_logs (user_id, action, module, description, created_at) VALUES (1, 'LOGIN', 'Returns', 'System activity log entry #195', '2026-02-11 12:21:05');
INSERT INTO activity_logs (user_id, action, module, description, created_at) VALUES (2, 'CREATE', 'Auth', 'System activity log entry #196', '2026-02-01 15:40:20');
INSERT INTO activity_logs (user_id, action, module, description, created_at) VALUES (3, 'UPDATE', 'Products', 'System activity log entry #197', '2026-04-12 04:52:02');
INSERT INTO activity_logs (user_id, action, module, description, created_at) VALUES (4, 'DELETE', 'Users', 'System activity log entry #198', '2026-05-18 00:30:15');
INSERT INTO activity_logs (user_id, action, module, description, created_at) VALUES (5, 'VIEW', 'Live Schedules', 'System activity log entry #199', '2026-05-19 15:01:58');
INSERT INTO activity_logs (user_id, action, module, description, created_at) VALUES (1, 'LOGIN', 'Live Sales', 'System activity log entry #200', '2026-03-21 07:44:12');
