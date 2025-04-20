-- Product Catalog View
CREATE VIEW product_catalog AS
SELECT 
  p.id,
  p.name,
  b.name AS brand,
  pc.name AS category,
  MIN(pi.price) AS starting_price
FROM products p
JOIN brands b ON p.brand_id = b.id
JOIN product_categories pc ON p.category_id = pc.id
JOIN product_items pi ON p.id = pi.product_id
GROUP BY p.id;

-- Inventory Alert Query
SELECT 
  p.name,
  pi.sku,
  pi.quantity_in_stock
FROM product_items pi
JOIN products p ON pi.product_id = p.id
WHERE pi.quantity_in_stock < 10;