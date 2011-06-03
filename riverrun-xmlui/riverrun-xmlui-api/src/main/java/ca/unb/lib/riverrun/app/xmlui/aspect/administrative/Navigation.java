package ca.unb.lib.riverrun.app.xmlui.aspect.administrative;

import java.io.IOException;
import java.sql.SQLException;
import java.util.Map;
import org.apache.avalon.framework.parameters.Parameters;
import org.apache.cocoon.ProcessingException;
import org.apache.cocoon.environment.SourceResolver;
import org.dspace.app.itemexport.ItemExport;
import org.dspace.app.xmlui.utils.HandleUtil;
import org.dspace.app.xmlui.utils.UIException;
import org.dspace.app.xmlui.wing.Message;
import org.dspace.app.xmlui.wing.WingException;
import org.dspace.app.xmlui.wing.element.List;
import org.dspace.app.xmlui.wing.element.Options;
import org.dspace.authorize.AuthorizeException;
import org.dspace.authorize.AuthorizeManager;
import org.dspace.content.Collection;
import org.dspace.content.Community;
import org.dspace.content.DSpaceObject;
import org.dspace.content.Item;
import org.dspace.core.Constants;
import org.xml.sax.SAXException;

/**
 * Overrides addOptions method to modify the layout of the 'Context' and
 * 'Administrative' options blocks.
 */
public class Navigation
        extends org.dspace.app.xmlui.aspect.administrative.Navigation {

    /** 
     * Language strings have private access in superclass so are redeclared here.
     */

    private static final Message T_MY_ACCOUNT = message("xmlui.EPerson.Navigation.my_account");
    private static final Message T_MY_ACCOUNT_EXPORTS = message("xmlui.administrative.Navigation.account_export");

    private static final Message T_CONTEXT_EDIT_ITEM = message("xmlui.administrative.Navigation.context_edit_item");
    private static final Message T_CONTEXT_EDIT_COLLECTION = message("xmlui.administrative.Navigation.context_edit_collection");
    private static final Message T_CONTEXT_EDIT_COMMUNITY = message("xmlui.administrative.Navigation.context_edit_community");

    private static final Message T_CONTEXT_CREATE_COLLECTION = message("xmlui.administrative.Navigation.context_create_collection");
    private static final Message T_CONTEXT_CREATE_SUBCOMMUNITY = message("xmlui.administrative.Navigation.context_create_subcommunity");
    private static final Message T_CONTEXT_CREATE_COMMUNITY = message("xmlui.administrative.Navigation.context_create_community");

    private static final Message T_CONTEXT_EXPORT_METADATA = message("xmlui.administrative.Navigation.context_export_metadata");
    private static final Message T_CONTEXT_EXPORT_ITEM = message("xmlui.administrative.Navigation.context_export_item");
    private static final Message T_CONTEXT_EXPORT_COLLECTION = message("xmlui.administrative.Navigation.context_export_collection");
    private static final Message T_CONTEXT_EXPORT_COMMUNITY = message("xmlui.administrative.Navigation.context_export_community");

    private static final Message T_CONTEXT_ITEM_MAPPER = message("xmlui.administrative.Navigation.context_item_mapper");

    private static final Message T_ADMINISTRATIVE_IMPORT_METADATA = message("xmlui.administrative.Navigation.administrative_import_metadata");
    private static final Message T_ADMINISTRATIVE_HEAD = message("xmlui.administrative.Navigation.administrative_head");
    private static final Message T_ADMINISTRATIVE_ACCESS_CONTROL = message("xmlui.administrative.Navigation.administrative_access_control");
    private static final Message T_ADMINISTRATIVE_PEOPLE = message("xmlui.administrative.Navigation.administrative_people");
    private static final Message T_ADMINISTRATIVE_GROUPS = message("xmlui.administrative.Navigation.administrative_groups");
    private static final Message T_ADMINISTRATIVE_AUTHORIZATIONS = message("xmlui.administrative.Navigation.administrative_authorizations");
    private static final Message T_ADMINISTRATIVE_REGISTRIES = message("xmlui.administrative.Navigation.administrative_registries");
    private static final Message T_ADMINISTRATIVE_METADATA = message("xmlui.administrative.Navigation.administrative_metadata");
    private static final Message T_ADMINISTRATIVE_FORMAT = message("xmlui.administrative.Navigation.administrative_format");
    private static final Message T_ADMINISTRATIVE_ITEMS = message("xmlui.administrative.Navigation.administrative_items");
    private static final Message T_ADMINISTRATIVE_WITHDRAWN = message("xmlui.administrative.Navigation.administrative_withdrawn");
    private static final Message T_ADMINISTRATIVE_CONTROL_PANEL = message("xmlui.administrative.Navigation.administrative_control_panel");

    private static final Message T_STATISTICS = message("xmlui.administrative.Navigation.statistics");

    /**
     * RiverRun-specific messages
     */
    private static final Message T_ITEM_ADMIN_HEAD = message("xmlui.RiverRunAdministrative.Navigation.item_admin_head");
    private static final Message T_COLLECTION_ADMIN_HEAD = message("xmlui.RiverRunAdministrative.Navigation.collection_admin_head");
    private static final Message T_COMMUNITY_ADMIN_HEAD = message("xmlui.RiverRunAdministrative.Navigation.community_admin_head");
    
    /**
     * Exports available for download. Not accessible in parent; redeclared.
     */
    java.util.List<String> availableExports = null;

    /**
     * Superclass setup() instantiates members with private access
     */
    @Override
    public void setup(SourceResolver resolver, Map objectModel, String src, Parameters parameters)
            throws ProcessingException, SAXException, IOException {

    	super.setup(resolver, objectModel, src, parameters);

        try {
            availableExports = ItemExport.getExportsAvailable(context.getCurrentUser());
    	}
    	catch (Exception e) {
            // nothing to do
    	}
    }

    @Override
    public void addOptions(Options options) throws SAXException, WingException,
            UIException, SQLException, IOException, AuthorizeException {

        /*
         * Create a skeleton menu structure to ensure consistent order among
         * aspects.  Some blocks may not be used.
         */

        options.addList("browse");
        List accountList = options.addList("account");
        options.addList("context");
        List adminList = options.addList("administrative");

        accountList.setHead(T_MY_ACCOUNT);

        // My Account options
        if (availableExports != null && availableExports.size() > 0) {
            accountList.addItem().addXref(contextPath + "/admin/export", T_MY_ACCOUNT_EXPORTS);
        }

        //Check if a system administrator
        boolean isSystemAdmin = AuthorizeManager.isAdmin(this.context);

        // Context Administrative options
        DSpaceObject dso = HandleUtil.obtainHandle(objectModel);

        // ITEM!
        if (dso instanceof Item) {
            Item item = (Item) dso;
            if (item.canEdit()) {
                adminList.setHead(T_ADMINISTRATIVE_HEAD);

                // Add a sublist for item admin options.
                List itemList = adminList.addList("item-context");
                itemList.setHead(T_ITEM_ADMIN_HEAD);
                itemList.addItem().addXref(contextPath + "/admin/item?itemID=" + item.getID(), T_CONTEXT_EDIT_ITEM);

                if (AuthorizeManager.isAdmin(this.context, dso)) {
                    itemList.addItem().addXref(contextPath + "/admin/export?itemID=" + item.getID(), T_CONTEXT_EXPORT_ITEM);
                    itemList.addItem().addXref(contextPath + "/csv/handle/" + dso.getHandle(), T_CONTEXT_EXPORT_METADATA);
                }
            }
        }
        // COLLECTION!
        else if (dso instanceof Collection) {
            Collection collection = (Collection) dso;

            // can they admin this collection?
            if (collection.canEditBoolean(true)) {
                adminList.setHead(T_ADMINISTRATIVE_HEAD);

                // Add a sublist for collection admin options
                List collectionList = adminList.addList("collection-context");
                collectionList.setHead(T_COLLECTION_ADMIN_HEAD);

                collectionList.addItemXref(contextPath + "/admin/collection?collectionID=" + collection.getID(), T_CONTEXT_EDIT_COLLECTION);
                collectionList.addItemXref(contextPath + "/admin/mapper?collectionID=" + collection.getID(), T_CONTEXT_ITEM_MAPPER);

                if (AuthorizeManager.isAdmin(this.context, dso)) {
                    collectionList.addItem().addXref(contextPath + "/admin/export?collectionID=" + collection.getID(), T_CONTEXT_EXPORT_COLLECTION);
                    collectionList.addItem().addXref(contextPath + "/csv/handle/" + dso.getHandle(), T_CONTEXT_EXPORT_METADATA);
                }
            }
        }
        // COMMUNITY!
        else if (dso instanceof Community) {
            Community community = (Community) dso;

            boolean canAdministerCommunity = community.canEditBoolean();
            boolean canAddtoCommunity = AuthorizeManager.authorizeActionBoolean(this.context, community, Constants.ADD);

            if (canAdministerCommunity || canAddtoCommunity) {

                // We need an admin options section for this community.
                adminList.setHead(T_ADMINISTRATIVE_HEAD);

                List communityList = adminList.addList("community-context");
                communityList.setHead(T_COMMUNITY_ADMIN_HEAD);

                if (canAdministerCommunity) {
                    communityList.addItemXref(contextPath + "/admin/community?communityID=" + community.getID(), T_CONTEXT_EDIT_COMMUNITY);

                    if (AuthorizeManager.isAdmin(this.context, dso)) {
                        communityList.addItem().addXref(contextPath + "/admin/export?communityID=" + community.getID(), T_CONTEXT_EXPORT_COMMUNITY);
                    }
                    communityList.addItem().addXref(contextPath + "/csv/handle/" + dso.getHandle(), T_CONTEXT_EXPORT_METADATA);
                }

                if (canAddtoCommunity) {
                    communityList.addItemXref(contextPath + "/admin/collection?createNew&communityID=" + community.getID(), T_CONTEXT_CREATE_COLLECTION);
                    communityList.addItemXref(contextPath + "/admin/community?createNew&communityID=" + community.getID(), T_CONTEXT_CREATE_SUBCOMMUNITY);
                }
            }
        }

        if ("community-list".equals(this.sitemapURI)) {
            // Only System administrators can create top-level communities
            if (isSystemAdmin) {
                adminList.setHead(T_ADMINISTRATIVE_HEAD);

                List communityOptions = adminList.addList("admin-community-context");
                communityOptions.setHead(T_COMMUNITY_ADMIN_HEAD);
                communityOptions.addItemXref(contextPath + "/admin/community?createNew", T_CONTEXT_CREATE_COMMUNITY);
            }
        }


        // SYSADMIN!
        if (isSystemAdmin) {
            adminList.setHead(T_ADMINISTRATIVE_HEAD);

            List epeople = adminList.addList("epeople");
            List registries = adminList.addList("registries");

            epeople.setHead(T_ADMINISTRATIVE_ACCESS_CONTROL);
            epeople.addItemXref(contextPath + "/admin/epeople", T_ADMINISTRATIVE_PEOPLE);
            epeople.addItemXref(contextPath + "/admin/groups", T_ADMINISTRATIVE_GROUPS);
            epeople.addItemXref(contextPath + "/admin/authorize", T_ADMINISTRATIVE_AUTHORIZATIONS);

            registries.setHead(T_ADMINISTRATIVE_REGISTRIES);
            registries.addItemXref(contextPath + "/admin/metadata-registry", T_ADMINISTRATIVE_METADATA);
            registries.addItemXref(contextPath + "/admin/format-registry", T_ADMINISTRATIVE_FORMAT);

            adminList.addItemXref(contextPath + "/admin/item", T_ADMINISTRATIVE_ITEMS);
            adminList.addItemXref(contextPath + "/admin/withdrawn", T_ADMINISTRATIVE_WITHDRAWN);
            adminList.addItemXref(contextPath + "/admin/panel", T_ADMINISTRATIVE_CONTROL_PANEL);
            adminList.addItemXref(contextPath + "/statistics", T_STATISTICS);
            adminList.addItemXref(contextPath + "/admin/metadataimport", T_ADMINISTRATIVE_IMPORT_METADATA);
        }
    }
}
