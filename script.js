/**
 * RAFUIQ ELMUSLIM ADMIN DASHBOARD - Consolidated Logic
 * All dashboard features are now centralized here.
 */

// Supabase Configuration
const SUPABASE_URL = 'https://kghwboxevphvxtsagrer.supabase.co';
const SUPABASE_ANON_KEY = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImtnaHdib3hldnBodnh0c2FncmVyIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjYxMjcwNzUsImV4cCI6MjA4MTcwMzA3NX0.PPh6rwxDbHGHHyHBUjdEz1WWdF_psdygbtF0nY5hNR4';
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

// Security: HTML Escape Function to prevent XSS
function escapeHtml(text) {
    if (!text) return '';
    const map = {
        '&': '&amp;',
        '<': '&lt;',
        '>': '&gt;',
        '"': '&quot;',
        "'": '&#039;'
    };
    return text.replace(/[&<>"']/g, m => map[m]);
}

const APP_FEATURES = [
    { id: 'quranView', name: 'القرآن الكريم', icon: '📖' },
    { id: 'azkar', name: 'الأذكار', icon: '📿' },
    { id: 'sebha', name: 'السبحة الإلكترونية', icon: '🖱️' },
    { id: 'khatmah', name: 'الختمات الجماعية', icon: '🕋' },
    { id: 'zakat', name: 'حساب الزكاة', icon: '💰' },
    { id: 'inheritance', name: 'المواريث', icon: '⚖️' },
    { id: 'expiation', name: 'الكفارات', icon: '🤲' },
    { id: 'wird', name: 'الورد اليومي', icon: '📅' },
    { id: 'radioView', name: 'إذاعات القرآن', icon: '📻' },
    { id: 'kids', name: 'ركن الأطفال', icon: '👶' },
    { id: 'hadith', name: 'كتب الحديث', icon: '📚' },
    { id: 'mosques', name: 'المساجد القريبة', icon: '🕌' },
    { id: 'timing', name: 'مواقيت الصلاة', icon: '🕋' },
    { id: 'qibla', name: 'القبلة', icon: '🧭' },
    { id: 'fajr_alarm', name: 'منبه الفجر', icon: '⏰' }
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
        
        const role = localStorage.getItem('dashboardRole') || 'admin';
        applyUserPermissions(role);
        
        if (role === 'admin') {
            initializeDashboard();
        } else {
            switchTab('communities');
            loadCommunities();
        }
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

// Sidebar Navigation Functions
function toggleSidebarCollapse() {
    const sidebar = document.getElementById('sidebar');
    const mainContent = document.getElementById('mainContent');
    if (sidebar) {
        sidebar.classList.toggle('collapsed');
    }
    if (mainContent) {
        mainContent.classList.toggle('sidebar-collapsed');
    }
}

function toggleMobileSidebar() {
    const sidebar = document.getElementById('sidebar');
    if (sidebar) {
        sidebar.classList.toggle('active');
    }
}

function closeMobileSidebar() {
    const sidebar = document.getElementById('sidebar');
    if (sidebar && window.innerWidth <= 768) {
        sidebar.classList.remove('active');
    }
}

// Analytics Toggle
function toggleAnalytics() {
    const section = document.getElementById('analyticsSection');
    const btn = document.getElementById('analyticsToggle');
    if (section) {
        const isHidden = section.style.display === 'none';
        section.style.display = isHidden ? 'block' : 'none';
        if (btn) {
            btn.textContent = isHidden ? '📊 إخفاء الإحصائيات' : '📊 عرض الإحصائيات';
        }
        if (isHidden) {
            initFeedbackCharts();
        }
    }
}

function initializeDashboard() {
    loadFeedback();
    loadUpdates();
    loadAnalytics();
    loadSettings();
    loadErrors();
    loadCharityStories();
    loadFeatures(); // Load features control
    loadPdfBooks(); // Load PDF books

    // Auto-refresh every 60 seconds
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
    }, 60000);
}

// --- AUTHENTICATION ---

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

function checkAuth() {
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
}

function logoutAdmin() {
    if (confirm('هل أنت متأكد من رغبتك في تسجيل الخروج؟')) {
        localStorage.removeItem('dashboardAuth');
        location.reload();
    }
}

// --- NAVIGATION ---
function switchTab(tabId) {
    console.log('Switching to tab:', tabId);

    // Hide all tabs
    document.querySelectorAll('.tab-content').forEach(tab => tab.classList.remove('active'));
    document.querySelectorAll('.sidebar-item').forEach(btn => btn.classList.remove('active'));

    // Show selected tab
    const content = document.getElementById(tabId + 'Tab');
    const btn = document.getElementById(tabId + 'TabBtn');

    if (content && btn) {
        content.classList.add('active');
        btn.classList.add('active');
    } else {
        console.warn('Tab elements not found for:', tabId);
    }

    // Close mobile sidebar after tab selection
    closeMobileSidebar();

    // Load specific data per tab if needed
    switch (tabId) {
        case 'analytics': loadAnalytics(); break;
        case 'features': loadFeatures(); break;
        case 'content': loadContent(); break;
        case 'kidsStories': loadKidsStories(); break;
        case 'charityStories': loadCharityStories(); break;
        case 'radio': loadRadios(); break;
        case 'banners': loadBanners(); break;
        case 'khatmah': loadKhatmahCampaigns(); break;
        case 'updates': loadUpdates(); break;
        case 'errors': loadErrors(); break;
        case 'settings': loadSettings(); break;
        case 'mosques': loadMosques(); break;
        case 'pdfBooks': loadPdfBooks(); break;
        case 'communities': loadCommunities(); break;
        case 'communityUsers': loadCommunityUsers(); break;
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
    const startDate = document.getElementById('startDate')?.value || '';
    const endDate = document.getElementById('endDate')?.value || '';

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
    if (startDate) {
        const start = new Date(startDate);
        filtered = filtered.filter(f => new Date(f.created_at) >= start);
    }
    if (endDate) {
        const end = new Date(endDate);
        end.setHours(23, 59, 59, 999);
        filtered = filtered.filter(f => new Date(f.created_at) <= end);
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
                    <h3>${escapeHtml(item.name) || 'مستخدم'}</h3>
                    <p>📧 ${escapeHtml(item.email) || 'بدون بريد'}</p>
                </div>
                <div style="display: flex; gap: 10px; align-items: center;">
                    <select onchange="updateFeedbackStatus('${item.id}', this.value)" style="padding: 5px; border-radius: 8px; border: 1px solid #ddd; font-size: 0.8rem;">
                        <option value="جديد" ${item.status === 'جديد' ? 'selected' : ''}>🆕 جديد</option>
                        <option value="تم استقبال المشكلة" ${item.status === 'تم استقبال المشكلة' ? 'selected' : ''}>📩 تم الاستقبال</option>
                        <option value="قيد المعالجة" ${item.status === 'قيد المعالجة' ? 'selected' : ''}>⏳ قيد المعالجة</option>
                        <option value="تم الحل" ${item.status === 'تم الحل' ? 'selected' : ''}>✅ تم الحل</option>
                    </select>
                    <span class="category-badge category-${item.category}">${escapeHtml(item.category) || 'عام'}</span>
                    <button class="delete-btn" onclick="deleteFeedback('${item.id}')">🗑️ حذف</button>
                </div>
            </div>

            <div class="feedback-description">
                ${escapeHtml(item.description) || ''}
            </div>

            ${item.image_urls && item.image_urls.length > 0 ? `
                <div class="images-grid">
                    ${item.image_urls.map(url => `
                        <img src="${escapeHtml(url)}" alt="صورة" onclick="openModal('${escapeHtml(url)}')">
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
                    ${escapeHtml(item.device_info.os || '')} ${escapeHtml(item.device_info.os_version || '')} •
                    ${escapeHtml(item.device_info.model || '')} •
                    إصدار التطبيق: ${escapeHtml(item.device_info.app_version || '')}
                </div>
            ` : ''}

            <div class="admin-notes" style="margin-top: 15px;">
                <strong>📝 ملاحظات الإدارة (داخلية):</strong>
                <textarea id="notes-${item.id}" style="width:100%; height:60px; margin-top:5px; padding:10px; border-radius:8px; border:1px solid #ddd;">${escapeHtml(item.admin_notes) || ''}</textarea>
                <button class="refresh-btn" style="margin-top:5px; padding:5px 15px; font-size:0.8rem;" onclick="saveAdminNotes('${item.id}')">حفظ الملاحظات</button>
            </div>

            <div class="reply-section" style="margin-top: 15px; border-top: 1px dashed #ddd; padding-top: 10px;">
                <strong>💬 الرد على المستخدم (سيظهر في التطبيق):</strong>
                <textarea id="reply-${item.id}" style="width:100%; height:60px; margin-top:5px; padding:10px; border-radius:8px; border:1px solid #ddd;">${escapeHtml(item.reply) || ''}</textarea>
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
    if (!reply.trim()) {
        alert('⚠️ يرجى كتابة الرد أولاً');
        return;
    }
    try {
        const { error } = await supabaseClient
            .from('feedback')
            .update({ reply: reply, status: 'تم استقبال المشكلة' })
            .eq('id', id);
        if (error) throw error;

        // تحديث البيانات محلياً مباشرة
        const feedbackItem = allFeedback.find(f => f.id === id);
        if (feedbackItem) {
            feedbackItem.reply = reply;
            feedbackItem.status = 'تم استقبال المشكلة';
        }

        alert('✅ تم إرسال الرد للمستخدم');
        loadFeedback();
    } catch (e) { alert('❌ فشل الرد: ' + e.message); }
}

async function deleteFeedback(id) {
    if (!confirm('⚠️ هل أنت متأكد من حذف هذه الشكوى نهائياً؟')) return;
    
    try {
        const { error, count } = await supabaseClient
            .from('feedback')
            .delete({ count: 'exact' })
            .eq('id', id);

        if (error) throw error;

        if (count === 0) {
            alert('⚠️ لم يتم الحذف! \n\nهذا غالباً بسبب إعدادات الحماية (RLS) في Supabase. يجب عليك تفعيل صلاحية الـ DELETE لجدول feedback من لوحة تحكم Supabase.');
            return;
        }

        alert('✅ تم الحذف بنجاح');
        await loadFeedback();
    } catch (e) {
        alert('❌ فشل الحذف: ' + e.message);
    }
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
            } catch (e) { }

            const versions = isJson ? JSON.parse(update.update_url) : { link: update.update_url };

            return `
            <div class="update-item" style="background:var(--card-bg); padding:15px; border-radius:12px; margin-bottom:10px; border:1px solid var(--border-color); display:flex; justify-content:space-between; align-items:center;">
                <div>
                    <div style="display: flex; align-items: center; gap: 10px; margin-bottom: 5px;">
                        <strong style="font-size: 1.1rem; color: var(--accent-color);">V ${update.version_name}</strong>
                        <span class="category-badge" style="background:${update.is_mandatory ? '#fee2e2' : '#d1fae5'}; color:${update.is_mandatory ? '#b91c1c' : '#065f46'};">
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
        alert('✅ تم حذف التحديث بنجاح');
        loadUpdates();
    } catch (e) { alert('❌ فشل الحذف: ' + e.message); }
}

async function updateAppUpdate(id) {
    const versionName = document.getElementById('editVersionName')?.value;
    const versionCode = document.getElementById('editVersionCode')?.value;
    const isMandatory = document.getElementById('editIsMandatory')?.value === 'true';
    const releaseNotes = document.getElementById('editReleaseNotes')?.value;
    const urlAndroid = document.getElementById('editUrlAndroid')?.value.trim();
    const urlIos = document.getElementById('editUrlIos')?.value.trim();
    const urlHuawei = document.getElementById('editUrlHuawei')?.value.trim();

    if (!versionName || !versionCode || (!urlAndroid && !urlIos && !urlHuawei)) {
        alert('⚠️ يرجى إكمال الحقول الأساسية ورابط واحد على الأقل');
        return;
    }

    const updateUrlObj = {
        android: urlAndroid,
        ios: urlIos,
        huawei: urlHuawei
    };
    const updateUrl = JSON.stringify(updateUrlObj);

    try {
        const { error } = await supabaseClient
            .from('app_updates')
            .update({
                version_name: versionName,
                version_code: parseInt(versionCode),
                is_mandatory: isMandatory,
                update_url: updateUrl,
                release_notes: releaseNotes
            })
            .eq('id', id);

        if (error) throw error;

        alert('✅ تم تحديث البيانات بنجاح');
        loadUpdates();
    } catch (error) {
        alert('❌ فشل التحديث: ' + error.message);
    }
}

// --- ANALYTICS ---
async function loadAnalytics() {
    try {
        const { data: usage, error: uError } = await supabaseClient.from('app_usage').select('*').order('created_at', { ascending: false });
        const { data: features, error: fError } = await supabaseClient.from('feature_usage').select('*');

        if (uError) throw uError;

        // تنظيف البيانات: إزالة العناصر بدون معلومات أساسية
        allUsageData = (usage || []).filter(u => u.device_id && u.created_at);
        window.featureUsageData = features || [];

        displayAnalyticsStats();
        initAnalyticsCharts();
    } catch (e) { console.error('Analytics load error:', e); }
}

function displayAnalyticsStats() {
    const total = allUsageData.length;
    const uniqueUsers = new Set(allUsageData.map(u => u.device_id)).size;

    // احسب الدول بعد تطبيع الأسماء (حتى يكون دقيقاً)
    const normalizedCountries = new Set(allUsageData.map(u => normalizeCountryName(u.country)));
    const countries = normalizedCountries.size;

    if (document.getElementById('totalLaunches')) document.getElementById('totalLaunches').textContent = total;
    if (document.getElementById('uniqueUsers')) document.getElementById('uniqueUsers').textContent = uniqueUsers;
    if (document.getElementById('countriesCount')) document.getElementById('countriesCount').textContent = countries;
}

function normalizeCountryName(name) {
    if (!name || name === 'Unknown' || name === 'أخرى' || name === 'تحديد تلقائي' || name === 'Default' || name.trim() === '') return 'غير معروف';

    const n = name.trim();
    const mapping = {
        'Egypt': 'مصر', 'EG': 'مصر', 'egypt': 'مصر',
        'Saudi Arabia': 'السعودية', 'SA': 'السعودية', 'KSA': 'السعودية', 'المملكة العربية السعودية': 'السعودية', 'saudi': 'السعودية',
        'Algeria': 'الجزائر', 'DZ': 'الجزائر', 'algeria': 'الجزائر',
        'Morocco': 'المغرب', 'Maroc': 'المغرب', 'MA': 'المغرب', 'morocco': 'المغرب',
        'Iraq': 'العراق', 'IQ': 'العراق', 'iraq': 'العراق',
        'Jordan': 'الأردن', 'JO': 'الأردن', 'jordan': 'الأردن',
        'Palestine': 'فلسطين', 'PS': 'فلسطين', 'palestine': 'فلسطين',
        'Kuwait': 'الكويت', 'KW': 'الكويت', 'kuwait': 'الكويت',
        'United Arab Emirates': 'الإمارات', 'UAE': 'الإمارات', 'AE': 'الإمارات', 'uae': 'الإمارات',
        'Tunisia': 'تونس', 'TN': 'تونس', 'tunisia': 'تونس',
        'Libya': 'ليبيا', 'LY': 'ليبيا', 'libya': 'ليبيا',
        'Sudan': 'السودان', 'SD': 'السودان', 'sudan': 'السودان',
        'Syria': 'سوريا', 'SY': 'سوريا', 'syria': 'سوريا',
        'Lebanon': 'لبنان', 'LB': 'لبنان', 'lebanon': 'لبنان',
        'Yemen': 'اليمن', 'YE': 'اليمن', 'yemen': 'اليمن',
        'Oman': 'عمان', 'OM': 'عمان', 'oman': 'عمان',
        'Qatar': 'قطر', 'QA': 'قطر', 'qatar': 'قطر',
        'Bahrain': 'البحرين', 'BH': 'البحرين', 'bahrain': 'البحرين',
        'Turkey': 'تركيا', 'TR': 'تركيا', 'turkey': 'تركيا'
    };

    // Check direct mapping or case-insensitive mapping
    if (mapping[n]) return mapping[n];
    for (let key in mapping) {
        if (key.toLowerCase() === n.toLowerCase()) return mapping[key];
    }

    return n || 'غير معروف';
}

function initAnalyticsCharts() {
    if (typeof Chart === 'undefined') return;

    // --- Country Data ---
    const countryCounts = {};
    allUsageData.forEach(u => {
        const c = normalizeCountryName(u.country);
        countryCounts[c] = (countryCounts[c] || 0) + 1;
    });

    const sortedCountries = Object.entries(countryCounts).sort((a, b) => b[1] - a[1]);
    
    // Update Top Country Badge
    const topCountryBadge = document.getElementById('topCountryBadge');
    if (topCountryBadge && sortedCountries.length > 0) {
        topCountryBadge.textContent = `👑 الأكثر نشاطاً: ${sortedCountries[0][0]} (${sortedCountries[0][1]})`;
    }

    displayCountryTable(sortedCountries);

    // --- OS Distribution Chart ---
    const osCounts = {};
    allUsageData.forEach(u => { 
        const os = u.os || 'Other'; 
        osCounts[os] = (osCounts[os] || 0) + 1; 
    });
    
    if (osChart) osChart.destroy();
    const osCtx = document.getElementById('osChart')?.getContext('2d');
    if (osCtx) {
        osChart = new Chart(osCtx, {
            type: 'doughnut',
            data: {
                labels: Object.keys(osCounts),
                datasets: [{ 
                    data: Object.values(osCounts), 
                    backgroundColor: ['#3b82f6', '#f59e0b', '#10b981', '#6b7280'],
                    borderWidth: 0
                }]
            },
            options: { 
                responsive: true, 
                maintainAspectRatio: false,
                plugins: { legend: { position: 'bottom' } }
            }
        });
    }

    // --- Daily Usage Trend ---
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
                datasets: [{
                    label: 'الفتحات اليومية',
                    data: Object.values(dailyCounts),
                    borderColor: '#3b82f6',
                    backgroundColor: 'rgba(59, 130, 246, 0.1)',
                    fill: true,
                    tension: 0.4,
                    pointRadius: 4,
                    pointBackgroundColor: '#3b82f6'
                }]
            },
            options: {
                responsive: true,
                maintainAspectRatio: false,
                scales: {
                    y: { beginAtZero: true, grid: { color: 'rgba(0,0,0,0.05)' } },
                    x: { grid: { display: false } }
                }
            }
        });
    }

    // Features Usage Analysis
    const fCounts = {};
    // Initialize with mapped names from APP_FEATURES
    APP_FEATURES.forEach(f => {
        fCounts[f.name] = 0;
    });

    if (window.featureUsageData) {
        window.featureUsageData.forEach(u => {
            // Find feature by matching ID (e.g. 'quranView' vs 'quranView')
            const feature = APP_FEATURES.find(f => f.id === u.feature_name);
            const name = feature ? feature.name : (u.feature_name || 'غير معروف');
            
            // If the name is already in fCounts, increment it, otherwise create it
            fCounts[name] = (fCounts[name] || 0) + 1;
        });
    }

    // Sort to show most used first
    const featureEntries = Object.entries(fCounts)
        .filter(e => e[1] > 0 || APP_FEATURES.some(f => f.name === e[0])) // Show all app features + others with data
        .sort((a, b) => b[1] - a[1])
        .slice(0, 12); // Top 12 features

    if (featuresUsageChart) featuresUsageChart.destroy();
    const fCtx = document.getElementById('featuresUsageChart')?.getContext('2d');
    if (fCtx) {
        featuresUsageChart = new Chart(fCtx, {
            type: 'bar',
            data: {
                labels: featureEntries.map(e => e[0]),
                datasets: [{
                    label: 'عدد النقرات',
                    data: featureEntries.map(e => e[1]),
                    backgroundColor: [
                        '#6366f1', '#10b981', '#f59e0b', '#3b82f6', 
                        '#ec4899', '#8b5cf6', '#06b6d4', '#f97316',
                        '#84cc16', '#0ea5e9', '#d946ef', '#f43f5e'
                    ],
                    borderRadius: 8
                }]
            },
            options: {
                responsive: true,
                maintainAspectRatio: false,
                plugins: { legend: { display: false } },
                scales: {
                    y: { beginAtZero: true, grid: { color: 'rgba(0,0,0,0.05)' }, ticks: { stepSize: 1 } },
                    x: { grid: { display: false } }
                }
            }
        });
    }
}

function displayCountryTable(sortedCountries) {
    const tableBody = document.getElementById('countryTableBody');
    if (!tableBody) return;

    if (sortedCountries.length === 0) {
        tableBody.innerHTML = '<tr><td colspan="4" style="text-align:center; padding: 20px;">لا توجد بيانات متاحة</td></tr>';
        return;
    }

    const totalLaunches = allUsageData.length;

    tableBody.innerHTML = sortedCountries.map((c, index) => {
        const name = c[0];
        const count = c[1];
        const percentage = totalLaunches > 0 ? ((count / totalLaunches) * 100).toFixed(1) : 0;
        
        // Simple flag emoji mapping
        const flags = {
            'مصر': '🇪🇬', 'السعودية': '🇸🇦', 'الجزائر': '🇩🇿', 'المغرب': '🇲🇦',
            'العراق': '🇮🇶', 'الأردن': '🇯🇴', 'فلسطين': '🇵🇸', 'الكويت': '🇰🇼',
            'الإمارات': '🇦🇪', 'تونس': '🇹🇳', 'ليبيا': '🇱🇾', 'السودان': '🇸🇩',
            'سوريا': '🇸🇾', 'لبنان': '🇱🇧', 'اليمن': '🇾🇪', 'عمان': '🇴🇲',
            'قطر': '🇶🇦', 'البحرين': '🇧🇭', 'تركيا': '🇹🇷'
        };
        const flag = flags[name] || '📍';

        return `
        <tr>
            <td style="padding: 12px; color: #94a3b8; font-weight: 500;">${index + 1}</td>
            <td style="padding: 12px;">
                <div style="display: flex; align-items: center; gap: 10px;">
                    <span style="font-size: 1.2rem;">${flag}</span>
                    <span style="font-weight: 600; color: var(--text-primary);">${name}</span>
                </div>
            </td>
            <td style="padding: 12px;">
                <div style="display: flex; flex-direction: column; gap: 4px;">
                    <div style="display: flex; justify-content: space-between; font-size: 0.8rem; color: var(--text-secondary);">
                        <span>${count} فتحة</span>
                        <span>${percentage}%</span>
                    </div>
                    <div style="width: 100%; height: 6px; background: #e2e8f0; border-radius: 10px; overflow: hidden;">
                        <div style="width: ${percentage}%; height: 100%; background: var(--accent-color); border-radius: 10px;"></div>
                    </div>
                </div>
            </td>
        </tr>
    `}).join('');
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
                        <h3 style="margin-bottom: 5px;">${escapeHtml(item.title)}</h3>
                        <span class="category-badge" style="background: #e0f2fe; color: #0284c7;">${escapeHtml(item.type)}</span>
                    </div>
                    <div style="display: flex; gap: 10px;">
                        <button class="refresh-btn" onclick="toggleContentActive('${item.id}', ${item.is_active})" style="padding: 5px 10px; font-size: 0.8rem; background: ${item.is_active ? '#6b7280' : 'var(--accent-color)'};">
                            ${item.is_active ? '👁️ إخفاء' : '👁️ إظهار'}
                        </button>
                        <button class="delete-btn" onclick="deleteContent('${item.id}')">🗑️ حذف</button>
                    </div>
                </div>
                <p style="margin-top: 10px; color: var(--text-secondary); line-height: 1.6;">${escapeHtml(item.body)}</p>
                ${item.image_url ? `<img src="${escapeHtml(item.image_url)}" style="margin-top: 10px; height: 100px; border-radius: 8px;">` : ''}
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

async function updateContent(id) {
    const title = document.getElementById('editContentTitle')?.value;
    const body = document.getElementById('editContentBody')?.value;
    const type = document.getElementById('editContentType')?.value;
    const image = document.getElementById('editContentImage')?.value;

    if (!title || !body) {
        alert('⚠️ يرجى إكمال العنوان والمحتوى');
        return;
    }

    try {
        const { error } = await supabaseClient
            .from('app_content')
            .update({
                title,
                body,
                type,
                image_url: image || null
            })
            .eq('id', id);

        if (error) throw error;

        alert('✅ تم تحديث المحتوى بنجاح');
        loadContent();
    } catch (e) {
        alert('❌ فشل التحديث: ' + e.message);
    }
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
                        <span style="font-size: 2rem;">${escapeHtml(story.emoji)}</span>
                        <div>
                            <h3>${escapeHtml(story.title)}</h3>
                            <div style="display: flex; gap: 5px;">
                                <span class="category-badge" style="background: #e0f2fe; color: #0284c7;">${escapeHtml(story.category) || 'منوع'}</span>
                                <span class="category-badge" style="background: #fef3c7; color: #d97706;">⭐ ${story.stars_reward} نجمة</span>
                            </div>
                        </div>
                    </div>
                    <div style="display: flex; gap: 10px;">
                        <button class="refresh-btn" onclick="editKidsStory('${story.id}')" style="padding: 5px 10px; font-size: 0.8rem; background: #3b82f6;">
                            ✏️ تعديل
                        </button>
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
    const category = document.getElementById('kidsStoryCategory').value;
    const emoji = document.getElementById('kidsStoryEmoji').value;
    const stars = parseInt(document.getElementById('kidsStoryStars').value);
    const content = document.getElementById('kidsStoryParagraphs').value;
    const moral = document.getElementById('kidsStoryMoral').value;
    if (!title || !content || !moral) return alert('⚠️ يرجى تعبئة الحقول');
    const paragraphs = content.split('\n').map(p => p.trim()).filter(p => p.length > 0);
    try {
        await supabaseClient.from('kids_stories').insert([{ title, category, emoji: emoji || '📖', stars_reward: stars, paragraphs, content, moral, is_visible: true }]);
        alert('✅ تم إضافة القصة');
        ['kidsStoryTitle', 'kidsStoryEmoji', 'kidsStoryParagraphs', 'kidsStoryMoral'].forEach(id => document.getElementById(id).value = '');
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

function editKidsStory(id) {
    supabaseClient.from('kids_stories').select('*').eq('id', id).single().then(({ data, error }) => {
        if (error) {
            alert('❌ فشل تحميل القصة: ' + error.message);
            return;
        }
        if (!data) return;

        document.getElementById('editStoryId').value = data.id;
        document.getElementById('editStoryTitle').value = data.title;
        document.getElementById('editStoryCategory').value = data.category || 'منوع';
        document.getElementById('editStoryEmoji').value = data.emoji || '📖';
        document.getElementById('editStoryStars').value = data.stars_reward || 20;
        document.getElementById('editStoryParagraphs').value = (data.paragraphs || []).join('\n');
        document.getElementById('editStoryMoral').value = data.moral || '';

        document.getElementById('editKidsStoryModal').classList.add('active');
        document.getElementById('editKidsStoryModal').style.display = 'flex';
    });
}

async function saveKidsStoryEdit() {
    const id = document.getElementById('editStoryId').value;
    const title = document.getElementById('editStoryTitle').value;
    const category = document.getElementById('editStoryCategory').value;
    const emoji = document.getElementById('editStoryEmoji').value;
    const stars = parseInt(document.getElementById('editStoryStars').value);
    const content = document.getElementById('editStoryParagraphs').value;
    const moral = document.getElementById('editStoryMoral').value;

    if (!title || !content || !moral) {
        alert('⚠️ يرجى تعبئة جميع الحقول الأساسية');
        return;
    }

    const paragraphs = content.split('\n').map(p => p.trim()).filter(p => p.length > 0);
    const content_text = paragraphs.join('\n\n');

    try {
        const { error } = await supabaseClient
            .from('kids_stories')
            .update({
                title,
                category,
                emoji: emoji || '📖',
                stars_reward: stars,
                paragraphs,
                content: content_text,
                moral
            })
            .eq('id', id);

        if (error) throw error;

        alert('✅ تم تحديث القصة بنجاح!');
        closeKidsStoryModal();
        loadKidsStories();
    } catch (error) {
        alert('❌ فشل التحديث: ' + error.message);
    }
}

function closeKidsStoryModal() {
    const modal = document.getElementById('editKidsStoryModal');
    if (modal) {
        modal.classList.remove('active');
        modal.style.display = 'none';
    }
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
                        <span style="font-size: 2rem;">${escapeHtml(story.emoji)}</span>
                        <div><h3>${escapeHtml(story.title)}</h3><span class="category-badge" style="background: #e0f2fe; color: #0284c7;">${escapeHtml(story.category)}</span></div>
                    </div>
                    <div style="display: flex; gap: 10px;">
                        <button class="refresh-btn" onclick="toggleCharityStoryVisibility('${story.id}', ${story.is_visible})" style="padding: 5px 10px; font-size: 0.8rem; background: ${story.is_visible ? '#6b7280' : 'var(--accent-color)'};">
                            ${story.is_visible ? '👁️ إخفاء' : '👁️ إظهار'}
                        </button>
                        <button class="delete-btn" onclick="deleteCharityStory('${story.id}')">🗑️ حذف</button>
                    </div>
                </div>
                <p style="margin-top: 15px; color: var(--text-primary); line-height: 1.8;">${escapeHtml(story.content)}</p>
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
        ['charityStoryTitle', 'charityStoryContent', 'charityStorySource'].forEach(id => document.getElementById(id).value = '');
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
    if (!confirm('⚠️ هل أنت متأكد من حذف هذه القصة؟')) return;
    try {
        await supabaseClient.from('charity_stories').delete().eq('id', id);
        alert('✅ تم حذف القصة بنجاح');
        loadCharityStories();
    } catch (e) { alert('❌ فشل: ' + e.message); }
}

async function updateCharityStory(id) {
    const title = document.getElementById('editCharityTitle')?.value;
    const category = document.getElementById('editCharityCategory')?.value;
    const emoji = document.getElementById('editCharityEmoji')?.value;
    const content = document.getElementById('editCharityContent')?.value;
    const source = document.getElementById('editCharitySource')?.value;

    if (!title || !content) {
        alert('⚠️ يرجى إكمال العنوان والمحتوى');
        return;
    }

    try {
        const { error } = await supabaseClient
            .from('charity_stories')
            .update({
                title,
                category,
                emoji: emoji || '🤲',
                content,
                source
            })
            .eq('id', id);

        if (error) throw error;

        alert('✅ تم تحديث القصة بنجاح');
        loadCharityStories();
    } catch (e) {
        alert('❌ فشل التحديث: ' + e.message);
    }
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
    if (!confirm('⚠️ حذف سجل الخطأ؟')) return;
    try {
        await supabaseClient.from('error_logs').delete().eq('id', id);
        alert('✅ تم حذف السجل بنجاح');
        loadErrors();
    } catch (e) { alert('❌ فشل: ' + e.message); }
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
// --- KHATMAH MANAGEMENT ---
async function loadKhatmahCampaigns() {
    const list = document.getElementById('khatmahCampaignsList');
    if (list) list.innerHTML = '<div class="loading">⏳ جاري تحميل الحملات...</div>';
    try {
        const { data, error } = await supabaseClient
            .from('community_campaigns')
            .select('*')
            .order('created_at', { ascending: false });

        if (error) throw error;
        if (data.length === 0) { list.innerHTML = '<div class="empty-state">ℹ️ لا توجد حملات حالياً</div>'; return; }

        let html = '';
        for (const c of data) {
            // Fetch counts
            const { count: completedItems } = await supabaseClient
                .from('community_progress')
                .select('*', { count: 'exact', head: true })
                .eq('campaign_id', c.id)
                .eq('status', 'completed');

            html += `
                <div class="update-item" style="background: var(--card-bg); border: 1px solid var(--border-color); border-radius: 12px; padding: 20px; margin-bottom: 15px;">
                    <div style="display: flex; justify-content: space-between; align-items: start;">
                        <div>
                            <h4 style="font-size: 1.2rem; margin-bottom: 5px; color: var(--text-primary);">${c.title}</h4>
                            <div style="display: flex; gap: 10px; flex-wrap: wrap;">
                                <span class="category-badge" style="background:#f3f4f6; color:#374151;">🎯 النوع: ${c.target_type === 'juz' ? 'أجزاء' : c.target_type === 'surah' ? 'سور' : 'صفحات'}</span>
                                <span class="category-badge" style="background:#f3f4f6; color:#374151;">📊 الإجمالي: ${c.target_total}</span>
                                <span class="category-badge" style="background:#dcfce7; color:#15803d; font-weight:bold;">✅ المكتمل: ${completedItems || 0} / ${c.target_total}</span>
                                <span class="category-badge" style="background:${c.is_active ? '#dcfce7' : '#fef2f2'}; color:${c.is_active ? '#166534' : '#991b1b'};">
                                    ${c.is_active ? '🟢 نشطة كحملة وحيدة' : '🔴 متوقفة'}
                                </span>
                            </div>
                            <div style="margin-top: 10px; font-size: 0.9rem; color: var(--text-secondary);">
                                🏆 الختمات الكلية المنتهية: <strong>${c.completed_count || 0}</strong>
                                <br><small style="color: grey;">(الشريط العلوي يعتمد على الأجزاء المكتملة بالأخضر)</small>
                            </div>
                        </div>
                        <div style="display: flex; gap: 10px;">
                            <button class="refresh-btn" onclick="toggleKhatmahActive('${c.id}', ${c.is_active})" style="background: ${c.is_active ? '#6b7280' : 'var(--accent-color)'}; font-size:0.85rem; padding:8px 15px;">
                                ${c.is_active ? 'إيقاف' : 'تنشيط الآن'}
                            </button>
                            <button class="delete-btn" onclick="deleteKhatmahCampaign('${c.id}')" style="font-size:0.85rem; padding:8px 15px;">حذف</button>
                        </div>
                    </div>
                </div>
            `;
        }
        list.innerHTML = html;
        loadKhatmahStats(); // Load global stats after campaigns
    } catch (e) {
        console.error(e);
        list.innerHTML = '<div class="error">❌ خطأ في تحميل الحملات</div>';
    }
}

async function createKhatmahCampaign() {
    const title = document.getElementById('khatmahTitle').value.trim();
    const type = document.getElementById('khatmahTargetType').value;
    const isActive = document.getElementById('khatmahIsActive').value === 'true';

    if (!title) { alert('⚠️ يرجى إدخال عنوان للحملة'); return; }

    const totals = { 'juz': 30, 'surah': 114, 'page': 604 };
    const targetTotal = totals[type];

    try {
        // If this one is active, deactivate others (only one active at a time)
        if (isActive) {
            await supabaseClient.from('community_campaigns').update({ is_active: false }).eq('is_active', true);
        }

        const { error } = await supabaseClient
            .from('community_campaigns')
            .insert([{ title, target_type: type, target_total: targetTotal, is_active: isActive }]);

        if (error) throw error;

        alert('✅ تم إنشاء الحملة بنجاح');
        document.getElementById('khatmahTitle').value = '';
        loadKhatmahCampaigns();
    } catch (e) { alert('❌ فشل إنشاء الحملة: ' + e.message); }
}

async function toggleKhatmahActive(id, currentStatus) {
    try {
        // If deactivating, just do it. If activating, deactivate others first.
        if (!currentStatus) {
            await supabaseClient.from('community_campaigns').update({ is_active: false }).eq('is_active', true);
        }

        const { error } = await supabaseClient
            .from('community_campaigns')
            .update({ is_active: !currentStatus })
            .eq('id', id);

        if (error) throw error;
        loadKhatmahCampaigns();
    } catch (e) { alert('❌ فشل تغيير الحالة: ' + e.message); }
}

async function deleteKhatmahCampaign(id) {
    if (!confirm('⚠️ هل أنت متأكد من حذف هذه الحملة وكل تقدمها؟ لا يمكن التراجع.')) return;
    try {
        const { error } = await supabaseClient.from('community_campaigns').delete().eq('id', id);
        if (error) throw error;
        loadKhatmahCampaigns();
    } catch (e) { alert('❌ فشل الحذف: ' + e.message); }
}

async function loadKhatmahStats() {
    try {
        const { data: allProgress, error } = await supabaseClient
            .from('community_progress')
            .select('user_name, status, updated_at');

        if (error) throw error;

        // 1. Total unique users
        const users = new Set(allProgress.map(p => p.user_name).filter(n => n));
        document.getElementById('khatmahTotalUsers').textContent = users.size;

        // 2. Currently reading
        const reading = allProgress.filter(p => p.status === 'reading').length;
        document.getElementById('khatmahCurrentReading').textContent = reading;

        // 3. Completed today
        const today = new Date().toISOString().split('T')[0];
        const todayDone = allProgress.filter(p => p.status === 'completed' && p.updated_at.startsWith(today)).length;
        document.getElementById('khatmahTodayDone').textContent = todayDone;

        // 4. Leaderboard
        const scores = {};
        allProgress.forEach(p => {
            if (p.status === 'completed' && p.user_name) {
                scores[p.user_name] = (scores[p.user_name] || 0) + 1;
            }
        });

        const sorted = Object.entries(scores).sort((a, b) => b[1] - a[1]);
        const lbContainer = document.getElementById('khatmahLeaderboard');
        const allParticipantsContainer = document.getElementById('khatmahAllParticipants');

        if (sorted.length === 0) {
            lbContainer.innerHTML = '<div class="empty-state">ℹ️ لا توجد بيانات للمتصدرين حالياً</div>';
            if (allParticipantsContainer) allParticipantsContainer.innerHTML = '<div class="empty-state">ℹ️ لا توجد بيانات حالياً</div>';
        } else {
            // Leaderboard (Top 5)
            lbContainer.innerHTML = sorted.slice(0, 5).map(([name, score], index) => `
                <div style="background: var(--body-bg); padding: 12px; border-radius: 10px; border: 1px solid var(--border-color); display: flex; align-items: center; gap: 12px;">
                    <span style="font-size: 1.2rem; font-weight: bold; color: var(--accent-color); min-width: 25px;">${index + 1}</span>
                    <div style="flex: 1;">
                        <div style="font-weight: bold; color: var(--text-primary); font-size: 0.95rem;">${name}</div>
                        <div style="font-size: 0.75rem; color: var(--text-secondary);">أتمَّ ${score} ورد</div>
                    </div>
                </div>
            `).join('');

            // All Participants
            if (allParticipantsContainer) {
                allParticipantsContainer.innerHTML = sorted.map(([name, score]) => `
                    <div style="background: rgba(0,0,0,0.02); padding: 8px 12px; border-radius: 8px; border: 1px solid var(--border-color); display: flex; justify-content: space-between; align-items: center;">
                        <div style="font-size: 0.9rem; color: var(--text-primary);">${name}</div>
                        <div style="font-size: 0.8rem; background: var(--accent-color); color: white; padding: 2px 8px; border-radius: 10px;">${score} ورد</div>
                    </div>
                `).join('');
            }
        }
    } catch (e) {
        console.error('Error loading stats:', e);
    }
}

async function exportKhatmahParticipants() {
    try {
        const { data: allProgress, error } = await supabaseClient
            .from('community_progress')
            .select('user_name, status, updated_at');

        if (error) throw error;

        // Group by user
        const scores = {};
        allProgress.forEach(p => {
            if (p.status === 'completed' && p.user_name) {
                scores[p.user_name] = (scores[p.user_name] || 0) + 1;
            }
        });

        // Convert to CSV
        let csvContent = "\ufeff" + "المشارك,عدد الأوراد المكتملة\n";
        Object.entries(scores).sort((a, b) => b[1] - a[1]).forEach(([name, count]) => {
            csvContent += `"${name}",${count}\n`;
        });

        // Create download link
        const blob = new Blob([csvContent], { type: 'text/csv;charset=utf-8;' });
        const url = URL.createObjectURL(blob);
        const link = document.createElement("a");
        link.setAttribute("href", url);
        link.setAttribute("download", `khatmah_participants_${new Date().toISOString().split('T')[0]}.csv`);
        link.style.visibility = 'hidden';
        document.body.appendChild(link);
        link.click();
        document.body.removeChild(link);

        alert('✅ تم تصدير القائمة بنجاح');
    } catch (e) {
        alert('❌ فشل تصدير البيانات: ' + e.message);
    }
}

// ============================================
// Features Management Functions
// ============================================

let allFeaturesData = []; 

async function loadFeatures() {
    try {
        const featuresList = document.getElementById('featuresList');
        if (!featuresList) return;

        featuresList.innerHTML = '<div class="loading">⏳ جاري تحميل الأقسام...</div>';

        const { data, error } = await supabaseClient
            .from('app_features')
            .select('*')
            .order('display_name');

        if (error) throw error;

        allFeaturesData = data || [];
        displayFeatures();
    } catch (error) {
        console.error('Error loading features:', error);
        const featuresList = document.getElementById('featuresList');
        if (featuresList) {
            featuresList.innerHTML = `
                <div class="error" style="grid-column: 1 / -1; padding: 20px; text-align: center; background: rgba(239, 68, 68, 0.1); border-radius: 12px; border: 1px solid #ef4444;">
                    ❌ فشل تحميل الأقسام: ${error.message}
                    <br><br>
                    <small>تأكد من إنشاء جدول app_features في Supabase وتحديثه للنسخة الجديدة</small>
                </div>
            `;
        }
    }
}

function displayFeatures() {
    const featuresList = document.getElementById('featuresList');
    if (!featuresList) return;

    if (allFeaturesData.length === 0) {
        featuresList.innerHTML = `
            <div class="empty-state" style="grid-column: 1 / -1;">
                <div class="empty-state-icon">📦</div>
                <h3>لا توجد أقسام</h3>
                <p>لم يتم العثور على أي أقسام في قاعدة البيانات</p>
            </div>
        `;
        return;
    }

    const getStatusText = (status) => {
        switch (status) {
            case 'active': return '🟢 نشط';
            case 'maintenance': return '🟠 صيانة';
            case 'hidden': return '🔴 مخفي';
            default: return '⚪ غير معروف';
        }
    };

    featuresList.innerHTML = allFeaturesData.map(feature => {
        const currentStatus = feature.status || 'active';
        return `
            <div class="feature-card ${currentStatus === 'hidden' ? 'disabled' : (currentStatus === 'maintenance' ? 'maintenance' : '')}">
                <div class="feature-header">
                    <div class="feature-info">
                        <div class="feature-emoji">${feature.emoji || '📱'}</div>
                        <div>
                            <h4 class="feature-name">${feature.display_name}</h4>
                            <p class="feature-status ${currentStatus}">
                                ${getStatusText(currentStatus)}
                            </p>
                        </div>
                    </div>
                    <select class="status-select" onchange="updateFeatureStatus('${feature.id}', this.value)">
                        <option value="active" ${currentStatus === 'active' ? 'selected' : ''}>🟢 نشط</option>
                        <option value="maintenance" ${currentStatus === 'maintenance' ? 'selected' : ''}>🟠 صيانة</option>
                        <option value="hidden" ${currentStatus === 'hidden' ? 'selected' : ''}>🔴 مخفي</option>
                    </select>
                </div>
            </div>
        `;
    }).join('');
}

async function updateFeatureStatus(featureId, newStatus) {
    try {
        const { error } = await supabaseClient
            .from('app_features')
            .update({
                status: newStatus,
                updated_at: new Date().toISOString()
            })
            .eq('id', featureId);

        if (error) throw error;

        // Update local state
        const feature = allFeaturesData.find(f => f.id === featureId);
        if (feature) {
            feature.status = newStatus;
        }

        // Refresh display
        displayFeatures();

        // Show success message
        const featureName = allFeaturesData.find(f => f.id === featureId)?.display_name || 'القسم';
        let statusMsg = '';
        switch (newStatus) {
            case 'active': statusMsg = 'تنشيط'; break;
            case 'maintenance': statusMsg = 'تفعيل وضع الصيانة لـ'; break;
            case 'hidden': statusMsg = 'إخفاء'; break;
        }

        showToastNotification(`✅ تم ${statusMsg} ${featureName} بنجاح`);

    } catch (error) {
        console.error('Error updating feature status:', error);
        alert('❌ فشل تحديث حالة القسم: ' + error.message);
        loadFeatures();
    }
}

function showToastNotification(message) {
    const toast = document.createElement('div');
    toast.style.cssText = `
        position: fixed;
        bottom: 30px;
        right: 30px;
        background: var(--accent-color);
        color: white;
        padding: 15px 25px;
        border-radius: 12px;
        box-shadow: 0 5px 20px rgba(0,0,0,0.2);
        z-index: 9999;
        animation: slideIn 0.3s ease;
    `;
    toast.textContent = message;
    document.body.appendChild(toast);

    setTimeout(() => {
        toast.style.animation = 'slideOut 0.3s ease';
        setTimeout(() => toast.remove(), 300);
    }, 2000);
}

// Keep toggleFeature for fallback
async function toggleFeature(featureId, isEnabled) {
    return updateFeatureStatus(featureId, isEnabled ? 'active' : 'hidden');
}


// --- MOSQUES MANAGEMENT ---

async function loadMosques() {
    const list = document.getElementById('mosquesList');
    // Check if list exists to avoid errors if tab is not active logic
    if (!list) return;

    list.innerHTML = '<div class="loading">⏳ جاري تحميل المساجد...</div>';

    try {
        // Load mosques data from 'user_mosques' table
        const { data, error } = await supabaseClient
            .from('user_mosques')
            .select('*')
            .order('created_at', { ascending: false });

        if (error) throw error;

        // Load unique devices count
        const { count: devicesCount, error: countError } = await supabaseClient
            .from('user_mosques')
            .select('device_id', { count: 'exact', head: true });

        // Calculate stats
        const total = data.length;
        const today = data.filter(m => {
            const date = new Date(m.created_at);
            const now = new Date();
            return date.getDate() === now.getDate() &&
                date.getMonth() === now.getMonth() &&
                date.getFullYear() === now.getFullYear();
        }).length;

        // Update stats UI
        if (document.getElementById('totalMosquesCount'))
            document.getElementById('totalMosquesCount').textContent = total;
        if (document.getElementById('mosquesDevicesCount'))
            document.getElementById('mosquesDevicesCount').textContent = devicesCount || '-';
        if (document.getElementById('mosquesTodayCount'))
            document.getElementById('mosquesTodayCount').textContent = today;

        if (!data || data.length === 0) {
            list.innerHTML = '<div class="empty-state"><h3>لا توجد مساجد</h3><p>لم يتم إضافة أي مساجد حتى الآن</p></div>';
            return;
        }

        list.innerHTML = data.map(mosque => `
            <div class="feedback-card">
                <div style="display: flex; justify-content: space-between; align-items: start;">
                    <div>
                        <h3 style="margin-bottom: 5px;">${mosque.name || 'مسجد بدون اسم'}</h3>
                        <div style="font-size: 0.9rem; color: var(--text-secondary); margin-bottom: 5px;">
                            📍 ${(mosque.latitude || 0).toFixed(5)}, ${(mosque.longitude || 0).toFixed(5)}
                        </div>
                        ${mosque.address ? `<div style="font-size: 0.85rem; color: var(--text-secondary); margin-bottom: 5px;">🏠 ${mosque.address}</div>` : ''}
                        <div style="font-size: 0.85rem; color: #666;">
                            📅 ${new Date(mosque.created_at).toLocaleString('ar-EG')}
                        </div>
                    </div>
                    <button class="delete-btn" onclick="deleteMosque('${mosque.id}')">🗑️ حذف</button>
                </div>
            </div>
        `).join('');

    } catch (error) {
        console.error(error);
        list.innerHTML = `<div class="error">❌ خطأ في تحميل المساجد: ${error.message}</div>`;
    }
}

async function deleteMosque(id) {
    if (!confirm('⚠️ هل أنت متأكد من حذف هذا المسجد؟')) return;
    try {
        const { error } = await supabaseClient
            .from('user_mosques')
            .delete()
            .eq('id', id);

        if (error) throw error;
        loadMosques();
    } catch (error) {
        alert('❌ فشل الحذف: ' + error.message);
    }
}
// --- PDF BOOKS MANAGEMENT ---
async function loadPdfBooks() {
    const list = document.getElementById('pdfBooksList');
    if (list) list.innerHTML = '<div class="loading">⏳ جاري تحميل الكتب...</div>';

    try {
        const { data, error } = await supabaseClient
            .from('pdf_books')
            .select('*')
            .order('created_at', { ascending: false });

        if (error) throw error;

        if (!data || data.length === 0) {
            if (list) list.innerHTML = '<div class="empty-state">ℹ️ لا توجد كتب في المكتبة حالياً</div>';
            return;
        }

        if (list) {
            list.innerHTML = data.map(book => `
                <div class="update-item" style="display: flex; gap: 20px; align-items: center; background: var(--card-bg); border: 1px solid var(--border-color); border-radius: 12px; padding: 15px; margin-bottom: 15px;">
                    ${book.coverUrl ? `<img src="${book.coverUrl}" style="width: 60px; height: 80px; object-fit: cover; border-radius: 6px;">` : '<div style="width: 60px; height: 80px; background: #eee; border-radius: 6px; display: flex; align-items: center; justify-content: center; font-size: 1.5rem;">📖</div>'}
                    <div style="flex: 1;">
                        <h4 style="color: var(--text-primary); margin-bottom: 5px;">${book.title}</h4>
                        <p style="font-size: 0.85rem; color: var(--text-secondary); margin-bottom: 8px;">${book.description || 'بدون وصف'}</p>
                        <div style="font-size: 0.75rem; color: #999; display: flex; gap: 15px;">
                            <span>📁 ${book.fileName}</span>
                            <span>🔗 <a href="${book.url}" target="_blank" style="color: var(--accent-color);">رابط الملف</a></span>
                        </div>
                    </div>
                    <div style="display: flex; gap: 10px;">
                        <button class="delete-btn" onclick="deletePdfBook('${book.id}')" style="font-size: 0.8rem; padding: 5px 12px;">🗑️ حذف</button>
                    </div>
                </div>
            `).join('');
        }
    } catch (e) {
        console.error('Error loading PDF books:', e);
        if (list) list.innerHTML = `<div class="error">❌ خطأ في تحميل الكتب: ${e.message}</div>`;
    }
}

async function addPdfBook() {
    const title = document.getElementById('pdfTitle').value.trim();
    const url = document.getElementById('pdfUrl').value.trim();
    const description = document.getElementById('pdfDescription').value.trim();
    const coverUrl = document.getElementById('pdfCoverUrl').value.trim();
    const fileName = document.getElementById('pdfFileName').value.trim();

    if (!title || !url || !fileName) {
        alert('⚠️ يرجى إدخال العنوان والرابط واسم الملف على الأقل');
        return;
    }

    try {
        const { error } = await supabaseClient
            .from('pdf_books')
            .insert([{
                title,
                url,
                description,
                coverUrl: coverUrl || null,
                fileName
            }]);

        if (error) throw error;

        alert('✅ تم إضافة الكتاب بنجاح');

        // Clear fields
        document.getElementById('pdfTitle').value = '';
        document.getElementById('pdfUrl').value = '';
        document.getElementById('pdfDescription').value = '';
        document.getElementById('pdfCoverUrl').value = '';
        document.getElementById('pdfFileName').value = '';

        loadPdfBooks();
    } catch (e) {
        alert('❌ فشل إضافة الكتاب: ' + e.message);
    }
}

async function deletePdfBook(id) {
    if (!confirm('⚠️ هل أنت متأكد من حذف هذا الكتاب نهائياً؟')) return;

    try {
        const { error } = await supabaseClient
            .from('pdf_books')
            .delete()
            .eq('id', id);

        if (error) throw error;

        loadPdfBooks();
    } catch (e) {
        alert('❌ فشل الحذف: ' + e.message);
    }
}


// ==========================================
// COMMUNITIES MANAGEMENT
// ==========================================

async function loadCommunities() {
    try {
        const { data, error } = await supabaseClient
            .from('communities')
            .select('*')
            .order('created_at', { ascending: false });

        if (error) throw error;

        const list = document.getElementById('communitiesList');
        if (!list) return;

        list.innerHTML = '';

        if (data.length === 0) {
            list.innerHTML = '<p style="color: var(--text-secondary); grid-column: 1/-1; text-align: center;">لا توجد مجتمعات حالياً.</p>';
            return;
        }

        data.forEach(community => {
            const card = document.createElement('div');
            card.className = 'feedback-card';
            card.style.background = 'var(--card-bg)';
            card.style.padding = '20px';
            card.style.borderRadius = '16px';
            card.style.border = '1px solid var(--border-color)';
            card.style.boxShadow = '0 4px 6px -1px rgba(0, 0, 0, 0.1)';

            let genderBadge = '';
            if (community.target_gender === 'male') {
                genderBadge = '👨 للرجال فقط';
            } else if (community.target_gender === 'female') {
                genderBadge = '👩 للنساء فقط';
            } else {
                genderBadge = '👥 متاح للجميع';
            }

            card.innerHTML = `
                <div style="display: flex; justify-content: space-between; align-items: start; margin-bottom: 15px;">
                    <h3 style="color: var(--accent-color); margin: 0;">${community.name}</h3>
                    <span style="background: rgba(16, 185, 129, 0.1); color: var(--accent-color); padding: 4px 12px; border-radius: 20px; font-size: 12px; font-weight: bold;">
                        ${genderBadge}
                    </span>
                </div>
                <p style="color: var(--text-secondary); font-size: 14px; margin-bottom: 15px; min-height: 40px;">
                    ${community.description || 'لا يوجد وصف'}
                </p>
                <div style="display: flex; gap: 10px; margin-top: auto;">
                    <button class="refresh-btn" onclick="openManageCommunityModal('${community.id}', '${community.name}')" style="flex: 1; padding: 8px;">⚙️ إدارة</button>
                    <button class="delete-btn" onclick="deleteCommunity('${community.id}')" style="padding: 8px;">🗑️</button>
                </div>
            `;
            list.appendChild(card);
        });

    } catch (e) {
        console.error('Error loading communities:', e);
    }
}

async function createCommunity() {
    const name = document.getElementById('communityName').value.trim();
    const targetGender = document.getElementById('communityTargetGender').value;
    const description = document.getElementById('communityDescription').value.trim();
    const inviteCode = 'COMM_' + Math.random().toString(36).substring(2, 10).toUpperCase();

    if (!name) {
        alert('❌ يرجى إدخال اسم المجتمع');
        return;
    }

    try {
        const { error } = await supabaseClient
            .from('communities')
            .insert({
                name: name,
                invite_code: inviteCode,
                description: description,
                target_gender: targetGender,
                created_by: '00000000-0000-0000-0000-000000000000' // Dashboard generic ID
            });

        if (error) {
            if (error.code === '23505') throw new Error('كود الانضمام مستخدم مسبقاً، يرجى اختيار كود آخر.');
            throw error;
        }

        document.getElementById('communityName').value = '';
        document.getElementById('communityDescription').value = '';
        
        loadCommunities();
        alert('✅ تم إنشاء المجتمع بنجاح');
    } catch (e) {
        alert('❌ فشل إنشاء المجتمع: ' + e.message);
    }
}

async function deleteCommunity(id) {
    if (!confirm('⚠️ هل أنت متأكد من حذف هذا المجتمع نهائياً؟ سيتم حذف جميع الحلقات والتقارير المرتبطة به.')) return;

    try {
        const { error } = await supabaseClient
            .from('communities')
            .delete()
            .eq('id', id);

        if (error) throw error;
        loadCommunities();
    } catch (e) {
        alert('❌ فشل حذف المجتمع: ' + e.message);
    }
}

function openManageCommunityModal(id, name) {
    document.getElementById('manageCommunityTitle').innerText = 'إدارة: ' + name;
    document.getElementById('currentCommunityId').value = id;
    
    // Clear fields
    document.getElementById('meetingTitle').value = '';
    document.getElementById('meetingTeacher').value = '';
    document.getElementById('meetingGender').value = 'both';
    document.getElementById('meetingUrl').value = '';
    document.getElementById('meetingDate').value = '';
    loadCommunityMeetings(id);
    document.getElementById('manageCommunityModal').style.display = 'flex';
}

function closeManageCommunityModal() {
    document.getElementById('manageCommunityModal').style.display = 'none';
}

async function loadCommunityMeetings(communityId) {
    const listEl = document.getElementById('communityMeetingsList');
    listEl.innerHTML = '<p style="text-align: center; color: var(--text-secondary);">جاري تحميل الحلقات...</p>';

    try {
        const { data, error } = await supabaseClient
            .from('meetings')
            .select('*')
            .eq('community_id', communityId)
            .order('meeting_date', { ascending: false });

        if (error) throw error;

        if (!data || data.length === 0) {
            listEl.innerHTML = '<p style="text-align: center; color: var(--text-secondary);">لا توجد حلقات مسجلة حتى الآن.</p>';
            return;
        }

        listEl.innerHTML = data.map(meeting => {
            const date = new Date(meeting.meeting_date);
            const formattedDate = date.toLocaleString('ar-EG');
            return `
                <div style="padding: 10px; border: 1px solid var(--border-color); border-radius: 8px; background: var(--body-bg); position: relative;">
                    <div style="display: flex; justify-content: space-between; align-items: start;">
                        <div>
                            <strong>${escapeHtml(meeting.title)}</strong><br>
                            <small style="color: var(--text-secondary);">📅 ${formattedDate}</small>
                            ${meeting.teacher_name ? `<br><small style="color: var(--accent-color);">👤 ${escapeHtml(meeting.teacher_name)}</small>` : ''}
                        </div>
                        <button onclick="deleteCommunityMeeting('${meeting.id}')" style="background: #fee; color: #c00; border: none; border-radius: 4px; padding: 4px 8px; cursor: pointer; font-size: 12px;">🗑️ حذف</button>
                    </div>
                    <div style="margin-top: 10px;">
                        <label style="font-size: 12px; color: var(--text-secondary);">التقرير / ملخص الحلقة</label>
                        <textarea id="report_${meeting.id}" style="width: 100%; height: 60px; padding: 6px; border-radius: 4px; border: 1px solid var(--border-color); resize: vertical; margin-top: 4px;">${escapeHtml(meeting.report_content || '')}</textarea>
                        <button onclick="saveMeetingReport('${meeting.id}')" style="background: var(--accent-color); color: white; border: none; border-radius: 4px; padding: 4px 10px; cursor: pointer; font-size: 12px; margin-top: 4px;">حفظ التقرير</button>
                    </div>
                </div>
            `;
        }).join('');
    } catch (e) {
        listEl.innerHTML = '<p style="text-align: center; color: #c00;">❌ حدث خطأ في تحميل الحلقات</p>';
    }
}

async function saveMeetingReport(meetingId) {
    const reportContent = document.getElementById(`report_${meetingId}`).value.trim();
    
    try {
        const { error } = await supabaseClient
            .from('meetings')
            .update({ report_content: reportContent || null })
            .eq('id', meetingId);

        if (error) throw error;
        alert('✅ تم حفظ التقرير بنجاح');
    } catch (e) {
        alert('❌ فشل حفظ التقرير: ' + e.message);
    }
}

async function deleteCommunityMeeting(meetingId) {
    if (!confirm('هل أنت متأكد من حذف هذه الحلقة؟ لا يمكن التراجع عن هذا الإجراء.')) return;

    try {
        const { error } = await supabaseClient
            .from('meetings')
            .delete()
            .eq('id', meetingId);

        if (error) throw error;
        
        const communityId = document.getElementById('currentCommunityId').value;
        loadCommunityMeetings(communityId);
    } catch (e) {
        alert('❌ فشل حذف الحلقة: ' + e.message);
    }
}

function escapeHtml(unsafe) {
    if (!unsafe) return '';
    return unsafe
         .replace(/&/g, "&amp;")
         .replace(/</g, "&lt;")
         .replace(/>/g, "&gt;")
         .replace(/"/g, "&quot;")
         .replace(/'/g, "&#039;");
}

async function createCommunityMeeting() {
    const communityId = document.getElementById('currentCommunityId').value;
    const title = document.getElementById('meetingTitle').value.trim();
    const teacherName = document.getElementById('meetingTeacher').value.trim();
    const targetGender = document.getElementById('meetingGender').value;
    const url = document.getElementById('meetingUrl').value.trim();
    const dateStr = document.getElementById('meetingDate').value;

    if (!title || !dateStr || !url) {
        alert('❌ يرجى إدخال عنوان الحلقة، وموعدها، ورابط الاجتماع (Google Meet)');
        return;
    }

    try {
        const meetingDate = new Date(dateStr).toISOString();

        const { error } = await supabaseClient
            .from('meetings')
            .insert({
                community_id: communityId,
                title: title,
                meet_url: url || null,
                meeting_date: meetingDate,
                duration_minutes: 60,
                target_gender: targetGender,
                teacher_name: teacherName || null,
                created_by: '00000000-0000-0000-0000-000000000000'
            });

        if (error) throw error;

        document.getElementById('meetingTitle').value = '';
        document.getElementById('meetingTeacher').value = '';
        document.getElementById('meetingGender').value = 'both';
        document.getElementById('meetingUrl').value = '';
        document.getElementById('meetingDate').value = '';
        alert('✅ تم جدولة الحلقة بنجاح');
        
        loadCommunityMeetings(communityId);
    } catch (e) {
        alert('❌ فشل جدولة الحلقة: ' + e.message);
    }
}


// --- COMMUNITY USERS MANAGEMENT ---
async function loadCommunityUsers() {
    const list = document.getElementById('communityUsersList');
    if (!list) return;

    list.innerHTML = '<tr><td colspan="6" class="loading">⏳ جاري تحميل البيانات...</td></tr>';

    try {
        const { data, error } = await supabaseClient
            .from('community_users')
            .select('*')
            .order('created_at', { ascending: false });

        if (error) throw error;

        // Update stats
        const total = data.length;
        const male = data.filter(u => u.gender === 'male').length;
        const female = data.filter(u => u.gender === 'female').length;

        if (document.getElementById('cuTotal')) document.getElementById('cuTotal').textContent = total;
        if (document.getElementById('cuMale')) document.getElementById('cuMale').textContent = male;
        if (document.getElementById('cuFemale')) document.getElementById('cuFemale').textContent = female;

        if (data.length === 0) {
            list.innerHTML = '<tr><td colspan="6" style="text-align: center; padding: 20px;">لا يوجد مستخدمين مسجلين بعد.</td></tr>';
            return;
        }

        list.innerHTML = data.map(user => `
            <tr style="border-bottom: 1px solid var(--border-color); transition: background-color 0.2s;">
                <td style="padding: 12px; color: var(--text-primary); font-weight: 500;">
                    ${user.name || 'بدون اسم'}
                </td>
                <td style="padding: 12px;">
                    ${user.gender === 'male' ? '👨 رجل' : '👩 امرأة'}
                </td>
                <td style="padding: 12px; color: var(--text-secondary);" dir="ltr">
                    ${user.phone || '-'}
                </td>
                <td style="padding: 12px; color: var(--text-secondary);">
                    ${user.email || '-'}
                </td>
                <td style="padding: 12px;">
                    <select onchange="toggleCommunityUserRole('${user.id}', this.value)" style="padding: 5px; border-radius: 8px; border: 1px solid var(--border-color); background: var(--card-bg); color: var(--text-primary); font-size: 0.85rem;">
                        <option value="false" ${!user.is_teacher ? 'selected' : ''}>مستخدم عادي</option>
                        <option value="true" ${user.is_teacher ? 'selected' : ''}>👨‍🏫 مدرس</option>
                    </select>
                </td>
                <td style="padding: 12px; color: var(--text-secondary);">
                    <span class="category-badge" style="background: rgba(16, 185, 129, 0.1); color: var(--accent-color);">
                        ${user.location || 'غير محدد'}
                    </span>
                </td>
                <td style="padding: 12px; color: var(--text-secondary); font-size: 0.9rem;">
                    ${new Date(user.created_at).toLocaleDateString('ar-EG')}
                </td>
            </tr>
        `).join('');

    } catch (e) {
        console.error('Error loading community users:', e);
        list.innerHTML = `<tr><td colspan="6" class="error">❌ حدث خطأ: ${e.message}</td></tr>`;
    }
}

async function toggleCommunityUserRole(userId, isTeacherValue) {
    try {
        const isTeacher = isTeacherValue === 'true';
        const { error } = await supabaseClient
            .from('community_users')
            .update({ is_teacher: isTeacher })
            .eq('id', userId);

        if (error) throw error;
        
        // Optional: show a small toast or just reload
        loadCommunityUsers();
    } catch (e) {
        alert('❌ فشل تغيير الصلاحية: ' + e.message);
        loadCommunityUsers(); // reset select
    }
}

// ─────────────────────────────────────────────────────────────────
// Push Notifications Logic
// ─────────────────────────────────────────────────────────────────

async function sendPushNotification() {
    const title = document.getElementById('notifTitle').value;
    const body = document.getElementById('notifBody').value;
    const image = document.getElementById('notifImage').value;
    const route = document.getElementById('notifRoute').value;
    const btn = document.getElementById('sendNotifBtn');
    const spinner = document.getElementById('sendNotifSpinner');
    const statusMsg = document.getElementById('notifStatusMsg');

    if (!title || !body) {
        showStatus(statusMsg, 'الرجاء إدخال العنوان والمحتوى', 'error');
        return;
    }

    // إظهار حالة التحميل
    btn.disabled = true;
    spinner.style.display = 'inline-block';
    statusMsg.style.display = 'none';

    try {
        // استدعاء الـ Edge Function
        const { data, error } = await supabaseClient.functions.invoke('send-notification', {
            body: {
                title: title,
                body: body,
                imageUrl: image || null,
                routePath: route || null
            }
        });

        if (error) {
            console.error("Supabase Function Error:", error);
            throw error;
        }

        if (data && data.error) {
            console.error("Function Data Error:", data.error);
            throw new Error(data.error);
        }

        // نجاح
        showStatus(statusMsg, 'تم إرسال الإشعار بنجاح! 🎉', 'success');
        
        // تفريغ الحقول
        document.getElementById('notifTitle').value = '';
        document.getElementById('notifBody').value = '';
        document.getElementById('notifImage').value = '';
        document.getElementById('notifRoute').value = '';

    } catch (err) {
        console.error('Error sending notification:', err);
        showStatus(statusMsg, 'حدث خطأ أثناء الإرسال: ' + (err.message || 'خطأ غير معروف'), 'error');
    } finally {
        // إعادة الزر لحالته الطبيعية
        btn.disabled = false;
        spinner.style.display = 'none';
    }
}

function showStatus(element, message, type) {
    element.textContent = message;
    element.style.display = 'block';
    if (type === 'success') {
        element.style.backgroundColor = '#d1fae5';
        element.style.color = '#065f46';
        element.style.border = '1px solid #10b981';
    } else {
        element.style.backgroundColor = '#fee2e2';
        element.style.color = '#991b1b';
        element.style.border = '1px solid #ef4444';
    }
}

window.sendPushNotification = sendPushNotification;
