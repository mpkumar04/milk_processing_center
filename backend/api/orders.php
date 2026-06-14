<?php
/**
 * Highland Milk Industries - Orders API
 * 
 * Handles customer order operations
 */

header("Access-Control-Allow-Origin: *");
header("Content-Type: application/json; charset=UTF-8");
header("Access-Control-Allow-Methods: GET, POST, PUT, DELETE");
header("Access-Control-Allow-Headers: Content-Type, Access-Control-Allow-Headers, Authorization, X-Requested-With");

require_once '../config/database.php';

$database = new Database();
$db = $database->getConnection();

$method = $_SERVER['REQUEST_METHOD'];

switch($method) {
    case 'GET':
        if(isset($_GET['id'])) {
            getOrderById($db, $_GET['id']);
        } elseif(isset($_GET['customers'])) {
            getCustomers($db);
        } elseif(isset($_GET['employees'])) {
            getEmployees($db);
        } else {
            getAllOrders($db);
        }
        break;
    
    case 'POST':
        createOrder($db);
        break;
    
    case 'PUT':
        updateOrder($db);
        break;
    
    case 'DELETE':
        deleteOrder($db);
        break;
    
    default:
        http_response_code(405);
        echo json_encode(array("message" => "Method not allowed"));
        break;
}

/**
 * Get all orders
 */
function getAllOrders($db) {
    $query = "SELECT 
                co.order_id,
                co.customer_id,
                c.customer_name,
                c.customer_type,
                co.order_date,
                co.required_date,
                co.order_status,
                co.subtotal,
                co.tax_amount,
                co.total_amount,
                CONCAT(e.first_name, ' ', e.last_name) as processed_by_name,
                co.remarks
              FROM CUSTOMER_ORDER co
              JOIN CUSTOMER c ON co.customer_id = c.customer_id
              JOIN EMPLOYEE e ON co.processed_by = e.employee_id
              ORDER BY co.order_date DESC, co.order_id DESC
              LIMIT 100";
    
    try {
        $stmt = $db->prepare($query);
        $stmt->execute();
        
        $orders = $stmt->fetchAll(PDO::FETCH_ASSOC);
        
        http_response_code(200);
        echo json_encode(array(
            "success" => true,
            "data" => $orders
        ));
    } catch(PDOException $e) {
        http_response_code(500);
        echo json_encode(array(
            "success" => false,
            "message" => "Failed to fetch orders: " . $e->getMessage()
        ));
    }
}

/**
 * Get order by ID
 */
function getOrderById($db, $id) {
    $query = "SELECT 
                co.*,
                c.customer_name,
                c.customer_type,
                c.address as customer_address,
                c.contact_number as customer_contact,
                CONCAT(e.first_name, ' ', e.last_name) as processed_by_name
              FROM CUSTOMER_ORDER co
              JOIN CUSTOMER c ON co.customer_id = c.customer_id
              JOIN EMPLOYEE e ON co.processed_by = e.employee_id
              WHERE co.order_id = :id";
    
    try {
        $stmt = $db->prepare($query);
        $stmt->bindParam(":id", $id);
        $stmt->execute();
        
        $order = $stmt->fetch(PDO::FETCH_ASSOC);
        
        if($order) {
            // Get order lines
            $query_lines = "SELECT 
                              ol.*,
                              p.product_name,
                              p.product_code,
                              p.unit
                            FROM ORDER_LINE ol
                            JOIN PRODUCT p ON ol.product_id = p.product_id
                            WHERE ol.order_id = :id";
            
            $stmt_lines = $db->prepare($query_lines);
            $stmt_lines->bindParam(":id", $id);
            $stmt_lines->execute();
            
            $order['order_lines'] = $stmt_lines->fetchAll(PDO::FETCH_ASSOC);
            
            http_response_code(200);
            echo json_encode(array(
                "success" => true,
                "data" => $order
            ));
        } else {
            http_response_code(404);
            echo json_encode(array(
                "success" => false,
                "message" => "Order not found"
            ));
        }
    } catch(PDOException $e) {
        http_response_code(500);
        echo json_encode(array(
            "success" => false,
            "message" => "Failed to fetch order: " . $e->getMessage()
        ));
    }
}

/**
 * Create new order
 */
function createOrder($db) {
    $data = json_decode(file_get_contents("php://input"));
    
    if(!empty($data->customer_id) && !empty($data->order_lines)) {
        
        try {
            $db->beginTransaction();
            
            // Insert order
            $query = "INSERT INTO CUSTOMER_ORDER 
                      (customer_id, order_date, required_date, order_status,
                       subtotal, tax_amount, total_amount, processed_by, remarks)
                      VALUES 
                      (:customer_id, :order_date, :required_date, :order_status,
                       :subtotal, :tax_amount, :total_amount, :processed_by, :remarks)";
            
            $stmt = $db->prepare($query);
            
            $stmt->bindParam(":customer_id", $data->customer_id);
            $stmt->bindParam(":order_date", $data->order_date);
            $stmt->bindParam(":required_date", $data->required_date);
            $order_status = $data->order_status ?? 'Pending';
            $stmt->bindParam(":order_status", $order_status);
            $stmt->bindParam(":subtotal", $data->subtotal);
            $stmt->bindParam(":tax_amount", $data->tax_amount);
            $stmt->bindParam(":total_amount", $data->total_amount);
            $stmt->bindParam(":processed_by", $data->processed_by);
            $remarks = $data->remarks ?? null;
            $stmt->bindParam(":remarks", $remarks);
            
            $stmt->execute();
            $order_id = $db->lastInsertId();
            
            // Insert order lines
            $query_line = "INSERT INTO ORDER_LINE 
                           (order_id, product_id, quantity, unit_price, line_total)
                           VALUES 
                           (:order_id, :product_id, :quantity, :unit_price, :line_total)";
            
            $stmt_line = $db->prepare($query_line);
            
            foreach($data->order_lines as $line) {
                $stmt_line->bindParam(":order_id", $order_id);
                $stmt_line->bindParam(":product_id", $line->product_id);
                $stmt_line->bindParam(":quantity", $line->quantity);
                $stmt_line->bindParam(":unit_price", $line->unit_price);
                $stmt_line->bindParam(":line_total", $line->line_total);
                $stmt_line->execute();
            }
            
            $db->commit();
            
            http_response_code(201);
            echo json_encode(array(
                "success" => true,
                "message" => "Order created successfully",
                "order_id" => $order_id
            ));
            
        } catch(PDOException $e) {
            $db->rollBack();
            http_response_code(500);
            echo json_encode(array(
                "success" => false,
                "message" => "Failed to create order: " . $e->getMessage()
            ));
        }
    } else {
        http_response_code(400);
        echo json_encode(array(
            "success" => false,
            "message" => "Incomplete data. Required fields: customer_id, order_lines"
        ));
    }
}

/**
 * Update order
 */
function updateOrder($db) {
    $data = json_decode(file_get_contents("php://input"));
    
    if(!empty($data->order_id)) {
        
        $query = "UPDATE CUSTOMER_ORDER SET
                  order_status = :order_status,
                  remarks = :remarks
                  WHERE order_id = :order_id";
        
        try {
            $stmt = $db->prepare($query);
            
            $stmt->bindParam(":order_id", $data->order_id);
            $stmt->bindParam(":order_status", $data->order_status);
            $stmt->bindParam(":remarks", $data->remarks);
            
            if($stmt->execute()) {
                http_response_code(200);
                echo json_encode(array(
                    "success" => true,
                    "message" => "Order updated successfully"
                ));
            }
        } catch(PDOException $e) {
            http_response_code(500);
            echo json_encode(array(
                "success" => false,
                "message" => "Failed to update order: " . $e->getMessage()
            ));
        }
    } else {
        http_response_code(400);
        echo json_encode(array(
            "success" => false,
            "message" => "Order ID is required"
        ));
    }
}

/**
 * Delete order
 */
function deleteOrder($db) {
    $data = json_decode(file_get_contents("php://input"));
    
    if(!empty($data->order_id)) {
        $query = "DELETE FROM CUSTOMER_ORDER WHERE order_id = :order_id";
        
        try {
            $stmt = $db->prepare($query);
            $stmt->bindParam(":order_id", $data->order_id);
            
            if($stmt->execute()) {
                http_response_code(200);
                echo json_encode(array(
                    "success" => true,
                    "message" => "Order deleted successfully"
                ));
            }
        } catch(PDOException $e) {
            http_response_code(500);
            echo json_encode(array(
                "success" => false,
                "message" => "Failed to delete order: " . $e->getMessage()
            ));
        }
    } else {
        http_response_code(400);
        echo json_encode(array(
            "success" => false,
            "message" => "Order ID is required"
        ));
    }
}

/**
 * Get active customers (for dropdown)
 */
function getCustomers($db) {
    $query = "SELECT customer_id, customer_name, customer_type FROM CUSTOMER WHERE status = 'Active' ORDER BY customer_name";
    try {
        $stmt = $db->prepare($query);
        $stmt->execute();
        echo json_encode(array("success" => true, "data" => $stmt->fetchAll(PDO::FETCH_ASSOC)));
    } catch(PDOException $e) {
        http_response_code(500);
        echo json_encode(array("success" => false, "message" => $e->getMessage()));
    }
}

/**
 * Get active employees (for processed_by dropdown)
 */
function getEmployees($db) {
    $query = "SELECT employee_id, first_name, last_name FROM EMPLOYEE WHERE status = 'Active' ORDER BY first_name, last_name";
    try {
        $stmt = $db->prepare($query);
        $stmt->execute();
        echo json_encode(array("success" => true, "data" => $stmt->fetchAll(PDO::FETCH_ASSOC)));
    } catch(PDOException $e) {
        http_response_code(500);
        echo json_encode(array("success" => false, "message" => $e->getMessage()));
    }
}
?>
