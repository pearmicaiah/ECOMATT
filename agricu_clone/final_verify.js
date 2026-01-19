
const fs = require('fs');
const path = require('path');

const rootDir = 'e:\\Pictures\\ECOMATT-WEBSITE\\agricu_clone';
const socialDomains = ["facebook.com", "instagram.com", "threads.com", "youtube.com", "whatsapp.com", "tiktok.com"];
const oldPhone = "+263 78 360 5456";

console.log("Checking files...");
let issuesFound = false;

const files = fs.readdirSync(rootDir).filter(f => f.endsWith('.html'));

files.forEach(file => {
    const filePath = path.join(rootDir, file);
    const content = fs.readFileSync(filePath, 'utf8');
    let fileIssues = [];

    // 1. Check "Farm Operations"
    if (!content.includes("Farm Operations") && content.includes('href="services.html">Services</a>')) {
        fileIssues.push("Menu item 'Services' not renamed");
    }

    // 2. Check Social Links
    socialDomains.forEach(domain => {
        const regex = new RegExp(`<a[^>]+href=["'][^"']*${domain.replace('.', '\\.')}[^"']*["'][^>]*>`, 'gi');
        let match;
        while ((match = regex.exec(content)) !== null) {
            if (!match[0].includes('target="_blank"') && !match[0].includes("target='_blank'")) {
                fileIssues.push(`Social link missing target='_blank': ${domain}`);
            }
        }
    });

    // 3. Old Phone
    if (content.includes(oldPhone)) {
        fileIssues.push("Old phone number found");
    }

    if (fileIssues.length > 0) {
        console.log(`${file}: ${fileIssues.join('; ')}`);
        issuesFound = true;
    }
});

if (!issuesFound) {
    console.log("All files passed text content verification.");
}
