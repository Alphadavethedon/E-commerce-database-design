##### ENHANCED DATABASE INITIALIZATION #####
CREATE DATABASE IF NOT EXISTS africa_commerce 
CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE africa_commerce;

##### MULTI-TENANCY WITH ADVANCED FEATURES #####
CREATE TABLE tenants (
  id INT AUTO_INCREMENT PRIMARY KEY,
  name VARCHAR(100) NOT NULL,
  api_key CHAR(64) NOT NULL UNIQUE,
  plan ENUM('starter', 'pro', 'enterprise', 'marketplace') DEFAULT 'starter',
  monthly_fee DECIMAL(10,2) DEFAULT 0.00,
  transaction_fee DECIMAL(5,2) DEFAULT 1.5 COMMENT 'Percentage fee per transaction',
  default_currency CHAR(3) DEFAULT 'KES',
  timezone VARCHAR(50) DEFAULT 'Africa/Nairobi',
  is_active BOOLEAN DEFAULT TRUE,
  onboarding_status ENUM('pending', 'verified', 'rejected') DEFAULT 'pending',
  kyc_data JSON COMMENT 'Stores KYC documents and verification status',
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  INDEX idx_plan_status (plan, onboarding_status)
) ENGINE=InnoDB PARTITION BY HASH(id) PARTITIONS 10;

##### AI-POWERED CUSTOMER MANAGEMENT #####
CREATE TABLE customers (
  id INT AUTO_INCREMENT PRIMARY KEY,
  tenant_id INT NOT NULL,
  name VARCHAR(100),
  email VARCHAR(100),
  phone_number VARCHAR(20) NOT NULL COMMENT 'Primary identifier in African context',
  password VARCHAR(255) NOT NULL,
  address JSON COMMENT 'Structured address with geolocation',
  is_verified BOOLEAN DEFAULT FALSE,
  verification_method ENUM('sms', 'ussd', 'whatsapp', 'email') DEFAULT 'sms',
  credit_score TINYINT COMMENT 'Internal credit rating 1-10',
  loyalty_points INT DEFAULT 0,
  preferred_language CHAR(2) DEFAULT 'en',
  marketing_consent JSON COMMENT 'Stores consent for different channels',
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  last_login DATETIME,
  device_fingerprint VARCHAR(255),
  FOREIGN KEY (tenant_id) REFERENCES tenants(id) ON DELETE CASCADE,
  UNIQUE KEY uk_phone_tenant (phone_number, tenant_id),
  INDEX idx_phone (phone_number),
  INDEX idx_tenant_phone (tenant_id, phone_number),
  FULLTEXT INDEX ft_search (name, email, phone_number)
) ENGINE=InnoDB;

##### INTELLIGENT PRODUCT CATALOG #####
CREATE TABLE product_categories (
  id INT AUTO_INCREMENT PRIMARY KEY,
  tenant_id INT NOT NULL,
  name VARCHAR(100) NOT NULL,
  parent_id INT,
  image_url VARCHAR(255),
  is_featured BOOLEAN DEFAULT FALSE,
  commission_rate DECIMAL(5,2) DEFAULT 0.00 COMMENT 'For marketplace models',
  seo_metadata JSON,
  ai_tags JSON COMMENT 'Automatically generated tags from ML models',
  FOREIGN KEY (tenant_id) REFERENCES tenants(id) ON DELETE CASCADE,
  FOREIGN KEY (parent_id) REFERENCES product_categories(id) ON DELETE SET NULL,
  INDEX idx_tenant_category (tenant_id, name),
  FULLTEXT INDEX ft_category_name (name)
) ENGINE=InnoDB;

CREATE TABLE products (
  id INT AUTO_INCREMENT PRIMARY KEY,
  tenant_id INT NOT NULL,
  category_id INT NOT NULL,
  name VARCHAR(255) NOT NULL,
  description TEXT,
  base_price DECIMAL(10,2) UNSIGNED CHECK (base_price > 0),
  compare_at_price DECIMAL(10,2),
  cost_price DECIMAL(10,2) COMMENT 'For margin calculations',
  is_active BOOLEAN DEFAULT TRUE,
  is_digital BOOLEAN DEFAULT FALSE,
  delivery_profile_id INT COMMENT 'Custom delivery rules',
  tax_profile_id INT,
  ai_recommendations JSON COMMENT 'ML-generated cross-sell/up-sell suggestions',
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  FOREIGN KEY (tenant_id) REFERENCES tenants(id) ON DELETE CASCADE,
  FOREIGN KEY (category_id) REFERENCES product_categories(id),
  INDEX idx_tenant_product (tenant_id, is_active),
  FULLTEXT INDEX ft_product_search (name, description)
) ENGINE=InnoDB PARTITION BY HASH(tenant_id) PARTITIONS 10;

##### AFRICAN PAYMENT GATEWAY INTEGRATION #####
CREATE TABLE payment_gateways (
  id INT AUTO_INCREMENT PRIMARY KEY,
  name VARCHAR(50) NOT NULL COMMENT 'M-Pesa, Airtel Money, Flutterwave',
  country_codes JSON NOT NULL COMMENT 'Countries where gateway operates',
  processing_fee DECIMAL(5,2) NOT NULL,
  settlement_days TINYINT DEFAULT 1,
  is_active BOOLEAN DEFAULT TRUE,
  config_schema JSON COMMENT 'Gateway-specific configuration',
  webhook_url VARCHAR(255)
) ENGINE=InnoDB;

CREATE TABLE payment_transactions (
  id BIGINT AUTO_INCREMENT PRIMARY KEY,
  tenant_id INT NOT NULL,
  customer_id INT NOT NULL,
  gateway_id INT NOT NULL,
  amount DECIMAL(12,2) NOT NULL,
  currency CHAR(3) DEFAULT 'KES',
  transaction_id VARCHAR(100) NOT NULL,
  phone_number VARCHAR(20) COMMENT 'For mobile money',
  status ENUM('pending', 'completed', 'failed', 'refunded') DEFAULT 'pending',
  fee_amount DECIMAL(10,2) DEFAULT 0.00,
  settlement_id VARCHAR(100),
  metadata JSON,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  FOREIGN KEY (tenant_id) REFERENCES tenants(id) ON DELETE CASCADE,
  FOREIGN KEY (customer_id) REFERENCES customers(id),
  FOREIGN KEY (gateway_id) REFERENCES payment_gateways(id),
  UNIQUE KEY uk_gateway_transaction (gateway_id, transaction_id),
  INDEX idx_tenant_transaction (tenant_id, status, created_at),
  INDEX idx_customer_transactions (customer_id, created_at)
) ENGINE=InnoDB PARTITION BY RANGE (YEAR(created_at)) (
  PARTITION p2023 VALUES LESS THAN (2024),
  PARTITION p2024 VALUES LESS THAN (2025),
  PARTITION pmax VALUES LESS THAN MAXVALUE
);

##### INNOVATIVE DELIVERY SYSTEM #####
CREATE TABLE delivery_zones (
  id INT AUTO_INCREMENT PRIMARY KEY,
  tenant_id INT NOT NULL,
  name VARCHAR(100) NOT NULL,
  polygon_coordinates JSON COMMENT 'GeoJSON polygon for zone coverage',
  base_fee DECIMAL(10,2) NOT NULL,
  fee_per_km DECIMAL(10,2) DEFAULT 0.00,
  estimated_days_min TINYINT NOT NULL,
  estimated_days_max TINYINT NOT NULL,
  is_active BOOLEAN DEFAULT TRUE,
  FOREIGN KEY (tenant_id) REFERENCES tenants(id) ON DELETE CASCADE,
  SPATIAL INDEX idx_zone_coverage (polygon_coordinates)
) ENGINE=InnoDB;

CREATE TABLE pickup_stations (
  id INT AUTO_INCREMENT PRIMARY KEY,
  tenant_id INT NOT NULL,
  name VARCHAR(100) NOT NULL,
  location POINT NOT NULL SRID 4326,
  address JSON,
  contact_phone VARCHAR(20) NOT NULL,
  operating_hours JSON,
  is_active BOOLEAN DEFAULT TRUE,
  FOREIGN KEY (tenant_id) REFERENCES tenants(id) ON DELETE CASCADE,
  SPATIAL INDEX idx_location (location)
) ENGINE=InnoDB;

##### AI-POWERED INVENTORY MANAGEMENT #####
CREATE TABLE inventory_items (
  id BIGINT AUTO_INCREMENT PRIMARY KEY,
  product_id INT NOT NULL,
  sku VARCHAR(100) NOT NULL,
  barcode VARCHAR(100),
  price DECIMAL(10,2) NOT NULL,
  cost_price DECIMAL(10,2),
  quantity INT NOT NULL DEFAULT 0,
  low_stock_threshold INT DEFAULT 5,
  reorder_point INT DEFAULT 10,
  weight_kg DECIMAL(6,3),
  dimensions VARCHAR(50) COMMENT 'LxWxH in cm',
  is_active BOOLEAN DEFAULT TRUE,
  ai_demand_forecast JSON COMMENT 'ML predicted demand data',
  FOREIGN KEY (product_id) REFERENCES products(id) ON DELETE CASCADE,
  UNIQUE KEY uk_product_sku (product_id, sku),
  INDEX idx_low_stock (quantity, low_stock_threshold),
  INDEX idx_barcode (barcode)
) ENGINE=InnoDB;

##### MARKET GAP SOLUTIONS #####
-- Agent Network Management
CREATE TABLE sales_agents (
  id INT AUTO_INCREMENT PRIMARY KEY,
  tenant_id INT NOT NULL,
  name VARCHAR(100) NOT NULL,
  phone VARCHAR(20) NOT NULL,
  id_number VARCHAR(50),
  location POINT SRID 4326,
  tier ENUM('bronze', 'silver', 'gold') DEFAULT 'bronze',
  commission_rate DECIMAL(5,2) DEFAULT 5.00,
  is_active BOOLEAN DEFAULT TRUE,
  performance_metrics JSON,
  FOREIGN KEY (tenant_id) REFERENCES tenants(id) ON DELETE CASCADE,
  UNIQUE KEY uk_tenant_phone (tenant_id, phone),
  SPATIAL INDEX idx_agent_location (location)
) ENGINE=InnoDB;

-- Buy Now Pay Later (BNPL)
CREATE TABLE bnpl_plans (
  id INT AUTO_INCREMENT PRIMARY KEY,
  tenant_id INT NOT NULL,
  name VARCHAR(100) NOT NULL,
  description TEXT,
  installment_count TINYINT NOT NULL,
  interest_rate DECIMAL(5,2) DEFAULT 0.00,
  min_amount DECIMAL(10,2),
  max_amount DECIMAL(10,2),
  is_active BOOLEAN DEFAULT TRUE,
  eligibility_criteria JSON,
  FOREIGN KEY (tenant_id) REFERENCES tenants(id) ON DELETE CASCADE
) ENGINE=InnoDB;

##### MONETIZATION FEATURES #####
-- Dynamic Pricing Engine
CREATE TABLE pricing_rules (
  id INT AUTO_INCREMENT PRIMARY KEY,
  tenant_id INT NOT NULL,
  name VARCHAR(100) NOT NULL,
  rule_type ENUM('discount', 'surcharge', 'fixed') NOT NULL,
  value DECIMAL(10,2) NOT NULL,
  conditions JSON NOT NULL COMMENT 'JSON logic for rule application',
  start_date DATETIME NOT NULL,
  end_date DATETIME,
  is_active BOOLEAN DEFAULT TRUE,
  priority TINYINT DEFAULT 0,
  FOREIGN KEY (tenant_id) REFERENCES tenants(id) ON DELETE CASCADE,
  INDEX idx_tenant_active (tenant_id, is_active, start_date, end_date)
) ENGINE=InnoDB;

-- Advertising Spots
CREATE TABLE ad_spaces (
  id INT AUTO_INCREMENT PRIMARY KEY,
  tenant_id INT NOT NULL,
  name VARCHAR(100) NOT NULL,
  location ENUM('homepage', 'category', 'product', 'cart', 'checkout') NOT NULL,
  price_model ENUM('cpm', 'cpc', 'flat') NOT NULL,
  base_price DECIMAL(10,2) NOT NULL,
  targeting_options JSON,
  is_active BOOLEAN DEFAULT TRUE,
  FOREIGN KEY (tenant_id) REFERENCES tenants(id) ON DELETE CASCADE
) ENGINE=InnoDB;

##### PERFORMANCE OPTIMIZATIONS #####
-- Materialized Views for Analytics
CREATE MATERIALIZED VIEW mv_daily_sales 
REFRESH COMPLETE ON DEMAND
AS
SELECT 
  tenant_id,
  DATE(created_at) AS sale_date,
  COUNT(*) AS order_count,
  SUM(amount) AS total_revenue,
  SUM(amount * transaction_fee/100) AS fee_income
FROM payment_transactions
WHERE status = 'completed'
GROUP BY tenant_id, DATE(created_at);

-- Sharding-ready design
CREATE TABLE shard_mapping (
  tenant_id INT PRIMARY KEY,
  shard_id TINYINT NOT NULL,
  server_name VARCHAR(100) NOT NULL,
  UNIQUE KEY uk_shard_mapping (shard_id, tenant_id)
) ENGINE=InnoDB;

##### SCALABILITY FEATURES #####
-- Event Sourcing for Critical Operations
CREATE TABLE event_log (
  id BIGINT AUTO_INCREMENT PRIMARY KEY,
  event_type VARCHAR(50) NOT NULL,
  entity_type VARCHAR(50) NOT NULL,
  entity_id VARCHAR(100) NOT NULL,
  event_data JSON NOT NULL,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  INDEX idx_entity_events (entity_type, entity_id),
  INDEX idx_event_timeline (created_at)
) ENGINE=InnoDB PARTITION BY RANGE (UNIX_TIMESTAMP(created_at)) (
  PARTITION p2023 VALUES LESS THAN (UNIX_TIMESTAMP('2024-01-01')),
  PARTITION p2024 VALUES LESS THAN (UNIX_TIMESTAMP('2025-01-01')),
  PARTITION pmax VALUES LESS THAN MAXVALUE
);

##### ADVANCED FUNCTIONS #####
DELIMITER //
CREATE FUNCTION calculate_dynamic_price(
  product_id INT,
  customer_id INT,
  quantity INT
) RETURNS DECIMAL(10,2) DETERMINISTIC
BEGIN
  DECLARE base_price DECIMAL(10,2);
  DECLARE final_price DECIMAL(10,2);
  DECLARE customer_tier VARCHAR(20);
  
  -- Get base price
  SELECT base_price INTO base_price FROM products WHERE id = product_id;
  
  -- Get customer tier if available
  SELECT tier INTO customer_tier FROM customers WHERE id = customer_id;
  
  -- Apply pricing rules (simplified example)
  SET final_price = base_price;
  
  -- Quantity discount
  IF quantity > 10 THEN
    SET final_price = final_price * 0.9; -- 10% discount
  END IF;
  
  -- Loyalty discount
  IF customer_tier = 'gold' THEN
    SET final_price = final_price * 0.85; -- 15% discount
  ELSEIF customer_tier = 'silver' THEN
    SET final_price = final_price * 0.9; -- 10% discount
  END IF;
  
  RETURN final_price;
END//

DELIMITER ;

##### INNOVATIVE MONETIZATION VIEWS #####
-- Customer Lifetime Value
CREATE VIEW customer_lifetime_value AS
SELECT 
  c.id AS customer_id,
  c.name,
  c.phone_number,
  COUNT(t.id) AS transaction_count,
  SUM(t.amount) AS total_spend,
  DATEDIFF(NOW(), MIN(t.created_at)) AS days_active,
  SUM(t.amount) / COUNT(DISTINCT DATE(t.created_at))) AS avg_daily_spend
FROM customers c
JOIN payment_transactions t ON c.id = t.customer_id
WHERE t.status = 'completed'
GROUP BY c.id, c.name, c.phone_number;

-- Product Affinity Analysis
CREATE VIEW product_affinity AS
SELECT 
  p1.id AS product_id,
  p1.name AS product_name,
  p2.id AS related_product_id,
  p2.name AS related_product_name,
  COUNT(*) AS co_purchase_count
FROM order_items oi1
JOIN order_items oi2 ON oi1.order_id = oi2.order_id AND oi1.product_id != oi2.product_id
JOIN products p1 ON oi1.product_id = p1.id
JOIN products p2 ON oi2.product_id = p2.id
GROUP BY p1.id, p1.name, p2.id, p2.name
ORDER BY co_purchase_count DESC;