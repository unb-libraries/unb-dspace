package ca.unb.lib.riverrun.app.xmlui.aspect.sherparomeo;

import java.util.Arrays;
import java.util.Iterator;
import java.util.List;
import org.apache.log4j.Logger;
import org.dspace.app.xmlui.cocoon.AbstractDSpaceTransformer;
import org.dspace.app.xmlui.wing.Message;
import org.dspace.content.DCValue;
import org.dspace.content.Item;
import org.dspace.core.ConfigurationManager;

/**
 * This class will become more useful if we extend S/R queries to allow journal
 * title, publisher name searches, etc.: it loads DSpace config settings that
 * identify DC elements to be used in S/R queries, and provides methods to fetch
 * values of those elements for the current Item.
 */
public class SherpaRomeoTransformer extends AbstractDSpaceTransformer {

    private static final Logger log = Logger.getLogger(SherpaRomeoTransformer.class);

        /** S/R responses */
    public enum Outcome {
        failed, notFound, singleJournal, manyJournals, excessJournals,
        publisherFound, uniqueZetoc;
    }

    /** S/R archiving permission */
    public enum Permission {
        can (message("xmlui.SherpaRomeo.PolicyViewer.Permission.can")),
        cannot (message("xmlui.SherpaRomeo.PolicyViewer.Permission.cannot")),
        restricted (message("xmlui.SherpaRomeo.PolicyViewer.Permission.restricted")),
        unclear (message("xmlui.SherpaRomeo.PolicyViewer.Permission.unclear")),
        unknown (message("xmlui.SherpaRomeo.PolicyViewer.Permission.unknown"));

        private final Message message;

        Permission(Message message) {
            this.message = message;
        }

        public Message getMessage() { return this.message; }
    }

    /** DSpace metadata element that stores ISSN */
    protected static String issnElement = null;

    static {
        issnElement = ConfigurationManager.getProperty("sherpa.romeo.issn");
    }

    /**
     * Obtain the item's ISSN
     */
    public static String getItemISSN(Item item) {
        String issn = null;

        if (issnElement == null) {
            throw new IllegalStateException("Missing DSpace configuration keys for SHERPA/RoMEO queries: sherpa.romeo.issn");
        }

        // We expect issnElement to be [schema].[element]{.[qualifier]?}
        List<String> issnParts = Arrays.asList(issnElement.split("\\."));

        String schema = null;
        String name = null;
        String qualifier = null;

        Iterator i = issnParts.iterator();
        if (i.hasNext()) {
            schema = (String) i.next();
        }
        if (i.hasNext()) {
            name = (String) i.next();
        }
        if (i.hasNext()) {
            qualifier = (String) i.next();
        }

        DCValue[] issns = item.getMetadata(schema, name, qualifier, Item.ANY);

        if (issns != null && issns.length > 0) {
            issn = issns[0].value;
        }

        return issn;
    }

}
