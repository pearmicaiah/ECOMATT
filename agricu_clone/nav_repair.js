const fs = require('fs');
const path = require('path');

function repairIndex(filepath) {
    try {
        let content = fs.readFileSync(filepath, 'utf8');
        const originalContent = content;

        // --- 1. Clean Up Broken & Removed Files ---

        // project-details.html -> project.html (Removed file)
        content = content.replace(/href=["']project-details\.html["']/gi, 'href="project.html"');

        // shop-detail.html -> mega-shop.html
        content = content.replace(/href=["']shop-detail\.html["']/gi, 'href="mega-shop.html"');

        // cart.html / checkout.html / register.html -> mega-shop.html (Assuming these are just stubs for now)
        content = content.replace(/href=["'](cart|checkout|register)\.html["']/gi, 'href="mega-shop.html"');


        // --- 2. The Master Navigation Map (Map Text/Context to Href) ---

        // Operations/Services (Read More/Icons) -> services.html
        // Identifying service blocks by class or context is safer than global "Read More"
        // Service blocks often have 'service-block' class.
        // We can do a global replace for "Read More" IF we exclude the blog ones.
        // But better: User said "All 'Read More' or service icons must point to services.html" (General rule?)
        // BUT "Blog/News ... Read More ... to blog.html".
        // Let's target specific known classes if possible or use regex lookarounds? No lookarounds in basic string replace easily for large blocks.
        // Strategy: Replace specific known classes' hrefs.

        // Service Block 3 Read More Arrow: class="service-block_three-arrow..."
        content = content.replace(/(class=["'][^"']*service-block_three-arrow[^"']*["'][^>]*href=["'])[^"']*["']/gi, '$1services.html"');
        // Service Block Title Links: class="service-block_three-title" ... <a href="...">
        // We can't match across too many lines easily.
        // However, we can replace href="#" matches that are NEAR "Poultry", "Piggery".

        // Specific Categories: Poultry, Piggery, Horticulture -> service-detail.html
        // We can look for the words inside the anchor tag
        const serviceCategories = ['Poultry', 'Piggery', 'Horticulture', 'Vegetables', 'Crops', 'Livestock', 'Milling', 'Butchery', 'Eggs', 'Meat'];
        serviceCategories.forEach(cat => {
            // Replace href="#" or href="" where text contains Category
            const regex = new RegExp(`(href=["'])(?:#|)[^"']*["']([^>]*>\\s*[^<]*${cat})`, 'gi');
            content = content.replace(regex, '$1service-detail.html"$2');
        });

        // Project Items: "View Details", Project Images -> project.html
        // Look for "View Details" text
        content = content.replace(/(href=["'])(?:#|)[^"']*["']([^>]*>\s*View Details)/gi, '$1project.html"$2');
        // Look for "Project Details" text (just in case)
        content = content.replace(/(href=["'])(?:#|)[^"']*["']([^>]*>\s*Project Details)/gi, '$1project.html"$2');
        // Footer Gallery Images were already done, but ensure any other project images link to project.html if they were valid before or #
        // (User said: "Any clickable project image ... point to project.html")
        // Hard to distinguish "project image" from other images without class.
        // We'll rely on "View Details" and previous updates.

        // Shop/Products: "Buy Now", "Add to Bag" -> mega-shop.html
        content = content.replace(/(href=["'])(?:#|)[^"']*["']([^>]*>\s*(?:Buy Now|Add to Bag|Add to cart))/gi, '$1mega-shop.html"$2');


        // Blog/News: "Read More" -> blog-classic.html
        // Target specifically news blocks if possible, or "Read More" generally?
        // User said: "All 'Read More' in the blog to point to blog-classic.html"
        // Let's assume generic "read more" usually implies reading an article/blog.
        // Earlier user said "Operations... Read More ... to services.html".
        // This is a conflict. "Service" blocks usually have "Read More" too?
        // Let's look at index.html content again.
        // Service blocks have `class="service-block_two-more"`.
        // News blocks have `class="news-block_three-more"`.

        content = content.replace(/(class=["'][^"']*service-block[^"']*more[^"']*["'][^>]*href=["'])[^"']*["']/gi, '$1services.html"');
        content = content.replace(/(class=["'][^"']*news-block[^"']*more[^"']*["'][^>]*href=["'])[^"']*["']/gi, '$1blog-classic.html"');
        // Generic "Read More &rarr;" often in Hero -> about.html (from "Discover More" rule? or User said "Discover More -> about.html")
        // Hero "Read More" is often `ecomatt-read-more-btn`.
        content = content.replace(/(class=["'][^"']*ecomatt-read-more-btn[^"']*["'][^>]*href=["'])[^"']*["']/gi, '$1about.html"');


        // --- 3. Contact & CTA Integrity ---

        // Phone & Email (Already done, but enforcing)
        content = content.replace(/href=["']tel:[^"']*["']/gi, 'href="tel:+263714745653"');
        content = content.replace(/href=["']mailto:[^"']*["']/gi, 'href="mailto:sales@ecomatt.co.zw"');

        // Discover More -> about.html
        // Match text "Discover More"
        content = content.replace(/(href=["'])(?:#|)[^"']*["']([^>]*>\s*(?:<[^>]+>\s*)*Discover More)/gi, '$1about.html"$2');


        // --- 4. Href="#" Cleanup (The "Full-Repair" part) ---
        // We want to replace href="#" with sensible defaults IF it's not a social link.
        // Social links: usually contain <i class="fa..."> or similar.
        // Strategy: Match <a href="#">...</a>. If innerHTML does NOT contain <i class="fa, then replace #.
        // But regex replacement with conditional logic on inner content is hard in one pass.
        // We can allow # for <i class> tags.
        // We'll proceed with specific fixes first.

        // Fix any remaining empty href=""
        // content = content.replace(/href=""/g, 'href="#"'); // Normalize to # first? Or fix directly.

        // If we still have href="#" on "Home", "Shop" etc labels?
        // We already fixed those in previous steps (Menu updates).

        // Verify any "Link" text?
        // Let's do a broad sweep for href="#" that are likely broken.

        // "Home" -> index.html (Safety net)
        content = content.replace(/(href=["'])#(?:["'][^>]*>\s*Home)/gi, '$1index.html"');

        if (content !== originalContent) {
            fs.writeFileSync(filepath, content, 'utf8');
            console.log(`Repaired: ${path.basename(filepath)}`);
        } else {
            console.log(`No repair needed: ${path.basename(filepath)}`);
        }

    } catch (err) {
        console.error(`Error processing ${filepath}:`, err);
    }
}

// Run on index.html specifically as requested
const target = path.join(process.cwd(), 'index.html');
if (fs.existsSync(target)) {
    repairIndex(target);
} else {
    console.error("index.html not found");
}
