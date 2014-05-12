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


function FrameRenderer(width, height){
    this.width = width;
    this.height = height;
    //index i = line i of frame
    //content at index i = pieces of string at line i
    this.lines = [];
}
FrameRenderer.prototype.getLine = function(index){
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
	    RegExp("(.{" + (windowWidth - 1) + "})")
	).filter(Boolean);//remove "" from the array. "" is falsey.
    });

    lines.forEach(function(line, index){
	this.getLine(window.top + index).push({column: window.left, text: line});
    }, this);
}
FrameRenderer.prototype.renderString = function(){
    for(var i = 0;i < this.height;i++){
	
    }
}

var tmp;
function displayScreen(displayData){
    terminal = $('.terminal-output');
    terminal.empty();
    terminal.width(Math.ceil(displayData.width * char_size().width));

    renderer = new FrameRenderer(displayData.width, displayData.height);
    renderer.addWindows(displayData.windows);
    tmp = renderer;
    //terminal.height(Math.ceil(displayData.height * char_size().heigth));
    //array one entry per line
    //put left -> str in it
    //go through array and output data
    $(displayData.windows).each(function(){
	
    });
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
	alert("connected")
	ws.send('');
    };
    ws.onmessage = serverMessage;
    ws.onclose = function(){alert("close")};
    
}

$(function(){
    connect();
});
