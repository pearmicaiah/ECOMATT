const fs = require('fs');
const path = require('path');

const rootDir = 'e:\\Pictures\\ECOMATT-WEBSITE\\agricu_clone';
const files = fs.readdirSync(rootDir).filter(f => f.endsWith('.html'));

const OLD_PHONE = '+263 78 360 5456';
const NEW_PHONE = '+263 71 474 5653';

let totalChanges = 0;

files.forEach(file => {
    const filePath = path.join(rootDir, file);
    let content = fs.readFileSync(filePath, 'utf8');

    if (content.includes(OLD_PHONE)) {
        // Simple string replace for the specific format found
        // Using global regex just in case
        content = content.replace(/\+263 78 360 5456/g, NEW_PHONE);
        fs.writeFileSync(filePath, content, 'utf8');
        console.log(`[FIXED PHONE] ${file}`);
        totalChanges++;
    }
});

console.log(`Phone number corrections: ${totalChanges}`);
