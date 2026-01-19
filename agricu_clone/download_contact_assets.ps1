
$baseUrl = "https://themecraze.net/html/agricu/"
$sourceFile = "contact_source.html"
$content = Get-Content $sourceFile -Raw

# Create directories
New-Item -ItemType Directory -Force -Path "assets/images" | Out-Null
New-Item -ItemType Directory -Force -Path "assets/images/background" | Out-Null
New-Item -ItemType Directory -Force -Path "assets/images/resource" | Out-Null
New-Item -ItemType Directory -Force -Path "assets/images/icons" | Out-Null
New-Item -ItemType Directory -Force -Path "assets/fonts" | Out-Null

# Function to download file
function Download-File {
    param($url, $outputPath)
    try {
        if (-not (Test-Path $outputPath)) {
            Invoke-WebRequest -Uri $url -OutFile $outputPath -ErrorAction Stop
            Write-Host "Downloaded: $outputPath"
        }
        else {
            Write-Host "Skipped (Exists): $outputPath"
        }
    }
    catch {
        Write-Warning "Failed to download $url : $_"
    }
}

# 1. Download Backgrounds
# Look for page title background
$bgMatches = $content | Select-String -Pattern 'style="background-image:url\((.*?)\)"' -AllMatches
foreach ($match in $bgMatches.Matches) {
    $relPath = $match.Groups[1].Value -replace "['""]", ""
    $fullUrl = "$baseUrl$relPath"
    $localPath = $relPath -replace "/", "\"
    Download-File -url $fullUrl -outputPath $localPath
}

# 2. Download Images (img tags)
$imgMatches = $content | Select-String -Pattern '<img[^>]+src="([^"]+)"' -AllMatches
foreach ($match in $imgMatches.Matches) {
    $relPath = $match.Groups[1].Value
    if ($relPath -notlike "http*" -and $relPath -notlike "data:*") {
        $fullUrl = "$baseUrl$relPath"
        $localPath = $relPath -replace "/", "\"
         
        # Ensure directory exists for nested paths
        $dir = Split-Path $localPath
        if (-not (Test-Path $dir)) { New-Item -ItemType Directory -Force -Path $dir | Out-Null }
         
        Download-File -url $fullUrl -outputPath $localPath
    }
}

# 3. Font Files (Critical for icons)
# Downloading generic font files if not already present
$fontFiles = @(
    "assets/fonts/fa-solid-900.woff2",
    "assets/fonts/fa-solid-900.woff",
    "assets/fonts/fa-solid-900.ttf",
    "assets/fonts/Flaticon.woff2",
    "assets/fonts/Flaticon.woff",
    "assets/fonts/Flaticon.ttf"
)

foreach ($fontPath in $fontFiles) {
    $fullUrl = "$baseUrl$fontPath"
    $localPath = $fontPath -replace "/", "\"
    Download-File -url $fullUrl -outputPath $localPath
}

Write-Host "Asset download complete."
