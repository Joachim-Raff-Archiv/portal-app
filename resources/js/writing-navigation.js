/**
 * writing-navigation.js
 * Handles navigation, scroll-to-top button, and smooth scrolling for writing pages
 */
(function() {
    'use strict';
    
    // Initialize navigation sticky positioning
    function initNavigation() {
        var mainNavbar = document.querySelector('.navbar.fixed-top');
        var navbarHeight = mainNavbar ? mainNavbar.offsetHeight : 60;
        
        var chapterHeader = document.getElementById('chapterNavHeader');
        var chapterContent = document.getElementById('chapterNavContent');
        var pageHeader = document.getElementById('pageNavHeader');
        var pageContent = document.getElementById('pageNavContent');
        
        if (chapterHeader && chapterContent && pageHeader && pageContent) {
            var headerOffset = navbarHeight + 10;
            var contentOffset = headerOffset + 50;
            
            chapterHeader.style.top = headerOffset + 'px';
            chapterContent.style.top = contentOffset + 'px';
            pageHeader.style.top = headerOffset + 'px';
            pageContent.style.top = contentOffset + 'px';
        }
        
        return navbarHeight + 20;
    }
    
    // Initialize scroll to top button
    function initScrollToTopButton() {
        console.log("=== Starting scroll to top button initialization ===");
        
        var scrollToTopBtn = document.getElementById("scrollToTopBtn");
        
        if (!scrollToTopBtn) {
            console.error("ERROR: Scroll to top button not found in DOM!");
            return;
        }
        
        console.log("✓ Button found:", scrollToTopBtn);
        console.log("  Initial display style:", window.getComputedStyle(scrollToTopBtn).display);
        
        // Try multiple selectors to find the scrollable content area
        var contentArea = null;
        var fulltextTab = document.getElementById('fulltext');
        
        console.log("✓ Fulltext tab found:", fulltextTab);
        
        if (fulltextTab) {
            // Method 1: Direct CSS selector
            contentArea = document.querySelector('#fulltext > .row > div.col:nth-of-type(2)');
            console.log("Method 1 (CSS selector):", contentArea);
            
            // Method 2: Fallback to querying
            if (!contentArea) {
                var rows = fulltextTab.querySelectorAll('.row');
                console.log("Found", rows.length, "rows in fulltext tab");
                
                if (rows.length > 0) {
                    var cols = rows[0].querySelectorAll('div.col');
                    console.log("Found", cols.length, "col divs in first row");
                    
                    // Log all columns to see structure
                    for (var i = 0; i < cols.length; i++) {
                        var colStyle = window.getComputedStyle(cols[i]);
                        console.log("Column", i, ":", cols[i].className, 
                                  "| scrollHeight:", cols[i].scrollHeight,
                                  "| clientHeight:", cols[i].clientHeight,
                                  "| overflow-y:", colStyle.overflowY);
                    }
                    
                    // Find the column with overflow-y: auto or scroll
                    for (var i = 0; i < cols.length; i++) {
                        var style = window.getComputedStyle(cols[i]);
                        if (style.overflowY === 'auto' || style.overflowY === 'scroll') {
                            contentArea = cols[i];
                            console.log("✓ Found scrollable content area at index", i);
                            break;
                        }
                    }
                }
            }
        }
        
        if (contentArea) {
            console.log("✓ Content area identified:", contentArea);
            console.log("  scrollHeight:", contentArea.scrollHeight,
                      "| clientHeight:", contentArea.clientHeight,
                      "| overflow-y:", window.getComputedStyle(contentArea).overflowY);
        } else {
            console.warn("WARNING: Could not find scrollable content area");
        }
        
        // Show/hide button on scroll
        function toggleButton() {
            var shouldShow = false;
            
            // Check main window scroll
            var mainScroll = window.pageYOffset || document.documentElement.scrollTop || document.body.scrollTop || 0;
            console.log("Main window scroll:", mainScroll);
            
            if (mainScroll > 300) {
                console.log("→ Main scroll > 300, showing button");
                shouldShow = true;
            }
            
            // Check content area scroll if in fulltext tab
            if (contentArea) {
                var isActive = fulltextTab.classList.contains('active') || fulltextTab.classList.contains('show');
                var contentScroll = contentArea.scrollTop;
                
                console.log("Content area scroll:", contentScroll, "| Tab active:", isActive);
                
                if (isActive && contentScroll > 200) {
                    console.log("→ Content scroll > 200 and tab active, showing button");
                    shouldShow = true;
                }
            }
            
            var newDisplay = shouldShow ? "block" : "none";
            console.log("Setting button display to:", newDisplay);
            scrollToTopBtn.style.display = newDisplay;
        }
        
        // Attach scroll event to window
        console.log("Attaching scroll listener to window");
        window.addEventListener('scroll', function() {
            console.log("Window scroll event fired");
            toggleButton();
        });
        
        // Attach scroll event to content area if it exists
        if (contentArea) {
            console.log("Attaching scroll listener to content area");
            contentArea.addEventListener('scroll', function() {
                console.log("Content area scroll event fired");
                toggleButton();
            });
        }
        
        // Attach click event
        scrollToTopBtn.addEventListener('click', function() {
            console.log("Scroll to top button clicked");
            
            // Scroll main window to top
            window.scrollTo({
                top: 0,
                behavior: 'smooth'
            });
            
            // Also scroll content area to top if in fulltext tab
            if (contentArea) {
                contentArea.scrollTo({
                    top: 0,
                    behavior: 'smooth'
                });
            }
        });
        
        // Initial check
        console.log("Running initial toggle check");
        toggleButton();
        
        // Re-check when tabs change
        document.querySelectorAll('a[data-toggle="tab"]').forEach(function(tab) {
            tab.addEventListener('shown.bs.tab', function(e) {
                console.log("Tab changed to:", e.target);
                toggleButton();
            });
        });
        
        console.log("=== Scroll to top button initialization complete ===");
    }
    
    // Initialize smooth scrolling for anchor links
    function initSmoothScrolling(offset) {
        document.querySelectorAll('a[href^="#"]').forEach(function(anchor) {
            anchor.addEventListener('click', function (e) {
                var href = this.getAttribute('href');
                if (href !== '#' && href.length > 1) {
                    e.preventDefault();
                    var target = document.querySelector(href);
                    if (target) {
                        var targetPosition = target.getBoundingClientRect().top + window.pageYOffset - offset;
                        window.scrollTo({
                            top: targetPosition,
                            behavior: 'smooth'
                        });
                    }
                }
            });
        });
    }
    
    // Initialize cross-tab navigation (e.g., links in metadata tab pointing to fulltext tab)
    function initCrossTabNavigation(offset) {
        // Find all links in the metadata tab
        var metadataTab = document.getElementById('metadata');
        if (!metadataTab) return;
        
        var links = metadataTab.querySelectorAll('a[href^="#"]');
        
        links.forEach(function(link) {
            link.addEventListener('click', function(e) {
                var href = this.getAttribute('href');
                if (href === '#' || href.length <= 1) return;
                
                e.preventDefault();
                
                // Check if target exists in fulltext tab
                var fulltextTab = document.getElementById('fulltext');
                if (!fulltextTab) return;
                
                var target = fulltextTab.querySelector(href);
                
                if (target) {
                    // Target is in fulltext tab - switch to it first
                    var fulltextTabLink = document.querySelector('a[href="#fulltext"][data-toggle="tab"]');
                    
                    if (fulltextTabLink) {
                        // Activate fulltext tab
                        $(fulltextTabLink).tab('show');
                        
                        // Wait for tab transition to complete, then scroll to target
                        setTimeout(function() {
                            // Try multiple selectors to find the scrollable content area
                            var contentArea = fulltextTab.querySelector('.col:nth-of-type(2)') 
                                || fulltextTab.querySelector('.writingText')
                                || fulltextTab.querySelector('[style*="overflow"]')
                                || fulltextTab;
                            
                            console.log('Scrolling to target:', href);
                            console.log('Content area:', contentArea);
                            console.log('Target element:', target);
                            
                            // Get the target's position relative to the content area
                            var targetRect = target.getBoundingClientRect();
                            var contentRect = contentArea.getBoundingClientRect();
                            
                            // Calculate scroll position
                            var scrollPosition = targetRect.top - contentRect.top + contentArea.scrollTop - offset;
                            
                            console.log('Scroll position:', scrollPosition);
                            
                            // Scroll to the target
                            contentArea.scrollTo({
                                top: scrollPosition,
                                behavior: 'smooth'
                            });
                            
                            // Also scroll the window if needed
                            window.scrollTo({
                                top: target.offsetTop - offset,
                                behavior: 'smooth'
                            });
                        }, 350); // Wait for Bootstrap tab transition (default is 300ms)
                    }
                } else {
                    // Target might be in current tab, use default behavior
                    var localTarget = document.querySelector(href);
                    if (localTarget) {
                        var targetPosition = localTarget.getBoundingClientRect().top + window.pageYOffset - offset;
                        window.scrollTo({
                            top: targetPosition,
                            behavior: 'smooth'
                        });
                    }
                }
            });
        });
    }
    
    // Initialize everything when DOM is ready
    function init() {
        var offset = initNavigation();
        initSmoothScrolling(offset);
        initCrossTabNavigation(offset);
        initScrollToTopButton();
    }
    
    if (document.readyState === 'loading') {
        document.addEventListener('DOMContentLoaded', init);
    } else {
        init();
    }
})();
