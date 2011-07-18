<?xml version="1.0" encoding="UTF-8"?>
<!-- @todo describe me -->    

<xsl:stylesheet 
	xmlns:i18n="http://apache.org/cocoon/i18n/2.1"
	xmlns:dri="http://di.tamu.edu/DRI/1.0/"
	xmlns:mets="http://www.loc.gov/METS/"
	xmlns:mods="http://www.loc.gov/mods/v3"
	xmlns:dc="http://purl.org/dc/elements/1.1/"
	xmlns:dim="http://www.dspace.org/xmlns/dspace/dim" 
	xmlns:xlink="http://www.w3.org/TR/xlink/"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">


	<xsl:import href="../dri2xhtml.xsl"/>
	
	<!-- override templates in ../dri2xhtml/structural.xsl -->
	<xsl:import href="structural.xsl"/>
	
	<!-- override templates in ../dri2xhtml/DIM-Handler.xsl -->
	<xsl:import href="DIM-Handler.xsl"/>

	<xsl:output indent="yes"/>       
	
</xsl:stylesheet>
