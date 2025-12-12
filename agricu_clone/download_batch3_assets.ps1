$baseUrl = "https://themecraze.net/html/agricu/assets/images"
$destBase = "d:\ECOMATT\agricu_clone\assets\images"

$files = @(
    "resources/cta-one-img-1.png",
    "shapes/cta-one-shape-1.png",
    "shapes/cta-one-shape-2.png",
    "shapes/cta-one-shape-bg.png",
    "icon/app-1.png",
    "icon/app-2.png",
    "backgrounds/testimonial-one-bg.jpg",
    "testimonial/testimonial-1-1.jpg",
    "testimonial/testimonial-1-2.jpg",
    "testimonial/testimonial-1-3.jpg",
    "testimonial/testimonial-1-4.jpg",
    "testimonial/testimonial-1-5.jpg",
    "testimonial/testimonial-1-6.jpg",
    "backgrounds/testimonial-one-text-box-bg.jpg",
    "shapes/testimonial-one-single-shape-1.png",
    "blog/blog-1-1.jpg",
    "blog/blog-1-2.jpg",
    "blog/blog-1-3.jpg"
)

foreach ($file in $files) {
    $url = "$baseUrl/$file"
    $dest = "$destBase\$file"
    $dir = Split-Path $dest
    if (!(Test-Path $dir)) {
        New-Item -ItemType Directory -Force -Path $dir | Out-Null
    }
    Write-Host "Downloading $url to $dest..."
    try {
        Invoke-WebRequest -Uri $url -OutFile $dest
    } catch {
        Write-Warning "Failed to download $file : $_"
    }
}
