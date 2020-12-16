$(document).ready(function() {
              var pageItem = $(".pagination li").not(".prev,.next");
              var prev = $(".pagination li.prev");
              var next = $(".pagination li.next");
            
              pageItem.click(function() {
                pageItem.removeClass("active");
                $(this).not(".prev,.next").addClass("active");
              });
            
              next.click(function() {
                $('li.active').removeClass('active').next().addClass('active');
                $('div[id^="facsimile-"].show.active').removeClass('show').removeClass('active').next().addClass('show').addClass('active');
              });
            
              prev.click(function() {
                $('li.active').removeClass('active').prev().addClass('active');
                $('div[id^="facsimile-"].show.active').removeClass('show').removeClass('active').next().addClass('show').addClass('active');
              });
            
            
            });