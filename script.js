/**
 * RECREATED script.js
 * Contains the logic for the feedback dashboard.
 * Note: specific Supabase identifiers/keys are missing, so backend calls are stubbed.
 */

// Global state
let currentTab = 'feedback';

document.addEventListener('DOMContentLoaded', () => {
    // Handle Enter key on password input
    const passInput = document.getElementById('authPassword');
    if (passInput) {
        passInput.addEventListener('keypress', (e) => {
            if (e.key === 'Enter') checkAuth();
        });
    }

    // Initialize charts with dummy data for UI visualization
    initCharts();
});

// --- Auth ---
function checkAuth() {
    const password = document.getElementById('authPassword').value.trim();
    const errorMsg = document.getElementById('authError');
    // Using simple "admin" password as per request
    if (password === 'admin') {
        document.getElementById('authOverlay').style.display = 'none';
        if (errorMsg) errorMsg.style.display = 'none';
        loadFeedback(); // Load initial data
        loadSettings(); // Load Settings
        loadBroadcasts(); // Load Broadcast History
        loadUpdates(); // Load Updates History
    } else {
        if (errorMsg) errorMsg.style.display = 'block';
    }
}

// --- Navigation ---
function toggleSidebar() {
    const sidebar = document.querySelector('.sidebar');
    if (sidebar) {
        sidebar.classList.toggle('active');
    }
}

function switchTab(tabId) {
    currentTab = tabId;

    // Hide all tabs
    document.querySelectorAll('.tab-pane').forEach(tab => {
        tab.classList.remove('active');
    });
    // Remove active class from all nav items
    document.querySelectorAll('.nav-item').forEach(item => {
        item.classList.remove('active');
    });

    // Show selected tab & activate nav item
    const targetTab = document.getElementById(tabId + 'Tab');
    const targetNav = document.getElementById(tabId + 'Nav');

    if (targetTab) targetTab.classList.add('active');
    if (targetNav) targetNav.classList.add('active');

    // Close sidebar on mobile
    if (window.innerWidth <= 768) {
        const sidebar = document.querySelector('.sidebar');
        if (sidebar) sidebar.classList.remove('active');
    }

    // Refresh charts if analytics tab is opened
    if (tabId === 'analytics') {
        // resize charts if needed
    }
}

const SUPABASE_URL = 'https://kghwboxevphvxtsagrer.supabase.co';
const SUPABASE_KEY = 'sb_publishable_Kl3FXiXa7AHEokVvCiImmQ_03UL91M0'; // User provided
const supabaseClient = supabase.createClient(SUPABASE_URL, SUPABASE_KEY);

// --- Real Data Logic ---

async function loadFeedback() {
    console.log('Fetching feedback from Supabase...');
    const listEl = document.getElementById('feedbackList');
    if (listEl) listEl.innerHTML = '<p style="text-align:center;">جاري التحميل...</p>';

    // Build query
    let query = supabaseClient.from('feedback').select('*').order('created_at', { ascending: false });

    // Apply filters from UI
    const cat = document.getElementById('categoryFilter').value;
    const status = document.getElementById('statusFilter').value;
    const search = document.getElementById('searchInput').value.trim();
    const rating = document.getElementById('ratingFilter').value;
    const unreplied = document.getElementById('unrepliedFilter').checked;

    if (cat) query = query.eq('category', cat);
    if (status) query = query.eq('status', status);
    if (status) query = query.eq('status', status);
    if (rating) query = query.eq('rating', parseInt(rating));
    
    // Unreplied Filter Logic
    if (unreplied) {
        // 'is' null fits most cases for empty text in Supabase if default is NULL
        query = query.is('reply', null); 
    }

    const { data, error } = await query;

    if (error) {
        console.error('Error loading feedback:', error);
        if (listEl) listEl.innerHTML = `<p style="color:red; text-align:center;">خطأ في التحميل: ${error.message}</p>`;
        return;
    }

    if (!data || data.length === 0) {
        if (listEl) listEl.innerHTML = '<p style="text-align:center;">لا يوجد بيانات</p>';
        updateStats([]);
        return;
    }

    updateStats(data);
    renderFeedbackList(data);
}

function renderFeedbackList(items) {
    const listEl = document.getElementById('feedbackList');
    if (!listEl) return;
    listEl.innerHTML = '';

    // --- DEBUG REMOVED ---

    items.forEach(item => {
        const div = document.createElement('div');
        div.className = 'card feedback-card';

        // Parse Device Info Logic
        let deviceInfoStr = 'غير معروف';
        let appVer = item.app_version || '?';

        if (item.device_info && typeof item.device_info === 'object') {
            const d = item.device_info;
            // From screenshot: manufacturer="realme", model="RMX2163", os="Android", os_version="12"
            const brand = d.manufacturer || d.brand || '';
            const model = d.model || d.product || '';
            const os = d.os || '';
            const osVer = d.os_version || '';

            if (brand || model) {
                deviceInfoStr = `${brand} ${model} (${os} ${osVer})`.trim();
            } else {
                deviceInfoStr = JSON.stringify(d);
            }

            // App version might be inside device_info
            if (d.app_version) appVer = d.app_version;
        } else if (item.device_info) {
            deviceInfoStr = item.device_info;
        }

        // Parse Image Logic
        let displayImage = null;
        if (item.image_urls && Array.isArray(item.image_urls) && item.image_urls.length > 0) {
            displayImage = item.image_urls[0];
        } else if (item.image_url) {
            displayImage = item.image_url;
        }

        div.innerHTML = `
            <div class="feedback-header">
                <span class="badge ${getBadgeClass(item.category)}">${item.category || 'عام'}</span>
                <span style="font-size:0.8rem; color:var(--text-muted);">${new Date(item.created_at).toLocaleString('ar-EG')}</span>
            </div>
            <p>${item.description || item.message || '(لا يوجد نص)'}</p>
            ${displayImage ? `<img src="${displayImage}" class="feedback-img" onclick="openImage('${displayImage}')">` : ''}
            <div class="device-info">
                📱 ${deviceInfoStr} | v${appVer}
            </div>
            ${item.reply ? `<div style="background:#f0fff4; padding:8px; margin-top:8px; border-radius:4px; font-size:0.9rem;"><strong>ردAdmin:</strong> ${item.reply}</div>` : ''}
            <div style="display:flex; gap:5px; margin-top:10px;">
                <button class="btn btn-primary" style="flex:1" onclick="replyToFeedback('${item.id}')">↩️ رد</button>
                <button class="btn btn-danger" style="flex:1" onclick="deleteFeedback('${item.id}')">🗑️ حذف</button>
            </div>
        `;
        listEl.appendChild(div);
    });
}

function getBadgeClass(cat) {
    if (cat === 'مشكلة') return 'badge-danger';
    if (cat === 'اقتراح') return 'badge-success';
    return 'badge-primary';
}

function updateStats(data) {
    updateStat('totalCount', data.length);
    updateStat('problemCount', data.filter(d => d.category === 'مشكلة').length);
    updateStat('suggestionCount', data.filter(d => d.category === 'اقتراح').length);
    // Simple logic for recent (last 7 days)
    const weekAgo = new Date();
    weekAgo.setDate(weekAgo.getDate() - 7);
    updateStat('recentCount', data.filter(d => new Date(d.created_at) > weekAgo).length);
}

function updateStat(id, val) {
    const el = document.getElementById(id);
    if (el) el.innerText = val;
}

function filterFeedback() {
    loadFeedback(); // Re-fetch with new filters
}

// Stubbed functions for other tabs (Content, Banner, etc) can be implemented similarly
// For now, we focus on Feedback and the generic DeleteAll

async function pushUpdate() {
    const versionName = document.getElementById('versionName').value.trim();
    const versionCode = document.getElementById('versionCode').value.trim();
    const isMandatory = document.getElementById('isMandatory').value === 'true';
    const updateUrl = document.getElementById('updateUrl').value.trim();
    const releaseNotes = document.getElementById('releaseNotes').value.trim();

    if (!versionName || !versionCode || !updateUrl) {
        alert('يرجى ملء الحقول الأساسية (الاسم، الكود، الرابط)');
        return;
    }

    const { error } = await supabaseClient
        .from('app_updates')
        .insert([{
            version_name: versionName,
            version_code: parseInt(versionCode),
            is_mandatory: isMandatory,
            update_url: updateUrl,
            release_notes: releaseNotes
        }]);

    if (error) {
        console.error('Error pushing update:', error);
        alert(`خطأ في نشر التحديث: ${error.message}`);
    } else {
        alert('تم نشر التحديث بنجاح 🚀');
        // Clear inputs
        document.getElementById('versionName').value = '';
        document.getElementById('versionCode').value = '';
        document.getElementById('updateUrl').value = '';
        document.getElementById('releaseNotes').value = '';
        
        loadUpdates(); // Refresh list
    }
}

async function loadUpdates() {
    console.log('Loading updates...');
    const listEl = document.getElementById('updatesList');
    if (!listEl) return;
    
    listEl.innerHTML = '<p>جاري التحميل...</p>';
    
    const { data, error } = await supabaseClient
        .from('app_updates')
        .select('*')
        .order('created_at', { ascending: false });

    if (error) {
        console.error('Error loading updates:', error);
        listEl.innerHTML = `<p style="color:red">خطأ: ${error.message}</p>`;
        return;
    }

    if (!data || data.length === 0) {
        listEl.innerHTML = '<p>لا توجد تحديثات سابقة.</p>';
        return;
    }

    listEl.innerHTML = '';
    data.forEach(item => {
        const div = document.createElement('div');
        div.className = 'card feedback-card';
        div.innerHTML = `
            <div class="feedback-header">
                <span class="badge ${item.is_mandatory ? 'badge-danger' : 'badge-primary'}">
                    ${item.is_mandatory ? 'إجباري' : 'اختياري'}
                </span>
                <span style="font-size:0.8rem">${new Date(item.created_at).toLocaleString('ar-EG')}</span>
            </div>
            <h4>v${item.version_name} (Code: ${item.version_code})</h4>
            <p style="white-space: pre-wrap;">${item.release_notes || 'لا توجد ملاحظات'}</p>
            <div style="font-size:0.8rem; color:var(--text-muted); margin-bottom:10px; word-break:break-all;">
                🔗 ${item.update_url}
            </div>
            <button class="btn btn-danger btn-sm" onclick="deleteUpdate('${item.id}')">🗑️ حذف</button>
        `;
        listEl.appendChild(div);
    });
}

async function deleteUpdate(id) {
    if(!confirm('هل أنت متأكد من حذف هذا التحديث؟')) return;

    const { error } = await supabaseClient
        .from('app_updates')
        .delete()
        .eq('id', id);

    if (error) {
        alert(`خطأ: ${error.message}`);
    } else {
        loadUpdates();
    }
}

function publishContent() {
    alert('Content functionality not yet connected to backend.');
}

function uploadBanner() {
    alert('Banner functionality not yet connected to backend.');
}

function addCustomRadio() {
    alert('Radio functionality not yet connected to backend.');
}

function addKidsStory() {
    alert('Kids Story functionality not yet connected to backend.');
}

function addCharityStory() {
    alert('Charity Story functionality not yet connected to backend.');
}

function updateMaintenanceMode(isActive) {
    console.log(`Maintenance mode set to: ${isActive}`);
    // Here you would update a 'config' table in Supabase
}

function updateThemeColor() {
    const color = document.getElementById('themeColorInput').value;
    document.documentElement.style.setProperty('--primary-color', color);
}

function updateNewsMarquee() {
    // Add logic to update news table
    alert('News Marquee not connected yet.');
}

async function loadBroadcasts() {
    console.log('Loading broadcasts...');
    const listEl = document.getElementById('broadcastHistoryList');
    if (!listEl) return;
    
    listEl.innerHTML = '<p>جاري التحميل...</p>';
    
    const { data, error } = await supabaseClient
        .from('broadcasts')
        .select('*')
        .order('created_at', { ascending: false });

    if (error) {
        console.error('Error loading broadcasts:', error);
        listEl.innerHTML = `<p style="color:red">خطأ: ${error.message}</p>`;
        return;
    }

    if (!data || data.length === 0) {
        listEl.innerHTML = '<p>لا توجد رسائل سابقة.</p>';
        return;
    }

    listEl.innerHTML = '';
    data.forEach(msg => {
        const div = document.createElement('div');
        div.className = 'card feedback-card';
        // Check if active
        // Assuming we might have an 'active' flag or just showing history
        div.innerHTML = `
            <div class="feedback-header">
                <span class="badge ${msg.is_active ? 'badge-success' : 'badge-danger'}">${msg.is_active ? 'نشط' : 'غير نشط'}</span>
                <span style="font-size:0.8rem">${new Date(msg.created_at).toLocaleString('ar-EG')}</span>
            </div>
            <p>${msg.message}</p>
            <button class="btn btn-sm btn-outline" onclick="deleteBroadcast('${msg.id}')">🗑️ حذف</button>
        `;
        listEl.appendChild(div);
    });
}

async function updateBroadcast() {
    const message = document.getElementById('broadcastInput').value.trim();
    const isActive = document.getElementById('broadcastToggle').checked;

    if (!message) {
        alert('الرجاء كتابة رسالة');
        return;
    }

    // Insert new broadcast
    const { error } = await supabaseClient
        .from('broadcasts')
        .insert([{ message: message, is_active: isActive }]);

    if (error) {
        console.error('Error sending broadcast:', error);
        alert(`خطأ: ${error.message}`);
    } else {
        alert('تم نشر الرسالة بنجاح ✅');
        document.getElementById('broadcastInput').value = '';
        loadBroadcasts(); // Refresh list
    }
}

async function deleteBroadcast(id) {
    if(!confirm('هل أنت متأكد من حذف هذه الرسالة؟')) return;

    const { error } = await supabaseClient
        .from('broadcasts')
        .delete()
        .eq('id', id);

    if (error) {
        alert(`خطأ: ${error.message}`);
    } else {
        loadBroadcasts();
    }
}

async function deleteFeedback(id) {
    if(!confirm('هل أنت متأكد من حذف هذه الشكوى؟')) return;

    const { error } = await supabaseClient
        .from('feedback')
        .delete()
        .eq('id', id);

    if (error) {
        alert(`خطأ في الحذف: ${error.message}`);
    } else {
        alert('تم الحذف بنجاح');
        loadFeedback(); // Refresh
    }
}

async function replyToFeedback(id) {
    const replyText = prompt('أدخل الرد على المستخدم:');
    if (replyText === null) return; // Cancelled
    if (replyText.trim() === '') {
        alert('الرد فارغ!');
        return;
    }

    const { error } = await supabaseClient
        .from('feedback')
        .update({ 
            reply: replyText,
            status: 'تم الرد' // Optional update status
        })
        .eq('id', id);

    if (error) {
        alert(`خطأ في الرد: ${error.message}`);
    } else {
        alert('تم إرسال الرد بنجاح ✅');
        loadFeedback(); // Refresh UI
    }
}

function updateDailyQuote() {
    // Add logic to update quotes table
}

function updateMinVersion() {
    // Add logic to update config table
}

function updateSupportLinks() {
    // Add logic to update config table
}

function updatePrayerOffsets() {
    // Add logic to update config table
}

// --- Social Banner Logic ---
async function updateSocialBanner() {
    const title = document.getElementById('socialBannerTitle').value;
    const link = document.getElementById('socialBannerLink').value;
    const platform = document.getElementById('socialBannerPlatform').value;
    const isActive = document.getElementById('socialBannerToggle').checked;

    const updates = [
        { key: 'social_banner_title', value: title },
        { key: 'social_banner_url', value: link },
        { key: 'social_banner_platform', value: platform },
        { key: 'social_banner_active', value: isActive.toString() }
    ];

    // Save to app_settings table using individual keys
    const { error } = await supabaseClient
        .from('app_settings')
        .upsert(updates);

    if (error) {
        console.error('Error saving banner:', error);
        alert('حدث خطأ أثناء حفظ البنر: ' + error.message);
    } else {
        alert('تم حفظ إعدادات البنر بنجاح ✅');
    }
}

async function loadSettings() {
    // Load Social Banner Config
    const { data: settings, error } = await supabaseClient
        .from('app_settings')
        .select('key, value')
        .in('key', ['social_banner_title', 'social_banner_url', 'social_banner_platform', 'social_banner_active']);

    if (settings && settings.length > 0) {
        // Helper to find value
        const getVal = (k) => settings.find(s => s.key === k)?.value;

        const title = getVal('social_banner_title');
        const url = getVal('social_banner_url');
        const platform = getVal('social_banner_platform');
        const active = getVal('social_banner_active');

        if(document.getElementById('socialBannerTitle')) document.getElementById('socialBannerTitle').value = title || '';
        if(document.getElementById('socialBannerLink')) document.getElementById('socialBannerLink').value = url || '';
        if(document.getElementById('socialBannerPlatform')) document.getElementById('socialBannerPlatform').value = platform || 'telegram';
        if(document.getElementById('socialBannerToggle')) document.getElementById('socialBannerToggle').checked = (active === 'true');
    }
}

// --- Modals ---
let pendingDeleteAction = null;

function deleteAll(type) {
    const modal = document.getElementById('confirmModal');
    const title = document.getElementById('confirmTitle');
    const msg = document.getElementById('confirmMessage');
    const yesBtn = document.getElementById('confirmYesBtn');

    if (modal) {
        title.innerText = 'حذف الكل؟';
        msg.innerText = `سيتم حذف جميع العناصر من قسم: ${type}`;
        modal.style.display = 'flex';

        // Remove old listener to avoid stacking
        const newBtn = yesBtn.cloneNode(true);
        yesBtn.parentNode.replaceChild(newBtn, yesBtn);

        newBtn.onclick = async () => {
            console.log(`Deleting all items for: ${type}`);

            // Map type to table name
            let tableName = '';
            if (type === 'feedback') tableName = 'feedback';
            else if (type === 'updates') tableName = 'app_updates';
            else if (type === 'content') tableName = 'daily_content';
            else if (type === 'banners') tableName = 'banners';
            else tableName = type; // fallback

            if (!tableName) {
                alert('الجدول غير معروف');
                return;
            }

            // Perform Delete (Assuming 'id' exists)
            // Perform Delete (Delete all rows where id is not null)
            const { error } = await supabaseClient.from(tableName).delete().not('id', 'is', null);

            if (error) {
                console.error(error);
                alert(`خطأ في الحذف: ${error.message}`);
            } else {
                // Clear the list in UI
                const listId = type === 'feedback' ? 'feedbackList' :
                    type === 'updates' ? 'updatesList' :
                        type + 'List';

                const listEl = document.getElementById(listId);
                if (listEl) listEl.innerHTML = '';

                alert('تم حذف جميع العناصر بنجاح.');
                // Reload to refresh stats if needed
                if (type === 'feedback') loadFeedback();
            }

            closeConfirmModal();
        };
    }
}

function closeModal() {
    const modal = document.getElementById('imageModal');
    if (modal) modal.style.display = 'none';
}

function closeConfirmModal() {
    const modal = document.getElementById('confirmModal');
    if (modal) modal.style.display = 'none';
}

// --- Charts Initialization ---
function initCharts() {
    // Only if Chart.js is loaded
    if (typeof Chart === 'undefined') return;

    // Category Chart
    const ctx1 = document.getElementById('categoryChart');
    if (ctx1) {
        new Chart(ctx1.getContext('2d'), {
            type: 'doughnut',
            data: {
                labels: ['مشكلة', 'اقتراح', 'استفسار', 'تحديث'],
                datasets: [{
                    data: [30, 50, 20, 10],
                    backgroundColor: ['#e74c3c', '#f1c40f', '#3498db', '#2ecc71']
                }]
            },
            options: { responsive: true }
        });
    }

    // Frequency Chart
    const ctx2 = document.getElementById('frequencyChart');
    if (ctx2) {
        new Chart(ctx2.getContext('2d'), {
            type: 'line',
            data: {
                labels: ['Week 1', 'Week 2', 'Week 3', 'Week 4'],
                datasets: [{
                    label: 'النشاط',
                    data: [12, 19, 3, 5],
                    borderColor: '#667eea',
                    fill: true,
                    backgroundColor: 'rgba(102, 126, 234, 0.2)'
                }]
            },
            options: { responsive: true }
        });
    }

    // Countries Chart
    const ctx3 = document.getElementById('countriesChart');
    if (ctx3) {
        new Chart(ctx3.getContext('2d'), {
            type: 'bar',
            data: {
                labels: ['Egypt', 'SA', 'US'],
                datasets: [{
                    label: 'المستخدمين',
                    data: [150, 80, 45],
                    backgroundColor: ['#e74c3c', '#2ecc71', '#3498db']
                }]
            },
            options: { responsive: true }
        });
    }
}
