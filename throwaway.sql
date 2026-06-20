SELECT 1;

-- ============================================================
-- Sample SQL queries for throwaway/testing purposes.
-- Generic tables: users, orders, products, order_items.
-- Standard SQL; not tied to any specific database engine.
-- ============================================================

-- 1. SELECT: all active users ordered by signup date.
SELECT id, name, email, created_at
FROM users
WHERE status = 'active'
ORDER BY created_at DESC;

-- 2. SELECT with aggregate: count users per status.
SELECT status, COUNT(*) AS user_count
FROM users
GROUP BY status;

-- 3. INSERT: add a new user.
INSERT INTO users (name, email, status, created_at)
VALUES ('Ada Lovelace', 'ada@example.com', 'active', CURRENT_TIMESTAMP);

-- 4. INSERT: add a new product.
INSERT INTO products (name, sku, price, in_stock)
VALUES ('Wireless Mouse', 'WM-001', 24.99, TRUE);

-- 5. UPDATE: bump the price of a single product.
UPDATE products
SET price = price * 1.10
WHERE sku = 'WM-001';

-- 6. UPDATE: deactivate users who have not logged in for a year.
UPDATE users
SET status = 'inactive'
WHERE last_login_at < CURRENT_DATE - INTERVAL '365' DAY;

-- 7. DELETE: remove products that are out of stock and unpriced.
DELETE FROM products
WHERE in_stock = FALSE
  AND price IS NULL;

-- 8. INNER JOIN: orders with the name of the user who placed them.
SELECT o.id AS order_id, u.name AS customer, o.total, o.placed_at
FROM orders AS o
INNER JOIN users AS u ON u.id = o.user_id
ORDER BY o.placed_at DESC;

-- 9. LEFT JOIN: every user with their order count (including zero).
SELECT u.id, u.name, COUNT(o.id) AS order_count
FROM users AS u
LEFT JOIN orders AS o ON o.user_id = u.id
GROUP BY u.id, u.name;

-- 10. Multi-table JOIN: line items expanded with product and order info.
SELECT o.id AS order_id, p.name AS product, oi.quantity, oi.unit_price
FROM order_items AS oi
INNER JOIN orders AS o ON o.id = oi.order_id
INNER JOIN products AS p ON p.id = oi.product_id
ORDER BY o.id, p.name;

-- 11. GROUP BY with HAVING: products that sold more than 100 units.
SELECT p.id, p.name, SUM(oi.quantity) AS total_sold
FROM products AS p
INNER JOIN order_items AS oi ON oi.product_id = p.id
GROUP BY p.id, p.name
HAVING SUM(oi.quantity) > 100
ORDER BY total_sold DESC;

-- 12. GROUP BY: total revenue per day.
SELECT DATE(placed_at) AS order_day, SUM(total) AS daily_revenue
FROM orders
GROUP BY DATE(placed_at)
ORDER BY order_day;

-- 13. Subquery (IN): users who have placed at least one order.
SELECT id, name, email
FROM users
WHERE id IN (SELECT DISTINCT user_id FROM orders);

-- 14. Correlated subquery: each user's most recent order total.
SELECT u.id, u.name,
       (SELECT o.total
        FROM orders AS o
        WHERE o.user_id = u.id
        ORDER BY o.placed_at DESC
        LIMIT 1) AS latest_order_total
FROM users AS u;

-- 15. Subquery in FROM: average order total per customer, then overall average.
SELECT AVG(per_user.avg_total) AS avg_of_customer_averages
FROM (
    SELECT user_id, AVG(total) AS avg_total
    FROM orders
    GROUP BY user_id
) AS per_user;
