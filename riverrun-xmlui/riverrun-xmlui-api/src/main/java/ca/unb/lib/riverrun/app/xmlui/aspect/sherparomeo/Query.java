package ca.unb.lib.riverrun.app.xmlui.aspect.sherparomeo;

import ca.unb.lib.riverrun.app.xmlui.aspect.sherparomeo.jaxb.Romeoapi;
import java.net.MalformedURLException;
import java.net.URL;
import javax.xml.bind.JAXBContext;
import javax.xml.bind.JAXBException;
import javax.xml.bind.Unmarshaller;
import org.apache.commons.httpclient.NameValuePair;
import org.apache.commons.httpclient.util.EncodingUtil;
import org.apache.log4j.Logger;
import org.dspace.core.ConfigurationManager;

public class Query {
    private static final Logger log = Logger.getLogger(Query.class);

    // SHERPA/RoMEO API URL, defined in DSpace config file
    // @todo: set this in S/R transformer & pass in
    private static final String sherpaRomeoURL;

    // Query parameters
    // @todo: add more
    private String issn;

    // Response from S/R; a JAXB-generated class
    private Romeoapi response = null;




    // Fetch S/R API URL from DSpace config
    // @todo: config this
    static {
       sherpaRomeoURL = ConfigurationManager.getProperty("sherpa.romeo.url");
    }

    // @todo: fix this.  This should be a static class that creates queries (?)
    public Query(String issn) {
        this.issn = issn;
    }

    public Romeoapi getResponse() {
        if (this.response == null)
            initResponse();

        return response;
    }

    private void initResponse() {
        // Query S/R for publisher info
        NameValuePair[] args = new NameValuePair[]{new NameValuePair("issn", this.issn)};
        String srUrl = sherpaRomeoURL + "?" + EncodingUtil.formUrlEncode(args, "UTF8");

        try {
            JAXBContext jc = JAXBContext.newInstance("ca.unb.lib.riverrun.app.xmlui.aspect.sherparomeo.jaxb");
            Unmarshaller unmarshaller = jc.createUnmarshaller();

            this.response = (Romeoapi) unmarshaller.unmarshal(new URL(srUrl));
        }
        catch (MalformedURLException ex) {
            log.error("Malformed SHERPA/RoMEO request", ex);
        }
        catch (JAXBException ex) {
            log.error("Error unmarshalling SHERPA/RoMEO data", ex);
        }

    }
}
