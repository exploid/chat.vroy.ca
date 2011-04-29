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

                ajax( "/join", { room: room, username: username }, function() {
                        $(".error").hide();
                        $("#room").html("<p><i>You have joined <b>"+room+"</b>.</i></p>");
                        subscribe( room, username )
                    } );
            });

        $("#send").click(function(e) {
                var message = $("#input").val();
                ajax( "/send", { room: room, username: username, message: message }, function() {
                        $("#input").val("");
                    } );
            });

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
            jug.subscribe( room, function(data){

                    if ( data.action == "join" ) {
                        $("#room").append("<p><i><b>"+data.username+"</b> joined the room.</i>");

                    } else if ( data.action == "part" ) {
                        $("#room").append("<p><i><b>"+data.username+"</b> quit the room.</i>");

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
