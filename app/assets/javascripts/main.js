$(document).on("ready page:load", function() {
    loadContentColors();
    addTabListener();
    handleNotifications();
    sweetDeleteAlert();
});

function sweetDeleteAlert() {
    //Override the default confirm dialog by rails
    $.rails.allowAction = function(link) {
            if (link.data("confirm") == undefined) {
                return true;
            }
            $.rails.showConfirmationDialog(link);
            return false;
        }
        //User click confirm button
    $.rails.confirmed = function(link) {
            link.data("confirm", null);
            link.trigger("click.rails");
        }
        //Display the confirmation dialog
    $.rails.showConfirmationDialog = function(link) {
        var message = link.data("confirm");
        
        swal({
            title: "Are you sure?",
            text: "You will not be able to recover this note!",
            type: "warning",
            showCancelButton: true,
            confirmButtonColor: "#DD6B55",
            confirmButtonText: "Yes, delete it!",
            cancelButtonText: "No, cancel it!",
            closeOnConfirm: false,
            closeOnCancel: false
        }, function(isConfirm) {
            if (isConfirm) {
                swal("Deleted!", "Your note has been deleted.", "success");
                setTimeout(function(){
                    $.rails.confirmed(link);
                },1000);
            } else {
                swal("Cancelled", "Your note is safe :)", "error");
            }
        });
    }
}

function loadContentColors(myContent) {
    console.log(myContent);
    //sets color for tags(blue) & cusers (pink)
    var content = myContent || document.getElementsByClassName('content');
    for (var i = 0; i < content.length; i++) {
        var str = content[i].innerHTML;
        // any word & digit combination sepearted by _ or - and may or mayn't be followed by word & digit.
        //ex: _xyz or -23x isn't accepted
        //insert span color tag for tags
        var regx_tag = /(#[a-zA-Z0-9]+((_|-)[a-zA-Z0-9]+)*)/g;
        var tags_inserted = str.replace(regx_tag, '<span class="content-tag">$1</span>');
        //insert span color tag for user
        var regx_user = /(@[a-z0-9]+)/g;
        var result = tags_inserted.replace(regx_user, '<span class="content-user">$1</span>');
        content[i].innerHTML = result;
    }
}


function addTabListener() {
    var tabLinks = document.getElementsByClassName('tab-links')[0];
    if (tabLinks) {
        tabLinks.addEventListener('click', handleTabs, false);
    }
}

function handleTabs(e) {
    var target = e.target;
    if (!target.classList.contains('active')) {
        // if it's not active and it's a link tab
        var allLinks = target.parentNode.children;
        //highlight the clicked tab
        for (var i = 0; i < allLinks.length; i++) {
            if (allLinks[i] === target) {
                // active it
                target.classList.add('active');
            } else if (allLinks[i].className.indexOf('active') !== -1) {
                allLinks[i].classList.remove('active');
            }

        }
        //display correct content
        console.log(target.parentNode);
        var contentsParent = document.getElementsByClassName('tab-content')[0];
        var contents = contentsParent.children;
        var href = target.href;
        var id = href.substr(href.indexOf('#') + 1);
        console.log(id);
        var contentToDisplay = document.getElementById(id);
        console.log(contentToDisplay);
        for (var i = 0; i < contents.length; i++) {
            if (contents[i] === contentToDisplay) {
                contentToDisplay.classList.add('visible');
            } else if (contents[i].className.indexOf('visible') !== -1) {
                // if found then delete it
                contents[i].classList.remove('visible');
            }
        }
    }
    e.preventDefault();
}

function handleNotifications() {
    // on bell clicking show it
    var bell = document.getElementById('bell');
    bell.onclick = function() {
        var notify_box = document.getElementById('notify-panel');
        if (this.classList.contains('clicked')) {
            this.classList.remove('clicked');
            notify_box.classList.remove('smoothUp');
        } else {
            this.classList.add('clicked');
            notify_box.classList.add('smoothUp');
        }
        // in jquery return false do 2 things.. e.preventDefaut & e.stopPropagation (i.e bubbling)
        return false;
    };
    //notification accordion
    var notifications = document.getElementsByClassName('each-request');
    for (var i = 0; i < notifications.length; i++) {
        notifications[i].onclick = function(e) {
            var target;
            //target is the container
            if (e.target.classList.contains('each-request')) {
                target = e.target;
            } else if (e.target.classList.contains('request-from') || e.target.classList.contains('request-note')) {
                target = e.target.parentNode;
            } else {
                target = e.target.parentNode.parentNode;
            }


            if (target.classList.contains('expandable')) {
                var viewNote = target.getElementsByClassName('request-note')[0];
                var closed = !(viewNote.classList.contains('visible'));
            }
            //close all excpet opened one
            for (var i = 0; i < notifications.length; i++) {
                if (notifications[i].classList.contains('expandable')) {
                    var hiddenNote = notifications[i].getElementsByClassName('request-note')[0];
                    if (hiddenNote.classList.contains('visible')) {
                        //if visible close it
                        hiddenNote.classList.remove('visible');
                        $(hiddenNote).slideUp(200);
                        var arrow = notifications[i].getElementsByTagName('i')[0];
                        arrow.classList.remove('active');
                    }
                }

            }

            if (closed) {
                //if opened then it has already been closed by above loop
                // so if closed open it
                viewNote.classList.add('visible');
                $(viewNote).slideDown(200);
                var arrow = target.getElementsByTagName('i')[0];
                arrow.classList.add('active');
            }

        }; //end onclick
    }
}
