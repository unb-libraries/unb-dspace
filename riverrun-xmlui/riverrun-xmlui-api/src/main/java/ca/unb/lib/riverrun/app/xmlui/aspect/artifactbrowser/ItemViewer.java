package ca.unb.lib.riverrun.app.xmlui.aspect.artifactbrowser;

import java.io.IOException;
import java.sql.SQLException;
import org.dspace.app.xmlui.utils.HandleUtil;
import org.dspace.app.xmlui.utils.UIException;
import org.dspace.app.xmlui.wing.Message;
import org.dspace.app.xmlui.wing.WingException;
import org.dspace.app.xmlui.wing.element.Body;
import org.dspace.app.xmlui.wing.element.Division;
import org.dspace.app.xmlui.wing.element.Para;
import org.dspace.app.xmlui.wing.element.ReferenceSet;
import org.dspace.authorize.AuthorizeException;
import org.dspace.content.Collection;
import org.dspace.content.DSpaceObject;
import org.dspace.content.Item;
import org.xml.sax.SAXException;

/**
 * Overrides addBody method to remove 'show full item' toggle from
 * top of metadata set; moves full-item toggle at bottom of page to follow
 * metadata set.
 */
public class ItemViewer 
        extends org.dspace.app.xmlui.aspect.artifactbrowser.ItemViewer{

    /** We need to define these again; they have private access in parent */
    private static final Message T_SHOW_SIMPLE =
        message("xmlui.ArtifactBrowser.ItemViewer.show_simple");

    private static final Message T_SHOW_FULL =
        message("xmlui.ArtifactBrowser.ItemViewer.show_full");

    private static final Message T_HEAD_PARENT_COLLECTIONS =
            message("xmlui.ArtifactBrowser.ItemViewer.head_parent_collections");

    private static final Message T_PERSISTENT_IDENTIFIER =
            message("xmlui.RiverRunArtifactBrowser.ItemViewer.persistent_identifier");

    @Override
    public void addBody(Body body) throws SAXException, WingException,
            UIException, SQLException, IOException, AuthorizeException {

        DSpaceObject dso = HandleUtil.obtainHandle(objectModel);
        if (!(dso instanceof Item))
            return;
        Item item = (Item) dso;

        // Build the item viewer division.
        Division division = body.addDivision("item-view","primary");
        String title = getItemTitle(item);
        if (title != null)
            division.setHead(title);
        else
            division.setHead(item.getHandle());


        /** @fixme remove hard-coded prefix */
        Para persistentIdentifier = division.addPara(null, "item-view-persistent-identifier");
        String pidURL = "http://hdl.handle.net/" + item.getHandle();
        persistentIdentifier.addContent(T_PERSISTENT_IDENTIFIER);
        persistentIdentifier.addContent(" ");
        persistentIdentifier.addXref(pidURL, pidURL);


        ReferenceSet referenceSet;
        if (showFullItem(objectModel)) {
            referenceSet = division.addReferenceSet("collection-viewer",
                    ReferenceSet.TYPE_DETAIL_VIEW);
        }
        else {
            referenceSet = division.addReferenceSet("collection-viewer",
                    ReferenceSet.TYPE_SUMMARY_VIEW);
        }
        
        // Refrence the actual Item
        ReferenceSet appearsInclude =
                referenceSet.addReference(item).addReferenceSet(
                    ReferenceSet.TYPE_DETAIL_LIST, null, "hierarchy"
                );

        appearsInclude.setHead(T_HEAD_PARENT_COLLECTIONS);

        // Reference all collections the item appears in.
        for (Collection collection : item.getCollections()) {
            appearsInclude.addReference(collection);
        }

        // toggle to show summary / detail view
        Para showfullPara = division.addPara(null,"item-view-toggle item-view-toggle-bottom");

        if (showFullItem(objectModel)) {
            String link = contextPath + "/handle/" + item.getHandle();
            showfullPara.addXref(link).addContent(T_SHOW_SIMPLE);
        }
        else {
            String link = contextPath + "/handle/" + item.getHandle()
                    + "?show=full";
            showfullPara.addXref(link).addContent(T_SHOW_FULL);
        }

    }

}
