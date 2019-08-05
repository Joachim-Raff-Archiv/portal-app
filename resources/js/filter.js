function myFilterLetter() {
    var input, filter, ul, li, a, i, txtValue;
    input = document.getElementById("myResearchInput");
    filter = input.value.toUpperCase();
    div = document.getElementById("divResults");
/*    p = div.getElementsByTagName("p");*/
/*    ul = p.getElementsByTagName("ul");*/
    li = div.getElementsByTagName("li");
    for (i = 0; i < li.length; i++) {
        a = li[i]; /*a = li[i].getElementsByTagName("a")[0];*/
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

function myFilterPerson() {
    var input, filter, li, a,  i, txtValue;
    input = document.getElementById("myResearchInput");
    filter = input.value.toUpperCase();
    div = document.getElementById("divResults");
/*    div = locNode.getElementsByTagName("div");*/
/*    ul = locNode.getElementsByTagName("ul");*/
    li = div.getElementsByTagName("li");
    for (i = 0; i < li.length; i++) {
        a = li[i]; /*a = li[i].getElementsByTagName("a")[0]; */
        b = a.parentNode;
/*        c = b.previousElementSibling;*/
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