-- Database table
CREATE TABLE ussd_codes (
    carrier ENUM('Safaricom','Airtel','Telkom') PRIMARY KEY,
    code VARCHAR(10) NOT NULL UNIQUE,
    cost_per_session DECIMAL(5,2) NOT NULL
);

INSERT INTO ussd_codes VALUES
('Safaricom', '*123#', 0.50),
('Airtel', '*321#', 0.30),
('Telkom', '*111#', 0.20);