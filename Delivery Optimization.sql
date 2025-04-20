-- County-partitioned delivery table
CREATE TABLE deliveries (
    id INT AUTO_INCREMENT,
    from_county TINYINT NOT NULL,
    to_county TINYINT NOT NULL,
    cost DECIMAL(6,2) NOT NULL,
    PRIMARY KEY (id, to_county)
) PARTITION BY LIST (to_county) (
    PARTITION p_nairobi VALUES IN (47),
    PARTITION p_coastal VALUES IN (1,2,3),
    PARTITION p_other VALUES IN (SELECT code FROM counties WHERE code NOT IN (1,2,3,47))
);