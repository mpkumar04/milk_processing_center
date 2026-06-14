<?php
/**
 * Highland Milk Industries - Farmers API
 * 
 * Handles farmer-related operations
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
            getFarmerById($db, $_GET['id']);
        } else {
            getAllFarmers($db);
        }
        break;
    
    case 'POST':
        createFarmer($db);
        break;
    
    case 'PUT':
        updateFarmer($db);
        break;
    
    case 'DELETE':
        deleteFarmer($db);
        break;
    
    default:
        http_response_code(405);
        echo json_encode(array("message" => "Method not allowed"));
        break;
}

/**
 * Get all farmers
 */
function getAllFarmers($db) {
    $query = "SELECT 
                farmer_id, nic_number, first_name, last_name, 
                address, district, village, contact_number, email,
                bank_name, bank_account_no, bank_branch, 
                registration_date, status
              FROM FARMER 
              ORDER BY farmer_id DESC";
    
    try {
        $stmt = $db->prepare($query);
        $stmt->execute();
        
        $farmers = $stmt->fetchAll(PDO::FETCH_ASSOC);
        
        http_response_code(200);
        echo json_encode(array(
            "success" => true,
            "data" => $farmers
        ));
    } catch(PDOException $e) {
        http_response_code(500);
        echo json_encode(array(
            "success" => false,
            "message" => "Failed to fetch farmers: " . $e->getMessage()
        ));
    }
}

/**
 * Get farmer by ID
 */
function getFarmerById($db, $id) {
    $query = "SELECT 
                farmer_id, nic_number, first_name, last_name, 
                address, district, village, contact_number, email,
                bank_name, bank_account_no, bank_branch, 
                registration_date, status
              FROM FARMER 
              WHERE farmer_id = :id";
    
    try {
        $stmt = $db->prepare($query);
        $stmt->bindParam(":id", $id);
        $stmt->execute();
        
        $farmer = $stmt->fetch(PDO::FETCH_ASSOC);
        
        if($farmer) {
            http_response_code(200);
            echo json_encode(array(
                "success" => true,
                "data" => $farmer
            ));
        } else {
            http_response_code(404);
            echo json_encode(array(
                "success" => false,
                "message" => "Farmer not found"
            ));
        }
    } catch(PDOException $e) {
        http_response_code(500);
        echo json_encode(array(
            "success" => false,
            "message" => "Failed to fetch farmer: " . $e->getMessage()
        ));
    }
}

/**
 * Create new farmer
 */
function createFarmer($db) {
    $data = json_decode(file_get_contents("php://input"));
    
    if(!empty($data->nic_number) && !empty($data->first_name) && !empty($data->last_name)) {
        
        $query = "INSERT INTO FARMER 
                  (nic_number, first_name, last_name, address, district, village, 
                   contact_number, email, bank_name, bank_account_no, bank_branch, status)
                  VALUES 
                  (:nic_number, :first_name, :last_name, :address, :district, :village,
                   :contact_number, :email, :bank_name, :bank_account_no, :bank_branch, :status)";
        
        try {
            $stmt = $db->prepare($query);
            
            $stmt->bindParam(":nic_number", $data->nic_number);
            $stmt->bindParam(":first_name", $data->first_name);
            $stmt->bindParam(":last_name", $data->last_name);
            $stmt->bindParam(":address", $data->address);
            $stmt->bindParam(":district", $data->district);
            $stmt->bindParam(":village", $data->village);
            $stmt->bindParam(":contact_number", $data->contact_number);
            $stmt->bindParam(":email", $data->email);
            $stmt->bindParam(":bank_name", $data->bank_name);
            $stmt->bindParam(":bank_account_no", $data->bank_account_no);
            $stmt->bindParam(":bank_branch", $data->bank_branch);
            $status = $data->status ?? 'Active';
            $stmt->bindParam(":status", $status);
            
            if($stmt->execute()) {
                http_response_code(201);
                echo json_encode(array(
                    "success" => true,
                    "message" => "Farmer created successfully",
                    "farmer_id" => $db->lastInsertId()
                ));
            }
        } catch(PDOException $e) {
            http_response_code(500);
            echo json_encode(array(
                "success" => false,
                "message" => "Failed to create farmer: " . $e->getMessage()
            ));
        }
    } else {
        http_response_code(400);
        echo json_encode(array(
            "success" => false,
            "message" => "Incomplete data. Required fields: nic_number, first_name, last_name"
        ));
    }
}

/**
 * Update farmer
 */
function updateFarmer($db) {
    $data = json_decode(file_get_contents("php://input"));
    
    if(!empty($data->farmer_id)) {
        
        $query = "UPDATE FARMER SET
                  nic_number = :nic_number,
                  first_name = :first_name,
                  last_name = :last_name,
                  address = :address,
                  district = :district,
                  village = :village,
                  contact_number = :contact_number,
                  email = :email,
                  bank_name = :bank_name,
                  bank_account_no = :bank_account_no,
                  bank_branch = :bank_branch,
                  status = :status
                  WHERE farmer_id = :farmer_id";
        
        try {
            $stmt = $db->prepare($query);
            
            $stmt->bindParam(":farmer_id", $data->farmer_id);
            $stmt->bindParam(":nic_number", $data->nic_number);
            $stmt->bindParam(":first_name", $data->first_name);
            $stmt->bindParam(":last_name", $data->last_name);
            $stmt->bindParam(":address", $data->address);
            $stmt->bindParam(":district", $data->district);
            $stmt->bindParam(":village", $data->village);
            $stmt->bindParam(":contact_number", $data->contact_number);
            $stmt->bindParam(":email", $data->email);
            $stmt->bindParam(":bank_name", $data->bank_name);
            $stmt->bindParam(":bank_account_no", $data->bank_account_no);
            $stmt->bindParam(":bank_branch", $data->bank_branch);
            $stmt->bindParam(":status", $data->status);
            
            if($stmt->execute()) {
                http_response_code(200);
                echo json_encode(array(
                    "success" => true,
                    "message" => "Farmer updated successfully"
                ));
            }
        } catch(PDOException $e) {
            http_response_code(500);
            echo json_encode(array(
                "success" => false,
                "message" => "Failed to update farmer: " . $e->getMessage()
            ));
        }
    } else {
        http_response_code(400);
        echo json_encode(array(
            "success" => false,
            "message" => "Farmer ID is required"
        ));
    }
}

/**
 * Delete farmer
 */
function deleteFarmer($db) {
    $data = json_decode(file_get_contents("php://input"));
    
    if(!empty($data->farmer_id)) {
        $query = "DELETE FROM FARMER WHERE farmer_id = :farmer_id";
        
        try {
            $stmt = $db->prepare($query);
            $stmt->bindParam(":farmer_id", $data->farmer_id);
            
            if($stmt->execute()) {
                http_response_code(200);
                echo json_encode(array(
                    "success" => true,
                    "message" => "Farmer deleted successfully"
                ));
            }
        } catch(PDOException $e) {
            http_response_code(500);
            echo json_encode(array(
                "success" => false,
                "message" => "Failed to delete farmer: " . $e->getMessage()
            ));
        }
    } else {
        http_response_code(400);
        echo json_encode(array(
            "success" => false,
            "message" => "Farmer ID is required"
        ));
    }
}
?>
