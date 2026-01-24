const fs = require('fs');
const path = require('path');

function updateFile(filepath) {
    try {
        let content = fs.readFileSync(filepath, 'utf8');
        const originalContent = content;

        // 1. Address Text: "Plot 12 Sherwood Kwekwe" -> "Plot 12 Sherwood, Kwekwe"
        // Handle newlines/tabs in between words
        content = content.replace(/Plot\s+12\s+Sherwood\s+Kwekwe/g, 'Plot 12 Sherwood, Kwekwe');

        // 2. Footer Quick Links
        // Portfolio: projects.html -> project.html (User specific request)
        content = content.replace(/href=["']projects\.html["']/g, 'href="project.html"');

        // 3. Footer Gallery Images
        // project-details.html -> services.html
        content = content.replace(/href=["']project-details\.html["']/g, 'href="services.html"');

        // 4. Footer "Our Products" links - likely broken, point to service-detail.html
        const brokenProducts = [
            'fresh-produce.html',
            'dairy-products.html',
            'livestock.html',
            'grains-cereals.html'
        ];

        brokenProducts.forEach(broken => {
            const regex = new RegExp(`href=["']${broken}["']`, 'g');
            content = content.replace(regex, 'href="service-detail.html"');
        });

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
