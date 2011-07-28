/*
 * ETDMSDisseminationCrosswalk.java
 */
package ca.unb.lib.riverrun.app.oai;

import java.io.File;
import java.io.FileInputStream;
import java.io.IOException;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.Enumeration;
import java.util.HashMap;
import java.util.HashSet;
import java.util.Iterator;
import java.util.List;
import java.util.Map;
import java.util.Properties;
import java.util.Set;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

import org.apache.log4j.Logger;
import org.dspace.authorize.AuthorizeException;
import org.dspace.content.Bitstream;
import org.dspace.content.Bundle;
import org.dspace.content.DCValue;
import org.dspace.content.DSpaceObject;
import org.dspace.content.Item;
import org.dspace.content.crosswalk.CrosswalkException;
import org.dspace.content.crosswalk.CrosswalkInternalException;
import org.dspace.content.crosswalk.CrosswalkObjectNotSupported;
import org.dspace.content.crosswalk.DisseminationCrosswalk;
import org.dspace.core.ConfigurationManager;
import org.dspace.core.Constants;
import org.dspace.core.SelfNamedPlugin;
import org.jdom.Element;
import org.jdom.Namespace;

/**
 * Configurable ETDMS Crosswalk
 * <p>
 * This class supports multiple dissemination crosswalks from DSpace
 * internal data to ETDMS XML
 *
 * <p>
 * It registers multiple Plugin names, which it reads from
 * the DSpace configuration as follows:
 *
 * <h3>Configuration</h3>
 * Every key starting with <code>"crosswalk.etdms.properties."</code> describes
 * an ETDMS crosswalk.  Everything after the last period is the <em>plugin instance</em>,
 * and the value is the pathname (relative to <code><em>dspace.dir</em>/config</code>)
 * of the crosswalk configuration file.
 * <p>
 * You can have two aliases point to the same crosswalk,
 * just add two configuration entries with the same value, e.g.
 * <pre>
 *    crosswalk.etdms.properties.thesescanada = xwalk/etdms.properties
 *    crosswalk.etdms.properties.synergies = xwalk/etdms.properties
 * </pre>
 * The first line creates a plugin with the name <code>"thesescanada"</code>
 * which is configured from the file <em>dspace-dir</em><code>/xwalk/etdms.properties</code>.
 * <p>
 * Since there is significant overhead in reading the properties file to
 * configure the crosswalk, and a crosswalk instance may be used any number
 * of times, we recommend caching one instance of the crosswalk for each
 * alias and simply reusing those instances. The PluginManager does
 * this by default.
 * <p>
 * Each named crosswalk has two other types of configuration lines:
 * <p>
 * XML Namespaces: all XML namespace prefixes used in the XML fragments below
 * <em>must</em> be defined in the configuration as follows.  Add a line of
 * the form: <pre>
 *  crosswalk.etdms.namespace.{NAME}.{prefix} = {namespace-URI}</pre>
 *
 * <p>
 * Finally, you need to declare an XML Schema URI for the plugin, with
 * a line of the form <pre>
 *  crosswalk.etdms.schema.{NAME} = {schema-URI}</pre>
 * for example,
 * <pre>crosswalk.etdms.schemaLocation.thesescanada  = \
 *   http://www.ndltd.org/standards/metadata/etdms/1.0/ \
 *   http://www.ndltd.org/standards/metadata/etdms/1.0/etdms.xsd</pre>
 *
 * Based on org.dspace.content.crosswalk.QDCCrosswalk.java by
 * @author Larry Stone
 * 
 */
public class ETDMSDisseminationCrosswalk extends SelfNamedPlugin
        implements DisseminationCrosswalk {

    /** log4j category */
    private static Logger log = Logger.getLogger(ETDMSDisseminationCrosswalk.class);

    // map of qdc to etdms
    private Map<String, Set<String>> qdc2etdms = new HashMap<String, Set<String>>();

    // List of elments nested under 'degree'
    private static final List<String> degreeChildren = Arrays.asList(new String[] {"name", "level", "discipline", "grantor"});

    // the XML namespaces from config file for this name.
    private Namespace namespaces[] = null;

    // OAI ETDMS Namespace
    private static final Namespace ETDMS_NS =
            Namespace.getNamespace("oai_etdms", "http://www.ndltd.org/standards/metadata/etdms/1.0/");

    // sentinal: done init?
    private boolean inited = false;

    // my plugin name
    private String myName = null;

    // prefix of all DSpace Configuration entries.
    private static final String CONFIG_PREFIX = "crosswalk.etdms";

    // prefix of Theses Canada identifier
    // @todo remove this.  Crosswalks shouldn't generate metadata
    private static final String CONFIG_TC_ID = CONFIG_PREFIX + ".thesescanada.id";

    // XML schemaLocation fragment for this crosswalk, from config.
    private String schemaLocation = null;

    // Theses Canada ID prefix, to be prepended to item handle
    private String thesesCanadaId = null;

    /**
     * Fill in the plugin-name table from DSpace configuration entries
     * for configuration files for flavors of ETDMS crosswalk:
     */
    private static String aliases[] = null;

    static {
        List aliasList = new ArrayList();
        Enumeration pe = ConfigurationManager.propertyNames();
        String propname = CONFIG_PREFIX + ".properties.";

        while (pe.hasMoreElements()) {
            String key = (String) pe.nextElement();
            if (key.startsWith(propname)) {
                aliasList.add(key.substring(propname.length()));
            }
        }
        aliases = (String[]) aliasList.toArray(new String[aliasList.size()]);
    }

    public static String[] getPluginNames() {
        return aliases;
    }


    /**
     * Initialize Crosswalk table from a properties file
     * which itself is the value of the DSpace configuration property
     * "crosswalk.etdms.properties.X", where "X" is the alias name of this
     * instance. Each instance may be configured with a separate mapping table.
     *
     * The ETDMS crosswalk configuration properties follow the format:
     *
     *  {qdc-element} = {etdms-element[,etdms-element]*}
     *
     *  1. qualified DC field name is of the form (qualifier is optional)
     *       {MDschema}.{element}.{qualifier}
     *
     *      e.g.  dc.contributor.author
     *            dc.title
     *            dc.subject.*
     *
     *  2. etdms-element identifies one or more field names into which the value
     *     of the corresponding qdc-element is mapped.
     *
     * Example properties lines:
     *
     *  dc.title = title
     *  dc.contributor.author = creator
     *  dc.subject.* = subject
     *  dc.publisher = publisher, grantor
     * 
     */
    private void init()
            throws CrosswalkException, IOException {
        if (inited) {
            return;
        }
        inited = true;

        myName = getPluginInstanceName();
        if (myName == null) {
            throw new CrosswalkInternalException("Cannot determine plugin name, "
                    + "You must use PluginManager to instantiate ETDMSDisseminationCrosswalk so the instance knows its name.");
        }

        // grovel DSpace configuration for namespaces
        List nsList = new ArrayList();
        Enumeration pe = ConfigurationManager.propertyNames();
        String propname = CONFIG_PREFIX + ".namespace." + myName + ".";

        while (pe.hasMoreElements()) {
            String key = (String) pe.nextElement();
            if (key.startsWith(propname)) {
                nsList.add(Namespace.getNamespace(key.substring(propname.length()),
                        ConfigurationManager.getProperty(key)));
            }
        }
        nsList.add(Namespace.XML_NAMESPACE);
        namespaces = (Namespace[]) nsList.toArray(new Namespace[nsList.size()]);

        // get XML schemaLocation fragment from config
        schemaLocation = ConfigurationManager.getProperty(CONFIG_PREFIX + ".schemaLocation." + myName);

        // get ThesesCanada ID prefix from config
        thesesCanadaId = ConfigurationManager.getProperty(CONFIG_TC_ID);

        // read properties
        String cmPropName = CONFIG_PREFIX + ".properties." + myName;
        String propsFilename = ConfigurationManager.getProperty(cmPropName);
        if (propsFilename == null) {
            throw new CrosswalkInternalException("Configuration error: "
                    + "No properties file configured for ETDMS crosswalk named \"" + myName + "\"");
        }

        String parent = ConfigurationManager.getProperty("dspace.dir")
                + File.separator + "config" + File.separator;
        File propsFile = new File(parent, propsFilename);
        Properties etdmsProps = new Properties();
        FileInputStream pfs = null;
        try {
            pfs = new FileInputStream(propsFile);
            etdmsProps.load(pfs);
        } finally {
            if (pfs != null) {
                try {
                    pfs.close();
                } catch (IOException ioe) {
                }
            }
        }

        // grovel properties to initialize qdc->etdms map
        pe = etdmsProps.propertyNames();

        while (pe.hasMoreElements()) {
            String qdc = (String) pe.nextElement();
            List<String> etdmsList = Arrays.asList(etdmsProps.getProperty(qdc, "").split(","));

            Set<String> tmp = qdc2etdms.get(qdc);
            if (tmp == null)
                tmp = new HashSet<String>();

            Iterator i = etdmsList.iterator();
            while (i.hasNext()) {
                String etdmsString = (String) i.next();
                tmp.add(etdmsString);
            }

            qdc2etdms.put(qdc, tmp);
        }
    }

    @Override
    public Namespace[] getNamespaces() {
        try {
            init();
        } catch (Exception e) {
        }
        return namespaces;
    }

    @Override
    public String getSchemaLocation() {
        try {
            init();
        } catch (Exception e) {
        }
        return schemaLocation;
    }

    /**
     * Returns object's metadata in ETDMS format, as XML structure node.
     */
    @Override
    public List disseminateList(DSpaceObject dso)
            throws CrosswalkException,
            IOException, SQLException, AuthorizeException {
        return disseminateListInternal(dso, false);
    }

    private List disseminateListInternal(DSpaceObject dso, boolean addSchema)
            throws CrosswalkException,
            IOException, SQLException, AuthorizeException {
        if (dso.getType() != Constants.ITEM) {
            throw new CrosswalkObjectNotSupported("ETDMSCrosswalk can only crosswalk an Item.");
        }
        Item item = (Item) dso;
        init();

        DCValue[] dc = item.getMetadata(Item.ANY, Item.ANY, Item.ANY, Item.ANY);

        // Most elements added directly to list
        List result = new ArrayList(dc.length);

        // ... but some added as children of degree element
        Element degreeElement = new Element("degree");
        

        for (int i = 0; i < dc.length; i++) {
            // Compose qualified DC name - schema.element[.qualifier]
            // e.g. "dc.title", "dc.subject.lcc", "lom.Classification.Keyword"

            String qdc = dc[i].schema + "."
                    + ((dc[i].qualifier == null) ? dc[i].element
                    : (dc[i].element + "." + dc[i].qualifier));

            Set<String> etdmsSet = qdc2etdms.get(qdc);

            if (etdmsSet != null) {
                Iterator iterator = etdmsSet.iterator();
                while (iterator.hasNext()) {
                    String etdmsString = (String) iterator.next();
                    Element etdmsElement = new Element(etdmsString.trim());

                    etdmsElement.addContent(dc[i].value);
                    if (addSchema) {
                        etdmsElement.setAttribute("schemaLocation", schemaLocation, XSI_NS);
                    }

                    if (degreeChildren.contains(etdmsElement.getName()))
                        degreeElement.addContent(etdmsElement);
                    else
                        result.add(etdmsElement);
                }

            }

        }

        // Add degree element, empty or not
        result.add(degreeElement);


        // Theses Canada identifier
        // @todo remove TC ID generation; crosswalks shouldn't create metadata
        // If we don't have a ThesesCanada prefix, skip this mess altogether.
        if (thesesCanadaId != null && (! thesesCanadaId.isEmpty())) {
            String handle = item.getHandle();
            if (handle != null) {
                Element tcElement = new Element("identifier");
                tcElement.addContent(thesesCanadaId + "-" + handle.substring(handle.lastIndexOf("/") + 1));
                if (addSchema) {
                    tcElement.setAttribute("schemaLocation", schemaLocation, XSI_NS);
                }
                result.add(tcElement);
            }
        }
        // end TC ID hack

        // Theses Canada, Synergies identifer: primary bitstream URL
        //
        // @fixme: bitstreams are examined for filenames ending in PDF.
        // The first matching filename is assumed to be the primary
        // document for the item & an 'identifier' element is created
        // with a URL to the document.
        //
        // Needless to say, this is too rough to be reliable, but is
        // more or less echoed from the U. Man. class -- it's no more
        // broken than it was.
        //
        // Also, the file identified in this bitstream may or may not
        // correspond to the MIME type & extent information, (possibly)
        // used by this crosswalk, that's fetched from item-level
        // metadata.
        //
        // Needs to be fixed or removed: see Bugzilla #32

        // Get bundles of bitstreams
        Bundle[] bundles = item.getBundles();
        List<Bundle> bundleList = Arrays.asList(bundles);
        Iterator i = bundleList.iterator();

        // Look for ORIGINAL bundle
        Bundle originalBundle = null;
        while (i.hasNext()) {
            Bundle bundle = (Bundle) i.next();
            if (bundle.getName().equalsIgnoreCase("ORIGINAL")) {
                originalBundle = bundle;
                break;
            }
        }

        // Found it.
        if (originalBundle != null) {
            Bitstream[] bitstreams = originalBundle.getBitstreams();
            List<Bitstream> bitstreamList = Arrays.asList(bitstreams);
            /*Iterator*/ i = bitstreamList.iterator();

            Pattern p = Pattern.compile(".+\\.(?i)pdf\\s*$");

            while (i.hasNext()) {
                Bitstream bitstream = (Bitstream) i.next();
                Matcher m = p.matcher(bitstream.getName());

                if (m.matches()) {
                    // Build a URL, of questionable utility, to bitstream...
                    String bitstreamURL =
                            ConfigurationManager.getProperty("dspace.url") +
                            "/bitstream/" +
                            item.getHandle() + "/" +
                            bitstream.getSequenceID() + "/" +
                            bitstream.getName();

                    Element bsElement = new Element("identifier");
                    bsElement.addContent(bitstreamURL);
                    result.add(bsElement);
                }
            }
        }
        // end Theses Canada, Synergies bitstream URL hack.
        // We now return to scheduled programming.

        // Return the list
        return result;
    }

    public Element disseminateElement(DSpaceObject dso)
            throws CrosswalkException,
            IOException, SQLException, AuthorizeException {

        init();
        Element root = new Element("thesis", ETDMS_NS);
        if (schemaLocation != null)
            root.setAttribute("schemaLocation", schemaLocation, XSI_NS);

        root.addContent(disseminateListInternal(dso, false));
        return root;
    }

    public boolean canDisseminate(DSpaceObject dso) {
        return true;
    }

    public boolean preferList() {
        return false;
    }
}
