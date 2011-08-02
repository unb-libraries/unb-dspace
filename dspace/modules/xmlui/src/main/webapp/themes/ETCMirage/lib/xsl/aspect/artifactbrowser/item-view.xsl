<!--
  ETCMirage/lib/xsl/aspect/artifactbrowser/item-view.xsl
  
  Templates for rendering the item display page in ETCMirage, a 'subtheme' of
  Mirage.
-->
<xsl:stylesheet xmlns:i18n="http://apache.org/cocoon/i18n/2.1"
	xmlns:dri="http://di.tamu.edu/DRI/1.0/" xmlns:mets="http://www.loc.gov/METS/"
	xmlns:dim="http://www.dspace.org/xmlns/dspace/dim" xmlns:xlink="http://www.w3.org/TR/xlink/"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0"
	xmlns:atom="http://www.w3.org/2005/Atom" xmlns:ore="http://www.openarchives.org/ore/terms/"
	xmlns:oreatom="http://www.openarchives.org/ore/atom/" xmlns:xalan="http://xml.apache.org/xalan"
	xmlns:encoder="xalan://java.net.URLEncoder" xmlns:util="org.dspace.app.xmlui.utils.XSLUtils"
	xmlns="http://www.w3.org/1999/xhtml"
	exclude-result-prefixes="xalan encoder i18n dri mets dim  xlink xsl">

	<xsl:output indent="yes"/>
	
	<!-- Special handling for dc.identifier.uri -->
	<xsl:template match="dim:field[@mdschema='dc' and @element='identifier' and @qualifier='uri']" mode="itemDetailView-DIM">
		<xsl:call-template name="dimField">
			<xsl:with-param name="value">
				<a>
					<xsl:attribute name="href">
						<xsl:value-of select="node()"/>
					</xsl:attribute>
					<xsl:value-of select="node()"/>
				</a>
			</xsl:with-param>
		</xsl:call-template>
	</xsl:template>
	
	<!-- Special handling for dc.identifier.doi -->
	<xsl:template match="dim:field[@mdschema='dc' and @element='identifier' and @qualifier='doi']" mode="itemDetailView-DIM">	
		
		<!-- DOIs may have been entered as URLs. Sort out which. -->
		<xsl:call-template name="dimField">
			<xsl:with-param name="value">
				<xsl:if test="starts-with(node(), 'http://')">
					<!-- assume it's been entered as a URL -->
					<a>
						<xsl:attribute name="href">
							<xsl:value-of select="node()"/>
						</xsl:attribute>
						<xsl:value-of select="substring-after(node(),'http://dx.doi.org/')"/>
					</a>
				</xsl:if>
				<xsl:if test="not(starts-with(node(), 'http://'))">
					<!-- assume it's a DOI... -->
					<a>
						<xsl:attribute name="href">
							<xsl:value-of select="concat('http://dx.doi.org/', node())"/>
						</xsl:attribute>
						<xsl:value-of select="node()"/>
					</a>
				</xsl:if>
			</xsl:with-param>
		</xsl:call-template>
	</xsl:template>

	<!-- All remaining DIM fields: --> 
	<xsl:template match="dim:field" mode="itemDetailView-DIM">
		<xsl:call-template name="dimField"/>
	</xsl:template>
	
	<!-- Generate a row in metadata table of item detail view -->
	<xsl:template name="dimField">
		<xsl:param name="value">
			<xsl:copy-of select="node()"/>
		</xsl:param>
		
		<tr>
			<xsl:attribute name="class">
				<xsl:text>ds-table-row </xsl:text>
				<xsl:if test="(position() div 2 mod 2 = 0)">even </xsl:if>
				<xsl:if test="(position() div 2 mod 2 = 1)">odd </xsl:if>
			</xsl:attribute>
			<td class="label-cell">
				<xsl:value-of select="./@mdschema"/>
				<xsl:text>.</xsl:text>
				<xsl:value-of select="./@element"/>
				<xsl:if test="./@qualifier">
					<xsl:text>.</xsl:text>
					<xsl:value-of select="./@qualifier"/>
				</xsl:if>
			</td>
			<td>
				<xsl:copy-of select="$value"/>
				<xsl:if test="./@authority and ./@confidence">
					<xsl:call-template name="authorityConfidenceIcon">
						<xsl:with-param name="confidence" select="./@confidence"/>
					</xsl:call-template>
				</xsl:if>
			</td>
			<td>
				<xsl:value-of select="./@language"/>
			</td>
		</tr>
	</xsl:template>

</xsl:stylesheet>
