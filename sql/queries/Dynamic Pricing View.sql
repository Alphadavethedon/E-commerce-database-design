CREATE VIEW county_product_prices AS
SELECT 
    p.name,
    c.name AS county,
    p.base_price * (1 + cp.markup) AS final_price,
    calculate_delivery(47, c.code, 1) AS delivery_fee  -- From Nairobi
FROM products p
JOIN county_products cp ON p.id = cp.product_id
JOIN counties c ON cp.county_code = c.code;