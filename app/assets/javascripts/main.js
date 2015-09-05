(function(){
	var tag
	window.onload = function(){
		addTabListener();
	};
	function addTabListener(){
		var tabLinks = document.getElementsByClassName('tab-links')[0];
		tabLinks.addEventListener('click',handleTabs,false);
	}

	function handleTabs(e){
		var target = e.target;
		if(target.tagName == "A" && !target.classList.contains('active')){
			// if it's not active and it's a link tab
			var allLinks = target.parentNode.children;
			//highlight the clicked tab
			for(var i=0;i<allLinks.length;i++){
				if(allLinks[i]===target){
					// active it
					target.classList.add('active');
				}else if(allLinks[i].className.indexOf('active')!==-1){
					allLinks[i].classList.remove('active');
				}

			}
			//display correct content
			console.log(target.parentNode);
			var contentsParent = document.getElementsByClassName('tab-content')[0];
			var contents = contentsParent.children;
			var href = target.href;
			var id = href.substr(href.indexOf('#')+1); 
			console.log(id);
			var contentToDisplay = document.getElementById(id);
			console.log(contentToDisplay);
			for(var i=0;i<contents.length;i++){
				if(contents[i]===contentToDisplay){
					contentToDisplay.classList.add('visible');
				}else if(contents[i].className.indexOf('visible')!==-1){
					// if found then delete it
					contents[i].classList.remove('visible');
				}
			}
		}
	}
})();

