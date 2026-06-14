# Milk Processing Center - Management System

A web-based management system for dairy milk processing operations built with PHP, MySQL, and Bootstrap 5.

## Features

- Dashboard with live statistics and charts
- Farmers management (CRUD)
- Milk collections management (CRUD)
- Products management (CRUD)
- Orders management (CRUD)
- Business intelligence reports with CSV export

## Tech Stack

- Frontend: HTML, CSS, Bootstrap 5, JavaScript, Chart.js, DataTables
- Backend: PHP 7.4+
- Database: MySQL 8.0+
- Server: XAMPP (Apache)

## Requirements

- XAMPP or any Apache + PHP server
- MySQL 8.0+
- MySQL Workbench (recommended)

## Setup

1. Clone the repository into your XAMPP htdocs folder:
   ```
   git clone https://github.com/mpkumar04/milk_processing_center.git
   ```

2. Open MySQL Workbench and run the SQL scripts in order:
   ```
   database/01_create_database.sql
   database/02_create_tables.sql
   database/03_create_triggers.sql
   database/04_create_functions.sql
   database/05_create_procedures.sql
   database/06_create_views.sql
   database/07_insert_sample_data.sql
   database/08_additional_sample_data.sql
   ```

3. Update the database password in `backend/config/database.php`:
   ```php
   define('DB_PASS', 'your_password');
   ```

4. Start Apache in XAMPP Control Panel.

5. Open in browser:
   ```
   http://localhost/milk_processing_center/frontend/index.html
   ```
   Or if Apache is on port 8080:
   ```
   http://localhost:8080/milk_processing_center/frontend/index.html
   ```

## Project Structure

```
milk_processing_center/
├── backend/
│   ├── api/          # PHP REST API endpoints
│   └── config/       # Database configuration
├── database/         # SQL scripts
└── frontend/
    ├── css/          # Stylesheets
    ├── js/           # JavaScript files
    └── *.html        # HTML pages
```

## Pages

| Page | Description |
|------|-------------|
| index.html | Dashboard |
| farmers.html | Farmer management |
| collections.html | Milk collection records |
| products.html | Product catalog |
| orders.html | Customer orders |
| reports.html | Reports and analytics |
