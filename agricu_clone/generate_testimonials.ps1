
$testimonials = @(
    @{
        role  = "Kwekwe Hotelier"
        name  = "Mr. T. Gweshe"
        title = "General Manager, Golden Mile Hotel"
        text  = "Partnering with Ecomatt Farm has transformed our kitchen operations entirely. We require a consistent, high-volume supply of poultry and pork to meet the demands of our hotel guests, and Ecomatt has never disappointed. Their broiler chickens are exceptionally sized, and the pork cuts are always fresh and professionally handled. What stands out most is their reliability; even during peak festive seasons, they deliver on time, every time. This level of consistency allows us to maintain our high culinary standards without worry."
    },
    @{
        role  = "Local School Head"
        name  = "Mrs. A. Moyo"
        title = "Headmistress, Kwekwe High School"
        text  = "The health and well-being of our students are paramount, which is why we switched to Chitsano Roller Meal for our boarding dining hall. The nutritional quality is evident, and the students genuinely enjoy the taste, which is a significant victory for us. Ecomatt Farm provides us with a fortified, wholesome product that supports the learners' daily energy needs. Their bulk delivery service is efficient, and the pricing is incredibly competitive for a school budget, making them our preferred supplier for the long term."
    },
    @{
        role  = "Horticulture Vendor"
        name  = "Mai Charamba"
        title = "Market Vendor, Mbizo Market"
        text  = "My customers at Mbizo Market are very particular about freshness, and that is why I source my tomatoes and onions exclusively from Plot 12 Sherwood. The produce from Ecomatt Farm is always firm, vibrant, and long-lasting, which means less waste for me and better value for my customers. Since I started selling their crops, my stall has become known for Quality, and my daily sales have improved significantly. It is a blessing to have such a reliable local farmer supporting small vendors like us."
    },
    @{
        role  = "Agro-Tourism Visitor"
        name  = "Sarah Jenkins"
        title = "Agricultural Student"
        text  = "Visiting Ecomatt Farm was an eye-opening experience that bridged the gap between theory and practice. The tour was meticulously organized, showcasing their integrated farming systems from the piggery units to the vast maize fields. The training session on sustainable soil management was particularly enlightening and professionally presented. It is inspiring to see a local farm implementing such advanced, eco-friendly techniques. I left with a wealth of knowledge and a renewed passion for agriculture, and I highly recommend their tours to anyone interested in farming."
    },
    @{
        role  = "Butchery Franchisee"
        name  = "Mr. C. Banda"
        title = "Owner, Meat World Kwekwe"
        text  = "In the butchery business, reputation is built on the quality of meat you sell, and Ecomatt Farm ensures my reputation stays intact. Their piggery operations are top-tier, producing pork that has the perfect meat-to-fat ratio that my customers love. The hygiene standards they maintain at the farm are reflected in the clean, premium product I receive. Knowing that the animals are raised ethically and fed well gives me confidence in what I sell, and my customers keep coming back for more."
    },
    @{
        role  = "Community Health Worker"
        name  = "Nurse R. Dube"
        title = "Community Health Advocate"
        text  = "Access to nutritious food is a major health determinant, and Ecomatt Farm is doing a wonderful job for the Kwekwe community. Their supply of chemical-free, organic vegetables provides families with safe, healthy food options that are crucial for fighting disease and maintaining good health. I often recommend their produce to patients who need to improve their diet because I trust their farming methods. It is rare to find a producer who cares as much about community health as they do about profit."
    },
    @{
        role  = "Small-Scale Farmer"
        name  = "Elder Makoni"
        title = "Smallholder Farmer"
        text  = "The Ecomatt supply store has become the backbone of my small farming project. I purchased their seedlings and cured manure last season, and the difference in my harvest was miraculous. The seedlings were robust and disease-free, establishing quickly in the field. Their manure is well-processed and rich, giving my crops the boost they needed without burning them. Their advice is also invaluable; they don't just sell to you, they want you to succeed. They are a true partner to us small farmers."
    },
    @{
        role  = "Supermarket Manager"
        name  = "Ms. L. Zhou"
        title = "Branch Manager, OK Mart"
        text  = "Stocking Ecomatt eggs has been a great business decision for our supermarket branch. The packaging is robust and attractive, standing out on the shelves, but more importantly, the product quality is consistent. We rarely experience breakage or returns due to spoilage because their shelf-life is excellent. Customers appreciate the consistent size and fresh taste of the eggs. Ecomatt's merchandising team is also very proactive, ensuring our stock levels are always maintained, which makes my job as a manager much easier."
    },
    @{
        role  = "Braai Spot Owner"
        name  = "Bigboy M."
        title = "Proprietor, The Chill Spot"
        text  = "Weekends at The Chill Spot are busy, and the braai stands never stop running. I choose Ecomatt pork and chicken because the meat quality handles the open fire perfectly—it stays juicy and flavorful. My patrons always compliment the taste, asking where I get such tender meat. Their bulk pricing allows me to keep my menu affordable while serving premium quality food. Ecomatt understands the hospitality business and helps me keep the fires burning and the customers happy every single weekend."
    },
    @{
        role  = "Vegetable Exporter"
        name  = "Mr. P. Van Der Merwe"
        title = "Export Agent"
        text  = "The export market demands perfection, and Ecomatt Farm delivers exactly that with their green beans and carrots. The aesthetic appeal, size consistency, and freedom from pests make their produce ideal for the international market. I have visited many farms, but the attention to detail at Plot 12 Sherwood is world-class. They understand the rigorous standards required for export compliance. Working with them has allowed me to open new markets, confident that the product will always meet the highest global standards."
    },
    @{
        role  = "Kwekwe Resident"
        name  = "Mrs. T. Chigumba"
        title = "Home Baker & Mom"
        text  = "As a busy mother and home baker, the farm-to-table delivery service from Ecomatt Farm is a lifesaver. Getting fresh eggs, milk, and vegetables delivered right to my doorstep saves me so much time. The convenience does not come at the cost of quality; everything arrives fresh, as if I picked it myself. The delivery team is polite and professional, always handling the goods with care. It feels good to feed my family fresh, local produce while supporting a business that truly values its customers."
    }
)

$images = @(
    "assets/images/resource/author-1.jpg",
    "assets/images/resource/author-2.jpg"
)

$output = ""
$i = 0

foreach ($t in $testimonials) {
    
    $img = $images[$i % 2]
    $i++
    
    $block = @"
				<!-- Testimonial Block $i -->
				<div class="testimonial-block_one col-lg-4 col-md-6 col-sm-12">
					<div class="testimonial-block_one-inner" style="height: 100%;">
						<div class="testimonial-block_one-icon flaticon-write"></div>
						<div class="d-flex justify-content-between align-items-center flex-wrap">
							<div class="testimonial-block_one-author">
								<img src="$img" alt="" />
							</div>
							<div class="testimonial-block_one-rating">
								<span class="fa fa-star"></span>
								<span class="fa fa-star"></span>
								<span class="fa fa-star"></span>
								<span class="fa fa-star"></span>
								<span class="fa fa-star"></span>
							</div>
						</div>
						<div class="testimonial-block_one-text">$($t.text)</div>
						<div class="testimonial-block_one-designation">
							$($t.name) <span>$($t.title)</span>
						</div>
					</div>
				</div>
"@
    $output += $block
}

$output | Out-File -FilePath "testimonials_content.html" -Encoding utf8
