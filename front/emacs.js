function serverMessage(msg){
    var displayData = JSON.parse(msg.data);
    displayScreen(displayData);    
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
    initkey();

    connect();
});
