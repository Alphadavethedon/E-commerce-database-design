##### DATABASE INITIALIZATION
CREATE DATABASE IF NOT EXISTS ecommerce;
USE ecommerce;

##### TENANT MANAGEMENT
CREATE TABLE tenants (
  id INT AUTO_INCREMENT PRIMARY KEY,
  name VARCHAR(100) NOT NULL,
  api_key CHAR(64) NOT NULL UNIQUE,
  plan ENUM('starter', 'pro', 'enterprise') DEFAULT 'starter',
  monthly_fee DECIMAL(10,2) DEFAULT 0.00,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

##### CUSTOMER ACCOUNTS
CREATE TABLE customers (
  id INT AUTO_INCREMENT PRIMARY KEY,
  tenant_id INT NOT NULL,
  name VARCHAR(100),
  email VARCHAR(100) UNIQUE,
  password VARCHAR(255) NOT NULL,
  phone_number VARCHAR(20),
  address TEXT,
  is_verified BOOLEAN DEFAULT FALSE,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (tenant_id) REFERENCES tenants(id) ON DELETE CASCADE
);

##### BRANDS
CREATE TABLE brands (
  id INT AUTO_INCREMENT PRIMARY KEY,
  name VARCHAR(100) NOT NULL,
  logo_url VARCHAR(255),
  description TEXT
);

##### PRODUCT CATEGORIES
CREATE TABLE product_categories (
  id INT AUTO_INCREMENT PRIMARY KEY,
  name VARCHAR(100) NOT NULL,
  parent_id INT,
  FOREIGN KEY (parent_id) REFERENCES product_categories(id) ON DELETE SET NULL
);

##### PRODUCTS
CREATE TABLE products (
  id INT AUTO_INCREMENT PRIMARY KEY,
  tenant_id INT NOT NULL,
  name VARCHAR(255) NOT NULL,
  description TEXT,
  base_price DECIMAL(10,2) CHECK (base_price > 0),
  brand_id INT NOT NULL,
  category_id INT NOT NULL,
  vendor_id INT,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (tenant_id) REFERENCES tenants(id) ON DELETE CASCADE,
  FOREIGN KEY (brand_id) REFERENCES brands(id),
  FOREIGN KEY (category_id) REFERENCES product_categories(id),
  FOREIGN KEY (vendor_id) REFERENCES vendors(id)
);

##### INVENTORY MANAGEMENT
CREATE TABLE product_items (
  id INT AUTO_INCREMENT PRIMARY KEY,
  product_id INT NOT NULL,
  sku VARCHAR(100) UNIQUE NOT NULL,
  price DECIMAL(10,2) NOT NULL,
  inventory_quantity INT NOT NULL DEFAULT 0,
  barcode VARCHAR(100),
  is_default BOOLEAN DEFAULT FALSE,
  image_id INT,
  FOREIGN KEY (product_id) REFERENCES products(id) ON DELETE CASCADE
);

##### SIZE CATEGORIES
CREATE TABLE size_categories (
  id INT AUTO_INCREMENT PRIMARY KEY,
  tenant_id INT NOT NULL,
  name VARCHAR(50) NOT NULL,
  code VARCHAR(20) UNIQUE NOT NULL,
  FOREIGN KEY (tenant_id) REFERENCES tenants(id) ON DELETE CASCADE
);

##### SIZE OPTIONS
CREATE TABLE size_options (
  id INT AUTO_INCREMENT PRIMARY KEY,
  size_category_id INT NOT NULL,
  name VARCHAR(50) NOT NULL,
  value VARCHAR(20) NOT NULL,
  sort_order INT DEFAULT 0,
  FOREIGN KEY (size_category_id) REFERENCES size_categories(id) ON DELETE CASCADE
);

##### COLORS
CREATE TABLE colors (
  id INT AUTO_INCREMENT PRIMARY KEY,
  tenant_id INT NOT NULL,
  name VARCHAR(50) NOT NULL,
  hex_code VARCHAR(7) NOT NULL,
  FOREIGN KEY (tenant_id) REFERENCES tenants(id) ON DELETE CASCADE
);

##### PRODUCT VARIATIONS
CREATE TABLE product_variations (
  id INT AUTO_INCREMENT PRIMARY KEY,
  product_id INT NOT NULL,
  name VARCHAR(100) NOT NULL,
  FOREIGN KEY (product_id) REFERENCES products(id) ON DELETE CASCADE
);

##### VARIATION VALUES
CREATE TABLE variation_values (
  id INT AUTO_INCREMENT PRIMARY KEY,
  variation_id INT NOT NULL,
  option_type ENUM('size', 'color', 'material', 'style') NOT NULL,
  size_option_id INT,
  color_id INT,
  custom_value VARCHAR(100),
  FOREIGN KEY (variation_id) REFERENCES product_variations(id) ON DELETE CASCADE,
  FOREIGN KEY (size_option_id) REFERENCES size_options(id) ON DELETE SET NULL,
  FOREIGN KEY (color_id) REFERENCES colors(id) ON DELETE SET NULL
);

##### PRODUCT ITEM VARIATIONS
CREATE TABLE product_item_variations (
  product_item_id INT NOT NULL,
  variation_value_id INT NOT NULL,
  PRIMARY KEY (product_item_id, variation_value_id),
  FOREIGN KEY (product_item_id) REFERENCES product_items(id) ON DELETE CASCADE,
  FOREIGN KEY (variation_value_id) REFERENCES variation_values(id) ON DELETE CASCADE
);

##### PRODUCT SEARCH INDEX
CREATE TABLE product_search_index (
  product_id INT NOT NULL,
  content TEXT NOT NULL,
  PRIMARY KEY (product_id),
  FULLTEXT INDEX idx_fulltext_content (content),
  FOREIGN KEY (product_id) REFERENCES products(id) ON DELETE CASCADE
);

##### COUNTIES
CREATE TABLE counties (
  code TINYINT PRIMARY KEY,
  name VARCHAR(50) NOT NULL
);

##### PAYMENTS
CREATE TABLE payments (
  payment_id INT AUTO_INCREMENT PRIMARY KEY,
  customer_id INT NOT NULL,
  amount DECIMAL(10,2) NOT NULL,
  county_code TINYINT NOT NULL,
  paid_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (customer_id) REFERENCES customers(id),
  FOREIGN KEY (county_code) REFERENCES counties(code)
);

##### COUNTY VENDORS
CREATE TABLE county_vendors (
  id INT AUTO_INCREMENT PRIMARY KEY,
  county_code TINYINT NOT NULL,
  business_name VARCHAR(100) NOT NULL,
  mpesa_paybill VARCHAR(10),
  airtel_money VARCHAR(15),
  FOREIGN KEY (county_code) REFERENCES counties(code)
);

##### PRODUCT TRANSLATIONS
CREATE TABLE product_translations (
  product_id INT NOT NULL,
  county_code TINYINT NOT NULL,
  language ENUM('sw','en','kam','kik','luo') DEFAULT 'sw',
  translated_name VARCHAR(255) NOT NULL,
  PRIMARY KEY (product_id, county_code, language)
);

##### VENDORS TEMPORARY TABLE (FOR MIGRATION)
CREATE TABLE vendors_temp (
  id INT AUTO_INCREMENT PRIMARY KEY,
  user_id INT,
  business_name VARCHAR(100) NOT NULL
);

##### DELIVERIES
CREATE TABLE deliveries (
  id INT AUTO_INCREMENT,
  from_county TINYINT NOT NULL,
  to_county TINYINT NOT NULL,
  cost DECIMAL(6,2) NOT NULL,
  PRIMARY KEY (id, to_county)
) PARTITION BY LIST (to_county) (
  PARTITION p_nairobi VALUES IN (47),
  PARTITION p_coastal VALUES IN (1,2,3),
  PARTITION p_other VALUES IN (4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,
                                21,22,23,24,25,26,27,28,29,30,31,32,33,34,35,
                                36,37,38,39,40,41,42,43,44,45,46)
);

##### DYNAMIC DELIVERY COST FUNCTION
DELIMITER //
CREATE FUNCTION calculate_delivery(
    from_county TINYINT,
    to_county TINYINT,
    weight_kg DECIMAL(5,2)
) RETURNS DECIMAL(7,2) DETERMINISTIC
BEGIN
    DECLARE base_rate DECIMAL(5,2);

    SELECT 
        CASE 
            WHEN from_county = to_county THEN 100.00
            WHEN from_county = 47 THEN 250.00
            ELSE 350.00
        END * (1 + weight_kg/10) 
    INTO base_rate;

    RETURN base_rate;
END//
DELIMITER ;

##### REVENUE REPORT BY COUNTY
SELECT 
    c.name,
    COUNT(p.payment_id) AS transactions,
    SUM(p.amount) AS revenue
FROM payments p
JOIN counties c ON p.county_code = c.code
GROUP BY c.code
ORDER BY revenue DESC;

######### DATABASE INITIALIZATION
CREATE DATABASE IF NOT EXISTS ecommerce;
USE ecommerce;

##### TENANT MANAGEMENT
CREATE TABLE tenants (
  id INT AUTO_INCREMENT PRIMARY KEY,
  name VARCHAR(100) NOT NULL,
  api_key CHAR(64) NOT NULL UNIQUE,
  plan ENUM('starter', 'pro', 'enterprise') DEFAULT 'starter',
  monthly_fee DECIMAL(10,2) DEFAULT 0.00,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  default_currency CHAR(3) DEFAULT 'KES',
  timezone VARCHAR(50) DEFAULT 'Africa/Nairobi',
  is_active BOOLEAN DEFAULT TRUE
);

##### CUSTOMER ACCOUNTS
CREATE TABLE customers (
  id INT AUTO_INCREMENT PRIMARY KEY,
  tenant_id INT NOT NULL,
  name VARCHAR(100),
  email VARCHAR(100) UNIQUE,
  password VARCHAR(255) NOT NULL,
  phone_number VARCHAR(20),
  address TEXT,
  is_verified BOOLEAN DEFAULT FALSE,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  last_login DATETIME,
  language_preference CHAR(2) DEFAULT 'en',
  marketing_opt_in BOOLEAN DEFAULT FALSE,
  FOREIGN KEY (tenant_id) REFERENCES tenants(id) ON DELETE CASCADE,
  INDEX idx_phone_number (phone_number)
);

##### MOBILE MONEY INTEGRATION
CREATE TABLE mobile_money_providers (
  id INT AUTO_INCREMENT PRIMARY KEY,
  name VARCHAR(50) NOT NULL,
  shortcode VARCHAR(10) NOT NULL,
  country_code VARCHAR(3) NOT NULL,
  is_active BOOLEAN DEFAULT TRUE,
  logo_url VARCHAR(255)
);

CREATE TABLE mobile_money_transactions (
  id BIGINT AUTO_INCREMENT PRIMARY KEY,
  customer_id INT NOT NULL,
  provider_id INT NOT NULL,
  transaction_id VARCHAR(50) NOT NULL,
  amount DECIMAL(10,2) NOT NULL,
  phone_number VARCHAR(15) NOT NULL,
  status ENUM('pending','completed','failed','reversed') DEFAULT 'pending',
  receipt_number VARCHAR(50),
  transaction_time DATETIME,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (customer_id) REFERENCES customers(id),
  FOREIGN KEY (provider_id) REFERENCES mobile_money_providers(id),
  INDEX idx_transaction_id (transaction_id),
  INDEX idx_phone_number (phone_number)
);

##### LOCAL PAYMENT METHODS
CREATE TABLE local_payment_methods (
  id INT AUTO_INCREMENT PRIMARY KEY,
  name VARCHAR(50) NOT NULL,
  description VARCHAR(255),
  is_cash_based BOOLEAN DEFAULT FALSE,
  requires_verification BOOLEAN DEFAULT FALSE,
  icon_class VARCHAR(50)
);

CREATE TABLE customer_payment_preferences (
  customer_id INT NOT NULL,
  payment_method_id INT NOT NULL,
  is_default BOOLEAN DEFAULT FALSE,
  details JSON COMMENT 'Method-specific details like M-Pesa number',
  PRIMARY KEY (customer_id, payment_method_id),
  FOREIGN KEY (customer_id) REFERENCES customers(id) ON DELETE CASCADE,
  FOREIGN KEY (payment_method_id) REFERENCES local_payment_methods(id)
);

##### COUNTIES & REGIONAL DATA
CREATE TABLE counties (
  code TINYINT PRIMARY KEY,
  name VARCHAR(50) NOT NULL,
  region VARCHAR(50) NOT NULL,
  capital VARCHAR(50),
  population INT,
  area_sq_km INT
);

CREATE TABLE informal_settlements (
  id INT AUTO_INCREMENT PRIMARY KEY,
  county_code TINYINT NOT NULL,
  name VARCHAR(100) NOT NULL,
  common_landmarks TEXT,
  delivery_instructions TEXT,
  FOREIGN KEY (county_code) REFERENCES counties(code),
  INDEX idx_settlement_name (name)
);

##### DELIVERY & LOGISTICS
CREATE TABLE delivery_partners (
  id INT AUTO_INCREMENT PRIMARY KEY,
  name VARCHAR(100) NOT NULL,
  coverage JSON NOT NULL COMMENT 'JSON array of county codes served',
  base_fee DECIMAL(10,2) NOT NULL,
  per_km_rate DECIMAL(10,2) NOT NULL,
  is_active BOOLEAN DEFAULT TRUE,
  contact_phone VARCHAR(20) NOT NULL,
  service_levels JSON COMMENT 'Standard, Express, Same-day etc.'
);

CREATE TABLE delivery_zones (
  id INT AUTO_INCREMENT PRIMARY KEY,
  county_code TINYINT NOT NULL,
  zone_name VARCHAR(50) NOT NULL,
  estimated_delivery_days INT NOT NULL,
  surcharge DECIMAL(10,2) DEFAULT 0.00,
  FOREIGN KEY (county_code) REFERENCES counties(code),
  UNIQUE KEY (county_code, zone_name)
);

CREATE TABLE pickup_stations (
  id INT AUTO_INCREMENT PRIMARY KEY,
  name VARCHAR(100) NOT NULL,
  county_code TINYINT NOT NULL,
  location VARCHAR(255) NOT NULL,
  contact_phone VARCHAR(20) NOT NULL,
  is_active BOOLEAN DEFAULT TRUE,
  coordinates POINT SRID 4326,
  operating_hours VARCHAR(100),
  FOREIGN KEY (county_code) REFERENCES counties(code),
  SPATIAL INDEX (coordinates)
);

##### BRANDS & CATEGORIES
CREATE TABLE brands (
  id INT AUTO_INCREMENT PRIMARY KEY,
  name VARCHAR(100) NOT NULL,
  logo_url VARCHAR(255),
  description TEXT,
  is_local BOOLEAN DEFAULT FALSE,
  country_of_origin CHAR(2)
);

CREATE TABLE product_categories (
  id INT AUTO_INCREMENT PRIMARY KEY,
  name VARCHAR(100) NOT NULL,
  parent_id INT,
  image_url VARCHAR(255),
  is_featured BOOLEAN DEFAULT FALSE,
  FOREIGN KEY (parent_id) REFERENCES product_categories(id) ON DELETE SET NULL,
  INDEX idx_parent_id (parent_id)
);

##### PRODUCTS & INVENTORY
CREATE TABLE products (
  id INT AUTO_INCREMENT PRIMARY KEY,
  tenant_id INT NOT NULL,
  name VARCHAR(255) NOT NULL,
  description TEXT,
  base_price DECIMAL(10,2) CHECK (base_price > 0),
  brand_id INT NOT NULL,
  category_id INT NOT NULL,
  vendor_id INT,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  is_active BOOLEAN DEFAULT TRUE,
  is_featured BOOLEAN DEFAULT FALSE,
  tax_rate DECIMAL(5,2) DEFAULT 0.00,
  weight_kg DECIMAL(5,2) DEFAULT 0.00,
  FOREIGN KEY (tenant_id) REFERENCES tenants(id) ON DELETE CASCADE,
  FOREIGN KEY (brand_id) REFERENCES brands(id),
  FOREIGN KEY (category_id) REFERENCES product_categories(id),
  FULLTEXT INDEX idx_product_search (name, description)
);

CREATE TABLE product_items (
  id INT AUTO_INCREMENT PRIMARY KEY,
  product_id INT NOT NULL,
  sku VARCHAR(100) UNIQUE NOT NULL,
  price DECIMAL(10,2) NOT NULL,
  inventory_quantity INT NOT NULL DEFAULT 0,
  barcode VARCHAR(100),
  is_default BOOLEAN DEFAULT FALSE,
  image_id INT,
  weight_kg DECIMAL(5,2) DEFAULT 0.00,
  dimensions VARCHAR(50) COMMENT 'Format: LxWxH in cm',
  FOREIGN KEY (product_id) REFERENCES products(id) ON DELETE CASCADE,
  INDEX idx_sku (sku),
  INDEX idx_barcode (barcode)
);

##### SIZE & VARIATIONS
CREATE TABLE size_categories (
  id INT AUTO_INCREMENT PRIMARY KEY,
  tenant_id INT NOT NULL,
  name VARCHAR(50) NOT NULL,
  code VARCHAR(20) UNIQUE NOT NULL,
  applies_to_category_id INT,
  FOREIGN KEY (tenant_id) REFERENCES tenants(id) ON DELETE CASCADE,
  FOREIGN KEY (applies_to_category_id) REFERENCES product_categories(id)
);

CREATE TABLE size_options (
  id INT AUTO_INCREMENT PRIMARY KEY,
  size_category_id INT NOT NULL,
  name VARCHAR(50) NOT NULL,
  value VARCHAR(20) NOT NULL,
  sort_order INT DEFAULT 0,
  size_chart_url VARCHAR(255),
  FOREIGN KEY (size_category_id) REFERENCES size_categories(id) ON DELETE CASCADE
);

CREATE TABLE colors (
  id INT AUTO_INCREMENT PRIMARY KEY,
  tenant_id INT NOT NULL,
  name VARCHAR(50) NOT NULL,
  hex_code VARCHAR(7) NOT NULL,
  color_group VARCHAR(50),
  FOREIGN KEY (tenant_id) REFERENCES tenants(id) ON DELETE CASCADE
);

CREATE TABLE product_variations (
  id INT AUTO_INCREMENT PRIMARY KEY,
  product_id INT NOT NULL,
  name VARCHAR(100) NOT NULL,
  is_required BOOLEAN DEFAULT TRUE,
  display_order INT DEFAULT 0,
  FOREIGN KEY (product_id) REFERENCES products(id) ON DELETE CASCADE
);

CREATE TABLE variation_values (
  id INT AUTO_INCREMENT PRIMARY KEY,
  variation_id INT NOT NULL,
  option_type ENUM('size', 'color', 'material', 'style', 'other') NOT NULL,
  size_option_id INT,
  color_id INT,
  custom_value VARCHAR(100),
  image_url VARCHAR(255),
  FOREIGN KEY (variation_id) REFERENCES product_variations(id) ON DELETE CASCADE,
  FOREIGN KEY (size_option_id) REFERENCES size_options(id) ON DELETE SET NULL,
  FOREIGN KEY (color_id) REFERENCES colors(id) ON DELETE SET NULL
);

CREATE TABLE product_item_variations (
  product_item_id INT NOT NULL,
  variation_value_id INT NOT NULL,
  PRIMARY KEY (product_item_id, variation_value_id),
  FOREIGN KEY (product_item_id) REFERENCES product_items(id) ON DELETE CASCADE,
  FOREIGN KEY (variation_value_id) REFERENCES variation_values(id) ON DELETE CASCADE
);

##### WAREHOUSING & INVENTORY
CREATE TABLE warehouses (
  id INT AUTO_INCREMENT PRIMARY KEY,
  tenant_id INT NOT NULL,
  name VARCHAR(100) NOT NULL,
  county_code TINYINT NOT NULL,
  location VARCHAR(255) NOT NULL,
  contact_phone VARCHAR(20) NOT NULL,
  capacity INT COMMENT 'Total capacity in cubic meters',
  is_active BOOLEAN DEFAULT TRUE,
  coordinates POINT SRID 4326,
  manager_name VARCHAR(100),
  operating_hours VARCHAR(100),
  FOREIGN KEY (tenant_id) REFERENCES tenants(id) ON DELETE CASCADE,
  FOREIGN KEY (county_code) REFERENCES counties(code),
  SPATIAL INDEX (coordinates)
);

CREATE TABLE inventory_movements (
  id BIGINT AUTO_INCREMENT PRIMARY KEY,
  product_item_id INT NOT NULL,
  warehouse_id INT NOT NULL,
  quantity INT NOT NULL,
  movement_type ENUM('in','out','transfer','adjustment') NOT NULL,
  reference_id VARCHAR(50) COMMENT 'Order ID, Transfer ID, etc.',
  recorded_by INT COMMENT 'User who recorded this movement',
  recorded_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  notes TEXT,
  FOREIGN KEY (product_item_id) REFERENCES product_items(id),
  FOREIGN KEY (warehouse_id) REFERENCES warehouses(id),
  INDEX idx_reference (reference_id),
  INDEX idx_recorded_at (recorded_at)
);

CREATE TABLE stock_level_alerts (
  id INT AUTO_INCREMENT PRIMARY KEY,
  tenant_id INT NOT NULL,
  product_id INT NOT NULL,
  threshold_quantity INT NOT NULL,
  notification_emails JSON COMMENT 'Array of emails to notify',
  is_active BOOLEAN DEFAULT TRUE,
  last_triggered_at DATETIME,
  FOREIGN KEY (tenant_id) REFERENCES tenants(id) ON DELETE CASCADE,
  FOREIGN KEY (product_id) REFERENCES products(id) ON DELETE CASCADE
);

##### MULTILINGUAL SUPPORT
CREATE TABLE languages (
  code CHAR(2) PRIMARY KEY,
  name VARCHAR(50) NOT NULL,
  native_name VARCHAR(50) NOT NULL,
  is_rtl BOOLEAN DEFAULT FALSE,
  is_active BOOLEAN DEFAULT TRUE
);

CREATE TABLE product_translations (
  id INT AUTO_INCREMENT PRIMARY KEY,
  product_id INT NOT NULL,
  language_code CHAR(2) NOT NULL,
  name VARCHAR(255) NOT NULL,
  description TEXT,
  features JSON COMMENT 'Translated product features in JSON format',
  FOREIGN KEY (product_id) REFERENCES products(id) ON DELETE CASCADE,
  FOREIGN KEY (language_code) REFERENCES languages(code),
  UNIQUE KEY (product_id, language_code)
);

CREATE TABLE category_translations (
  id INT AUTO_INCREMENT PRIMARY KEY,
  category_id INT NOT NULL,
  language_code CHAR(2) NOT NULL,
  name VARCHAR(100) NOT NULL,
  description TEXT,
  FOREIGN KEY (category_id) REFERENCES product_categories(id) ON DELETE CASCADE,
  FOREIGN KEY (language_code) REFERENCES languages(code),
  UNIQUE KEY (category_id, language_code)
);

##### CUSTOMER EXPERIENCE
CREATE TABLE customer_support_channels (
  id INT AUTO_INCREMENT PRIMARY KEY,
  tenant_id INT NOT NULL,
  channel_type ENUM('whatsapp','phone','email','facebook','twitter','instagram','live_chat') NOT NULL,
  value VARCHAR(100) NOT NULL,
  is_primary BOOLEAN DEFAULT FALSE,
  hours_of_operation VARCHAR(100),
  average_response_time VARCHAR(20),
  FOREIGN KEY (tenant_id) REFERENCES tenants(id) ON DELETE CASCADE
);

CREATE TABLE customer_support_tickets (
  id BIGINT AUTO_INCREMENT PRIMARY KEY,
  customer_id INT NOT NULL,
  channel_id INT NOT NULL,
  subject VARCHAR(255) NOT NULL,
  description TEXT NOT NULL,
  status ENUM('open','in_progress','resolved','closed') DEFAULT 'open',
  priority ENUM('low','medium','high','critical') DEFAULT 'medium',
  assigned_to INT COMMENT 'Support agent ID',
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  resolved_at DATETIME,
  satisfaction_rating TINYINT CHECK (satisfaction_rating BETWEEN 1 AND 5),
  FOREIGN KEY (customer_id) REFERENCES customers(id),
  FOREIGN KEY (channel_id) REFERENCES customer_support_channels(id),
  INDEX idx_status (status),
  INDEX idx_priority (priority)
);

CREATE TABLE product_reviews (
  id BIGINT AUTO_INCREMENT PRIMARY KEY,
  product_id INT NOT NULL,
  customer_id INT NOT NULL,
  rating TINYINT NOT NULL CHECK (rating BETWEEN 1 AND 5),
  review_text TEXT,
  is_verified_purchase BOOLEAN DEFAULT FALSE,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  helpful_count INT DEFAULT 0,
  FOREIGN KEY (product_id) REFERENCES products(id) ON DELETE CASCADE,
  FOREIGN KEY (customer_id) REFERENCES customers(id),
  INDEX idx_rating (rating),
  INDEX idx_verified (is_verified_purchase)
);

##### MARKETING & PROMOTIONS
CREATE TABLE promotional_campaigns (
  id INT AUTO_INCREMENT PRIMARY KEY,
  tenant_id INT NOT NULL,
  name VARCHAR(100) NOT NULL,
  description TEXT,
  start_date DATETIME NOT NULL,
  end_date DATETIME NOT NULL,
  is_active BOOLEAN DEFAULT TRUE,
  target_counties JSON COMMENT 'Array of county codes',
  target_customer_segments JSON,
  min_order_amount DECIMAL(10,2),
  max_uses_per_customer INT,
  image_url VARCHAR(255),
  FOREIGN KEY (tenant_id) REFERENCES tenants(id) ON DELETE CASCADE,
  INDEX idx_dates (start_date, end_date)
);

CREATE TABLE discounts (
  id INT AUTO_INCREMENT PRIMARY KEY,
  campaign_id INT,
  discount_type ENUM('percentage','fixed_amount','free_shipping','buy_x_get_y') NOT NULL,
  value DECIMAL(10,2) NOT NULL,
  max_discount_amount DECIMAL(10,2),
  min_products INT,
  code VARCHAR(20) UNIQUE,
  is_reusable BOOLEAN DEFAULT FALSE,
  max_uses INT,
  current_uses INT DEFAULT 0,
  applies_to_category_id INT,
  applies_to_product_id INT,
  FOREIGN KEY (campaign_id) REFERENCES promotional_campaigns(id) ON DELETE CASCADE,
  FOREIGN KEY (applies_to_category_id) REFERENCES product_categories(id),
  FOREIGN KEY (applies_to_product_id) REFERENCES products(id),
  INDEX idx_code (code)
);

CREATE TABLE flash_sales (
  id INT AUTO_INCREMENT PRIMARY KEY,
  tenant_id INT NOT NULL,
  name VARCHAR(100) NOT NULL,
  start_time DATETIME NOT NULL,
  end_time DATETIME NOT NULL,
  is_active BOOLEAN DEFAULT TRUE,
  max_items_per_customer INT,
  landing_page_url VARCHAR(255),
  banner_image_url VARCHAR(255),
  FOREIGN KEY (tenant_id) REFERENCES tenants(id) ON DELETE CASCADE,
  INDEX idx_times (start_time, end_time)
);

CREATE TABLE flash_sale_products (
  flash_sale_id INT NOT NULL,
  product_item_id INT NOT NULL,
  sale_price DECIMAL(10,2) NOT NULL,
  initial_quantity INT NOT NULL,
  remaining_quantity INT NOT NULL,
  purchase_limit_per_customer INT,
  PRIMARY KEY (flash_sale_id, product_item_id),
  FOREIGN KEY (flash_sale_id) REFERENCES flash_sales(id) ON DELETE CASCADE,
  FOREIGN KEY (product_item_id) REFERENCES product_items(id)
);

##### ANALYTICS & REPORTING
CREATE TABLE customer_segments (
  id INT AUTO_INCREMENT PRIMARY KEY,
  tenant_id INT NOT NULL,
  name VARCHAR(50) NOT NULL,
  criteria JSON NOT NULL COMMENT 'JSON defining segment criteria',
  customer_count INT DEFAULT 0,
  last_updated TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  FOREIGN KEY (tenant_id) REFERENCES tenants(id) ON DELETE CASCADE
);

CREATE TABLE customer_behavior_events (
  id BIGINT AUTO_INCREMENT PRIMARY KEY,
  customer_id INT NOT NULL,
  event_type ENUM('page_view','product_view','cart_add','cart_remove','search','purchase','wishlist_add','login','logout') NOT NULL,
  product_id INT,
  search_query VARCHAR(255),
  metadata JSON COMMENT 'Additional event data',
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  device_type ENUM('mobile','desktop','tablet','other'),
  ip_address VARCHAR(45),
  FOREIGN KEY (customer_id) REFERENCES customers(id),
  FOREIGN KEY (product_id) REFERENCES products(id),
  INDEX idx_event_type (event_type),
  INDEX idx_created_at (created_at)
);

CREATE TABLE sales_trends (
  id INT AUTO_INCREMENT PRIMARY KEY,
  tenant_id INT NOT NULL,
  date DATE NOT NULL,
  total_sales DECIMAL(12,2) NOT NULL,
  order_count INT NOT NULL,
  average_order_value DECIMAL(10,2) NOT NULL,
  new_customers INT NOT NULL,
  returning_customers INT NOT NULL,
  top_county_code TINYINT,
  top_product_id INT,
  mobile_money_percentage DECIMAL(5,2),
  FOREIGN KEY (tenant_id) REFERENCES tenants(id) ON DELETE CASCADE,
  FOREIGN KEY (top_county_code) REFERENCES counties(code),
  FOREIGN KEY (top_product_id) REFERENCES products(id),
  UNIQUE KEY (tenant_id, date)
);

##### SECURITY & FRAUD PREVENTION
CREATE TABLE login_attempts (
  id BIGINT AUTO_INCREMENT PRIMARY KEY,
  customer_id INT,
  email VARCHAR(100) NOT NULL,
  ip_address VARCHAR(45) NOT NULL,
  user_agent VARCHAR(255),
  success BOOLEAN NOT NULL,
  attempted_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  location_data JSON,
  INDEX idx_customer_id (customer_id),
  INDEX idx_email (email),
  INDEX idx_ip_address (ip_address),
  INDEX idx_attempted_at (attempted_at)
);

CREATE TABLE fraud_indicators (
  id INT AUTO_INCREMENT PRIMARY KEY,
  name VARCHAR(50) NOT NULL,
  description TEXT,
  risk_score TINYINT NOT NULL CHECK (risk_score BETWEEN 1 AND 10),
  is_active BOOLEAN DEFAULT TRUE
);

CREATE TABLE order_fraud_assessments (
  order_id INT PRIMARY KEY,
  total_risk_score TINYINT NOT NULL CHECK (total_risk_score BETWEEN 0 AND 100),
  indicators JSON COMMENT 'Array of fraud indicator IDs and scores',
  is_flagged BOOLEAN DEFAULT FALSE,
  reviewed_by INT COMMENT 'Admin who reviewed this assessment',
  review_decision ENUM('approve','reject','manual_review') DEFAULT 'manual_review',
  reviewed_at DATETIME,
  notes TEXT,
  INDEX idx_risk_score (total_risk_score),
  INDEX idx_review_decision (review_decision)
);

##### UTILITY TABLES
CREATE TABLE exchange_rates (
  from_currency CHAR(3) NOT NULL,
  to_currency CHAR(3) NOT NULL,
  rate DECIMAL(10,4) NOT NULL,
  last_updated TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (from_currency, to_currency)
);

CREATE TABLE scheduled_tasks (
  id INT AUTO_INCREMENT PRIMARY KEY,
  task_name VARCHAR(100) NOT NULL,
  description TEXT,
  cron_expression VARCHAR(50) NOT NULL,
  is_active BOOLEAN DEFAULT TRUE,
  last_run TIMESTAMP NULL,
  next_run TIMESTAMP NULL,
  task_class VARCHAR(255) NOT NULL,
  task_parameters JSON
);

CREATE TABLE system_settings (
  id INT AUTO_INCREMENT PRIMARY KEY,
  setting_key VARCHAR(100) NOT NULL UNIQUE,
  setting_value TEXT NOT NULL,
  data_type ENUM('string','number','boolean','json','array') NOT NULL,
  description TEXT,
  is_public BOOLEAN DEFAULT FALSE,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

##### DELIVERY COST FUNCTION
DELIMITER //
CREATE FUNCTION calculate_delivery(
    from_county TINYINT,
    to_county TINYINT,
    weight_kg DECIMAL(5,2),
    delivery_type ENUM('standard','express','same_day')
) RETURNS DECIMAL(7,2) DETERMINISTIC
BEGIN
    DECLARE base_rate DECIMAL(5,2);
    DECLARE weight_surcharge DECIMAL(5,2);
    DECLARE delivery_multiplier DECIMAL(3,2);
    
    -- Set delivery type multiplier
    SET delivery_multiplier = CASE 
        WHEN delivery_type = 'express' THEN 1.5
        WHEN delivery_type = 'same_day' THEN 2.0
        ELSE 1.0
    END;
    
    -- Calculate base rate
    SELECT 
        CASE 
            WHEN from_county = to_county THEN 100.00
            WHEN from_county = 47 THEN 250.00 -- Nairobi
            ELSE 350.00
        END * delivery_multiplier
    INTO base_rate;
    
    -- Calculate weight surcharge (free for first 5kg)
    SET weight_surcharge = GREATEST(0, weight_kg - 5) * 20;
    
    RETURN base_rate + weight_surcharge;
END//
DELIMITER ;

##### REVENUE REPORT BY COUNTY
CREATE VIEW county_revenue_report AS
SELECT 
    c.code AS county_code,
    c.name AS county_name,
    c.region,
    COUNT(p.payment_id) AS transactions,
    SUM(p.amount) AS revenue,
    COUNT(DISTINCT p.customer_id) AS unique_customers,
    AVG(p.amount) AS avg_order_value
FROM payments p
JOIN counties c ON p.county_code = c.code
GROUP BY c.code, c.name, c.region
ORDER BY revenue DESC;

##### TOP PRODUCTS BY COUNTY VIEW
CREATE VIEW top_products_by_county AS
SELECT 
    p.county_code,
    c.name AS county_name,
    pr.id AS product_id,
    pr.name AS product_name,
    COUNT(*) AS units_sold,
    SUM(oi.price * oi.quantity) AS revenue
FROM order_items oi
JOIN orders o ON oi.order_id = o.id
JOIN payments p ON o.payment_id = p.payment_id
JOIN counties c ON p.county_code = c.code
JOIN product_items pi ON oi.product_item_id = pi.id
JOIN products pr ON pi.product_id = pr.id
GROUP BY p.county_code, c.name, pr.id, pr.name
ORDER BY p.county_code, revenue DESC;

##### INITIAL DATA INSERTS
INSERT INTO counties (code, name, region) VALUES
(1, 'Mombasa', 'Coast'), (2, 'Kwale', 'Coast'), (3, 'Kilifi', 'Coast'),
(47, 'Nairobi', 'Nairobi'), (4, 'Tana River', 'Coast'), (5, 'Lamu', 'Coast');

INSERT INTO mobile_money_providers (name, shortcode, country_code) VALUES
('M-Pesa', '303303', 'KE'), ('Airtel Money', '555555', 'KE'), 
('T-Kash', '851', 'KE'), ('Equitel', '247247', 'KE');

INSERT INTO languages (code, name, native_name, is_active) VALUES
('en', 'English', 'English', TRUE), ('sw', 'Swahili', 'Kiswahili', TRUE),
('kam', 'Kamba', 'Kikamba', TRUE), ('kik', 'Kikuyu', 'Gikuyu', TRUE),
('luo', 'Luo', 'Dholuo', TRUE);