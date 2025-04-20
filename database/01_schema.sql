-- Core Tables
CREATE TABLE brands (
  id INT AUTO_INCREMENT PRIMARY KEY,
  name VARCHAR(100) NOT NULL,
  logo_url VARCHAR(255),
  description TEXT
) ENGINE=InnoDB;

CREATE TABLE product_categories (
  id INT AUTO_INCREMENT PRIMARY KEY,
  name VARCHAR(100) NOT NULL,
  parent_id INT,
  FOREIGN KEY (parent_id) REFERENCES product_categories(id)
);

-- Product System
CREATE TABLE products (
  id INT AUTO_INCREMENT PRIMARY KEY,
  name VARCHAR(255) NOT NULL,
  description TEXT,
  base_price DECIMAL(10,2) CHECK (base_price > 0),
  brand_id INT NOT NULL,
  category_id INT NOT NULL,
  FOREIGN KEY (brand_id) REFERENCES brands(id),
  FOREIGN KEY (category_id) REFERENCES product_categories(id)
);

-- Inventory Management
CREATE TABLE product_items (
  id INT AUTO_INCREMENT PRIMARY KEY,
  product_id INT NOT NULL,
  sku VARCHAR(100) UNIQUE,
  price DECIMAL(10,2),
  quantity_in_stock INT DEFAULT 0,
  FOREIGN KEY (product_id) REFERENCES products(id)
);