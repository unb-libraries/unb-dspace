<!--
    Global variables for the ETCMirage theme, accessible from other templates
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
	
	<!-- 
		Global variables:
			* $context-path
			* $theme-path 
		are defined in dri2xhtml-alt/core/global-variables.xsl. 
		
		ETCMirage builds on Mirage as a 'base theme' so we define global variables
		for the base theme name and path which are included in the DRI document by
		our sitemap.xmamp.
		
		$base-theme-path represents the full path to the 'base' theme, useful for 
		accessing static resources (CSS, Java, images) used by ETCMirage without
		modification.
	-->
	<xsl:variable 
		name="base-theme-path" 
		select="concat($context-path,'/themes/',/dri:document/dri:meta/dri:pageMeta/dri:metadata[@element='basetheme'][@qualifier='path'])"/>
	
</xsl:stylesheet>
