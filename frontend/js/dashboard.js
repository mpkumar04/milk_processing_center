/**
 * Highland Milk Industries - Dashboard JavaScript
 */

const API_BASE_URL = '../backend/api';

// Load dashboard data on page load
document.addEventListener('DOMContentLoaded', function() {
    loadDashboardData();
});

/**
 * Load all dashboard data
 */
async function loadDashboardData() {
    try {
        const response = await fetch(`${API_BASE_URL}/dashboard.php`);
        const result = await response.json();
        
        if (result.success) {
            const data = result.data;
            
            // Update statistics cards
            updateStatistics(data);
            
            // Update recent collections table
            updateRecentCollections(data.recent_collections);
            
            // Update top farmers table
            updateTopFarmers(data.top_farmers);
            
            // Update stock alerts
            updateStockAlerts(data.stock_alerts);
            
            // Update collection trend chart
            updateCollectionTrendChart(data.collection_trend);
        } else {
            showAlert('error', 'Failed to load dashboard data');
        }
    } catch (error) {
        console.error('Error loading dashboard:', error);
        showAlert('error', 'Error connecting to server');
    }
}

/**
 * Update statistics cards
 */
function updateStatistics(data) {
    document.getElementById('activeFarmers').textContent = data.active_farmers || 0;
    document.getElementById('todayCollections').textContent = data.today_collections || 0;
    document.getElementById('todayQuantity').textContent = `${data.today_quantity || 0} Liters`;
    document.getElementById('pendingOrders').textContent = data.pending_orders || 0;
    document.getElementById('monthRevenue').textContent = `Rs. ${formatNumber(data.month_revenue || 0)}`;
}

/**
 * Update recent collections table
 */
function updateRecentCollections(collections) {
    const tbody = document.getElementById('recentCollectionsTable');
    
    if (!collections || collections.length === 0) {
        tbody.innerHTML = '<tr><td colspan="5" class="text-center">No recent collections</td></tr>';
        return;
    }
    
    tbody.innerHTML = '';
    collections.forEach(collection => {
        const row = `
            <tr>
                <td>${collection.farmer_name}</td>
                <td>${formatDate(collection.collection_date)}</td>
                <td>${parseFloat(collection.quantity_liters).toFixed(2)}</td>
                <td>${parseFloat(collection.fat_percentage).toFixed(2)}%</td>
                <td><span class="badge badge-grade-${collection.quality_grade}">${collection.quality_grade}</span></td>
            </tr>
        `;
        tbody.innerHTML += row;
    });
}

/**
 * Update top farmers table
 */
function updateTopFarmers(farmers) {
    const tbody = document.getElementById('topFarmersTable');
    
    if (!farmers || farmers.length === 0) {
        tbody.innerHTML = '<tr><td colspan="5" class="text-center">No data available</td></tr>';
        return;
    }
    
    tbody.innerHTML = '';
    farmers.forEach((farmer, index) => {
        const row = `
            <tr>
                <td><strong>${index + 1}</strong></td>
                <td>${farmer.farmer_name}</td>
                <td>${farmer.collection_days}</td>
                <td>${parseFloat(farmer.total_quantity).toFixed(2)}</td>
                <td>${parseFloat(farmer.avg_fat).toFixed(2)}%</td>
            </tr>
        `;
        tbody.innerHTML += row;
    });
}

/**
 * Update stock alerts table
 */
function updateStockAlerts(alerts) {
    const tbody = document.getElementById('stockAlertsTable');
    
    if (!alerts || alerts.length === 0) {
        tbody.innerHTML = '<tr><td colspan="4" class="text-center text-success">No stock alerts</td></tr>';
        return;
    }
    
    tbody.innerHTML = '';
    alerts.forEach(alert => {
        const row = `
            <tr class="table-danger">
                <td>${alert.product_name}</td>
                <td>${alert.warehouse_name}</td>
                <td>${parseFloat(alert.current_stock).toFixed(2)}</td>
                <td>${parseFloat(alert.reorder_level).toFixed(2)}</td>
            </tr>
        `;
        tbody.innerHTML += row;
    });
}

/**
 * Update collection trend chart
 */
function updateCollectionTrendChart(trendData) {
    const ctx = document.getElementById('collectionTrendChart');
    
    if (!trendData || trendData.length === 0) {
        return;
    }
    
    const labels = trendData.map(item => item.month);
    const quantities = trendData.map(item => parseFloat(item.total_quantity));
    const fatPercentages = trendData.map(item => parseFloat(item.avg_fat));
    
    new Chart(ctx, {
        type: 'line',
        data: {
            labels: labels,
            datasets: [
                {
                    label: 'Total Quantity (Liters)',
                    data: quantities,
                    borderColor: 'rgb(13, 110, 253)',
                    backgroundColor: 'rgba(13, 110, 253, 0.1)',
                    tension: 0.4,
                    yAxisID: 'y'
                },
                {
                    label: 'Average Fat %',
                    data: fatPercentages,
                    borderColor: 'rgb(255, 193, 7)',
                    backgroundColor: 'rgba(255, 193, 7, 0.1)',
                    tension: 0.4,
                    yAxisID: 'y1'
                }
            ]
        },
        options: {
            responsive: true,
            maintainAspectRatio: true,
            interaction: {
                mode: 'index',
                intersect: false
            },
            plugins: {
                legend: {
                    position: 'top'
                },
                tooltip: {
                    callbacks: {
                        label: function(context) {
                            let label = context.dataset.label || '';
                            if (label) {
                                label += ': ';
                            }
                            if (context.parsed.y !== null) {
                                label += context.parsed.y.toFixed(2);
                            }
                            return label;
                        }
                    }
                }
            },
            scales: {
                y: {
                    type: 'linear',
                    display: true,
                    position: 'left',
                    title: {
                        display: true,
                        text: 'Quantity (Liters)'
                    }
                },
                y1: {
                    type: 'linear',
                    display: true,
                    position: 'right',
                    title: {
                        display: true,
                        text: 'Fat %'
                    },
                    grid: {
                        drawOnChartArea: false
                    }
                }
            }
        }
    });
}

/**
 * Format number with thousands separator
 */
function formatNumber(num) {
    return parseFloat(num).toFixed(2).replace(/\B(?=(\d{3})+(?!\d))/g, ",");
}

/**
 * Format date to readable format
 */
function formatDate(dateString) {
    const date = new Date(dateString);
    const options = { year: 'numeric', month: 'short', day: 'numeric' };
    return date.toLocaleDateString('en-US', options);
}

/**
 * Show alert message
 */
function showAlert(type, message) {
    const alertClass = type === 'success' ? 'alert-success' : 'alert-danger';
    const alertHtml = `
        <div class="alert ${alertClass} alert-dismissible fade show" role="alert">
            ${message}
            <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
        </div>
    `;
    const container = document.querySelector('.page-wrapper') || document.querySelector('.container-fluid');
    container.insertAdjacentHTML('afterbegin', alertHtml);
    setTimeout(() => {
        const alert = document.querySelector('.alert');
        if (alert) alert.remove();
    }, 5000);
}

/**
 * Refresh dashboard data every 60 seconds
 */
setInterval(loadDashboardData, 60000);
