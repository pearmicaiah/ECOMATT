
import os
import re

root_dir = r"e:\Pictures\ECOMATT-WEBSITE\agricu_clone"
social_domains = ["facebook.com", "instagram.com", "threads.com", "youtube.com", "whatsapp.com", "tiktok.com"]

files_with_issues = []

def check_file(filepath):
    with open(filepath, 'r', encoding='utf-8') as f:
        content = f.read()

    issues = []
    
    # 1. Check "Farm Operations"
    if "Farm Operations" not in content and "Services" in content:
        # It might be that 'Services' is used unrelated to the menu, but checking for the menu link specifically
        if 'href="services.html">Services</a>' in content:
            issues.append("Menu item 'Services' not renamed to 'Farm Operations'")

    # 2. Check Social Links for target="_blank"
    # Find all <a> tags with social domains
    for domain in social_domains:
        # Regex to find <a ... href="...domain..." ...>
        # This is a simple regex, might miss matching quotes if complex, but good for a quick check
        pattern = re.compile(f'<a[^>]+href=["\'][^"\']*{re.escape(domain)}[^"\']*["\'][^>]*>', re.IGNORECASE)
        matches = pattern.findall(content)
        for match in matches:
            if 'target="_blank"' not in match and "target='_blank'" not in match:
                issues.append(f"Social link missing target='_blank': {match[:50]}...")

    # 3. Check for correct Phone Number format
    if "+263 78 360 5456" in content:
        issues.append("Old phone number found")

    # 4. Check Mobile Menu Hardcoding
    # If .mobile-menu has <li> content inside it explicitly (not injected via JS)
    # The standard is: <div class="menu-outer"><!--Here Menu Will Come Automatically...--></div>
    # We look for <div class="mobile-menu">...<ul class="navigation">...
    # But wait, script.js appends .main-menu content to .menu-outer.
    # If the file *already* has <ul> inside .menu-outer, it might be double or wrong.
    
    if '<div class="mobile-menu">' in content:
        menu_part = content.split('<div class="mobile-menu">')[1].split('</header>')[0]
        if '<ul class="navigation' in menu_part:
            # Check if it is the placeholder content or real content?
            # Actually, standard template has EMPTY .menu-outer.
            # If we find <ul> inside .menu-outer, it might be hardcoded.
            if '<div class="menu-outer">\n\t\t\t\t\t\t<!--Here' not in menu_part and '<div class="menu-outer">\n                        <!--Here' not in menu_part:
                 pass # It's hard to distinguish perfectly with regex, but if we see 'Farm Operations' missing in a hardcoded list, that's an issue.

    if issues:
        return f"{os.path.basename(filepath)}: {'; '.join(issues)}"
    return None

print("Checking files...")
for filename in os.listdir(root_dir):
    if filename.endswith(".html"):
        res = check_file(os.path.join(root_dir, filename))
        if res:
            files_with_issues.append(res)

if files_with_issues:
    print("ISSUES FOUND:")
    for i in files_with_issues:
        print(i)
else:
    print("All files passed text content verification.")
