$(document).ready(function(){
        
        var room;
        var username;

        initField("#room_selection", "Room");
        initField("#username", "Username");
        
        $(".error").hide();

        // Subscribe to a Juggernaut channel
        var jug = new Juggernaut;

        $("#join").click(function(e) {
                if (jug && room) {
                    jug.unsubscribe(room);
                }

                room = $("#room_selection").val();
                username = $("#username").val();

                $("#room").html("");

                ajax( "/join", { room: room, username: username }, function(data) {
                        if (data.success == true) {
                            $(".error").hide();
                            $("#room").html("<p><i>You have joined <b>"+room+"</b>.</i></p>");
                            $("#roomname").html(room);
                            subscribe( room, username );
                            showUserList( data.online_users, username );
                        } else {
                            $(".error").html( data.message ).show();
                            $("#list").html("");
                        }
                    } );
            });

        $("#send").click(function(e) {
                var message = $("#input").val();
                ajax( "/send", { room: room, username: username, message: message }, function() {
                        $("#input").val("");
                    } );
            });

        function showUserList( online_users, current_username ) {
            online_users = online_users.sort();

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
        
        function subscribe(room, username) {
            jug = new Juggernaut;
            jug.meta = { username: username };
            jug.subscribe( room, function(data){

                    if ( data.action == "join" ) {
                        $("#room").append("<p><i><b>"+data.username+"</b> joined the room.</i>");

                        if ( data.online_users ) {
                            showUserList( data.online_users, username );
                        }

                    } else if ( data.action == "part" ) {
                        $("#room").append("<p><i><b>"+data.username+"</b> quit the room.</i>");
                        showUserList( data.online_users, username );

                    } else { // message
                        $("#room").append("<p><b>"+data.username+"</b>: "+data.message+"</p>");

                    }

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
                    if ( e.keyCode == 13 ) {
                        postCronLine(displayNextCrons);
                    }
                });
        }
  
  
});
