/**
 * Milk Processing Center - Farmers Management JavaScript
 */

const API_BASE_URL = '../backend/api';
let farmersTable;

// Load farmers on page load
document.addEventListener('DOMContentLoaded', function() {
    loadFarmers();
});

/**
 * Load all farmers
 */
async function loadFarmers() {
    try {
        const response = await fetch(`${API_BASE_URL}/farmers.php`);
        const result = await response.json();
        
        if (result.success) {
            displayFarmers(result.data);
        } else {
            showAlert('danger', 'Failed to load farmers');
        }
    } catch (error) {
        console.error('Error loading farmers:', error);
        showAlert('danger', 'Error connecting to server');
    }
}

/**
 * Display farmers in DataTable
 */
function displayFarmers(farmers) {
    const tbody = document.querySelector('#farmersTable tbody');
    tbody.innerHTML = '';
    
    if (farmersTable) {
        farmersTable.destroy();
    }
    
    farmers.forEach(farmer => {
        const statusBadge = farmer.status === 'Active' 
            ? '<span class="badge status-active">Active</span>' 
            : '<span class="badge status-inactive">Inactive</span>';
        
        const row = `
            <tr>
                <td>${farmer.farmer_id}</td>
                <td>${farmer.nic_number}</td>
                <td>${farmer.first_name} ${farmer.last_name}</td>
                <td>${farmer.village}</td>
                <td>${farmer.district}</td>
                <td>${farmer.contact_number}</td>
                <td>${farmer.bank_name} - ${farmer.bank_branch}</td>
                <td>${statusBadge}</td>
                <td>
                    <button class="btn btn-sm btn-info" onclick="viewFarmer(${farmer.farmer_id})">
                        <i class="fas fa-eye"></i>
                    </button>
                    <button class="btn btn-sm btn-warning" onclick="editFarmer(${farmer.farmer_id})">
                        <i class="fas fa-edit"></i>
                    </button>
                    <button class="btn btn-sm btn-danger" onclick="deleteFarmer(${farmer.farmer_id})">
                        <i class="fas fa-trash"></i>
                    </button>
                </td>
            </tr>
        `;
        tbody.innerHTML += row;
    });
    
    // Initialize DataTable
    farmersTable = $('#farmersTable').DataTable({
        order: [[0, 'desc']],
        pageLength: 25,
        language: {
            search: "Search Farmers:",
            lengthMenu: "Show _MENU_ farmers per page"
        }
    });
}

/**
 * Open add modal
 */
function openAddModal() {
    document.getElementById('modalTitle').textContent = 'Add New Farmer';
    document.getElementById('farmerForm').reset();
    document.getElementById('farmerId').value = '';
}

/**
 * View farmer details
 */
async function viewFarmer(id) {
    try {
        const response = await fetch(`${API_BASE_URL}/farmers.php?id=${id}`);
        const result = await response.json();
        if (result.success) {
            const f = result.data;
            const statusBadge = f.status === 'Active'
                ? '<span class="badge status-active">Active</span>'
                : '<span class="badge status-inactive">Inactive</span>';
            document.getElementById('viewFarmerBody').innerHTML = `
                <table class="table table-bordered table-sm mb-0">
                    <tr><th style="width:40%">Farmer ID</th><td>#${f.farmer_id}</td></tr>
                    <tr><th>Full Name</th><td>${f.first_name} ${f.last_name}</td></tr>
                    <tr><th>NIC</th><td>${f.nic_number}</td></tr>
                    <tr><th>Address</th><td>${f.address}</td></tr>
                    <tr><th>Village</th><td>${f.village}</td></tr>
                    <tr><th>District</th><td>${f.district}</td></tr>
                    <tr><th>Contact</th><td>${f.contact_number}</td></tr>
                    <tr><th>Email</th><td>${f.email || '<span class="text-muted">N/A</span>'}</td></tr>
                    <tr><th>Bank</th><td>${f.bank_name}</td></tr>
                    <tr><th>Account No.</th><td>${f.bank_account_no}</td></tr>
                    <tr><th>Branch</th><td>${f.bank_branch}</td></tr>
                    <tr><th>Registered</th><td>${f.registration_date}</td></tr>
                    <tr><th>Status</th><td>${statusBadge}</td></tr>
                </table>`;
            new bootstrap.Modal(document.getElementById('viewFarmerModal')).show();
        }
    } catch (error) {
        console.error('Error:', error);
        showAlert('danger', 'Error loading farmer details');
    }
}

/**
 * Edit farmer
 */
async function editFarmer(id) {
    try {
        const response = await fetch(`${API_BASE_URL}/farmers.php?id=${id}`);
        const result = await response.json();
        
        if (result.success) {
            const farmer = result.data;
            document.getElementById('modalTitle').textContent = 'Edit Farmer';
            document.getElementById('farmerId').value = farmer.farmer_id;
            document.getElementById('nicNumber').value = farmer.nic_number;
            document.getElementById('firstName').value = farmer.first_name;
            document.getElementById('lastName').value = farmer.last_name;
            document.getElementById('address').value = farmer.address;
            document.getElementById('village').value = farmer.village;
            document.getElementById('district').value = farmer.district;
            document.getElementById('contactNumber').value = farmer.contact_number;
            document.getElementById('email').value = farmer.email || '';
            document.getElementById('bankName').value = farmer.bank_name;
            document.getElementById('bankAccountNo').value = farmer.bank_account_no;
            document.getElementById('bankBranch').value = farmer.bank_branch;
            document.getElementById('status').value = farmer.status;
            
            const modal = new bootstrap.Modal(document.getElementById('farmerModal'));
            modal.show();
        }
    } catch (error) {
        console.error('Error:', error);
        showAlert('danger', 'Error loading farmer details');
    }
}

/**
 * Save farmer (Create or Update)
 */
async function saveFarmer() {
    const farmerId = document.getElementById('farmerId').value;
    const data = {
        nic_number: document.getElementById('nicNumber').value,
        first_name: document.getElementById('firstName').value,
        last_name: document.getElementById('lastName').value,
        address: document.getElementById('address').value,
        village: document.getElementById('village').value,
        district: document.getElementById('district').value,
        contact_number: document.getElementById('contactNumber').value,
        email: document.getElementById('email').value,
        bank_name: document.getElementById('bankName').value,
        bank_account_no: document.getElementById('bankAccountNo').value,
        bank_branch: document.getElementById('bankBranch').value,
        status: document.getElementById('status').value
    };
    
    try {
        let response;
        if (farmerId) {
            // Update
            data.farmer_id = farmerId;
            response = await fetch(`${API_BASE_URL}/farmers.php`, {
                method: 'PUT',
                headers: {'Content-Type': 'application/json'},
                body: JSON.stringify(data)
            });
        } else {
            // Create
            response = await fetch(`${API_BASE_URL}/farmers.php`, {
                method: 'POST',
                headers: {'Content-Type': 'application/json'},
                body: JSON.stringify(data)
            });
        }
        
        const result = await response.json();
        
        if (result.success) {
            showAlert('success', result.message);
            bootstrap.Modal.getInstance(document.getElementById('farmerModal')).hide();
            loadFarmers();
        } else {
            showAlert('danger', result.message);
        }
    } catch (error) {
        console.error('Error:', error);
        showAlert('danger', 'Error saving farmer');
    }
}

/**
 * Delete farmer
 */
async function deleteFarmer(id) {
    if (!confirm('Are you sure you want to delete this farmer?')) {
        return;
    }
    
    try {
        const response = await fetch(`${API_BASE_URL}/farmers.php`, {
            method: 'DELETE',
            headers: {'Content-Type': 'application/json'},
            body: JSON.stringify({ farmer_id: id })
        });
        
        const result = await response.json();
        
        if (result.success) {
            showAlert('success', result.message);
            loadFarmers();
        } else {
            showAlert('danger', result.message);
        }
    } catch (error) {
        console.error('Error:', error);
        showAlert('danger', 'Error deleting farmer');
    }
}

/**
 * Show alert message
 */
function showAlert(type, message) {
    const alertDiv = document.createElement('div');
    alertDiv.className = `alert alert-${type} alert-dismissible fade show`;
    alertDiv.innerHTML = `
        ${message}
        <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
    `;
    
    const container = document.querySelector('.page-wrapper') || document.body;
    container.insertBefore(alertDiv, container.firstChild);
    
    setTimeout(() => alertDiv.remove(), 5000);
}
