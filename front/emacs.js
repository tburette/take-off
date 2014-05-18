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


//-----------------------------------------------------------------------------
//Code for the dynamic part of the page below


/*
 Called when there has potentially been a change in the list of buttons
*/
function buttonsMayHaveChanged(){
    if($('.buttons *').length)
	$('button[name=openRemoveButtonDialog]').removeClass('disabled');
    else
	$('button[name=openRemoveButtonDialog]').addClass('disabled');
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
	buttonsMayHaveChanged();
    }
}

function openRemoveButtonDialog(){
    removeKeyEvents();
    var buttonList = $('#removeButtonDialog div.buttonList');
    $('#removeButtonDialog .modal-body').append(buttonList);
    buttonList.append(
	$('.buttons button').map(function(){
	    var checkDiv = $('<div class="form-group">');
	    var checkLabel = $('<label>');
	    var checkbox = $('<input type="checkbox"></input>');
	    checkbox.data('divButton', $(this));
	    checkLabel.append(checkbox[0]);
	    checkLabel.append($(this).text());
	    checkDiv.append(checkLabel[0]);
	    return checkDiv[0];
	})
    );
    $('#removeButtonDialog').show();
}

function closeRemoveButtonDialog(){
    addKeyEvents();
    $('#removeButtonDialog .buttonList').empty();
    $('#removeButtonDialog').hide();
}

function removeButtons(){
    $('#removeButtonDialog .buttonList :checkbox:checked').each(function(){
	$(this).data('divButton').remove();
    });
    buttonsMayHaveChanged();
}


$(function(){
    initkey();
    setupConnection();

    //TODO refactor dialogs to automate opening/closing/... 
    //and reduce duplication
    $('button[name=openButtonDialog]').on('click', function(){
	removeKeyEvents();
	$('#newButtonDialog').show();
	$('#newButtonDialog #buttonCode').focus();
	
    });
    $('#newButtonDialogClose').on('click', function(){	
	closeAddButtonDialog();
    });
    $('button[name=buttonAdd]').on('click', function(){
	addButton();
	closeAddButtonDialog();
    });


    $('button[name=openRemoveButtonDialog]').on('click', function(){
	openRemoveButtonDialog();
    });
    $('#removeButtonDialogClose').on('click', function(){	
	closeRemoveButtonDialog();
    });
    $('#removeButtonDialog button[name=buttonRemove]').on('click', function(){
	removeButtons();
	closeRemoveButtonDialog();
    });
});
