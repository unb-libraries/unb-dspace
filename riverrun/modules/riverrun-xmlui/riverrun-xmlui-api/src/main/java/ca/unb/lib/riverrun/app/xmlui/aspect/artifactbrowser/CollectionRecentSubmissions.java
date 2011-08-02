package ca.unb.lib.riverrun.app.xmlui.aspect.artifactbrowser;

import org.apache.log4j.Logger;
import org.dspace.app.xmlui.utils.HandleUtil;
import org.dspace.app.xmlui.utils.UIException;
import org.dspace.app.xmlui.wing.Message;
import org.dspace.app.xmlui.wing.WingException;
import org.dspace.app.xmlui.wing.element.Body;
import org.dspace.app.xmlui.wing.element.Division;
import org.dspace.app.xmlui.wing.element.ReferenceSet;
import org.dspace.authorize.AuthorizeException;
import org.dspace.browse.*;
import org.dspace.content.Collection;
import org.dspace.content.DSpaceObject;
import org.dspace.core.ConfigurationManager;
import org.dspace.sort.SortException;
import org.dspace.sort.SortOption;
import org.xml.sax.SAXException;

import java.io.IOException;
import java.sql.SQLException;
import java.util.ArrayList;

/**
 * Overrides addBody() method to renders a list of recently submitted items for
 * the collection, followed by a link to view all items in the collection. *
 */
public class CollectionRecentSubmissions
        extends org.dspace.app.xmlui.aspect.artifactbrowser.CollectionRecentSubmissions {

    private static final Logger log = Logger.getLogger(CommunityRecentSubmissions.class);

    /* Redeclare messages with private access in parent */
    private static final Message T_HEAD_RECENT_SUBMISSIONS =
                                 message("xmlui.ArtifactBrowser.CollectionViewer.head_recent_submissions");
    /* RiverRun messages */

    private static final Message T_BROWSE_ALL_ITEMS =
                                 message("xmlui.RiverRunArtifactBrowser.CollectionViewer.browse_all_items");

    /** Cache of recently submitted items has private access in parent */
    private java.util.List<BrowseItem> recentlySubmittedItems;

    /** Number of recent submissions to list, if not defined in dspace.cfg  */
    private static final int RECENT_SUBMISSIONS = 5;

    @Override
    public void addBody(Body body) throws SAXException, WingException,
            UIException, SQLException, IOException, AuthorizeException {

        DSpaceObject dso = HandleUtil.obtainHandle(objectModel);
        if (!(dso instanceof Collection)) {
            return;
        }

        // Set up the major variables
        Collection collection = (Collection) dso;

        java.util.List<BrowseItem> items = getRecentlySubmittedItems(collection);
        if (items.isEmpty()) {
            return;
        }

        Division home = body.addDivision("collection-home", "primary repository collection");

        Division lastSubmittedDiv = home.addDivision("collection-recent-submission", "secondary recent-submission");
        lastSubmittedDiv.setHead(T_HEAD_RECENT_SUBMISSIONS);

        ReferenceSet lastSubmitted = lastSubmittedDiv.addReferenceSet(
                "collection-last-submitted",
                ReferenceSet.TYPE_SUMMARY_LIST,
                null,
                "recent-submissions");

        for (BrowseItem item : items) {
            lastSubmitted.addReference(item);
        }

         // Follow the list of recent submissions with the option to browse collection titles,
        Division allSubmissionsDiv = home.addDivision("collection-browse-all", "secondary browse-all");
        allSubmissionsDiv.setHead("All Submissions");

        String browseURL = contextPath + "/handle/" + collection.getHandle() + "/browse?type=title";
        allSubmissionsDiv.addPara("collection-view-browse-all-items", "collection-view-browse-all-items").addXref(browseURL, T_BROWSE_ALL_ITEMS);
    }

  /**
     * Get the recently submitted items for the given community.
     *
     * @param community The community.
     * @return List of recently submitted items
     */
    private java.util.List<BrowseItem> getRecentlySubmittedItems(Collection collection)
            throws SQLException {

        if (recentlySubmittedItems != null) {
            return recentlySubmittedItems;
        }

        String source = ConfigurationManager.getProperty("recent.submissions.sort-option");
        int numRecentSubmissions = ConfigurationManager.getIntProperty("recent.submissions.count", RECENT_SUBMISSIONS);

        if (numRecentSubmissions == 0) {
            return new ArrayList<BrowseItem>();
        }

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
            this.recentlySubmittedItems = be.browseMini(scope).getResults();
        }
        catch (SortException se) {
            log.error("Caught SortException", se);
        }
        catch (BrowseException bex) {
            log.error("Caught BrowseException", bex);
        }

        return this.recentlySubmittedItems;
    }

    /**
     * Re-cycle the re-declared cache of recently submitted items
     */
    @Override
    public void recycle() {
        this.recentlySubmittedItems = null;
        super.recycle();
    }
}
