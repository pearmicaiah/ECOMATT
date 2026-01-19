
$indexContent = Get-Content "index.html" -Raw
$sourceContent = Get-Content "contact_source.html" -Raw

# 1. Extract Head (ensure all styles are present)
if ($indexContent -match '(?ms)(<head>.*?</head>)') {
    $headBlock = $matches[1]
    # Add original contact specific styles if needed (usually covered by style.css but just in case)
    # Also ensuring assets/css/style.css is linked for specific page layouts
    if ($headBlock -notmatch 'assets/css/style.css') {
        $headBlock = $headBlock -replace '</head>', '
    <link href="assets/css/style.css" rel="stylesheet">
    <link href="assets/css/responsive.css" rel="stylesheet">
    <style>
        .logo img { max-height: 80px; width: auto; }
        .contact-one-info { font-weight: 700; }
        .contact-one-info h3 { color: #569D03 !important; }
        .main-content-wrapper { padding-top: 120px; }
        .page-title h2 { font-family: "Manrope", sans-serif; font-weight: 800; }
    </style>
</head>'
    }
}

# 2. Extract Main Header
if ($indexContent -match '(?ms)(<!-- Main Header -->.*?</header>)') {
    $headerBlock = $matches[1]
}

# 3. Extract Footer (Site Footer Two)
if ($indexContent -match '(?ms)(<!--Site Footer Two Start-->.*?<!--Site Footer Two End-->)') {
    $footerBlock = $matches[1]
}

# 4. Extract Unique Content (Page Title + Contact Section + Map)
# Assuming content starts after header and ends before footer in source
# But practically, let's select by sections.
$uniqueContent = ""

# Page Title
if ($sourceContent -match '(?ms)(<section class="page-title".*?</section>)') {
    $uniqueContent += $matches[1] + "`n"
}

# Contact One (Info & Form)
if ($sourceContent -match '(?ms)(<section class="contact-one".*?</section>)') {
    $uniqueContent += $matches[1] + "`n"
}

# Map Section
if ($sourceContent -match '(?ms)(<section class="map-one".*?</section>)') {
    $uniqueContent += $matches[1] + "`n"
}

# 5. Asset Path Correction in Unique Content
$uniqueContent = $uniqueContent -replace 'href="css/', 'href="assets/css/'
$uniqueContent = $uniqueContent -replace 'src="images/', 'src="assets/images/'
$uniqueContent = $uniqueContent -replace 'url\(images/', 'url(assets/images/'
# Fix specific paths if they were just "images/" in source but "assets/images/" in local structure
# The download script mapped them to assets/images so unique content needs to point there.

# 6. Assemble contact.html
$finalHtml = @"
<!DOCTYPE html>
<html>
$headBlock
<body>

<div class="page-wrapper">
    
    <!-- Cursor -->
	<div class="cursor"></div>
	<div class="cursor-follower"></div>
	<!-- Cursor End -->

    <!-- Preloader (Optional, skipping for speed or keeping if needed) -->
    
    $headerBlock

    <!-- Sidebar Cart Item -->
	<div class="xs-sidebar-group info-group">
		<div class="xs-overlay xs-bg-black"></div>
		<div class="xs-sidebar-widget">
			<div class="sidebar-widget-container">
				<div class="close-button">
					<span class="fa-solid fa-xmark fa-fw"></span>
				</div>
				<div class="sidebar-textwidget">
					
					<!-- Sidebar Info Content -->
					<div class="sidebar-info-contents">
						<div class="content-inner">
						
							<!-- Title Box -->
							<div class="title-box">
								<h5>Banking at <span>Your Fingertips</span></h5>
								<div class="price">$500 from free Commercial Bank</div>
							</div>
							
							<!-- Empty Cart Box -->
							<div class="empty-cart-box">
								<!-- No Product -->
								<div class="no-cart">
									<span class="icon fa-solid fa-cart-flatbed-suitcase fa-fw"></span>
									No products in cart.
								</div>
							</div>
							
							<!-- Lower Box -->
							<div class="lower-box">
								<h5>Popular <span>Suggestions</span></h5>
									
								<!-- Post Block -->
								<div class="post-block">
									<div class="inner-box">
										<div class="image">
											<img src="assets/images/resource/post-thumb-1.jpg" alt="" />
										</div>
										<h6><a href="#">Quality Standards</a></h6>
										<div class="rating">
											<span class="fa fa-star"></span>
											<span class="fa fa-star"></span>
											<span class="fa fa-star"></span>
											<span class="fa fa-star"></span>
											<span class="fa fa-star"></span>
										</div>
										<div class="price-box">$49.00</div>
										<a class="theme-btn bag-btn" href="#">add to bag</a>
									</div>
								</div>
								
								<!-- Post Block -->
								<div class="post-block">
									<div class="inner-box">
										<div class="image">
											<img src="assets/images/resource/post-thumb-2.jpg" alt="" />
										</div>
										<h6><a href="#">Organic Farming</a></h6>
										<div class="rating">
											<span class="fa fa-star"></span>
											<span class="fa fa-star"></span>
											<span class="fa fa-star"></span>
											<span class="fa fa-star"></span>
											<span class="fa fa-star"></span>
										</div>
										<div class="price-box">$59.00</div>
										<a class="theme-btn bag-btn" href="#">add to bag</a>
									</div>
								</div>
								
								<!-- Post Block -->
								<div class="post-block">
									<div class="inner-box">
										<div class="image">
											<img src="assets/images/resource/post-thumb-3.jpg" alt="" />
										</div>
										<h6><a href="#">Agriculture Products</a></h6>
										<div class="rating">
											<span class="fa fa-star"></span>
											<span class="fa fa-star"></span>
											<span class="fa fa-star"></span>
											<span class="fa fa-star"></span>
											<span class="fa fa-star"></span>
										</div>
										<div class="price-box">$69.00</div>
										<a class="theme-btn bag-btn" href="#">add to bag</a>
									</div>
								</div>
								
							</div>
							
						</div>
					</div>
					
				</div>
			</div>
		</div>
	</div>
	<!-- End Sidebar Cart Item -->

    <div class="main-content-wrapper">
        $uniqueContent
    </div>

    $footerBlock

</div>
<!-- End PageWrapper -->

<div class="progress-wrap">
	<svg class="progress-circle svg-content" width="100%" height="100%" viewBox="-1 -1 102 102">
		<path d="M50,1 a49,49 0 0,1 0,98 a49,49 0 0,1 0,-98"/>
	</svg>
</div>

<script src="assets/js/jquery.js"></script>
<script src="assets/js/popper.min.js"></script>
<script src="assets/js/bootstrap.min.js"></script>
<script src="assets/js/appear.js"></script>
<script src="assets/js/parallax.min.js"></script>
<script src="assets/js/tilt.jquery.min.js"></script>
<script src="assets/js/jquery.paroller.min.js"></script>
<script src="assets/js/wow.js"></script>
<script src="assets/js/swiper.min.js"></script>
<script src="assets/js/backtotop.js"></script>
<script src="assets/js/odometer.js"></script>
<script src="assets/js/parallax-scroll.js"></script>

<script src="assets/js/gsap.min.js"></script>
<script src="assets/js/SplitText.min.js"></script>
<script src="assets/js/ScrollTrigger.min.js"></script>
<script src="assets/js/ScrollToPlugin.min.js"></script>
<script src="assets/js/ScrollSmoother.min.js"></script>

<script src="assets/js/typeit.js"></script>
<script src="assets/js/jquery.marquee.min.js"></script>
<script src="assets/js/magnific-popup.min.js"></script>
<script src="assets/js/nav-tool.js"></script>
<script src="assets/js/jquery-ui.js"></script>
<script src="assets/js/element-in-view.js"></script>
<script src="assets/js/color-settings.js"></script>
<script src="assets/js/script.js"></script>

</body>
</html>
"@

$finalHtml | Set-Content "contact.html"
Write-Host "Successfully created contact.html"
