const fs = require('fs');
const path = require('path');

function deepRepairIndex(filepath) {
    try {
        let content = fs.readFileSync(filepath, 'utf8');
        const originalContent = content;

        // 1. Shop Product Details -> mega-shop.html
        content = content.replace(/href=["']product-details\.html["']/gi, 'href="mega-shop.html"');

        // 2. Team Details -> team.html
        content = content.replace(/href=["']team-detail\.html["']/gi, 'href="team.html"');

        // 3. Shop Action Icons (in shop-now__info list)
        // These are currently href="#". We want them to point to mega-shop.html
        // Pattern: <a href="#" ... ><i class="... heart/cart/eye ...">
        // We can target specific icons.
        const shopIcons = ['fa-heart', 'fa-cart-plus', 'fa-eye', 'fa-repeat', 'flaticon-share'];
        // Note: flaticon-share is in Team block, usually href="#" is fine or maybe team.html?
        // User said "Social Media ... set to #". Share icon is kinda social.
        // But "Shop-related buttons must point to mega-shop.html".

        // Let's target the Shop section specific structure if possible, or just the icons globally if safe.
        // Shop icons usually inside shop-now__info
        // We will simple replace href="#" closely followed by these icons.
        shopIcons.forEach(icon => {
            // Regex: href="#" (optional whitespace) then anything until the icon class
            // This is risky if strict ordering isn't guaranteed.
            // Better: Replace href="#" with href="mega-shop.html" IF the <a> contains these icons?
            // Since we use strings, let's use a replacer function for <a> tags.
        });

        // Robust Approach: Find all <a> tags and check content.
        content = content.replace(/<a\s+[^>]*href=["'](?:#|)?["'][^>]*>/gi, (match) => {
            // Check if it's an image link (don't touch)
            if (match.match(/href=["'][^"']+\.(jpg|png|jpeg|gif)["']/i)) return match;

            // Check if it's a social link (keep #)
            if (match.match(/facebook|twitter|instagram|pinterest|youtube|linkedin|tiktok|whatsapp|dribbble/i)) {
                if (match.includes('href=""') || match.includes("href=''")) return match.replace(/href=["']["']/, 'href="#"');
                return match;
            }

            // Shop Icons -> mega-shop.html
            if (match.match(/fa-heart|fa-cart-plus|fa-eye|fa-repeat/)) {
                return match.replace(/href=["'](?:#|)?["']/, 'href="mega-shop.html"');
            }

            // Blog/News Empty Links -> blog-classic.html
            // If it's inside a news block? hard to tell from just <a> tag.
            // But if it's strictly empty href="" or href="#", and NOT social/shop...
            // Check strictly empty
            if (match.match(/href=["'](?:#|)["']/)) {
                // Context check is hard here.
                // Default Fallback?
                return match; // Skip generic replace in this function, do specific text replace below.
            }
            return match;
        });

        // 4. Specific Empty Link Fixes based on context text/classes

        // News Block Headings with empty href
        // Pattern: <h4 class="news-block_three-heading"><a href="">...</a>
        content = content.replace(/(class=["']news-block_three-heading["'][^>]*>\s*<a\s+)href=["'](?:#|)?["']/gi, '$1href="blog-classic.html"');
        // News Block Images with empty href
        // Pattern: <div class="news-block_three-image">\s*<a href="">
        content = content.replace(/(class=["']news-block_three-image["'][^>]*>\s*<a\s+)href=["'](?:#|)?["']/gi, '$1href="blog-classic.html"');

        // Shop Action Icons manual regex (if function above missed)
        // targeting style: <a href="#" title="Add to cart">
        content = content.replace(/(<a\s+href=["'])#(?:["'][^>]*title=["'](?:Add to|Quick View|Compare)[^"']*["'])/gi, '$1mega-shop.html"');

        // 5. Final Sweeps
        // Ensure "Sbali Roller Meal" link is fixed (was product-details.html, handled in step 1)

        if (content !== originalContent) {
            fs.writeFileSync(filepath, content, 'utf8');
            console.log(`Deep Repaired: ${path.basename(filepath)}`);
        } else {
            console.log(`No deep repair needed: ${path.basename(filepath)}`);
        }

    } catch (err) {
        console.error(`Error processing ${filepath}:`, err);
    }
}

// Run on index.html
const target = path.join(process.cwd(), 'index.html');
if (fs.existsSync(target)) {
    deepRepairIndex(target);
}
