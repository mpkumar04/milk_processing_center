# 🐄 Pelwatte Milk Industries - Management System

![PHP](https://img.shields.io/badge/PHP-7.4+-blue)
![MySQL](https://img.shields.io/badge/MySQL-5.7+-orange)
![Bootstrap](https://img.shields.io/badge/Bootstrap-5.3-purple)
![License](https://img.shields.io/badge/License-MIT-green)

Complete dairy production and distribution management system with business intelligence features.

## 📋 Project Overview

A comprehensive web-based dairy farm management system designed to manage all aspects of dairy operations:

- 🧑‍🌾 **Farmer Management** - Registration and profile management
- 🥛 **Milk Collection** - Daily collection tracking with quality parameters
- 📦 **Product Management** - Product catalog and inventory control
- 🛒 **Order Processing** - Customer orders and delivery management
- 💰 **Payment Processing** - Automated farmer payment calculations
- 📊 **Business Intelligence** - Analytics dashboards and reports

## 🖼️ Screenshots

### Dashboard
![Dashboard](https://via.placeholder.com/800x400?text=Dashboard+Screenshot)

### Farmers Management
![Farmers](https://via.placeholder.com/800x400?text=Farmers+Management)

### Reports & Analytics
![Reports](https://via.placeholder.com/800x400?text=Reports+%26+Analytics)

## 🚀 Features

### 💾 Database Features
- ✅ **17 Normalized Tables** (3NF compliant)
- ✅ **Triggers** for automated business logic
- ✅ **Stored Procedures** for complex operations
- ✅ **User-Defined Functions** for calculations
- ✅ **Views** for simplified data access
- ✅ **Comprehensive Constraints** (PK, FK, CHECK, UNIQUE)
- ✅ **Indexes** for optimized query performance

### 📊 Business Intelligence
- 📈 Monthly milk collection analysis
- 🏆 Top-performing farmers identification
- 💵 Revenue and sales analytics
- 📉 Product demand forecasting
- 📦 Inventory health monitoring
- 🎯 Collection center performance tracking

### 🌐 Web Application
- 📱 Responsive dashboard with real-time statistics
- 👥 Complete CRUD operations for farmers
- 🥛 Milk collection tracking
- 📦 Product and inventory management
- 🛒 Order processing system
- 📊 Interactive reports with charts
- 📥 CSV export functionality

## 📁 Project Structure

```
highland_milk/
├── database/
│   ├── highland_milk_backup.sql     # 🔄 Complete database backup
│   ├── 01_create_database.sql       # 🗄️ Database creation
│   ├── 02_create_tables.sql         # 📋 Table definitions
│   ├── 03_create_triggers.sql       # ⚡ Trigger implementations
│   ├── 04_create_functions.sql      # 🔧 User-defined functions
│   ├── 05_create_procedures.sql     # 📜 Stored procedures
│   ├── 06_create_views.sql          # 👁️ View definitions
│   └── 07_insert_sample_data.sql    # 📊 Sample data for testing
├── backend/
│   ├── config/
│   │   └── database.php             # ⚙️ Database connection
│   └── api/
│       ├── dashboard.php            # 📊 Dashboard API
│       ├── farmers.php              # 👨‍🌾 Farmer CRUD API
│       ├── collections.php          # 🥛 Collection API
│       ├── products.php             # 📦 Product API
│       ├── orders.php               # 🛒 Order API
│       └── reports.php              # 📈 Reports API
├── frontend/
│   ├── index.html                   # 🏠 Dashboard
│   ├── farmers.html                 # 👥 Farmers page
│   ├── collections.html             # 🥛 Collections page
│   ├── products.html                # 📦 Products page
│   ├── orders.html                  # 🛒 Orders page
│   ├── reports.html                 # 📊 Reports page
│   ├── css/
│   │   └── style.css                # 🎨 Custom styles
│   └── js/
│       ├── dashboard.js             # Dashboard logic
│       ├── farmers.js               # Farmers management
│       ├── collections.js           # Collections tracking
│       ├── products.js              # Products management
│       ├── orders.js                # Orders processing
│       └── reports.js               # Reports generation
├── .gitignore                       # 🚫 Git ignore rules
├── README.md                        # 📖 This file
└── TEST_PAGES.html                  # 🧪 Quick page tester
```

## � Quick Start

### Prerequisites

- 💾 **MySQL Server** 5.7+ or 8.0+
- 🐘 **PHP** 7.4 or higher
- 🌐 **Apache/Nginx** web server (XAMPP recommended for Windows)
- 🌍 **Web Browser** (Chrome, Firefox, Edge, Safari)

### Option 1: Quick Setup (Using Backup File)

```bash
# 1. Clone the repository
git clone https://github.com/YOUR_USERNAME/highland-milk-industries.git
cd highland-milk-industries

# 2. Import complete database
mysql -u root -p < database/highland_milk_backup.sql

# 3. Configure database connection
# Edit backend/config/database.php with your credentials

# 4. Copy to web server
# For XAMPP: Copy entire folder to c:\xampp\htdocs\
# For Linux: Copy to /var/www/html/

# 5. Open in browser
http://localhost/highland_milk/frontend/index.html
```

### Option 2: Step-by-Step Setup

### Database Setup

1. **Create the database:**
   ```bash
   mysql -u root -p < database/01_create_database.sql
   ```

2. **Create tables:**
   ```bash
   mysql -u root -p highland_milk_db < database/02_create_tables.sql
   ```

3. **Create triggers:**
   ```bash
   mysql -u root -p highland_milk_db < database/03_create_triggers.sql
   ```

4. **Create functions:**
   ```bash
   mysql -u root -p highland_milk_db < database/04_create_functions.sql
   ```

5. **Create stored procedures:**
   ```bash
   mysql -u root -p highland_milk_db < database/05_create_procedures.sql
   ```

6. **Create views:**
   ```bash
   mysql -u root -p highland_milk_db < database/06_create_views.sql
   ```

7. **Insert sample data:**
   ```bash
   mysql -u root -p highland_milk_db < database/07_insert_sample_data.sql
   ```

### Alternative: Execute all at once
```bash
cat database/*.sql | mysql -u root -p
```

### Backend Configuration

1. **Configure database connection:**
   Edit `backend/config/database.php`:
   ```php
   define('DB_HOST', 'localhost');
   define('DB_NAME', 'highland_milk_db');
   define('DB_USER', 'root');
   define('DB_PASS', 'your_password');
   ```

2. **Copy files to web server:**
   ```bash
   # For XAMPP
   cp -r backend /xampp/htdocs/highland_milk/
   cp -r frontend /xampp/htdocs/highland_milk/
   
   # For Linux/Apache
   cp -r backend /var/www/html/highland_milk/
   cp -r frontend /var/www/html/highland_milk/
   ```

### Frontend Access

1. Start your web server (Apache/Nginx)
2. Open browser and navigate to:
   ```
   http://localhost/highland_milk/frontend/index.html
   ```

## 📊 Database Schema

### Core Tables

- **FARMER** - Farmer information and bank details
- **MILK_COLLECTION** - Daily milk collection records
- **PRODUCT** - Product catalog
- **INVENTORY** - Stock management
- **CUSTOMER_ORDER** - Customer orders
- **ORDER_LINE** - Order details
- **DELIVERY** - Delivery tracking
- **PAYMENT** - Farmer payments

### Supporting Tables

- **COLLECTION_CENTER** - Milk collection centers
- **WAREHOUSE** - Storage facilities
- **PRODUCT_CATEGORY** - Product categorization
- **CUSTOMER** - Customer information
- **EMPLOYEE** - Staff records
- **DEPARTMENT** - Organizational structure
- **SUPPLIER** - Supplier management

## 🔧 API Endpoints

### Farmers API
```
GET    /backend/api/farmers.php          # Get all farmers
GET    /backend/api/farmers.php?id=1     # Get farmer by ID
POST   /backend/api/farmers.php          # Create new farmer
PUT    /backend/api/farmers.php          # Update farmer
DELETE /backend/api/farmers.php          # Delete farmer
```

### Collections API
```
GET    /backend/api/collections.php      # Get all collections
GET    /backend/api/collections.php?id=1 # Get collection by ID
POST   /backend/api/collections.php      # Record new collection
PUT    /backend/api/collections.php      # Update collection
DELETE /backend/api/collections.php      # Delete collection
```

### Dashboard API
```
GET    /backend/api/dashboard.php        # Get dashboard statistics
```

## 📖 Usage Examples

### Recording Milk Collection

```javascript
const collectionData = {
    farmer_id: 1,
    collection_date: "2026-06-03",
    collection_time: "06:00:00",
    quantity_liters: 25.5,
    fat_percentage: 5.2,
    snf_value: 8.9,
    temperature: 4.5,
    collection_center_id: 1,
    collected_by: 6
};

fetch('backend/api/collections.php', {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify(collectionData)
});
```

### Calculating Farmer Payment

```sql
-- Calculate payment for farmer 1 for May 2026
CALL sp_calculate_farmer_payment(1, 5, 2026, 80.00, 5);
```

### Getting Stock Alerts

```sql
-- Check products needing reorder
CALL sp_stock_reorder_alert();
```

## 📈 Business Intelligence Queries

### Top Farmers Report
```sql
SELECT * FROM vw_milk_collection_performance
WHERE year_month = '2026-06'
ORDER BY total_quantity DESC
LIMIT 10;
```

### Monthly Sales Analysis
```sql
SELECT * FROM vw_monthly_sales_analysis
WHERE year_month = '2026-06'
ORDER BY total_sales_amount DESC;
```

### Stock Status Check
```sql
SELECT * FROM vw_product_stock_status
WHERE stock_status IN ('LOW STOCK', 'EXPIRING SOON');
```

## 🧪 Testing

### 🚀 Quick Test
Visit `TEST_PAGES.html` to quickly access all pages of the application.

### Test Database Functions
```sql
-- Test quality premium calculation
SELECT fn_calculate_quality_premium(5.5, 20, 3.5) as premium;

-- Test farmer performance grade
SELECT fn_farmer_performance_grade(1, 6, 2026) as grade;

-- Test order total calculation
SELECT fn_calculate_order_total(1) as total;
```

### Test Stored Procedures
```sql
-- Generate monthly collection report
CALL sp_monthly_collection_report(6, 2026);

-- Process customer order
SET @order_id = 0;
CALL sp_process_customer_order(1, '2026-06-10', 3, 1, 10, @order_id);
SELECT @order_id;
```

## 🔒 Security Features

- **Prepared statements** to prevent SQL injection
- **Input validation** on all forms
- **Role-based access control** (can be extended)
- **Password hashing** (for user authentication module)
- **Audit trails** with timestamps
- **Data encryption** for sensitive information

## 📱 Browser Support

- Chrome (latest)
- Firefox (latest)
- Safari (latest)
- Edge (latest)
- Mobile browsers (iOS Safari, Chrome Mobile)

## 🐛 Troubleshooting

### Database Connection Issues
```
Error: Connection failed
Solution: Check database credentials in backend/config/database.php
```

### API Not Working
```
Error: 404 Not Found
Solution: Ensure mod_rewrite is enabled in Apache
```

### Chart Not Displaying
```
Error: Chart.js not loading
Solution: Check internet connection (CDN) or download Chart.js locally
```

## 📝 License

This project is developed for educational purposes as part of an Advanced Database Management Systems course.

## 👥 Contributors

- **Student Name:** [Your Name]
- **Registration No:** [Your Reg No]
- **Organization:** Highland Milk Industries PLC
- **Academic Year:** 2025/2026

## 📞 Support


## 🎯 Future Enhancements

- [ ] 📱 Mobile application for farmers
- [ ] 💬 SMS notifications for payments
- [ ] 🗺️ GPS tracking for deliveries
- [ ] 🔬 IoT integration for quality testing
- [ ] 🤖 Machine learning for demand forecasting
- [ ] ⛓️ Blockchain for supply chain transparency
- [ ] 🔐 Advanced authentication system
- [ ] 📧 Email notification system

## 📚 Documentation

Complete project documentation including:
- System architecture
- Database design
- Business rules
- User manual
- Test cases
- BI features

See: `Highland_Milk_ADBMS_Report.md`

---

**Version:** 1.0.0  
**Last Updated:** June 2026  
**Status:** ✅ Production Ready

---

<p align="center">Made with ❤️ for Dairy Farm Management</p>
