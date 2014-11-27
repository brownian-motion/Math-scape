/*
hide.js

Hide/show elements of a class. In this case, core stuff.
*/

var className = "core";

var elements = document.getElementsByClassName(className);
		originalDisplay = [];
		shown = true;

// Store previous display types in a table so when we show them they aren't in a different format
function prepare() {
	for (var i = 0; i < elements.length; i++) {
		originalDisplay[i] = elements[i].style.display;
	};
};

// Display elements
function show() {
	for (var i = 0; i < elements.length; i++) {
		elements[i].style.display = originalDisplay[i];
	};
};

// Hide elements
function hide() {
	for (var i = 0; i < elements.length; i++) {
		elements[i].style.display = "none";
	};
};


/*
Now we add the listener to the button
*/
var hideshow = document.getElementById("hideshow");
hideshow.style.display = "inline";

hideshow.onclick = function() {
	if (shown) {
		hide();
		shown = false;
		this.innerHTML = "Show Core";
	} else {
		show();
		shown = true;
		this.innerHTML = "Hide Core";
	}
}

// Prepare and hide initially
prepare();
hideshow.onclick();