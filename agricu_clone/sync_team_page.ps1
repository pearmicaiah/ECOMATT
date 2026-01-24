$indexContent = Get-Content "index.html" -Raw -Encoding UTF8
$teamContent = Get-Content "team.html" -Raw -Encoding UTF8

# Extract Header from index.html
if ($indexContent -match '(?s)<!-- Main Header -->(.*?)<!-- End Main Header -->') {
    $headerBlock = $matches[0]
}
else {
    Write-Host "Error: Header not found in index.html" -ForegroundColor Red
    exit 1
}

# Extract Footer from index.html (Site Footer Two)
if ($indexContent -match '(?s)<!--Site Footer Two Start-->(.*?)<!--Site Footer Two End-->') {
    $footerBlock = $matches[0]
}
else {
    Write-Host "Error: Footer not found in index.html" -ForegroundColor Red
    exit 1
}

# Replace Header in team.html
$teamContent = [regex]::Replace($teamContent, '(?s)<!-- Main Header -->(.*?)<!-- End Main Header -->', $headerBlock)

# Replace Footer in team.html
# Replacing the existing "Main Footer" block with the extracted "Site Footer Two" block
$teamContent = [regex]::Replace($teamContent, '(?s)<!-- Main Footer -->(.*?)<!-- End Footer Style -->', "$footerBlock`r`n<!-- End Footer Style -->")

# Insert Wrapper
# Before <!-- Page Title -->
$wrapperStart = '<div class="main-content-wrapper" style="padding-top: 120px;">'
$teamContent = $teamContent.Replace('<!-- Page Title -->', "$wrapperStart`r`n    <!-- Page Title -->")

# Close Wrapper before Footer
$wrapperEnd = '</div><!-- End Main Content Wrapper -->'
$teamContent = $teamContent.Replace('<!--Site Footer Two Start-->', "$wrapperEnd`r`n<!--Site Footer Two Start-->")

# Add Styling in Head
$styleBlock = @"
<style>
    .logo img { max-height: 80px; }
    .team-block_one-title a { font-weight: 700 !important; color: #569D03 !important; }
    .team-block_one-designation { font-weight: 600 !important; color: #1f1e1d !important; }
</style>
"@
$teamContent = $teamContent.Replace('</head>', "$styleBlock`r`n</head>")

Set-Content "team.html" -Value $teamContent -Encoding UTF8
Write-Host "Successfully synced team.html" -ForegroundColor Green
