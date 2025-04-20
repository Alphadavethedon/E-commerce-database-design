// Advanced E-Commerce Schema
Table products {
  product_id int [pk, increment]
  name varchar(255)
  brand_id int [ref: > brands.brand_id]
  // ... other fields ...
}

Table product_items {
  item_id int [pk, increment]
  product_id int [ref: > products.product_id]
  sku varchar(100) [unique]
  // ... other fields ...
}

// Generate with: dbml2png schema.dbml -o ERD/architecture.png