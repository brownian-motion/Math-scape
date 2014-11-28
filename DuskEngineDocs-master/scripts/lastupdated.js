/*
date.js

Adds the last modified date to the document (in a nice format, too!).
*/

var suffix = ["th", "st", "nd", "rd"];

function getOrdinal(n) {
	var v = n % 100;
	return n + (suffix[(v - 20) % 10] || suffix[v] || suffix[0]);
}

var threshold = 8; // Just give the date if it was modified more than a week ago
var months = ["January", "Febuary", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December"]

var modified = new Date(document.lastModified);
var modified_day = modified.getDate();
var modified_month = modified.getMonth();
var modified_year = modified.getFullYear();

var today = new Date();
var today_day = today.getDate();
var today_month = today.getMonth();
var today_year = today.getFullYear();

var daysAgo = today_day - modified_day;
var monthsAgo = today_month - modified_month;
var yearsAgo = today_year - modified_year;

var days_string = "";
var months_string = "";
var years_string = "";

if (
	daysAgo < threshold &&
	monthsAgo == 0 &&
	yearsAgo == 0
) {
	if (daysAgo == 0) {
		days_string = "today";
	} else if (daysAgo == 1) {
		days_string = "yesterday";
	} else if (daysAgo == 2) {
		days_string = "the day before yesterday";
	} else if (daysAgo == 7) {
		days_string = "a week ago";
	} else {
		days_string = daysAgo + " days ago";
	}
} else if (daysAgo >= threshold) {
	days_string = getOrdinal(modified_day);
	months_string = months[modified_month] + " ";
}

if (yearsAgo > 0) {
	years_string = ", " + modified_year;
}

document.write("<lastmod>Last updated " + months_string + days_string + years_string + "</lastmod>");