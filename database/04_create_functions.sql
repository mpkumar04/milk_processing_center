-- =====================================================
-- Milk Processing Center - User-Defined Functions
-- =====================================================

USE highland_milk_db;

DELIMITER //

-- =====================================================
-- Function 1: Calculate Quality Premium for Milk Collection
-- =====================================================
CREATE FUNCTION fn_calculate_quality_premium(
    p_fat_percentage DECIMAL(4,2),
    p_quantity DECIMAL(8,2),
    p_base_fat DECIMAL(4,2)
)
RETURNS DECIMAL(10,2)
DETERMINISTIC
BEGIN
    DECLARE v_premium DECIMAL(10,2);
    DECLARE v_premium_rate DECIMAL(5,2) DEFAULT 5.00;
    
    -- Calculate premium if fat percentage exceeds base
    IF p_fat_percentage > p_base_fat THEN
        SET v_premium = (p_fat_percentage - p_base_fat) * v_premium_rate * p_quantity;
    ELSE
        SET v_premium = 0;
    END IF;
    
    RETURN v_premium;
END//

-- =====================================================
-- Function 2: Calculate Order Total with Tax
-- =====================================================
CREATE FUNCTION fn_calculate_order_total(
    p_order_id INT
)
RETURNS DECIMAL(12,2)
DETERMINISTIC
READS SQL DATA
BEGIN
    DECLARE v_subtotal DECIMAL(12,2);
    DECLARE v_tax_rate DECIMAL(5,3) DEFAULT 0.08;
    DECLARE v_total DECIMAL(12,2);
    
    -- Calculate subtotal from order lines
    SELECT COALESCE(SUM(line_total), 0)
    INTO v_subtotal
    FROM ORDER_LINE
    WHERE order_id = p_order_id;
    
    -- Calculate total with tax
    SET v_total = v_subtotal + (v_subtotal * v_tax_rate);
    
    RETURN v_total;
END//

-- =====================================================
-- Function 3: Determine Farmer Performance Grade
-- =====================================================
CREATE FUNCTION fn_farmer_performance_grade(
    p_farmer_id INT,
    p_month INT,
    p_year INT
)
RETURNS VARCHAR(20)
DETERMINISTIC
READS SQL DATA
BEGIN
    DECLARE v_total_quantity DECIMAL(10,2);
    DECLARE v_avg_fat DECIMAL(4,2);
    DECLARE v_collection_days INT;
    DECLARE v_grade VARCHAR(20);
    
    -- Get farmer statistics
    SELECT 
        COALESCE(SUM(quantity_liters), 0),
        COALESCE(AVG(fat_percentage), 0),
        COUNT(DISTINCT collection_date)
    INTO 
        v_total_quantity,
        v_avg_fat,
        v_collection_days
    FROM MILK_COLLECTION
    WHERE farmer_id = p_farmer_id
    AND MONTH(collection_date) = p_month
    AND YEAR(collection_date) = p_year;
    
    -- Determine grade based on criteria
    IF v_total_quantity >= 500 AND v_avg_fat >= 5.0 AND v_collection_days >= 25 THEN
        SET v_grade = 'Excellent';
    ELSEIF v_total_quantity >= 300 AND v_avg_fat >= 4.0 AND v_collection_days >= 20 THEN
        SET v_grade = 'Good';
    ELSEIF v_total_quantity >= 150 AND v_avg_fat >= 3.5 AND v_collection_days >= 15 THEN
        SET v_grade = 'Average';
    ELSEIF v_total_quantity > 0 THEN
        SET v_grade = 'Below Average';
    ELSE
        SET v_grade = 'No Activity';
    END IF;
    
    RETURN v_grade;
END//

-- =====================================================
-- Function 4: Calculate Days Until Product Expiry
-- =====================================================
CREATE FUNCTION fn_days_to_expiry(
    p_expiry_date DATE
)
RETURNS INT
DETERMINISTIC
BEGIN
    DECLARE v_days INT;
    
    SET v_days = DATEDIFF(p_expiry_date, CURDATE());
    
    RETURN v_days;
END//

-- =====================================================
-- Function 5: Get Customer Credit Available
-- =====================================================
CREATE FUNCTION fn_customer_credit_available(
    p_customer_id INT
)
RETURNS DECIMAL(10,2)
DETERMINISTIC
READS SQL DATA
BEGIN
    DECLARE v_credit_limit DECIMAL(10,2);
    DECLARE v_outstanding DECIMAL(10,2);
    DECLARE v_available DECIMAL(10,2);
    
    -- Get customer credit limit
    SELECT COALESCE(credit_limit, 0)
    INTO v_credit_limit
    FROM CUSTOMER
    WHERE customer_id = p_customer_id;
    
    -- Calculate outstanding amount (confirmed but not delivered orders)
    SELECT COALESCE(SUM(total_amount), 0)
    INTO v_outstanding
    FROM CUSTOMER_ORDER
    WHERE customer_id = p_customer_id
    AND order_status IN ('Confirmed', 'Pending');
    
    -- Calculate available credit
    SET v_available = v_credit_limit - v_outstanding;
    
    IF v_available < 0 THEN
        SET v_available = 0;
    END IF;
    
    RETURN v_available;
END//

-- =====================================================
-- Function 6: Calculate Delivery Charge by District
-- =====================================================
CREATE FUNCTION fn_delivery_charge(
    p_district VARCHAR(50)
)
RETURNS DECIMAL(8,2)
DETERMINISTIC
BEGIN
    DECLARE v_charge DECIMAL(8,2);
    
    -- Set charges based on district
    CASE p_district
        WHEN 'Colombo' THEN SET v_charge = 500.00;
        WHEN 'Gampaha' THEN SET v_charge = 750.00;
        WHEN 'Kandy' THEN SET v_charge = 1500.00;
        WHEN 'Galle' THEN SET v_charge = 2000.00;
        WHEN 'Matara' THEN SET v_charge = 2500.00;
        WHEN 'Jaffna' THEN SET v_charge = 3500.00;
        WHEN 'Batticaloa' THEN SET v_charge = 3000.00;
        WHEN 'Nuwara Eliya' THEN SET v_charge = 1800.00;
        WHEN 'Kurunegala' THEN SET v_charge = 1200.00;
        WHEN 'Anuradhapura' THEN SET v_charge = 2200.00;
        ELSE SET v_charge = 1000.00;
    END CASE;
    
    RETURN v_charge;
END//

DELIMITER ;

-- Display confirmation
SELECT 'All functions created successfully!' as Status;
