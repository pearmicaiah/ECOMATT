$files = @(
    "about.html",
    "blog-classic.html",
    "blog.html",
    "contact.html",
    "contact_source.html",
    "faq.html",
    "mega-shop.html",
    "project.html",
    "service-detail.html",
    "services.html",
    "shop.html",
    "shop1.html",
    "team.html",
    "temp_farmology_index.html",
    "temp_frutin_shop.html",
    "temp_frutin_shop_v2.html",
    "temp_index2.html",
    "temp_index3.html",
    "temp_reference.html",
    "temp_reference_index2.html",
    "temp_source.html",
    "testimonial.html",
    "testimonial_source.html",
    "assets\css\custom-sections.css"
)

foreach ($file in $files) {
    $path = Join-Path -Path $PWD -ChildPath $file
    if (Test-Path $path) {
        $content = Get-Content -Path $path
        $newContent = @()
        $state = "NORMAL"
        $conflictFound = $false

        foreach ($line in $content) {
            if ($line -match "^<<<<<<< HEAD") {
                $state = "IN_HEAD"
                $conflictFound = $true
                continue
            }
            
            if ($state -eq "IN_HEAD") {
                if ($line -match "^=======") {
                    $state = "IN_INCOMING"
                    continue
                }
                continue
            }

            if ($state -eq "IN_INCOMING") {
                if ($line -match "^>>>>>>>") {
                    $state = "NORMAL"
                    continue
                }
                $newContent += $line
                continue
            }

            if ($state -eq "NORMAL") {
                $newContent += $line
            }
        }

        if ($conflictFound) {
            $newContent | Set-Content -Path $path -Encoding UTF8
            Write-Host "Fixed conflicts in: $file"
        } else {
            Write-Host "No conflicts found in: $file"
        }
    } else {
        Write-Host "File not found: $path"
    }
}
