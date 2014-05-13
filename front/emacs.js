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

function nSpaces(n){
    //+ 1 because join inserts between
    return Array(n + 1).join(" ");
}

function encodeSpaces(string){
    return string.replace(/ /g, "&nbsp;");
}

/*
In emacs:
Frame = entire emacs window
window = a portion of the window rendering a certain buffer

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
    //each value is an array of fragments of buffers which together represent text at index i
    //fragment = {column:<column index> string:<string value>}
    this.lines = [];
    //the poin of the selected window
    //correspond to the one point visible in emacs
    this.point = null;
}

FrameRenderer.prototype.getLine = function(index){
    if(index > this.height - 1){
	var error = new RangeError(index + 
			       " is outside valid lines (min 0, max " + 
			       (this.height - 1) + ")");
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

/*
@throws RangeError no segment corresponding to x, y
@returns {object} segment including where x, y is located
*/
FrameRenderer.prototype.getFragmentAt = function(x, y){
    if(!this.lines[y])
	throw new RangeError("no line " + y);
    var result;
    if(this.lines[y].some(function(fragment){
	if(fragment.column <= x && 
	   x <= fragment.column + fragment.text.length - 1){
	    result = fragment;
	    return true;
	}
    })){
	return result;
    } else
	throw new RangeError(
	    "no fragment at column " + x + " for the line " + y);
}

/*
Add data to the segment corresponding to x, y
@param {object} data key/values to be added to the segment
@throws RangeError no segment corresponding to x, y
*/
FrameRenderer.prototype.addDataToFragment = function(x, y, data){
    $.extend(this.getFragmentAt(x, y), data);
}

FrameRenderer.prototype.processData = function(displayData){
    this.addWindows(displayData.windows);
}

FrameRenderer.prototype.addWindows = function(windows){
    windows.forEach(function(window){
	this.addWindow(window);
    }, this);
}

//TODO missing hscroll handling
FrameRenderer.prototype.addWindow = function(window){
    //split. this excludes "\\n" (backslash n typed in a buffer)
    var lines = window.text.replace(/\t/g, nSpaces(window.tabWidth)).split(/\n/g);
    var windowWidth = window.right - window.left + 1;
    //split lines too big. Emulates wrap
    //the place at which line are split can vary
    //saw case where it is width (w/ gui) anohther width -1 (terminal)
    lines = $.map(lines, function(line){//map flattens
	if(line == "") return line;
	return line.split(
	    //parenthesis to include match in results
	    RegExp("(.{" + (windowWidth - 1) + "})")
	).filter(Boolean);//remove "" from the array. "" is falsey.
    });

    //TODO make sure lines don't expand past :bottom
    //Our algorithm to handle line too long (split, horizontal scroll) might
    //not fit the one used by emacs. Make sure we don't have too many lines
    lines = lines.splice(0, window.bottom - window.top + 1)

    lines.forEach(function(line, index){
	var fragment = {column: window.left, text: line};
	if(window.point && window.point.y == index + window.top){
	    fragment.point = window.point;
	}
	this.getLine(window.top + index).push(fragment);
	//TODO ordered insertion
	this.getLine(window.top + index).sort(function(a, b){
	    return a.column - b.column
	});
    }, this);

    //TODO add in the forEach
    //! global vs local coordonates
    // if(window.point)
    // 	this.addDataToFragment(
    // 	    window.point.x,
    // 	    window.point.y,
    // 	    {point: window.point});

}

FrameRenderer.prototype.renderLine = function(line){
    var that = this;
    function reduceLine(acc, windowSegment){
	var renderedSegment = that.renderSegment(windowSegment);
	var newString = acc.rendered +
	    encodeSpaces(nSpaces((windowSegment.column - acc.charCount))) + 
	    renderedSegment;
	return {rendered:newString, charCount:acc.charCount + windowSegment.text.length};
    }
    //accumulator is the rendered string + the number of chars in the rendered string
    //must keep track of number of chars handled because
    //one char in the source may be rendered with multiple chars. e.g.: ' ' => &nbsp;
    var result = line.reduce(reduceLine, {rendered:"", charCount:0});
    return result.rendered
}

/*
 Render the segment
 @param {object} segment
 @return {string} the string representation of the segment
 */
FrameRenderer.prototype.renderSegment = function(segment){
    /*
     Point (cursor) needs a span to be visible.
     Alter string of the segment containing the point (if there is one)
     to add the span
     */
    if(!segment.point)
	return encodeSpaces(segment.text)

    var x = segment.point.x;
    //does not check x validity in the segment, must have been correctly set
    return [encodeSpaces(segment.text.slice(0, x)),
			 '<span class="cursor">' + 
			 encodeSpaces(segment.text[x]) +
			 '</span>',
			 encodeSpaces(
			     segment.text.slice(
				 x+1,
				 segment.text.length))].join('');
}

FrameRenderer.prototype.render = function(){
    var result = [];
    for(var i = 0;i < this.height;i++){
	result.push(this.renderLine(this.getLine(i)));
    }
    return result.join('<br>\n');
}

function displayScreen(displayData){
    var terminal = $('.terminal-output');
    terminal.empty();
    $('.terminal').width(Math.ceil(displayData.width * char_size().width));
    //terminal.width(Math.ceil(displayData.width * char_size().width));

    var renderer = new FrameRenderer(displayData.width, displayData.height);
    tmp = renderer;
    tmp2 = displayData;
    renderer.processData(displayData);
    terminal.append(renderer.render());
}

function serverMessage(msg){
    var displayData = JSON.parse(msg.data);
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
