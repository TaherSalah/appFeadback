const fs = require('fs');
const content = fs.readFileSync('index.html', 'utf-8');

const blockStart = content.indexOf('        <!-- Communities Tab -->');
const blockEnd = content.indexOf('    <!-- Error Overlay -->');

if (blockStart !== -1 && blockEnd !== -1) {
    const comm_block = content.substring(blockStart, blockEnd).trim();
    let new_content = content.substring(0, blockStart) + content.substring(blockEnd);
    
    // The target is before '    <!-- Auth Overlay -->'
    // But we want it before the closing divs:
    //             </div>
    //         </div>
    //             </div>
    //         </div>
    //     </div>
    // Let's just find '    <!-- Auth Overlay -->'
    const authStart = new_content.indexOf('    <!-- Auth Overlay -->');
    if (authStart !== -1) {
        // We want to go back and find the 5 closing divs
        // Since it's tricky with \r\n, let's just insert it before the first of those 5 closing divs.
        // Or simpler: The mosquesList ends at:
        //                 <div id="mosquesList">
        //                     <div class="loading">⏳ جاري تحميل المساجد...</div>
        //                 </div>
        //             </div>
        //         </div>
        
        const mosqueEndStr = '                <div id="mosquesList">\r\n                    <div class="loading">⏳ جاري تحميل المساجد...</div>\r\n                </div>\r\n            </div>\r\n        </div>';
        const mosqueEndStr2 = '                <div id="mosquesList">\n                    <div class="loading">⏳ جاري تحميل المساجد...</div>\n                </div>\n            </div>\n        </div>';
        
        let targetIndex = new_content.indexOf(mosqueEndStr);
        if (targetIndex === -1) {
            targetIndex = new_content.indexOf(mosqueEndStr2);
        }
        
        if (targetIndex !== -1) {
            const insertPosition = targetIndex + (targetIndex === new_content.indexOf(mosqueEndStr) ? mosqueEndStr.length : mosqueEndStr2.length);
            
            new_content = new_content.substring(0, insertPosition) + '\n\n' + comm_block + '\n' + new_content.substring(insertPosition);
            fs.writeFileSync('index.html', new_content);
            console.log('Success inserted block');
        } else {
            console.log('Mosque end not found');
        }
    } else {
        console.log('Auth start not found');
    }
} else {
    console.log('Block not found');
}
