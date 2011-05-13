/*
 * Contact.java
 *
 * Version: $Revision: 3705 $
 */
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
import org.dspace.app.xmlui.wing.element.Body;
import org.dspace.app.xmlui.wing.element.Division;
import org.dspace.app.xmlui.wing.element.List;
import org.dspace.app.xmlui.wing.element.PageMeta;
import org.dspace.authorize.AuthorizeException;
import org.dspace.core.ConfigurationManager;
import org.xml.sax.SAXException;

/**
 * Creates a simple 'contact us' page.
 */
public class Contact extends AbstractDSpaceTransformer implements CacheableProcessingComponent {

    /** language strings */
    private static final Message T_TITLE =
                                 message("xmlui.RiverRunArtifactBrowser.Contact.title");

    private static final Message T_DSPACE_HOME =
                                 message("xmlui.general.dspace_home");

    private static final Message T_TRAIL =
                                 message("xmlui.RiverRunArtifactBrowser.Contact.trail");

    private static final Message T_HEAD =
                                 message("xmlui.RiverRunArtifactBrowser.Contact.head");

    private static final Message T_PARA =
                                 message("xmlui.RiverRunArtifactBrowser.Contact.para");

    private static final Message T_REPOADMIN_LABEL =
                                 message("xmlui.RiverRunArtifactBrowser.Contact.repoadmin_label");

    private static final Message T_SYSADMIN_LABEL =
                                 message("xmlui.RiverRunArtifactBrowser.Contact.sysadmin_label");

    private static final Message T_FEEDBACK_LABEL =
                                 message("xmlui.RiverRunArtifactBrowser.Contact.feedback_label");

    private static final Message T_FEEDBACK_LINK =
                                 message("xmlui.RiverRunArtifactBrowser.Contact.feedback_link");

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

        pageMeta.addMetadata("title").addContent(T_TITLE);

        pageMeta.addTrailLink(contextPath + "/", T_DSPACE_HOME);
        pageMeta.addTrail().addContent(T_TRAIL);
    }

    @Override
    public void addBody(Body body) throws SAXException, WingException,
            UIException, SQLException, IOException, AuthorizeException {
        Division contact = body.addDivision("contact", "primary");

        contact.setHead(T_HEAD);
        contact.addPara(T_PARA);

        List list = contact.addList("contact");

        // The repository manager receives general feedback
        String feedbackRecipient = ConfigurationManager.getProperty("feedback.recipient");
        list.addLabel(T_REPOADMIN_LABEL);
        list.addItem().addXref("mailto:" + feedbackRecipient, feedbackRecipient);

        // Sysadmin for technical issues
        String mailAdmin = ConfigurationManager.getProperty("mail.admin");
        list.addLabel(T_SYSADMIN_LABEL);
        list.addItem().addXref("mailto:" + mailAdmin, mailAdmin);

        // Or use the feedback form
        list.addLabel(T_FEEDBACK_LABEL);
        list.addItem().addXref(contextPath + "/feedback", T_FEEDBACK_LINK);
    }
}
