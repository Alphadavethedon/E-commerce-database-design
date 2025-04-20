CREATE TABLE tenants (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100),
    api_key VARCHAR(64) UNIQUE,
    plan ENUM('starter','pro','enterprise'),
    monthly_fee DECIMAL(10,2)
);

CREATE TABLE products (
    id INT AUTO_INCREMENT PRIMARY KEY,
    tenant_id INT NOT NULL,
    name VARCHAR(255),
    price DECIMAL(10,2),
    FOREIGN KEY (tenant_id) REFERENCES tenants(id)
);