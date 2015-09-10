(function() {

    $(document).on("ready page:load",function() {
        addTabListener();
        handleNotifications();
        // fix the button click issue
    });

    function addTabListener() {
        var tabLinks = document.getElementsByClassName('tab-links')[0];
        if(tabLinks){
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
        bell.onclick = function(){
            var notify_box = document.getElementById('notify-panel');
            if(this.classList.contains('clicked')){
                this.classList.remove('clicked');
                notify_box.classList.remove('smoothUp');
            }else{
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

})();
