import re

def read_file(path):
    with open(path, 'r', encoding='utf-8') as f:
        return f.read()

def write_file(path, content):
    with open(path, 'w', encoding='utf-8') as f:
        f.write(content)

def extract_block(content, start_marker, end_marker):
    pattern = re.compile(f'({re.escape(start_marker)}.*?{re.escape(end_marker)})', re.DOTALL)
    match = pattern.search(content)
    if match:
        return match.group(1)
    return None

def main():
    index_content = read_file('e:\\Desktop\\ECOMATT-WEBSITE\\agricu_clone\\index.html')
    team_content = read_file('e:\\Desktop\\ECOMATT-WEBSITE\\agricu_clone\\team.html')

    # Extract Header from index.html
    header_block = extract_block(index_content, '<!-- Main Header -->', '<!-- End Main Header -->')
    if not header_block:
        print("Error: Could not find Header in index.html")
        return

    # Extract Footer from index.html (Site Footer Two)
    footer_block = extract_block(index_content, '<!--Site Footer Two Start-->', '<!--Site Footer Two End-->')
    if not footer_block:
        print("Error: Could not find Footer in index.html")
        return

    # Replace Header in team.html
    # team.html header might be slightly different layout but has same markers
    team_content = re.sub(r'<!-- Main Header -->.*?<!-- End Main Header -->', header_block, team_content, flags=re.DOTALL)

    # Replace Footer in team.html
    # team.html currently has "Main Footer" style one. We want to replace it with Site Footer Two.
    # We will look for <!-- Main Footer --> ... <!-- End Footer Style -->
    # BUT, the replacement footer ends with <!--Site Footer Two End-->.
    # The original team.html footer block:
    # <!-- Main Footer --> ... <!-- End Footer Style -->
    team_content = re.sub(r'<!-- Main Footer -->.*?<!-- End Footer Style -->', footer_block + '\n<!-- End Footer Style -->', team_content, flags=re.DOTALL)

    # Insert Wrapper
    # Before <!-- Page Title -->
    wrapper_start = '<div class="main-content-wrapper" style="padding-top: 120px;">'
    team_content = team_content.replace('<!-- Page Title -->', wrapper_start + '\n\t<!-- Page Title -->')

    # After <!-- Clients One --> block (which ends with </section>)
    # We look for <!-- Clients One --> ... </section> ... <!-- Clients One --> (End comment seems to be <!-- Clients One --> in team.html lines 590 and 636)
    # Line 636 is <!-- Clients One -->? No, line 636 is <!-- Clients One -->. The block starts at 591.
    # Let's target the exact end of that section.
    # Structure:
    # <!-- Clients One -->
    # <section ...>
    # ...
    # </section>
    # <!-- Clients One -->
    
    # We want to close the wrapper AFTER this entire block.
    # So we replace the second <!-- Clients One --> (or just find the closing tag and append)
    # A safer way: Find "<!-- Main Footer -->" (which we replaced) or "<!--Site Footer Two Start-->"
    # The wrapper should end BEFORE the footer start.
    
    wrapper_end = '</div><!-- End Main Content Wrapper -->\n'
    team_content = team_content.replace('<!--Site Footer Two Start-->', wrapper_end + '\n<!--Site Footer Two Start-->')

    # Add Styling in Head
    style_block = """
<style>
    .logo img { max-height: 80px; }
    .team-block_one-title a { font-weight: 700 !important; color: #569D03 !important; }
    .team-block_one-designation { font-weight: 600 !important; color: #1f1e1d !important; }
</style>
"""
    team_content = team_content.replace('</head>', style_block + '\n</head>')

    write_file('e:\\Desktop\\ECOMATT-WEBSITE\\agricu_clone\\team.html', team_content)
    print("Successfully synced team.html")

if __name__ == "__main__":
    main()
