package ca.unb.lib.riverrun.app.xmlui.aspect.sherparomeo;

import ca.unb.lib.riverrun.app.xmlui.aspect.sherparomeo.jaxb.Condition;
import ca.unb.lib.riverrun.app.xmlui.aspect.sherparomeo.jaxb.Copyrightlink;
import ca.unb.lib.riverrun.app.xmlui.aspect.sherparomeo.jaxb.Journal;
import ca.unb.lib.riverrun.app.xmlui.aspect.sherparomeo.jaxb.Postrestriction;
import ca.unb.lib.riverrun.app.xmlui.aspect.sherparomeo.jaxb.Postrestrictions;
import ca.unb.lib.riverrun.app.xmlui.aspect.sherparomeo.jaxb.Prerestriction;
import ca.unb.lib.riverrun.app.xmlui.aspect.sherparomeo.jaxb.Prerestrictions;
import ca.unb.lib.riverrun.app.xmlui.aspect.sherparomeo.jaxb.Publisher;
import ca.unb.lib.riverrun.app.xmlui.aspect.sherparomeo.jaxb.Romeoapi;
import java.io.IOException;
import java.io.Serializable;
import java.sql.SQLException;
import java.util.Iterator;
import java.util.List;
import org.apache.cocoon.caching.CacheableProcessingComponent;
import org.apache.cocoon.util.HashUtil;
import org.apache.excalibur.source.SourceValidity;
import org.apache.log4j.Logger;
import org.dspace.app.xmlui.utils.DSpaceValidity;
import org.dspace.app.xmlui.utils.HandleUtil;
import org.dspace.app.xmlui.utils.UIException;
import org.dspace.app.xmlui.wing.Message;
import org.dspace.app.xmlui.wing.WingException;
import org.dspace.app.xmlui.wing.element.Body;
import org.dspace.app.xmlui.wing.element.Division;
import org.dspace.app.xmlui.wing.element.PageMeta;
import org.dspace.app.xmlui.wing.element.Para;
import org.dspace.authorize.AuthorizeException;
import org.dspace.content.DSpaceObject;
import org.dspace.content.Item;
import org.xml.sax.SAXException;

/**
 * @todo: write me
 */
public class PolicyViewer extends SherpaRomeoTransformer implements CacheableProcessingComponent {

    private static final Logger log = Logger.getLogger(PolicyViewer.class);

    /** Language strings */
    private static final Message T_DSPACE_HOME =
                                 message("xmlui.general.dspace_home");

    private static final Message T_ITEM_TRAIL =
                                 message("xmlui.ArtifactBrowser.ItemViewer.trail");

    private static final Message T_POLICY_TRAIL =
                                 message("xmlui.SherpaRomeo.PolicyViewer.trail");

    private static final Message T_TITLE =
                                 message("xmlui.SherpaRomeo.PolicyViewer.title");

    private static final Message T_ERROR =
                                 message("xmlui.SherpaRomeo.PolicyViewer.error");

    private static final Message T_NO_INFORMATION =
                                 message("xmlui.SherpaRomeo.PolicyViewer.no_information");

    private static final Message T_CONTACT_US =
                                 message("xmlui.SherpaRomeo.PolicyViewer.contact_us");

    /** Cached validity object */
    private SourceValidity validity = null;

    /**
     * Generate the unique caching key.
     * This key must be unique inside the space of this component.
     */
    public Serializable getKey() {
        try {
            DSpaceObject dso = HandleUtil.obtainHandle(objectModel);

            if (dso == null) {
                return "0"; // no item, something is wrong.
            }
            return HashUtil.hash(dso.getHandle() + "show-policies");
        }
        catch (SQLException sqle) {
            // Ignore all errors and just return that the component is not cachable.
            return "0";
        }
    }

    /**
     * Generate the cache validity object.
     * 
     * The validity object will include the item being viewed, 
     * along with all bundles & bitstreams.
     */
    public SourceValidity getValidity() {
        DSpaceObject dso = null;

        if (this.validity == null) {
            try {
                dso = HandleUtil.obtainHandle(objectModel);

                DSpaceValidity dsValidity = new DSpaceValidity();
                dsValidity.add(dso);
                this.validity = dsValidity.complete();
            }
            catch (Exception e) {
                // Ignore all errors and just invalidate the cache.
            }

        }
        return this.validity;
    }

    /**
     * Add the item's title and trail links to the page's metadata.
     */
    @Override
    public void addPageMeta(PageMeta pageMeta) throws SAXException,
            WingException, UIException, SQLException, IOException,
            AuthorizeException {

        DSpaceObject dso = HandleUtil.obtainHandle(objectModel);
        if (!(dso instanceof Item)) {
            return;
        }
        Item item = (Item) dso;

        // set page title
        pageMeta.addMetadata("title").addContent(T_TITLE);

        // Modify trail links for Policy view
        pageMeta.addTrailLink(contextPath + "/", T_DSPACE_HOME);
        HandleUtil.buildHandleTrail(item, pageMeta, contextPath);

        // Add trail items for referring item & current view
        pageMeta.addTrailLink(contextPath + "/handle/" + item.getHandle(), T_ITEM_TRAIL);
        pageMeta.addTrail().addContent(T_POLICY_TRAIL);
    }

    @Override
    public void addBody(Body body) throws SAXException,
            WingException, UIException, SQLException, IOException,
            AuthorizeException {

        DSpaceObject dso = HandleUtil.obtainHandle(objectModel);
        if (!(dso instanceof Item)) {
            return;
        }

        Division division = body.addDivision("policy-viewer", "primary");
        division.setHead(T_TITLE);

        Item item = (Item) dso;
        Query query = new Query(getItemISSN(item));
        Romeoapi response = query.getResponse();

        if (response != null) {

            try {
                // Throws IllegalArgumentException if String retured by
                // getOutcome() doesn't map to a value in enum list
                Outcome outcome = Outcome.valueOf(response.getHeader().getOutcome());

                switch (outcome) {

                    case failed:
                        displayFailed(division);
                        break;

                    case notFound:
                        displayNotFound(division);
                        break;

                    case singleJournal:
                        displayJournal(division, response);
                        break;

                    case manyJournals:
                    case excessJournals:
                    case publisherFound:
                    case uniqueZetoc:
                        // Responses to unimplemented S/R query types
                        // it's an error if they're received
                        log.error("Unexpected SHERPA/RoMEO outcome: " + outcome);
                        displayFailed(division);
                        break;

                    default:
                        // Unhandled outcomes are an error.
                        log.error("Unhandled SHERPA/RoMEO outcome: " + outcome);
                        displayFailed(division);
                        break;
                }
            }
            catch (IllegalArgumentException ex) {
                // Log the error, report failure.
                log.error("Unknown SHERPA/RoMEO outcome", ex);
                displayFailed(division);
            }
        }
    }

    /**
     * Recycle
     */
    @Override
    public void recycle() {
        this.validity = null;
        super.recycle();
    }

    private void displayFailed(Division division) throws WingException {
        division.addPara(T_ERROR);
        division.addPara(T_CONTACT_US);
    }

    private void displayNotFound(Division division) throws WingException {
        division.addPara(T_NO_INFORMATION);
        division.addPara(T_CONTACT_US);
    }


    private void displayJournal(Division division, Romeoapi response) throws WingException {
        Journal journal = response.getJournals().getJournal().get(0);
        
        Division journalDivision = division.addDivision("single-journal");

        journalDivision.setHead(journal.getJtitle());
        journalDivision.addPara("journal-issn", null).addContent(
                    message("xmlui.SherpaRomeo.PolicyViewer.Journal.issn").parameterize(journal.getIssn())
                );

        List<Publisher> publisherList = response.getPublishers().getPublisher();

        if (publisherList.isEmpty()) {
            journalDivision.addPara(message("xmlui.SherpaRomeo.PolicyViewer.Publisher.not_found"));
        }
        else {
            journalDivision.addPara(message("xmlui.SherpaRomeo.PolicyViewer.Publisher.found").parameterize(publisherList.size()));
            
            Iterator i = publisherList.iterator();
            while (i.hasNext()) {

                Publisher publ = (Publisher) i.next();
                Division publDivision = journalDivision.addDivision("publisher");
                publDivision.setHead(publ.getName());

                // Publisher website, if available
                if (! publ.getHomeurl().trim().isEmpty())
                    publDivision.addPara().addXref(publ.getHomeurl(), publ.getHomeurl());

                // Preprint policy
                Division preprintPolicy = publDivision.addDivision("preprint-policy");
                preprintPolicy.setHead(message("xmlui.SherpaRomeo.PolicyViewer.Preprint.title"));

                // Map pre-archiving permission to value in Permission enum
                try {
                    preprintPolicy.addPara(
                            Permission.valueOf(
                                  publ.getPreprints().getPrearchiving()
                              ).getMessage()
                           );
                }
                catch (IllegalArgumentException ex) {
                    // Boo.
                    log.error("Unknown SHERPA/RoMEO permission", ex);
                    preprintPolicy.addPara(T_ERROR);
                }

                // One or more lists of preprint conditions
                List<Prerestrictions> prerestrictionsList = publ.getPreprints().getPrerestrictions();
                if (! prerestrictionsList.isEmpty()) {
                    org.dspace.app.xmlui.wing.element.List preprintConditions = preprintPolicy.addList("preprint-conditions");

                    Iterator iprel = prerestrictionsList.iterator();
                    while (iprel.hasNext()) {
                        Prerestrictions prerestrictions = (Prerestrictions) iprel.next();

                        // Get a list of individual preresticons
                        List<Prerestriction> prerestriction = prerestrictions.getPrerestriction();
                        Iterator ipre = prerestriction.iterator();
                        while (ipre.hasNext()) {
                            Prerestriction pre = (Prerestriction) ipre.next();
                            // Filter indeterminate, escaped XML and HTML fragments returned by S/R
                            addFilteredContent(preprintConditions.addItem(), pre.getvalue());
                        }
                    }
                }

               // Postprint policy
                Division postprintPolicy = publDivision.addDivision("postprint-policy");
                postprintPolicy.setHead(message("xmlui.SherpaRomeo.PolicyViewer.Postprint.title"));

                // Map post-archiving permission to value in Permission enum
                try {
                    postprintPolicy.addPara(
                            Permission.valueOf(
                                  publ.getPostprints().getPostarchiving()
                              ).getMessage()
                           );
                }
                catch (IllegalArgumentException ex) {
                    // Boo.
                    log.error("Unknown SHERPA/RoMEO permission", ex);
                    postprintPolicy.addPara(T_ERROR);
                }

                // One or more lists of postprint conditions
                List<Postrestrictions> postrestrictionsList = publ.getPostprints().getPostrestrictions();
                if (! postrestrictionsList.isEmpty()) {
                    org.dspace.app.xmlui.wing.element.List postprintConditions = postprintPolicy.addList("postprint-conditions");

                    Iterator ipostl = postrestrictionsList.iterator();
                    while (ipostl.hasNext()) {
                        Postrestrictions postrestrictions = (Postrestrictions) ipostl.next();

                        // Get a list of individual post-restrictions
                        List<Postrestriction> postrestriction = postrestrictions.getPostrestriction();
                        Iterator ipost = postrestriction.iterator();
                        while (ipost.hasNext()) {
                            Postrestriction post = (Postrestriction) ipost.next();
                            // Filter indeterminate, escaped XML and HTML fragments returned by S/R
                            addFilteredContent(postprintConditions.addItem(), post.getvalue());
                        }
                    }
                }

                // General Conditions, if any
                List<Condition> conditionList = publ.getConditions().getCondition();
                if (! conditionList.isEmpty()) {
                    org.dspace.app.xmlui.wing.element.List conditions  = publDivision.addList("conditions");
                    conditions.setHead(message("xmlui.SherpaRomeo.PolicyViewer.GeneralConditions.title"));

                    Iterator ic = conditionList.iterator();
                    while (ic.hasNext()) {
                        Condition cond = (Condition) ic.next();
                        // Filter indeterminate, escaped XML and HTML fragments returned by S/R
                        addFilteredContent(conditions.addItem(), cond.getvalue());
                    }
                }
                // Paid open access, if any
                Division paidaccessDiv = publDivision.addDivision("paid-access");
                paidaccessDiv.setHead(message("xmlui.SherpaRomeo.PolicyViewer.PaidOpenAccess.title"));
                Para paidaccessPara = paidaccessDiv.addPara();

                String paidaccessName = publ.getPaidaccess().getPaidaccessname().trim();
                String paidaccessURL = publ.getPaidaccess().getPaidaccessurl().trim();
                String paidaccessNotes = publ.getPaidaccess().getPaidaccessnotes().trim();

                if (paidaccessName.isEmpty() && paidaccessURL.isEmpty()
                        && paidaccessNotes.isEmpty()) {
                    paidaccessPara.addContent(message("xmlui.SherpaRomeo.PolicyViewer.PaidOpenAccess.no_information"));
                }
                else {
                    // format a URL
                    // @fixme ugly
                    if (! paidaccessName.isEmpty() && ! paidaccessURL.isEmpty()) {
                        paidaccessPara.addXref(paidaccessURL, paidaccessName);
                    }
                    else if (paidaccessName.isEmpty()) {
                        // we only have the target
                        paidaccessPara.addXref(paidaccessURL, paidaccessURL);
                    }
                    else {
                        // we only have the name
                        paidaccessPara.addContent(paidaccessName);
                    }

                    // Add notes, if available
                    if (! paidaccessNotes.isEmpty()) {
                        paidaccessPara.addContent(" (" + paidaccessNotes + ")");
                    }

                }
                // Copyright
                Division copyrightDivision = publDivision.addDivision("copyright");
                copyrightDivision.setHead(message("xmlui.SherpaRomeo.PolicyViewer.Copyright.title"));

                List<Copyrightlink> copyrightlinks = publ.getCopyrightlinks().getCopyrightlink();

                if (copyrightlinks.isEmpty()) {
                    copyrightDivision.addPara(message("xmlui.SherpaRomeo.PolicyViewer.Copyright.no_information"));
                }
                else {
                    Iterator ic = copyrightlinks.iterator();
                    org.dspace.app.xmlui.wing.element.List linksList = copyrightDivision.addList("copyright-links");

                    // @fixme link generation w/ possibly empty text, target repeated
                    while (ic.hasNext()) {
                        Copyrightlink copyrightlink = (Copyrightlink) ic.next();
                        String crText = copyrightlink.getCopyrightlinktext().trim();
                        String crURL = copyrightlink.getCopyrightlinkurl().trim();
                        
                        if (crText.isEmpty() && crURL.isEmpty()) {
                            continue;
                        }
                        if (crURL.isEmpty()) {
                            linksList.addItem(crText);
                            continue;
                        }
                        if (crText.isEmpty()) {
                            linksList.addItemXref(crURL, crURL);
                            continue;
                        }
                        
                        // both present then.
                        linksList.addItemXref(crURL, crText);
                    }
                }
                
                // Last updated
                if (! publ.getDateupdated().trim().isEmpty()) {
                    publDivision.addPara("last-updated", null).addContent(
                                 message("xmlui.SherpaRomeo.PolicyViewer.Date.updated").parameterize(publ.getDateupdated())
                            );
                }
            }
        }
    }
}
