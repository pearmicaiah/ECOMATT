$ErrorActionPreference = 'Stop'

# Base URL for Frutin Demo
$baseUrl = "https://html.themehour.net/frutin/demo/"

# Define the folder structure
$fontDirs = @(
    "assets/fonts/fontawesome",
    "assets/fonts",
    "css"
)

# Create directories if they don't exist
foreach ($dir in $fontDirs) {
    if (-not (Test-Path $dir)) {
        New-Item -ItemType Directory -Force -Path $dir | Out-Null
        Write-Host "Created directory: $dir"
    }
}

# List of files to download [SourcePath, DestinationPath]
$filesToDownload = @(
    # FontAwesome Fonts
    @("assets/fonts/fontawesome/fa-light-300.woff2", "assets/fonts/fontawesome/fa-light-300.woff2"),
    @("assets/fonts/fontawesome/fa-regular-400.woff2", "assets/fonts/fontawesome/fa-regular-400.woff2"),
    @("assets/fonts/fontawesome/fa-solid-900.woff2", "assets/fonts/fontawesome/fa-solid-900.woff2"),
    @("assets/fonts/fontawesome/fa-brands-400.woff2", "assets/fonts/fontawesome/fa-brands-400.woff2"),
    @("assets/fonts/fontawesome/fa-light-300.woff", "assets/fonts/fontawesome/fa-light-300.woff"),
    @("assets/fonts/fontawesome/fa-regular-400.woff", "assets/fonts/fontawesome/fa-regular-400.woff"),
    @("assets/fonts/fontawesome/fa-solid-900.woff", "assets/fonts/fontawesome/fa-solid-900.woff"),
    @("assets/fonts/fontawesome/fa-brands-400.woff", "assets/fonts/fontawesome/fa-brands-400.woff"),
    @("assets/fonts/fontawesome/fa-light-300.ttf", "assets/fonts/fontawesome/fa-light-300.ttf"),
    @("assets/fonts/fontawesome/fa-regular-400.ttf", "assets/fonts/fontawesome/fa-regular-400.ttf"),
    @("assets/fonts/fontawesome/fa-solid-900.ttf", "assets/fonts/fontawesome/fa-solid-900.ttf"),
    @("assets/fonts/fontawesome/fa-brands-400.ttf", "assets/fonts/fontawesome/fa-brands-400.ttf"),

    # Flaticon Fonts
    @("assets/fonts/flaticon_mycollection.woff2", "assets/fonts/flaticon_mycollection.woff2"),
    @("assets/fonts/flaticon_mycollection.woff", "assets/fonts/flaticon_mycollection.woff"),
    @("assets/fonts/flaticon_mycollection.ttf", "assets/fonts/flaticon_mycollection.ttf"),

    # CSS
    @("assets/css/fontawesome.min.css", "css/frutin-fontawesome.min.css")
)

foreach ($pair in $filesToDownload) {
    $remotePath = $pair[0]
    $localPath = $pair[1]
    $url = $baseUrl + $remotePath

    Write-Host "Downloading $url to $localPath..."
    try {
        Invoke-WebRequest -Uri $url -OutFile $localPath -ErrorAction Stop
        Write-Host "  -> Success"
    }
    catch {
        Write-Warning "  -> Failed: $($_.Exception.Message)"
    }
}
