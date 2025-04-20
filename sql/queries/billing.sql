CREATE TABLE api_usage (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    tenant_id INT NOT NULL,
    endpoint VARCHAR(50),
    credits_used INT DEFAULT 1,
    charge_amount DECIMAL(10,2),
    timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);