function myFilterLetter() {
    var input, filter, ul, li, a, i, txtValue;
    input = document.getElementById("myResearchInput");
    filter = input.value.toUpperCase();
    div = document.getElementById("divResults");
    entry = div.getElementsByClassName("RegisterEntry");
    
    for (i = 0; i < entry.length; i++) {
        a = entry[i]; /* getElementsByTagName("div") */
        b = a.parentNode;
        c = b.previousElementSibling;
        txtValue = a.textContent || a.innerText;
        if (txtValue.toUpperCase().indexOf(filter) > -1) {
            a.style.display = "";
            b.style.display = "";
            c.style.display = "";
        } else {
            a.style.display = "none";
            b.style.display = "none";
            c.style.display = "none";
        }
    }
}

function myFilter() {
    var input, filter, div, entry, a, b, c, i, txtValue;
    input = document.getElementById("myResearchInput");
    filter = input.value.toUpperCase();
    div = document.getElementById("divResults");
    entry = div.getElementsByClassName("RegisterEntry");
    
    for (i = 0; i < entry.length; i++) {
        a = entry[i]; /* getElementsByTagName("div") */
        b = a.parentNode;
        c = b.previousElementSibling;
        txtValue = a.textContent || a.innerText;
        if (txtValue.toUpperCase().indexOf(filter) > -1) {
            a.style.display = "";
            b.style.display = "";
            c.style.display = "";
        } else {
            a.style.display = "none";
/*            b.style.display = "none";*/
/*            c.style.display = "none";*/
        }
    }
}