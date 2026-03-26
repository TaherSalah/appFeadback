/**
 * RAFUIQ ELMUSLIM ADMIN DASHBOARD - Consolidated Logic
 * All dashboard features are now centralized here.
 */

// Supabase Configuration
const SUPABASE_URL = 'https://kghwboxevphvxtsagrer.supabase.co';
const SUPABASE_ANON_KEY = 'sb_publishable_Kl3FXiXa7AHEokVvCiImmQ_03UL91M0';
const supabaseClient = window.supabase.createClient(SUPABASE_URL, SUPABASE_ANON_KEY);

// Global State
let allFeedback = [];
let allUsageData = [];
let categoryChart = null;
let frequencyChart = null;
let countriesChart = null;
let osChart = null;
let dailyUsageChart = null;
let featuresUsageChart = null;

const APP_FEATURES = [
    { id: 'musshaf', name: 'المصحف', icon: '📖' },
    { id: 'azkar', name: 'الأذكار', icon: '📿' },
    { id: 'sebha', name: 'السبحة', icon: '📿' },
    { id: 'khatmah', name: 'الختمات الجماعية', icon: '🕋' },
    { id: 'zakat', name: 'حساب الزكاة', icon: '💰' },
    { id: 'wird', name: 'الورد اليومي', icon: '📝' },
    { id: 'charity', name: 'الصدقة الجارية', icon: '🤝' },
    { id: 'radio', name: 'إذاعات القرآن', icon: '📻' },
    { id: 'kids', name: 'ركن الأطفال', icon: '👶' },
    { id: 'hadith', name: 'كتب الحديث', icon: '📚' },
    { id: 'mosques', name: 'المساجد القريبة', icon: '🕌' },
    { id: 'timing', name: 'مواقيت الصلاة', icon: '⏰' },
    { id: 'qibla', name: 'اتجاه القبلة', icon: '🧭' },
    { id: 'fajr_alarm', name: 'منبه الفجر', icon: '🌅' },
    { id: 'calendar', name: 'التقويم الهجري', icon: '📅' },
    { id: 'settings', name: 'الإعدادات', icon: '⚙️' },
    { id: 'friday_companion', name: 'رفيق الجمعة', icon: '🕌' }
];

document.addEventListener('DOMContentLoaded', () => {
    // Handle Enter key on password input
    const authPasswordInput = document.getElementById('authPassword');
    if (authPasswordInput) {
        authPasswordInput.addEventListener('keypress', function (e) {
            if (e.key === 'Enter') {
                checkAuth();
            }
        });
    }

    // Check auth on load
    if (localStorage.getItem('dashboardAuth') === 'true') {
        const authOverlay = document.getElementById('authOverlay');
        if (authOverlay) authOverlay.style.display = 'none';
        initializeDashboard();
    }

    // Initialize UI listeners
    setupEventListeners();
});

function setupEventListeners() {
    const filters = ['categoryFilter', 'statusFilter', 'ratingFilter', 'searchInput', 'startDate', 'endDate'];
    filters.forEach(id => {
        const el = document.getElementById(id);
        if (el) el.addEventListener('change', filterFeedback);
        if (el && id === 'searchInput') el.addEventListener('input', filterFeedback);
    });

    const themeColorInput = document.getElementById('themeColorInput');
    if (themeColorInput) {
        themeColorInput.addEventListener('input', (e) => {
            const hexInput = document.getElementById('themeColorHex');
            if (hexInput) hexInput.value = e.target.value;
        });
    }

    // Keyboard shortcut for modal
    document.addEventListener('keydown', (e) => {
        if (e.key === 'Escape') closeModal();
    });
}

function initializeDashboard() {
    loadFeedback();
    loadUpdates();
    loadAnalytics();
    loadSettings();
    loadErrors();
    loadKidsStories();
    loadCharityStories();

    // Auto-refresh every 60 seconds
    setInterval(() => {
        if (localStorage.getItem('dashboardAuth') === 'true') {
            loadFeedback();
            loadUpdates();
        }
    }, 60000);
}

// --- AUTHENTICATION ---
function checkAuth() {
    const passwordInput = document.getElementById('authPassword');
    if (!passwordInput) return;
    
    const password = passwordInput.value.trim();
    const correctPassword = 'admin';

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
}

// --- NAVIGATION ---
function switchTab(tabId) {
    console.log('Switching to tab:', tabId);
    
    // Hide all tabs
    document.querySelectorAll('.tab-content').forEach(tab => tab.classList.remove('active'));
    document.querySelectorAll('.tab').forEach(btn => btn.classList.remove('active'));

    // Show selected tab
    const content = document.getElementById(tabId + 'Tab');
    const btn = document.getElementById(tabId + 'TabBtn');

    if (content && btn) {
        content.classList.add('active');
        btn.classList.add('active');
    } else {
        console.warn('Tab elements not found for:', tabId);
    }

    // Load specific data per tab if needed
    switch(tabId) {
        case 'analytics': loadAnalytics(); break;
        case 'features': loadFeatures(); break;
        case 'content': loadContent(); break;
        case 'kidsStories': loadKidsStories(); break;
        case 'charityStories': loadCharityStories(); break;
        case 'radio': loadRadios(); break;
        case 'banners': loadBanners(); break;
        case 'updates': loadUpdates(); break;
        case 'errors': loadErrors(); break;
        case 'settings': loadSettings(); break;
    }
}

function toggleTheme() {
    const currentTheme = document.documentElement.getAttribute('data-theme');
    const newTheme = currentTheme === 'dark' ? 'light' : 'dark';
    document.documentElement.setAttribute('data-theme', newTheme);
    localStorage.setItem('dashboardTheme', newTheme);
}

// --- FEEDBACK MANAGEMENT ---
async function loadFeedback() {
    const feedbackList = document.getElementById('feedbackList');
    if (feedbackList) feedbackList.innerHTML = '<div class="loading">⏳ جاري تحميل البيانات...</div>';

    try {
        const { data, error } = await supabaseClient
            .from('feedback')
            .select('*')
            .order('created_at', { ascending: false });

        if (error) throw error;

        allFeedback = data || [];
        updateStats();
        filterFeedback(); 
        initFeedbackCharts();
    } catch (error) {
        if (feedbackList) feedbackList.innerHTML = `<div class="error">❌ خطأ في تحميل البيانات: ${error.message}</div>`;
    }
}

function filterFeedback() {
    const category = document.getElementById('categoryFilter')?.value || '';
    const status = document.getElementById('statusFilter')?.value || '';
    const rating = document.getElementById('ratingFilter')?.value || '';
    const search = document.getElementById('searchInput')?.value.toLowerCase() || '';
    const unrepliedOnly = document.getElementById('unrepliedFilter')?.checked;

    let filtered = allFeedback;

    if (unrepliedOnly) {
        filtered = filtered.filter(f => !f.reply || f.reply.trim() === '');
    }
    if (category) {
        filtered = filtered.filter(f => f.category === category);
    }
    if (status) {
        filtered = filtered.filter(f => f.status === status);
    }
    if (rating) {
        filtered = filtered.filter(f => f.rating >= parseInt(rating));
    }
    if (search) {
        filtered = filtered.filter(f =>
            f.name.toLowerCase().includes(search) ||
            f.email.toLowerCase().includes(search) ||
            f.description.toLowerCase().includes(search)
        );
    }

    displayFeedback(filtered);
}

function displayFeedback(feedback) {
    const feedbackList = document.getElementById('feedbackList');
    if (!feedbackList) return;

    if (feedback.length === 0) {
        feedbackList.innerHTML = `
            <div class="empty-state">
                <div class="empty-state-icon">📭</div>
                <h3>لا توجد شكاوى</h3>
                <p>لم يتم العثور على أي شكاوى بالمعايير المحددة</p>
            </div>
        `;
        return;
    }

    feedbackList.innerHTML = feedback.map(item => `
        <div class="feedback-card">
            <div class="feedback-header">
                <div class="feedback-info">
                    <h3>${item.name || 'مستخدم'}</h3>
                    <p>📧 ${item.email || 'بدون بريد'}</p>
                </div>
                <div style="display: flex; gap: 10px; align-items: center;">
                    <select onchange="updateFeedbackStatus('${item.id}', this.value)" style="padding: 5px; border-radius: 8px; border: 1px solid #ddd; font-size: 0.8rem;">
                        <option value="جديد" ${item.status === 'جديد' ? 'selected' : ''}>🆕 جديد</option>
                        <option value="تم استقبال المشكلة" ${item.status === 'تم استقبال المشكلة' ? 'selected' : ''}>📩 تم الاستقبال</option>
                        <option value="قيد المعالجة" ${item.status === 'قيد المعالجة' ? 'selected' : ''}>⏳ قيد المعالجة</option>
                        <option value="تم الحل" ${item.status === 'تم الحل' ? 'selected' : ''}>✅ تم الحل</option>
                    </select>
                    <span class="category-badge category-${item.category}">${item.category || 'عام'}</span>
                    <button class="delete-btn" onclick="deleteFeedback('${item.id}')">🗑️ حذف</button>
                </div>
            </div>
            
            <div class="feedback-description">
                ${item.description || ''}
            </div>

            ${item.image_urls && item.image_urls.length > 0 ? `
                <div class="images-grid">
                    ${item.image_urls.map(url => `
                        <img src="${url}" alt="صورة" onclick="openModal('${url}')">
                    `).join('')}
                </div>
            ` : ''}

            <div class="feedback-meta">
                <div class="meta-item">
                    📅 ${new Date(item.created_at).toLocaleString('ar-EG')}
                </div>
                ${item.image_urls && item.image_urls.length > 0 ? `
                    <div class="meta-item">
                        🖼️ ${item.image_urls.length} صورة
                    </div>
                ` : ''}
            </div>

            ${item.device_info ? `
                <div class="device-info" style="font-size: 0.8rem; background: rgba(0,0,0,0.05); padding: 8px; border-radius: 6px; margin-top: 10px;">
                    <strong>📱 معلومات الجهاز:</strong>
                    ${item.device_info.os || ''} ${item.device_info.os_version || ''} • 
                    ${item.device_info.model || ''} • 
                    إصدار التطبيق: ${item.device_info.app_version || ''}
                </div>
            ` : ''}

            <div class="admin-notes" style="margin-top: 15px;">
                <strong>📝 ملاحظات الإدارة (داخلية):</strong>
                <textarea id="notes-${item.id}" style="width:100%; height:60px; margin-top:5px; padding:10px; border-radius:8px; border:1px solid #ddd;">${item.admin_notes || ''}</textarea>
                <button class="refresh-btn" style="margin-top:5px; padding:5px 15px; font-size:0.8rem;" onclick="saveAdminNotes('${item.id}')">حفظ الملاحظات</button>
            </div>

            <div class="reply-section" style="margin-top: 15px; border-top: 1px dashed #ddd; padding-top: 10px;">
                <strong>💬 الرد على المستخدم (سيظهر في التطبيق):</strong>
                <textarea id="reply-${item.id}" style="width:100%; height:60px; margin-top:5px; padding:10px; border-radius:8px; border:1px solid #ddd;">${item.reply || ''}</textarea>
                <button class="refresh-btn" style="margin-top:5px; padding:5px 15px; font-size:0.8rem; background:#4f46e5;" onclick="saveFeedbackReply('${item.id}')">إرسال الرد</button>
            </div>
        </div>
    `).join('');
}

async function updateFeedbackStatus(id, newStatus) {
    try {
        const { error } = await supabaseClient
            .from('feedback')
            .update({ status: newStatus })
            .eq('id', id);
        if (error) throw error;
        alert('✅ تم تحديث الحالة بنجاح');
        loadFeedback();
    } catch (e) { alert('❌ فشل تحديث الحالة: ' + e.message); }
}

async function saveAdminNotes(id) {
    const notes = document.getElementById(`notes-${id}`).value;
    try {
        const { error } = await supabaseClient
            .from('feedback')
            .update({ admin_notes: notes })
            .eq('id', id);
        if (error) throw error;
        alert('✅ تم حفظ الملاحظات');
    } catch (e) { alert('❌ فشل الحفظ: ' + e.message); }
}

async function saveFeedbackReply(id) {
    const reply = document.getElementById(`reply-${id}`).value;
    try {
        const { error } = await supabaseClient
            .from('feedback')
            .update({ reply: reply, status: 'تم استقبال المشكلة' })
            .eq('id', id);
        if (error) throw error;
        alert('✅ تم حفظ الرد');
        loadFeedback();
    } catch (e) { alert('❌ فشل الرد: ' + e.message); }
}

async function deleteFeedback(id) {
    if (!confirm('⚠️ حذف هذه الشكوى نهائياً؟')) return;
    try {
        const { error } = await supabaseClient.from('feedback').delete().eq('id', id);
        if (error) throw error;
        loadFeedback();
    } catch (e) { alert('❌ فشل الحذف: ' + e.message); }
}

function updateStats() {
    const total = allFeedback.length;
    const problems = allFeedback.filter(f => f.category === 'مشكلة').length;
    const suggestions = allFeedback.filter(f => f.category === 'اقتراح').length;
    const weekAgo = new Date();
    weekAgo.setDate(weekAgo.getDate() - 7);
    const recent = allFeedback.filter(f => new Date(f.created_at) > weekAgo).length;

    if (document.getElementById('totalCount')) document.getElementById('totalCount').textContent = total;
    if (document.getElementById('problemCount')) document.getElementById('problemCount').textContent = problems;
    if (document.getElementById('suggestionCount')) document.getElementById('suggestionCount').textContent = suggestions;
    if (document.getElementById('recentCount')) document.getElementById('recentCount').textContent = recent;
}

// --- UPDATES MANAGEMENT ---
async function pushUpdate() {
    const versionName = document.getElementById('versionName').value;
    const versionCode = document.getElementById('versionCode').value;
    const isMandatory = document.getElementById('isMandatory').value === 'true';
    const releaseNotes = document.getElementById('releaseNotes').value;

    const urlAndroid = document.getElementById('urlAndroid').value.trim();
    const urlIos = document.getElementById('urlIos').value.trim();
    const urlHuawei = document.getElementById('urlHuawei').value.trim();

    if (!versionName || !versionCode || (!urlAndroid && !urlIos && !urlHuawei)) {
        alert('⚠️ يرجى إكمال الحقول الأساسية ورابط واحد على الأقل');
        return;
    }

    // Bundle URLs into a JSON object
    const updateUrlObj = {
        android: urlAndroid,
        ios: urlIos,
        huawei: urlHuawei
    };
    const updateUrl = JSON.stringify(updateUrlObj);

    try {
        const { error } = await supabaseClient
            .from('app_updates')
            .insert([{
                version_name: versionName,
                version_code: parseInt(versionCode),
                is_mandatory: isMandatory,
                update_url: updateUrl,
                release_notes: releaseNotes
            }]);

        if (error) throw error;

        alert('✅ تم نشر التحديث بنجاح!');
        loadUpdates();

        // Clear form
        document.getElementById('versionName').value = '';
        document.getElementById('versionCode').value = '';
        document.getElementById('urlAndroid').value = '';
        document.getElementById('urlIos').value = '';
        document.getElementById('urlHuawei').value = '';
        document.getElementById('releaseNotes').value = '';
    } catch (error) {
        alert('❌ فشل نشر التحديث: ' + error.message);
    }
}

async function loadUpdates() {
    const updatesList = document.getElementById('updatesList');
    if (!updatesList) return;

    try {
        const { data, error } = await supabaseClient
            .from('app_updates')
            .select('*')
            .order('created_at', { ascending: false });

        if (error) throw error;

        if (data.length === 0) {
            updatesList.innerHTML = '<div class="empty-state">لا يوجد سجل تحديثات حتى الآن.</div>';
            return;
        }

        updatesList.innerHTML = data.map(update => {
            let displayLink = update.update_url;
            let isJson = false;
            try {
                const parsed = JSON.parse(update.update_url);
                if (typeof parsed === 'object') {
                    isJson = true;
                    displayLink = 'متعدد المنصات (JSON)';
                }
            } catch (e) {}

            const versions = isJson ? JSON.parse(update.update_url) : { link: update.update_url };
            
            return `
            <div class="update-item" style="background:var(--card-bg); padding:15px; border-radius:12px; margin-bottom:10px; border:1px solid var(--border-color); display:flex; justify-content:space-between; align-items:center;">
                <div>
                    <div style="display: flex; align-items: center; gap: 10px; margin-bottom: 5px;">
                        <strong style="font-size: 1.1rem; color: var(--accent-color);">V ${update.version_name}</strong>
                        <span class="category-badge" style="background:${update.is_mandatory ? '#fee2e2':'#d1fae5'}; color:${update.is_mandatory ? '#b91c1c':'#065f46'};">
                            ${update.is_mandatory ? 'إجباري' : 'اختياري'}
                        </span>
                        <span style="font-size: 0.8rem; color: #999;">(Build: ${update.version_code})</span>
                    </div>
                    <div style="font-size: 0.85rem; color: #666;">
                        📅 ${new Date(update.created_at).toLocaleDateString('ar-EG')}
                    </div>
                </div>
                <div style="display: flex; gap: 10px; flex-wrap: wrap; justify-content: flex-end;">
                    ${isJson ? `
                        ${versions.android ? `<button class="refresh-btn" onclick="window.open('${versions.android}', '_blank')" style="padding: 5px 10px; font-size:0.7rem;">🤖 Android</button>` : ''}
                        ${versions.ios ? `<button class="refresh-btn" onclick="window.open('${versions.ios}', '_blank')" style="padding: 5px 10px; font-size:0.7rem; background:#000;">🍎 iOS</button>` : ''}
                        ${versions.huawei ? `<button class="refresh-btn" onclick="window.open('${versions.huawei}', '_blank')" style="padding: 5px 10px; font-size:0.7rem; background:#cf0a2c;">🎒 Huawei</button>` : ''}
                    ` : `<button class="refresh-btn" onclick="window.open('${update.update_url}', '_blank')" style="padding: 5px 15px; font-size:0.8rem;">🔗 الرابط</button>`}
                    
                    <button class="delete-btn" onclick="deleteUpdate('${update.id}')">🗑️ حذف</button>
                </div>
            </div>
        `}).join('');
    } catch (error) {
        updatesList.innerHTML = `<div class="error">❌ خطأ: ${error.message}</div>`;
    }
}

async function deleteUpdate(id) {
    if (!confirm('⚠️ حذف سجل التحديث؟')) return;
    try {
        const { error } = await supabaseClient.from('app_updates').delete().eq('id', id);
        if (error) throw error;
        loadUpdates();
    } catch (e) { alert('❌ فشل الحذف: ' + e.message); }
}

// --- ANALYTICS ---
async function loadAnalytics() {
    try {
        const { data: usage, error: uError } = await supabaseClient.from('app_usage').select('*').order('created_at', { ascending: false });
        const { data: features, error: fError } = await supabaseClient.from('feature_usage').select('*');

        if (uError) throw uError;
        allUsageData = usage || [];
        window.featureUsageData = features || [];

        displayAnalyticsStats();
        initAnalyticsCharts();
    } catch (e) { console.error('Analytics load error:', e); }
}

function displayAnalyticsStats() {
    const total = allUsageData.length;
    const uniqueUsers = new Set(allUsageData.map(u => u.device_id)).size;
    const countries = new Set(allUsageData.map(u => u.country)).size;

    if (document.getElementById('totalLaunches')) document.getElementById('totalLaunches').textContent = total;
    if (document.getElementById('uniqueUsers')) document.getElementById('uniqueUsers').textContent = uniqueUsers;
    if (document.getElementById('countriesCount')) document.getElementById('countriesCount').textContent = countries;
}

function initAnalyticsCharts() {
    if (typeof Chart === 'undefined') return;

    // Countries Chart
    const countryCounts = {};
    allUsageData.forEach(u => { const c = u.country || 'أخرى'; countryCounts[c] = (countryCounts[c] || 0) + 1; });
    const sortedCountries = Object.entries(countryCounts).sort((a,b) => b[1]-a[1]).slice(0, 5);

    if (countriesChart) countriesChart.destroy();
    const cCtx = document.getElementById('countriesChart')?.getContext('2d');
    if (cCtx) {
        countriesChart = new Chart(cCtx, {
            type: 'bar',
            data: {
                labels: sortedCountries.map(c => c[0]),
                datasets: [{ label: 'عدد الفتحات', data: sortedCountries.map(c => c[1]), backgroundColor: '#10b981' }]
            },
            options: { indexAxis: 'y', responsive: true, maintainAspectRatio: false }
        });
    }

    // OS Chart
    const osCounts = {};
    allUsageData.forEach(u => { const os = u.os || 'Other'; osCounts[os] = (osCounts[os] || 0) + 1; });
    if (osChart) osChart.destroy();
    const osCtx = document.getElementById('osChart')?.getContext('2d');
    if (osCtx) {
        osChart = new Chart(osCtx, {
            type: 'pie',
            data: {
                labels: Object.keys(osCounts),
                datasets: [{ data: Object.values(osCounts), backgroundColor: ['#3b82f6', '#f59e0b', '#6b7280'] }]
            },
            options: { responsive: true, maintainAspectRatio: false }
        });
    }

    // Daily Usage Chart
    const dailyCounts = {};
    const last15Days = [...Array(15)].map((_, i) => {
        const d = new Date(); d.setDate(d.getDate() - i); return d.toISOString().split('T')[0];
    }).reverse();
    last15Days.forEach(date => dailyCounts[date] = 0);
    allUsageData.forEach(u => {
        const date = new Date(u.created_at).toISOString().split('T')[0];
        if (dailyCounts[date] !== undefined) dailyCounts[date]++;
    });

    if (dailyUsageChart) dailyUsageChart.destroy();
    const dCtx = document.getElementById('dailyUsageChart')?.getContext('2d');
    if (dCtx) {
        dailyUsageChart = new Chart(dCtx, {
            type: 'line',
            data: {
                labels: last15Days.map(d => d.split('-').slice(1).join('/')),
                datasets: [{ label: 'مرات فتح التطبيق', data: last15Days.map(date => dailyCounts[date]), borderColor: '#10b981', backgroundColor: 'rgba(16, 185, 129, 0.1)', fill: true, tension: 0.4 }]
            },
            options: { responsive: true, maintainAspectRatio: false }
        });
    }

    // Features Usage Chart
    const fCounts = {};
    APP_FEATURES.forEach(f => fCounts[f.name] = 0);
    if (window.featureUsageData) {
        window.featureUsageData.forEach(u => {
            const feature = APP_FEATURES.find(f => f.id === u.feature_name);
            const name = feature ? feature.name : u.feature_name;
            fCounts[name] = (fCounts[name] || 0) + 1;
        });
    }
    if (featuresUsageChart) featuresUsageChart.destroy();
    const fCtx = document.getElementById('featuresUsageChart')?.getContext('2d');
    if (fCtx) {
        featuresUsageChart = new Chart(fCtx, {
            type: 'bar',
            data: {
                labels: Object.keys(fCounts),
                datasets: [{ label: 'عدد النقرات', data: Object.values(fCounts), backgroundColor: '#6366f1' }]
            },
            options: { responsive: true, maintainAspectRatio: false }
        });
    }
}

function initFeedbackCharts() {
    if (typeof Chart === 'undefined') return;
    
    // Category Distribution
    const categories = {};
    allFeedback.forEach(f => { categories[f.category || 'عام'] = (categories[f.category || 'عام'] || 0) + 1; });

    if (categoryChart) categoryChart.destroy();
    const catCtx = document.getElementById('categoryChart')?.getContext('2d');
    if (catCtx) {
        categoryChart = new Chart(catCtx, {
            type: 'doughnut',
            data: {
                labels: Object.keys(categories),
                datasets: [{ data: Object.values(categories), backgroundColor: ['#10b981', '#3b82f6', '#f59e0b', '#8b5cf6', '#6b7280'] }]
            },
            options: { responsive: true, maintainAspectRatio: false, plugins: { title: { display: true, text: 'توزيع التصنيفات' } } }
        });
    }

    // Recent Frequency
    const dates = {};
    const last14Days = [...Array(14)].map((_, i) => {
        const d = new Date(); d.setDate(d.getDate() - i); return d.toISOString().split('T')[0];
    }).reverse();
    last14Days.forEach(d => dates[d] = 0);
    allFeedback.forEach(f => {
        const date = new Date(f.created_at).toISOString().split('T')[0];
        if (dates[date] !== undefined) dates[date]++;
    });

    if (frequencyChart) frequencyChart.destroy();
    const freqCtx = document.getElementById('frequencyChart')?.getContext('2d');
    if (freqCtx) {
        frequencyChart = new Chart(freqCtx, {
            type: 'line',
            data: {
                labels: last14Days.map(d => d.split('-').slice(1).join('/')),
                datasets: [{ label: 'الشكاوى', data: Object.values(dates), borderColor: '#10b981', backgroundColor: 'rgba(16, 185, 129, 0.1)', fill: true, tension: 0.4 }]
            },
            options: { responsive: true, maintainAspectRatio: false, plugins: { title: { display: true, text: 'النشاط الأخير' } } }
        });
    }
}

// --- SETTINGS MANAGEMENT ---
async function loadSettings() {
    try {
        const { data, error } = await supabaseClient.from('app_settings').select('*');
        if (error) throw error;
        if (!data) return;

        data.forEach(s => {
            const el = document.getElementById(getSettingElementId(s.key));
            if (!el) return;
            if (el.type === 'checkbox') el.checked = (s.value === 'true');
            else el.value = s.value;
            
            // Sync Color Text
            if (s.key === 'primary_hex_color') {
                const hexText = document.getElementById('themeColorHex');
                if (hexText) hexText.value = s.value;
            }
        });
    } catch (e) { console.error('Settings load error:', e); }
}

function getSettingElementId(key) {
    const map = {
        'maintenance_mode': 'maintenanceToggle',
        'quote_of_the_day': 'quoteInput',
        'quote_active': 'quoteToggle',
        'news_marquee': 'newsInput',
        'news_marquee_label': 'newsLabelInput',
        'news_marquee_type': 'newsTypeInput',
        'news_active': 'newsActiveToggle',
        'min_required_version': 'minAppVersion',
        'primary_hex_color': 'themeColorInput',
        'broadcast_message': 'broadcastInput',
        'broadcast_active': 'broadcastToggle',
        'link_facebook': 'linkFacebook',
        'link_whatsapp': 'linkWhatsapp',
        'link_appstore': 'linkAppStore',
        'link_playstore': 'linkPlayStore',
        'prayer_offset_fajr': 'offsetFajr',
        'prayer_offset_sunrise': 'offsetSunrise',
        'prayer_offset_dhuhr': 'offsetDhuhr',
        'prayer_offset_asr': 'offsetAsr',
        'prayer_offset_maghrib': 'offsetMaghrib',
        'prayer_offset_isha': 'offsetIsha'
    };
    return map[key] || key;
}

async function updateMaintenanceMode(isActive) {
    try {
        const { error } = await supabaseClient.from('app_settings').upsert({ key: 'maintenance_mode', value: isActive.toString() });
        if (error) throw error;
        alert(`✅ تم ${isActive ? 'تفعيل' : 'إيقاف'} وضع الصيانة`);
    } catch (e) { alert('❌ فشل: ' + e.message); }
}

async function updateThemeColor() {
    let color = document.getElementById('themeColorHex').value.trim();
    if (!color.startsWith('#')) color = '#' + color;
    try {
        const { error } = await supabaseClient.from('app_settings').upsert({ key: 'primary_hex_color', value: color });
        if (error) throw error;
        alert('✅ تم تحديث اللون');
    } catch (e) { alert('❌ فشل: ' + e.message); }
}

async function updateNewsMarquee() {
    const news = document.getElementById('newsInput').value;
    const label = document.getElementById('newsLabelInput').value;
    const type = document.getElementById('newsTypeInput').value;
    const active = document.getElementById('newsActiveToggle').checked;
    try {
        await supabaseClient.from('app_settings').upsert([
            { key: 'news_marquee', value: news },
            { key: 'news_marquee_label', value: label },
            { key: 'news_marquee_type', value: type },
            { key: 'news_active', value: active.toString() }
        ]);
        alert('✅ تم تحديث الشريط');
    } catch (e) { alert('❌ فشل: ' + e.message); }
}

async function updateBroadcast() {
    const msg = document.getElementById('broadcastInput').value;
    const active = document.getElementById('broadcastToggle').checked;
    try {
        await supabaseClient.from('app_settings').upsert([
            { key: 'broadcast_message', value: msg },
            { key: 'broadcast_active', value: active.toString() },
            { key: 'broadcast_id', value: Date.now().toString() }
        ]);
        alert('✅ تم النشر');
    } catch (e) { alert('❌ فشل: ' + e.message); }
}

async function updateDailyQuote() {
    const quote = document.getElementById('quoteInput').value;
    const active = document.getElementById('quoteToggle').checked;
    try {
        await supabaseClient.from('app_settings').upsert([
            { key: 'quote_of_the_day', value: quote },
            { key: 'quote_active', value: active.toString() }
        ]);
        alert('✅ تم الحفظ');
    } catch (e) { alert('❌ فشل: ' + e.message); }
}

async function updateSupportLinks() {
    const fb = document.getElementById('linkFacebook').value;
    const wa = document.getElementById('linkWhatsapp').value;
    const as = document.getElementById('linkAppStore').value;
    const ps = document.getElementById('linkPlayStore').value;
    try {
        await supabaseClient.from('app_settings').upsert([
            { key: 'link_facebook', value: fb }, { key: 'link_whatsapp', value: wa },
            { key: 'link_appstore', value: as }, { key: 'link_playstore', value: ps }
        ]);
        alert('✅ تم الحفظ');
    } catch (e) { alert('❌ فشل: ' + e.message); }
}

async function updatePrayerOffsets() {
    const offsets = ['Fajr', 'Sunrise', 'Dhuhr', 'Asr', 'Maghrib', 'Isha'].map(p => ({
        key: `prayer_offset_${p.toLowerCase()}`, value: document.getElementById(`offset${p}`).value
    }));
    try {
        await supabaseClient.from('app_settings').upsert(offsets);
        alert('✅ تم حفظ المواقيت');
    } catch (e) { alert('❌ فشل: ' + e.message); }
}

async function updateMinVersion() {
    const ver = document.getElementById('minAppVersion').value;
    try {
        await supabaseClient.from('app_settings').upsert({ key: 'min_required_version', value: ver });
        alert('✅ تم التحديث');
    } catch (e) { alert('❌ فشل: ' + e.message); }
}

// --- BANNERS MANAGEMENT ---
async function loadBanners() {
    const list = document.getElementById('bannersList');
    if (list) list.innerHTML = '<div class="loading">⏳ جاري تحميل البانرات...</div>';
    try {
        const { data, error } = await supabaseClient.from('banners').select('*').order('created_at', { ascending: false });
        if (error) throw error;
        if (data.length === 0) { list.innerHTML = '<div class="no-data">ℹ️ لا توجد بانرات</div>'; return; }
        list.innerHTML = data.map(b => `
            <div class="update-item" style="display: flex; gap: 20px; align-items: center; background: var(--card-bg); border: 1px solid var(--border-color); border-radius: 12px; padding: 15px; margin-bottom: 15px;">
                <img src="${b.image_url}" style="width: 150px; height: 80px; object-fit: cover; border-radius: 10px;">
                <div style="flex: 1;">
                    <h4 style="color: var(--text-primary);">${b.title || 'بدون عنوان'}</h4>
                    <div style="font-size: 0.8rem; color: var(--text-secondary);">🔗 ${b.link_url || 'لا يوجد رابط'}</div>
                    <div style="display: flex; gap: 10px; margin-top:10px;">
                        <button class="refresh-btn" onclick="toggleBannerActive('${b.id}', ${b.is_active})" style="background: ${b.is_active ? '#6b7280' : 'var(--accent-color)'}; font-size:0.8rem; padding:5px 12px;">
                            ${b.is_active ? '👁️ إخفاء' : '👁️ إظهار'}
                        </button>
                        <button class="delete-btn" onclick="deleteBanner('${b.id}')" style="font-size:0.8rem; padding:5px 12px;">🗑️ حذف</button>
                    </div>
                </div>
            </div>
        `).join('');
    } catch (e) { list.innerHTML = '<div class="no-data">❌ خطأ في التحميل</div>'; }
}

async function uploadBanner() {
    const fileInput = document.getElementById('bannerFile');
    const title = document.getElementById('bannerTitle').value;
    const link = document.getElementById('bannerLink').value;
    const progressBar = document.getElementById('progressBar');
    const pContainer = document.getElementById('uploadProgress');

    if (fileInput.files.length === 0) { alert('⚠️ يرجى اختيار صورة'); return; }

    const file = fileInput.files[0];
    const fileName = `${Math.random().toString(36).substring(2)}_${Date.now()}.${file.name.split('.').pop()}`;
    const filePath = `ads/${fileName}`;

    if (pContainer) pContainer.style.display = 'block';
    if (progressBar) progressBar.style.width = '10%';

    try {
        const { error: uError } = await supabaseClient.storage.from('banners_storage').upload(filePath, file);
        if (uError) throw uError;
        if (progressBar) progressBar.style.width = '60%';

        const { data: { publicUrl } } = supabaseClient.storage.from('banners_storage').getPublicUrl(filePath);
        await supabaseClient.from('banners').insert([{ title, image_url: publicUrl, link_url: link, is_active: true }]);

        if (progressBar) progressBar.style.width = '100%';
        setTimeout(() => { if (pContainer) pContainer.style.display = 'none'; }, 1000);
        alert('✅ تم رفع البانر بنجاح');
        fileInput.value = '';
        loadBanners();
    } catch (e) { alert('❌ فشل الرفع: ' + e.message); if (pContainer) pContainer.style.display = 'none'; }
}

async function deleteBanner(id) {
    if (!confirm('⚠️ حذف البانر؟')) return;
    try {
        await supabaseClient.from('banners').delete().eq('id', id);
        loadBanners();
    } catch (e) { alert('❌ فشل: ' + e.message); }
}

async function toggleBannerActive(id, currentStatus) {
    try {
        await supabaseClient.from('banners').update({ is_active: !currentStatus }).eq('id', id);
        loadBanners();
    } catch (e) { alert('❌ فشل: ' + e.message); }
}

// --- FEATURE CONTROL ---
async function loadFeatures() {
    const grid = document.getElementById('featuresGrid');
    if (!grid) return;
    grid.innerHTML = '<div class="loading">⏳ جاري التحميل...</div>';
    try {
        const { data, error } = await supabaseClient.from('app_features').select('*');
        if (error) throw error;
        
        // Create a map for easier lookup: feature_name -> status
        const featureStatusMap = {};
        if (data) {
             data.forEach(item => {
                 featureStatusMap[item.feature_name] = item.status;
             });
        }

        grid.innerHTML = APP_FEATURES.map(f => {
            const status = featureStatusMap[f.id] || 'active';
            return `
                <div class="update-item" style="flex-direction: column; align-items: flex-start; gap: 15px;">
                    <div style="display: flex; align-items: center; gap: 12px; width: 100%;">
                        <span style="font-size: 1.5rem;">${f.icon}</span>
                        <span style="font-weight: bold; flex: 1; color: var(--text-primary); text-align:right;">${f.name}</span>
                        <span class="category-badge" style="background: ${status === 'active' ? '#d1fae5' : status === 'maintenance' ? '#fef3c7' : '#f3f4f6'}; color: ${status === 'active' ? '#065f46' : status === 'maintenance' ? '#92400e' : '#374151'};">
                            ${status === 'active' ? 'نشط' : status === 'maintenance' ? 'صيانة' : 'مخفي'}
                        </span>
                    </div>
                    <select onchange="updateFeatureStatus('${f.id}', this.value)" style="width: 100%; padding: 10px; border-radius: 8px; border: 1px solid var(--border-color); background: var(--card-bg); color: var(--text-primary);">
                        <option value="active" ${status === 'active' ? 'selected' : ''}>🟢 نشط</option>
                        <option value="maintenance" ${status === 'maintenance' ? 'selected' : ''}>🟠 صيانة</option>
                        <option value="hidden" ${status === 'hidden' ? 'selected' : ''}>⚪ مخفي</option>
                    </select>
                </div>
            `;
        }).join('');
    } catch (e) { grid.innerHTML = '<div class="no-data">❌ فشل تحميل البيانات</div>'; }
}

async function updateFeatureStatus(featureId, newStatus) {
    try {
        const { error } = await supabaseClient
            .from('app_features')
            .upsert({ feature_name: featureId, status: newStatus }, { onConflict: 'feature_name' });

        if (error) throw error;
        loadFeatures();
    } catch (e) { alert('❌ فشل: ' + e.message); }
}

// --- RADIOS MANAGEMENT ---
async function loadRadios() {
    const list = document.getElementById('radioList');
    if (!list) return;
    try {
        const { data, error } = await supabaseClient.from('custom_radios').select('*').order('created_at', { ascending: false });
        if (error) throw error;
        if (data.length === 0) { list.innerHTML = '<div class="empty-state">لا توجد إذاعات مخصصة</div>'; return; }
        list.innerHTML = data.map(r => `
            <div class="update-item" style="border-right: 5px solid ${r.is_active ? 'var(--accent-color)' : '#ccc'};">
                <div style="flex: 1; text-align:right;">
                    <h4 style="margin: 0; color: var(--text-primary);">${r.name}</h4>
                    <div style="font-size: 0.8rem; color: var(--text-secondary); word-break: break-all;" dir="ltr">🔗 ${r.url}</div>
                </div>
                <div style="display: flex; gap: 10px; margin-right: 20px;">
                    <button class="refresh-btn" onclick="toggleRadioActive('${r.id}', ${r.is_active})" style="background: ${r.is_active ? '#10b981' : '#6b7280'}; font-size:0.8rem; padding:5px 12px;">
                        ${r.is_active ? ' نشط' : ' معطل'}
                    </button>
                    <button class="delete-btn" onclick="deleteRadio('${r.id}')" style="font-size:0.8rem; padding:5px 12px;">🗑️ حذف</button>
                </div>
            </div>
        `).join('');
    } catch (e) { console.error(e); }
}

async function addCustomRadio() {
    const name = document.getElementById('radioName').value;
    const url = document.getElementById('radioUrl').value;
    if (!name || !url) return alert('⚠️ يرجى إدخال الاسم والرابط');
    try {
        await supabaseClient.from('custom_radios').insert([{ name, url, is_active: true }]);
        alert('✅ تم إضافة الإذاعة');
        document.getElementById('radioName').value = '';
        document.getElementById('radioUrl').value = '';
        loadRadios();
    } catch (e) { alert('❌ فشل: ' + e.message); }
}

async function toggleRadioActive(id, currentStatus) {
    try {
        await supabaseClient.from('custom_radios').update({ is_active: !currentStatus }).eq('id', id);
        loadRadios();
    } catch (e) { alert('❌ فشل: ' + e.message); }
}

async function deleteRadio(id) {
    if (!confirm('حذف الإذاعة؟')) return;
    try {
        await supabaseClient.from('custom_radios').delete().eq('id', id);
        loadRadios();
    } catch (e) { alert('❌ فشل: ' + e.message); }
}

// --- CONTENT MANAGEMENT (CMS) ---
async function loadContent() {
    const list = document.getElementById('contentList');
    if (!list) return;
    try {
        const { data, error } = await supabaseClient.from('app_content').select('*').order('created_at', { ascending: false });
        if (error) throw error;
        if (data.length === 0) { list.innerHTML = '<div class="empty-state">لا يوجد محتوى</div>'; return; }
        list.innerHTML = data.map(item => `
            <div class="feedback-card" style="border-right: 5px solid ${item.is_active ? 'var(--accent-color)' : '#ccc'};">
                <div style="display: flex; justify-content: space-between; align-items: start;">
                    <div>
                        <h3 style="margin-bottom: 5px;">${item.title}</h3>
                        <span class="category-badge" style="background: #e0f2fe; color: #0284c7;">${item.type}</span>
                    </div>
                    <div style="display: flex; gap: 10px;">
                        <button class="refresh-btn" onclick="toggleContentActive('${item.id}', ${item.is_active})" style="padding: 5px 10px; font-size: 0.8rem; background: ${item.is_active ? '#6b7280' : 'var(--accent-color)'};">
                            ${item.is_active ? '👁️ إخفاء' : '👁️ إظهار'}
                        </button>
                        <button class="delete-btn" onclick="deleteContent('${item.id}')">🗑️ حذف</button>
                    </div>
                </div>
                <p style="margin-top: 10px; color: var(--text-secondary); line-height: 1.6;">${item.body}</p>
                ${item.image_url ? `<img src="${item.image_url}" style="margin-top: 10px; height: 100px; border-radius: 8px;">` : ''}
            </div>
        `).join('');
    } catch (e) { console.error(e); }
}

async function publishContent() {
    const title = document.getElementById('contentTitle').value;
    const body = document.getElementById('contentBody').value;
    const type = document.getElementById('contentType').value;
    const image = document.getElementById('contentImage').value;
    if (!title || !body) return alert('⚠️ يرجى كتابة العنوان والمحتوى');
    try {
        await supabaseClient.from('app_content').insert([{ title, body, type, image_url: image || null, is_active: true }]);
        alert('✅ تم نشر المحتوى');
        document.getElementById('contentTitle').value = '';
        document.getElementById('contentBody').value = '';
        document.getElementById('contentImage').value = '';
        loadContent();
    } catch (e) { alert('❌ فشل: ' + e.message); }
}

async function deleteContent(id) {
    if (!confirm('⚠️ حذف المحتوى؟')) return;
    try {
        await supabaseClient.from('app_content').delete().eq('id', id);
        loadContent();
    } catch (e) { alert('❌ فشل: ' + e.message); }
}

async function toggleContentActive(id, currentStatus) {
    try {
        await supabaseClient.from('app_content').update({ is_active: !currentStatus }).eq('id', id);
        loadContent();
    } catch (e) { alert('❌ فشل: ' + e.message); }
}

// --- KIDS STORIES ---
async function loadKidsStories() {
    const list = document.getElementById('kidsStoriesList');
    if (!list) return;
    try {
        const { data, error } = await supabaseClient.from('kids_stories').select('*').order('created_at', { ascending: false });
        if (error) throw error;
        if (data.length === 0) { list.innerHTML = '<div class="empty-state">لا توجد قصص</div>'; return; }
        list.innerHTML = data.map(story => `
            <div class="feedback-card" style="border-right: 5px solid ${story.is_visible ? 'var(--accent-color)' : '#ccc'};">
                <div style="display: flex; justify-content: space-between; align-items: start;">
                    <div style="display: flex; gap: 15px; align-items: center;">
                        <span style="font-size: 2rem;">${story.emoji}</span>
                        <div><h3>${story.title}</h3><span class="category-badge" style="background: #fef3c7; color: #d97706;">⭐ ${story.stars_reward} نجمة</span></div>
                    </div>
                    <div style="display: flex; gap: 10px;">
                        <button class="refresh-btn" onclick="toggleKidsStoryVisibility('${story.id}', ${story.is_visible})" style="padding: 5px 10px; font-size: 0.8rem; background: ${story.is_visible ? '#6b7280' : 'var(--accent-color)'};">
                            ${story.is_visible ? '👁️ إخفاء' : '👁️ إظهار'}
                        </button>
                        <button class="delete-btn" onclick="deleteKidsStory('${story.id}')">🗑️ حذف</button>
                    </div>
                </div>
            </div>
        `).join('');
    } catch (e) { console.error(e); }
}

async function addKidsStory() {
    const title = document.getElementById('kidsStoryTitle').value;
    const emoji = document.getElementById('kidsStoryEmoji').value;
    const stars = parseInt(document.getElementById('kidsStoryStars').value);
    const content = document.getElementById('kidsStoryParagraphs').value;
    const moral = document.getElementById('kidsStoryMoral').value;
    if (!title || !content || !moral) return alert('⚠️ يرجى تعبئة الحقول');
    const paragraphs = content.split('\n').map(p => p.trim()).filter(p => p.length > 0);
    try {
        await supabaseClient.from('kids_stories').insert([{ title, emoji: emoji || '📖', stars_reward: stars, paragraphs, content, moral, is_visible: true }]);
        alert('✅ تم إضافة القصة');
        ['kidsStoryTitle','kidsStoryEmoji','kidsStoryParagraphs','kidsStoryMoral'].forEach(id => document.getElementById(id).value = '');
        loadKidsStories();
    } catch (e) { alert('❌ فشل: ' + e.message); }
}

async function toggleKidsStoryVisibility(id, currentStatus) {
    try {
        await supabaseClient.from('kids_stories').update({ is_visible: !currentStatus }).eq('id', id);
        loadKidsStories();
    } catch (e) { alert('❌ فشل: ' + e.message); }
}

async function deleteKidsStory(id) {
    if (!confirm('حذف القصة؟')) return;
    try {
        await supabaseClient.from('kids_stories').delete().eq('id', id);
        loadKidsStories();
    } catch (e) { alert('❌ فشل: ' + e.message); }
}

// --- CHARITY STORIES ---
async function loadCharityStories() {
    const list = document.getElementById('charityStoriesList');
    if (!list) return;
    try {
        const { data, error } = await supabaseClient.from('charity_stories').select('*').order('created_at', { ascending: false });
        if (error) throw error;
        if (data.length === 0) { list.innerHTML = '<div class="empty-state">لا توجد قصص</div>'; return; }
        list.innerHTML = data.map(story => `
            <div class="feedback-card" style="border-right: 5px solid ${story.is_visible ? 'var(--accent-color)' : '#ccc'};">
                <div style="display: flex; justify-content: space-between; align-items: start;">
                    <div style="display: flex; gap: 15px; align-items: center;">
                        <span style="font-size: 2rem;">${story.emoji}</span>
                        <div><h3>${story.title}</h3><span class="category-badge" style="background: #e0f2fe; color: #0284c7;">${story.category}</span></div>
                    </div>
                    <div style="display: flex; gap: 10px;">
                        <button class="refresh-btn" onclick="toggleCharityStoryVisibility('${story.id}', ${story.is_visible})" style="padding: 5px 10px; font-size: 0.8rem; background: ${story.is_visible ? '#6b7280' : 'var(--accent-color)'};">
                            ${story.is_visible ? '👁️ إخفاء' : '👁️ إظهار'}
                        </button>
                        <button class="delete-btn" onclick="deleteCharityStory('${story.id}')">🗑️ حذف</button>
                    </div>
                </div>
                <p style="margin-top: 15px; color: var(--text-primary); line-height: 1.8;">${story.content}</p>
            </div>
        `).join('');
    } catch (e) { console.error(e); }
}

async function addCharityStory() {
    const title = document.getElementById('charityStoryTitle').value;
    const category = document.getElementById('charityStoryCategory').value;
    const emoji = document.getElementById('charityStoryEmoji').value;
    const content = document.getElementById('charityStoryContent').value;
    const source = document.getElementById('charityStorySource').value;
    if (!title || !content || !source) return alert('⚠️ يرجى تعبئة الحقول');
    try {
        await supabaseClient.from('charity_stories').insert([{ title, category, emoji: emoji || '🤲', content, source, is_visible: true }]);
        alert('✅ تم إضافة القصة');
        ['charityStoryTitle','charityStoryContent','charityStorySource'].forEach(id => document.getElementById(id).value = '');
        loadCharityStories();
    } catch (e) { alert('❌ فشل: ' + e.message); }
}

async function toggleCharityStoryVisibility(id, currentStatus) {
    try {
        await supabaseClient.from('charity_stories').update({ is_visible: !currentStatus }).eq('id', id);
        loadCharityStories();
    } catch (e) { alert('❌ فشل: ' + e.message); }
}

async function deleteCharityStory(id) {
    if (!confirm('حذف القصة؟')) return;
    try {
        await supabaseClient.from('charity_stories').delete().eq('id', id);
        loadCharityStories();
    } catch (e) { alert('❌ فشل: ' + e.message); }
}

// --- ERROR LOGS ---
async function loadErrors() {
    const errorsList = document.getElementById('errorsList');
    if (!errorsList) return;
    try {
        const { data, error } = await supabaseClient.from('error_logs').select('*').order('created_at', { ascending: false });
        if (error) throw error;
        if (data.length === 0) { errorsList.innerHTML = '<div class="loading">✅ لا توجد أخطاء مسجلة</div>'; return; }
        errorsList.innerHTML = data.map(err => `
            <div class="update-item" style="border-left: 5px solid #ff4444; position: relative; flex-direction:column; align-items:flex-start;">
                <button class="delete-btn" onclick="deleteError('${err.id}')" style="position: absolute; left: 15px; top: 15px; background: none; border: none; font-size: 1.2rem; cursor: pointer; color: #ff4444;">🗑️</button>
                <h4 style="color: var(--text-primary); margin-bottom: 5px;">${err.message.substring(0, 100)}${err.message.length > 100 ? '...' : ''}</h4>
                <small style="color: #888;">📅 ${new Date(err.created_at).toLocaleString('ar-EG')}</small>
                <div style="margin-top: 10px;">
                    <details><summary style="cursor:pointer; color:#3b82f6;">عرض تفاصيل الخطأ (Stack Trace)</summary>
                    <pre style="background: #1e1e1e; color: #d4d4d4; padding: 15px; border-radius: 8px; font-size: 0.75rem; overflow-x: auto; margin-top: 10px; text-align: left; direction: ltr;">${err.stack_trace}</pre></details>
                </div>
            </div>
        `).join('');
    } catch (e) { errorsList.innerHTML = `<div class="error">❌ خطأ: ${e.message}</div>`; }
}

async function deleteError(id) {
    if (!confirm('⚠️ حذف السجل؟')) return;
    try { await supabaseClient.from('error_logs').delete().eq('id', id); loadErrors(); } catch (e) { alert('❌ فشل: ' + e.message); }
}

// --- MODALS & UTILS ---
function openModal(url) {
    const modalImage = document.getElementById('modalImage');
    const imageModal = document.getElementById('imageModal');
    if (modalImage && imageModal) {
        modalImage.src = url;
        imageModal.classList.add('active');
        imageModal.style.display = 'flex';
    }
}

function closeModal() {
    const imageModal = document.getElementById('imageModal');
    if (imageModal) {
        imageModal.classList.remove('active');
        imageModal.style.display = 'none';
    }
}

function resetThemeColor() {
    if (!confirm('العودة للون الأصلي؟')) return;
    updateThemeColor('#178B74');
}

async function exportToCSV() {
    if (allFeedback.length === 0) return;
    const headers = ['الاسم', 'البريد', 'التصنيف', 'الوصف', 'التاريخ', 'الجهاز'];
    const rows = allFeedback.map(f => [
        f.name || '', f.email || '', f.category || '', (f.description || '').replace(/\n/g, ' '),
        new Date(f.created_at).toLocaleString(), f.device_info ? `${f.device_info.model} (${f.device_info.os})` : ''
    ]);
    let csvContent = "data:text/csv;charset=utf-8,\uFEFF" + headers.join(",") + "\n" + rows.map(r => r.map(c => `"${c}"`).join(",")).join("\n");
    const link = document.createElement("a");
    link.setAttribute("href", encodeURI(csvContent));
    link.setAttribute("download", `feedback_report_${new Date().toLocaleDateString()}.csv`);
    document.body.appendChild(link); link.click(); document.body.removeChild(link);
}

function setStatusFilter(status, el) {
    const filterEl = document.getElementById('statusFilter');
    if (filterEl) filterEl.value = status;
    document.querySelectorAll('.status-tab').forEach(tab => tab.classList.remove('active'));
    if (el) el.classList.add('active');
    filterFeedback();
}
