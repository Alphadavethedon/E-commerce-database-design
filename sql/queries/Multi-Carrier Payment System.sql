-- UNIFIED PAYMENTS TABLE
CREATE TABLE mobile_payments (
    id VARCHAR(36) PRIMARY KEY,
    phone VARCHAR(15) NOT NULL CHECK (phone LIKE '+254%'),
    amount DECIMAL(10,2) NOT NULL,
    county_code TINYINT NOT NULL,
    carrier ENUM('Safaricom','Airtel','Telkom') NOT NULL,
    status ENUM('pending','paid','failed'),
    FOREIGN KEY (county_code) REFERENCES counties(code)
) PARTITION BY LIST (county_code) (
    PARTITION mombasa VALUES IN (1),
    PARTITION nairobi VALUES IN (47),
    ...
);

-- CARRIER FEE MATRIX
CREATE TABLE carrier_fees (
    carrier ENUM('Safaricom','Airtel','Telkom') PRIMARY KEY,
    base_fee DECIMAL(5,2) NOT NULL,
    percentage_fee DECIMAL(3,2) NOT NULL
);

INSERT INTO carrier_fees VALUES
('Safaricom', 5.00, 0.01),  -- KSh 5 + 1%
('Airtel', 3.00, 0.015),     -- KSh 3 + 1.5%
('Telkom', 2.50, 0.02);      -- KSh 2.50 + 2%