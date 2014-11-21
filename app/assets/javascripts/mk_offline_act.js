(function(){
	var username = document.getElementById('username')  ,
		phone = document.getElementById('phone') ,
		city = document.getElementById('city') ,
		will = document.getElementById('will')  ,
		$submitButton = $('#submit') ,
		$expendBtn = $('#expendBtn') ,
		$listItem = $('.w-ul ul > li') ,
		uv, pv, cv ; // username . phone, city value  ;

	// Handler username field event 
	addEventHandle(username, 'focus', hideError );

	addEventHandle(username, 'change', function( event ){
		uv = this.value.trim() ;
		if( !uv ){
			var error = document.getElementById('uerror') ;
			error.innerHTML =  '必填' ;
			error.style.display = 'inline' ;
		}
	}) ;

	// Handle telephone field event 
	addEventHandle(phone, 'focus', hideError) ;

	addEventHandle(phone, 'change', function( event ){
		pv = this.value.trim() ;
		var	error = document.getElementById('perror') ;
		if( pv ){
			if(!/^[0-9]{11}$/.test( pv )){
				error.innerHTML = '应为11位有效数字' ;
			}
		} else {
			error.innerHTML = '必填' ;
		}

		if( error.innerHTML ){
			error.style.display = 'inline' ;
		}
	});

	// Handle city field event 
	addEventHandle(city, 'focus', hideError)  ;

	addEventHandle(city, 'change', function() {
		cv = this.value.trim() ;
		var error = document.getElementById('cerror') ;
		if( !cv ){
			error.innerHTML = '必填' ;
			error.style.display = 'inline'  ;
		}
	}); 

	// Handle submit field event  
	$submitButton.click( function( event ){
//		event.preventDefault() ;
		var ipv = pv || /^[0-9]{11}$/.test(pv)  ,
			info = {} ;
		console.log(uv +','+ cv +','+ ipv)
        var flag = false
		if( !uv || !cv || !ipv){
			$('#allValid')[0].innerHTML = '您需要填写相关信息'; 
			$('#allValid').parent().toggleClass('hide') ;
		}else {
            console.log('come')
			info.username = uv  ; 
			info.phone = pv ; 
			info.city = cv   ; 
			$("#inquiry_will").val($('.w-ul li.active').text()) ;
            flag = true;
        }
        return flag;
	});

	// Hide error message 
	function hideError(){
        $(this).next().val('');
//		this.nextSibling.innerHTML = '' ; // set error as empty string
//		this.nextSibling.style.display = 'none' ; // hide the error message
        $(this).next().hide();
		$('#allValid').parent().addClass('hide') ;
	}

	// Add event listener 
	function addEventHandle( obj, event, func){
		if( window.addEventListener ){
			obj.addEventListener(event, func, false) ;
		} else {
			obj.attachEvent('on'+ event, func, false) ;
		}
	}

	// Handle expend button click action 
	$expendBtn.click(function(event){
		var $this = $(this) , 
			$parent = $this.parents('.w-ul') ; 

		event.preventDefault() ;

		$this.parent().siblings().css('transform', 'translate3d(0, 0, 0)') ;

		if( $this.hasClass('in')){
			$parent.animate({
				height:65 
			}, 200) ;
		} else {
			$parent.animate({
				height:35
			}, 200);
		}

		$this.toggleClass('in') ;
	}) ;

	// Handle each list item event 
	$listItem.on('click', function(){
		var $this = $(this)  ;
		if($expendBtn.hasClass('in')) 
			return  ;

		$this.parents('.w-ul').animate({
			height:35
		}, 200) ;

		$expendBtn.toggleClass('in') ;
		$listItem.removeClass('active') ;

		if($this.attr('data-index') === '0') {
			$this.parent().css('transform', 'translate3d(0, 0, 0)') ;
		} else {
			$this.parent().css('transform', 'translate3d(0, -35px, 0)') ;
		} 
		$this.addClass('active') ;
	}) ;
})() ;