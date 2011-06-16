$(document).ready(function(){

  // Are we on the community-list page?
  if (location.href.toLowerCase().indexOf( ('community-list').toLowerCase() ) > 0) {
    
    // turn off default list styling
    $('.ds-artifact-item').css('list-style-type','none');
    
    // Collapse the list: hide any lists that follow a community heading
    $('span.community-summary-list ~ ul').hide();

    // Add anchors with classes to identify list state: expanded/collapsed, or headings w/o children
    $('span.community-summary-list').each(function(index) {
      $(this).before(function() {
        var listState = 
          ( $(this).next('ul').children('li').length > 0 ) ?
          'collapsed' :
          'no-children';
        return '<a href="#" class="' + listState + '">&nbsp;</a>';
      });
    });

    // Click to expand:
     $('.collapsed').live('click', expandList);

    // Click to collapse:
     $('.expanded').live('click', collapseList);
  }

});

function expandList(e) {
  $(this).addClass('expanded');    
  $(this).removeClass('collapsed');

  // slideDown animation doesn't work in IE6:
  if (navigator.userAgent.match('MSIE 6')) {
    $(this).parent().find('span.community-summary-list ~ ul').show();
  }
  else {
    $(this).parent().children('ul').slideDown('fast');
  }
 
  // return false to discard href attribute value
  return false;  
}

function collapseList(e) {
  $(this).addClass('collapsed');
  $(this).removeClass('expanded');    
    
  // slideDown animation doesn't work in IE6:
  if (navigator.userAgent.match('MSIE 6')) {
    $(this).parent().find('span.community-summary-list ~ ul').hide();    
  } 
  else {
    $(this).parent().children('ul').slideUp('fast');
  }
  
  // collapse any expanded children, as well
  $(this).parent().find('ul li a.expanded').click();

  return false;
}


