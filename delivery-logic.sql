-- DYNAMIC DELIVERY CALCULATION
CREATE FUNCTION calculate_delivery(
    from_county TINYINT,
    to_county TINYINT,
    weight_kg DECIMAL(5,2)
RETURNS DECIMAL(7,2) DETERMINISTIC
BEGIN
    DECLARE base_rate DECIMAL(5,2);
    
    SELECT 
        CASE 
            WHEN from_county = to_county THEN 100.00
            WHEN from_county = 47 THEN 250.00 -- From Nairobi
            ELSE 350.00
        END * (1 + weight_kg/10) 
    INTO base_rate;
    
    RETURN base_rate;
END;