function serverMessage(msg){
    var displayData = JSON.parse(msg.data);
    displayScreen(displayData);    
 }


var ws;
function openedConnection(){
    $('.notconnected').hide();
    $('.connected').show();
    ws.send('');    
}
function closedConnection(){
    $('.notconnected').show();
    $('.connected').hide();
    setTimeout(connect, 3 * 1000);
}
function setupConnection(){
    connect();    
}
function connect(){
    if(ws){
	ws.onopen = null;
	ws.onclose = null;
    }
    var emacsURL = 'localhost:8000/socket';
    console.log("Trying to connect to " + emacsURL);
    ws = new WebSocket('ws://' + emacsURL);
    ws.onopen = openedConnection;
    ws.onmessage = serverMessage;
    ws.onclose = closedConnection;
}

$(function(){
    initkey();
    setupConnection();
});
