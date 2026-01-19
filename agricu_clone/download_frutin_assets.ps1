$ErrorActionPreference = 'Continue'
$baseUrl = "https://html.themehour.net/frutin/demo/"
$htmlFile = "mega-shop.html"

if (-not (Test-Path $htmlFile)) { Write-Error "HTML file not found"; exit }

$content = Get-Content $htmlFile -Raw

# Match src, data-bg-src, url()
# We process them to get clean paths
$patterns = @(
    'src=["'']([^"'']+\.(?:jpg|png|svg|jpeg|gif|webp))["'']',
    'data-bg-src=["'']([^"'']+\.(?:jpg|png|svg|jpeg|gif|webp))["'']',
    'url\([\"\^\'']?([^\"\^\'')]+\.(?:jpg|png|svg|jpeg|gif|webp))[\"\^\'']?\)'
)

$uniqueAssets = @{}

foreach ($pat in $patterns) {
    $matches = [regex]::Matches($content, $pat)
    foreach ($m in $matches) {
        $raw = $m.Groups[1].Value
        if ($raw -match "^data:" -or $raw -match "^http") { continue }
        
        $clean = $raw.Split('?')[0].Split('#')[0]
        # Remove leading ../
        $clean = $clean -replace '^\.\./', ''
        
        if (-not $uniqueAssets.ContainsKey($clean)) {
            $uniqueAssets[$clean] = $true
        }
    }
}

Write-Host "Found $($uniqueAssets.Count) unique assets to download."

foreach ($path in $uniqueAssets.Keys) {
    # If path starts with assets/, we keep it structure
    # If it starts with images/, we might need to map it, but let's assume relative to root
    
    $dlUrl = $baseUrl + $path
    $localPath = $path -replace '/', '\'
    
    $dir = Split-Path $localPath -Parent
    if (-not (Test-Path $dir)) { New-Item -ItemType Directory -Force -Path $dir | Out-Null }
    
    if (-not (Test-Path $localPath)) {
        Write-Host "Downloading $path..."
        try {
            Invoke-WebRequest -Uri $dlUrl -OutFile $localPath -ErrorAction Stop
        }
        catch {
            Write-Warning "Failed to download $dlUrl"
        }
    }
}

Write-Host "Download Complete."
