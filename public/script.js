$(document).ready(function(){
        
        /* ************************************************************* INIT */
        var room;
        var username;

        var my_messages = []; // A log of all of the messages that I sent.
        var current_message_index; // Keeps track of where we are in my_messages.

        initField("#room_selection", "Room");
        initField("#username", "Username");
        
        $(".error").hide();

        // Subscribe to a Juggernaut channel
        var jug = new Juggernaut;

        /* *********************************************************** EVENTS */
        $("#join").click( joinRoom );
        $("#send").click( sendMessage );

        $("#input").keydown(function(e) {
                if ( e.keyCode == 13 && !e.shiftKey ) { // enter
                    sendMessage();
                } else {
                    resizeInput( $(this), false );
                }
            });
        $("#input").keyup(function(e) {
                resizeInput( $(this), false );
                
                rotateThroughSentMessages(e);
            });
        
        /* ******************************************************** Functions */

        // 38 = up
        // 40 = down
        function rotateThroughSentMessages(e) {
            // Filter out keys.
            if ( !e.ctrlKey ) { return; }
            if ( e.keyCode != 38 && e.keyCode != 40) { return; }

            // Set the index to be one higher than the last message so we can adjust correctly in the up condition
            if ( current_message_index == undefined ) {
                current_message_index = my_messages.length;
            }

            // Rotate through the messages
            if ( e.keyCode == 38 ) { current_message_index -= 1; } // up
            if ( e.keyCode == 40 ) { current_message_index += 1; } // down

            // Continue looping through when out of range.
            if ( current_message_index > my_messages.length-1 ) {
                current_message_index = 0;
            } else if ( current_message_index < 0 ) {
                current_message_index = my_messages.length-1;
            }

            $("#input").val( my_messages[current_message_index] );
        }

        // @input = jquery object representing the input
        function resizeInput( input, clear ) {
            var lines = input.val().split("\n");

            // When enter is hit and the message is not sent, reset back to a one line field.
            if ( clear == true ) {
                input.val("");
                lines = [""];
            }

            var line_count = lines.length;

            for (var i in lines) {
                // 105 is the number of characters that I found fits in the textarea
                line_count += parseInt( lines[i].length / 105 );
            }

            line_count -= 1; // Compensate for the first line (27)
            if (line_count == 0) line_count = 1;
            var height = 27 + ((line_count)*15); // 15 is the height of an additional line.
                
            input.css("height", height);
        }
        
        function sendMessage() {
            var message = $("#input").val();
            if ( message.trim().length > 0 ) {
                ajax( "/send", { room: room, username: username, message: message }, function() {
                        my_messages.push( message );
                        current_message_index = undefined; // Reset so rotateThroughSentMessages works
                        resizeInput( $("#input"), true);
                    });
            } else {
                resizeInput( $("#input"), true);
            }

            $("#input").focus();
        }

        function joinRoom() {
            if (room == $("#room_selection").val() && username == $("#username").val() ) {
                return; // Cancel if trying to join the same room.
            }

            if (jug && room) {
                jug.unsubscribe(room);
            }
            
            room = $("#room_selection").val();
            username = $("#username").val();
            
            $("#room").html("");

            ajax( "/join", { room: room, username: username }, function(data) {
                    if (data.success == true) {
                        $(".error").hide();
                        $("#room").html("<div class='join'><p><i>You have joined <b>"+room+"</b>.</i></p></div><div class='clear'></div>");
                        $("#roomname").html(room);
                        subscribe( room, username );
                        showUserList( data.online_users, username );
                        $("#input").focus();
                    } else {
                        $(".error").html( data.message ).show();
                        $("#list").html("");
                    }
                } );
        }


        function showUserList( online_users, current_username ) {
            $("#list").html("");
            for (var i in online_users) {
                if (online_users[i] == current_username) {
                    $("#list").append("<li><b>"+online_users[i]+"</b></li>");
                } else {
                    $("#list").append("<li>"+online_users[i]+"</li>");
                }
            }
        }

        function ajax(path, data, callback) {
            $.ajax({
                    url: path,
                        dataType: "json",
                        data: data,
                        type: "POST",
                        success: callback,
                        error: displayErrorMessage
                        });
        }

        function getFormattedLocalTime() {
            var now = new Date();
            var hour = now.getHours(),
                minute = now.getMinutes(),
                second = now.getSeconds(),
                am_pm = "AM";

            if( hour > 11 ) am_pm = "PM"; // defaults to am.
            if ( hour < 10 ) hour = "0"+hour;
            if ( minute < 10 ) minute = "0"+minute;
            if ( second < 10 ) second = "0"+second;

            return hour+":"+minute+":"+second+" "+am_pm;
        }

        function subscribe(room, username) {
            jug = new Juggernaut;
            jug.meta = { username: username };
            jug.subscribe( room, function(data){
                    var local_time = getFormattedLocalTime();

                    if ( data.action == "join" ) {
                        $("#room").append("<div class='join'><p><i><b>"+data.username+"</b> joined the room.</p></div><div class='clear'></div>");

                        if ( data.online_users ) {
                            showUserList( data.online_users, username );
                        }

                    } else if ( data.action == "part" ) {
                        $("#room").append("<div class='part'><p><i><b>"+data.username+"</b> quit the room.</p></div><div class='clear'></div>");
                        showUserList( data.online_users, username );

                    } else { // message
                        $("#room").append("<div class='message'><b>("+local_time+") "+data.username+":&nbsp;</b>"+data.message+"</div><div class='clear'></div>");
                        $("#room div.message:last p:last").css("margin-bottom", "0px");

                    }
                    
                    // Scrolldown the window after appending a message.
                    var room_object = $("#room");
                    room_object.attr( "scrollTop", room_object.attr("scrollHeight") );

                });
        }

        function displayErrorMessage() {
            $(".error").html("Something wrong happened. Please try again.").show();
            $("#room").html("Waiting for you to join a room...");
            $("#input").val("");
        }

        /* Make a field change to default text when empty and to empty when clicked */
        function initField(field_selector, value) {
            $(field_selector).val(value).attr("title", value);
            $(field_selector).focus(function() {
                    if ( $(this).val() == value ) {
                        $(this).val("");
                    }
                });

            $(field_selector).blur(function() {
                    if ( $(this).val() == "" ) {
                        $(this).val(value);
                    }
                });
        
            $(field_selector).keyup(function(e) {
                    if ( e.keyCode == 13 ) { // enter
                        joinRoom();
                    }
                });
        }
  
  
});
