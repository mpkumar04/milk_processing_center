<?php
/**
 * Highland Milk Industries - Dashboard API
 * Business Intelligence Dashboard Data
 */

header("Access-Control-Allow-Origin: *");
header("Content-Type: application/json; charset=UTF-8");

require_once '../config/database.php';

$database = new Database();
$db = $database->getConnection();

// Get dashboard statistics
$stats = array();

try {
    // Active Farmers
    $query = "SELECT COUNT(*) as count FROM FARMER WHERE status = 'Active'";
    $stmt = $db->query($query);
    $stats['active_farmers'] = $stmt->fetch()['count'];

    // Today's Collections
    $query = "SELECT 
                COUNT(*) as count,
                COALESCE(SUM(quantity_liters), 0) as total_quantity,
                COALESCE(AVG(fat_percentage), 0) as avg_fat
              FROM MILK_COLLECTION 
              WHERE collection_date = CURDATE()";
    $stmt = $db->query($query);
    $today_collection = $stmt->fetch();
    $stats['today_collections'] = $today_collection['count'];
    $stats['today_quantity'] = round($today_collection['total_quantity'], 2);
    $stats['today_avg_fat'] = round($today_collection['avg_fat'], 2);

    // Pending Orders
    $query = "SELECT COUNT(*) as count FROM CUSTOMER_ORDER WHERE order_status = 'Pending'";
    $stmt = $db->query($query);
    $stats['pending_orders'] = $stmt->fetch()['count'];

    // Low Stock Products
    $query = "SELECT COUNT(*) as count FROM INVENTORY WHERE quantity < reorder_level";
    $stmt = $db->query($query);
    $stats['low_stock_products'] = $stmt->fetch()['count'];

    // This Month Revenue
    $query = "SELECT COALESCE(SUM(total_amount), 0) as revenue 
              FROM CUSTOMER_ORDER 
              WHERE order_status IN ('Confirmed', 'Delivered')
              AND MONTH(order_date) = MONTH(CURDATE())
              AND YEAR(order_date) = YEAR(CURDATE())";
    $stmt = $db->query($query);
    $stats['month_revenue'] = round($stmt->fetch()['revenue'], 2);

    // Recent Collections (Last 10)
    $query = "SELECT 
                mc.collection_id,
                CONCAT(f.first_name, ' ', f.last_name) as farmer_name,
                mc.collection_date,
                mc.quantity_liters,
                mc.fat_percentage,
                mc.quality_grade
              FROM MILK_COLLECTION mc
              JOIN FARMER f ON mc.farmer_id = f.farmer_id
              ORDER BY mc.collection_date DESC, mc.collection_time DESC
              LIMIT 10";
    $stmt = $db->query($query);
    $stats['recent_collections'] = $stmt->fetchAll(PDO::FETCH_ASSOC);

    // Top 5 Farmers This Month
    $query = "SELECT 
                f.farmer_id,
                CONCAT(f.first_name, ' ', f.last_name) as farmer_name,
                COUNT(*) as collection_days,
                SUM(mc.quantity_liters) as total_quantity,
                AVG(mc.fat_percentage) as avg_fat
              FROM MILK_COLLECTION mc
              JOIN FARMER f ON mc.farmer_id = f.farmer_id
              WHERE MONTH(mc.collection_date) = MONTH(CURDATE())
              AND YEAR(mc.collection_date) = YEAR(CURDATE())
              GROUP BY f.farmer_id
              ORDER BY total_quantity DESC
              LIMIT 5";
    $stmt = $db->query($query);
    $stats['top_farmers'] = $stmt->fetchAll(PDO::FETCH_ASSOC);

    // Stock Alerts
    $query = "SELECT 
                p.product_name,
                i.quantity as current_stock,
                i.reorder_level,
                w.warehouse_name
              FROM INVENTORY i
              JOIN PRODUCT p ON i.product_id = p.product_id
              JOIN WAREHOUSE w ON i.warehouse_id = w.warehouse_id
              WHERE i.quantity < i.reorder_level
              AND p.status = 'Active'
              ORDER BY (i.reorder_level - i.quantity) DESC
              LIMIT 5";
    $stmt = $db->query($query);
    $stats['stock_alerts'] = $stmt->fetchAll(PDO::FETCH_ASSOC);

    // Monthly Collection Trend (Last 6 months)
    $query = "SELECT 
                DATE_FORMAT(collection_date, '%Y-%m') as month,
                SUM(quantity_liters) as total_quantity,
                AVG(fat_percentage) as avg_fat
              FROM MILK_COLLECTION
              WHERE collection_date >= DATE_SUB(CURDATE(), INTERVAL 6 MONTH)
              GROUP BY DATE_FORMAT(collection_date, '%Y-%m')
              ORDER BY month";
    $stmt = $db->query($query);
    $stats['collection_trend'] = $stmt->fetchAll(PDO::FETCH_ASSOC);

    http_response_code(200);
    echo json_encode(array(
        "success" => true,
        "data" => $stats
    ));

} catch(PDOException $e) {
    http_response_code(500);
    echo json_encode(array(
        "success" => false,
        "message" => "Failed to fetch dashboard data: " . $e->getMessage()
    ));
}
?>
