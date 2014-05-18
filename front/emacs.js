function serverMessage(msg){
    displayData = JSON.parse(msg.data);
    displayScreen(displayData);    
 }

var ws;
function openedConnection(){
    $('.not-connected').hide();
    $('.connected').show();
    ws.send('{}');    
}
function closedConnection(){
    $('.not-connected').show();
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
    var emacsURL = '192.168.1.24:8000/socket';
    console.log("Trying to connect to " + emacsURL);
    ws = new WebSocket('ws://' + emacsURL);
    ws.onopen = openedConnection;
    ws.onmessage = serverMessage;
    ws.onclose = closedConnection;
}

function execute(code){
    JSON.stringify(ws.send(JSON.stringify({code: code})));
}

function closeAddButtonDialog(){
    addKeyEvents();
    $('#buttonCode').val('');
    $('#buttonName').val('');
    $('#newButtonDialog').hide();
}

function addButton(){
    var code = $('#buttonCode').val();
    if(code.trim()){
	var newButton = $('<button class="btn btn-primary btn-lg"></button>');
	newButton[0].code = code;
	var name = $('#buttonName').val();
	if(!name || !name.trim()){
	    var match = code.match(/^[\s()]*([^\t\r\n\f()]+)/);
	    if(match)
		name = match[1];
	    else
		name = code.replace(/[\(\)\s]+/g, '');
	}
	if(name.length > 20){
	    name = name.slice(0, 17) + '…';
	}
	newButton.text(name);
	newButton.on('click', function(){
	    execute(this.code);
	});
	$('.buttons').append(newButton);
    }

    closeAddButtonDialog();
}

function openRemoveButtonDialog(){
    removeKeyEvents();
    $('#removeButtonDialog .modal-body').append(
	$('.buttons button').map(function(){
	    var checkbox = $('<input type="checkbox"></input>');
	    checkbox.value($(this).text());
	    return checkbox[0];
	})
    );
    $('#removeButtonDialog').show();
}

function closeRemoveButtonDialog(){
    addKeyEvents();
    $('#removeButtonDialog').hide();
}


$(function(){
    initkey();
    setupConnection();

    //TODO refactor dialog to automate opening/closing/...
    $('button[name=openButtonDialog]').on('click', function(){
	removeKeyEvents();
	$('#newButtonDialog').show();
	$('#newButtonDialog #buttonCode').focus();
	
    });
    $('#newButtonDialogClose').on('click', function(){	
	closeAddButtonDialog();
    });
    $('button[name=buttonAdd]').on('click', addButton);


    $('button[name=openRemoveButtonDialog]').on('click', function(){
	openRemoveButtonDialog();
    });
    $('#removeButtonDialogClose').on('click', function(){	
	closeRemoveButtonDialog();
    });
    
});
