$ErrorActionPreference = 'Stop'

# Paths
$frutinPath = 'temp_frutin_shop_v2.html'
$indexPath = 'index.html'
$targetPath = 'mega-shop.html'

# 1. Read Contents
$frutinHtml = Get-Content -Path $frutinPath -Raw -Encoding UTF8
$indexHtml = Get-Content -Path $indexPath -Raw -Encoding UTF8

# 2. Extract Frutin Content
# We want everything between header end and footer start
# Frutin Header End: </header>
# Frutin Footer Start: <footer
$contentPattern = "(?s)(?<=<\/header>)(.*?)(?=<div class=.footer-top-newsletter|<footer)"
$match = [regex]::Match($frutinHtml, $contentPattern)

if (-not $match.Success) {
    # Fallback if footer-top-newsletter is not found
    $contentPattern = "(?s)(?<=<\/header>)(.*?)(?=<footer)"
    $match = [regex]::Match($frutinHtml, $contentPattern)
}

if ($match.Success) {
    $uniqueContent = $match.Value
    
    # 2a. Scrub Scripts from Content (to avoid duplicates or execution in wrong order)
    $uniqueContent = $uniqueContent -replace "(?s)<script.*?</script>", ""
    
    # 2b. Scrub Preloader if captured (usually it's in body top, but just in case)
    $uniqueContent = $uniqueContent -replace "(?s)<div class=.preloader.*?</div>", ""

}
else {
    Write-Error "Could not extract content from Frutin HTML"
}

# 3. Prepare Ecomatt Shell
# We split index.html at the end of the header and start of the footer
# Finding Header End in Ecomatt
# Logic: Find </header> and look for sticky wrapper/mobile menu ends if adjacent
# Safer: Just split after </header> and before <footer
$headerEndRegex = "(?s).*<\/header>"
$headerMatch = [regex]::Match($indexHtml, $headerEndRegex)
if ($headerMatch.Success) {
    # We want to keep everything up to the </header>
    # BUT wait, Ecomatt index.html has content between header and footer. We discard that.
    $headerEndPos = $indexHtml.IndexOf("</header>") + 9
    $ecomattHeader = $indexHtml.Substring(0, $headerEndPos)
}
else {
    Write-Error "Could not find header in index.html"
}

# Finding Footer Start in Ecomatt
$footerStartRegex = "<footer"
$footerStartPos = $indexHtml.IndexOf($footerStartRegex)
if ($footerStartPos -ge 0) {
    $ecomattFooter = $indexHtml.Substring($footerStartPos)
}
else {
    Write-Error "Could not find footer in index.html"
}

# 4. Construct New HTML
# Wrap content in isolated div
# Added padding-top to account for fixed header overlay
$wrapper = "<div class='frutin-shop-wrapper' style='padding-top: 0px;'>
    $uniqueContent
</div>"

# Inject CSS in Head (Replace </head>)
$cssInject = @"
<link href="https://fonts.googleapis.com/css2?family=Akshar:wght@300..700&family=DM+Sans:ital,wght@0,100..1000;1,100..1000&family=Shadows+Into+Light+Two&display=swap" rel="stylesheet">
<link href='css/frutin-style.css' rel='stylesheet'>
<link href='assets/css/frutin-fontawesome.min.css' rel='stylesheet'>
<style>
    /* Critical Fixes */
    .frutin-shop-wrapper img { max-width: 100%; } 
    .main-header .logo img { max-height: 80px !important; width: auto !important; }
    /* Ensure header sits on top */
    .main-header { z-index: 9999 !important; }
    .frutin-shop-wrapper { position: relative; z-index: 1; }
</style>
"@
$finalHeader = $ecomattHeader -replace "</head>", "$cssInject`n</head>"

# Inject Scripts before Body End (Replace </body>)
$scriptInject = @"
<!-- Frutin Scripts -->
<script src="js/frutin-app.min.js"></script>
<script src="js/frutin-main.js"></script>
"@
$finalFooter = $ecomattFooter -replace "</body>", "$scriptInject`n</body>"

# Assemble
$finalHtml = $finalHeader + "`n" + $wrapper + "`n" + $finalFooter
$finalHtml = $finalHtml -replace "<title>.*?</title>", "<title>Ecomatt | Mega Shop</title>"

Set-Content -Path $targetPath -Value $finalHtml -Encoding UTF8
Write-Host "Re-Clone Complete. Content injected."
