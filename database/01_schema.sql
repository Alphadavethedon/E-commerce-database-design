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

##### ORDER MANAGEMENT SYSTEM #####
CREATE TABLE orders (
  id INT AUTO_INCREMENT PRIMARY KEY,
  tenant_id INT NOT NULL,
  customer_id INT NOT NULL,
  order_number VARCHAR(50) NOT NULL,
  status ENUM('pending', 'confirmed', 'processing', 'shipped', 'delivered', 'cancelled', 'returned') DEFAULT 'pending',
  subtotal DECIMAL(12,2) NOT NULL,
  shipping_total DECIMAL(10,2) NOT NULL,
  tax_total DECIMAL(10,2) DEFAULT 0.00,
  discount_total DECIMAL(10,2) DEFAULT 0.00,
  grand_total DECIMAL(12,2) NOT NULL,
  payment_method VARCHAR(50) NOT NULL,
  payment_status ENUM('pending', 'partial', 'paid', 'refunded', 'failed') DEFAULT 'pending',
  shipping_address JSON NOT NULL,
  billing_address JSON,
  customer_note TEXT,
  ip_address VARCHAR(45),
  device_type ENUM('mobile', 'desktop', 'tablet', 'other'),
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  FOREIGN KEY (tenant_id) REFERENCES tenants(id) ON DELETE CASCADE,
  FOREIGN KEY (customer_id) REFERENCES customers(id),
  UNIQUE KEY uk_order_number (tenant_id, order_number),
  INDEX idx_order_status (status, created_at),
  INDEX idx_customer_orders (customer_id, created_at)
) ENGINE=InnoDB PARTITION BY RANGE (YEAR(created_at)) (
  PARTITION p2023 VALUES LESS THAN (2024),
  PARTITION p2024 VALUES LESS THAN (2025),
  PARTITION pmax VALUES LESS THAN MAXVALUE
);

CREATE TABLE order_items (
  id INT AUTO_INCREMENT PRIMARY KEY,
  order_id INT NOT NULL,
  product_id INT NOT NULL,
  vendor_id INT NOT NULL,
  quantity INT NOT NULL,
  price DECIMAL(10,2) NOT NULL,
  discount_amount DECIMAL(10,2) DEFAULT 0.00,
  tax_amount DECIMAL(10,2) DEFAULT 0.00,
  total_price DECIMAL(10,2) NOT NULL,
  fulfillment_status ENUM('unfulfilled', 'partial', 'fulfilled') DEFAULT 'unfulfilled',
  FOREIGN KEY (order_id) REFERENCES orders(id) ON DELETE CASCADE,
  FOREIGN KEY (product_id) REFERENCES products(id),
  FOREIGN KEY (vendor_id) REFERENCES vendors(id),
  INDEX idx_order_products (order_id, product_id)
);

##### SHIPPING & FULFILLMENT #####
CREATE TABLE shipments (
  id INT AUTO_INCREMENT PRIMARY KEY,
  order_id INT NOT NULL,
  carrier VARCHAR(50) NOT NULL,
  tracking_number VARCHAR(100),
  tracking_url VARCHAR(255),
  status ENUM('label_created', 'in_transit', 'out_for_delivery', 'delivered', 'returned') DEFAULT 'label_created',
  estimated_delivery DATE,
  actual_delivery DATE,
  shipping_cost DECIMAL(10,2) NOT NULL,
  package_weight DECIMAL(6,2),
  package_dimensions VARCHAR(50),
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  FOREIGN KEY (order_id) REFERENCES orders(id),
  INDEX idx_tracking (tracking_number),
  INDEX idx_shipment_status (status, estimated_delivery)
);

CREATE TABLE shipment_items (
  id INT AUTO_INCREMENT PRIMARY KEY,
  shipment_id INT NOT NULL,
  order_item_id INT NOT NULL,
  quantity INT NOT NULL,
  FOREIGN KEY (shipment_id) REFERENCES shipments(id) ON DELETE CASCADE,
  FOREIGN KEY (order_item_id) REFERENCES order_items(id)
);

##### TAXATION SYSTEM #####
CREATE TABLE tax_categories (
  id INT AUTO_INCREMENT PRIMARY KEY,
  tenant_id INT NOT NULL,
  name VARCHAR(100) NOT NULL,
  description TEXT,
  is_active BOOLEAN DEFAULT TRUE,
  FOREIGN KEY (tenant_id) REFERENCES tenants(id) ON DELETE CASCADE
);

CREATE TABLE tax_rates (
  id INT AUTO_INCREMENT PRIMARY KEY,
  tax_category_id INT NOT NULL,
  country_code CHAR(2) NOT NULL,
  region_code VARCHAR(10),
  rate DECIMAL(5,2) NOT NULL,
  is_default BOOLEAN DEFAULT FALSE,
  FOREIGN KEY (tax_category_id) REFERENCES tax_categories(id) ON DELETE CASCADE,
  UNIQUE KEY uk_tax_location (tax_category_id, country_code, region_code)
);

##### PROMOTIONS & DISCOUNTS #####
CREATE TABLE coupons (
  id INT AUTO_INCREMENT PRIMARY KEY,
  tenant_id INT NOT NULL,
  code VARCHAR(50) NOT NULL,
  description TEXT,
  discount_type ENUM('percentage', 'fixed_amount', 'free_shipping') NOT NULL,
  discount_value DECIMAL(10,2) NOT NULL,
  min_order_amount DECIMAL(10,2),
  max_discount_amount DECIMAL(10,2),
  start_date DATETIME NOT NULL,
  end_date DATETIME NOT NULL,
  usage_limit INT,
  usage_count INT DEFAULT 0,
  is_active BOOLEAN DEFAULT TRUE,
  applies_to JSON COMMENT 'Product/category restrictions',
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (tenant_id) REFERENCES tenants(id) ON DELETE CASCADE,
  UNIQUE KEY uk_coupon_code (tenant_id, code),
  INDEX idx_coupon_active (is_active, start_date, end_date)
);

##### VENDOR COMMISSION SYSTEM #####
CREATE TABLE commission_plans (
  id INT AUTO_INCREMENT PRIMARY KEY,
  tenant_id INT NOT NULL,
  name VARCHAR(100) NOT NULL,
  commission_type ENUM('percentage', 'fixed') NOT NULL,
  commission_value DECIMAL(5,2) NOT NULL,
  min_sale_amount DECIMAL(10,2),
  tiered_commissions JSON COMMENT 'For volume-based commissions',
  is_default BOOLEAN DEFAULT FALSE,
  FOREIGN KEY (tenant_id) REFERENCES tenants(id) ON DELETE CASCADE
);

CREATE TABLE vendor_commissions (
  id INT AUTO_INCREMENT PRIMARY KEY,
  vendor_order_id INT NOT NULL,
  commission_plan_id INT NOT NULL,
  calculated_amount DECIMAL(10,2) NOT NULL,
  paid_amount DECIMAL(10,2) DEFAULT 0.00,
  status ENUM('pending', 'processing', 'paid', 'cancelled') DEFAULT 'pending',
  payout_date DATE,
  FOREIGN KEY (vendor_order_id) REFERENCES vendor_orders(id),
  FOREIGN KEY (commission_plan_id) REFERENCES commission_plans(id)
);

##### VENDOR PERFORMANCE METRICS #####
CREATE TABLE vendor_quality_metrics (
  id INT AUTO_INCREMENT PRIMARY KEY,
  vendor_id INT NOT NULL,
  metric_date DATE NOT NULL,
  order_defect_rate DECIMAL(5,2) DEFAULT 0.00,
  late_shipment_rate DECIMAL(5,2) DEFAULT 0.00,
  cancellation_rate DECIMAL(5,2) DEFAULT 0.00,
  avg_rating DECIMAL(3,2) DEFAULT 0.00,
  response_time_hours DECIMAL(5,2),
  FOREIGN KEY (vendor_id) REFERENCES vendors(id) ON DELETE CASCADE,
  UNIQUE KEY uk_vendor_metric_date (vendor_id, metric_date)
);

##### VENDOR SETTLEMENT SYSTEM #####
CREATE TABLE vendor_balance (
  id INT AUTO_INCREMENT PRIMARY KEY,
  vendor_id INT NOT NULL,
  available_balance DECIMAL(12,2) DEFAULT 0.00,
  pending_balance DECIMAL(12,2) DEFAULT 0.00,
  last_payout_date DATE,
  next_payout_date DATE,
  FOREIGN KEY (vendor_id) REFERENCES vendors(id) ON DELETE CASCADE
);

CREATE TABLE vendor_payout_schedules (
  id INT AUTO_INCREMENT PRIMARY KEY,
  tenant_id INT NOT NULL,
  schedule_type ENUM('daily', 'weekly', 'biweekly', 'monthly') NOT NULL,
  day_of_week TINYINT COMMENT 'For weekly schedules',
  day_of_month TINYINT COMMENT 'For monthly schedules',
  minimum_payout_amount DECIMAL(10,2) DEFAULT 0.00,
  is_active BOOLEAN DEFAULT TRUE,
  FOREIGN KEY (tenant_id) REFERENCES tenants(id) ON DELETE CASCADE
);

##### FRAUD PREVENTION SYSTEM #####
CREATE TABLE fraud_rules (
  id INT AUTO_INCREMENT PRIMARY KEY,
  tenant_id INT NOT NULL,
  name VARCHAR(100) NOT NULL,
  description TEXT,
  rule_conditions JSON NOT NULL,
  action ENUM('flag', 'hold', 'cancel') DEFAULT 'flag',
  is_active BOOLEAN DEFAULT TRUE,
  priority TINYINT DEFAULT 0,
  FOREIGN KEY (tenant_id) REFERENCES tenants(id) ON DELETE CASCADE
);

CREATE TABLE fraud_attempts (
  id BIGINT AUTO_INCREMENT PRIMARY KEY,
  tenant_id INT NOT NULL,
  order_id INT,
  customer_id INT,
  ip_address VARCHAR(45),
  risk_score TINYINT NOT NULL,
  triggered_rules JSON,
  action_taken VARCHAR(50),
  reviewed_by INT,
  review_notes TEXT,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (tenant_id) REFERENCES tenants(id) ON DELETE CASCADE,
  FOREIGN KEY (order_id) REFERENCES orders(id),
  FOREIGN KEY (customer_id) REFERENCES customers(id),
  INDEX idx_fraud_attempts (tenant_id, created_at)
);

##### AI RECOMMENDATION ENGINE #####
CREATE TABLE recommendation_models (
  id INT AUTO_INCREMENT PRIMARY KEY,
  tenant_id INT NOT NULL,
  name VARCHAR(100) NOT NULL,
  model_type ENUM('product', 'content', 'bundling') NOT NULL,
  version VARCHAR(50) NOT NULL,
  is_active BOOLEAN DEFAULT FALSE,
  last_trained_at TIMESTAMP NULL,
  performance_metrics JSON,
  FOREIGN KEY (tenant_id) REFERENCES tenants(id) ON DELETE CASCADE
);

CREATE TABLE product_recommendations (
  id BIGINT AUTO_INCREMENT PRIMARY KEY,
  customer_id INT,
  session_id VARCHAR(100),
  product_id INT NOT NULL,
  recommended_product_id INT NOT NULL,
  model_id INT NOT NULL,
  score DECIMAL(5,4) NOT NULL,
  context JSON COMMENT 'Recommendation context data',
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (product_id) REFERENCES products(id),
  FOREIGN KEY (recommended_product_id) REFERENCES products(id),
  FOREIGN KEY (model_id) REFERENCES recommendation_models(id),
  INDEX idx_product_recommendations (product_id, recommended_product_id)
);

##### MARKETPLACE NOTIFICATION SYSTEM #####
CREATE TABLE notification_templates (
  id INT AUTO_INCREMENT PRIMARY KEY,
  tenant_id INT NOT NULL,
  name VARCHAR(100) NOT NULL,
  notification_type ENUM('email', 'sms', 'push', 'in_app') NOT NULL,
  subject VARCHAR(255),
  content_template TEXT NOT NULL,
  variables JSON COMMENT 'Available template variables',
  is_active BOOLEAN DEFAULT TRUE,
  FOREIGN KEY (tenant_id) REFERENCES tenants(id) ON DELETE CASCADE
);

CREATE TABLE notifications (
  id BIGINT AUTO_INCREMENT PRIMARY KEY,
  tenant_id INT NOT NULL,
  recipient_id INT NOT NULL,
  recipient_type ENUM('customer', 'vendor', 'admin') NOT NULL,
  template_id INT,
  subject VARCHAR(255),
  content TEXT NOT NULL,
  notification_type ENUM('email', 'sms', 'push', 'in_app') NOT NULL,
  status ENUM('queued', 'sent', 'delivered', 'failed') DEFAULT 'queued',
  read_at TIMESTAMP NULL,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (tenant_id) REFERENCES tenants(id) ON DELETE CASCADE,
  FOREIGN KEY (template_id) REFERENCES notification_templates(id),
  INDEX idx_notification_status (status, created_at)
);

##################
# Database Schema for Multi-Vendor E-Commerce Platform
# Optimized for East African Market with Advanced Features
##################

##################
# Core Platform Tables
##################

CREATE TABLE tenants (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    api_key VARCHAR(64) UNIQUE NOT NULL,
    plan ENUM('starter', 'professional', 'enterprise') NOT NULL DEFAULT 'starter',
    monthly_fee DECIMAL(10,2) NOT NULL DEFAULT 0.00,
    is_active BOOLEAN NOT NULL DEFAULT TRUE,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_tenant_active (is_active)
) ENGINE=InnoDB;

CREATE TABLE counties (
    code TINYINT PRIMARY KEY,
    name VARCHAR(50) NOT NULL,
    region VARCHAR(50) NOT NULL,
    delivery_base_rate DECIMAL(6,2) NOT NULL,
    UNIQUE INDEX idx_county_name (name)
) ENGINE=InnoDB;

##################
# User Management
##################

CREATE TABLE users (
    id INT AUTO_INCREMENT PRIMARY KEY,
    tenant_id INT NOT NULL,
    email VARCHAR(255) NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    phone_number VARCHAR(20) NOT NULL,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    county_code TINYINT NOT NULL,
    is_verified BOOLEAN NOT NULL DEFAULT FALSE,
    last_login TIMESTAMP NULL,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (tenant_id) REFERENCES tenants(id) ON DELETE CASCADE,
    FOREIGN KEY (county_code) REFERENCES counties(code),
    UNIQUE INDEX idx_user_email (tenant_id, email),
    UNIQUE INDEX idx_user_phone (tenant_id, phone_number)
) ENGINE=InnoDB;

##################
# Vendor Management
##################

CREATE TABLE vendors (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    tenant_id INT NOT NULL,
    business_name VARCHAR(100) NOT NULL,
    business_reg_number VARCHAR(50),
    description TEXT,
    logo_url VARCHAR(255),
    mpesa_paybill VARCHAR(10),
    airtel_money VARCHAR(15),
    bank_account_number VARCHAR(20),
    bank_name VARCHAR(50),
    is_approved BOOLEAN NOT NULL DEFAULT FALSE,
    rating DECIMAL(3,2) DEFAULT 0.00,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (tenant_id) REFERENCES tenants(id) ON DELETE CASCADE,
    INDEX idx_vendor_approval (is_approved),
    INDEX idx_vendor_rating (rating)
) ENGINE=InnoDB;

##################
# Product Catalog
##################

CREATE TABLE brands (
    id INT AUTO_INCREMENT PRIMARY KEY,
    tenant_id INT NOT NULL,
    name VARCHAR(100) NOT NULL,
    logo_url VARCHAR(255),
    description TEXT,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (tenant_id) REFERENCES tenants(id) ON DELETE CASCADE,
    UNIQUE INDEX idx_brand_tenant (tenant_id, name)
) ENGINE=InnoDB;

CREATE TABLE product_categories (
    id INT AUTO_INCREMENT PRIMARY KEY,
    tenant_id INT NOT NULL,
    name VARCHAR(100) NOT NULL,
    parent_id INT,
    description TEXT,
    image_url VARCHAR(255),
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (tenant_id) REFERENCES tenants(id) ON DELETE CASCADE,
    FOREIGN KEY (parent_id) REFERENCES product_categories(id) ON DELETE SET NULL,
    INDEX idx_category_hierarchy (tenant_id, parent_id)
) ENGINE=InnoDB;

CREATE TABLE products (
    id INT AUTO_INCREMENT PRIMARY KEY,
    tenant_id INT NOT NULL,
    vendor_id INT NOT NULL,
    name VARCHAR(255) NOT NULL,
    description TEXT,
    base_price DECIMAL(10,2) NOT NULL CHECK (base_price > 0),
    brand_id INT,
    category_id INT NOT NULL,
    is_active BOOLEAN NOT NULL DEFAULT TRUE,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (tenant_id) REFERENCES tenants(id) ON DELETE CASCADE,
    FOREIGN KEY (vendor_id) REFERENCES vendors(id) ON DELETE CASCADE,
    FOREIGN KEY (brand_id) REFERENCES brands(id) ON DELETE SET NULL,
    FOREIGN KEY (category_id) REFERENCES product_categories(id) ON DELETE RESTRICT,
    INDEX idx_product_vendor (vendor_id),
    INDEX idx_product_category (category_id),
    FULLTEXT INDEX idx_product_search (name, description)
) ENGINE=InnoDB;

##################
# Product Variations & Inventory
##################

CREATE TABLE size_categories (
    id INT AUTO_INCREMENT PRIMARY KEY,
    tenant_id INT NOT NULL,
    name VARCHAR(50) NOT NULL,
    code VARCHAR(20) UNIQUE NOT NULL,
    FOREIGN KEY (tenant_id) REFERENCES tenants(id) ON DELETE CASCADE,
    UNIQUE INDEX idx_size_category (tenant_id, code)
) ENGINE=InnoDB;

CREATE TABLE size_options (
    id INT AUTO_INCREMENT PRIMARY KEY,
    size_category_id INT NOT NULL,
    name VARCHAR(50) NOT NULL,
    value VARCHAR(20) NOT NULL,
    sort_order INT NOT NULL DEFAULT 0,
    FOREIGN KEY (size_category_id) REFERENCES size_categories(id) ON DELETE CASCADE,
    UNIQUE INDEX idx_size_option (size_category_id, value)
) ENGINE=InnoDB;

CREATE TABLE colors (
    id INT AUTO_INCREMENT PRIMARY KEY,
    tenant_id INT NOT NULL,
    name VARCHAR(50) NOT NULL,
    hex_code VARCHAR(7) NOT NULL,
    FOREIGN KEY (tenant_id) REFERENCES tenants(id) ON DELETE CASCADE,
    UNIQUE INDEX idx_color_tenant (tenant_id, name)
) ENGINE=InnoDB;

CREATE TABLE product_variations (
    id INT AUTO_INCREMENT PRIMARY KEY,
    product_id INT NOT NULL,
    name VARCHAR(100) NOT NULL,
    FOREIGN KEY (product_id) REFERENCES products(id) ON DELETE CASCADE,
    INDEX idx_variation_product (product_id)
) ENGINE=InnoDB;

CREATE TABLE variation_values (
    id INT AUTO_INCREMENT PRIMARY KEY,
    variation_id INT NOT NULL,
    option_type ENUM('size', 'color', 'material', 'style') NOT NULL,
    size_option_id INT,
    color_id INT,
    custom_value VARCHAR(100),
    FOREIGN KEY (variation_id) REFERENCES product_variations(id) ON DELETE CASCADE,
    FOREIGN KEY (size_option_id) REFERENCES size_options(id) ON DELETE SET NULL,
    FOREIGN KEY (color_id) REFERENCES colors(id) ON DELETE SET NULL,
    INDEX idx_variation_type (variation_id, option_type)
) ENGINE=InnoDB;

CREATE TABLE product_items (
    id INT AUTO_INCREMENT PRIMARY KEY,
    product_id INT NOT NULL,
    sku VARCHAR(100) UNIQUE NOT NULL,
    price DECIMAL(10,2) NOT NULL,
    inventory_quantity INT NOT NULL DEFAULT 0,
    barcode VARCHAR(100),
    is_default BOOLEAN NOT NULL DEFAULT FALSE,
    image_id INT,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (product_id) REFERENCES products(id) ON DELETE CASCADE,
    INDEX idx_product_item (product_id, sku),
    INDEX idx_inventory_status (inventory_quantity)
) ENGINE=InnoDB;

CREATE TABLE product_item_variations (
    product_item_id INT NOT NULL,
    variation_value_id INT NOT NULL,
    PRIMARY KEY (product_item_id, variation_value_id),
    FOREIGN KEY (product_item_id) REFERENCES product_items(id) ON DELETE CASCADE,
    FOREIGN KEY (variation_value_id) REFERENCES variation_values(id) ON DELETE CASCADE
) ENGINE=InnoDB;

##################
# Localization Support
##################

CREATE TABLE product_translations (
    product_id INT NOT NULL,
    county_code TINYINT NOT NULL,
    language ENUM('sw','en','kam','kik','luo') NOT NULL DEFAULT 'sw',
    translated_name VARCHAR(255) NOT NULL,
    translated_description TEXT,
    PRIMARY KEY (product_id, county_code, language),
    FOREIGN KEY (product_id) REFERENCES products(id) ON DELETE CASCADE,
    FOREIGN KEY (county_code) REFERENCES counties(code) ON DELETE CASCADE,
    INDEX idx_product_translation (county_code, language)
) ENGINE=InnoDB;

##################
# Order Management
##################

CREATE TABLE orders (
    id INT AUTO_INCREMENT PRIMARY KEY,
    tenant_id INT NOT NULL,
    customer_id INT NOT NULL,
    order_number VARCHAR(20) UNIQUE NOT NULL,
    status ENUM('pending', 'paid', 'processing', 'shipped', 'delivered', 'cancelled') NOT NULL DEFAULT 'pending',
    subtotal DECIMAL(10,2) NOT NULL,
    delivery_fee DECIMAL(6,2) NOT NULL,
    tax_amount DECIMAL(6,2) NOT NULL,
    total_amount DECIMAL(10,2) NOT NULL,
    delivery_county_code TINYINT NOT NULL,
    delivery_address TEXT NOT NULL,
    delivery_notes TEXT,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (tenant_id) REFERENCES tenants(id) ON DELETE CASCADE,
    FOREIGN KEY (customer_id) REFERENCES users(id) ON DELETE RESTRICT,
    FOREIGN KEY (delivery_county_code) REFERENCES counties(code) ON DELETE RESTRICT,
    INDEX idx_order_status (status),
    INDEX idx_order_customer (customer_id),
    INDEX idx_order_date (created_at)
) ENGINE=InnoDB;

CREATE TABLE order_items (
    id INT AUTO_INCREMENT PRIMARY KEY,
    order_id INT NOT NULL,
    product_item_id INT NOT NULL,
    quantity INT NOT NULL CHECK (quantity > 0),
    unit_price DECIMAL(10,2) NOT NULL,
    total_price DECIMAL(10,2) NOT NULL,
    vendor_id INT NOT NULL,
    FOREIGN KEY (order_id) REFERENCES orders(id) ON DELETE CASCADE,
    FOREIGN KEY (product_item_id) REFERENCES product_items(id) ON DELETE RESTRICT,
    FOREIGN KEY (vendor_id) REFERENCES vendors(id) ON DELETE RESTRICT,
    INDEX idx_order_item (order_id, product_item_id)
) ENGINE=InnoDB;

##################
# Payment System
##################

CREATE TABLE payment_methods (
    id INT AUTO_INCREMENT PRIMARY KEY,
    tenant_id INT NOT NULL,
    code VARCHAR(20) NOT NULL,
    name VARCHAR(50) NOT NULL,
    is_active BOOLEAN NOT NULL DEFAULT TRUE,
    config JSON,
    FOREIGN KEY (tenant_id) REFERENCES tenants(id) ON DELETE CASCADE,
    UNIQUE INDEX idx_payment_method (tenant_id, code)
) ENGINE=InnoDB;

CREATE TABLE payments (
    id INT AUTO_INCREMENT PRIMARY KEY,
    tenant_id INT NOT NULL,
    order_id INT NOT NULL,
    payment_method_id INT NOT NULL,
    amount DECIMAL(10,2) NOT NULL,
    transaction_id VARCHAR(100),
    status ENUM('pending', 'completed', 'failed', 'refunded') NOT NULL DEFAULT 'pending',
    payment_details JSON,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (tenant_id) REFERENCES tenants(id) ON DELETE CASCADE,
    FOREIGN KEY (order_id) REFERENCES orders(id) ON DELETE CASCADE,
    FOREIGN KEY (payment_method_id) REFERENCES payment_methods(id) ON DELETE RESTRICT,
    INDEX idx_payment_status (status),
    INDEX idx_payment_transaction (transaction_id),
    INDEX idx_payment_date (created_at)
) ENGINE=InnoDB;

##################
# Delivery System
##################

CREATE TABLE deliveries (
    id INT AUTO_INCREMENT,
    order_id INT NOT NULL,
    from_county TINYINT NOT NULL,
    to_county TINYINT NOT NULL,
    cost DECIMAL(6,2) NOT NULL,
    status ENUM('pending', 'dispatched', 'in_transit', 'delivered') NOT NULL DEFAULT 'pending',
    tracking_number VARCHAR(50),
    estimated_delivery_date DATE,
    actual_delivery_date DATE,
    PRIMARY KEY (id, to_county),
    FOREIGN KEY (order_id) REFERENCES orders(id) ON DELETE CASCADE,
    FOREIGN KEY (from_county) REFERENCES counties(code) ON DELETE RESTRICT,
    FOREIGN KEY (to_county) REFERENCES counties(code) ON DELETE RESTRICT,
    INDEX idx_delivery_status (status),
    INDEX idx_delivery_tracking (tracking_number)
) ENGINE=InnoDB
PARTITION BY LIST (to_county) (
    PARTITION p_nairobi VALUES IN (47),
    PARTITION p_coastal VALUES IN (1,2,3),
    PARTITION p_other VALUES IN (4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,32,33,34,35,36,37,38,39,40,41,42,43,44,45,46,48)
);

##################
# Advanced Features
##################

CREATE FUNCTION calculate_delivery_fee(
    from_county TINYINT,
    to_county TINYINT,
    weight_kg DECIMAL(5,2)
) RETURNS DECIMAL(7,2) DETERMINISTIC
BEGIN
    DECLARE base_rate DECIMAL(5,2);
    DECLARE county_surcharge DECIMAL(5,2);
    
    -- Get base county rate
    SELECT delivery_base_rate INTO county_surcharge
    FROM counties WHERE code = to_county;
    
    -- Calculate base rate
    IF from_county = to_county THEN
        SET base_rate = county_surcharge * 0.5; -- Local delivery discount
    ELSEIF from_county = 47 THEN -- From Nairobi
        SET base_rate = county_surcharge * 1.2;
    ELSE
        SET base_rate = county_surcharge;
    END IF;
    
    -- Apply weight multiplier
    RETURN base_rate * (1 + (weight_kg / 10));
END;

CREATE TRIGGER update_product_search_index AFTER INSERT ON products
FOR EACH ROW
BEGIN
    INSERT INTO product_search_index (product_id, content)
    VALUES (NEW.id, CONCAT(NEW.name, ' ', NEW.description))
    ON DUPLICATE KEY UPDATE content = CONCAT(NEW.name, ' ', NEW.description);
END;

CREATE TRIGGER update_inventory_after_order AFTER INSERT ON order_items
FOR EACH ROW
BEGIN
    UPDATE product_items
    SET inventory_quantity = inventory_quantity - NEW.quantity
    WHERE id = NEW.product_item_id;
END;

##################
# Analytics Tables
##################

CREATE TABLE revenue_by_county (
    county_code TINYINT NOT NULL,
    date DATE NOT NULL,
    transaction_count INT NOT NULL DEFAULT 0,
    total_revenue DECIMAL(12,2) NOT NULL DEFAULT 0.00,
    PRIMARY KEY (county_code, date),
    FOREIGN KEY (county_code) REFERENCES counties(code) ON DELETE CASCADE
) ENGINE=InnoDB;

CREATE TABLE vendor_performance (
    vendor_id INT NOT NULL,
    month DATE NOT NULL,
    order_count INT NOT NULL DEFAULT 0,
    total_sales DECIMAL(12,2) NOT NULL DEFAULT 0.00,
    avg_rating DECIMAL(3,2) NOT NULL DEFAULT 0.00,
    PRIMARY KEY (vendor_id, month),
    FOREIGN KEY (vendor_id) REFERENCES vendors(id) ON DELETE CASCADE
) ENGINE=InnoDB;

##################
# Indexes for Performance
##################

CREATE INDEX idx_product_price ON products(tenant_id, base_price);
CREATE INDEX idx_product_active ON products(tenant_id, is_active);
CREATE INDEX idx_order_vendor ON order_items(vendor_id);
CREATE INDEX idx_payment_method_active ON payment_methods(tenant_id, is_active);