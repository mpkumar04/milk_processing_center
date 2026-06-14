/**
 * Milk Processing Center - Collections Management JavaScript
 */

const API_BASE_URL = '../backend/api';
let collectionsTable;

// Load collections and dropdowns on page load
document.addEventListener('DOMContentLoaded', function () {
    loadCollections();
    loadFarmerOptions();
    loadCenterOptions();
    loadEmployeeOptions();
    // Set default date/time
    const now = new Date();
    document.getElementById('collectionDate').value = now.toISOString().split('T')[0];
    document.getElementById('collectionTime').value = now.toTimeString().slice(0, 5);
});

/**
 * Load all collections
 */
async function loadCollections() {
    try {
        const response = await fetch(`${API_BASE_URL}/collections.php`);
        const result = await response.json();
        if (result.success) {
            displayCollections(result.data);
        } else {
            showAlert('danger', 'Failed to load collections');
        }
    } catch (error) {
        console.error('Error loading collections:', error);
        showAlert('danger', 'Error connecting to server');
    }
}

/**
 * Load farmer dropdown options
 */
async function loadFarmerOptions() {
    try {
        const response = await fetch(`${API_BASE_URL}/farmers.php`);
        const result = await response.json();
        if (result.success) {
            const select = document.getElementById('farmerId');
            result.data.forEach(f => {
                if (f.status === 'Active') {
                    const opt = document.createElement('option');
                    opt.value = f.farmer_id;
                    opt.textContent = `${f.first_name} ${f.last_name} (${f.nic_number})`;
                    select.appendChild(opt);
                }
            });
        }
    } catch (e) { console.error(e); }
}

/**
 * Load collection center dropdown options
 */
async function loadCenterOptions() {
    try {
        const response = await fetch(`${API_BASE_URL}/collections.php?centers=1`);
        const result = await response.json();
        if (result.success) {
            const select = document.getElementById('collectionCenterId');
            result.data.forEach(c => {
                const opt = document.createElement('option');
                opt.value = c.center_id;
                opt.textContent = c.center_name;
                select.appendChild(opt);
            });
        }
    } catch (e) { console.error(e); }
}

/**
 * Load employee dropdown options
 */
async function loadEmployeeOptions() {
    try {
        const response = await fetch(`${API_BASE_URL}/collections.php?employees=1`);
        const result = await response.json();
        if (result.success) {
            const select = document.getElementById('collectedBy');
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
 * Display collections in DataTable
 */
function displayCollections(collections) {
    // Destroy existing DataTable instance before touching the DOM
    if (collectionsTable) {
        collectionsTable.destroy();
        collectionsTable = null;
    }

    const tbody = document.querySelector('#collectionsTable tbody');
    tbody.innerHTML = '';

    collections.forEach(collection => {
        const gradeBadge = `<span class="badge badge-grade-${collection.quality_grade}">${collection.quality_grade}</span>`;
        const row = document.createElement('tr');
        row.innerHTML = `
            <td>${collection.collection_id}</td>
            <td>${collection.farmer_name}</td>
            <td>${collection.collection_date}</td>
            <td>${collection.collection_time}</td>
            <td>${parseFloat(collection.quantity_liters).toFixed(2)}</td>
            <td>${parseFloat(collection.fat_percentage).toFixed(2)}%</td>
            <td>${parseFloat(collection.snf_value).toFixed(2)}</td>
            <td>${parseFloat(collection.temperature).toFixed(1)}°C</td>
            <td>${gradeBadge}</td>
            <td>${collection.center_name}</td>
            <td>
                <button class="btn btn-sm btn-info" title="View" onclick="viewCollection(${collection.collection_id})">
                    <i class="fas fa-eye"></i>
                </button>
                <button class="btn btn-sm btn-warning" title="Edit" onclick="editCollection(${collection.collection_id})">
                    <i class="fas fa-edit"></i>
                </button>
                <button class="btn btn-sm btn-danger" title="Delete" onclick="deleteCollection(${collection.collection_id})">
                    <i class="fas fa-trash"></i>
                </button>
            </td>`;
        tbody.appendChild(row);
    });

    collectionsTable = $('#collectionsTable').DataTable({
        order: [[0, 'desc']],
        pageLength: 25,
        language: {
            search: "Search Collections:",
            lengthMenu: "Show _MENU_ collections per page",
            emptyTable: "No collections found"
        }
    });
}

/**
 * Open add modal (clear form)
 */
function openAddModal() {
    document.getElementById('collectionModalTitle').textContent = 'Add New Collection';
    document.getElementById('collectionForm').reset();
    document.getElementById('collectionId').value = '';
    const now = new Date();
    document.getElementById('collectionDate').value = now.toISOString().split('T')[0];
    document.getElementById('collectionTime').value = now.toTimeString().slice(0, 5);
}

/**
 * View collection details
 */
async function viewCollection(id) {
    try {
        const response = await fetch(`${API_BASE_URL}/collections.php?id=${id}`);
        const result = await response.json();
        if (result.success) {
            const c = result.data;
            document.getElementById('viewCollectionBody').innerHTML = `
                <table class="table table-bordered">
                    <tr><th>ID</th><td>${c.collection_id}</td></tr>
                    <tr><th>Farmer</th><td>${c.farmer_name}</td></tr>
                    <tr><th>Date</th><td>${c.collection_date}</td></tr>
                    <tr><th>Time</th><td>${c.collection_time}</td></tr>
                    <tr><th>Quantity</th><td>${parseFloat(c.quantity_liters).toFixed(2)} Liters</td></tr>
                    <tr><th>Fat %</th><td>${parseFloat(c.fat_percentage).toFixed(2)}%</td></tr>
                    <tr><th>SNF</th><td>${parseFloat(c.snf_value).toFixed(2)}</td></tr>
                    <tr><th>Temperature</th><td>${parseFloat(c.temperature).toFixed(1)}°C</td></tr>
                    <tr><th>Grade</th><td><span class="badge badge-grade-${c.quality_grade}">${c.quality_grade}</span></td></tr>
                    <tr><th>Center</th><td>${c.center_name}</td></tr>
                    <tr><th>Collected By</th><td>${c.collector_name}</td></tr>
                    <tr><th>Remarks</th><td>${c.remarks || 'N/A'}</td></tr>
                </table>`;
            new bootstrap.Modal(document.getElementById('viewCollectionModal')).show();
        }
    } catch (error) {
        console.error('Error:', error);
        showAlert('danger', 'Error loading collection details');
    }
}

/**
 * Edit collection — populate modal
 */
async function editCollection(id) {
    try {
        const response = await fetch(`${API_BASE_URL}/collections.php?id=${id}`);
        const result = await response.json();
        if (result.success) {
            const c = result.data;
            document.getElementById('collectionModalTitle').textContent = 'Edit Collection';
            document.getElementById('collectionId').value = c.collection_id;
            document.getElementById('farmerId').value = c.farmer_id;
            document.getElementById('collectionCenterId').value = c.collection_center_id;
            document.getElementById('collectionDate').value = c.collection_date;
            document.getElementById('collectionTime').value = c.collection_time;
            document.getElementById('quantityLiters').value = c.quantity_liters;
            document.getElementById('fatPercentage').value = c.fat_percentage;
            document.getElementById('snfValue').value = c.snf_value;
            document.getElementById('temperature').value = c.temperature;
            document.getElementById('qualityGrade').value = c.quality_grade;
            document.getElementById('collectedBy').value = c.collected_by;
            document.getElementById('remarks').value = c.remarks || '';
            new bootstrap.Modal(document.getElementById('collectionModal')).show();
        }
    } catch (error) {
        console.error('Error:', error);
        showAlert('danger', 'Error loading collection details');
    }
}

/**
 * Save collection (Create or Update)
 */
async function saveCollection() {
    const collectionId = document.getElementById('collectionId').value;
    const data = {
        farmer_id: document.getElementById('farmerId').value,
        collection_center_id: document.getElementById('collectionCenterId').value,
        collection_date: document.getElementById('collectionDate').value,
        collection_time: document.getElementById('collectionTime').value,
        quantity_liters: document.getElementById('quantityLiters').value,
        fat_percentage: document.getElementById('fatPercentage').value,
        snf_value: document.getElementById('snfValue').value,
        temperature: document.getElementById('temperature').value,
        quality_grade: document.getElementById('qualityGrade').value,
        collected_by: document.getElementById('collectedBy').value,
        remarks: document.getElementById('remarks').value
    };

    // Basic validation
    if (!data.farmer_id || !data.collection_center_id || !data.collection_date ||
        !data.quantity_liters || !data.fat_percentage || !data.snf_value ||
        !data.temperature || !data.collected_by) {
        showAlert('warning', 'Please fill in all required fields');
        return;
    }

    try {
        let response;
        if (collectionId) {
            data.collection_id = collectionId;
            response = await fetch(`${API_BASE_URL}/collections.php`, {
                method: 'PUT',
                headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify(data)
            });
        } else {
            response = await fetch(`${API_BASE_URL}/collections.php`, {
                method: 'POST',
                headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify(data)
            });
        }

        const result = await response.json();
        if (result.success) {
            showAlert('success', result.message);
            bootstrap.Modal.getInstance(document.getElementById('collectionModal')).hide();
            loadCollections();
        } else {
            showAlert('danger', result.message);
        }
    } catch (error) {
        console.error('Error:', error);
        showAlert('danger', 'Error saving collection');
    }
}

/**
 * Delete collection
 */
async function deleteCollection(id) {
    if (!confirm('Are you sure you want to delete this collection record?')) return;

    try {
        const response = await fetch(`${API_BASE_URL}/collections.php`, {
            method: 'DELETE',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({ collection_id: id })
        });
        const result = await response.json();
        if (result.success) {
            showAlert('success', result.message);
            loadCollections();
        } else {
            showAlert('danger', result.message);
        }
    } catch (error) {
        console.error('Error:', error);
        showAlert('danger', 'Error deleting collection');
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
