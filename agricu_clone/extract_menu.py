from bs4 import BeautifulSoup

with open('temp_frutin_shop.html', 'r', encoding='utf-8') as f:
    html = f.read()

soup = BeautifulSoup(html, 'html.parser')
category_menu = soup.find(class_='category-menu-wrap')

if category_menu:
    print("FOUND_MENU_START")
    print(category_menu.prettify())
    print("FOUND_MENU_END")
else:
    print("Menu not found")
