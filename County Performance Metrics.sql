-- Revenue by county
SELECT 
    c.name,
    COUNT(p.payment_id) AS transactions,
    SUM(p.amount) AS revenue
FROM payments p
JOIN counties c ON p.county_code = c.code
GROUP BY c.code
ORDER BY revenue DESC;