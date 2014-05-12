function char_size() {
    var temp = $('<div class="terminal"><div class="cmd"><span>&nbsp;' +
                 '</span></div></div>').appendTo('body');
    var span = temp.find('span');
    var result = {
        width: span.width(),
        height: span.outerHeight()
    };
    temp.remove();
    return result;
}


/*
Naive way to render the visible parts of a buffer
Doesn't do most of the rendering done by emacs.
E.g. doesn't handle:
* invisible text
* overlay
* display table
* color

*/
function FrameRenderer(width, height){
    this.width = width;
    this.height = height;
    //index i = line i of frame
    //content at index i = fragment of buffers at line i
    //fragment = starting at column x is the string y
    this.lines = [];
}
FrameRenderer.prototype.getLine = function(index){
    if(index > this.height - 1){
	var error = new RangeError(index + 
			       " is outside valid lines (min 0, max " + 
			       this.height-1 + ")");
        error.lineRequested = index;
	throw error;
    }
    if(this.lines[index])
	return this.lines[index];
    else{
	this.lines[index] = [];
	return this.lines[index];
    } 
}
FrameRenderer.prototype.addWindows = function(windows){
    windows.forEach(function(window){
	this.addWindow(window);
    }, this);
}
//TODO missing hscroll handling
FrameRenderer.prototype.addWindow = function(window){
    //split. this excludes "\\n" (backslash n typed in a buffer)
    var lines = window.text.split(/\n/g);
    var windowWidth = window.right - window.left + 1;
    //split lines too big. Emulates wrap
    //the place at which line are split can vary
    //saw case where it is width (w/ gui) anohther width -1 (terminal)
    lines = $.map(lines, function(line){//map flattens
	return line.split(
	    //parenthesis to include match in results
	    RegExp("(.{" + (windowWidth -2) + "})")
	).filter(Boolean);//remove "" from the array. "" is falsey.
    });

    lines.forEach(function(line, index){
	this.getLine(window.top + index).push({column: window.left, text: line});
	//TODO ordered insertion
	//this.getLine(window.top + index).sort(function(a, b){a.column - b.column});
    }, this);
}
FrameRenderer.prototype.render = function(){
    function nSpaces(n){
	//+ 1 because join inserts between
	try{
	return Array(n + 1).join(" ");
	}catch(err){
	    console.log(err);
	}
    }
    var result = [];
    for(var i = 0;i < this.height;i++){
	result.push(this.getLine(i).reduce(function(stringAcc, windowSegment){
	    return stringAcc +
	        nSpaces((windowSegment.column - stringAcc.length)) + 
		windowSegment.text;
	}, "").replace(/ /g, "&nbsp;"));
    }
    return result.join('<br>\n');
}

var tmp;
function displayScreen(displayData){
    terminal = $('.terminal-output');
    terminal.empty();
    $('.terminal').width(Math.ceil(displayData.width * char_size().width));
    //terminal.width(Math.ceil(displayData.width * char_size().width));

    renderer = new FrameRenderer(displayData.width, displayData.height);
    tmp = renderer;
    renderer.addWindows(displayData.windows);
    terminal.append(renderer.render());
}

function serverMessage(msg){
    displayData = JSON.parse(msg.data);
    displayScreen(displayData);    
    //$('.terminal-output').text(msg.data);
}

var ws;
function connect(){
    ws = new WebSocket("ws://localhost:8000/socket");
    ws.onopen = function(){
	ws.send('');
    };
    ws.onmessage = serverMessage;
    ws.onclose = function(){alert("close")};
    
}

$(function(){
    connect();
});
