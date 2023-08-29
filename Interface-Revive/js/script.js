$(function () {
    
    function display(bool) {
        if (bool) {
            $("#xbody").show();
            $('.container').fadeIn();
        } else {
            $("#xbody").hide();
            $('.container').fadeOut();
        }
    };
    

    window.addEventListener('message', function(event) {
        var item = event.data;
        if (item.type === "ui") {
            if (item.status == true) {
                display(true)
                $('#Playerid').html(item.id);

            } else {
                display(false)
            }
        } else if (item.type === "addclass") {
            if (item.status == true) {
                $("#ped").hide();
            } else {
                $("#ped").show();
            }
        } else if (item.type === "police") {
            if (item.status == true) {
                $("#police").hide();
            } else {
                $("#police").show();
            }
        } else if (item.type === "time") {
            $("#time").html(item.time);
        } else if (item.type === "sendsignal") {
            if (item.status == true) {
                $("#sendsignal").hide();
            } else {
                $("#sendsignal").show();
            }
        } else if (item.type === "requestTalk") {
            if (item.status == true) {
                $("#requesttalk").hide();
            } else {
                $("#requesttalk").show();
            }
        } else if (item.type === "gang") {
            if (item.status == true) {
                $("#gang").hide();
            } else {
                $("#gang").show();
            }
        } else if (item.type === "police") {
            if (item.status == true) {
                $("#police").hide();
            } else {
                $("#police").show();
            }
        }
    })
})