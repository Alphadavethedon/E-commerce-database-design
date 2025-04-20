-- Core Business Entities
CREATE TABLE brands (
    brand_id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    slug VARCHAR(100) UNIQUE,
    logo_url VARCHAR(255),
    description TEXT,
    is_featured BOOLEAN DEFAULT FALSE
) ENGINE=InnoDB ROW_FORMAT=COMPRESSED;

CREATE TABLE product_categories (
    category_id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    slug VARCHAR(100) UNIQUE,
    parent_id INT NULL,
    FOREIGN KEY (parent_id) REFERENCES product_categories(category_id)
);

-- Product System with Advanced Features
CREATE TABLE products (
    product_id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(255) NOT NULL FULLTEXT,
    slug VARCHAR(255) UNIQUE,
    description TEXT FULLTEXT,
    base_price DECIMAL(10,2) UNSIGNED,
    brand_id INT NOT NULL,
    category_id INT NOT NULL,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (brand_id) REFERENCES brands(brand_id),
    FOREIGN KEY (category_id) REFERENCES product_categories(category_id),
    INDEX idx_fulltext_search (name, description) WITH PARSER ngram,
    CONSTRAINT chk_price CHECK (base_price > 0)
) ENGINE=InnoDB;

-- Variant Management System
CREATE TABLE product_items (
    item_id INT AUTO_INCREMENT PRIMARY KEY,
    product_id INT NOT NULL,
    sku VARCHAR(100) UNIQUE,
    price DECIMAL(10,2) UNSIGNED,
    quantity_in_stock INT UNSIGNED DEFAULT 0,
    is_active BOOLEAN DEFAULT TRUE,
    FOREIGN KEY (product_id) REFERENCES products(product_id) ON DELETE CASCADE
);

-- Media Management (CDN-ready)
CREATE TABLE product_media (
    media_id INT AUTO_INCREMENT PRIMARY KEY,
    product_id INT NOT NULL,
    url VARCHAR(512) NOT NULL,
    type ENUM('image', 'video', '3d_model'),
    is_primary BOOLEAN DEFAULT FALSE,
    display_order INT DEFAULT 0,
    FOREIGN KEY (product_id) REFERENCES products(product_id) ON DELETE CASCADE
);