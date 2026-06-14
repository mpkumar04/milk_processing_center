-- =====================================================
-- Milk Processing Center - Table Creation Script
-- =====================================================

USE highland_milk_db;

-- =====================================================
-- PART 1: CORE OPERATIONAL TABLES
-- =====================================================

-- Table: PRODUCT_CATEGORY
CREATE TABLE PRODUCT_CATEGORY (
    category_id INT AUTO_INCREMENT PRIMARY KEY,
    category_name VARCHAR(100) NOT NULL UNIQUE,
    description TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_category_name (category_name)
) ENGINE=InnoDB;

-- Table: DEPARTMENT
CREATE TABLE DEPARTMENT (
    department_id INT AUTO_INCREMENT PRIMARY KEY,
    department_name VARCHAR(100) NOT NULL UNIQUE,
    description TEXT,
    head_of_department INT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_dept_name (department_name)
) ENGINE=InnoDB;

-- Table: EMPLOYEE
CREATE TABLE EMPLOYEE (
    employee_id INT AUTO_INCREMENT PRIMARY KEY,
    nic_number VARCHAR(12) NOT NULL UNIQUE,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    address VARCHAR(200) NOT NULL,
    contact_number VARCHAR(15) NOT NULL,
    email VARCHAR(100),
    department_id INT NOT NULL,
    designation VARCHAR(100) NOT NULL,
    salary DECIMAL(10,2) NOT NULL CHECK (salary > 0),
    date_of_joining DATE NOT NULL,
    status ENUM('Active', 'Inactive') NOT NULL DEFAULT 'Active',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (department_id) REFERENCES DEPARTMENT(department_id),
    INDEX idx_employee_dept (department_id),
    INDEX idx_employee_status (status),
    INDEX idx_employee_name (first_name, last_name)
) ENGINE=InnoDB;

-- Add foreign key to DEPARTMENT for head_of_department
ALTER TABLE DEPARTMENT
ADD CONSTRAINT fk_dept_head
FOREIGN KEY (head_of_department) REFERENCES EMPLOYEE(employee_id) ON DELETE SET NULL;

-- Table: FARMER
CREATE TABLE FARMER (
    farmer_id INT AUTO_INCREMENT PRIMARY KEY,
    nic_number VARCHAR(12) NOT NULL UNIQUE,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    address VARCHAR(200) NOT NULL,
    district VARCHAR(50) NOT NULL,
    village VARCHAR(100) NOT NULL,
    contact_number VARCHAR(15) NOT NULL,
    email VARCHAR(100),
    bank_name VARCHAR(100) NOT NULL,
    bank_account_no VARCHAR(20) NOT NULL,
    bank_branch VARCHAR(100) NOT NULL,
    registration_date DATE NOT NULL DEFAULT (CURRENT_DATE),
    status ENUM('Active', 'Inactive') NOT NULL DEFAULT 'Active',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_farmer_district (district),
    INDEX idx_farmer_status (status),
    INDEX idx_farmer_name (first_name, last_name)
) ENGINE=InnoDB;

-- Table: COLLECTION_CENTER
CREATE TABLE COLLECTION_CENTER (
    center_id INT AUTO_INCREMENT PRIMARY KEY,
    center_name VARCHAR(100) NOT NULL UNIQUE,
    location VARCHAR(200) NOT NULL,
    district VARCHAR(50) NOT NULL,
    contact_number VARCHAR(15) NOT NULL,
    manager_id INT,
    capacity_liters DECIMAL(10,2) NOT NULL CHECK (capacity_liters > 0),
    status ENUM('Active', 'Inactive') NOT NULL DEFAULT 'Active',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (manager_id) REFERENCES EMPLOYEE(employee_id) ON DELETE SET NULL,
    INDEX idx_center_district (district),
    INDEX idx_center_status (status)
) ENGINE=InnoDB;

-- Table: MILK_COLLECTION
CREATE TABLE MILK_COLLECTION (
    collection_id INT AUTO_INCREMENT PRIMARY KEY,
    farmer_id INT NOT NULL,
    collection_date DATE NOT NULL,
    collection_time TIME NOT NULL,
    quantity_liters DECIMAL(8,2) NOT NULL CHECK (quantity_liters > 0),
    fat_percentage DECIMAL(4,2) NOT NULL CHECK (fat_percentage BETWEEN 3.0 AND 8.0),
    snf_value DECIMAL(4,2) NOT NULL CHECK (snf_value BETWEEN 8.0 AND 10.0),
    temperature DECIMAL(4,2) NOT NULL,
    quality_grade ENUM('A', 'B', 'C') NOT NULL,
    collection_center_id INT NOT NULL,
    collected_by INT NOT NULL,
    remarks TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (farmer_id) REFERENCES FARMER(farmer_id),
    FOREIGN KEY (collection_center_id) REFERENCES COLLECTION_CENTER(center_id),
    FOREIGN KEY (collected_by) REFERENCES EMPLOYEE(employee_id),
    UNIQUE KEY unique_farmer_collection (farmer_id, collection_date, collection_time),
    INDEX idx_collection_date (collection_date),
    INDEX idx_farmer_collection (farmer_id, collection_date),
    INDEX idx_center_collection (collection_center_id, collection_date)
) ENGINE=InnoDB;

-- Table: PRODUCT
CREATE TABLE PRODUCT (
    product_id INT AUTO_INCREMENT PRIMARY KEY,
    product_code VARCHAR(20) NOT NULL UNIQUE,
    product_name VARCHAR(100) NOT NULL,
    description TEXT,
    category_id INT NOT NULL,
    unit VARCHAR(20) NOT NULL,
    unit_price DECIMAL(10,2) NOT NULL CHECK (unit_price > 0),
    shelf_life_days INT NOT NULL CHECK (shelf_life_days > 0),
    status ENUM('Active', 'Discontinued') NOT NULL DEFAULT 'Active',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (category_id) REFERENCES PRODUCT_CATEGORY(category_id),
    INDEX idx_product_category (category_id),
    INDEX idx_product_status (status),
    INDEX idx_product_name (product_name)
) ENGINE=InnoDB;

-- Table: WAREHOUSE
CREATE TABLE WAREHOUSE (
    warehouse_id INT AUTO_INCREMENT PRIMARY KEY,
    warehouse_name VARCHAR(100) NOT NULL UNIQUE,
    location VARCHAR(200) NOT NULL,
    district VARCHAR(50) NOT NULL,
    capacity DECIMAL(12,2) NOT NULL CHECK (capacity > 0),
    manager_id INT,
    contact_number VARCHAR(15) NOT NULL,
    status ENUM('Active', 'Inactive') NOT NULL DEFAULT 'Active',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (manager_id) REFERENCES EMPLOYEE(employee_id) ON DELETE SET NULL,
    INDEX idx_warehouse_district (district),
    INDEX idx_warehouse_status (status)
) ENGINE=InnoDB;

-- Table: INVENTORY
CREATE TABLE INVENTORY (
    inventory_id INT AUTO_INCREMENT PRIMARY KEY,
    product_id INT NOT NULL,
    warehouse_id INT NOT NULL,
    quantity DECIMAL(10,2) NOT NULL CHECK (quantity >= 0),
    batch_number VARCHAR(50) NOT NULL,
    manufacture_date DATE NOT NULL,
    expiry_date DATE NOT NULL,
    reorder_level DECIMAL(10,2) NOT NULL CHECK (reorder_level >= 0),
    last_updated TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (product_id) REFERENCES PRODUCT(product_id),
    FOREIGN KEY (warehouse_id) REFERENCES WAREHOUSE(warehouse_id),
    UNIQUE KEY unique_product_warehouse_batch (product_id, warehouse_id, batch_number),
    INDEX idx_inventory_product (product_id),
    INDEX idx_inventory_warehouse (warehouse_id),
    INDEX idx_expiry_date (expiry_date),
    INDEX idx_low_stock (product_id, quantity, reorder_level)
) ENGINE=InnoDB;

-- Table: SUPPLIER
CREATE TABLE SUPPLIER (
    supplier_id INT AUTO_INCREMENT PRIMARY KEY,
    supplier_name VARCHAR(100) NOT NULL,
    contact_person VARCHAR(100) NOT NULL,
    address VARCHAR(200) NOT NULL,
    contact_number VARCHAR(15) NOT NULL,
    email VARCHAR(100),
    supplier_type VARCHAR(50) NOT NULL,
    rating DECIMAL(2,1) CHECK (rating BETWEEN 1.0 AND 5.0),
    status ENUM('Active', 'Inactive') NOT NULL DEFAULT 'Active',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_supplier_type (supplier_type),
    INDEX idx_supplier_status (status),
    INDEX idx_supplier_name (supplier_name)
) ENGINE=InnoDB;

-- Table: CUSTOMER
CREATE TABLE CUSTOMER (
    customer_id INT AUTO_INCREMENT PRIMARY KEY,
    customer_name VARCHAR(100) NOT NULL,
    customer_type ENUM('Retail', 'Wholesale', 'Institutional') NOT NULL,
    address VARCHAR(200) NOT NULL,
    district VARCHAR(50) NOT NULL,
    contact_number VARCHAR(15) NOT NULL,
    email VARCHAR(100),
    credit_limit DECIMAL(10,2) DEFAULT 0 CHECK (credit_limit >= 0),
    registration_date DATE NOT NULL DEFAULT (CURRENT_DATE),
    status ENUM('Active', 'Inactive') NOT NULL DEFAULT 'Active',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_customer_type (customer_type),
    INDEX idx_customer_district (district),
    INDEX idx_customer_status (status),
    INDEX idx_customer_name (customer_name)
) ENGINE=InnoDB;

-- Table: CUSTOMER_ORDER
CREATE TABLE CUSTOMER_ORDER (
    order_id INT AUTO_INCREMENT PRIMARY KEY,
    customer_id INT NOT NULL,
    order_date DATE NOT NULL DEFAULT (CURRENT_DATE),
    required_date DATE NOT NULL,
    order_status ENUM('Pending', 'Confirmed', 'Delivered', 'Cancelled') NOT NULL DEFAULT 'Pending',
    subtotal DECIMAL(12,2) NOT NULL CHECK (subtotal >= 0),
    tax_amount DECIMAL(10,2) NOT NULL CHECK (tax_amount >= 0),
    total_amount DECIMAL(12,2) NOT NULL CHECK (total_amount >= 0),
    processed_by INT NOT NULL,
    remarks TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (customer_id) REFERENCES CUSTOMER(customer_id),
    FOREIGN KEY (processed_by) REFERENCES EMPLOYEE(employee_id),
    INDEX idx_order_date (order_date),
    INDEX idx_order_status (order_status),
    INDEX idx_customer_order (customer_id, order_date),
    INDEX idx_required_date (required_date)
) ENGINE=InnoDB;

-- Table: ORDER_LINE
CREATE TABLE ORDER_LINE (
    order_line_id INT AUTO_INCREMENT PRIMARY KEY,
    order_id INT NOT NULL,
    product_id INT NOT NULL,
    quantity DECIMAL(10,2) NOT NULL CHECK (quantity > 0),
    unit_price DECIMAL(10,2) NOT NULL CHECK (unit_price >= 0),
    line_total DECIMAL(12,2) NOT NULL CHECK (line_total >= 0),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (order_id) REFERENCES CUSTOMER_ORDER(order_id) ON DELETE CASCADE,
    FOREIGN KEY (product_id) REFERENCES PRODUCT(product_id),
    INDEX idx_order_line_order (order_id),
    INDEX idx_order_line_product (product_id)
) ENGINE=InnoDB;

-- Table: DELIVERY
CREATE TABLE DELIVERY (
    delivery_id INT AUTO_INCREMENT PRIMARY KEY,
    order_id INT NOT NULL UNIQUE,
    delivery_date DATE NOT NULL,
    vehicle_number VARCHAR(20) NOT NULL,
    driver_id INT NOT NULL,
    delivery_status ENUM('Scheduled', 'In Transit', 'Delivered', 'Failed') NOT NULL DEFAULT 'Scheduled',
    actual_delivery_date DATE,
    received_by VARCHAR(100),
    remarks TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (order_id) REFERENCES CUSTOMER_ORDER(order_id),
    FOREIGN KEY (driver_id) REFERENCES EMPLOYEE(employee_id),
    INDEX idx_delivery_date (delivery_date),
    INDEX idx_delivery_status (delivery_status),
    INDEX idx_driver (driver_id)
) ENGINE=InnoDB;

-- Table: PAYMENT
CREATE TABLE PAYMENT (
    payment_id INT AUTO_INCREMENT PRIMARY KEY,
    farmer_id INT NOT NULL,
    payment_date DATE NOT NULL,
    period_month INT NOT NULL CHECK (period_month BETWEEN 1 AND 12),
    period_year INT NOT NULL CHECK (period_year >= 2020),
    total_quantity DECIMAL(10,2) NOT NULL CHECK (total_quantity >= 0),
    base_amount DECIMAL(12,2) NOT NULL CHECK (base_amount >= 0),
    quality_premium DECIMAL(10,2) NOT NULL CHECK (quality_premium >= 0),
    total_amount DECIMAL(12,2) NOT NULL CHECK (total_amount >= 0),
    payment_method ENUM('Bank Transfer', 'Cheque', 'Cash') NOT NULL,
    payment_status ENUM('Pending', 'Processed', 'Completed') NOT NULL DEFAULT 'Pending',
    processed_by INT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (farmer_id) REFERENCES FARMER(farmer_id),
    FOREIGN KEY (processed_by) REFERENCES EMPLOYEE(employee_id),
    UNIQUE KEY unique_farmer_payment_period (farmer_id, period_month, period_year),
    INDEX idx_payment_date (payment_date),
    INDEX idx_payment_period (period_year, period_month),
    INDEX idx_payment_status (payment_status)
) ENGINE=InnoDB;

-- Table: DAILY_COLLECTION_SUMMARY (for trigger usage)
CREATE TABLE DAILY_COLLECTION_SUMMARY (
    summary_id INT AUTO_INCREMENT PRIMARY KEY,
    collection_date DATE NOT NULL UNIQUE,
    total_collections INT DEFAULT 0,
    total_quantity DECIMAL(12,2) DEFAULT 0,
    average_fat_percentage DECIMAL(5,2) DEFAULT 0,
    last_updated TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_summary_date (collection_date)
) ENGINE=InnoDB;

-- Display confirmation
SELECT 'All tables created successfully!' as Status;
