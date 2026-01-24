$baseUrl = "https://themecraze.net/html/agricu/assets/images"
$localBase = "assets/images"

$files = @(
    @{Remote = "resource/team-1.jpg"; Local = "resource/team-1.jpg" },
    @{Remote = "resource/team-2.jpg"; Local = "resource/team-2.jpg" },
    @{Remote = "resource/team-3.jpg"; Local = "resource/team-3.jpg" },
    @{Remote = "resource/team-4.jpg"; Local = "resource/team-4.jpg" },
    @{Remote = "resource/team-5.jpg"; Local = "resource/team-5.jpg" },
    @{Remote = "resource/team-6.jpg"; Local = "resource/team-6.jpg" },
    @{Remote = "background/page-title.jpg"; Local = "background/page-title.jpg" },
    @{Remote = "background/footer-pattern-1.png"; Local = "background/footer-pattern-1.png" }
)

foreach ($file in $files) {
    $remoteUrl = "$baseUrl/$($file.Remote)"
    $localPath = "$localBase/$($file.Local)"
    $dir = Split-Path $localPath
    if (!(Test-Path $dir)) { mkdir $dir }
    
    Write-Host "Downloading $remoteUrl to $localPath..."
    try {
        Invoke-WebRequest -Uri $remoteUrl -OutFile $localPath -UserAgent "Mozilla/5.0" -ErrorAction Stop
        Write-Host "Success." -ForegroundColor Green
    }
    catch {
        Write-Host "Failed: $_" -ForegroundColor Red
    }
}
