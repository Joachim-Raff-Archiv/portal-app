/*function myFilterBasic() {
    var input, filter, div, entry, a, b, c, i, txtValue;
    input = document.getElementById("myResearchInput");
    filter = input.value.toUpperCase();
    div = document.getElementById("divResults");
    entry = div.getElementsByClassName("RegisterEntry");
    
    for (i = 0; i < entry.length; i++) {
        a = entry[i];
        b = a.parentNode;
        c = b.previousElementSibling;
        txtValue = a.textContent || a.innerText;
        if (txtValue.toUpperCase().indexOf(filter) > -1) {
            a.style.display = "";
            b.style.display = "";
            c.style.display = "";
        } else {
            a.style.display = "none";
            /\*            b.style.display = "none";*\/
            /\*            c.style.display = "none";*\/
        }
    }
}*/

function myFilter() {
    var input = document.getElementById("myResearchInput");
    var filter = input.value.toUpperCase();
    //var filter = "kab".toUpperCase();
    var div = document.getElementById("divResults");
    var entries = div.getElementsByClassName("RegisterEntry");
    
    // set all non-targets to display: none
    for (var i = 0; i < entries.length; i++) {
        var thisEntry = entries[i]
        var parentNode = thisEntry.parentNode;
        var grandParentNode = parentNode.parentNode;
        var txtValue = thisEntry.textContent || thisEntry.innerText
        
        if (txtValue.toUpperCase().indexOf(filter) > -1) {
            thisEntry.style.display = "";
            parentNode.style.display = "";
            grandParentNode.style.display = "";
        } else {
            thisEntry.style.display = "none";
        }
    }
    
    var sortBoxes = div.getElementsByClassName("RegisterSortBox")
    // if a sortBox has no visible children, then set it also to display: none
    for (var i = 0; i < sortBoxes.length; i++) {
        
        var entriesToCheck = sortBoxes[i].getElementsByClassName('RegisterEntry')
        var invisibleCount = 0;
        for (var j = 0; j < entriesToCheck.length; j++) {
            if (entriesToCheck[j].style.display == 'none')
                invisibleCount++;
        }
        if (invisibleCount == entriesToCheck.length) {
            sortBoxes[i].style.display = "none";
        }
    }
}
