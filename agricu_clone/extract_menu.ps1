$ErrorActionPreference = 'Stop'
$content = Get-Content 'temp_frutin_shop.html' -Raw -Encoding UTF8
# Regex to find the category-menu-wrap div content
# Matching nested divs with regex is hard, but we know the structure ends with </nav></div> based on my review
$regex = '(?s)<div class="category-menu-wrap">.*?<\/nav><\/div>'
$match = [regex]::Match($content, $regex)

if ($match.Success) {
    Set-Content 'menu_extract.txt' -Value $match.Value -Encoding UTF8
    Write-Host "Extracted to menu_extract.txt"
}
else {
    Write-Error "Content not found"
}
