/**
 * Highland Milk Industries - Orders Management JavaScript
 */

const API_BASE_URL = '../backend/api';
let ordersTable;
let productsList = []; // cache for product data

document.addEventListener('DOMContentLoaded', function () {
    loadOrders();
    loadCustomerOptions();
    loadEmployeeOptions();
    loadProductsCache();

    const today = new Date().toISOString().split('T')[0];
    document.getElementById('orderDate').value = today;
    // Default required date = today + 3 days
    const req = new Date();
    req.setDate(req.getDate() + 3);
    document.getElementById('requiredDate').value = req.toISOString().split('T')[0];
});

/**
 * Load all orders
 */
async function loadOrders() {
    try {
        const response = await fetch(`${API_BASE_URL}/orders.php`);
        const result = await response.json();
        if (result.success) {
            displayOrders(result.data);
        } else {
            showAlert('danger', 'Failed to load orders');
        }
    } catch (error) {
        console.error('Error loading orders:', error);
        showAlert('danger', 'Error connecting to server');
    }
}

/**
 * Load customer dropdown
 */
async function loadCustomerOptions() {
    try {
        const response = await fetch(`${API_BASE_URL}/orders.php?customers=1`);
        const result = await response.json();
        if (result.success) {
            const select = document.getElementById('customerId');
            result.data.forEach(c => {
                const opt = document.createElement('option');
                opt.value = c.customer_id;
                opt.textContent = `${c.customer_name} (${c.customer_type})`;
                select.appendChild(opt);
            });
        }
    } catch (e) { console.error(e); }
}

/**
 * Load employee dropdown (processed by)
 */
async function loadEmployeeOptions() {
    try {
        const response = await fetch(`${API_BASE_URL}/orders.php?employees=1`);
        const result = await response.json();
        if (result.success) {
            const select = document.getElementById('processedBy');
            result.data.forEach(e => {
                const opt = document.createElement('option');
                opt.value = e.employee_id;
                opt.textContent = `${e.first_name} ${e.last_name}`;
                select.appendChild(opt);
            });
        }
    } catch (e) { console.error(e); }
}

/**
 * Cache products for order lines
 */
async function loadProductsCache() {
    try {
        const response = await fetch(`${API_BASE_URL}/products.php`);
        const result = await response.json();
        if (result.success) {
            productsList = result.data.filter(p => p.status === 'Active');
        }
    } catch (e) { console.error(e); }
}

/**
 * Display orders in DataTable
 */
function displayOrders(orders) {
    // Destroy existing DataTable instance before touching the DOM
    if (ordersTable) {
        ordersTable.destroy();
        ordersTable = null;
    }

    const tbody = document.querySelector('#ordersTable tbody');
    tbody.innerHTML = '';

    orders.forEach(order => {
        const statusBadges = {
            'Pending':   '<span class="badge status-pending">Pending</span>',
            'Confirmed': '<span class="badge status-confirmed">Confirmed</span>',
            'Delivered': '<span class="badge status-delivered">Delivered</span>',
            'Cancelled': '<span class="badge status-cancelled">Cancelled</span>'
        };
        const statusBadge = statusBadges[order.order_status] || order.order_status;

        const row = document.createElement('tr');
        row.innerHTML = `
            <td>${order.order_id}</td>
            <td>${order.customer_name}<br><small class="text-muted">${order.customer_type}</small></td>
            <td>${order.order_date}</td>
            <td>${order.required_date}</td>
            <td>Rs. ${parseFloat(order.total_amount).toFixed(2)}</td>
            <td>${statusBadge}</td>
            <td>${order.processed_by_name}</td>
            <td>
                <button class="btn btn-sm btn-info" title="View" onclick="viewOrder(${order.order_id})">
                    <i class="fas fa-eye"></i>
                </button>
                <button class="btn btn-sm btn-success" title="Confirm" onclick="updateOrderStatus(${order.order_id}, 'Confirmed')">
                    <i class="fas fa-check"></i>
                </button>
                <button class="btn btn-sm btn-primary" title="Mark Delivered" onclick="updateOrderStatus(${order.order_id}, 'Delivered')">
                    <i class="fas fa-truck"></i>
                </button>
                <button class="btn btn-sm btn-warning" title="Cancel" onclick="updateOrderStatus(${order.order_id}, 'Cancelled')">
                    <i class="fas fa-ban"></i>
                </button>
                <button class="btn btn-sm btn-danger" title="Delete" onclick="deleteOrder(${order.order_id})">
                    <i class="fas fa-trash"></i>
                </button>
            </td>`;
        tbody.appendChild(row);
    });

    ordersTable = $('#ordersTable').DataTable({
        order: [[0, 'desc']],
        pageLength: 25,
        language: {
            search: "Search Orders:",
            lengthMenu: "Show _MENU_ orders per page",
            emptyTable: "No orders found"
        }
    });
}

/**
 * Open add modal — reset form and add one empty line
 */
function openAddModal() {
    document.getElementById('orderForm').reset();
    document.getElementById('orderLinesBody').innerHTML = '';

    const today = new Date().toISOString().split('T')[0];
    document.getElementById('orderDate').value = today;
    const req = new Date();
    req.setDate(req.getDate() + 3);
    document.getElementById('requiredDate').value = req.toISOString().split('T')[0];

    updateTotals();
    addOrderLine(); // start with one empty line
}

/**
 * Add a new order line row
 */
function addOrderLine() {
    const tbody = document.getElementById('orderLinesBody');
    const rowIndex = tbody.rows.length;

    let productOptions = '<option value="">-- Select Product --</option>';
    productsList.forEach(p => {
        productOptions += `<option value="${p.product_id}" data-price="${p.unit_price}">${p.product_name} (${p.unit})</option>`;
    });

    const row = document.createElement('tr');
    row.innerHTML = `
        <td>
            <select class="form-select form-select-sm" onchange="onProductSelect(this, ${rowIndex})">
                ${productOptions}
            </select>
        </td>
        <td>
            <input type="number" class="form-control form-control-sm line-qty" min="0.01" step="0.01"
                value="1" oninput="recalcLine(${rowIndex})" data-row="${rowIndex}">
        </td>
        <td>
            <input type="number" class="form-control form-control-sm line-price" min="0" step="0.01"
                value="0.00" oninput="recalcLine(${rowIndex})" data-row="${rowIndex}">
        </td>
        <td>
            <input type="text" class="form-control form-control-sm line-total" readonly value="0.00">
        </td>
        <td class="text-center">
            <button type="button" class="btn btn-sm btn-danger" onclick="removeOrderLine(this)">
                <i class="fas fa-times"></i>
            </button>
        </td>`;
    tbody.appendChild(row);
}

/**
 * When a product is selected — auto-fill unit price
 */
function onProductSelect(selectEl, rowIndex) {
    const selected = selectEl.options[selectEl.selectedIndex];
    const price = selected.dataset.price || 0;
    const row = selectEl.closest('tr');
    row.querySelector('.line-price').value = parseFloat(price).toFixed(2);
    recalcLine(rowIndex);
}

/**
 * Recalculate a single line total
 */
function recalcLine(rowIndex) {
    const tbody = document.getElementById('orderLinesBody');
    const rows = tbody.rows;
    // find the correct row by index (rowIndex may shift after deletions, use data-row)
    for (let row of rows) {
        const qtyInput = row.querySelector('.line-qty');
        if (qtyInput && parseInt(qtyInput.dataset.row) === rowIndex) {
            const qty = parseFloat(qtyInput.value) || 0;
            const price = parseFloat(row.querySelector('.line-price').value) || 0;
            row.querySelector('.line-total').value = (qty * price).toFixed(2);
            break;
        }
    }
    updateTotals();
}

/**
 * Remove an order line row
 */
function removeOrderLine(btn) {
    btn.closest('tr').remove();
    updateTotals();
}

/**
 * Update subtotal / tax / total display
 */
function updateTotals() {
    let subtotal = 0;
    document.querySelectorAll('.line-total').forEach(el => {
        subtotal += parseFloat(el.value) || 0;
    });
    const tax = subtotal * 0.08;
    const total = subtotal + tax;

    document.getElementById('subtotalDisplay').textContent = `Rs. ${subtotal.toFixed(2)}`;
    document.getElementById('taxDisplay').textContent = `Rs. ${tax.toFixed(2)}`;
    document.getElementById('totalDisplay').innerHTML = `<strong>Rs. ${total.toFixed(2)}</strong>`;
}

/**
 * Save new order
 */
async function saveOrder() {
    const customerId = document.getElementById('customerId').value;
    const orderDate = document.getElementById('orderDate').value;
    const requiredDate = document.getElementById('requiredDate').value;
    const processedBy = document.getElementById('processedBy').value;
    const remarks = document.getElementById('orderRemarks').value;

    if (!customerId || !orderDate || !requiredDate || !processedBy) {
        showAlert('warning', 'Please fill in all required fields');
        return;
    }

    // Collect order lines
    const lines = [];
    const rows = document.getElementById('orderLinesBody').rows;
    for (let row of rows) {
        const productSelect = row.querySelector('select');
        const qty = parseFloat(row.querySelector('.line-qty').value) || 0;
        const price = parseFloat(row.querySelector('.line-price').value) || 0;
        if (!productSelect.value || qty <= 0) continue;
        lines.push({
            product_id: parseInt(productSelect.value),
            quantity: qty,
            unit_price: price,
            line_total: parseFloat((qty * price).toFixed(2))
        });
    }

    if (lines.length === 0) {
        showAlert('warning', 'Please add at least one order item');
        return;
    }

    const subtotal = lines.reduce((sum, l) => sum + l.line_total, 0);
    const taxAmount = parseFloat((subtotal * 0.08).toFixed(2));
    const totalAmount = parseFloat((subtotal + taxAmount).toFixed(2));

    const data = {
        customer_id: parseInt(customerId),
        order_date: orderDate,
        required_date: requiredDate,
        order_status: 'Pending',
        subtotal: parseFloat(subtotal.toFixed(2)),
        tax_amount: taxAmount,
        total_amount: totalAmount,
        processed_by: parseInt(processedBy),
        remarks: remarks,
        order_lines: lines
    };

    try {
        const response = await fetch(`${API_BASE_URL}/orders.php`, {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify(data)
        });
        const result = await response.json();
        if (result.success) {
            showAlert('success', result.message);
            bootstrap.Modal.getInstance(document.getElementById('orderModal')).hide();
            loadOrders();
        } else {
            showAlert('danger', result.message);
        }
    } catch (error) {
        console.error('Error:', error);
        showAlert('danger', 'Error saving order');
    }
}

/**
 * View order details
 */
async function viewOrder(id) {
    try {
        const response = await fetch(`${API_BASE_URL}/orders.php?id=${id}`);
        const result = await response.json();
        if (result.success) {
            const o = result.data;
            const statusBadges = {
                'Pending':   '<span class="badge status-pending">Pending</span>',
                'Confirmed': '<span class="badge status-confirmed">Confirmed</span>',
                'Delivered': '<span class="badge status-delivered">Delivered</span>',
                'Cancelled': '<span class="badge status-cancelled">Cancelled</span>'
            };

            let linesHtml = '';
            o.order_lines.forEach((line, i) => {
                linesHtml += `<tr>
                    <td>${i + 1}</td>
                    <td>${line.product_name} <small class="text-muted">(${line.unit})</small></td>
                    <td>${parseFloat(line.quantity).toFixed(2)}</td>
                    <td>Rs. ${parseFloat(line.unit_price).toFixed(2)}</td>
                    <td>Rs. ${parseFloat(line.line_total).toFixed(2)}</td>
                </tr>`;
            });

            document.getElementById('viewOrderBody').innerHTML = `
                <div class="row mb-3">
                    <div class="col-md-6">
                        <table class="table table-sm table-bordered">
                            <tr><th>Order ID</th><td>#${o.order_id}</td></tr>
                            <tr><th>Customer</th><td>${o.customer_name}</td></tr>
                            <tr><th>Type</th><td>${o.customer_type}</td></tr>
                            <tr><th>Contact</th><td>${o.customer_contact}</td></tr>
                        </table>
                    </div>
                    <div class="col-md-6">
                        <table class="table table-sm table-bordered">
                            <tr><th>Order Date</th><td>${o.order_date}</td></tr>
                            <tr><th>Required Date</th><td>${o.required_date}</td></tr>
                            <tr><th>Status</th><td>${statusBadges[o.order_status] || o.order_status}</td></tr>
                            <tr><th>Processed By</th><td>${o.processed_by_name}</td></tr>
                        </table>
                    </div>
                </div>
                <h6>Order Items</h6>
                <table class="table table-sm table-striped table-bordered">
                    <thead><tr><th>#</th><th>Product</th><th>Qty</th><th>Unit Price</th><th>Total</th></tr></thead>
                    <tbody>${linesHtml}</tbody>
                </table>
                <div class="row justify-content-end">
                    <div class="col-md-4">
                        <table class="table table-sm">
                            <tr><td class="text-end">Subtotal:</td><td class="text-end">Rs. ${parseFloat(o.subtotal).toFixed(2)}</td></tr>
                            <tr><td class="text-end">Tax:</td><td class="text-end">Rs. ${parseFloat(o.tax_amount).toFixed(2)}</td></tr>
                            <tr class="table-success fw-bold"><td class="text-end">Total:</td><td class="text-end">Rs. ${parseFloat(o.total_amount).toFixed(2)}</td></tr>
                        </table>
                    </div>
                </div>
                ${o.remarks ? `<p class="text-muted"><strong>Remarks:</strong> ${o.remarks}</p>` : ''}`;

            new bootstrap.Modal(document.getElementById('viewOrderModal')).show();
        }
    } catch (error) {
        console.error('Error:', error);
        showAlert('danger', 'Error loading order details');
    }
}

/**
 * Update order status
 */
async function updateOrderStatus(id, status) {
    if (!confirm(`Change this order status to "${status}"?`)) return;

    try {
        const response = await fetch(`${API_BASE_URL}/orders.php`, {
            method: 'PUT',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({ order_id: id, order_status: status, remarks: '' })
        });
        const result = await response.json();
        if (result.success) {
            showAlert('success', result.message);
            loadOrders();
        } else {
            showAlert('danger', result.message);
        }
    } catch (error) {
        console.error('Error:', error);
        showAlert('danger', 'Error updating order status');
    }
}

/**
 * Delete order
 */
async function deleteOrder(id) {
    if (!confirm('Are you sure you want to delete this order? This cannot be undone.')) return;

    try {
        const response = await fetch(`${API_BASE_URL}/orders.php`, {
            method: 'DELETE',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({ order_id: id })
        });
        const result = await response.json();
        if (result.success) {
            showAlert('success', result.message);
            loadOrders();
        } else {
            showAlert('danger', result.message);
        }
    } catch (error) {
        console.error('Error:', error);
        showAlert('danger', 'Error deleting order');
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
