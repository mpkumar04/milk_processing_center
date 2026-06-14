<?php
/**
 * Highland Milk Industries - Products API
 * 
 * Handles product-related operations
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
            getProductById($db, $_GET['id']);
        } elseif(isset($_GET['categories'])) {
            getCategories($db);
        } else {
            getAllProducts($db);
        }
        break;
    
    case 'POST':
        createProduct($db);
        break;
    
    case 'PUT':
        updateProduct($db);
        break;
    
    case 'DELETE':
        deleteProduct($db);
        break;
    
    default:
        http_response_code(405);
        echo json_encode(array("message" => "Method not allowed"));
        break;
}

/**
 * Get all products
 */
function getAllProducts($db) {
    $query = "SELECT 
                p.product_id, p.product_code, p.product_name, 
                p.description, p.unit, p.unit_price, p.shelf_life_days,
                p.status, pc.category_name
              FROM PRODUCT p
              JOIN PRODUCT_CATEGORY pc ON p.category_id = pc.category_id
              ORDER BY p.product_id DESC";
    
    try {
        $stmt = $db->prepare($query);
        $stmt->execute();
        
        $products = $stmt->fetchAll(PDO::FETCH_ASSOC);
        
        http_response_code(200);
        echo json_encode(array(
            "success" => true,
            "data" => $products
        ));
    } catch(PDOException $e) {
        http_response_code(500);
        echo json_encode(array(
            "success" => false,
            "message" => "Failed to fetch products: " . $e->getMessage()
        ));
    }
}

/**
 * Get product by ID
 */
function getProductById($db, $id) {
    $query = "SELECT 
                p.*, pc.category_name
              FROM PRODUCT p
              JOIN PRODUCT_CATEGORY pc ON p.category_id = pc.category_id
              WHERE p.product_id = :id";
    
    try {
        $stmt = $db->prepare($query);
        $stmt->bindParam(":id", $id);
        $stmt->execute();
        
        $product = $stmt->fetch(PDO::FETCH_ASSOC);
        
        if($product) {
            http_response_code(200);
            echo json_encode(array(
                "success" => true,
                "data" => $product
            ));
        } else {
            http_response_code(404);
            echo json_encode(array(
                "success" => false,
                "message" => "Product not found"
            ));
        }
    } catch(PDOException $e) {
        http_response_code(500);
        echo json_encode(array(
            "success" => false,
            "message" => "Failed to fetch product: " . $e->getMessage()
        ));
    }
}

/**
 * Create new product
 */
function createProduct($db) {
    $data = json_decode(file_get_contents("php://input"));
    
    if(!empty($data->product_code) && !empty($data->product_name)) {
        
        $query = "INSERT INTO PRODUCT 
                  (product_code, product_name, description, category_id, 
                   unit, unit_price, shelf_life_days, status)
                  VALUES 
                  (:product_code, :product_name, :description, :category_id,
                   :unit, :unit_price, :shelf_life_days, :status)";
        
        try {
            $stmt = $db->prepare($query);
            
            $stmt->bindParam(":product_code", $data->product_code);
            $stmt->bindParam(":product_name", $data->product_name);
            $stmt->bindParam(":description", $data->description);
            $stmt->bindParam(":category_id", $data->category_id);
            $stmt->bindParam(":unit", $data->unit);
            $stmt->bindParam(":unit_price", $data->unit_price);
            $stmt->bindParam(":shelf_life_days", $data->shelf_life_days);
            $status = $data->status ?? 'Active';
            $stmt->bindParam(":status", $status);
            
            if($stmt->execute()) {
                http_response_code(201);
                echo json_encode(array(
                    "success" => true,
                    "message" => "Product created successfully",
                    "product_id" => $db->lastInsertId()
                ));
            }
        } catch(PDOException $e) {
            http_response_code(500);
            echo json_encode(array(
                "success" => false,
                "message" => "Failed to create product: " . $e->getMessage()
            ));
        }
    } else {
        http_response_code(400);
        echo json_encode(array(
            "success" => false,
            "message" => "Incomplete data. Required fields: product_code, product_name"
        ));
    }
}

/**
 * Update product
 */
function updateProduct($db) {
    $data = json_decode(file_get_contents("php://input"));
    
    if(!empty($data->product_id)) {
        
        $query = "UPDATE PRODUCT SET
                  product_code = :product_code,
                  product_name = :product_name,
                  description = :description,
                  category_id = :category_id,
                  unit = :unit,
                  unit_price = :unit_price,
                  shelf_life_days = :shelf_life_days,
                  status = :status
                  WHERE product_id = :product_id";
        
        try {
            $stmt = $db->prepare($query);
            
            $stmt->bindParam(":product_id", $data->product_id);
            $stmt->bindParam(":product_code", $data->product_code);
            $stmt->bindParam(":product_name", $data->product_name);
            $stmt->bindParam(":description", $data->description);
            $stmt->bindParam(":category_id", $data->category_id);
            $stmt->bindParam(":unit", $data->unit);
            $stmt->bindParam(":unit_price", $data->unit_price);
            $stmt->bindParam(":shelf_life_days", $data->shelf_life_days);
            $stmt->bindParam(":status", $data->status);
            
            if($stmt->execute()) {
                http_response_code(200);
                echo json_encode(array(
                    "success" => true,
                    "message" => "Product updated successfully"
                ));
            }
        } catch(PDOException $e) {
            http_response_code(500);
            echo json_encode(array(
                "success" => false,
                "message" => "Failed to update product: " . $e->getMessage()
            ));
        }
    } else {
        http_response_code(400);
        echo json_encode(array(
            "success" => false,
            "message" => "Product ID is required"
        ));
    }
}

/**
 * Delete product
 */
function deleteProduct($db) {
    $data = json_decode(file_get_contents("php://input"));
    
    if(!empty($data->product_id)) {
        $query = "DELETE FROM PRODUCT WHERE product_id = :product_id";
        
        try {
            $stmt = $db->prepare($query);
            $stmt->bindParam(":product_id", $data->product_id);
            
            if($stmt->execute()) {
                http_response_code(200);
                echo json_encode(array(
                    "success" => true,
                    "message" => "Product deleted successfully"
                ));
            }
        } catch(PDOException $e) {
            http_response_code(500);
            echo json_encode(array(
                "success" => false,
                "message" => "Failed to delete product: " . $e->getMessage()
            ));
        }
    } else {
        http_response_code(400);
        echo json_encode(array(
            "success" => false,
            "message" => "Product ID is required"
        ));
    }
}

/**
 * Get all product categories (for dropdown)
 */
function getCategories($db) {
    $query = "SELECT category_id, category_name FROM PRODUCT_CATEGORY ORDER BY category_name";
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
