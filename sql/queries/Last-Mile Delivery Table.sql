CREATE TABLE delivery_routes (
    from_county TINYINT,
    to_county TINYINT,
    partner VARCHAR(50) NOT NULL,
    days TINYINT NOT NULL,
    base_cost DECIMAL(6,2) NOT NULL,
    PRIMARY KEY (from_county, to_county),
    FOREIGN KEY (from_county) REFERENCES counties(code),
    FOREIGN KEY (to_county) REFERENCES counties(code)
);

-- Sample data for 3 counties
INSERT INTO delivery_routes VALUES
(47, 1, 'Sendy', 2, 250.00),  # Nairobi→Mombasa
(47, 3, 'Bodaboda Collective', 4, 180.00), # Nairobi→Kilifi
(1, 3, 'Ferry Service', 1, 120.00); # Mombasa→Kilifi