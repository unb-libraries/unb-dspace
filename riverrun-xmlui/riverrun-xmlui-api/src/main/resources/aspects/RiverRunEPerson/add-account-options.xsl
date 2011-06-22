<?xml version="1.0" encoding="UTF-8"?>

<!--
    Document   : add-account-options.xsl.xsl
    Created on : June 13, 2011, 11:50 AM
    Author     : dspace
    Description: adds simple, always-on options to the Account options block.

-->

<xsl:stylesheet
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:dri="http://di.tamu.edu/DRI/1.0/"
  xmlns:i18n="http://apache.org/cocoon/i18n/2.1"  
  version="1.0">

    <xsl:output method="xml"/>

    <xsl:template match="*">
        <xsl:copy>
            <xsl:copy-of select="@*"/>
            <xsl:apply-templates/>
        </xsl:copy>
    </xsl:template>

    <xsl:template match="dri:list[@id='aspect.artifactbrowser.Navigation.list.account']">
        <xsl:copy>
            <xsl:copy-of select="@*"/>
            <xsl:apply-templates/>
            <dri:item>
                <dri:xref>
                    <xsl:attribute name="target">
                        <xsl:value-of select="/dri:document/dri:meta/dri:pageMeta/dri:metadata[@element='contextPath'][not(@qualifier)]"/>
                        <xsl:text>/help</xsl:text>
                    </xsl:attribute>
                    <i18n:text>xmlui.dri2xhtml.structural.help</i18n:text>
                </dri:xref>
            </dri:item>
        </xsl:copy>
    </xsl:template>

</xsl:stylesheet>

