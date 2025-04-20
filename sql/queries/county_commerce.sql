-- COUNTY SUPPORT CORE
CREATE TABLE counties (
    code TINYINT PRIMARY KEY, -- 1-47
    name VARCHAR(30) NOT NULL UNIQUE,
    delivery_surcharge DECIMAL(5,2),
    active_carriers SET('Safaricom','Airtel','Telkom') NOT NULL
);

-- Insert all 47 counties
INSERT INTO counties (code, name, delivery_surcharge, active_carriers) VALUES
(1, 'Mombasa', 150.00, 'Safaricom,Airtel'),
(2, 'Kwale', 200.00, 'Safaricom'),
...
(47, 'Nairobi', 0.00, 'Safaricom,Airtel,Telkom');

-- COUNTY-SPECIFIC PRICING
CREATE TABLE county_products (
    product_id INT NOT NULL,
    county_code TINYINT NOT NULL,
    markup DECIMAL(5,2) DEFAULT 0.00,
    available BOOLEAN DEFAULT TRUE,
    PRIMARY KEY (product_id, county_code),
    FOREIGN KEY (county_code) REFERENCES counties(code)
);