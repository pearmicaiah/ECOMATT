(function ($) {
    "use strict";

    $(window).on("load", function () {
        if ($('.hero-swiper').length) {
            // 1. Initialize Swiper
            var heroSwiper = new Swiper('.hero-swiper', {
                effect: 'creative',
                speed: 1000,
                parallax: true,
                loop: true,
                // Configure autoplay but controlled manually
                autoplay: {
                    delay: 2000, // 2s per slide (for images)
                    disableOnInteraction: false,
                },
                creativeEffect: {
                    prev: {
                        shadow: true,
                        translate: [0, 0, -400],
                        opacity: 0,
                        scale: 0.9,
                    },
                    next: {
                        translate: ['100%', 0, 0],
                        rotate: [0, 0, 10],
                        scale: 0.5,
                    },
                },
                on: {
                    init: function (swiper) {
                        swiper.autoplay.stop();
                        handleSlideLogic(swiper);
                    },
                    slideChangeTransitionStart: function (swiper) {
                        handleSlideLogic(swiper);
                    }
                }
            });

            function handleSlideLogic(swiper) {
                // 1. Pause ANY playing video in the slider (cleanup)
                $('.hero-swiper video').each(function () {
                    this.pause();
                    this.currentTime = 0;
                });

                // 2. Identify Active Slide
                var activeSlide = $(swiper.slides[swiper.activeIndex]);
                var videoElement = activeSlide.find('video').get(0);

                if (videoElement) {
                    // --- SCENARIO A: VIDEO SLIDE ---
                    swiper.autoplay.stop(); // Kill timer immediately

                    // Play Video
                    videoElement.currentTime = 0;
                    videoElement.muted = true;
                    var playPromise = videoElement.play();

                    if (playPromise !== undefined) {
                        playPromise.catch(error => {
                            console.warn("Autoplay blocked:", error);
                            // Fallback if video fails
                            swiper.slideNext();
                        });
                    }

                    // Strict Wait for 'ended'
                    $(videoElement).off('ended').on('ended', function () {
                        swiper.slideNext();
                    });

                } else {
                    // --- SCENARIO B: IMAGE SLIDE ---
                    // Resume timer for normal slides
                    swiper.autoplay.start();
                }
            }
        }
    });

})(jQuery);
