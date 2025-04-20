### Revenue Tracking
-- This query tracks the revenue generated from each product category over time.
-- It aggregates the revenue by category and month, allowing for analysis of sales trends.
CREATE TABLE revenue_streams (
    id INT AUTO_INCREMENT PRIMARY KEY,
    county_code TINYINT NOT NULL,
    stream_type ENUM('subscription','transaction','data'),
    amount DECIMAL(10,2) NOT NULL,
    FOREIGN KEY (county_code) REFERENCES counties(code)
) PARTITION BY LIST (county_code) (
    PARTITION p_nairobi VALUES IN (47),
    PARTITION p_mombasa VALUES IN (1),
    PARTITION p_other VALUES IN (SELECT code FROM counties WHERE code NOT IN (1,47))
);