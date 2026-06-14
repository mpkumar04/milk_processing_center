<?php
/**
 * Highland Milk Industries - Milk Collections API
 * 
 * Handles milk collection operations
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
            getCollectionById($db, $_GET['id']);
        } elseif(isset($_GET['centers'])) {
            getCollectionCenters($db);
        } elseif(isset($_GET['employees'])) {
            getEmployees($db);
        } else {
            getAllCollections($db);
        }
        break;
    
    case 'POST':
        createCollection($db);
        break;
    
    case 'PUT':
        updateCollection($db);
        break;
    
    case 'DELETE':
        deleteCollection($db);
        break;
    
    default:
        http_response_code(405);
        echo json_encode(array("message" => "Method not allowed"));
        break;
}

/**
 * Get all collections
 */
function getAllCollections($db) {
    $query = "SELECT 
                mc.collection_id,
                mc.farmer_id,
                CONCAT(f.first_name, ' ', f.last_name) as farmer_name,
                mc.collection_date,
                mc.collection_time,
                mc.quantity_liters,
                mc.fat_percentage,
                mc.snf_value,
                mc.temperature,
                mc.quality_grade,
                mc.collection_center_id,
                cc.center_name,
                mc.collected_by,
                CONCAT(e.first_name, ' ', e.last_name) as collector_name,
                mc.remarks
              FROM MILK_COLLECTION mc
              JOIN FARMER f ON mc.farmer_id = f.farmer_id
              JOIN COLLECTION_CENTER cc ON mc.collection_center_id = cc.center_id
              JOIN EMPLOYEE e ON mc.collected_by = e.employee_id
              ORDER BY mc.collection_date DESC, mc.collection_time DESC
              LIMIT 100";
    
    try {
        $stmt = $db->prepare($query);
        $stmt->execute();
        
        $collections = $stmt->fetchAll(PDO::FETCH_ASSOC);
        
        http_response_code(200);
        echo json_encode(array(
            "success" => true,
            "data" => $collections
        ));
    } catch(PDOException $e) {
        http_response_code(500);
        echo json_encode(array(
            "success" => false,
            "message" => "Failed to fetch collections: " . $e->getMessage()
        ));
    }
}

/**
 * Get collection by ID
 */
function getCollectionById($db, $id) {
    $query = "SELECT 
                mc.*,
                CONCAT(f.first_name, ' ', f.last_name) as farmer_name,
                cc.center_name,
                CONCAT(e.first_name, ' ', e.last_name) as collector_name
              FROM MILK_COLLECTION mc
              JOIN FARMER f ON mc.farmer_id = f.farmer_id
              JOIN COLLECTION_CENTER cc ON mc.collection_center_id = cc.center_id
              JOIN EMPLOYEE e ON mc.collected_by = e.employee_id
              WHERE mc.collection_id = :id";
    
    try {
        $stmt = $db->prepare($query);
        $stmt->bindParam(":id", $id);
        $stmt->execute();
        
        $collection = $stmt->fetch(PDO::FETCH_ASSOC);
        
        if($collection) {
            http_response_code(200);
            echo json_encode(array(
                "success" => true,
                "data" => $collection
            ));
        } else {
            http_response_code(404);
            echo json_encode(array(
                "success" => false,
                "message" => "Collection not found"
            ));
        }
    } catch(PDOException $e) {
        http_response_code(500);
        echo json_encode(array(
            "success" => false,
            "message" => "Failed to fetch collection: " . $e->getMessage()
        ));
    }
}

/**
 * Create new collection
 */
function createCollection($db) {
    $data = json_decode(file_get_contents("php://input"));
    
    if(!empty($data->farmer_id) && !empty($data->quantity_liters) && !empty($data->fat_percentage)) {
        
        $query = "INSERT INTO MILK_COLLECTION 
                  (farmer_id, collection_date, collection_time, quantity_liters, 
                   fat_percentage, snf_value, temperature, quality_grade,
                   collection_center_id, collected_by, remarks)
                  VALUES 
                  (:farmer_id, :collection_date, :collection_time, :quantity_liters,
                   :fat_percentage, :snf_value, :temperature, :quality_grade,
                   :collection_center_id, :collected_by, :remarks)";
        
        try {
            $stmt = $db->prepare($query);
            
            $stmt->bindParam(":farmer_id", $data->farmer_id);
            $stmt->bindParam(":collection_date", $data->collection_date);
            $stmt->bindParam(":collection_time", $data->collection_time);
            $stmt->bindParam(":quantity_liters", $data->quantity_liters);
            $stmt->bindParam(":fat_percentage", $data->fat_percentage);
            $stmt->bindParam(":snf_value", $data->snf_value);
            $stmt->bindParam(":temperature", $data->temperature);
            $quality_grade = $data->quality_grade ?? 'B';
            $stmt->bindParam(":quality_grade", $quality_grade);
            $stmt->bindParam(":collection_center_id", $data->collection_center_id);
            $stmt->bindParam(":collected_by", $data->collected_by);
            $remarks = $data->remarks ?? null;
            $stmt->bindParam(":remarks", $remarks);
            
            if($stmt->execute()) {
                http_response_code(201);
                echo json_encode(array(
                    "success" => true,
                    "message" => "Collection recorded successfully",
                    "collection_id" => $db->lastInsertId()
                ));
            }
        } catch(PDOException $e) {
            http_response_code(500);
            echo json_encode(array(
                "success" => false,
                "message" => "Failed to record collection: " . $e->getMessage()
            ));
        }
    } else {
        http_response_code(400);
        echo json_encode(array(
            "success" => false,
            "message" => "Incomplete data. Required fields: farmer_id, quantity_liters, fat_percentage"
        ));
    }
}

/**
 * Update collection
 */
function updateCollection($db) {
    $data = json_decode(file_get_contents("php://input"));
    
    if(!empty($data->collection_id)) {
        
        $query = "UPDATE MILK_COLLECTION SET
                  farmer_id = :farmer_id,
                  collection_date = :collection_date,
                  collection_time = :collection_time,
                  quantity_liters = :quantity_liters,
                  fat_percentage = :fat_percentage,
                  snf_value = :snf_value,
                  temperature = :temperature,
                  quality_grade = :quality_grade,
                  collection_center_id = :collection_center_id,
                  collected_by = :collected_by,
                  remarks = :remarks
                  WHERE collection_id = :collection_id";
        
        try {
            $stmt = $db->prepare($query);
            
            $stmt->bindParam(":collection_id", $data->collection_id);
            $stmt->bindParam(":farmer_id", $data->farmer_id);
            $stmt->bindParam(":collection_date", $data->collection_date);
            $stmt->bindParam(":collection_time", $data->collection_time);
            $stmt->bindParam(":quantity_liters", $data->quantity_liters);
            $stmt->bindParam(":fat_percentage", $data->fat_percentage);
            $stmt->bindParam(":snf_value", $data->snf_value);
            $stmt->bindParam(":temperature", $data->temperature);
            $stmt->bindParam(":quality_grade", $data->quality_grade);
            $stmt->bindParam(":collection_center_id", $data->collection_center_id);
            $stmt->bindParam(":collected_by", $data->collected_by);
            $stmt->bindParam(":remarks", $data->remarks);
            
            if($stmt->execute()) {
                http_response_code(200);
                echo json_encode(array(
                    "success" => true,
                    "message" => "Collection updated successfully"
                ));
            }
        } catch(PDOException $e) {
            http_response_code(500);
            echo json_encode(array(
                "success" => false,
                "message" => "Failed to update collection: " . $e->getMessage()
            ));
        }
    } else {
        http_response_code(400);
        echo json_encode(array(
            "success" => false,
            "message" => "Collection ID is required"
        ));
    }
}

/**
 * Delete collection
 */
function deleteCollection($db) {
    $data = json_decode(file_get_contents("php://input"));
    
    if(!empty($data->collection_id)) {
        $query = "DELETE FROM MILK_COLLECTION WHERE collection_id = :collection_id";
        
        try {
            $stmt = $db->prepare($query);
            $stmt->bindParam(":collection_id", $data->collection_id);
            
            if($stmt->execute()) {
                http_response_code(200);
                echo json_encode(array(
                    "success" => true,
                    "message" => "Collection deleted successfully"
                ));
            }
        } catch(PDOException $e) {
            http_response_code(500);
            echo json_encode(array(
                "success" => false,
                "message" => "Failed to delete collection: " . $e->getMessage()
            ));
        }
    } else {
        http_response_code(400);
        echo json_encode(array(
            "success" => false,
            "message" => "Collection ID is required"
        ));
    }
}

/**
 * Get all active collection centers (for dropdown)
 */
function getCollectionCenters($db) {
    $query = "SELECT center_id, center_name FROM COLLECTION_CENTER WHERE status = 'Active' ORDER BY center_name";
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
 * Get all active employees (for collected_by dropdown)
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
