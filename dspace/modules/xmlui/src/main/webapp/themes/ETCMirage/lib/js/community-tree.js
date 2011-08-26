// Initialize.
function init_tree() {

	// Does community list exist?
	if (! $('div#aspect_artifactbrowser_CommunityBrowser_div_comunity-browser > ul:first').length) {
		// If not, exit.
		return;
	}

	// Insert elements:
	// anchors as triggers to open/close sublists
	// spans as slugs for childless list items
  $('div.artifact-description').each(function(index) {
    $(this).before(function() {
      var tree_anchor = 
        $(this).next('ul').children('li').length ?
          '<a href="#" class="tree-trigger">&nbsp;</a>' :
          '<span class="tree-slug">&nbsp;</span>';
        
      return tree_anchor;
    });
  });
  

	// Expand and collapse.
	$('p.tree-controls a.expand-all, p.tree-controls a.collapse-all').click(function() {

		// Look at the class.
		if ($(this).hasClass('expand-all')) {
				$(this).parent('p').next('ul').find('a.tree-trigger').addClass('tree-trigger-expanded').end().find('ul').addClass('tree-expanded');
				return false;
		}
		else {
				$(this).parent('p').next('ul').find('a.tree-trigger').removeClass('tree-trigger-expanded').end().find('ul').removeClass('tree-expanded');
		}

		// Nofollow.
		this.blur();
		return false;
	});  
	
	// Listen for tree clicks.  Check first() -- causing problems w/ last list.
	$('div#aspect_artifactbrowser_CommunityBrowser_div_comunity-browser ul a.tree-trigger').live('click', function() {
	  
		if ($(this).siblings('ul').first().is(':hidden')) {
			$(this).addClass('tree-trigger-expanded').siblings('ul').addClass('tree-expanded');
		} 
		else {
			$(this).removeClass('tree-trigger-expanded').siblings('ul').removeClass('tree-expanded');
		}

		// Nofollow.
		this.blur();

		return false;
	});
	
	// Add class to the first child <ul> of the community / collection list, because:
	// * IE6 doesn't support CSS2 > or :first-child
	// * IE7 only provides static support for :first-child
	$('div#aspect_artifactbrowser_CommunityBrowser_div_comunity-browser > ul:first').addClass('tree');
	
	// Add class to first <li> in first level of tree
	// @fixme $('div#aspect_artifactbrowser_CommunityBrowser_div_comunity-browser > ul > li:first').addClass('first');
	
	// Add class for last <li>.
	$('div#aspect_artifactbrowser_CommunityBrowser_div_comunity-browser ul li:last-child').addClass('last');

	// Change state of trigger.
	$('ul.tree-expanded').parent('li').children('a').first().addClass('tree-trigger-expanded');

}
	
// Kick things off.
$(document).ready(function() {
	init_tree();
});