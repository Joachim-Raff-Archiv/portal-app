function myFilterLetter() {
    var input, filter, ul, li, a, i, txtValue;
    input = document.getElementById("myResearchInput");
    filter = input.value.toUpperCase();
    div = document.getElementById("divResults");
    tr = div.getElementsByClassName("RegisterEntry");
    td = tr.getElementsByName("td");
    for (i = 0; i < tr.length; i++) {
        a = tr[i].getElementsByTagName("td")[0];
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
   var input, filter, ul, li, a, i, txtValue;
    input = document.getElementById("myResearchInput");
    filter = input.value.toUpperCase();
    div = document.getElementById("divResults");
    tr = div.getElementsByClassName("RegisterEntry");
    td = tr.div;
    for (i = 0; i < tr.length; i++) {
        a = tr[i].getElementsByTagName("div")[0].parentNode;
        txtValue = a.textContent || a.innerText;
        if (txtValue.toUpperCase().indexOf(filter) > -1) {
            a.style.display = "";
/*            c.style.display = "";*/
        } else {
            a.style.display = "none";
/*            c.style.display = "none";*/
        }
    }
}