package ca.unb.lib.riverrun.app.oai;

/**
 * The parent QDC crosswalk returns metadata as a list of elements, rather than
 * as a root element with nested subelements, because:
 *
 * "Some metadata formats have an XML schema without a root element, for
 * example, the Dublin Core and Qualified Dublin Core formats. [The QDC
 * crosswalk] would "prefer" to return a list, since any root element it has to
 * produce would have to be part of a nonstandard schema."
 *
 * However, OCLC's Digital Collections Gateway requires that an OAI-PMH response
 * contains an element that is a child of <metadata> which encompasses all of
 * the metadata tags.
 *
 * This subclass overrides the preferList() method in the parent to return
 * FALSE so QDC metadata is returned inside root element in an OAI response.
 *
 * @see org.dspace.content.crosswalk.DisseminationCrosswalk.java
 */
public class QDCCrosswalk extends org.dspace.content.crosswalk.QDCCrosswalk {

    @Override
    public boolean preferList() {
        return false;
    }
}
