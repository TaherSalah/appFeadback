const fs = require('fs');
let html = fs.readFileSync('index.html', 'utf-8');

const targetStr = '<div class="header">\r\n                <button class="theme-toggle" onclick="toggleTheme()" title="تبديل الوضع">🌓</button>\r\n                <h1>لوحة تحكم رفيق المسلم اليومي</h1>';

const replacementStr = '<div class="header">\r\n                <div class="header-actions">\r\n                    <button class="theme-toggle" onclick="toggleTheme()" title="تبديل الوضع">🌓</button>\r\n                    <button class="logout-btn" onclick="logoutAdmin()" title="تسجيل الخروج">🚪</button>\r\n                </div>\r\n                <h1>لوحة تحكم رفيق المسلم اليومي</h1>';

const targetStrLF = targetStr.replace(/\r\n/g, '\n');
const replacementStrLF = replacementStr.replace(/\r\n/g, '\n');

if (html.includes(targetStr)) {
    html = html.replace(targetStr, replacementStr);
    fs.writeFileSync('index.html', html);
    console.log('Success CRLF');
} else if (html.includes(targetStrLF)) {
    html = html.replace(targetStrLF, replacementStrLF);
    fs.writeFileSync('index.html', html);
    console.log('Success LF');
} else {
    console.log('Target not found');
}
