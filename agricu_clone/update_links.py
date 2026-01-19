import os
import re

def update_file(filepath):
    with open(filepath, 'r', encoding='utf-8') as f:
        content = f.read()

    original_content = content

    # 1. Global Navigation Label Update: "Services" -> "Farm Operations"
    # Target <a>Services</a> specifically in nav
    # We look for >Services< to be safe, assuming it's the link text.
    content = re.sub(r'(<a\s[^>]*>)\s*Services\s*(</a>)', r'\1Farm Operations\2', content)

    # 2. Master Navigation Map (Update href only)
    
    # Home -> index.html
    # Matches <a href="#">Home</a>
    content = re.sub(r'(<a\s+[^>]*href=["\'])#(["\'][^>]*>\s*Home\s*</a>)', r'\1index.html\2', content)

    # Farm Operations (formerly Services) -> services.html
    # Note: Label might be "Services" or "Farm Operations" depending on order, but we already swapped label.
    # We want to ensure href is services.html for "Farm Operations"
    content = re.sub(r'(<a\s+[^>]*href=["\'])[^"\']*(["\'][^>]*>\s*Farm Operations\s*</a>)', r'\1services.html\2', content)
    
    # Projects -> project.html
    content = re.sub(r'(<a\s+[^>]*href=["\'])[^"\']*(["\'][^>]*>\s*(?:Projects?|projects?)\s*</a>)', r'\1project.html\2', content, flags=re.IGNORECASE)

    # Shop -> mega-shop.html
    content = re.sub(r'(<a\s+[^>]*href=["\'])[^"\']*(["\'][^>]*>\s*(?:Shop|shop)\s*</a>)', r'\1mega-shop.html\2', content)

    # Blog -> blog.html
    content = re.sub(r'(<a\s+[^>]*href=["\'])[^"\']*(["\'][^>]*>\s*Blog\s*</a>)', r'\1blog.html\2', content, flags=re.IGNORECASE)

    # About Us -> about.html (or just "About")
    content = re.sub(r'(<a\s+[^>]*href=["\'])[^"\']*(["\'][^>]*>\s*(?:About|About\s+Us)\s*</a>)', r'\1about.html\2', content, flags=re.IGNORECASE)

    # FAQ -> faq.html
    content = re.sub(r'(<a\s+[^>]*href=["\'])[^"\']*(["\'][^>]*>\s*(?:Faq|FAQ)\s*</a>)', r'\1faq.html\2', content, flags=re.IGNORECASE)

    # Testimonial -> testimonial.html
    content = re.sub(r'(<a\s+[^>]*href=["\'])[^"\']*(["\'][^>]*>\s*Testimonial\s*</a>)', r'\1testimonial.html\2', content, flags=re.IGNORECASE)

    # Team -> team.html
    content = re.sub(r'(<a\s+[^>]*href=["\'])[^"\']*(["\'][^>]*>\s*Team\s*</a>)', r'\1team.html\2', content, flags=re.IGNORECASE)

    # Contact -> contact.html
    content = re.sub(r'(<a\s+[^>]*href=["\'])[^"\']*(["\'][^>]*>\s*Contact\s*</a>)', r'\1contact.html\2', content, flags=re.IGNORECASE)


    # 3. Our Farm (Mega Menu) -> service-detail.html
    # This is trickier. We need to target the links inside the mega menu.
    # Given the snippet, they look like <li><a href="#">Tomatoes</a></li> inside .mega-menu
    # We will try to find the Mega Menu block and replace href="#" with href="service-detail.html" INSIDE it.
    
    # Strategy: Find the mega menu block start and end is hard with regex.
    # Alternative: The user listed specific sub-items: Poultry, Piggery, Horticulture, etc. 
    # Actually, the user said "Point all sub-items (Poultry, Piggery, Horticulture, etc.) to the service-detail.html file."
    # The snippet showed: <li><a href="#">Tomatoes</a></li>, <li><a href="#">Onions</a></li> etc.
    # We can replace href="#" with href="service-detail.html" ONLY if it follows a pattern usually found in these lists.
    # However, replacing ALL href="#" might be too aggressive if there are other placeholders.
    # But usually legit links have destinations. 
    # Let's target the exact list items seen in index.html to be safe, or use a broader context if possible.
    # The lists were inside <div class="mega-sub-block"> ... <ul> ... <li><a href="#">...</a></li>
    
    # We'll regex replace href="#" with href="service-detail.html" IF the link text is NOT Home, Shop, etc. which we already handled.
    # Actually, we already handled the main nav items. The remaining href="#" are likely the sub-items.
    # Let's act on href="#" specifically for items that look like list items in the mega menu.
    # To be safer: look for <li><a href="#">TEXT</a></li> where TEXT is not one of the main navs.
    # Or better, searching for the specific headers/items mentioned in the snippet:
    # Tomatoes, Onions, Green Beans, Cabbage, Carrots, Maize, Grain Crops, Watermelon, Ginger, Pumpkins, Broilers, Layers, Pork Production, Breeding, Meat, Cattle, Fish, Rabbits, Chitsano Roller Meal, By-Products, Fresh Pork, Chicken, Goat, Packaged Eggs, Sausages, Feed, Chicks, Seedlings, Manure, Training, Farm Tours, Marketplace & Distribution, MountPlus
    
    known_sub_items = [
        "Tomatoes", "Onions", "Green Beans", "Cabbage", "Carrots",
        "Maize", "Grain Crops", "Watermelon", "Ginger", "Pumpkins",
        "Broilers", "Layers", "Pork Production", "Breeding", "Meat",
        "Cattle", "Fish", "Rabbits", "Chitsano Roller Meal", "By-Products",
        "Fresh Pork", "Chicken", "Goat", "Packaged Eggs", "Sausages",
        "Feed", "Chicks", "Seedlings", "Manure",
        "Training", "Farm Tours", "Marketplace & Distribution", "MountPlus"
    ]
    
    for item in known_sub_items:
        # Replace matches of href="#" that wrap these specific texts
        # Note: Some texts might have whitespace
        pattern = r'(<a\s+href=["\'])#(["\'][^>]*>\s*' + re.escape(item) + r'\s*</a>)'
        content = re.sub(pattern, r'\1service-detail.html\2', content)


    # 4. Action Button Linkage
    # "Discover More" or "View All" on homepage -> about.html or services.html
    # "Discover More" -> about.html
    content = re.sub(r'(<a\s+[^>]*href=["\'])[^"\']*(["\'][^>]*class="[^"]*theme-btn[^"]*"[^>]*>\s*<span[^>]*>\s*<span[^>]*>\s*Discover More)', r'\1about.html\2', content, flags=re.IGNORECASE)
    # "View All" -> services.html. Sometimes "View All Projects" etc.
    # Assume "View All" generic button.
    content = re.sub(r'(<a\s+href=["\'])[^"\']*(["\'][^>]*>\s*View All\s*</a>)', r'\1services.html\2', content, flags=re.IGNORECASE)

    # "Read More" -> blog-classic.html
    content = re.sub(r'(<a\s+href=["\'])[^"\']*(["\'][^>]*class="[^"]*read-more[^"]*"[^>]*>\s*Read More)', r'\1blog-classic.html\2', content, flags=re.IGNORECASE)
     # Also catch "Read More &rarr;" type links if they exist and are generic
    content = re.sub(r'(<a\s+href=["\'])[^"\']*(["\'][^>]*>\s*Read More\s*&rarr;\s*</a>)', r'\1blog-classic.html\2', content, flags=re.IGNORECASE)

    # "Project Details" -> services.html
    # Often in overlay or button
    content = re.sub(r'(<a\s+[^>]*href=["\'])[^"\']*(["\'][^>]*>\s*(?:View\s+)?Project\s+Details\s*</a>)', r'\1services.html\2', content, flags=re.IGNORECASE)
    
    # 5. Branding & Contact
    
    # Logo links: <a href="..."> <img ... ecomatt-logo ... > </a>
    # We look for the logo img and ensure the wrapping A tag has index.html
    # Pattern: <a href="...">...<img...ecomatt-logo...>...</a>
    # This is hard with simple regex if they are far apart, but usually they are close.
    # Let's try replacing <a href="..."> that immediately precedes the logo image.
    content = re.sub(r'(<a\s+href=["\'])[^"\']*(["\'][^>]*>\s*<img\s+src="[^"]*ecomatt-logo\.png")', r'\1index.html\2', content)
    content = re.sub(r'(<a\s+href=["\'])[^"\']*(["\'][^>]*>\s*<img\s+src="[^"]*mobile-logo\.png")', r'\1index.html\2', content)
    content = re.sub(r'(<a\s+href=["\'])[^"\']*(["\'][^>]*>\s*<img\s+src="[^"]*footer-logo\.png")', r'\1index.html\2', content)

    # Phone: tel:+263714745653
    # Look for the phone number text or the specific href if it exists
    # The text is +263 71 474 5653
    content = re.sub(r'href=["\']tel:[^"\']*["\']([^>]*>\s*\+263\s*71\s*474\s*5653)', r'href="tel:+263714745653"\1', content)
    
    # Email: mailto:sales@ecomatt.co.zw
    content = re.sub(r'href=["\']mailto:[^"\']*["\']([^>]*>\s*sales@ecomatt\.co\.zw)', r'href="mailto:sales@ecomatt.co.zw"\1', content)

    if content != original_content:
        with open(filepath, 'w', encoding='utf-8') as f:
            f.write(content)
        print(f"Updated: {os.path.basename(filepath)}")
    else:
        print(f"No changes: {os.path.basename(filepath)}")

def main():
    root_dir = os.getcwd() # Run in current dir
    for filename in os.listdir(root_dir):
        if filename.endswith(".html") and not filename.startswith("temp_"):
            update_file(os.path.join(root_dir, filename))

if __name__ == "__main__":
    main()
