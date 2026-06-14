/**
 * Highland Milk Industries - Reports JavaScript
 */

const API_BASE_URL = '../backend/api';
let currentReportData = null;
let trendChart = null;
let distributionChart = null;

// Set default dates on page load
document.addEventListener('DOMContentLoaded', function () {
    const today = new Date();
    // Default: last 30 days so data is likely to appear
    const thirtyDaysAgo = new Date();
    thirtyDaysAgo.setDate(today.getDate() - 30);

    document.getElementById('startDate').value = thirtyDaysAgo.toISOString().split('T')[0];
    document.getElementById('endDate').value = today.toISOString().split('T')[0];
});

/**
 * Generate report
 */
async function generateReport() {
    const reportType = document.getElementById('reportType').value;
    const startDate  = document.getElementById('startDate').value;
    const endDate    = document.getElementById('endDate').value;

    if (!startDate || !endDate) {
        showAlert('danger', 'Please select start and end dates');
        return;
    }
    if (startDate > endDate) {
        showAlert('danger', 'Start date cannot be after end date');
        return;
    }

    // Show loading
    const content = document.getElementById('reportContent');
    content.innerHTML = `
        <div class="text-center py-5">
            <div class="spinner-border text-primary" role="status"></div>
            <p class="mt-3 text-muted">Generating report...</p>
        </div>`;

    // Clear old charts
    destroyCharts();

    try {
        const url = `${API_BASE_URL}/reports.php?type=${encodeURIComponent(reportType)}&start_date=${startDate}&end_date=${endDate}`;
        const response = await fetch(url);

        // Check HTTP status first
        if (!response.ok) {
            const text = await response.text();
            throw new Error(`Server returned ${response.status}: ${text.substring(0, 200)}`);
        }

        const result = await response.json();

        if (result.success) {
            currentReportData = result;
            displayReport(result);
            updateCharts(result);
        } else {
            content.innerHTML = `<div class="alert alert-danger"><strong>Report Error:</strong> ${result.message || 'Unknown error'}</div>`;
        }
    } catch (error) {
        console.error('Report error:', error);
        content.innerHTML = `
            <div class="alert alert-danger">
                <strong>Connection Error:</strong> ${error.message}<br>
                <small>Check that Apache is running and the database is connected.</small>
            </div>`;
    }
}

/**
 * Display report table
 */
function displayReport(report) {
    const content = document.getElementById('reportContent');
    const title   = getReportTitle(report.report_type);

    let html = `
        <div class="d-flex justify-content-between align-items-center mb-3">
            <h5 class="mb-0">${title}</h5>
            <span class="badge bg-secondary">Period: ${report.period.start} &rarr; ${report.period.end}</span>
        </div>`;

    if (!report.data || report.data.length === 0) {
        html += `<div class="alert alert-info">
                    <i class="fas fa-info-circle"></i>
                    No data found for the selected period. Try widening your date range.
                 </div>`;
        content.innerHTML = html;
        return;
    }

    // Summary cards for revenue report
    if (report.totals) {
        html += `
            <div class="row mb-4">
                <div class="col-md-4">
                    <div class="card bg-primary text-white text-center">
                        <div class="card-body py-3">
                            <h6>Total Orders</h6>
                            <h3>${report.totals.total_orders}</h3>
                        </div>
                    </div>
                </div>
                <div class="col-md-4">
                    <div class="card bg-success text-white text-center">
                        <div class="card-body py-3">
                            <h6>Total Revenue</h6>
                            <h3>Rs. ${parseFloat(report.totals.total_revenue).toLocaleString('en-US', {minimumFractionDigits:2})}</h3>
                        </div>
                    </div>
                </div>
                <div class="col-md-4">
                    <div class="card bg-info text-white text-center">
                        <div class="card-body py-3">
                            <h6>Total Tax</h6>
                            <h3>Rs. ${parseFloat(report.totals.total_tax).toLocaleString('en-US', {minimumFractionDigits:2})}</h3>
                        </div>
                    </div>
                </div>
            </div>`;
    }

    // Data table
    html += '<div class="table-responsive"><table class="table table-sm table-striped table-hover table-bordered">';
    html += '<thead class="table-dark"><tr>';
    Object.keys(report.data[0]).forEach(key => {
        html += `<th>${formatColumnName(key)}</th>`;
    });
    html += '</tr></thead><tbody>';

    report.data.forEach(row => {
        html += '<tr>';
        Object.entries(row).forEach(([key, value]) => {
            if (value === null || value === undefined) {
                html += '<td><span class="text-muted">-</span></td>';
            } else if (key.includes('revenue') || key.includes('amount') || key.includes('price') || key.includes('subtotal') || key.includes('tax')) {
                html += `<td>Rs. ${parseFloat(value).toLocaleString('en-US', {minimumFractionDigits:2})}</td>`;
            } else if (key.includes('percentage') || key.includes('fat')) {
                html += `<td>${parseFloat(value).toFixed(2)}%</td>`;
            } else if (key.includes('quantity') || key.includes('avg_')) {
                html += `<td>${parseFloat(value).toFixed(2)}</td>`;
            } else {
                html += `<td>${value}</td>`;
            }
        });
        html += '</tr>';
    });

    html += '</tbody></table></div>';
    html += `<p class="text-muted small mt-2"><i class="fas fa-table"></i> ${report.data.length} record(s) found</p>`;

    content.innerHTML = html;
}

/**
 * Destroy existing charts safely
 */
function destroyCharts() {
    if (trendChart) {
        trendChart.destroy();
        trendChart = null;
    }
    if (distributionChart) {
        distributionChart.destroy();
        distributionChart = null;
    }
}

/**
 * Update charts
 */
function updateCharts(report) {
    const data = report.data;
    if (!data || data.length === 0) return;

    // ---- Trend Chart ----
    const trendCtx = document.getElementById('trendChart').getContext('2d');
    let trendLabels = [];
    let trendValues = [];

    switch (report.report_type) {
        case 'farmer_performance':
            trendLabels = data.slice(0, 10).map(d => d.farmer_name);
            trendValues = data.slice(0, 10).map(d => parseFloat(d.total_quantity) || 0);
            break;
        case 'collection_summary':
            trendLabels = data.map(d => d.collection_date).reverse();
            trendValues = data.map(d => parseFloat(d.total_quantity) || 0).reverse();
            break;
        case 'product_sales':
            trendLabels = data.slice(0, 10).map(d => d.product_name);
            trendValues = data.slice(0, 10).map(d => parseFloat(d.total_revenue) || 0);
            break;
        case 'revenue_report':
            trendLabels = data.map(d => d.order_date).reverse();
            trendValues = data.map(d => parseFloat(d.total_revenue) || 0).reverse();
            break;
    }

    trendChart = new Chart(trendCtx, {
        type: report.report_type === 'farmer_performance' || report.report_type === 'product_sales' ? 'bar' : 'line',
        data: {
            labels: trendLabels,
            datasets: [{
                label: getTrendLabel(report.report_type),
                data: trendValues,
                borderColor: 'rgb(13, 110, 253)',
                backgroundColor: 'rgba(13, 110, 253, 0.6)',
                tension: 0.4,
                fill: true
            }]
        },
        options: {
            responsive: true,
            maintainAspectRatio: false,
            plugins: { legend: { position: 'top' } },
            scales: {
                y: { beginAtZero: true }
            }
        }
    });

    // ---- Distribution Chart ----
    const distCtx = document.getElementById('distributionChart').getContext('2d');
    let distLabels = [];
    let distValues = [];

    switch (report.report_type) {
        case 'farmer_performance':
            distLabels = data.slice(0, 6).map(d => d.farmer_name);
            distValues = data.slice(0, 6).map(d => parseFloat(d.total_quantity) || 0);
            break;
        case 'collection_summary': {
            // Sum grade totals across all days
            const gradeA = data.reduce((s, d) => s + (parseInt(d.grade_a) || 0), 0);
            const gradeB = data.reduce((s, d) => s + (parseInt(d.grade_b) || 0), 0);
            const gradeC = data.reduce((s, d) => s + (parseInt(d.grade_c) || 0), 0);
            distLabels = ['Grade A', 'Grade B', 'Grade C'];
            distValues = [gradeA, gradeB, gradeC];
            break;
        }
        case 'product_sales':
            distLabels = data.slice(0, 6).map(d => d.product_name);
            distValues = data.slice(0, 6).map(d => parseFloat(d.total_revenue) || 0);
            break;
        case 'revenue_report': {
            const totP = data.reduce((s, d) => s + (parseInt(d.pending_orders)   || 0), 0);
            const totC = data.reduce((s, d) => s + (parseInt(d.confirmed_orders) || 0), 0);
            const totD = data.reduce((s, d) => s + (parseInt(d.delivered_orders) || 0), 0);
            const totX = data.reduce((s, d) => s + (parseInt(d.cancelled_orders) || 0), 0);
            distLabels = ['Pending', 'Confirmed', 'Delivered', 'Cancelled'];
            distValues = [totP, totC, totD, totX];
            break;
        }
    }

    // Only draw if there's actual non-zero data
    const hasData = distValues.some(v => v > 0);
    if (hasData) {
        distributionChart = new Chart(distCtx, {
            type: 'doughnut',
            data: {
                labels: distLabels,
                datasets: [{
                    data: distValues,
                    backgroundColor: [
                        'rgba(13, 110, 253, 0.8)',
                        'rgba(25, 135, 84, 0.8)',
                        'rgba(255, 193, 7, 0.8)',
                        'rgba(220, 53, 69, 0.8)',
                        'rgba(13, 202, 240, 0.8)',
                        'rgba(108, 117, 125, 0.8)'
                    ]
                }]
            },
            options: {
                responsive: true,
                maintainAspectRatio: false,
                plugins: { legend: { position: 'bottom' } }
            }
        });
    }
}

/**
 * Export to CSV
 */
function exportReport() {
    if (!currentReportData || !currentReportData.data || currentReportData.data.length === 0) {
        showAlert('warning', 'Generate a report first before exporting');
        return;
    }

    const data = currentReportData.data;
    const headers = Object.keys(data[0]);
    let csv = headers.join(',') + '\n';
    data.forEach(row => {
        const values = Object.values(row).map(v => {
            if (v === null || v === undefined) return '';
            const str = String(v);
            return str.includes(',') ? `"${str}"` : str;
        });
        csv += values.join(',') + '\n';
    });

    const blob = new Blob([csv], { type: 'text/csv' });
    const url  = window.URL.createObjectURL(blob);
    const a    = document.createElement('a');
    a.href     = url;
    a.download = `${currentReportData.report_type}_${currentReportData.period.start}_to_${currentReportData.period.end}.csv`;
    document.body.appendChild(a);
    a.click();
    document.body.removeChild(a);
    window.URL.revokeObjectURL(url);
    showAlert('success', 'Report exported successfully');
}

/* ---- Helpers ---- */
function getReportTitle(type) {
    return {
        farmer_performance: 'Farmer Performance Report',
        collection_summary: 'Collection Summary Report',
        product_sales:      'Product Sales Report',
        revenue_report:     'Revenue Report'
    }[type] || 'Report';
}

function formatColumnName(name) {
    return name.replace(/_/g, ' ').replace(/\b\w/g, c => c.toUpperCase());
}

function getTrendLabel(type) {
    return {
        farmer_performance: 'Total Quantity (Liters)',
        collection_summary: 'Daily Collection (Liters)',
        product_sales:      'Revenue (Rs.)',
        revenue_report:     'Daily Revenue (Rs.)'
    }[type] || 'Value';
}

function showAlert(type, message) {
    const alertDiv = document.createElement('div');
    alertDiv.className = `alert alert-${type} alert-dismissible fade show`;
    alertDiv.innerHTML = `${message}<button type="button" class="btn-close" data-bs-dismiss="alert"></button>`;
    const container = document.querySelector('.page-wrapper') || document.body;
    container.insertBefore(alertDiv, container.firstChild);
    setTimeout(() => alertDiv.remove(), 5000);
}
