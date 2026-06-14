-- =====================================================
-- Highland Milk Industries - Triggers
-- =====================================================

USE highland_milk_db;

DELIMITER //

-- =====================================================
-- Trigger 1: Calculate Order Line Total (BEFORE INSERT)
-- =====================================================
CREATE TRIGGER trg_calculate_order_line_total_insert
BEFORE INSERT ON ORDER_LINE
FOR EACH ROW
BEGIN
    -- Calculate line total as quantity × unit price
    SET NEW.line_total = NEW.quantity * NEW.unit_price;
END//

-- =====================================================
-- Trigger 2: Calculate Order Line Total (BEFORE UPDATE)
-- =====================================================
CREATE TRIGGER trg_calculate_order_line_total_update
BEFORE UPDATE ON ORDER_LINE
FOR EACH ROW
BEGIN
    -- Recalculate line total if quantity or price changes
    SET NEW.line_total = NEW.quantity * NEW.unit_price;
END//

-- =====================================================
-- Trigger 3: Set Quality Grade Based on Parameters
-- =====================================================
CREATE TRIGGER trg_set_quality_grade
BEFORE INSERT ON MILK_COLLECTION
FOR EACH ROW
BEGIN
    -- Determine quality grade based on fat and SNF values
    IF NEW.fat_percentage >= 6.0 AND NEW.snf_value >= 9.0 THEN
        SET NEW.quality_grade = 'A';
    ELSEIF NEW.fat_percentage >= 4.5 AND NEW.snf_value >= 8.5 THEN
        SET NEW.quality_grade = 'B';
    ELSE
        SET NEW.quality_grade = 'C';
    END IF;
END//

-- =====================================================
-- Trigger 4: Update Daily Collection Summary
-- =====================================================
CREATE TRIGGER trg_update_daily_collection_summary
AFTER INSERT ON MILK_COLLECTION
FOR EACH ROW
BEGIN
    -- Insert or update daily summary
    INSERT INTO DAILY_COLLECTION_SUMMARY 
        (collection_date, total_collections, total_quantity, average_fat_percentage)
    VALUES 
        (NEW.collection_date, 1, NEW.quantity_liters, NEW.fat_percentage)
    ON DUPLICATE KEY UPDATE
        total_collections = total_collections + 1,
        total_quantity = total_quantity + NEW.quantity_liters,
        average_fat_percentage = (
            (average_fat_percentage * total_collections + NEW.fat_percentage) / 
            (total_collections + 1)
        );
END//

-- =====================================================
-- Trigger 5: Update Inventory on Order Confirmation
-- =====================================================
CREATE TRIGGER trg_update_inventory_on_order_confirm
AFTER UPDATE ON CUSTOMER_ORDER
FOR EACH ROW
BEGIN
    -- Only execute when order status changes to 'Confirmed'
    IF NEW.order_status = 'Confirmed' AND OLD.order_status = 'Pending' THEN
        -- Update inventory for each order line
        UPDATE INVENTORY i
        INNER JOIN ORDER_LINE ol ON i.product_id = ol.product_id
        SET i.quantity = i.quantity - ol.quantity
        WHERE ol.order_id = NEW.order_id
        AND i.warehouse_id = (
            SELECT warehouse_id 
            FROM WAREHOUSE 
            WHERE status = 'Active' 
            ORDER BY warehouse_id 
            LIMIT 1
        )
        AND i.quantity >= ol.quantity;
    END IF;
END//

-- =====================================================
-- Trigger 6: Restore Inventory on Order Cancellation
-- =====================================================
CREATE TRIGGER trg_restore_inventory_on_cancel
AFTER UPDATE ON CUSTOMER_ORDER
FOR EACH ROW
BEGIN
    -- Only execute when order status changes to 'Cancelled' from 'Confirmed'
    IF NEW.order_status = 'Cancelled' AND OLD.order_status = 'Confirmed' THEN
        -- Restore inventory for each order line
        UPDATE INVENTORY i
        INNER JOIN ORDER_LINE ol ON i.product_id = ol.product_id
        SET i.quantity = i.quantity + ol.quantity
        WHERE ol.order_id = NEW.order_id
        AND i.warehouse_id = (
            SELECT warehouse_id 
            FROM WAREHOUSE 
            WHERE status = 'Active' 
            ORDER BY warehouse_id 
            LIMIT 1
        );
    END IF;
END//

DELIMITER ;

-- Display confirmation
SELECT 'All triggers created successfully!' as Status;
