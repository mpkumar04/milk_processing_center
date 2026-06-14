-- =====================================================
-- Milk Processing Center - Stored Procedures
-- =====================================================

USE highland_milk_db;

DELIMITER //

-- =====================================================
-- Procedure 1: Calculate and Generate Farmer Payment
-- =====================================================
CREATE PROCEDURE sp_calculate_farmer_payment(
    IN p_farmer_id INT,
    IN p_month INT,
    IN p_year INT,
    IN p_base_rate DECIMAL(10,2),
    IN p_processed_by INT
)
BEGIN
    DECLARE v_total_quantity DECIMAL(10,2);
    DECLARE v_avg_fat_percentage DECIMAL(5,2);
    DECLARE v_base_amount DECIMAL(12,2);
    DECLARE v_quality_premium DECIMAL(10,2);
    DECLARE v_total_amount DECIMAL(12,2);
    DECLARE v_payment_exists INT;
    
    -- Check if payment already exists
    SELECT COUNT(*) INTO v_payment_exists
    FROM PAYMENT
    WHERE farmer_id = p_farmer_id
    AND period_month = p_month
    AND period_year = p_year;
    
    IF v_payment_exists > 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Payment already exists for this farmer in the specified period';
    END IF;
    
    -- Calculate total quantity and average fat percentage
    SELECT 
        SUM(quantity_liters),
        AVG(fat_percentage)
    INTO 
        v_total_quantity,
        v_avg_fat_percentage
    FROM MILK_COLLECTION
    WHERE farmer_id = p_farmer_id
    AND MONTH(collection_date) = p_month
    AND YEAR(collection_date) = p_year;
    
    -- Check if farmer had any collections
    IF v_total_quantity IS NULL OR v_total_quantity = 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'No collections found for this farmer in the specified period';
    END IF;
    
    -- Calculate base amount
    SET v_base_amount = v_total_quantity * p_base_rate;
    
    -- Calculate quality premium using the function
    SET v_quality_premium = fn_calculate_quality_premium(v_avg_fat_percentage, v_total_quantity, 3.5);
    
    -- Calculate total payment
    SET v_total_amount = v_base_amount + v_quality_premium;
    
    -- Insert payment record
    INSERT INTO PAYMENT (
        farmer_id, payment_date, period_month, period_year,
        total_quantity, base_amount, quality_premium, total_amount,
        payment_method, payment_status, processed_by
    ) VALUES (
        p_farmer_id, CURDATE(), p_month, p_year,
        v_total_quantity, v_base_amount, v_quality_premium, v_total_amount,
        'Bank Transfer', 'Pending', p_processed_by
    );
    
    -- Return payment details
    SELECT 
        LAST_INSERT_ID() as payment_id,
        v_total_quantity as total_liters,
        v_avg_fat_percentage as avg_fat_percentage,
        v_base_amount as base_amount,
        v_quality_premium as quality_premium,
        v_total_amount as total_amount,
        'Payment record created successfully' as message;
        
END//

-- =====================================================
-- Procedure 2: Process Customer Order
-- =====================================================
CREATE PROCEDURE sp_process_customer_order(
    IN p_customer_id INT,
    IN p_required_date DATE,
    IN p_processed_by INT,
    IN p_product_id INT,
    IN p_quantity DECIMAL(10,2),
    OUT p_order_id INT
)
BEGIN
    DECLARE v_subtotal DECIMAL(12,2) DEFAULT 0;
    DECLARE v_tax_rate DECIMAL(5,3) DEFAULT 0.08;
    DECLARE v_tax_amount DECIMAL(10,2);
    DECLARE v_total_amount DECIMAL(12,2);
    DECLARE v_unit_price DECIMAL(10,2);
    DECLARE v_available_stock DECIMAL(10,2);
    
    -- Validate customer exists and is active
    IF NOT EXISTS (SELECT 1 FROM CUSTOMER WHERE customer_id = p_customer_id AND status = 'Active') THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Customer not found or inactive';
    END IF;
    
    -- Get product price and validate
    SELECT unit_price INTO v_unit_price
    FROM PRODUCT
    WHERE product_id = p_product_id AND status = 'Active';
    
    IF v_unit_price IS NULL THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Invalid or inactive product';
    END IF;
    
    -- Check stock availability
    SELECT COALESCE(SUM(quantity), 0) INTO v_available_stock
    FROM INVENTORY
    WHERE product_id = p_product_id;
    
    IF v_available_stock < p_quantity THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Insufficient stock for product';
    END IF;
    
    -- Start transaction
    START TRANSACTION;
    
    -- Calculate amounts
    SET v_subtotal = p_quantity * v_unit_price;
    SET v_tax_amount = v_subtotal * v_tax_rate;
    SET v_total_amount = v_subtotal + v_tax_amount;
    
    -- Create order header
    INSERT INTO CUSTOMER_ORDER (
        customer_id, order_date, required_date, order_status,
        subtotal, tax_amount, total_amount, processed_by
    ) VALUES (
        p_customer_id, CURDATE(), p_required_date, 'Pending',
        v_subtotal, v_tax_amount, v_total_amount, p_processed_by
    );
    
    SET p_order_id = LAST_INSERT_ID();
    
    -- Insert order line
    INSERT INTO ORDER_LINE (order_id, product_id, quantity, unit_price, line_total)
    VALUES (p_order_id, p_product_id, p_quantity, v_unit_price, v_subtotal);
    
    COMMIT;
    
    -- Return order summary
    SELECT 
        p_order_id as order_id,
        v_subtotal as subtotal,
        v_tax_amount as tax_amount,
        v_total_amount as total_amount,
        'Order created successfully' as message;
        
END//

-- =====================================================
-- Procedure 3: Generate Monthly Collection Report
-- =====================================================
CREATE PROCEDURE sp_monthly_collection_report(
    IN p_month INT,
    IN p_year INT
)
BEGIN
    -- Summary statistics
    SELECT 
        'MONTHLY SUMMARY' as report_section,
        COUNT(DISTINCT farmer_id) as total_farmers,
        COUNT(*) as total_collections,
        SUM(quantity_liters) as total_quantity,
        ROUND(AVG(quantity_liters), 2) as avg_collection_per_day,
        ROUND(AVG(fat_percentage), 2) as avg_fat_percentage,
        ROUND(AVG(snf_value), 2) as avg_snf,
        SUM(CASE WHEN quality_grade = 'A' THEN 1 ELSE 0 END) as grade_a_count,
        SUM(CASE WHEN quality_grade = 'B' THEN 1 ELSE 0 END) as grade_b_count,
        SUM(CASE WHEN quality_grade = 'C' THEN 1 ELSE 0 END) as grade_c_count
    FROM MILK_COLLECTION
    WHERE MONTH(collection_date) = p_month
    AND YEAR(collection_date) = p_year;
    
    -- Top 10 farmers by quantity
    SELECT 
        'TOP 10 FARMERS' as report_section,
        f.farmer_id,
        CONCAT(f.first_name, ' ', f.last_name) as farmer_name,
        f.district,
        COUNT(*) as collection_days,
        ROUND(SUM(mc.quantity_liters), 2) as total_quantity,
        ROUND(AVG(mc.fat_percentage), 2) as avg_fat_percentage,
        ROUND(SUM(mc.quantity_liters) * 80, 2) as estimated_payment
    FROM MILK_COLLECTION mc
    JOIN FARMER f ON mc.farmer_id = f.farmer_id
    WHERE MONTH(mc.collection_date) = p_month
    AND YEAR(mc.collection_date) = p_year
    GROUP BY f.farmer_id, f.first_name, f.last_name, f.district
    ORDER BY total_quantity DESC
    LIMIT 10;
    
    -- Collection center performance
    SELECT 
        'CENTER PERFORMANCE' as report_section,
        cc.center_name,
        cc.district,
        COUNT(*) as total_collections,
        ROUND(SUM(mc.quantity_liters), 2) as total_quantity,
        ROUND(AVG(mc.fat_percentage), 2) as avg_fat_percentage,
        ROUND((SUM(mc.quantity_liters) / cc.capacity_liters) * 100, 2) as capacity_utilization_pct
    FROM MILK_COLLECTION mc
    JOIN COLLECTION_CENTER cc ON mc.collection_center_id = cc.center_id
    WHERE MONTH(mc.collection_date) = p_month
    AND YEAR(mc.collection_date) = p_year
    GROUP BY cc.center_id, cc.center_name, cc.district, cc.capacity_liters
    ORDER BY total_quantity DESC;
    
END//

-- =====================================================
-- Procedure 4: Stock Reorder Alert
-- =====================================================
CREATE PROCEDURE sp_stock_reorder_alert()
BEGIN
    -- Products below reorder level
    SELECT 
        'LOW STOCK PRODUCTS' as alert_type,
        p.product_id,
        p.product_code,
        p.product_name,
        pc.category_name,
        w.warehouse_name,
        i.quantity as current_stock,
        i.reorder_level,
        (i.reorder_level - i.quantity) as shortage,
        i.last_updated
    FROM INVENTORY i
    JOIN PRODUCT p ON i.product_id = p.product_id
    JOIN PRODUCT_CATEGORY pc ON p.category_id = pc.category_id
    JOIN WAREHOUSE w ON i.warehouse_id = w.warehouse_id
    WHERE i.quantity < i.reorder_level
    AND p.status = 'Active'
    ORDER BY (i.reorder_level - i.quantity) DESC;
    
    -- Products expiring within 7 days
    SELECT 
        'EXPIRING SOON' as alert_type,
        p.product_id,
        p.product_code,
        p.product_name,
        w.warehouse_name,
        i.batch_number,
        i.quantity,
        i.expiry_date,
        DATEDIFF(i.expiry_date, CURDATE()) as days_to_expiry
    FROM INVENTORY i
    JOIN PRODUCT p ON i.product_id = p.product_id
    JOIN WAREHOUSE w ON i.warehouse_id = w.warehouse_id
    WHERE i.expiry_date <= DATE_ADD(CURDATE(), INTERVAL 7 DAY)
    AND i.quantity > 0
    AND p.status = 'Active'
    ORDER BY i.expiry_date;
    
END//

-- =====================================================
-- Procedure 5: Update Payment Status
-- =====================================================
CREATE PROCEDURE sp_update_payment_status(
    IN p_payment_id INT,
    IN p_new_status VARCHAR(20)
)
BEGIN
    DECLARE v_current_status VARCHAR(20);
    
    -- Get current status
    SELECT payment_status INTO v_current_status
    FROM PAYMENT
    WHERE payment_id = p_payment_id;
    
    IF v_current_status IS NULL THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Payment ID not found';
    END IF;
    
    -- Validate status transition
    IF v_current_status = 'Completed' THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Cannot change status of completed payment';
    END IF;
    
    -- Update status
    UPDATE PAYMENT
    SET payment_status = p_new_status,
        updated_at = CURRENT_TIMESTAMP
    WHERE payment_id = p_payment_id;
    
    SELECT 
        p_payment_id as payment_id,
        v_current_status as old_status,
        p_new_status as new_status,
        'Payment status updated successfully' as message;
END//

DELIMITER ;

-- Display confirmation
SELECT 'All stored procedures created successfully!' as Status;
