const fs = require('fs');

// 1. Update index.html
let html = fs.readFileSync('index.html', 'utf-8');

const targetStr = '<p style="color: #666; margin-bottom: 20px;">يرجى إدخال كلمة المرور للوصول إلى لوحة التحكم</p>\r\n            <input type="password" id="authPassword" class="auth-input" placeholder="كلمة المرور">\r\n            <button class="auth-btn" onclick="checkAuth()">دخول</button>\r\n            <p id="authError" style="color: #c00; margin-top: 15px; display: none;">❌ كلمة المرور غير صحيحة</p>';

const targetStr2 = targetStr.replace(/\r\n/g, '\n');

const replacementStr = '<p style="color: #666; margin-bottom: 20px;">يرجى إدخال بيانات الدخول للوصول إلى لوحة التحكم</p>\n            <input type="text" id="authUsername" class="auth-input" placeholder="اسم المستخدم" style="margin-bottom: 10px;">\n            <input type="password" id="authPassword" class="auth-input" placeholder="كلمة المرور">\n            <button class="auth-btn" onclick="checkAuth()">دخول</button>\n            <p id="authError" style="color: #c00; margin-top: 15px; display: none;">❌ بيانات الدخول غير صحيحة</p>';

if (html.includes(targetStr)) {
    html = html.replace(targetStr, replacementStr);
} else if (html.includes(targetStr2)) {
    html = html.replace(targetStr2, replacementStr);
} else {
    console.log('Target not found in index.html');
}

fs.writeFileSync('index.html', html);

// 2. Update script.js
let script = fs.readFileSync('script.js', 'utf-8');

// The applyUserPermissions function
const applyFunc = `
function applyUserPermissions(role) {
    const allTabs = document.querySelectorAll('.sidebar-item');
    if (role === 'admin') {
        allTabs.forEach(tab => tab.style.display = 'flex');
    } else if (role === 'user') {
        allTabs.forEach(tab => {
            if (tab.id === 'communitiesTabBtn' || tab.id === 'communityUsersTabBtn') {
                tab.style.display = 'flex';
            } else {
                tab.style.display = 'none';
            }
        });
    }
}
`;

// Insert the applyFunc before checkAuth
const checkAuthStart = script.indexOf('function checkAuth() {');
if (checkAuthStart !== -1) {
    script = script.slice(0, checkAuthStart) + applyFunc + '\n' + script.slice(checkAuthStart);
} else {
    console.log('checkAuth not found');
}

// Replace checkAuth body
const oldCheckAuthStr = `function checkAuth() {
    const passwordInput = document.getElementById('authPassword');
    if (!passwordInput) return;

    const password = passwordInput.value.trim();
    const correctPassword = 'Taher';

    if (password === correctPassword) {
        try {
            document.getElementById('authOverlay').style.display = 'none';
            localStorage.setItem('dashboardAuth', 'true');
            initializeDashboard();
        } catch (e) {
            console.error('Initial load failure:', e);
            alert('⚠️ فشل تحميل بعض البيانات بعد الدخول: ' + e.message);
        }
    } else {
        const authError = document.getElementById('authError');
        if (authError) authError.style.display = 'block';
    }
}`;

const oldCheckAuthStr2 = oldCheckAuthStr.replace(/\n/g, '\r\n');

const newCheckAuthStr = `function checkAuth() {
    const usernameInput = document.getElementById('authUsername');
    const passwordInput = document.getElementById('authPassword');
    if (!passwordInput || !usernameInput) return;

    const username = usernameInput.value.trim();
    const password = passwordInput.value.trim();

    let role = null;
    if (username.toUpperCase() === 'TAHER' && password === 'Taher') {
        role = 'admin';
    } else if (username.toLowerCase() === 'user' && password === 'user') {
        role = 'user';
    }

    if (role) {
        try {
            document.getElementById('authOverlay').style.display = 'none';
            localStorage.setItem('dashboardAuth', 'true');
            localStorage.setItem('dashboardRole', role);
            applyUserPermissions(role);
            if (role === 'admin') {
                initializeDashboard();
            } else {
                switchTab('communities');
                loadCommunities();
            }
        } catch (e) {
            console.error('Initial load failure:', e);
            alert('⚠️ فشل تحميل بعض البيانات بعد الدخول: ' + e.message);
        }
    } else {
        const authError = document.getElementById('authError');
        if (authError) authError.style.display = 'block';
    }
}`;

if (script.includes(oldCheckAuthStr)) {
    script = script.replace(oldCheckAuthStr, newCheckAuthStr);
} else if (script.includes(oldCheckAuthStr2)) {
    script = script.replace(oldCheckAuthStr2, newCheckAuthStr);
} else {
    console.log('oldCheckAuthStr not found');
}

// Modify the DOMContentLoaded initialization to check role
const oldInitStr = `    // Check auth on load
    if (localStorage.getItem('dashboardAuth') === 'true') {
        const authOverlay = document.getElementById('authOverlay');
        if (authOverlay) authOverlay.style.display = 'none';
        initializeDashboard();
    }`;
const oldInitStr2 = oldInitStr.replace(/\n/g, '\r\n');

const newInitStr = `    // Check auth on load
    if (localStorage.getItem('dashboardAuth') === 'true') {
        const authOverlay = document.getElementById('authOverlay');
        if (authOverlay) authOverlay.style.display = 'none';
        
        const role = localStorage.getItem('dashboardRole') || 'admin';
        applyUserPermissions(role);
        
        if (role === 'admin') {
            initializeDashboard();
        } else {
            switchTab('communities');
            loadCommunities();
        }
    }`;

if (script.includes(oldInitStr)) {
    script = script.replace(oldInitStr, newInitStr);
} else if (script.includes(oldInitStr2)) {
    script = script.replace(oldInitStr2, newInitStr);
}

// And the interval check
const oldIntervalStr = `    // Auto-refresh every 60 seconds
    setInterval(() => {
        if (localStorage.getItem('dashboardAuth') === 'true') {
            loadFeedback();
            loadUpdates();
        }
    }, 60000);`;
const oldIntervalStr2 = oldIntervalStr.replace(/\n/g, '\r\n');

const newIntervalStr = `    // Auto-refresh every 60 seconds
    setInterval(() => {
        if (localStorage.getItem('dashboardAuth') === 'true') {
            const role = localStorage.getItem('dashboardRole') || 'admin';
            if (role === 'admin') {
                loadFeedback();
                loadUpdates();
            } else {
                loadCommunities();
            }
        }
    }, 60000);`;

if (script.includes(oldIntervalStr)) {
    script = script.replace(oldIntervalStr, newIntervalStr);
} else if (script.includes(oldIntervalStr2)) {
    script = script.replace(oldIntervalStr2, newIntervalStr);
}

fs.writeFileSync('script.js', script);
console.log('All updates complete');
