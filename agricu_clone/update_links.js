const fs = require('fs');
const path = require('path');

function updateFile(filepath) {
    try {
        let content = fs.readFileSync(filepath, 'utf8');
        const originalContent = content;

        // 1. Global Navigation Label Update: "Services" -> "Farm Operations"
        content = content.replace(/(<a\s[^>]*>)\s*Services\s*(<\/a>)/g, '$1Farm Operations$2');

        // 2. Master Navigation Map (Update href only)

        // Home -> index.html
        content = content.replace(/(<a\s+[^>]*href=["'])#(["'][^>]*>\s*Home\s*<\/a>)/g, '$1index.html$2');

        // Farm Operations -> services.html
        content = content.replace(/(<a\s+[^>]*href=["'])[^"']*(["'][^>]*>\s*Farm Operations\s*<\/a>)/g, '$1services.html$2');
        // Also catch if it was already services.html or something else, but primarily target the label we just fixed or existing ones.
        // If the label is still Services (skipped above?), regex won't match. 
        // We already did step 1, so it should be Farm Operations. 

        // Projects -> project.html
        content = content.replace(/(<a\s+[^>]*href=["'])[^"']*(["'][^>]*>\s*(?:Projects?|projects?)\s*<\/a>)/gi, '$1project.html$2');

        // Shop -> mega-shop.html
        content = content.replace(/(<a\s+[^>]*href=["'])[^"']*(["'][^>]*>\s*(?:Shop|shop)\s*<\/a>)/g, '$1mega-shop.html$2');

        // Blog -> blog.html
        content = content.replace(/(<a\s+[^>]*href=["'])[^"']*(["'][^>]*>\s*Blog\s*<\/a>)/gi, '$1blog.html$2');

        // About Us -> about.html
        content = content.replace(/(<a\s+[^>]*href=["'])[^"']*(["'][^>]*>\s*(?:About|About\s+Us)\s*<\/a>)/gi, '$1about.html$2');

        // FAQ -> faq.html
        content = content.replace(/(<a\s+[^>]*href=["'])[^"']*(["'][^>]*>\s*(?:Faq|FAQ)\s*<\/a>)/gi, '$1faq.html$2');

        // Testimonial -> testimonial.html
        content = content.replace(/(<a\s+[^>]*href=["'])[^"']*(["'][^>]*>\s*Testimonial\s*<\/a>)/gi, '$1testimonial.html$2');

        // Team -> team.html
        content = content.replace(/(<a\s+[^>]*href=["'])[^"']*(["'][^>]*>\s*Team\s*<\/a>)/gi, '$1team.html$2');

        // Contact -> contact.html
        content = content.replace(/(<a\s+[^>]*href=["'])[^"']*(["'][^>]*>\s*Contact\s*<\/a>)/gi, '$1contact.html$2');

        // 3. Our Farm (Mega Menu) -> service-detail.html
        // Target list items inside mega menu.
        const knownSubItems = [
            "Tomatoes", "Onions", "Green Beans", "Cabbage", "Carrots",
            "Maize", "Grain Crops", "Watermelon", "Ginger", "Pumpkins",
            "Broilers", "Layers", "Pork Production", "Breeding", "Meat",
            "Cattle", "Fish", "Rabbits", "Chitsano Roller Meal", "By-Products",
            "Fresh Pork", "Chicken", "Goat", "Packaged Eggs", "Sausages",
            "Feed", "Chicks", "Seedlings", "Manure",
            "Training", "Farm Tours", "Marketplace & Distribution", "MountPlus"
        ];

        knownSubItems.forEach(item => {
            // Escape regex special chars in item if any (none in this list really)
            const regex = new RegExp(`(<a\\s+href=["'])#(["'][^>]*>\\s*${item}\\s*<\\/a>)`, 'g');
            content = content.replace(regex, '$1service-detail.html$2');
        });

        // 4. Action Button Linkage

        // "Discover More" -> about.html
        content = content.replace(/(<a\s+[^>]*href=["'])[^"']*(["'][^>]*class="[^"]*theme-btn[^"]*"[^>]*>\s*<span[^>]*>\s*<span[^>]*>\s*Discover More)/gi, '$1about.html$2');

        // "View All" -> services.html
        content = content.replace(/(<a\s+href=["'])[^"']*(["'][^>]*>\s*View All\s*<\/a>)/gi, '$1services.html$2');

        // "Read More" -> blog-classic.html
        content = content.replace(/(<a\s+href=["'])[^"']*(["'][^>]*class="[^"]*read-more[^"]*"[^>]*>\s*Read More)/gi, '$1blog-classic.html$2');
        // Catch "Read More ->" 
        content = content.replace(/(<a\s+href=["'])[^"']*(["'][^>]*>\s*Read More\s*&rarr;\s*<\/a>)/gi, '$1blog-classic.html$2');

        // "Project Details" -> services.html
        content = content.replace(/(<a\s+[^>]*href=["'])[^"']*(["'][^>]*>\s*(?:View\s+)?Project\s+Details\s*<\/a>)/gi, '$1services.html$2');


        // 5. Branding & Contact

        // Logo links
        content = content.replace(/(<a\s+href=["'])[^"']*(["'][^>]*>\s*<img\s+src="[^"]*ecomatt-logo\.png")/g, '$1index.html$2');
        content = content.replace(/(<a\s+href=["'])[^"']*(["'][^>]*>\s*<img\s+src="[^"]*mobile-logo\.png")/g, '$1index.html$2');
        content = content.replace(/(<a\s+href=["'])[^"']*(["'][^>]*>\s*<img\s+src="[^"]*footer-logo\.png")/g, '$1index.html$2');

        // Phone
        content = content.replace(/href=["']tel:[^"']*["']([^>]*>\s*\+263\s*71\s*474\s*5653)/g, 'href="tel:+263714745653"$1');

        // Email
        content = content.replace(/href=["']mailto:[^"']*["']([^>]*>\s*sales@ecomatt\.co\.zw)/g, 'href="mailto:sales@ecomatt.co.zw"$1');

        if (content !== originalContent) {
            fs.writeFileSync(filepath, content, 'utf8');
            console.log(`Updated: ${path.basename(filepath)}`);
        } else {
            console.log(`No changes: ${path.basename(filepath)}`);
        }

    } catch (err) {
        console.error(`Error processing ${filepath}:`, err);
    }
}

function main() {
    const rootDir = process.cwd();
    fs.readdir(rootDir, (err, files) => {
        if (err) {
            console.error("Could not list directory", err);
            return;
        }

        files.forEach(filename => {
            if (filename.endsWith('.html') && !filename.startsWith('temp_')) {
                updateFile(path.join(rootDir, filename));
            }
        });
    });
}

main();
