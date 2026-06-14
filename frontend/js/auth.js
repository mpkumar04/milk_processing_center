/**
 * Milk Processing Center - Auth Guard
 * Redirects to login if not authenticated.
 * Include this script on every protected page.
 */

(function () {
    if (sessionStorage.getItem('mpc_logged_in') !== 'true') {
        window.location.href = 'login.html';
    }
})();

/**
 * Render the logged-in user info + logout button in the navbar.
 * Call after DOM is ready.
 */
function renderNavUser() {
    const username = sessionStorage.getItem('mpc_username') || 'User';
    const role     = sessionStorage.getItem('mpc_role')     || '';

    const nav = document.querySelector('.navbar-nav');
    if (!nav) return;

    const li = document.createElement('li');
    li.className = 'nav-item dropdown ms-2';
    li.innerHTML = `
        <a class="nav-link dropdown-toggle d-flex align-items-center gap-2"
           href="#" role="button" data-bs-toggle="dropdown"
           style="background:rgba(255,255,255,.15);border-radius:7px;padding:.45rem .9rem;">
            <i class="fas fa-user-circle"></i>
            <span style="font-size:.85rem;font-weight:600;">${username}</span>
        </a>
        <ul class="dropdown-menu dropdown-menu-end shadow border-0" style="min-width:180px;">
            <li>
                <span class="dropdown-item-text d-flex flex-column py-2">
                    <strong style="font-size:.875rem;">${username}</strong>
                    <small class="text-muted">${role}</small>
                </span>
            </li>
            <li><hr class="dropdown-divider my-1"></li>
            <li>
                <a class="dropdown-item text-danger" href="#" onclick="logout()">
                    <i class="fas fa-sign-out-alt me-2"></i>Logout
                </a>
            </li>
        </ul>`;
    nav.appendChild(li);
}

function logout() {
    sessionStorage.clear();
    window.location.href = 'login.html';
}

document.addEventListener('DOMContentLoaded', renderNavUser);
