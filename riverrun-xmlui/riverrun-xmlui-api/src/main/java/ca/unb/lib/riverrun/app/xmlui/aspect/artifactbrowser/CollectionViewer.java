/*
 * CollectionViewer.java
 */
package ca.unb.lib.riverrun.app.xmlui.aspect.artifactbrowser;

import java.io.IOException;
import java.sql.SQLException;

import org.apache.log4j.Logger;
import org.dspace.app.xmlui.utils.HandleUtil;
import org.dspace.app.xmlui.utils.UIException;
import org.dspace.app.xmlui.wing.Message;
import org.dspace.app.xmlui.wing.WingException;
import org.dspace.app.xmlui.wing.element.Body;
import org.dspace.app.xmlui.wing.element.Division;
import org.dspace.app.xmlui.wing.element.ReferenceSet;
import org.dspace.app.xmlui.wing.element.Para;
import org.dspace.authorize.AuthorizeException;
import org.dspace.browse.BrowseEngine;
import org.dspace.browse.BrowseException;
import org.dspace.browse.BrowseIndex;
import org.dspace.browse.BrowseItem;
import org.dspace.browse.BrowserScope;
import org.dspace.content.Collection;
import org.dspace.content.DSpaceObject;
import org.dspace.core.ConfigurationManager;
import org.dspace.sort.SortException;
import org.dspace.sort.SortOption;
import org.xml.sax.SAXException;

/**
 * Display a single collection. The default DSpace version includes a full text
 * search and list of recent submissions.
 *
 * This overrides the addBody() method to include a link to browse all
 * collection titles, following the list of 'Recent Submissions.'
 *
 * If there are no recent submissions, a message is provided to that effect,
 * before the browse-all link.
 *
 * The addBody() method in the parent class generates a list of browse options
 * that is not styled by any of the default XMLUI themes, nor by our custom
 * theme, so the list has been removed here.
 */
public class CollectionViewer extends org.dspace.app.xmlui.aspect.artifactbrowser.CollectionViewer {

    private static final Logger log = Logger.getLogger(CollectionViewer.class);

    /** Redeclare language strings given private access in parent. */
    private static final Message T_FULL_TEXT_SEARCH =
                                 message("xmlui.ArtifactBrowser.CollectionViewer.full_text_search");

    private static final Message T_GO =
                                 message("xmlui.general.go");

    private static final Message T_ADVANCED_SEARCH_LINK =
                                 message("xmlui.ArtifactBrowser.CollectionViewer.advanced_search_link");

    private static final Message T_HEAD_RECENT_SUBMISSIONS =
                                 message("xmlui.ArtifactBrowser.CollectionViewer.head_recent_submissions");

    /**
     * Messages we've added to customize the collection view
     */
    private static final Message T_NO_RECENT_SUBMISSIONS =
                                 message("xmlui.RiverRunArtifactBrowser.CollectionViewer.no_recent_submissions");

    private static final Message T_BROWSE_ALL_ITEMS =
                                 message("xmlui.RiverRunArtifactBrowser.CollectionViewer.browse_all_items");

    /**
     * Redeclared: default number of recent submissions to display,
     * if not otherwise stated in dspace.cfg
     */
    private static final int RECENT_SUBMISSIONS = 5;

    /**
     * Display a single collection
     */
    @Override
    public void addBody(Body body) throws SAXException, WingException,
            UIException, SQLException, IOException, AuthorizeException {

        DSpaceObject dso = HandleUtil.obtainHandle(objectModel);
        if (!(dso instanceof Collection)) {
            return;
        }

        // Set up the major variables
        Collection collection = (Collection) dso;

        // Build the collection viewer division.
        Division home = body.addDivision("collection-home", "primary repository collection");
        String name = collection.getMetadata("name");

        if (name == null || name.length() == 0) {
            /* Unlike other Message objects, T_untitled declared public in parent */
            home.setHead(T_untitled);
        }
        else {
            home.setHead(name);
        }

        // Advanced search box. Parent also generates a list of browse options
        // that is not styled by any of the default XMLUI themes, nor by our
        // custom theme, so the list has been removed here.
        {
            Division search = 
                    home.addDivision("collection-search-browse", "secondary search-browse");

            // Search query
            Division query = 
                    search.addInteractiveDivision("collection-search",
                                                   contextPath + "/handle/" + collection.getHandle() + "/search",
                                                   Division.METHOD_POST, "secondary search");

            Para para = query.addPara("search-query", null);
            para.addContent(T_FULL_TEXT_SEARCH);
            para.addContent(" ");
            para.addText("query");
            para.addContent(" ");
            para.addButton("submit").setValue(T_GO);

            query.addPara().addXref(contextPath + "/handle/" + collection.getHandle() + "/advanced-search", T_ADVANCED_SEARCH_LINK);
        }

        // Add the reference
        {
            Division viewer = home.addDivision("collection-view", "secondary");
            ReferenceSet mainInclude = viewer.addReferenceSet("collection-view",
                                                              ReferenceSet.TYPE_DETAIL_VIEW);
            mainInclude.addReference(collection);
        }

        // Recently submitted items
        {
            java.util.List<BrowseItem> items = getRecentlySubmittedItems(collection);

            // Follow the list of recent submissions with the option to browse collection titles, 
            String browseURL =  contextPath + "/handle/" + collection.getHandle() + "/browse?type=title";

            // 'Browse all' link placed here so it can be right-floated to appear
            // next to the 'Recent Submissions' heading
            home.addPara("collection-view-browse-all-items", "collection-view-browse-all-items").addXref(browseURL, T_BROWSE_ALL_ITEMS);

            Division lastSubmittedDiv = home.addDivision("collection-recent-submission", "secondary recent-submission");
            lastSubmittedDiv.setHead(T_HEAD_RECENT_SUBMISSIONS);

            // List of recent submissions may be null
            if (items == null || items.isEmpty()) {
                lastSubmittedDiv.addPara().addContent(T_NO_RECENT_SUBMISSIONS);
            }
            else {
                ReferenceSet lastSubmitted =
                             lastSubmittedDiv.addReferenceSet("collection-last-submitted",
                                                              ReferenceSet.TYPE_SUMMARY_LIST, null, "recent-submissions");

                for (BrowseItem item : items) {
                    lastSubmitted.addReference(item);
                }
            }
        }
    }

    /**
     * Get the recently submitted items for the given collection.
     * 
     * @param collection The collection.
     */
    private java.util.List<BrowseItem> getRecentlySubmittedItems(Collection collection) throws SQLException {

        java.util.List<BrowseItem> recentSubmissions = null;

        String source = ConfigurationManager.getProperty("recent.submissions.sort-option");
        int numRecentSubmissions = ConfigurationManager.getIntProperty("recent.submissions.count", RECENT_SUBMISSIONS);

        BrowserScope scope = new BrowserScope(context);
        scope.setCollection(collection);
        scope.setResultsPerPage(numRecentSubmissions);

        try {
            scope.setBrowseIndex(BrowseIndex.getItemBrowseIndex());
            for (SortOption so : SortOption.getSortOptions()) {
                if (so.getName().equals(source)) {
                    scope.setSortBy(so.getNumber());
                    scope.setOrder(SortOption.DESCENDING);
                }
            }

            BrowseEngine be = new BrowseEngine(context);
            recentSubmissions = be.browseMini(scope).getResults();
        }
        catch (SortException se) {
            log.error("Caught SortException", se);
        }
        catch (BrowseException bex) {
            log.error("Caught BrowseException", bex);
        }

        return recentSubmissions;
    }

}
