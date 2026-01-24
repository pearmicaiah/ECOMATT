import os
import re
import requests
from urllib.parse import urljoin

BASE_URL = "https://html.themehour.net/frutin/demo/"
HTML_FILE = "temp_frutin_shop_v2.html"
OUTPUT_DIR = "assets"

def download_assets():
    # Read HTML
    if not os.path.exists(HTML_FILE):
        print(f"Error: {HTML_FILE} not found.")
        return

    with open(HTML_FILE, 'r', encoding='utf-8') as f:
        content = f.read()

    # Regex for images and backgrounds
    # Matches src="..." and url('...')
    img_patterns = [
        r'src=["\']([^"\']+\.(?:jpg|png|svg|jpeg|gif|webp))["\']',
        r'data-bg-src=["\']([^"\']+\.(?:jpg|png|svg|jpeg|gif|webp))["\']',
        r'url\([\"\']?([^\"\')]+\.(?:jpg|png|svg|jpeg|gif|webp))[\"\']?\)'
    ]

    assets = set()
    for pattern in img_patterns:
        matches = re.findall(pattern, content)
        for match in matches:
            if not match.startswith('data:') and not match.startswith('http'):
                # Normalize path
                clean_path = match.split('?')[0].split('#')[0]
                # Remove ../ if present at start (basic)
                clean_path = clean_path.replace('../', '')
                if clean_path.startswith('assets/'):
                    assets.add(clean_path)
                else:
                    assets.add(clean_path) 

    print(f"Found {len(assets)} unique assets.")

    for asset_path in assets:
        # We assume assets should go into local 'assets/' structure
        # If path is 'assets/img/foo.jpg', we save to 'assets/img/foo.jpg'
        # If path is 'images/foo.jpg', we might want to map it? 
        # But Frutin seems to use 'assets/' base.
        
        # URL construction
        file_url = urljoin(BASE_URL, asset_path)
        
        # Local path construction
        # Force 'assets/' prefix if not present for local storage consistency with our HTML rewrite?
        # Actually, let's trust the relative path matches the HTML structure.
        local_path = asset_path.replace('/', os.sep)
        
        # Ensure it starts with assets mainly
        if not asset_path.startswith('assets/'):
             # If source is 'images/foo.jpg', we save to 'images/foo.jpg' relative to root
             pass

        dir_name = os.path.dirname(local_path)
        if dir_name and not os.path.exists(dir_name):
            try:
                os.makedirs(dir_name)
            except OSError as e:
                print(f"Could not create dir {dir_name}: {e}")
                continue

        if not os.path.exists(local_path):
            print(f"Downloading {asset_path}...")
            try:
                r = requests.get(file_url, timeout=10)
                if r.status_code == 200:
                    with open(local_path, 'wb') as f:
                        f.write(r.content)
                else:
                    print(f"Failed {asset_path}: Status {r.status_code}")
            except Exception as e:
                print(f"Error downloading {asset_path}: {e}")
        else:
            # print(f"Skipping {asset_path} (exists)")
            pass

if __name__ == "__main__":
    download_assets()
