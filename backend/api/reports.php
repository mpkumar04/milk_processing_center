<?php
/**
 * Milk Processing Center - Reports API
 */

header("Access-Control-Allow-Origin: *");
header("Content-Type: application/json; charset=UTF-8");
header("Access-Control-Allow-Methods: GET");
header("Access-Control-Allow-Headers: Content-Type, Access-Control-Allow-Headers, Authorization, X-Requested-With");

require_once '../config/database.php';

$database = new Database();
$db = $database->getConnection();

if (!$db) {
    http_response_code(500);
    echo json_encode(["success" => false, "message" => "Database connection failed"]);
    exit;
}

$method = $_SERVER['REQUEST_METHOD'];

if ($method !== 'GET') {
    http_response_code(405);
    echo json_encode(["success" => false, "message" => "Method not allowed"]);
    exit;
}

$reportType = isset($_GET['type']) ? trim($_GET['type']) : '';
$startDate  = isset($_GET['start_date']) ? trim($_GET['start_date']) : date('Y-m-01');
$endDate    = isset($_GET['end_date'])   ? trim($_GET['end_date'])   : date('Y-m-d');

// Basic date validation
if (!$reportType) {
    http_response_code(400);
    echo json_encode(["success" => false, "message" => "Report type is required"]);
    exit;
}

switch ($reportType) {
    case 'farmer_performance':
        getFarmerPerformanceReport($db, $startDate, $endDate);
        break;
    case 'collection_summary':
        getCollectionSummaryReport($db, $startDate, $endDate);
        break;
    case 'product_sales':
        getProductSalesReport($db, $startDate, $endDate);
        break;
    case 'revenue_report':
        getRevenueReport($db, $startDate, $endDate);
        break;
    default:
        http_response_code(400);
        echo json_encode(["success" => false, "message" => "Invalid report type: $reportType"]);
}

/* ============================================================
   Farmer Performance Report
   ============================================================ */
function getFarmerPerformanceReport($db, $startDate, $endDate) {
    $query = "SELECT
                f.farmer_id,
                CONCAT(f.first_name, ' ', f.last_name) AS farmer_name,
                f.village,
                f.district,
                COUNT(mc.collection_id)                                          AS total_collections,
                COALESCE(SUM(mc.quantity_liters), 0)                            AS total_quantity,
                COALESCE(AVG(mc.quantity_liters), 0)                            AS avg_quantity_per_collection,
                COALESCE(AVG(mc.fat_percentage), 0)                             AS avg_fat_percentage,
                SUM(CASE WHEN mc.quality_grade = 'A' THEN 1 ELSE 0 END)         AS grade_a_count,
                SUM(CASE WHEN mc.quality_grade = 'B' THEN 1 ELSE 0 END)         AS grade_b_count,
                SUM(CASE WHEN mc.quality_grade = 'C' THEN 1 ELSE 0 END)         AS grade_c_count
              FROM FARMER f
              INNER JOIN MILK_COLLECTION mc
                ON f.farmer_id = mc.farmer_id
                AND mc.collection_date BETWEEN :start_date AND :end_date
              WHERE f.status = 'Active'
              GROUP BY f.farmer_id, f.first_name, f.last_name, f.village, f.district
              ORDER BY total_quantity DESC";

    try {
        $stmt = $db->prepare($query);
        $stmt->bindParam(":start_date", $startDate);
        $stmt->bindParam(":end_date",   $endDate);
        $stmt->execute();
        $data = $stmt->fetchAll(PDO::FETCH_ASSOC);

        echo json_encode([
            "success"     => true,
            "report_type" => "farmer_performance",
            "period"      => ["start" => $startDate, "end" => $endDate],
            "data"        => $data
        ]);
    } catch (PDOException $e) {
        http_response_code(500);
        echo json_encode(["success" => false, "message" => "Query failed: " . $e->getMessage()]);
    }
}

/* ============================================================
   Collection Summary Report
   ============================================================ */
function getCollectionSummaryReport($db, $startDate, $endDate) {
    $query = "SELECT
                DATE(mc.collection_date)                                          AS collection_date,
                COUNT(mc.collection_id)                                           AS total_collections,
                COUNT(DISTINCT mc.farmer_id)                                      AS unique_farmers,
                SUM(mc.quantity_liters)                                           AS total_quantity,
                AVG(mc.quantity_liters)                                           AS avg_quantity,
                AVG(mc.fat_percentage)                                            AS avg_fat_percentage,
                MIN(mc.fat_percentage)                                            AS min_fat,
                MAX(mc.fat_percentage)                                            AS max_fat,
                SUM(CASE WHEN mc.quality_grade = 'A' THEN 1 ELSE 0 END)          AS grade_a,
                SUM(CASE WHEN mc.quality_grade = 'B' THEN 1 ELSE 0 END)          AS grade_b,
                SUM(CASE WHEN mc.quality_grade = 'C' THEN 1 ELSE 0 END)          AS grade_c
              FROM MILK_COLLECTION mc
              WHERE mc.collection_date BETWEEN :start_date AND :end_date
              GROUP BY DATE(mc.collection_date)
              ORDER BY collection_date DESC";

    try {
        $stmt = $db->prepare($query);
        $stmt->bindParam(":start_date", $startDate);
        $stmt->bindParam(":end_date",   $endDate);
        $stmt->execute();
        $data = $stmt->fetchAll(PDO::FETCH_ASSOC);

        echo json_encode([
            "success"     => true,
            "report_type" => "collection_summary",
            "period"      => ["start" => $startDate, "end" => $endDate],
            "data"        => $data
        ]);
    } catch (PDOException $e) {
        http_response_code(500);
        echo json_encode(["success" => false, "message" => "Query failed: " . $e->getMessage()]);
    }
}

/* ============================================================
   Product Sales Report
   ============================================================ */
function getProductSalesReport($db, $startDate, $endDate) {
    // Use INNER JOIN via subquery to avoid HAVING on aliased aggregate
    $query = "SELECT
                p.product_id,
                p.product_code,
                p.product_name,
                pc.category_name,
                COUNT(DISTINCT ol.order_id)  AS total_orders,
                SUM(ol.quantity)             AS total_quantity_sold,
                SUM(ol.line_total)           AS total_revenue,
                AVG(ol.unit_price)           AS avg_selling_price
              FROM ORDER_LINE ol
              INNER JOIN CUSTOMER_ORDER co
                ON ol.order_id = co.order_id
                AND co.order_date BETWEEN :start_date AND :end_date
                AND co.order_status IN ('Confirmed', 'Delivered')
              INNER JOIN PRODUCT p
                ON ol.product_id = p.product_id
              LEFT JOIN PRODUCT_CATEGORY pc
                ON p.category_id = pc.category_id
              GROUP BY p.product_id, p.product_code, p.product_name, pc.category_name
              ORDER BY total_revenue DESC";

    try {
        $stmt = $db->prepare($query);
        $stmt->bindParam(":start_date", $startDate);
        $stmt->bindParam(":end_date",   $endDate);
        $stmt->execute();
        $data = $stmt->fetchAll(PDO::FETCH_ASSOC);

        echo json_encode([
            "success"     => true,
            "report_type" => "product_sales",
            "period"      => ["start" => $startDate, "end" => $endDate],
            "data"        => $data
        ]);
    } catch (PDOException $e) {
        http_response_code(500);
        echo json_encode(["success" => false, "message" => "Query failed: " . $e->getMessage()]);
    }
}

/* ============================================================
   Revenue Report
   ============================================================ */
function getRevenueReport($db, $startDate, $endDate) {
    $query = "SELECT
                DATE(co.order_date)                                                          AS order_date,
                COUNT(co.order_id)                                                           AS total_orders,
                COUNT(DISTINCT co.customer_id)                                               AS unique_customers,
                SUM(CASE WHEN co.order_status = 'Pending'   THEN 1 ELSE 0 END)              AS pending_orders,
                SUM(CASE WHEN co.order_status = 'Confirmed' THEN 1 ELSE 0 END)              AS confirmed_orders,
                SUM(CASE WHEN co.order_status = 'Delivered' THEN 1 ELSE 0 END)              AS delivered_orders,
                SUM(CASE WHEN co.order_status = 'Cancelled' THEN 1 ELSE 0 END)              AS cancelled_orders,
                SUM(co.subtotal)                                                             AS total_subtotal,
                SUM(co.tax_amount)                                                           AS total_tax,
                SUM(CASE WHEN co.order_status IN ('Confirmed','Delivered')
                    THEN co.total_amount ELSE 0 END)                                         AS total_revenue
              FROM CUSTOMER_ORDER co
              WHERE co.order_date BETWEEN :start_date AND :end_date
              GROUP BY DATE(co.order_date)
              ORDER BY order_date DESC";

    try {
        $stmt = $db->prepare($query);
        $stmt->bindParam(":start_date", $startDate);
        $stmt->bindParam(":end_date",   $endDate);
        $stmt->execute();
        $data = $stmt->fetchAll(PDO::FETCH_ASSOC);

        $totals = ["total_orders" => 0, "total_revenue" => 0.0, "total_tax" => 0.0];
        foreach ($data as $row) {
            $totals['total_orders']  += (int)$row['total_orders'];
            $totals['total_revenue'] += (float)$row['total_revenue'];
            $totals['total_tax']     += (float)$row['total_tax'];
        }

        echo json_encode([
            "success"     => true,
            "report_type" => "revenue_report",
            "period"      => ["start" => $startDate, "end" => $endDate],
            "totals"      => $totals,
            "data"        => $data
        ]);
    } catch (PDOException $e) {
        http_response_code(500);
        echo json_encode(["success" => false, "message" => "Query failed: " . $e->getMessage()]);
    }
}
?>
