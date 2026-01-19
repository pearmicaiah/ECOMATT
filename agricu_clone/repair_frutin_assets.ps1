$ErrorActionPreference = 'Continue'
$baseUrl = "https://html.themehour.net/frutin/demo/"

# Read Headers
$tempHtml = Get-Content -Path 'temp_frutin_shop.html' -Raw -Encoding UTF8

# 1. Image Assets
$assetsRegex = 'src=["'']([^"'']+\.(?:jpg|png|svg|jpeg|gif|webp))["'']'
$matches = [regex]::Matches($tempHtml, $assetsRegex)
$imgAssets = $matches | ForEach-Object { $_.Groups[1].Value } | Select-Object -Unique

Write-Host "Found $( $imgAssets.Count ) images."

foreach ($relPath in $imgAssets) {
    if ($relPath -match "^data:" -or $relPath -match "^http") { continue }
    $cleanPath = $relPath.Split('?')[0].Split('#')[0] -replace '../', ''
    
    # Force assets/ path
    if ($cleanPath -notmatch "^assets/") { $targetPath = "assets/" + $cleanPath } else { $targetPath = $cleanPath }
    
    $localFile = $targetPath -replace '/', '\'
    $dlUrl = $baseUrl + $cleanPath
    
    $dir = Split-Path $localFile -Parent
    if (-not (Test-Path $dir)) { New-Item -ItemType Directory -Force -Path $dir | Out-Null }
    
    try {
        if (-not (Test-Path $localFile)) {
            Write-Host "Downloading $localFile..."
            Invoke-WebRequest -Uri $dlUrl -OutFile $localFile
        }
    }
    catch {
        Write-Warning "Failed to download $dlUrl"
    }
}

# 2. FontAwesome (Localize to ensure icons work)
$fontCss = "assets/css/fontawesome.min.css"
$localFontCss = "assets/css/frutin-fontawesome.min.css" # Rename to avoid conflict
Invoke-WebRequest -Uri ($baseUrl + $fontCss) -OutFile $localFontCss -ErrorAction SilentlyContinue

# Parse Webfonts from CSS (simple heuristic)
# Usually ../webfonts/
# We will just manually download the standard set
$webfonts = @("fa-brands-400.woff2", "fa-regular-400.woff2", "fa-solid-900.woff2", "fa-v4compatibility.woff2")
foreach ($wf in $webfonts) {
    $wfUrl = $baseUrl + "assets/webfonts/" + $wf
    $wfLocal = "assets/webfonts/" + $wf
    if (-not (Test-Path "assets/webfonts")) { New-Item -ItemType Directory -Force -Path "assets/webfonts" | Out-Null }
    try {
        Invoke-WebRequest -Uri $wfUrl -OutFile $wfLocal -ErrorAction SilentlyContinue
    }
    catch {}
}

Write-Host "Asset Repair Done."
