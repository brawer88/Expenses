function enableTab(id) {
    var el = document.getElementById(id);
    el.onkeydown = function(e) {
        if (e.keyCode === 9) { // tab was pressed

            // get caret position/selection
            var val = this.value,
                start = this.selectionStart,
                end = this.selectionEnd;

            

            // set textarea value to: text before caret + tab + text after caret
            this.value = val.substring(0, start) + '    ' + val.substring(end);

            // put caret at right position again
            this.selectionStart = this.selectionEnd = start + 4;

            // prevent the focus lose
            return false;

        }
    };
}

function toggleChangeLog() {
var x = document.getElementById("changelog");
    if (x.style.display === "none") {
        x.style.display = "block";
    } else {
        x.style.display = "none";
    }
} 


