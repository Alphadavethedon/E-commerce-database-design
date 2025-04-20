-- INFORMAL SECTOR SUPPORT
CREATE TABLE county_vendors (
    id INT AUTO_INCREMENT PRIMARY KEY,
    county_code TINYINT NOT NULL,
    business_name VARCHAR(100) NOT NULL,
    mpesa_paybill VARCHAR(10),
    airtel_money VARCHAR(15),
    FOREIGN KEY (county_code) REFERENCES counties(code)
);

-- LOCAL LANGUAGE SUPPORT
CREATE TABLE product_translations (
    product_id INT NOT NULL,
    county_code TINYINT NOT NULL,
    language ENUM('sw','en','kam','kik','luo') DEFAULT 'sw',
    translated_name VARCHAR(255) NOT NULL,
    PRIMARY KEY (product_id, county_code, language)
);