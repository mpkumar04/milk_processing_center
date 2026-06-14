-- =====================================================
-- Highland Milk Industries - Views
-- Fixed for MariaDB / XAMPP
-- =====================================================

USE highland_milk_db;

DROP VIEW IF EXISTS vw_farmer_payment_summary;
DROP VIEW IF EXISTS vw_product_stock_status;
DROP VIEW IF EXISTS vw_monthly_sales_analysis;
DROP VIEW IF EXISTS vw_milk_collection_performance;
DROP VIEW IF EXISTS vw_customer_order_status;
DROP VIEW IF EXISTS vw_business_dashboard;

CREATE VIEW vw_farmer_payment_summary AS
SELECT 
    f.farmer_id,
    f.nic_number,
    CONCAT(f.first_name, ' ', f.last_name) AS farmer_name,
    f.district,
    f.village,
    f.contact_number,
    f.bank_name,
    f.bank_account_no,
    f.bank_branch,
    p.payment_id,
    p.payment_date,
    p.period_month,
    p.period_year,
    p.total_quantity,
    p.base_amount,
    p.quality_premium,
    p.total_amount,
    p.payment_status,
    p.payment_method,
    CONCAT(e.first_name, ' ', e.last_name) AS processed_by_name
FROM FARMER f
LEFT JOIN PAYMENT p ON f.farmer_id = p.farmer_id
LEFT JOIN EMPLOYEE e ON p.processed_by = e.employee_id
WHERE f.status = 'Active';

CREATE VIEW vw_product_stock_status AS
SELECT 
    p.product_id,
    p.product_code,
    p.product_name,
    pc.category_name,
    w.warehouse_name,
    w.district AS warehouse_district,
    i.quantity AS current_stock,
    i.reorder_level,
    i.batch_number,
    i.manufacture_date,
    i.expiry_date,
    DATEDIFF(i.expiry_date, CURDATE()) AS days_to_expiry,
    CASE 
        WHEN i.quantity = 0 THEN 'OUT OF STOCK'
        WHEN DATEDIFF(i.expiry_date, CURDATE()) <= 0 THEN 'EXPIRED'
        WHEN DATEDIFF(i.expiry_date, CURDATE()) <= 7 THEN 'EXPIRING SOON'
        WHEN i.quantity < i.reorder_level THEN 'LOW STOCK'
        ELSE 'OK'
    END AS stock_status,
    i.last_updated
FROM INVENTORY i
JOIN PRODUCT p ON i.product_id = p.product_id
JOIN PRODUCT_CATEGORY pc ON p.category_id = pc.category_id
JOIN WAREHOUSE w ON i.warehouse_id = w.warehouse_id
WHERE p.status = 'Active';

CREATE VIEW vw_monthly_sales_analysis AS
SELECT 
    YEAR(o.order_date) AS order_year,
    MONTH(o.order_date) AS order_month,
    DATE_FORMAT(o.order_date, '%Y-%m') AS report_month,
    p.product_id,
    p.product_code,
    p.product_name,
    pc.category_name,
    COUNT(DISTINCT o.order_id) AS order_count,
    SUM(ol.quantity) AS total_quantity_sold,
    SUM(ol.line_total) AS total_sales_amount,
    AVG(ol.unit_price) AS avg_selling_price,
    COUNT(DISTINCT o.customer_id) AS unique_customers
FROM CUSTOMER_ORDER o
JOIN ORDER_LINE ol ON o.order_id = ol.order_id
JOIN PRODUCT p ON ol.product_id = p.product_id
JOIN PRODUCT_CATEGORY pc ON p.category_id = pc.category_id
WHERE o.order_status IN ('Confirmed', 'Delivered')
GROUP BY 
    YEAR(o.order_date),
    MONTH(o.order_date),
    DATE_FORMAT(o.order_date, '%Y-%m'),
    p.product_id,
    p.product_code,
    p.product_name,
    pc.category_name;

CREATE VIEW vw_milk_collection_performance AS
SELECT 
    f.farmer_id,
    CONCAT(f.first_name, ' ', f.last_name) AS farmer_name,
    f.district AS farmer_district,
    f.village,
    cc.center_name,
    DATE_FORMAT(mc.collection_date, '%Y-%m') AS report_month,
    COUNT(*) AS collection_days,
    SUM(mc.quantity_liters) AS total_quantity,
    AVG(mc.quantity_liters) AS avg_daily_quantity,
    AVG(mc.fat_percentage) AS avg_fat_percentage,
    AVG(mc.snf_value) AS avg_snf,
    SUM(CASE WHEN mc.quality_grade = 'A' THEN 1 ELSE 0 END) AS grade_a_count,
    SUM(CASE WHEN mc.quality_grade = 'B' THEN 1 ELSE 0 END) AS grade_b_count,
    SUM(CASE WHEN mc.quality_grade = 'C' THEN 1 ELSE 0 END) AS grade_c_count,
    ROUND((SUM(CASE WHEN mc.quality_grade = 'A' THEN 1 ELSE 0 END) / COUNT(*)) * 100, 2) AS quality_a_percentage
FROM MILK_COLLECTION mc
JOIN FARMER f ON mc.farmer_id = f.farmer_id
JOIN COLLECTION_CENTER cc ON mc.collection_center_id = cc.center_id
GROUP BY 
    f.farmer_id,
    f.first_name,
    f.last_name,
    f.district,
    f.village,
    cc.center_name,
    DATE_FORMAT(mc.collection_date, '%Y-%m');

CREATE VIEW vw_customer_order_status AS
SELECT 
    o.order_id,
    o.order_date,
    o.required_date,
    c.customer_id,
    c.customer_name,
    c.customer_type,
    c.district,
    o.order_status,
    o.total_amount,
    COUNT(ol.order_line_id) AS item_count,
    d.delivery_id,
    d.delivery_date,
    d.delivery_status,
    d.actual_delivery_date,
    d.vehicle_number,
    CONCAT(e1.first_name, ' ', e1.last_name) AS processed_by,
    CONCAT(e2.first_name, ' ', e2.last_name) AS driver_name,
    CASE 
        WHEN o.order_status = 'Delivered' THEN 'Completed'
        WHEN o.order_status = 'Cancelled' THEN 'Cancelled'
        WHEN d.delivery_status = 'Failed' THEN 'Failed Delivery'
        WHEN o.required_date < CURDATE() AND o.order_status = 'Pending' THEN 'Overdue'
        ELSE 'In Progress'
    END AS overall_status
FROM CUSTOMER_ORDER o
JOIN CUSTOMER c ON o.customer_id = c.customer_id
JOIN ORDER_LINE ol ON o.order_id = ol.order_id
LEFT JOIN DELIVERY d ON o.order_id = d.order_id
LEFT JOIN EMPLOYEE e1 ON o.processed_by = e1.employee_id
LEFT JOIN EMPLOYEE e2 ON d.driver_id = e2.employee_id
GROUP BY 
    o.order_id,
    o.order_date,
    o.required_date,
    c.customer_id,
    c.customer_name,
    c.customer_type,
    c.district,
    o.order_status,
    o.total_amount,
    d.delivery_id,
    d.delivery_date,
    d.delivery_status,
    d.actual_delivery_date,
    d.vehicle_number,
    e1.first_name,
    e1.last_name,
    e2.first_name,
    e2.last_name;

CREATE VIEW vw_business_dashboard AS
SELECT 
    'Current Month Statistics' AS metric_category,
    (SELECT COUNT(*) FROM FARMER WHERE status = 'Active') AS active_farmers,
    (SELECT COUNT(DISTINCT farmer_id) 
     FROM MILK_COLLECTION 
     WHERE MONTH(collection_date) = MONTH(CURDATE()) 
     AND YEAR(collection_date) = YEAR(CURDATE())) AS farmers_who_supplied,
    (SELECT COALESCE(SUM(quantity_liters), 0) 
     FROM MILK_COLLECTION 
     WHERE MONTH(collection_date) = MONTH(CURDATE()) 
     AND YEAR(collection_date) = YEAR(CURDATE())) AS total_milk_collected,
    (SELECT COUNT(*) 
     FROM CUSTOMER_ORDER 
     WHERE MONTH(order_date) = MONTH(CURDATE()) 
     AND YEAR(order_date) = YEAR(CURDATE())) AS total_orders,
    (SELECT COALESCE(SUM(total_amount), 0) 
     FROM CUSTOMER_ORDER 
     WHERE order_status IN ('Confirmed', 'Delivered')
     AND MONTH(order_date) = MONTH(CURDATE()) 
     AND YEAR(order_date) = YEAR(CURDATE())) AS total_revenue,
    (SELECT COUNT(*) 
     FROM INVENTORY 
     WHERE quantity < reorder_level) AS low_stock_products,
    (SELECT COUNT(*) 
     FROM CUSTOMER_ORDER 
     WHERE order_status = 'Pending') AS pending_orders,
    (SELECT COUNT(*) 
     FROM DELIVERY 
     WHERE delivery_status = 'Scheduled') AS scheduled_deliveries;

SELECT 'All views created successfully!' AS Status;