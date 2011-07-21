<!--
    RiverRun customizations to the main structure of the page
    constructed by Mirage base theme.
    
    * Modifies page footer
-->

<xsl:stylesheet xmlns:i18n="http://apache.org/cocoon/i18n/2.1"
	xmlns:dri="http://di.tamu.edu/DRI/1.0/"
	xmlns:mets="http://www.loc.gov/METS/"
	xmlns:xlink="http://www.w3.org/TR/xlink/"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0"
	xmlns:dim="http://www.dspace.org/xmlns/dspace/dim"
	xmlns:xhtml="http://www.w3.org/1999/xhtml"
	xmlns:mods="http://www.loc.gov/mods/v3"
	xmlns:dc="http://purl.org/dc/elements/1.1/"
	xmlns="http://www.w3.org/1999/xhtml"
	exclude-result-prefixes="i18n dri mets xlink xsl dim xhtml mods dc">

    <xsl:output indent="yes"/>

    <xsl:template name="buildFooter">
        <div id="ds-footer-wrapper">
            <div id="ds-footer">
                <div id="ds-footer-left">
                  <i18n:text>xmlui.dri2xhtml-alt.page-structure.footer-promotional</i18n:text>
                </div>
                <div id="ds-footer-right">
                    <a id="ds-footer-logo-link-etc" class="ds-footer-logo-link" title="Electronic Text Centre" href="http://etc.lib.unb.ca/">
                      <span id="ds-footer-logo-etc" class="ds-footer-logo">&#160;</span>
                    </a>
                    <a id="ds-footer-logo-link-lib" class="ds-footer-logo-link" title="UNB Libraries" href="http://lib.unb.ca/">
                      <span id="ds-footer-logo-lib" class="ds-footer-logo">&#160;</span>
                    </a>
                </div>
                <div id="ds-footer-links">
                    <a>
                        <xsl:attribute name="href">
                            <xsl:value-of
                                    select="/dri:document/dri:meta/dri:pageMeta/dri:metadata[@element='contextPath'][not(@qualifier)]"/>
                            <xsl:text>/contact</xsl:text>
                        </xsl:attribute>
                        <i18n:text>xmlui.dri2xhtml.structural.contact-link</i18n:text>
                    </a>
                    <xsl:text> | </xsl:text>
                    <a>
                        <xsl:attribute name="href">
                            <xsl:value-of
                                    select="/dri:document/dri:meta/dri:pageMeta/dri:metadata[@element='contextPath'][not(@qualifier)]"/>
                            <xsl:text>/feedback</xsl:text>
                        </xsl:attribute>
                        <i18n:text>xmlui.dri2xhtml.structural.feedback-link</i18n:text>
                    </a>
                </div>
                <!--Invisible link to HTML sitemap (for search engines) -->
                <a class="hidden">
                    <xsl:attribute name="href">
                        <xsl:value-of
                                select="/dri:document/dri:meta/dri:pageMeta/dri:metadata[@element='contextPath'][not(@qualifier)]"/>
                        <xsl:text>/htmlmap</xsl:text>
                    </xsl:attribute>
                    <xsl:text>&#160;</xsl:text>
                </a>
            </div>
        </div>
    </xsl:template>
</xsl:stylesheet>