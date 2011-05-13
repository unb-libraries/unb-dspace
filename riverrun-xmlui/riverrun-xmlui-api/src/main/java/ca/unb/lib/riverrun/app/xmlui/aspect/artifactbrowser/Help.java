package ca.unb.lib.riverrun.app.xmlui.aspect.artifactbrowser;

import java.io.IOException;
import java.io.Serializable;
import java.sql.SQLException;
import org.apache.cocoon.caching.CacheableProcessingComponent;
import org.apache.excalibur.source.SourceValidity;
import org.apache.excalibur.source.impl.validity.NOPValidity;
import org.dspace.app.xmlui.cocoon.AbstractDSpaceTransformer;
import org.dspace.app.xmlui.utils.UIException;
import org.dspace.app.xmlui.wing.Message;
import org.dspace.app.xmlui.wing.WingException;
import org.dspace.app.xmlui.wing.element.PageMeta;
import org.dspace.authorize.AuthorizeException;
import org.xml.sax.SAXException;

public class Help extends AbstractDSpaceTransformer implements CacheableProcessingComponent {

    /** Language strings */
    private static final Message T_DSPACE_HOME = message("xmlui.general.dspace_home");
    private static final Message T_TRAIL = message("xmlui.RiverRunArtifactBrowser.HelpViewer.trail");
    private static final Message T_TITLE = message("xmlui.RiverRunArtifactBrowser.HelpViewer.title");

    /**
     * Generate the unique caching key.
     * This key must be unique inside the space of this component.
     */
    public Serializable getKey() {
        return "1";
    }

    /**
     * Generate the cache validity object.
     */
    public SourceValidity getValidity() {
        return NOPValidity.SHARED_INSTANCE;
    }

    @Override
    public void addPageMeta(PageMeta pageMeta) throws SAXException,
            WingException, UIException, SQLException, IOException,
            AuthorizeException {

        // page title
        pageMeta.addMetadata("title").addContent(T_TITLE);

        // Modify trail links
        pageMeta.addTrailLink(contextPath + "/", T_DSPACE_HOME);
        pageMeta.addTrail().addContent(T_TRAIL);
    }



}
