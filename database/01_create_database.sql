-- =====================================================
-- Highland Milk Industries Database Creation Script
-- Advanced Dairy Production and Distribution Management System
-- =====================================================

-- Drop database if exists (for fresh installation)
DROP DATABASE IF EXISTS highland_milk_db;

-- Create database
CREATE DATABASE highland_milk_db
    CHARACTER SET utf8mb4
    COLLATE utf8mb4_unicode_ci;

-- Use the database
USE highland_milk_db;

-- Display confirmation
SELECT 'Database highland_milk_db created successfully!' as Status;
