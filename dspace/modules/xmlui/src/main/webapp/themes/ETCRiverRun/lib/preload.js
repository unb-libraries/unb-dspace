$(document).ready(function(){

// Are we on the community-list page?
if (location.href.toLowerCase().indexOf( ('community-list').toLowerCase() ) > 0) {
  $('.ds-artifact-item').css('list-style-type','none');
}

// Collapse the list: hide any lists that follow a community heading
$('span.community-summary-list ~ ul').hide();

/*
	// Expansion
	$("p.list-plus").click(function() {
		$(this).hide();
		$(this).next("p.list-minus").show();
	
		// slideDown animation doesn't work in IE6:
		if (navigator.userAgent.match("MSIE 6")) {
		    $(this).parent().find("p.list-plus").hide();
		    $(this).parent().find("p.list-minus").show();
		    $(this).parent().find("p.list-minus + span.bold ~ ul").show();
		} else {
		    $(this).parent().children("ul").slideDown("fast");
		}
  });

	// Contraction
	$("p.list-minus").click(function(){
		$(this).hide();
		$(this).prev("p.list-plus").show();
		
		//slideUp animation doesn't work in IE6:
		if (navigator.userAgent.match("MSIE 6")) {
		    $(this).parent().find("p.list-plus").show();
		    $(this).parent().find("p.list-minus").hide();
		    $(this).parent().find("p.list-minus + span.bold ~ ul").hide();
		} else {
		    $(this).parent().children("ul").slideUp("fast");
		}
	});
*/
});



