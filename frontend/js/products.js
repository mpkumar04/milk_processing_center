/**
 * Highland Milk Industries - Products Management JavaScript
 */

const API_BASE_URL = '../backend/api';
let productsTable;

document.addEventListener('DOMContentLoaded', function () {
    loadProducts();
    loadCategoryOptions();
});

/**
 * Load all products
 */
async function loadProducts() {
    try {
        const response = await fetch(`${API_BASE_URL}/products.php`);
        const result = await response.json();
        if (result.success) {
            displayProducts(result.data);
        } else {
            showAlert('danger', 'Failed to load products');
        }
    } catch (error) {
        console.error('Error loading products:', error);
        showAlert('danger', 'Error connecting to server');
    }
}

/**
 * Load category dropdown options
 */
async function loadCategoryOptions() {
    try {
        const response = await fetch(`${API_BASE_URL}/products.php?categories=1`);
        const result = await response.json();
        if (result.success) {
            const select = document.getElementById('categoryId');
            result.data.forEach(c => {
                const opt = document.createElement('option');
                opt.value = c.category_id;
                opt.textContent = c.category_name;
                select.appendChild(opt);
            });
        }
    } catch (e) { console.error(e); }
}

/**
 * Display products in DataTable
 */
function displayProducts(products) {
    // Destroy existing DataTable instance before touching the DOM
    if (productsTable) {
        productsTable.destroy();
        productsTable = null;
    }

    const tbody = document.querySelector('#productsTable tbody');
    tbody.innerHTML = '';

    products.forEach(product => {
        const statusBadge = product.status === 'Active'
            ? '<span class="badge status-active">Active</span>'
            : '<span class="badge bg-secondary">Discontinued</span>';

        const row = document.createElement('tr');
        row.innerHTML = `
            <td>${product.product_id}</td>
            <td>${product.product_code}</td>
            <td>${product.product_name}</td>
            <td>${product.category_name}</td>
            <td>${product.unit}</td>
            <td>Rs. ${parseFloat(product.unit_price).toFixed(2)}</td>
            <td>${product.shelf_life_days} days</td>
            <td>${statusBadge}</td>
            <td>
                <button class="btn btn-sm btn-info" title="View" onclick="viewProduct(${product.product_id})">
                    <i class="fas fa-eye"></i>
                </button>
                <button class="btn btn-sm btn-warning" title="Edit" onclick="editProduct(${product.product_id})">
                    <i class="fas fa-edit"></i>
                </button>
                <button class="btn btn-sm btn-danger" title="Delete" onclick="deleteProduct(${product.product_id})">
                    <i class="fas fa-trash"></i>
                </button>
            </td>`;
        tbody.appendChild(row);
    });

    productsTable = $('#productsTable').DataTable({
        order: [[0, 'desc']],
        pageLength: 25,
        language: {
            search: "Search Products:",
            lengthMenu: "Show _MENU_ products per page",
            emptyTable: "No products found"
        }
    });
}

/**
 * Open add modal (clear form)
 */
function openAddModal() {
    document.getElementById('productModalTitle').textContent = 'Add New Product';
    document.getElementById('productForm').reset();
    document.getElementById('productId').value = '';
}

/**
 * View product details
 */
async function viewProduct(id) {
    try {
        const response = await fetch(`${API_BASE_URL}/products.php?id=${id}`);
        const result = await response.json();
        if (result.success) {
            const p = result.data;
            const statusBadge = p.status === 'Active'
                ? '<span class="badge status-active">Active</span>'
                : '<span class="badge bg-secondary">Discontinued</span>';
            document.getElementById('viewProductBody').innerHTML = `
                <table class="table table-bordered">
                    <tr><th>ID</th><td>${p.product_id}</td></tr>
                    <tr><th>Code</th><td>${p.product_code}</td></tr>
                    <tr><th>Name</th><td>${p.product_name}</td></tr>
                    <tr><th>Category</th><td>${p.category_name}</td></tr>
                    <tr><th>Description</th><td>${p.description || 'N/A'}</td></tr>
                    <tr><th>Unit</th><td>${p.unit}</td></tr>
                    <tr><th>Price</th><td>Rs. ${parseFloat(p.unit_price).toFixed(2)}</td></tr>
                    <tr><th>Shelf Life</th><td>${p.shelf_life_days} days</td></tr>
                    <tr><th>Status</th><td>${statusBadge}</td></tr>
                </table>`;
            new bootstrap.Modal(document.getElementById('viewProductModal')).show();
        }
    } catch (error) {
        console.error('Error:', error);
        showAlert('danger', 'Error loading product details');
    }
}

/**
 * Edit product — populate modal
 */
async function editProduct(id) {
    try {
        const response = await fetch(`${API_BASE_URL}/products.php?id=${id}`);
        const result = await response.json();
        if (result.success) {
            const p = result.data;
            document.getElementById('productModalTitle').textContent = 'Edit Product';
            document.getElementById('productId').value = p.product_id;
            document.getElementById('productCode').value = p.product_code;
            document.getElementById('productName').value = p.product_name;
            document.getElementById('productDescription').value = p.description || '';
            document.getElementById('categoryId').value = p.category_id;
            document.getElementById('productUnit').value = p.unit;
            document.getElementById('unitPrice').value = p.unit_price;
            document.getElementById('shelfLifeDays').value = p.shelf_life_days;
            document.getElementById('productStatus').value = p.status;
            new bootstrap.Modal(document.getElementById('productModal')).show();
        }
    } catch (error) {
        console.error('Error:', error);
        showAlert('danger', 'Error loading product details');
    }
}

/**
 * Save product (Create or Update)
 */
async function saveProduct() {
    const productId = document.getElementById('productId').value;
    const data = {
        product_code: document.getElementById('productCode').value.trim(),
        product_name: document.getElementById('productName').value.trim(),
        description: document.getElementById('productDescription').value.trim(),
        category_id: document.getElementById('categoryId').value,
        unit: document.getElementById('productUnit').value,
        unit_price: document.getElementById('unitPrice').value,
        shelf_life_days: document.getElementById('shelfLifeDays').value,
        status: document.getElementById('productStatus').value
    };

    if (!data.product_code || !data.product_name || !data.category_id || !data.unit_price || !data.shelf_life_days) {
        showAlert('warning', 'Please fill in all required fields');
        return;
    }

    try {
        let response;
        if (productId) {
            data.product_id = productId;
            response = await fetch(`${API_BASE_URL}/products.php`, {
                method: 'PUT',
                headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify(data)
            });
        } else {
            response = await fetch(`${API_BASE_URL}/products.php`, {
                method: 'POST',
                headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify(data)
            });
        }

        const result = await response.json();
        if (result.success) {
            showAlert('success', result.message);
            bootstrap.Modal.getInstance(document.getElementById('productModal')).hide();
            loadProducts();
        } else {
            showAlert('danger', result.message);
        }
    } catch (error) {
        console.error('Error:', error);
        showAlert('danger', 'Error saving product');
    }
}

/**
 * Delete product
 */
async function deleteProduct(id) {
    if (!confirm('Are you sure you want to delete this product?')) return;

    try {
        const response = await fetch(`${API_BASE_URL}/products.php`, {
            method: 'DELETE',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({ product_id: id })
        });
        const result = await response.json();
        if (result.success) {
            showAlert('success', result.message);
            loadProducts();
        } else {
            showAlert('danger', result.message);
        }
    } catch (error) {
        console.error('Error:', error);
        showAlert('danger', 'Error deleting product');
    }
}

/**
 * Show alert message
 */
function showAlert(type, message) {
    const alertDiv = document.createElement('div');
    alertDiv.className = `alert alert-${type} alert-dismissible fade show`;
    alertDiv.innerHTML = `${message}<button type="button" class="btn-close" data-bs-dismiss="alert"></button>`;
    const container = document.querySelector('.page-wrapper') || document.body;
    container.insertBefore(alertDiv, container.firstChild);
    setTimeout(() => alertDiv.remove(), 5000);
}
