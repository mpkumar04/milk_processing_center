-- =====================================================
-- Milk Processing Center - Sample Data Insertion
-- =====================================================

USE highland_milk_db;

-- =====================================================
-- Insert Department Data
-- =====================================================
INSERT INTO DEPARTMENT (department_name, description) VALUES
('Production', 'Dairy production and processing department'),
('Quality Control', 'Quality assurance and testing'),
('Sales and Marketing', 'Sales, marketing, and customer relations'),
('Logistics', 'Transportation and delivery operations'),
('Finance', 'Accounting and financial management'),
('Human Resources', 'Employee management and recruitment'),
('IT', 'Information technology and systems'),
('Collection Operations', 'Milk collection from farmers');

-- =====================================================
-- Insert Employee Data
-- =====================================================
INSERT INTO EMPLOYEE (nic_number, first_name, last_name, address, contact_number, email, department_id, designation, salary, date_of_joining, status) VALUES
('197512345678', 'Nimal', 'Perera', '123 Galle Road, Colombo 03', '0771234567', 'nimal.perera@mpc.lk', 1, 'Production Manager', 85000.00, '2015-03-15', 'Active'),
('198234567890', 'Kamala', 'Silva', '45 Kandy Road, Peradeniya', '0772345678', 'kamala.silva@mpc.lk', 2, 'QC Officer', 55000.00, '2018-07-01', 'Active'),
('199045678901', 'Sunil', 'Fernando', '78 Main Street, Gampaha', '0773456789', 'sunil.fernando@mpc.lk', 3, 'Sales Manager', 75000.00, '2016-01-10', 'Active'),
('198556789012', 'Madhavi', 'Wickramasinghe', '23 Station Road, Kandy', '0774567890', 'madhavi.w@mpc.lk', 4, 'Logistics Coordinator', 60000.00, '2017-05-20', 'Active'),
('199267890123', 'Anil', 'Jayawardena', '56 Hospital Road, Negombo', '0775678901', 'anil.j@mpc.lk', 5, 'Accountant', 65000.00, '2019-02-14', 'Active'),
('198878901234', 'Dilini', 'Rajapakse', '89 Temple Road, Matara', '0776789012', 'dilini.r@mpc.lk', 8, 'Collection Officer', 45000.00, '2020-06-01', 'Active'),
('199189012345', 'Rohan', 'De Silva', '34 Beach Road, Galle', '0777890123', 'rohan.d@mpc.lk', 4, 'Driver', 40000.00, '2020-09-15', 'Active'),
('198990123456', 'Sanduni', 'Gunasekara', '67 Hill Street, Nuwara Eliya', '0778901234', 'sanduni.g@mpc.lk', 8, 'Collection Officer', 45000.00, '2021-01-05', 'Active'),
('199301234567', 'Kasun', 'Perera', '12 Lake Road, Kandy', '0779012345', 'kasun.p@mpc.lk', 4, 'Driver', 40000.00, '2021-03-10', 'Active'),
('198912345678', 'Priyanka', 'Fernando', '45 Colombo Road, Gampaha', '0770123456', 'priyanka.f@mpc.lk', 3, 'Sales Officer', 50000.00, '2019-08-20', 'Active');

-- Update department heads
UPDATE DEPARTMENT SET head_of_department = 1 WHERE department_name = 'Production';
UPDATE DEPARTMENT SET head_of_department = 2 WHERE department_name = 'Quality Control';
UPDATE DEPARTMENT SET head_of_department = 3 WHERE department_name = 'Sales and Marketing';
UPDATE DEPARTMENT SET head_of_department = 4 WHERE department_name = 'Logistics';
UPDATE DEPARTMENT SET head_of_department = 5 WHERE department_name = 'Finance';

-- =====================================================
-- Insert Collection Center Data
-- =====================================================
INSERT INTO COLLECTION_CENTER (center_name, location, district, contact_number, manager_id, capacity_liters, status) VALUES
('Kandy Central Collection Point', 'Peradeniya Road, Kandy', 'Kandy', '0812234567', 1, 5000.00, 'Active'),
('Nuwara Eliya Highland Center', 'Main Street, Nuwara Eliya', 'Nuwara Eliya', '0522234567', 2, 4000.00, 'Active'),
('Gampaha Collection Hub', 'Station Road, Gampaha', 'Gampaha', '0332234567', 6, 3500.00, 'Active'),
('Matara Coastal Center', 'Beach Road, Matara', 'Matara', '0412234567', 8, 3000.00, 'Active');

-- =====================================================
-- Insert Farmer Data
-- =====================================================
INSERT INTO FARMER (nic_number, first_name, last_name, address, district, village, contact_number, email, bank_name, bank_account_no, bank_branch, status) VALUES
('196523456789', 'Bandula', 'Rathnayake', 'Udawela, Kandy', 'Kandy', 'Udawela', '0711234567', NULL, 'Bank of Ceylon', '1234567890', 'Kandy', 'Active'),
('197034567890', 'Sumana', 'Gunawardena', 'Ambagamuwa, Nuwara Eliya', 'Nuwara Eliya', 'Ambagamuwa', '0721234567', NULL, 'People\'s Bank', '2345678901', 'Nuwara Eliya', 'Active'),
('196845678901', 'Lalith', 'Wijesinghe', 'Hanguranketha, Kandy', 'Kandy', 'Hanguranketha', '0731234567', NULL, 'Commercial Bank', '3456789012', 'Kandy', 'Active'),
('197256789012', 'Prema', 'Jayasundara', 'Kotmale, Nuwara Eliya', 'Nuwara Eliya', 'Kotmale', '0741234567', NULL, 'Sampath Bank', '4567890123', 'Nuwara Eliya', 'Active'),
('196767890123', 'Mahinda', 'Karunaratne', 'Pussellawa, Kandy', 'Kandy', 'Pussellawa', '0751234567', NULL, 'Bank of Ceylon', '5678901234', 'Kandy', 'Active'),
('197178901234', 'Chandrika', 'Senanayake', 'Lindula, Nuwara Eliya', 'Nuwara Eliya', 'Lindula', '0761234567', NULL, 'Hatton National Bank', '6789012345', 'Nuwara Eliya', 'Active'),
('196989012345', 'Kamal', 'Dissanayake', 'Divulapitiya, Gampaha', 'Gampaha', 'Divulapitiya', '0771234568', NULL, 'People\'s Bank', '7890123456', 'Gampaha', 'Active'),
('197290123456', 'Niluka', 'Ranasinghe', 'Minuwangoda, Gampaha', 'Gampaha', 'Minuwangoda', '0781234567', NULL, 'Commercial Bank', '8901234567', 'Gampaha', 'Active'),
('196801234567', 'Gamini', 'Hewage', 'Akuressa, Matara', 'Matara', 'Akuressa', '0791234567', NULL, 'Bank of Ceylon', '9012345678', 'Matara', 'Active'),
('197112345678', 'Malini', 'Samaraweera', 'Hakmana, Matara', 'Matara', 'Hakmana', '0701234567', NULL, 'Sampath Bank', '0123456789', 'Matara', 'Active'),
('196612345679', 'Sunil', 'Kumara', 'Gampola, Kandy', 'Kandy', 'Gampola', '0712345670', NULL, 'Bank of Ceylon', '1234567891', 'Kandy', 'Active'),
('197123456780', 'Anula', 'Perera', 'Hatton, Nuwara Eliya', 'Nuwara Eliya', 'Hatton', '0722345671', NULL, 'People\'s Bank', '2345678902', 'Nuwara Eliya', 'Active'),
('196734567881', 'Piyal', 'Silva', 'Nawalapitiya, Kandy', 'Kandy', 'Nawalapitiya', '0732345672', NULL, 'Commercial Bank', '3456789013', 'Kandy', 'Active'),
('197245678982', 'Nandana', 'Fernando', 'Nanu Oya, Nuwara Eliya', 'Nuwara Eliya', 'Nanu Oya', '0742345673', NULL, 'Sampath Bank', '4567890124', 'Nuwara Eliya', 'Active'),
('196856789083', 'Wasantha', 'De Silva', 'Mirigama, Gampaha', 'Gampaha', 'Mirigama', '0752345674', NULL, 'Bank of Ceylon', '5678901235', 'Gampaha', 'Active');

-- =====================================================
-- Insert Milk Collection Data (Last 30 days)
-- =====================================================
INSERT INTO MILK_COLLECTION (farmer_id, collection_date, collection_time, quantity_liters, fat_percentage, snf_value, temperature, quality_grade, collection_center_id, collected_by) VALUES
-- Recent collections (last 7 days)
(1, DATE_SUB(CURDATE(), INTERVAL 0 DAY), '06:00:00', 25.50, 5.2, 8.9, 4.5, 'A', 1, 6),
(2, DATE_SUB(CURDATE(), INTERVAL 0 DAY), '06:30:00', 30.00, 6.1, 9.2, 4.0, 'A', 2, 8),
(3, DATE_SUB(CURDATE(), INTERVAL 0 DAY), '07:00:00', 20.00, 4.8, 8.7, 4.8, 'B', 1, 6),
(4, DATE_SUB(CURDATE(), INTERVAL 0 DAY), '07:30:00', 28.00, 5.5, 9.0, 4.3, 'A', 2, 8),
(5, DATE_SUB(CURDATE(), INTERVAL 0 DAY), '06:15:00', 22.00, 5.0, 8.8, 4.6, 'A', 1, 6),
(6, DATE_SUB(CURDATE(), INTERVAL 0 DAY), '06:45:00', 24.00, 5.8, 9.0, 4.2, 'A', 2, 8),
(7, DATE_SUB(CURDATE(), INTERVAL 0 DAY), '08:00:00', 18.50, 4.2, 8.5, 5.0, 'B', 3, 6),
(8, DATE_SUB(CURDATE(), INTERVAL 0 DAY), '08:30:00', 19.00, 4.5, 8.6, 4.9, 'B', 3, 6),
(9, DATE_SUB(CURDATE(), INTERVAL 0 DAY), '09:00:00', 23.00, 5.1, 8.9, 4.5, 'A', 4, 8),
(10, DATE_SUB(CURDATE(), INTERVAL 0 DAY), '09:30:00', 21.50, 5.3, 9.0, 4.4, 'A', 4, 8),
(1, DATE_SUB(CURDATE(), INTERVAL 1 DAY), '06:00:00', 26.00, 5.3, 9.0, 4.2, 'A', 1, 6),
(2, DATE_SUB(CURDATE(), INTERVAL 1 DAY), '06:30:00', 29.50, 6.0, 9.1, 4.1, 'A', 2, 8),
(3, DATE_SUB(CURDATE(), INTERVAL 1 DAY), '07:00:00', 21.00, 4.9, 8.8, 4.6, 'B', 1, 6),
(4, DATE_SUB(CURDATE(), INTERVAL 1 DAY), '07:30:00', 27.50, 5.6, 9.1, 4.4, 'A', 2, 8),
(5, DATE_SUB(CURDATE(), INTERVAL 1 DAY), '06:15:00', 22.50, 5.1, 8.9, 4.5, 'A', 1, 6),
(11, DATE_SUB(CURDATE(), INTERVAL 1 DAY), '06:45:00', 20.00, 4.7, 8.7, 4.7, 'B', 1, 6),
(12, DATE_SUB(CURDATE(), INTERVAL 1 DAY), '07:15:00', 26.50, 5.9, 9.1, 4.3, 'A', 2, 8),
(13, DATE_SUB(CURDATE(), INTERVAL 1 DAY), '06:30:00', 19.50, 4.6, 8.6, 4.8, 'B', 1, 6),
(14, DATE_SUB(CURDATE(), INTERVAL 1 DAY), '07:00:00', 25.00, 5.7, 9.0, 4.2, 'A', 2, 8),
(15, DATE_SUB(CURDATE(), INTERVAL 1 DAY), '08:00:00', 17.50, 4.3, 8.5, 4.9, 'B', 3, 6);

-- =====================================================
-- Insert Product Category Data
-- =====================================================
INSERT INTO PRODUCT_CATEGORY (category_name, description) VALUES
('Fresh Milk', 'Pasteurized and sterilized milk products'),
('Flavored Milk', 'Flavored milk beverages'),
('Yogurt', 'Yogurt and curd products'),
('Ice Cream', 'Ice cream products'),
('Milk Powder', 'Powdered milk products'),
('Dairy Spreads', 'Butter, ghee, and cheese products');

-- =====================================================
-- Insert Product Data
-- =====================================================
INSERT INTO PRODUCT (product_code, product_name, description, category_id, unit, unit_price, shelf_life_days, status) VALUES
('FM001', 'Full Cream Fresh Milk 1L', 'Full cream pasteurized milk', 1, 'Liter', 280.00, 5, 'Active'),
('FM002', 'Low Fat Fresh Milk 1L', 'Low fat pasteurized milk', 1, 'Liter', 260.00, 5, 'Active'),
('FM003', 'Skimmed Milk 1L', 'Fat-free pasteurized milk', 1, 'Liter', 240.00, 5, 'Active'),
('FLV001', 'Chocolate Milk 200ml', 'Chocolate flavored milk', 2, 'Piece', 120.00, 7, 'Active'),
('FLV002', 'Strawberry Milk 200ml', 'Strawberry flavored milk', 2, 'Piece', 120.00, 7, 'Active'),
('YG001', 'Natural Yogurt 400g', 'Plain natural yogurt', 3, 'Piece', 180.00, 14, 'Active'),
('YG002', 'Fruit Yogurt 400g', 'Mixed fruit yogurt', 3, 'Piece', 200.00, 14, 'Active'),
('IC001', 'Vanilla Ice Cream 1L', 'Premium vanilla ice cream', 4, 'Piece', 650.00, 180, 'Active'),
('IC002', 'Chocolate Ice Cream 1L', 'Premium chocolate ice cream', 4, 'Piece', 680.00, 180, 'Active'),
('MP001', 'Full Cream Milk Powder 400g', 'Full cream milk powder', 5, 'Piece', 850.00, 365, 'Active'),
('DS001', 'Butter 250g', 'Premium dairy butter', 6, 'Piece', 450.00, 60, 'Active'),
('DS002', 'Cheese Slices 200g', 'Cheddar cheese slices', 6, 'Piece', 520.00, 45, 'Active');

-- =====================================================
-- Insert Warehouse Data
-- =====================================================
INSERT INTO WAREHOUSE (warehouse_name, location, district, capacity, manager_id, contact_number, status) VALUES
('Main Warehouse Colombo', 'Industrial Zone, Colombo 10', 'Colombo', 50000.00, 1, '0112345678', 'Active'),
('Regional Warehouse Kandy', 'Peradeniya Industrial Area', 'Kandy', 30000.00, 2, '0812345678', 'Active'),
('Coastal Warehouse Galle', 'Galle Port Area', 'Galle', 25000.00, 4, '0912345678', 'Active');

-- =====================================================
-- Insert Inventory Data
-- =====================================================
INSERT INTO INVENTORY (product_id, warehouse_id, quantity, batch_number, manufacture_date, expiry_date, reorder_level) VALUES
(1, 1, 500.00, 'B2026060001', CURDATE(), DATE_ADD(CURDATE(), INTERVAL 5 DAY), 100.00),
(1, 2, 300.00, 'B2026060002', CURDATE(), DATE_ADD(CURDATE(), INTERVAL 5 DAY), 80.00),
(2, 1, 400.00, 'B2026060003', CURDATE(), DATE_ADD(CURDATE(), INTERVAL 5 DAY), 100.00),
(3, 1, 350.00, 'B2026060004', CURDATE(), DATE_ADD(CURDATE(), INTERVAL 5 DAY), 100.00),
(4, 1, 800.00, 'B2026060005', CURDATE(), DATE_ADD(CURDATE(), INTERVAL 7 DAY), 200.00),
(5, 1, 750.00, 'B2026060006', CURDATE(), DATE_ADD(CURDATE(), INTERVAL 7 DAY), 200.00),
(6, 1, 600.00, 'B2026060007', DATE_SUB(CURDATE(), INTERVAL 5 DAY), DATE_ADD(CURDATE(), INTERVAL 9 DAY), 150.00),
(7, 2, 550.00, 'B2026060008', DATE_SUB(CURDATE(), INTERVAL 5 DAY), DATE_ADD(CURDATE(), INTERVAL 9 DAY), 150.00),
(8, 1, 200.00, 'B2026060009', DATE_SUB(CURDATE(), INTERVAL 150 DAY), DATE_ADD(CURDATE(), INTERVAL 30 DAY), 50.00),
(9, 1, 180.00, 'B2026060010', DATE_SUB(CURDATE(), INTERVAL 150 DAY), DATE_ADD(CURDATE(), INTERVAL 30 DAY), 50.00),
(10, 1, 450.00, 'B2026060011', DATE_SUB(CURDATE(), INTERVAL 30 DAY), DATE_ADD(CURDATE(), INTERVAL 335 DAY), 100.00),
(11, 1, 380.00, 'B2026060012', DATE_SUB(CURDATE(), INTERVAL 10 DAY), DATE_ADD(CURDATE(), INTERVAL 50 DAY), 80.00),
(12, 1, 420.00, 'B2026060013', DATE_SUB(CURDATE(), INTERVAL 8 DAY), DATE_ADD(CURDATE(), INTERVAL 37 DAY), 90.00);

-- =====================================================
-- Insert Supplier Data
-- =====================================================
INSERT INTO SUPPLIER (supplier_name, contact_person, address, contact_number, email, supplier_type, rating, status) VALUES
('Lanka Packaging Solutions', 'Ajith Perera', 'Colombo 10', '0112567890', 'info@lankapack.lk', 'Packaging', 4.5, 'Active'),
('Ceylon Cold Storage Equipment', 'Nimal Silva', 'Colombo 15', '0112678901', 'sales@ceyloncold.lk', 'Equipment', 4.8, 'Active'),
('Island Dairy Supplies', 'Kumara Fernando', 'Kandy', '0812789012', 'info@islanddairy.lk', 'Raw Material', 4.2, 'Active');

-- =====================================================
-- Insert Customer Data
-- =====================================================
INSERT INTO CUSTOMER (customer_name, customer_type, address, district, contact_number, email, credit_limit, status) VALUES
('Cargills Food City - Kandy', 'Wholesale', 'Dalada Veediya, Kandy', 'Kandy', '0812223344', 'kandy@cargills.lk', 500000.00, 'Active'),
('Keells Super - Colombo 03', 'Wholesale', 'Galle Road, Colombo 03', 'Colombo', '0112223344', 'colombo03@keells.lk', 750000.00, 'Active'),
('Arpico Supercentre - Gampaha', 'Wholesale', 'Main Street, Gampaha', 'Gampaha', '0332223344', 'gampaha@arpico.lk', 400000.00, 'Active'),
('Sunshine Hotel - Kandy', 'Institutional', 'Temple Street, Kandy', 'Kandy', '0812334455', 'purchase@sunshinehotel.lk', 200000.00, 'Active'),
('Green Valley Restaurant', 'Retail', 'Lake Road, Nuwara Eliya', 'Nuwara Eliya', '0522334455', 'greenvalley@email.lk', 50000.00, 'Active'),
('Royal Hospital - Colombo', 'Institutional', 'Ward Place, Colombo 07', 'Colombo', '0112334455', 'procurement@royalhospital.lk', 300000.00, 'Active');

-- =====================================================
-- Insert Customer Order Data
-- =====================================================
INSERT INTO CUSTOMER_ORDER (customer_id, order_date, required_date, order_status, subtotal, tax_amount, total_amount, processed_by) VALUES
(1, DATE_SUB(CURDATE(), INTERVAL 2 DAY), DATE_SUB(CURDATE(), INTERVAL 1 DAY), 'Delivered', 45000.00, 3600.00, 48600.00, 3),
(2, DATE_SUB(CURDATE(), INTERVAL 1 DAY), CURDATE(), 'Confirmed', 62000.00, 4960.00, 66960.00, 3),
(3, CURDATE(), DATE_ADD(CURDATE(), INTERVAL 1 DAY), 'Pending', 28000.00, 2240.00, 30240.00, 10),
(4, CURDATE(), DATE_ADD(CURDATE(), INTERVAL 2 DAY), 'Pending', 18500.00, 1480.00, 19980.00, 10);

-- =====================================================
-- Insert Order Line Data
-- =====================================================
INSERT INTO ORDER_LINE (order_id, product_id, quantity, unit_price, line_total) VALUES
-- Order 1 (Delivered)
(1, 1, 100, 280.00, 28000.00),
(1, 2, 50, 260.00, 13000.00),
(1, 6, 20, 180.00, 3600.00),
-- Order 2 (Confirmed)
(2, 1, 150, 280.00, 42000.00),
(2, 4, 100, 120.00, 12000.00),
(2, 7, 40, 200.00, 8000.00),
-- Order 3 (Pending)
(3, 3, 80, 240.00, 19200.00),
(3, 5, 60, 120.00, 7200.00),
(3, 6, 10, 180.00, 1800.00),
-- Order 4 (Pending)
(4, 1, 50, 280.00, 14000.00),
(4, 6, 25, 180.00, 4500.00);

-- =====================================================
-- Insert Delivery Data
-- =====================================================
INSERT INTO DELIVERY (order_id, delivery_date, vehicle_number, driver_id, delivery_status, actual_delivery_date, received_by) VALUES
(1, DATE_SUB(CURDATE(), INTERVAL 1 DAY), 'WP CAB-1234', 7, 'Delivered', DATE_SUB(CURDATE(), INTERVAL 1 DAY), 'Mr. Perera'),
(2, CURDATE(), 'WP CAB-5678', 9, 'Scheduled', NULL, NULL);

-- Display confirmation
SELECT 'Sample data inserted successfully!' as Status;
SELECT 'Database setup complete and ready for use!' as FinalStatus;
