/*
Nanochrome Version A

This is a pre-beta version of Nanochrome, a lightweight JavaScript syntax highlighting tool.

By Caleb Place of Gymbyl Coding
*/

var default_syntax = "lua"; // If no code type is given, default to this

/*
Syntax Definitions

I've only added Lua to this version of Nanochrome.
*/

var syntax_definitions = {
	lua: {
		keyword: /(?=\b)(and|break|do|else|elseif|end|false|for|function|if|in|local|nil|not|or|repeat|return|then|true|until|while)(?=\b)/g,
		string: /("(\\?.)*?")|('(?:\\?.)*?')|(\[(=*)\[[\s\S]*?\]\2\])/g,
		defined: /(?=\b)(getmetatable|assert|loadfile|bit32|coroutine|ipairs|_G|collectgarbage|pcall|rawlen|rawset|os|type|load|module|math|package|print|_VERSION|rawget|io|error|debug|tonumber|require|setmetatable|tostring|xpcall|string|select|self|table|unpack|rawequal|loadstring|next|pairs|dofile)(?=\b)/g,
		comment: /(--\[(=*)\[[\s\S]*?\]\2\])|(--.*?(\n|$))/g,
		number: /(?=\b)(0x[a-fA-F\d]+|\b\d+(\.\d+)?([eE]-?\d+)?|\.\d+([eE]-?\d+)?)/g,
		operator: /(\=|\=\=|\~\=|\<\=|\>\=|\*|\-|\+|\/|\#|\^|\%)/g
	}
};

/*
Miscellaneous functions.

sortSyntaxTree() - Function used to sort the syntax tree
replaceSection() - Replace a section of a string with a new one
filterSyntaxTree() - Filter the syntax tree from "overlapping" elements
*/
function sortSyntaxTree(obj1, obj2) { return obj1.index1 - obj2.index1; };
function replaceSection(str, start, end, what) { return str.substring(0, start) + what + str.substring(end); };
function filterSyntaxTree(s) { var nextOpen = 0; for (var i in s) { if (s[i].index1 >= nextOpen) { nextOpen = s[i].index2; } else if (s[i].index1 < nextOpen) { s[i].ignore = true; } } };

/*
Add Syntax Highlighting

Adds syntax highlighting to a given code HTML object.
*/
function addSyntaxHighlighting(codeText, syntaxMode) {
	var syntax = syntax_definitions[syntaxMode];

	if (!syntax) { return codeText; };

	var format = [];

	for (p in syntax) {
		while (matches = syntax[p].exec(codeText)) {
			var element = {
				index1: matches.index,
				index2: matches.index + matches[0].length,
				text: matches[0],
				type: p
			}

			format.push(element);
		}
	}

	format.sort(sortSyntaxTree);
	filterSyntaxTree(format);
	
	var offset = 0;

	for (i = 0; i < format.length; i++) {
		if (format[i].ignore) { continue; };
		var index1 = format[i].index1 + offset;
		var index2 = format[i].index2 + offset;

		var oldLength = format[i].text.length;
		var newString = "<nanochrome class=\"" + format[i].type + "\">" + format[i].text + "</nanochrome>";
		var newLength = newString.length
		
		codeText = replaceSection(codeText, index1, index2, newString);
		offset += newLength - oldLength;
	};

	codeText = "<nanochrome-block>" + codeText + "</nanochrome-block>";
	return codeText;
};

/*
Apply

Here we'll collect all elements within a <pre><code> tag and add syntax highlighting
*/
var preElements = document.getElementsByTagName("pre");

var codes = []

// Insert into codes array
for (var i = 0; i < preElements.length; i++) {
	var theseCodes = preElements[i].getElementsByTagName("code");
	for (var c = 0; c < theseCodes.length; c++) {
		codes.push(theseCodes[c]);
	};
};

// Add the syntax
for (var iter = 0; iter < codes.length; iter++) {
	var codeText = codes[iter].innerHTML;
	var syntaxMode = codes[iter].getAttribute("class") || default_syntax;

	codeText = addSyntaxHighlighting(codeText, syntaxMode);

	codes[iter].innerHTML = codeText;
};
