window.onload = function() {
    document.forms["feelingform"].onsubmit = formSubmitted;
}

function formSubmitted() {
    var feeling = document.forms["feelingform"]["feeling"].value;

    if (feeling == null || feeling == "") {
        alert("Surely you feel something!");
        return false;
    }

    return false;
}