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

    // Insert elements:
    // anchors as triggers to open/close sublists
    // spans as slugs for childless list items
    $('ul#aspect_artifactbrowser_CommunityBrowser_list_comunity-browser li').each(function(index) {
        $(this).prepend(function() {
            var tree_anchor =
            $('ul.ds-simple-list li', this).length ?
            '<a href="#" class="tree-trigger">&nbsp;</a>' :
            '<span class="tree-slug">&nbsp;</span>';

            return tree_anchor;
        });
    });

    // Listen for tree clicks.  Check first() -- causing problems w/ last list.
    $('div#aspect_artifactbrowser_CommunityBrowser_div_comunity-browser ul a.tree-trigger').live('click', function() {
	  
        if ($(this).siblings('ul').first().is(':hidden')) {
            $(this).addClass('tree-trigger-expanded').siblings('ul').addClass('tree-expanded');
        }
        else {
            $(this).removeClass('tree-trigger-expanded').siblings('ul').removeClass('tree-expanded');

            // Collapse descendants, too
            $(this).siblings('ul').find('a.tree-trigger-expanded').removeClass('tree-trigger-expanded').addClass('tree-trigger');
            $(this).siblings('ul').find('ul').removeClass('tree-expanded');
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