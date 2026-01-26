import os

files_to_fix = [
    r"e:\Desktop\ECOMATT-WEBSITE\agricu_clone\about.html",
    r"e:\Desktop\ECOMATT-WEBSITE\agricu_clone\blog-classic.html",
    r"e:\Desktop\ECOMATT-WEBSITE\agricu_clone\blog.html",
    r"e:\Desktop\ECOMATT-WEBSITE\agricu_clone\contact.html",
    r"e:\Desktop\ECOMATT-WEBSITE\agricu_clone\contact_source.html",
    r"e:\Desktop\ECOMATT-WEBSITE\agricu_clone\faq.html",
    r"e:\Desktop\ECOMATT-WEBSITE\agricu_clone\mega-shop.html",
    r"e:\Desktop\ECOMATT-WEBSITE\agricu_clone\project.html",
    r"e:\Desktop\ECOMATT-WEBSITE\agricu_clone\service-detail.html",
    r"e:\Desktop\ECOMATT-WEBSITE\agricu_clone\services.html",
    r"e:\Desktop\ECOMATT-WEBSITE\agricu_clone\shop.html",
    r"e:\Desktop\ECOMATT-WEBSITE\agricu_clone\shop1.html",
    r"e:\Desktop\ECOMATT-WEBSITE\agricu_clone\team.html",
    r"e:\Desktop\ECOMATT-WEBSITE\agricu_clone\temp_farmology_index.html",
    r"e:\Desktop\ECOMATT-WEBSITE\agricu_clone\temp_frutin_shop.html",
    r"e:\Desktop\ECOMATT-WEBSITE\agricu_clone\temp_frutin_shop_v2.html",
    r"e:\Desktop\ECOMATT-WEBSITE\agricu_clone\temp_index2.html",
    r"e:\Desktop\ECOMATT-WEBSITE\agricu_clone\temp_index3.html",
    r"e:\Desktop\ECOMATT-WEBSITE\agricu_clone\temp_reference.html",
    r"e:\Desktop\ECOMATT-WEBSITE\agricu_clone\temp_reference_index2.html",
    r"e:\Desktop\ECOMATT-WEBSITE\agricu_clone\temp_source.html",
    r"e:\Desktop\ECOMATT-WEBSITE\agricu_clone\testimonial.html",
    r"e:\Desktop\ECOMATT-WEBSITE\agricu_clone\testimonial_source.html",
    r"e:\Desktop\ECOMATT-WEBSITE\agricu_clone\assets\css\custom-sections.css"
]

def clean_file(filepath):
    if not os.path.exists(filepath):
        print(f"File not found: {filepath}")
        return

    try:
        with open(filepath, 'r', encoding='utf-8') as f:
            lines = f.readlines()
    except Exception as e:
        print(f"Error reading {filepath}: {e}")
        return

    new_lines = []
    state = "NORMAL" # NORMAL, IN_HEAD, IN_INCOMING
    
    conflict_found = False

    for line in lines:
        if line.strip().startswith("<<<<<<< HEAD"):
            state = "IN_HEAD"
            conflict_found = True
            continue
        
        if state == "IN_HEAD":
            if line.strip().startswith("======="):
                state = "IN_INCOMING"
                continue
            # Skip lines in HEAD block
            continue
            
        if state == "IN_INCOMING":
            if line.strip().startswith(">>>>>>>"):
                state = "NORMAL"
                continue
            # Keep lines in INCOMING block
            new_lines.append(line)
            continue
            
        if state == "NORMAL":
            new_lines.append(line)

    if conflict_found:
        try:
            with open(filepath, 'w', encoding='utf-8') as f:
                f.writelines(new_lines)
            print(f"Fixed conflicts in: {filepath}")
        except Exception as e:
            print(f"Error writing {filepath}: {e}")
    else:
        print(f"No conflicts found in: {filepath}")

for fp in files_to_fix:
    clean_file(fp)
