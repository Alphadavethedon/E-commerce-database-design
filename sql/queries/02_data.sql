-- Premium Brands
INSERT INTO brands (name, slug, description) VALUES
('Apple', 'apple', 'Innovative technology products'),
('Nike', 'nike', 'Athletic apparel and footwear');

-- Hierarchical Categories
INSERT INTO product_categories (name, slug, parent_id) VALUES
('Electronics', 'electronics', NULL),
('Smartphones', 'smartphones', 1),
('Clothing', 'clothing', NULL),
('Running Shoes', 'running-shoes', 4);

-- Featured Products
INSERT INTO products (name, slug, description, base_price, brand_id, category_id) VALUES
('iPhone 15 Pro', 'iphone-15-pro', 'Titanium, A17 Pro chip, 48MP camera', 999.00, 1, 2),
('Air Jordan 1', 'air-jordan-1', 'Iconic basketball sneakers', 180.00, 2, 4);