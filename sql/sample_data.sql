-- Insert Brands
INSERT INTO brands (name, description) VALUES
('Nike', 'Athletic apparel and footwear'),
('Samsung', 'Electronics and appliances');

-- Insert Categories
INSERT INTO product_categories (name, parent_id) VALUES
('Electronics', NULL),
('Smartphones', 1),
('Clothing', NULL),
('Footwear', 3);

-- Insert Products
INSERT INTO products (name, description, base_price, brand_id, category_id) VALUES
('Galaxy S23', 'Flagship smartphone', 999.99, 2, 2),
('Air Max 90', 'Classic sneakers', 129.99, 1, 4);