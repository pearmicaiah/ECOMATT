const fs = require('fs');
const path = require('path');

const rootDir = 'e:\\Pictures\\ECOMATT-WEBSITE\\agricu_clone';
// Only process .html files
const files = fs.readdirSync(rootDir).filter(f => f.endsWith('.html'));

const socialLinkMap = {
    'facebook': 'https://www.facebook.com/profile.php?id=61583618074262',
    'instagram': 'https://www.instagram.com/ecomatt_farm/',
    'threads': 'https://www.threads.com/@ecomatt_farm',
    'youtube': 'https://www.youtube.com/channel/UCqUuQcsNDZy8uW7wfkgJVdA',
    'whatsapp': 'https://whatsapp.com/channel/0029Vb7GohSLdQeZMOg58x2l',
    'tiktok': 'https://www.tiktok.com/@ecomattfarm?lang=en'
};

const linkMap = {
    'faq': 'faq.html',
    'testimonial': 'testimonial.html',
    'shop': 'mega-shop.html',
    'about': 'about.html',
    'contact': 'contact.html',
    'project': 'project.html',
    'service': 'services.html'
};

const CONTACT_PHONE = '+263 71 474 5653';
const CONTACT_PHONE_HREF = 'tel:+263714745653';
const CONTACT_EMAIL = 'sales@ecomatt.co.zw';
const CONTACT_EMAIL_HREF = 'mailto:sales@ecomatt.co.zw';

let totalChanges = 0;

files.forEach(file => {
    const filePath = path.join(rootDir, file);
    let content = fs.readFileSync(filePath, 'utf8');
    let originalContent = content;
    let fileChanges = 0;

    // --- 1. Social Media Updates (Reinforce) ---
    // Update individual social links if they exist with specific classes or hrefs
    // Targeting by class (fa-facebook, etc.) or existing hrefs
    // This part is tricky to do globally without breaking structure if we don't know the exact current state.
    // However, the previous script replaced entire blocks. Here we will do fine-grained href replacement just in case.

    // Regex to find <a> tags containing specific social icons and update their href/target/rel
    const socialPlatforms = [
        { key: 'facebook', iconRegex: /fa-facebook/ },
        { key: 'instagram', iconRegex: /fa-instagram/ },
        { key: 'threads', iconRegex: /fa-threads|fa-twitter/ }, // Assuming threads might have replaced twitter or using twitter icon placeholder
        { key: 'youtube', iconRegex: /fa-youtube/ },
        { key: 'whatsapp', iconRegex: /fa-whatsapp/ },
        { key: 'tiktok', iconRegex: /fa-tiktok/ }
    ];

    // Helper to update specific links
    // Strategy: Find <a>...</i>...</a> blocks or <a> that contains the icon
    // Complex regex is risky. Instead, let's rely on the previous block replacement logic if possible?
    // User asked to "Global Social Media Link Injection... Update every social icon link... to these exact URLs".
    // Since I ran the block replacement before, let's look for any stray ones or non-standard ones.

    // Let's just do a specific href replacement for ANY link that looks like a social link placeholder
    // or update known bad links.
    // Actually, safest is to parse the file or use heuristic regex replacement for the HREF attribute if the content contains the icon.
    // But since the previous step did "Social Block" replacement, most should be good.
    // Let's double check the "Threads" mapping. Current files might still have twitter icon for threads?
    // User said: "Threads: https://www.threads.com/@ecomatt_farm".
    // I will look for twitter links and change them to Threads links if they are intended to be threads, OR just add threads.
    // The previous script added Threads explicitely.
    // Let's ensure target="_blank" on all these specific URLs.

    Object.keys(socialLinkMap).forEach(key => {
        const url = socialLinkMap[key];
        // Replace href="..." with the correct url if it matches the domain or is empty/placeholder near an icon
        // This is hard.
        // Let's stick to the "Block Replacement" strategy from before? 
        // No, let's just ensure if the URL is present, it has target blank.
        const urlRegex = new RegExp(`href="${url.replace(/\?/g, '\\?')}"[^>]*`, 'g');
        content = content.replace(urlRegex, `href="${url}" target="_blank" rel="noopener noreferrer"`);
    });

    // --- 2. Navigation Rename: Services -> Farm Operations ---
    // Look for <a ...>Services</a> or <a ...> Services </a>
    // Be careful not to replace "Services & Supply" in mega menu if not desired.
    // User said "Rename Navigation: Ensure the 'Services' menu item is renamed to 'Farm Operations' on every single page."
    // This usually refers to the main top-level menu item.
    content = content.replace(/(<a[^>]*href=["']services\.html["'][^>]*>)\s*Services\s*(<\/a>)/gi, '$1Farm Operations$2');

    // --- 3. Repair Dead Links ---
    // Find href="#" or href=""
    // Check inner text for clues
    content = content.replace(/<a([^>]*)href=["'](?:#|javascript:;|)["']([^>]*)>([\s\S]*?)<\/a>/gi, (match, attrs, restAttrs, innerText) => {
        const lowerText = innerText.toLowerCase();
        let newHref = '#'; // Default if no match

        if (lowerText.includes('faq')) newHref = linkMap['faq'];
        else if (lowerText.includes('testimonial')) newHref = linkMap['testimonial'];
        else if (lowerText.includes('shop')) newHref = linkMap['shop'];
        else if (lowerText.includes('about')) newHref = linkMap['about'];
        else if (lowerText.includes('contact')) newHref = linkMap['contact'];
        else if (lowerText.includes('project')) newHref = linkMap['project'];

        if (newHref !== '#') {
            return `<a${attrs}href="${newHref}"${restAttrs}>${innerText}</a>`;
        }
        return match;
    });

    // --- 4. Remove project-details.html ---
    content = content.replace(/project-details\.html/g, 'project.html');

    // --- 5. Branding & Contact ---
    // Phone
    // Replace href="tel:..."
    content = content.replace(/href=["']tel:[^"']*["']/g, `href="${CONTACT_PHONE_HREF}"`);
    // Replace displayed phone numbers (tricky regex, try to match specifically formatted ones or common placeholders)
    // Matches +1 234..., +012..., 666 888...
    // Let's target the inner text of the tel link specifically if possible, OR just common strings.
    // We already fixed the href. Now let's find the content inside that <a> tag.
    // Regex for <a> with tel href.
    content = content.replace(/(<a[^>]*href=["']tel:\+263714745653["'][^>]*>)([\s\S]*?)(<\/a>)/g, (match, openTag, inner, closeTag) => {
        // Only replace if it doesn't look like an icon-only link
        if (inner.replace(/<[^>]*>/g, '').trim().length > 0) {
            return `${openTag}${CONTACT_PHONE}${closeTag}`;
        }
        return match;
    });

    // Email
    content = content.replace(/href=["']mailto:[^"']*["']/g, `href="${CONTACT_EMAIL_HREF}"`);
    content = content.replace(/(<a[^>]*href=["']mailto:sales@ecomatt\.co\.zw["'][^>]*>)([\s\S]*?)(<\/a>)/g, (match, openTag, inner, closeTag) => {
        if (inner.replace(/<[^>]*>/g, '').trim().length > 0) {
            return `${openTag}${CONTACT_EMAIL}${closeTag}`;
        }
        return match;
    });

    // Logo Link
    // Look for <div class="logo"><a href="..."> or similar
    // Or just generic: any <a> wrapping an <img> with 'logo' in src or class="logo"
    content = content.replace(/(<div class=["']logo["'][^>]*>\s*<a href=["'])([^"']*)(["'])/gi, '$1index.html$3');
    content = content.replace(/(<a href=["'])([^"']*)(["'][^>]*>\s*<img[^>]*src=["'][^"']*logo[^"']*["'])/gi, '$1index.html$3');

    // --- 6. Previous Social Block Script Re-run (Condensed) ---
    // The user explicitely asked for "Global Social Media Link Injection" again.
    // It's safer to re-run the generator logic for the social boxes to guarantee compliance with the "exact URLs" and "target blank" rule.
    // I will inject the same block replacement logic here for the specific container classes found previously.

    const socialMap = [
        { name: 'facebook', url: 'https://www.facebook.com/profile.php?id=61583618074262', icon: 'fa-brands fa-facebook-f' },
        { name: 'instagram', url: 'https://www.instagram.com/ecomatt_farm/', icon: 'fa-brands fa-instagram' },
        { name: 'threads', url: 'https://www.threads.com/@ecomatt_farm', icon: 'fa-brands fa-threads' },
        { name: 'youtube', url: 'https://www.youtube.com/channel/UCqUuQcsNDZy8uW7wfkgJVdA', icon: 'fa-brands fa-youtube' },
        { name: 'whatsapp', url: 'https://whatsapp.com/channel/0029Vb7GohSLdQeZMOg58x2l', icon: 'fa-brands fa-whatsapp' },
        { name: 'tiktok', url: 'https://www.tiktok.com/@ecomattfarm?lang=en', icon: 'fa-brands fa-tiktok' }
    ];
    const generateLinks = () => socialMap.map(s => `<a href="${s.url}" target="_blank" rel="noopener noreferrer"><i class="${s.icon}"></i></a>`).join('\n');
    const generateListItems = () => socialMap.map(s => `<li><a href="${s.url}" target="_blank" rel="noopener noreferrer"><i class="${s.icon}"></i></a></li>`).join('\n');

    const replaceBlock = (regex, type = 'div') => {
        content = content.replace(regex, (match, p1, p2, p3) => {
            const newContent = type === 'list' ? generateListItems() : generateLinks();
            // Check if content actually changed to avoid unnecessary diffs (whitespace ignores)
            // But strict replacement is safer for compliance.
            return `${p1}\n${newContent}\n${p3}`;
        });
    };

    // Use same targets as before
    replaceBlock(/(<div class="social-inner">)([\s\S]*?)(<\/div>)/g);
    replaceBlock(/(<div class="social-box">)([\s\S]*?)(<\/div>)/g);
    replaceBlock(/(<div class="ecomatt-hero-socials">)([\s\S]*?)(<\/div>)/g);
    replaceBlock(/(<div class="site-footer-two__social">)([\s\S]*?)(<\/div>)/g);
    replaceBlock(/(<div class="team-socials[^"]*">)([\s\S]*?)(<\/div>)/g);
    replaceBlock(/(<div class="footer-social">)([\s\S]*?)(<\/div>)/g);
    replaceBlock(/(<div class="mobile-nav__social">)([\s\S]*?)(<\/div>)/g);
    replaceBlock(/(<ul class="social-icon-one">)([\s\S]*?)(<\/ul>)/g, 'list');


    if (content !== originalContent) {
        fs.writeFileSync(filePath, content, 'utf8');
        console.log(`[UPDATED] ${file}`);
        totalChanges++;
    }
});

console.log(`Total files updated: ${totalChanges}`);
