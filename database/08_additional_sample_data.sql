-- =====================================================
-- Milk Processing Center - Additional Sample Data
-- Run this AFTER 07_insert_sample_data.sql
-- Uses dynamic employee ID lookup to avoid FK errors
-- =====================================================

USE highland_milk_db;

-- =====================================================
-- Store collector and processor employee IDs safely
-- =====================================================
SET @collector1 = (SELECT employee_id FROM EMPLOYEE WHERE designation = 'Collection Officer' LIMIT 1);
SET @collector2 = (SELECT employee_id FROM EMPLOYEE WHERE designation = 'Collection Officer' LIMIT 1 OFFSET 1);
SET @sales1    = (SELECT employee_id FROM EMPLOYEE WHERE designation IN ('Sales Manager','Sales Officer') LIMIT 1);
SET @sales2    = (SELECT employee_id FROM EMPLOYEE WHERE designation IN ('Sales Manager','Sales Officer') LIMIT 1 OFFSET 1);

-- Fallback: if only 1 collector, use same for both
SET @collector1 = IFNULL(@collector1, (SELECT MIN(employee_id) FROM EMPLOYEE));
SET @collector2 = IFNULL(@collector2, @collector1);
SET @sales1    = IFNULL(@sales1,    (SELECT MIN(employee_id) FROM EMPLOYEE));
SET @sales2    = IFNULL(@sales2,    @sales1);

SELECT CONCAT('Using collector IDs: ', @collector1, ' and ', @collector2,
              ' | Sales IDs: ', @sales1, ' and ', @sales2) AS Config;

-- =====================================================
-- Additional Farmers (10 more, total ~25)
-- =====================================================
INSERT IGNORE INTO FARMER (nic_number, first_name, last_name, address, district, village, contact_number, email, bank_name, bank_account_no, bank_branch, status) VALUES
('197345678001', 'Ranjith',    'Wijeratne',    'Galagedara, Kandy',        'Kandy',       'Galagedara',   '0713456781', 'ranjith.w@email.lk', 'Bank of Ceylon',      '1111222233', 'Kandy',       'Active'),
('196745678002', 'Padmini',    'Abeysekara',   'Balangoda, Ratnapura',     'Ratnapura',   'Balangoda',    '0723456782', NULL,                 'Peoples Bank',        '2222333344', 'Ratnapura',   'Active'),
('197845678003', 'Chaminda',   'Rajapaksha',   'Kelaniya, Gampaha',        'Gampaha',     'Kelaniya',     '0733456783', NULL,                 'Commercial Bank',     '3333444455', 'Gampaha',     'Active'),
('196545678004', 'Sriyani',    'Kariyawasam',  'Embilipitiya, Ratnapura',  'Ratnapura',   'Embilipitiya', '0743456784', NULL,                 'Sampath Bank',        '4444555566', 'Ratnapura',   'Active'),
('197645678005', 'Asanka',     'Bandara',      'Wattegama, Kandy',         'Kandy',       'Wattegama',    '0753456785', NULL,                 'Hatton National Bank','5555666677', 'Kandy',       'Active'),
('196945678006', 'Kumari',     'Dissanayake',  'Matale, Matale',           'Matale',      'Matale',       '0763456786', 'kumari.d@email.lk',  'Bank of Ceylon',      '6666777788', 'Matale',      'Active'),
('197545678007', 'Thilak',     'Pathirana',    'Kurunegala, Kurunegala',   'Kurunegala',  'Kurunegala',   '0773456787', NULL,                 'Peoples Bank',        '7777888899', 'Kurunegala',  'Active'),
('196645678008', 'Nirosha',    'Siriwardena',  'Kuliyapitiya, Kurunegala', 'Kurunegala',  'Kuliyapitiya', '0783456788', NULL,                 'Commercial Bank',     '8888999900', 'Kurunegala',  'Active'),
('197745678009', 'Pradeep',    'Liyanage',     'Aluthgama, Kalutara',      'Kalutara',    'Aluthgama',    '0793456789', NULL,                 'Sampath Bank',        '9999000011', 'Kalutara',    'Active'),
('196845678010', 'Damayanthi', 'Jayawardena',  'Panadura, Kalutara',       'Kalutara',    'Panadura',     '0703456780', NULL,                 'Bank of Ceylon',      '0000111122', 'Kalutara',    'Inactive');

-- =====================================================
-- Additional Customers (5 more)
-- =====================================================
INSERT IGNORE INTO CUSTOMER (customer_name, customer_type, address, district, contact_number, email, credit_limit, status) VALUES
('Lanka Sathosa - Matara',    'Wholesale',     'Main Street, Matara',      'Matara',       '0412445566', 'matara@sathosa.lk',        350000.00, 'Active'),
('Nuwara Eliya Grand Hotel',  'Institutional', 'Grand Hotel Road, NE',     'Nuwara Eliya', '0522445566', 'purchase@grandhotel.lk',   150000.00, 'Active'),
('City Supermart - Gampaha',  'Retail',        'Station Road, Gampaha',    'Gampaha',      '0332445566', 'city@supermart.lk',         80000.00, 'Active'),
('Kandy City Hotel',          'Institutional', 'Dalada Veediya, Kandy',    'Kandy',        '0812445566', 'kitchen@kandycityhotel.lk',120000.00, 'Active'),
('Fresh Mart - Colombo 07',   'Retail',        'Jawatta Road, Colombo 07', 'Colombo',      '0112445566', 'freshmart@email.lk',         60000.00, 'Active');

-- =====================================================
-- Additional Products (10 more)
-- =====================================================
INSERT IGNORE INTO PRODUCT (product_code, product_name, description, category_id, unit, unit_price, shelf_life_days, status) VALUES
('FM004', 'UHT Full Cream Milk 1L',   'Ultra-high temperature processed milk',  1, 'Liter',  320.00, 90,  'Active'),
('FM005', 'Toned Milk 500ml',          'Toned pasteurized milk',                 1, 'Liter',  150.00, 5,   'Active'),
('FLV003','Mango Milk 200ml',          'Mango flavored milk drink',              2, 'Piece',  130.00, 7,   'Active'),
('FLV004','Vanilla Milk 200ml',        'Vanilla flavored milk drink',            2, 'Piece',  125.00, 7,   'Active'),
('YG003', 'Greek Yogurt 250g',         'Thick creamy Greek-style yogurt',        3, 'Piece',  250.00, 21,  'Active'),
('YG004', 'Drinking Yogurt 200ml',     'Drinkable probiotic yogurt',             3, 'Piece',  160.00, 14,  'Active'),
('IC003', 'Strawberry Ice Cream 1L',   'Premium strawberry ice cream',           4, 'Piece',  650.00, 180, 'Active'),
('MP002', 'Skimmed Milk Powder 400g',  'Low-fat skimmed milk powder',            5, 'Piece',  780.00, 365, 'Active'),
('DS003', 'Ghee 200g',                 'Pure clarified butter',                  6, 'Piece',  680.00, 180, 'Active'),
('DS004', 'Cream Cheese 150g',         'Soft spreadable cream cheese',           6, 'Piece',  580.00, 30,  'Discontinued');

-- =====================================================
-- Milk Collections (30 days) using dynamic employee IDs
-- =====================================================

-- Day 2
INSERT IGNORE INTO MILK_COLLECTION (farmer_id, collection_date, collection_time, quantity_liters, fat_percentage, snf_value, temperature, quality_grade, collection_center_id, collected_by) VALUES
(6,  DATE_SUB(CURDATE(), INTERVAL 2 DAY), '06:00:00', 24.50, 5.7, 9.0, 4.2, 'A', 2, @collector2),
(7,  DATE_SUB(CURDATE(), INTERVAL 2 DAY), '07:00:00', 18.00, 4.3, 8.5, 5.1, 'B', 3, @collector1),
(8,  DATE_SUB(CURDATE(), INTERVAL 2 DAY), '07:30:00', 20.50, 4.6, 8.7, 4.8, 'B', 3, @collector1),
(9,  DATE_SUB(CURDATE(), INTERVAL 2 DAY), '08:00:00', 22.00, 5.0, 8.8, 4.5, 'A', 4, @collector2),
(10, DATE_SUB(CURDATE(), INTERVAL 2 DAY), '08:30:00', 21.00, 5.2, 8.9, 4.4, 'A', 4, @collector2),
(11, DATE_SUB(CURDATE(), INTERVAL 2 DAY), '06:30:00', 19.50, 4.8, 8.7, 4.7, 'B', 1, @collector1),
(12, DATE_SUB(CURDATE(), INTERVAL 2 DAY), '07:00:00', 27.00, 6.0, 9.2, 4.1, 'A', 2, @collector2),
(13, DATE_SUB(CURDATE(), INTERVAL 2 DAY), '06:45:00', 18.00, 4.5, 8.6, 4.9, 'B', 1, @collector1),
(14, DATE_SUB(CURDATE(), INTERVAL 2 DAY), '07:15:00', 26.00, 5.8, 9.1, 4.2, 'A', 2, @collector2),
(15, DATE_SUB(CURDATE(), INTERVAL 2 DAY), '08:15:00', 16.50, 4.2, 8.4, 5.0, 'C', 3, @collector1);

-- Day 3
INSERT IGNORE INTO MILK_COLLECTION (farmer_id, collection_date, collection_time, quantity_liters, fat_percentage, snf_value, temperature, quality_grade, collection_center_id, collected_by) VALUES
(1,  DATE_SUB(CURDATE(), INTERVAL 3 DAY), '06:00:00', 27.00, 5.4, 9.1, 4.1, 'A', 1, @collector1),
(2,  DATE_SUB(CURDATE(), INTERVAL 3 DAY), '06:30:00', 31.00, 6.2, 9.3, 3.9, 'A', 2, @collector2),
(3,  DATE_SUB(CURDATE(), INTERVAL 3 DAY), '07:00:00', 19.50, 4.7, 8.6, 4.7, 'B', 1, @collector1),
(4,  DATE_SUB(CURDATE(), INTERVAL 3 DAY), '07:30:00', 29.00, 5.7, 9.1, 4.3, 'A', 2, @collector2),
(5,  DATE_SUB(CURDATE(), INTERVAL 3 DAY), '06:15:00', 23.00, 5.2, 8.9, 4.5, 'A', 1, @collector1),
(6,  DATE_SUB(CURDATE(), INTERVAL 3 DAY), '06:45:00', 25.00, 5.9, 9.1, 4.1, 'A', 2, @collector2),
(7,  DATE_SUB(CURDATE(), INTERVAL 3 DAY), '08:00:00', 17.50, 4.1, 8.4, 5.2, 'C', 3, @collector1),
(8,  DATE_SUB(CURDATE(), INTERVAL 3 DAY), '08:30:00', 19.00, 4.4, 8.6, 4.9, 'B', 3, @collector1),
(9,  DATE_SUB(CURDATE(), INTERVAL 3 DAY), '09:00:00', 24.00, 5.2, 9.0, 4.4, 'A', 4, @collector2),
(10, DATE_SUB(CURDATE(), INTERVAL 3 DAY), '09:30:00', 22.00, 5.4, 9.1, 4.3, 'A', 4, @collector2);

-- Day 4
INSERT IGNORE INTO MILK_COLLECTION (farmer_id, collection_date, collection_time, quantity_liters, fat_percentage, snf_value, temperature, quality_grade, collection_center_id, collected_by) VALUES
(11, DATE_SUB(CURDATE(), INTERVAL 4 DAY), '06:45:00', 21.00, 4.9, 8.8, 4.6, 'B', 1, @collector1),
(12, DATE_SUB(CURDATE(), INTERVAL 4 DAY), '07:15:00', 28.00, 6.1, 9.2, 4.0, 'A', 2, @collector2),
(13, DATE_SUB(CURDATE(), INTERVAL 4 DAY), '06:30:00', 20.00, 4.7, 8.7, 4.8, 'B', 1, @collector1),
(14, DATE_SUB(CURDATE(), INTERVAL 4 DAY), '07:00:00', 26.50, 5.8, 9.1, 4.2, 'A', 2, @collector2),
(15, DATE_SUB(CURDATE(), INTERVAL 4 DAY), '08:00:00', 18.00, 4.3, 8.5, 5.0, 'B', 3, @collector1),
(1,  DATE_SUB(CURDATE(), INTERVAL 4 DAY), '06:00:00', 25.00, 5.1, 8.9, 4.4, 'A', 1, @collector1),
(2,  DATE_SUB(CURDATE(), INTERVAL 4 DAY), '06:30:00', 30.50, 6.0, 9.2, 4.0, 'A', 2, @collector2),
(3,  DATE_SUB(CURDATE(), INTERVAL 4 DAY), '07:00:00', 20.50, 4.8, 8.7, 4.7, 'B', 1, @collector1),
(4,  DATE_SUB(CURDATE(), INTERVAL 4 DAY), '07:30:00', 28.50, 5.6, 9.0, 4.3, 'A', 2, @collector2),
(5,  DATE_SUB(CURDATE(), INTERVAL 4 DAY), '06:15:00', 22.00, 5.0, 8.8, 4.6, 'A', 1, @collector1);

-- Day 5
INSERT IGNORE INTO MILK_COLLECTION (farmer_id, collection_date, collection_time, quantity_liters, fat_percentage, snf_value, temperature, quality_grade, collection_center_id, collected_by) VALUES
(6,  DATE_SUB(CURDATE(), INTERVAL 5 DAY), '06:45:00', 23.50, 5.7, 9.0, 4.2, 'A', 2, @collector2),
(7,  DATE_SUB(CURDATE(), INTERVAL 5 DAY), '08:00:00', 19.00, 4.3, 8.5, 5.0, 'B', 3, @collector1),
(8,  DATE_SUB(CURDATE(), INTERVAL 5 DAY), '08:30:00', 20.00, 4.5, 8.6, 4.9, 'B', 3, @collector1),
(9,  DATE_SUB(CURDATE(), INTERVAL 5 DAY), '09:00:00', 23.50, 5.1, 8.9, 4.5, 'A', 4, @collector2),
(10, DATE_SUB(CURDATE(), INTERVAL 5 DAY), '09:30:00', 22.00, 5.3, 9.0, 4.4, 'A', 4, @collector2),
(11, DATE_SUB(CURDATE(), INTERVAL 5 DAY), '06:45:00', 20.50, 4.8, 8.7, 4.6, 'B', 1, @collector1),
(12, DATE_SUB(CURDATE(), INTERVAL 5 DAY), '07:15:00', 27.00, 5.9, 9.1, 4.1, 'A', 2, @collector2),
(1,  DATE_SUB(CURDATE(), INTERVAL 5 DAY), '06:00:00', 26.00, 5.3, 9.0, 4.2, 'A', 1, @collector1),
(2,  DATE_SUB(CURDATE(), INTERVAL 5 DAY), '06:30:00', 28.50, 5.9, 9.1, 4.1, 'A', 2, @collector2),
(5,  DATE_SUB(CURDATE(), INTERVAL 5 DAY), '06:15:00', 22.50, 5.0, 8.8, 4.5, 'A', 1, @collector1);

-- Day 6
INSERT IGNORE INTO MILK_COLLECTION (farmer_id, collection_date, collection_time, quantity_liters, fat_percentage, snf_value, temperature, quality_grade, collection_center_id, collected_by) VALUES
(1,  DATE_SUB(CURDATE(), INTERVAL 6 DAY), '06:00:00', 26.50, 5.3, 9.0, 4.2, 'A', 1, @collector1),
(2,  DATE_SUB(CURDATE(), INTERVAL 6 DAY), '06:30:00', 29.00, 5.9, 9.1, 4.1, 'A', 2, @collector2),
(3,  DATE_SUB(CURDATE(), INTERVAL 6 DAY), '07:00:00', 21.50, 4.9, 8.8, 4.6, 'B', 1, @collector1),
(4,  DATE_SUB(CURDATE(), INTERVAL 6 DAY), '07:30:00', 27.00, 5.5, 9.0, 4.4, 'A', 2, @collector2),
(5,  DATE_SUB(CURDATE(), INTERVAL 6 DAY), '06:15:00', 22.50, 5.1, 8.9, 4.5, 'A', 1, @collector1),
(6,  DATE_SUB(CURDATE(), INTERVAL 6 DAY), '06:45:00', 24.50, 5.8, 9.0, 4.2, 'A', 2, @collector2),
(7,  DATE_SUB(CURDATE(), INTERVAL 6 DAY), '08:00:00', 18.00, 4.2, 8.5, 5.1, 'B', 3, @collector1),
(8,  DATE_SUB(CURDATE(), INTERVAL 6 DAY), '08:30:00', 19.50, 4.5, 8.6, 4.9, 'B', 3, @collector1),
(9,  DATE_SUB(CURDATE(), INTERVAL 6 DAY), '09:00:00', 22.50, 5.0, 8.8, 4.5, 'A', 4, @collector2),
(10, DATE_SUB(CURDATE(), INTERVAL 6 DAY), '09:30:00', 21.00, 5.2, 8.9, 4.4, 'A', 4, @collector2);

-- Days 7-14 bulk
INSERT IGNORE INTO MILK_COLLECTION (farmer_id, collection_date, collection_time, quantity_liters, fat_percentage, snf_value, temperature, quality_grade, collection_center_id, collected_by) VALUES
(1,  DATE_SUB(CURDATE(), INTERVAL 7 DAY),  '06:00:00', 25.00, 5.2, 8.9, 4.3, 'A', 1, @collector1),
(2,  DATE_SUB(CURDATE(), INTERVAL 7 DAY),  '06:30:00', 30.00, 6.1, 9.2, 4.0, 'A', 2, @collector2),
(3,  DATE_SUB(CURDATE(), INTERVAL 7 DAY),  '07:00:00', 20.00, 4.8, 8.7, 4.7, 'B', 1, @collector1),
(4,  DATE_SUB(CURDATE(), INTERVAL 7 DAY),  '07:30:00', 28.00, 5.6, 9.0, 4.3, 'A', 2, @collector2),
(5,  DATE_SUB(CURDATE(), INTERVAL 7 DAY),  '06:15:00', 22.00, 5.0, 8.8, 4.5, 'A', 1, @collector1),
(6,  DATE_SUB(CURDATE(), INTERVAL 7 DAY),  '06:45:00', 24.00, 5.7, 9.0, 4.2, 'A', 2, @collector2),
(9,  DATE_SUB(CURDATE(), INTERVAL 7 DAY),  '09:00:00', 23.00, 5.1, 8.9, 4.4, 'A', 4, @collector2),
(10, DATE_SUB(CURDATE(), INTERVAL 7 DAY),  '09:30:00', 21.50, 5.3, 9.0, 4.4, 'A', 4, @collector2),
(1,  DATE_SUB(CURDATE(), INTERVAL 8 DAY),  '06:00:00', 26.00, 5.3, 9.0, 4.2, 'A', 1, @collector1),
(2,  DATE_SUB(CURDATE(), INTERVAL 8 DAY),  '06:30:00', 28.50, 5.9, 9.1, 4.1, 'A', 2, @collector2),
(3,  DATE_SUB(CURDATE(), INTERVAL 8 DAY),  '07:00:00', 19.00, 4.7, 8.6, 4.8, 'B', 1, @collector1),
(5,  DATE_SUB(CURDATE(), INTERVAL 8 DAY),  '06:15:00', 23.50, 5.2, 8.9, 4.4, 'A', 1, @collector1),
(7,  DATE_SUB(CURDATE(), INTERVAL 8 DAY),  '08:00:00', 18.00, 4.2, 8.5, 5.0, 'B', 3, @collector1),
(11, DATE_SUB(CURDATE(), INTERVAL 8 DAY),  '06:45:00', 20.00, 4.8, 8.7, 4.7, 'B', 1, @collector1),
(12, DATE_SUB(CURDATE(), INTERVAL 8 DAY),  '07:15:00', 27.50, 6.0, 9.2, 4.0, 'A', 2, @collector2),
(14, DATE_SUB(CURDATE(), INTERVAL 8 DAY),  '07:00:00', 25.00, 5.6, 9.0, 4.3, 'A', 2, @collector2),
(1,  DATE_SUB(CURDATE(), INTERVAL 9 DAY),  '06:00:00', 24.50, 5.1, 8.9, 4.4, 'A', 1, @collector1),
(2,  DATE_SUB(CURDATE(), INTERVAL 9 DAY),  '06:30:00', 31.00, 6.2, 9.3, 3.9, 'A', 2, @collector2),
(4,  DATE_SUB(CURDATE(), INTERVAL 9 DAY),  '07:30:00', 27.00, 5.4, 9.0, 4.4, 'A', 2, @collector2),
(5,  DATE_SUB(CURDATE(), INTERVAL 9 DAY),  '06:15:00', 21.00, 4.9, 8.8, 4.6, 'B', 1, @collector1),
(6,  DATE_SUB(CURDATE(), INTERVAL 9 DAY),  '06:45:00', 23.00, 5.6, 8.9, 4.3, 'A', 2, @collector2),
(8,  DATE_SUB(CURDATE(), INTERVAL 9 DAY),  '08:30:00', 20.50, 4.5, 8.6, 4.8, 'B', 3, @collector1),
(13, DATE_SUB(CURDATE(), INTERVAL 9 DAY),  '06:30:00', 18.50, 4.5, 8.6, 4.9, 'B', 1, @collector1),
(15, DATE_SUB(CURDATE(), INTERVAL 9 DAY),  '08:00:00', 17.00, 4.1, 8.4, 5.1, 'C', 3, @collector1),
(1,  DATE_SUB(CURDATE(), INTERVAL 10 DAY), '06:00:00', 25.50, 5.2, 8.9, 4.3, 'A', 1, @collector1),
(2,  DATE_SUB(CURDATE(), INTERVAL 10 DAY), '06:30:00', 29.50, 6.0, 9.2, 4.0, 'A', 2, @collector2),
(3,  DATE_SUB(CURDATE(), INTERVAL 10 DAY), '07:00:00', 20.50, 4.8, 8.7, 4.7, 'B', 1, @collector1),
(4,  DATE_SUB(CURDATE(), INTERVAL 10 DAY), '07:30:00', 28.00, 5.5, 9.0, 4.3, 'A', 2, @collector2),
(9,  DATE_SUB(CURDATE(), INTERVAL 10 DAY), '09:00:00', 23.50, 5.2, 9.0, 4.4, 'A', 4, @collector2),
(10, DATE_SUB(CURDATE(), INTERVAL 10 DAY), '09:30:00', 22.00, 5.4, 9.1, 4.3, 'A', 4, @collector2),
(11, DATE_SUB(CURDATE(), INTERVAL 10 DAY), '06:45:00', 19.50, 4.7, 8.7, 4.7, 'B', 1, @collector1),
(12, DATE_SUB(CURDATE(), INTERVAL 10 DAY), '07:15:00', 26.50, 5.8, 9.1, 4.2, 'A', 2, @collector2),
(1,  DATE_SUB(CURDATE(), INTERVAL 11 DAY), '06:00:00', 27.00, 5.4, 9.1, 4.1, 'A', 1, @collector1),
(2,  DATE_SUB(CURDATE(), INTERVAL 11 DAY), '06:30:00', 30.00, 6.1, 9.2, 4.0, 'A', 2, @collector2),
(5,  DATE_SUB(CURDATE(), INTERVAL 11 DAY), '06:15:00', 22.00, 5.0, 8.8, 4.5, 'A', 1, @collector1),
(6,  DATE_SUB(CURDATE(), INTERVAL 11 DAY), '06:45:00', 24.50, 5.8, 9.0, 4.2, 'A', 2, @collector2),
(7,  DATE_SUB(CURDATE(), INTERVAL 11 DAY), '08:00:00', 18.00, 4.2, 8.5, 5.0, 'B', 3, @collector1),
(8,  DATE_SUB(CURDATE(), INTERVAL 11 DAY), '08:30:00', 19.50, 4.5, 8.6, 4.9, 'B', 3, @collector1),
(13, DATE_SUB(CURDATE(), INTERVAL 11 DAY), '06:30:00', 19.00, 4.6, 8.6, 4.8, 'B', 1, @collector1),
(14, DATE_SUB(CURDATE(), INTERVAL 11 DAY), '07:00:00', 25.50, 5.7, 9.0, 4.2, 'A', 2, @collector2),
(1,  DATE_SUB(CURDATE(), INTERVAL 12 DAY), '06:00:00', 24.00, 5.1, 8.9, 4.4, 'A', 1, @collector1),
(2,  DATE_SUB(CURDATE(), INTERVAL 12 DAY), '06:30:00', 28.00, 5.8, 9.1, 4.1, 'A', 2, @collector2),
(3,  DATE_SUB(CURDATE(), INTERVAL 12 DAY), '07:00:00', 21.00, 4.9, 8.8, 4.6, 'B', 1, @collector1),
(4,  DATE_SUB(CURDATE(), INTERVAL 12 DAY), '07:30:00', 27.50, 5.5, 9.0, 4.4, 'A', 2, @collector2),
(9,  DATE_SUB(CURDATE(), INTERVAL 12 DAY), '09:00:00', 22.50, 5.1, 8.9, 4.5, 'A', 4, @collector2),
(10, DATE_SUB(CURDATE(), INTERVAL 12 DAY), '09:30:00', 21.00, 5.2, 9.0, 4.4, 'A', 4, @collector2),
(15, DATE_SUB(CURDATE(), INTERVAL 12 DAY), '08:00:00', 16.00, 4.0, 8.3, 5.2, 'C', 3, @collector1),
(1,  DATE_SUB(CURDATE(), INTERVAL 13 DAY), '06:00:00', 26.50, 5.3, 9.0, 4.2, 'A', 1, @collector1),
(2,  DATE_SUB(CURDATE(), INTERVAL 13 DAY), '06:30:00', 31.50, 6.2, 9.3, 3.8, 'A', 2, @collector2),
(5,  DATE_SUB(CURDATE(), INTERVAL 13 DAY), '06:15:00', 23.00, 5.1, 8.9, 4.5, 'A', 1, @collector1),
(6,  DATE_SUB(CURDATE(), INTERVAL 13 DAY), '06:45:00', 25.00, 5.9, 9.1, 4.1, 'A', 2, @collector2),
(11, DATE_SUB(CURDATE(), INTERVAL 13 DAY), '06:45:00', 20.50, 4.8, 8.7, 4.6, 'B', 1, @collector1),
(12, DATE_SUB(CURDATE(), INTERVAL 13 DAY), '07:15:00', 28.00, 6.0, 9.2, 4.0, 'A', 2, @collector2),
(13, DATE_SUB(CURDATE(), INTERVAL 13 DAY), '06:30:00', 18.50, 4.5, 8.5, 4.9, 'B', 1, @collector1),
(14, DATE_SUB(CURDATE(), INTERVAL 13 DAY), '07:00:00', 26.00, 5.8, 9.1, 4.2, 'A', 2, @collector2),
(1,  DATE_SUB(CURDATE(), INTERVAL 14 DAY), '06:00:00', 25.50, 5.2, 8.9, 4.3, 'A', 1, @collector1),
(2,  DATE_SUB(CURDATE(), INTERVAL 14 DAY), '06:30:00', 29.00, 5.9, 9.1, 4.1, 'A', 2, @collector2),
(3,  DATE_SUB(CURDATE(), INTERVAL 14 DAY), '07:00:00', 20.00, 4.8, 8.7, 4.7, 'B', 1, @collector1),
(4,  DATE_SUB(CURDATE(), INTERVAL 14 DAY), '07:30:00', 27.00, 5.5, 9.0, 4.3, 'A', 2, @collector2),
(7,  DATE_SUB(CURDATE(), INTERVAL 14 DAY), '08:00:00', 17.50, 4.2, 8.5, 5.1, 'B', 3, @collector1),
(8,  DATE_SUB(CURDATE(), INTERVAL 14 DAY), '08:30:00', 19.00, 4.4, 8.6, 4.9, 'B', 3, @collector1),
(9,  DATE_SUB(CURDATE(), INTERVAL 14 DAY), '09:00:00', 23.00, 5.0, 8.8, 4.5, 'A', 4, @collector2),
(10, DATE_SUB(CURDATE(), INTERVAL 14 DAY), '09:30:00', 22.00, 5.3, 9.0, 4.4, 'A', 4, @collector2);

-- Days 15-30 (spread)
INSERT IGNORE INTO MILK_COLLECTION (farmer_id, collection_date, collection_time, quantity_liters, fat_percentage, snf_value, temperature, quality_grade, collection_center_id, collected_by) VALUES
(1, DATE_SUB(CURDATE(), INTERVAL 15 DAY), '06:00:00', 24.00, 5.1, 8.8, 4.4, 'A', 1, @collector1),
(2, DATE_SUB(CURDATE(), INTERVAL 15 DAY), '06:30:00', 29.00, 6.0, 9.2, 4.0, 'A', 2, @collector2),
(3, DATE_SUB(CURDATE(), INTERVAL 15 DAY), '07:00:00', 19.00, 4.7, 8.6, 4.8, 'B', 1, @collector1),
(4, DATE_SUB(CURDATE(), INTERVAL 15 DAY), '07:30:00', 26.00, 5.4, 9.0, 4.4, 'A', 2, @collector2),
(5, DATE_SUB(CURDATE(), INTERVAL 15 DAY), '06:15:00', 21.50, 4.9, 8.8, 4.6, 'B', 1, @collector1),
(1, DATE_SUB(CURDATE(), INTERVAL 17 DAY), '06:00:00', 25.00, 5.2, 8.9, 4.3, 'A', 1, @collector1),
(2, DATE_SUB(CURDATE(), INTERVAL 17 DAY), '06:30:00', 30.00, 6.1, 9.2, 4.0, 'A', 2, @collector2),
(6, DATE_SUB(CURDATE(), INTERVAL 17 DAY), '06:45:00', 23.50, 5.6, 9.0, 4.3, 'A', 2, @collector2),
(9, DATE_SUB(CURDATE(), INTERVAL 17 DAY), '09:00:00', 22.00, 5.0, 8.8, 4.5, 'A', 4, @collector2),
(10,DATE_SUB(CURDATE(), INTERVAL 17 DAY), '09:30:00', 21.00, 5.2, 9.0, 4.4, 'A', 4, @collector2),
(1, DATE_SUB(CURDATE(), INTERVAL 20 DAY), '06:00:00', 26.00, 5.3, 9.0, 4.2, 'A', 1, @collector1),
(2, DATE_SUB(CURDATE(), INTERVAL 20 DAY), '06:30:00', 28.50, 5.8, 9.1, 4.1, 'A', 2, @collector2),
(3, DATE_SUB(CURDATE(), INTERVAL 20 DAY), '07:00:00', 20.00, 4.8, 8.7, 4.7, 'B', 1, @collector1),
(4, DATE_SUB(CURDATE(), INTERVAL 20 DAY), '07:30:00', 27.00, 5.5, 9.0, 4.3, 'A', 2, @collector2),
(11,DATE_SUB(CURDATE(), INTERVAL 20 DAY), '06:45:00', 19.50, 4.7, 8.7, 4.7, 'B', 1, @collector1),
(1, DATE_SUB(CURDATE(), INTERVAL 25 DAY), '06:00:00', 24.50, 5.1, 8.9, 4.4, 'A', 1, @collector1),
(2, DATE_SUB(CURDATE(), INTERVAL 25 DAY), '06:30:00', 30.50, 6.1, 9.2, 4.0, 'A', 2, @collector2),
(5, DATE_SUB(CURDATE(), INTERVAL 25 DAY), '06:15:00', 22.00, 5.0, 8.8, 4.5, 'A', 1, @collector1),
(6, DATE_SUB(CURDATE(), INTERVAL 25 DAY), '06:45:00', 24.00, 5.7, 9.0, 4.2, 'A', 2, @collector2),
(12,DATE_SUB(CURDATE(), INTERVAL 25 DAY), '07:15:00', 27.00, 5.9, 9.1, 4.1, 'A', 2, @collector2),
(1, DATE_SUB(CURDATE(), INTERVAL 30 DAY), '06:00:00', 23.00, 5.0, 8.8, 4.5, 'A', 1, @collector1),
(2, DATE_SUB(CURDATE(), INTERVAL 30 DAY), '06:30:00', 29.00, 6.0, 9.1, 4.0, 'A', 2, @collector2),
(3, DATE_SUB(CURDATE(), INTERVAL 30 DAY), '07:00:00', 19.50, 4.7, 8.6, 4.8, 'B', 1, @collector1),
(4, DATE_SUB(CURDATE(), INTERVAL 30 DAY), '07:30:00', 26.50, 5.4, 9.0, 4.4, 'A', 2, @collector2),
(9, DATE_SUB(CURDATE(), INTERVAL 30 DAY), '09:00:00', 22.50, 5.1, 8.9, 4.5, 'A', 4, @collector2);

-- 6-month historical collections for trend chart
INSERT IGNORE INTO MILK_COLLECTION (farmer_id, collection_date, collection_time, quantity_liters, fat_percentage, snf_value, temperature, quality_grade, collection_center_id, collected_by) VALUES
(1, DATE_SUB(CURDATE(), INTERVAL 45 DAY), '06:00:00', 22.00, 5.0, 8.8, 4.5, 'A', 1, @collector1),
(2, DATE_SUB(CURDATE(), INTERVAL 45 DAY), '06:30:00', 27.50, 5.8, 9.0, 4.1, 'A', 2, @collector2),
(3, DATE_SUB(CURDATE(), INTERVAL 45 DAY), '07:00:00', 18.50, 4.6, 8.6, 4.8, 'B', 1, @collector1),
(4, DATE_SUB(CURDATE(), INTERVAL 45 DAY), '07:30:00', 25.00, 5.3, 8.9, 4.4, 'A', 2, @collector2),
(5, DATE_SUB(CURDATE(), INTERVAL 45 DAY), '06:15:00', 20.50, 4.8, 8.7, 4.7, 'B', 1, @collector1),
(1, DATE_SUB(CURDATE(), INTERVAL 50 DAY), '06:00:00', 23.50, 5.1, 8.9, 4.4, 'A', 1, @collector1),
(2, DATE_SUB(CURDATE(), INTERVAL 50 DAY), '06:30:00', 28.00, 5.9, 9.1, 4.0, 'A', 2, @collector2),
(6, DATE_SUB(CURDATE(), INTERVAL 50 DAY), '06:45:00', 22.50, 5.5, 8.9, 4.3, 'A', 2, @collector2),
(9, DATE_SUB(CURDATE(), INTERVAL 55 DAY), '09:00:00', 21.50, 5.0, 8.8, 4.5, 'A', 4, @collector2),
(1, DATE_SUB(CURDATE(), INTERVAL 75 DAY), '06:00:00', 21.00, 4.9, 8.7, 4.6, 'B', 1, @collector1),
(2, DATE_SUB(CURDATE(), INTERVAL 75 DAY), '06:30:00', 26.50, 5.7, 9.0, 4.2, 'A', 2, @collector2),
(3, DATE_SUB(CURDATE(), INTERVAL 75 DAY), '07:00:00', 18.00, 4.5, 8.5, 5.0, 'B', 1, @collector1),
(4, DATE_SUB(CURDATE(), INTERVAL 80 DAY), '07:30:00', 24.50, 5.2, 8.9, 4.4, 'A', 2, @collector2),
(1, DATE_SUB(CURDATE(), INTERVAL 85 DAY), '06:00:00', 22.50, 5.0, 8.8, 4.5, 'A', 1, @collector1),
(2, DATE_SUB(CURDATE(), INTERVAL 85 DAY), '06:30:00', 27.00, 5.8, 9.0, 4.1, 'A', 2, @collector2),
(1, DATE_SUB(CURDATE(), INTERVAL 110 DAY),'06:00:00', 20.00, 4.8, 8.7, 4.7, 'B', 1, @collector1),
(2, DATE_SUB(CURDATE(), INTERVAL 110 DAY),'06:30:00', 25.00, 5.6, 8.9, 4.2, 'A', 2, @collector2),
(3, DATE_SUB(CURDATE(), INTERVAL 115 DAY),'07:00:00', 17.50, 4.4, 8.5, 5.0, 'B', 1, @collector1),
(4, DATE_SUB(CURDATE(), INTERVAL 115 DAY),'07:30:00', 23.50, 5.1, 8.9, 4.5, 'A', 2, @collector2),
(1, DATE_SUB(CURDATE(), INTERVAL 120 DAY),'06:00:00', 21.50, 4.9, 8.8, 4.5, 'A', 1, @collector1),
(1, DATE_SUB(CURDATE(), INTERVAL 145 DAY),'06:00:00', 19.50, 4.7, 8.7, 4.7, 'B', 1, @collector1),
(2, DATE_SUB(CURDATE(), INTERVAL 145 DAY),'06:30:00', 24.50, 5.5, 8.9, 4.2, 'A', 2, @collector2),
(3, DATE_SUB(CURDATE(), INTERVAL 150 DAY),'07:00:00', 17.00, 4.3, 8.4, 5.1, 'C', 1, @collector1),
(4, DATE_SUB(CURDATE(), INTERVAL 150 DAY),'07:30:00', 22.00, 5.0, 8.8, 4.5, 'A', 2, @collector2),
(1, DATE_SUB(CURDATE(), INTERVAL 175 DAY),'06:00:00', 18.50, 4.6, 8.6, 4.8, 'B', 1, @collector1),
(2, DATE_SUB(CURDATE(), INTERVAL 175 DAY),'06:30:00', 23.00, 5.4, 8.8, 4.3, 'A', 2, @collector2),
(3, DATE_SUB(CURDATE(), INTERVAL 180 DAY),'07:00:00', 16.50, 4.2, 8.4, 5.1, 'C', 1, @collector1),
(4, DATE_SUB(CURDATE(), INTERVAL 180 DAY),'07:30:00', 21.00, 4.9, 8.7, 4.6, 'B', 2, @collector2),
(5, DATE_SUB(CURDATE(), INTERVAL 180 DAY),'06:15:00', 17.50, 4.4, 8.5, 5.0, 'B', 1, @collector1);

-- =====================================================
-- Additional Orders (using dynamic employee IDs)
-- =====================================================
INSERT INTO CUSTOMER_ORDER (customer_id, order_date, required_date, order_status, subtotal, tax_amount, total_amount, processed_by, remarks) VALUES
(5, DATE_SUB(CURDATE(), INTERVAL 3 DAY),  DATE_SUB(CURDATE(), INTERVAL 1 DAY),  'Delivered',  15600.00, 1248.00, 16848.00, @sales2, 'Regular weekly order'),
(6, DATE_SUB(CURDATE(), INTERVAL 3 DAY),  DATE_SUB(CURDATE(), INTERVAL 1 DAY),  'Delivered',  38400.00, 3072.00, 41472.00, @sales1, 'Hospital monthly supply'),
(1, DATE_SUB(CURDATE(), INTERVAL 4 DAY),  DATE_SUB(CURDATE(), INTERVAL 2 DAY),  'Delivered',  56000.00, 4480.00, 60480.00, @sales1, NULL),
(2, DATE_SUB(CURDATE(), INTERVAL 5 DAY),  DATE_SUB(CURDATE(), INTERVAL 3 DAY),  'Delivered',  72000.00, 5760.00, 77760.00, @sales1, 'Bulk order'),
(3, DATE_SUB(CURDATE(), INTERVAL 5 DAY),  DATE_SUB(CURDATE(), INTERVAL 3 DAY),  'Cancelled',  24000.00, 1920.00, 25920.00, @sales2, 'Customer cancelled'),
(4, DATE_SUB(CURDATE(), INTERVAL 7 DAY),  DATE_SUB(CURDATE(), INTERVAL 5 DAY),  'Delivered',  21600.00, 1728.00, 23328.00, @sales2, NULL),
(7, DATE_SUB(CURDATE(), INTERVAL 8 DAY),  DATE_SUB(CURDATE(), INTERVAL 6 DAY),  'Delivered',  19200.00, 1536.00, 20736.00, @sales1, 'Sathosa weekly'),
(8, DATE_SUB(CURDATE(), INTERVAL 8 DAY),  DATE_SUB(CURDATE(), INTERVAL 5 DAY),  'Delivered',  12400.00,  992.00, 13392.00, @sales2, NULL),
(9, DATE_SUB(CURDATE(), INTERVAL 9 DAY),  DATE_SUB(CURDATE(), INTERVAL 7 DAY),  'Delivered',   8800.00,  704.00,  9504.00, @sales2, NULL),
(1, DATE_SUB(CURDATE(), INTERVAL 10 DAY), DATE_SUB(CURDATE(), INTERVAL 8 DAY),  'Delivered',  52000.00, 4160.00, 56160.00, @sales1, NULL),
(2, DATE_SUB(CURDATE(), INTERVAL 12 DAY), DATE_SUB(CURDATE(), INTERVAL 10 DAY), 'Delivered',  68000.00, 5440.00, 73440.00, @sales1, 'Large weekly'),
(5, DATE_SUB(CURDATE(), INTERVAL 13 DAY), DATE_SUB(CURDATE(), INTERVAL 11 DAY), 'Delivered',  14400.00, 1152.00, 15552.00, @sales2, NULL),
(6, DATE_SUB(CURDATE(), INTERVAL 14 DAY), DATE_SUB(CURDATE(), INTERVAL 12 DAY), 'Delivered',  36000.00, 2880.00, 38880.00, @sales1, NULL),
(3, DATE_SUB(CURDATE(), INTERVAL 14 DAY), DATE_SUB(CURDATE(), INTERVAL 12 DAY), 'Delivered',  27200.00, 2176.00, 29376.00, @sales2, NULL),
(4, DATE_SUB(CURDATE(), INTERVAL 15 DAY), DATE_SUB(CURDATE(), INTERVAL 13 DAY), 'Delivered',  19800.00, 1584.00, 21384.00, @sales2, 'Hotel stock top-up'),
(1, DATE_SUB(CURDATE(), INTERVAL 2 DAY),  DATE_ADD(CURDATE(), INTERVAL 1 DAY),  'Confirmed',  48000.00, 3840.00, 51840.00, @sales1, NULL),
(7, DATE_SUB(CURDATE(), INTERVAL 2 DAY),  DATE_ADD(CURDATE(), INTERVAL 2 DAY),  'Confirmed',  22800.00, 1824.00, 24624.00, @sales1, NULL),
(8, DATE_SUB(CURDATE(), INTERVAL 1 DAY),  DATE_ADD(CURDATE(), INTERVAL 3 DAY),  'Pending',    11600.00,  928.00, 12528.00, @sales2, NULL),
(9, DATE_SUB(CURDATE(), INTERVAL 1 DAY),  DATE_ADD(CURDATE(), INTERVAL 3 DAY),  'Pending',     9200.00,  736.00,  9936.00, @sales2, NULL),
(10,CURDATE(),                             DATE_ADD(CURDATE(), INTERVAL 4 DAY),  'Pending',    32000.00, 2560.00, 34560.00, @sales1, 'Fresh Mart monthly');

-- =====================================================
-- Order Lines (using subqueries to find correct order_ids)
-- =====================================================
INSERT INTO ORDER_LINE (order_id, product_id, quantity, unit_price, line_total)
SELECT o.order_id, 4, 80, 120.00, 9600.00 FROM CUSTOMER_ORDER o WHERE o.customer_id=5 AND o.subtotal=15600.00 LIMIT 1;
INSERT INTO ORDER_LINE (order_id, product_id, quantity, unit_price, line_total)
SELECT o.order_id, 5, 50, 120.00, 6000.00 FROM CUSTOMER_ORDER o WHERE o.customer_id=5 AND o.subtotal=15600.00 LIMIT 1;

INSERT INTO ORDER_LINE (order_id, product_id, quantity, unit_price, line_total)
SELECT o.order_id, 1, 100, 280.00, 28000.00 FROM CUSTOMER_ORDER o WHERE o.customer_id=6 AND o.subtotal=38400.00 LIMIT 1;
INSERT INTO ORDER_LINE (order_id, product_id, quantity, unit_price, line_total)
SELECT o.order_id, 6, 40, 180.00, 7200.00 FROM CUSTOMER_ORDER o WHERE o.customer_id=6 AND o.subtotal=38400.00 LIMIT 1;
INSERT INTO ORDER_LINE (order_id, product_id, quantity, unit_price, line_total)
SELECT o.order_id, 7, 16, 200.00, 3200.00 FROM CUSTOMER_ORDER o WHERE o.customer_id=6 AND o.subtotal=38400.00 LIMIT 1;

INSERT INTO ORDER_LINE (order_id, product_id, quantity, unit_price, line_total)
SELECT o.order_id, 1, 200, 280.00, 56000.00 FROM CUSTOMER_ORDER o WHERE o.customer_id=1 AND o.subtotal=56000.00 LIMIT 1;

INSERT INTO ORDER_LINE (order_id, product_id, quantity, unit_price, line_total)
SELECT o.order_id, 1, 150, 280.00, 42000.00 FROM CUSTOMER_ORDER o WHERE o.customer_id=2 AND o.subtotal=72000.00 LIMIT 1;
INSERT INTO ORDER_LINE (order_id, product_id, quantity, unit_price, line_total)
SELECT o.order_id, 10, 30, 850.00, 25500.00 FROM CUSTOMER_ORDER o WHERE o.customer_id=2 AND o.subtotal=72000.00 LIMIT 1;
INSERT INTO ORDER_LINE (order_id, product_id, quantity, unit_price, line_total)
SELECT o.order_id, 11, 10, 450.00, 4500.00 FROM CUSTOMER_ORDER o WHERE o.customer_id=2 AND o.subtotal=72000.00 LIMIT 1;

INSERT INTO ORDER_LINE (order_id, product_id, quantity, unit_price, line_total)
SELECT o.order_id, 2, 80, 260.00, 20800.00 FROM CUSTOMER_ORDER o WHERE o.customer_id=3 AND o.subtotal=24000.00 LIMIT 1;
INSERT INTO ORDER_LINE (order_id, product_id, quantity, unit_price, line_total)
SELECT o.order_id, 5, 26, 120.00, 3120.00 FROM CUSTOMER_ORDER o WHERE o.customer_id=3 AND o.subtotal=24000.00 LIMIT 1;

INSERT INTO ORDER_LINE (order_id, product_id, quantity, unit_price, line_total)
SELECT o.order_id, 1, 50, 280.00, 14000.00 FROM CUSTOMER_ORDER o WHERE o.customer_id=4 AND o.subtotal=21600.00 LIMIT 1;
INSERT INTO ORDER_LINE (order_id, product_id, quantity, unit_price, line_total)
SELECT o.order_id, 6, 30, 180.00, 5400.00 FROM CUSTOMER_ORDER o WHERE o.customer_id=4 AND o.subtotal=21600.00 LIMIT 1;
INSERT INTO ORDER_LINE (order_id, product_id, quantity, unit_price, line_total)
SELECT o.order_id, 7, 11, 200.00, 2200.00 FROM CUSTOMER_ORDER o WHERE o.customer_id=4 AND o.subtotal=21600.00 LIMIT 1;

INSERT INTO ORDER_LINE (order_id, product_id, quantity, unit_price, line_total)
SELECT o.order_id, 1, 50, 280.00, 14000.00 FROM CUSTOMER_ORDER o WHERE o.customer_id=7 AND o.subtotal=19200.00 LIMIT 1;
INSERT INTO ORDER_LINE (order_id, product_id, quantity, unit_price, line_total)
SELECT o.order_id, 4, 30, 120.00, 3600.00 FROM CUSTOMER_ORDER o WHERE o.customer_id=7 AND o.subtotal=19200.00 LIMIT 1;
INSERT INTO ORDER_LINE (order_id, product_id, quantity, unit_price, line_total)
SELECT o.order_id, 5, 13, 120.00, 1560.00 FROM CUSTOMER_ORDER o WHERE o.customer_id=7 AND o.subtotal=19200.00 LIMIT 1;

INSERT INTO ORDER_LINE (order_id, product_id, quantity, unit_price, line_total)
SELECT o.order_id, 1, 30, 280.00, 8400.00 FROM CUSTOMER_ORDER o WHERE o.customer_id=8 AND o.subtotal=12400.00 LIMIT 1;
INSERT INTO ORDER_LINE (order_id, product_id, quantity, unit_price, line_total)
SELECT o.order_id, 6, 22, 180.00, 3960.00 FROM CUSTOMER_ORDER o WHERE o.customer_id=8 AND o.subtotal=12400.00 LIMIT 1;

INSERT INTO ORDER_LINE (order_id, product_id, quantity, unit_price, line_total)
SELECT o.order_id, 4, 40, 120.00, 4800.00 FROM CUSTOMER_ORDER o WHERE o.customer_id=9 AND o.subtotal=8800.00 LIMIT 1;
INSERT INTO ORDER_LINE (order_id, product_id, quantity, unit_price, line_total)
SELECT o.order_id, 5, 33, 120.00, 3960.00 FROM CUSTOMER_ORDER o WHERE o.customer_id=9 AND o.subtotal=8800.00 LIMIT 1;

INSERT INTO ORDER_LINE (order_id, product_id, quantity, unit_price, line_total)
SELECT o.order_id, 1, 180, 280.00, 50400.00 FROM CUSTOMER_ORDER o WHERE o.customer_id=1 AND o.subtotal=52000.00 LIMIT 1;
INSERT INTO ORDER_LINE (order_id, product_id, quantity, unit_price, line_total)
SELECT o.order_id, 3, 7, 240.00, 1680.00 FROM CUSTOMER_ORDER o WHERE o.customer_id=1 AND o.subtotal=52000.00 LIMIT 1;

INSERT INTO ORDER_LINE (order_id, product_id, quantity, unit_price, line_total)
SELECT o.order_id, 1, 200, 280.00, 56000.00 FROM CUSTOMER_ORDER o WHERE o.customer_id=2 AND o.subtotal=68000.00 LIMIT 1;
INSERT INTO ORDER_LINE (order_id, product_id, quantity, unit_price, line_total)
SELECT o.order_id, 10, 8, 850.00, 6800.00 FROM CUSTOMER_ORDER o WHERE o.customer_id=2 AND o.subtotal=68000.00 LIMIT 1;
INSERT INTO ORDER_LINE (order_id, product_id, quantity, unit_price, line_total)
SELECT o.order_id, 12, 10, 520.00, 5200.00 FROM CUSTOMER_ORDER o WHERE o.customer_id=2 AND o.subtotal=68000.00 LIMIT 1;

INSERT INTO ORDER_LINE (order_id, product_id, quantity, unit_price, line_total)
SELECT o.order_id, 4, 70, 120.00, 8400.00 FROM CUSTOMER_ORDER o WHERE o.customer_id=5 AND o.subtotal=14400.00 LIMIT 1;
INSERT INTO ORDER_LINE (order_id, product_id, quantity, unit_price, line_total)
SELECT o.order_id, 5, 50, 120.00, 6000.00 FROM CUSTOMER_ORDER o WHERE o.customer_id=5 AND o.subtotal=14400.00 LIMIT 1;

INSERT INTO ORDER_LINE (order_id, product_id, quantity, unit_price, line_total)
SELECT o.order_id, 1, 100, 280.00, 28000.00 FROM CUSTOMER_ORDER o WHERE o.customer_id=6 AND o.subtotal=36000.00 LIMIT 1;
INSERT INTO ORDER_LINE (order_id, product_id, quantity, unit_price, line_total)
SELECT o.order_id, 6, 30, 180.00, 5400.00 FROM CUSTOMER_ORDER o WHERE o.customer_id=6 AND o.subtotal=36000.00 LIMIT 1;
INSERT INTO ORDER_LINE (order_id, product_id, quantity, unit_price, line_total)
SELECT o.order_id, 7, 13, 200.00, 2600.00 FROM CUSTOMER_ORDER o WHERE o.customer_id=6 AND o.subtotal=36000.00 LIMIT 1;

INSERT INTO ORDER_LINE (order_id, product_id, quantity, unit_price, line_total)
SELECT o.order_id, 2, 80, 260.00, 20800.00 FROM CUSTOMER_ORDER o WHERE o.customer_id=3 AND o.subtotal=27200.00 LIMIT 1;
INSERT INTO ORDER_LINE (order_id, product_id, quantity, unit_price, line_total)
SELECT o.order_id, 5, 40, 120.00, 4800.00 FROM CUSTOMER_ORDER o WHERE o.customer_id=3 AND o.subtotal=27200.00 LIMIT 1;
INSERT INTO ORDER_LINE (order_id, product_id, quantity, unit_price, line_total)
SELECT o.order_id, 6, 9, 180.00, 1620.00 FROM CUSTOMER_ORDER o WHERE o.customer_id=3 AND o.subtotal=27200.00 LIMIT 1;

INSERT INTO ORDER_LINE (order_id, product_id, quantity, unit_price, line_total)
SELECT o.order_id, 1, 40, 280.00, 11200.00 FROM CUSTOMER_ORDER o WHERE o.customer_id=4 AND o.subtotal=19800.00 LIMIT 1;
INSERT INTO ORDER_LINE (order_id, product_id, quantity, unit_price, line_total)
SELECT o.order_id, 6, 35, 180.00, 6300.00 FROM CUSTOMER_ORDER o WHERE o.customer_id=4 AND o.subtotal=19800.00 LIMIT 1;
INSERT INTO ORDER_LINE (order_id, product_id, quantity, unit_price, line_total)
SELECT o.order_id, 11, 5, 450.00, 2250.00 FROM CUSTOMER_ORDER o WHERE o.customer_id=4 AND o.subtotal=19800.00 LIMIT 1;

INSERT INTO ORDER_LINE (order_id, product_id, quantity, unit_price, line_total)
SELECT o.order_id, 1, 120, 280.00, 33600.00 FROM CUSTOMER_ORDER o WHERE o.customer_id=1 AND o.subtotal=48000.00 LIMIT 1;
INSERT INTO ORDER_LINE (order_id, product_id, quantity, unit_price, line_total)
SELECT o.order_id, 2, 40, 260.00, 10400.00 FROM CUSTOMER_ORDER o WHERE o.customer_id=1 AND o.subtotal=48000.00 LIMIT 1;
INSERT INTO ORDER_LINE (order_id, product_id, quantity, unit_price, line_total)
SELECT o.order_id, 7, 20, 200.00, 4000.00 FROM CUSTOMER_ORDER o WHERE o.customer_id=1 AND o.subtotal=48000.00 LIMIT 1;

INSERT INTO ORDER_LINE (order_id, product_id, quantity, unit_price, line_total)
SELECT o.order_id, 1, 60, 280.00, 16800.00 FROM CUSTOMER_ORDER o WHERE o.customer_id=7 AND o.subtotal=22800.00 LIMIT 1;
INSERT INTO ORDER_LINE (order_id, product_id, quantity, unit_price, line_total)
SELECT o.order_id, 4, 50, 120.00, 6000.00 FROM CUSTOMER_ORDER o WHERE o.customer_id=7 AND o.subtotal=22800.00 LIMIT 1;

INSERT INTO ORDER_LINE (order_id, product_id, quantity, unit_price, line_total)
SELECT o.order_id, 1, 30, 280.00, 8400.00 FROM CUSTOMER_ORDER o WHERE o.customer_id=8 AND o.subtotal=11600.00 LIMIT 1;
INSERT INTO ORDER_LINE (order_id, product_id, quantity, unit_price, line_total)
SELECT o.order_id, 6, 17, 180.00, 3060.00 FROM CUSTOMER_ORDER o WHERE o.customer_id=8 AND o.subtotal=11600.00 LIMIT 1;

INSERT INTO ORDER_LINE (order_id, product_id, quantity, unit_price, line_total)
SELECT o.order_id, 4, 45, 120.00, 5400.00 FROM CUSTOMER_ORDER o WHERE o.customer_id=9 AND o.subtotal=9200.00 LIMIT 1;
INSERT INTO ORDER_LINE (order_id, product_id, quantity, unit_price, line_total)
SELECT o.order_id, 5, 32, 120.00, 3840.00 FROM CUSTOMER_ORDER o WHERE o.customer_id=9 AND o.subtotal=9200.00 LIMIT 1;

INSERT INTO ORDER_LINE (order_id, product_id, quantity, unit_price, line_total)
SELECT o.order_id, 1, 80, 280.00, 22400.00 FROM CUSTOMER_ORDER o WHERE o.customer_id=10 AND o.subtotal=32000.00 LIMIT 1;
INSERT INTO ORDER_LINE (order_id, product_id, quantity, unit_price, line_total)
SELECT o.order_id, 2, 30, 260.00, 7800.00 FROM CUSTOMER_ORDER o WHERE o.customer_id=10 AND o.subtotal=32000.00 LIMIT 1;
INSERT INTO ORDER_LINE (order_id, product_id, quantity, unit_price, line_total)
SELECT o.order_id, 7, 9, 200.00, 1800.00 FROM CUSTOMER_ORDER o WHERE o.customer_id=10 AND o.subtotal=32000.00 LIMIT 1;

-- =====================================================
-- Final summary
-- =====================================================
SELECT CONCAT(
    'Done! Farmers: ', (SELECT COUNT(*) FROM FARMER),
    ' | Collections: ', (SELECT COUNT(*) FROM MILK_COLLECTION),
    ' | Products: ', (SELECT COUNT(*) FROM PRODUCT),
    ' | Orders: ', (SELECT COUNT(*) FROM CUSTOMER_ORDER),
    ' | Customers: ', (SELECT COUNT(*) FROM CUSTOMER)
) AS Summary;
