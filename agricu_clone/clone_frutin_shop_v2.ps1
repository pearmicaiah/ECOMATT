$ErrorActionPreference = 'Stop'
$baseUrl = "https://html.themehour.net/frutin/demo/"

# 1. Read Templates & Content
$tempHtml = Get-Content -Path 'temp_frutin_shop.html' -Raw -Encoding UTF8
$indexHtml = Get-Content -Path 'index.html' -Raw -Encoding UTF8
$frutinStyle = Get-Content -Path 'temp_frutin_style.css' -Raw -Encoding UTF8
$frutinApp = Get-Content -Path 'temp_frutin_app.css' -Raw -Encoding UTF8

# Extract Main Content
$contentRegex = "(?s)(?<=header-layout3..>)(.*?)(?=<div class=.footer-top-newsletter)"
$match = [regex]::Match($tempHtml, $contentRegex)
if (-not $match.Success) {
    # Fallback capture
    $contentRegex = "(?s)(?<=header-layout3..>)(.*?)(?=<footer)"
    $match = [regex]::Match($tempHtml, $contentRegex)
}
$uniqueContent = $match.Value

# 2. CSS Safeguarding (Critical for Header/Footer)
# We can't fully namespace minified CSS easily, but we CAN prevent it from breaking the global header/footer
# by renaming the selectors it likely uses to target them.
$safeApp = $frutinApp -replace "header(?![a-zA-Z-])", ".frutin-disabled-header" `
    -replace "footer(?![a-zA-Z-])", ".frutin-disabled-footer" `
    -replace "\.main-header", ".frutin-disabled-main-header" `
    -replace "\.sticky-wrapper", ".frutin-sticky-wrapper"  # Prevent double sticky

$safeStyle = $frutinStyle -replace "header(?![a-zA-Z-])", ".frutin-disabled-header" `
    -replace "footer(?![a-zA-Z-])", ".frutin-disabled-footer" `
    -replace "\.main-header", ".frutin-disabled-main-header"

# Combine CSS
$finalCss = $safeApp + "`n" + $safeStyle
Set-Content -Path "css/frutin-style.css" -Value $finalCss -Encoding UTF8

# 3. JS Handling
# Download Frutin specific Scripts
$jsFiles = @("assets/js/app.min.js", "assets/js/main.js")
foreach ($js in $jsFiles) {
    $fileName = Split-Path $js -Leaf
    $localPath = "js/frutin-$fileName" 
    $dlUrl = $baseUrl + $js
    Invoke-WebRequest -Uri $dlUrl -OutFile $localPath -ErrorAction SilentlyContinue
}

# 4. Asset Download (Images/Fonts)
$assetsRegex = '["'']([^"'']+\.(?:jpg|png|svg|jpeg|gif|webp))["'']'
$matches = [regex]::Matches($uniqueContent, $assetsRegex)
$imgAssets = $matches | ForEach-Object { $_.Groups[1].Value }

$cssUrlRegex = 'url\s*\((?:["'']?)([^)"'']+)["'']?\)'
$cssMatches = [regex]::Matches($finalCss, $cssUrlRegex)
$cssAssets = $cssMatches | ForEach-Object { $_.Groups[1].Value }

$allAssets = $imgAssets + $cssAssets | Select-Object -Unique

foreach ($relPath in $allAssets) {
    if ($relPath -match "^data:" -or $relPath -match "^http") { continue }
    $cleanPath = $relPath.Split('?')[0].Split('#')[0] -replace '../', ''
    
    # Map to assets/
    if ($cleanPath -notmatch "^assets/") { $targetPath = "assets/" + $cleanPath } else { $targetPath = $cleanPath }
    
    $localFile = $targetPath -replace '/', '\'
    $dir = Split-Path $localFile -Parent
    if (-not (Test-Path $dir)) { New-Item -ItemType Directory -Force -Path $dir | Out-Null }
    
    try {
        if (-not (Test-Path $localFile)) {
            Invoke-WebRequest -Uri ($baseUrl + $cleanPath) -OutFile $localFile -ErrorAction SilentlyContinue
        }
    }
    catch {}
}

# 5. HTML Assembly
# Prepare Shell
$shellSplitStart = "<!-- End About Sidebar -->"
$shellSplitEnd = "<!-- Main Footer -->"
$parts = $indexHtml -split [regex]::Escape($shellSplitStart)
$preContent = $parts[0] + "<!-- End About Sidebar -->"
$rest = $indexHtml.Substring($indexHtml.IndexOf($shellSplitEnd))
$postContent = $rest

# Inject Wrapper
$wrappedContent = "`n<div class='frutin-shop-wrapper' style='padding-top: 120px;'>`n" + $uniqueContent + "`n</div>`n"

# Inject Head Resources
# Frutin Fonts + CSS
$frutinHead = @"
<link href="https://fonts.googleapis.com/css2?family=Akshar:wght@300..700&family=DM+Sans:ital,wght@0,100..1000;1,100..1000&family=Shadows+Into+Light+Two&display=swap" rel="stylesheet">
<link href='css/frutin-style.css' rel='stylesheet'>
<style>
    /* Critical Fixes for Frutin Integration */
    .frutin-shop-wrapper img { max-width: 100%; } 
    .main-header .logo img { max-height: 80px !important; width: auto !important; }
    /* Fix Swiper Conflicts if any */
    .swiper-container { overflow: hidden; }
</style>
"@
$preContent = $preContent -replace "</head>", "$frutinHead`n</head>"

# Inject Scripts before body end
# We use Ecomatt's jQuery, then Frutin's App/Main
# Note: Frutin's app.min.js might include jQuery too, causing conflicts. 
# We'll stick to just these new files after the existing ones.
$frutinScripts = @"
<script src="js/frutin-app.min.js"></script>
<script src="js/frutin-main.js"></script>
"@
$postContent = $postContent -replace "</body>", "$frutinScripts`n</body>"

$finalHtml = $preContent + $wrappedContent + $postContent
$finalHtml = $finalHtml -replace "<title>.*?</title>", "<title>Ecomatt | Mega Shop</title>"

Set-Content -Path 'mega-shop.html' -Value $finalHtml -Encoding UTF8
Write-Host "Refined Clone Complete."
