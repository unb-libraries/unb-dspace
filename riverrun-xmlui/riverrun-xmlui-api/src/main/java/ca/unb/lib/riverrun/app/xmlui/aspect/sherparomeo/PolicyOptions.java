/*
 * PolicyOptions.java
 */
package ca.unb.lib.riverrun.app.xmlui.aspect.sherparomeo;

import java.io.IOException;
import java.io.Serializable;
import java.sql.SQLException;

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
import org.dspace.app.xmlui.wing.element.Para;
import org.dspace.authorize.AuthorizeException;
import org.dspace.content.DSpaceObject;
import org.dspace.content.Item;
import org.xml.sax.SAXException;

/**
 * Adds a block of text and links to publishers' self-archiving policies.
 * to all views (?showFull = true or ?showFull = false) of an Item with a
 * non-null value in the DC element that stores ISSN data.
 */
public class PolicyOptions extends SherpaRomeoTransformer implements CacheableProcessingComponent
{
    private static final Logger log = Logger.getLogger(PolicyOptions.class);
    
    /** Language strings */
    private static final Message T_PUBLISHER_POLICIES =
        message("xmlui.SherpaRomeo.PolicyOptions.publisher_policies");

    private static final Message T_SHOW_POLICIES =
        message("xmlui.SherpaRomeo.PolicyOptions.show_policies");
    
	/** Cached validity object */
	private SourceValidity validity = null;
	

    /**
     * Generate the unique caching key.
     * This key must be unique inside the space of this component.
     */
    public Serializable getKey() {
        try {
            DSpaceObject dso = HandleUtil.obtainHandle(objectModel);
            
            if (dso == null)
                return "0"; // no item, something is wrong.
            
            return HashUtil.hash(dso.getHandle());
        } 
        catch (SQLException sqle)
        {
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
    public SourceValidity getValidity() 
    {
        DSpaceObject dso = null;

        if (this.validity == null)
    	{
	        try {
	            dso = HandleUtil.obtainHandle(objectModel);
	            
	            DSpaceValidity dsValidity = new DSpaceValidity();
	            dsValidity.add(dso);
	            this.validity =  dsValidity.complete();
	        }
	        catch (Exception e)
	        {
	            // Ignore all errors and just invalidate the cache.
	        }

    	}
    	return this.validity;
    }
    
    
    /**
     * Display a single item
     */
    @Override
    public void addBody(Body body) throws SAXException, WingException,
            UIException, SQLException, IOException, AuthorizeException
    {

        DSpaceObject dso = HandleUtil.obtainHandle(objectModel);
        if (!(dso instanceof Item))
            return;
        Item item = (Item) dso;

        if (getItemISSN(item) != null) {
            // Add a division for S/R text and links
            Division division = body.addDivision("policy-options");
            division.setHead(T_PUBLISHER_POLICIES);

            Para showPoliciesPara = division.addPara();
            String link = contextPath + "/handle/" + item.getHandle() + "/show-policies";
            showPoliciesPara.addXref(link).addContent(T_SHOW_POLICIES);
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
}
