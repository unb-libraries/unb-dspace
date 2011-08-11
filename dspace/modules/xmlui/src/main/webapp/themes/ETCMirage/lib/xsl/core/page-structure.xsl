<!--
    RiverRun customizations to the main structure of the page constructed by
    Mirage base theme.

		@todo update this 
    * Modifies <head> to refer to ETCMirage files, where customized 
    * Modifies page header to include 'Help' link next to 'Login' link
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

	<!-- 
		The HTML head element contains references to CSS as well as embedded
		JavaScript code. Most of this information is either user-provided bits of
		post-processing (as in the case of the JavaScript), or references to
		stylesheets pulled directly from the pageMeta element. 
		
		ETCMirage builds on Mirage as a 'base theme' so we include static resources
		that we've customized for the current theme, as well as unmodiified versions
		from Mirage.
		
		Global variables used in this stylesheet:
		
		dri2xhtml-alt/core/global-variables.xsl
		* $context-path
		* $theme-path 
		
		ETCMirage/core/global-variables.xsl
		* $subtheme-path
		
	-->
	<xsl:template name="buildHead">
		<head>
			<meta http-equiv="Content-Type" content="text/html; charset=UTF-8"/>
			
			<!-- Always force latest IE rendering engine (even in intranet) & Chrome Frame -->
			<meta http-equiv="X-UA-Compatible" content="IE=edge,chrome=1"/>
			
			<!--  
				Mobile Viewport Fix
				j.mp/mobileviewport & davidbcalhoun.com/2010/viewport-metatag
				
				device-width : Occupy full width of the screen in its current orientation
				initial-scale = 1.0 retains dimensions instead of zooming out if page height > device height
				maximum-scale = 1.0 retains dimensions instead of zooming in if page width < device width
			-->
			<meta name="viewport" content="width=device-width; initial-scale=1.0; maximum-scale=1.0;"/>
			
			<link rel="shortcut icon">
				<xsl:attribute name="href">
					<xsl:value-of select="$subtheme-path"/>
					<xsl:text>/images/favicon.ico</xsl:text>
				</xsl:attribute>
			</link>
			<link rel="apple-touch-icon">
				<xsl:attribute name="href">
					<xsl:value-of select="$theme-path"/>
					<xsl:text>/images/apple-touch-icon.png</xsl:text>
				</xsl:attribute>
			</link>
			
			<meta name="Generator">
				<xsl:attribute name="content">
					<xsl:text>DSpace</xsl:text>
					<xsl:if test="/dri:document/dri:meta/dri:pageMeta/dri:metadata[@element='dspace'][@qualifier='version']">
						<xsl:text> </xsl:text>
						<xsl:value-of select="/dri:document/dri:meta/dri:pageMeta/dri:metadata[@element='dspace'][@qualifier='version']"/>
					</xsl:if>
				</xsl:attribute>
			</meta>
			
			<!-- 
				Add stylsheets. Sitemap defines all stylesheet paths relative to base 
				theme; modify sitemap.xmap to add / change stylesheet paths.
			-->
			<xsl:for-each select="/dri:document/dri:meta/dri:pageMeta/dri:metadata[@element='stylesheet']">
				<link rel="stylesheet" type="text/css">
					<xsl:attribute name="media">
						<xsl:value-of select="@qualifier"/>
					</xsl:attribute>
					<xsl:attribute name="href">
						<xsl:value-of select="$theme-path"/>
						<xsl:text>/</xsl:text>
						<xsl:value-of select="."/>
					</xsl:attribute>
				</link>
			</xsl:for-each>
			
			<!-- 
			  Before the page renders, include CSS to pre-hide content that will be displayed
			  during Javascript-powered page interactions.  Including the CSS with Javascript
			  means users *without* Javascript will be able to view all page content.
		 -->
			<xsl:for-each select="/dri:document/dri:meta/dri:pageMeta/dri:metadata[@element='preload']">
<script type="text/javascript">
  <xsl:text disable-output-escaping="yes">
    /* &lt;![CDATA[ */</xsl:text>
  <xsl:text disable-output-escaping="yes">
    document.write('&lt;link rel="stylesheet" type="text/css" href="</xsl:text>
	<xsl:value-of select="$theme-path"/>
	<xsl:text>/</xsl:text>
	<xsl:value-of select="."/>
  <xsl:text disable-output-escaping="yes">" /&gt;');</xsl:text>
  <xsl:text disable-output-escaping="yes">
    /* ]]&gt; */
  </xsl:text>
</script>
			</xsl:for-each>			
			
			<!-- Add syndication feeds -->
			<xsl:for-each select="/dri:document/dri:meta/dri:pageMeta/dri:metadata[@element='feed']">
				<link rel="alternate" type="application">
					<xsl:attribute name="type">
						<xsl:text>application/</xsl:text>
						<xsl:value-of select="@qualifier"/>
					</xsl:attribute>
					<xsl:attribute name="href">
						<xsl:value-of select="."/>
					</xsl:attribute>
				</link>
			</xsl:for-each>
			
			<!--  Add OpenSearch auto-discovery link -->
			<xsl:if test="/dri:document/dri:meta/dri:pageMeta/dri:metadata[@element='opensearch'][@qualifier='shortName']">
				<link rel="search" type="application/opensearchdescription+xml">
					<xsl:attribute name="href">
						<xsl:value-of select="/dri:document/dri:meta/dri:pageMeta/dri:metadata[@element='request'][@qualifier='scheme']"/>
						<xsl:text>://</xsl:text>
						<xsl:value-of select="/dri:document/dri:meta/dri:pageMeta/dri:metadata[@element='request'][@qualifier='serverName']"/>
						<xsl:text>:</xsl:text>
						<xsl:value-of select="/dri:document/dri:meta/dri:pageMeta/dri:metadata[@element='request'][@qualifier='serverPort']"/>
						<xsl:value-of select="$context-path"/>
						<xsl:text>/</xsl:text>
						<xsl:value-of select="/dri:document/dri:meta/dri:pageMeta/dri:metadata[@element='opensearch'][@qualifier='context']"/>
						<xsl:text>description.xml</xsl:text>
					</xsl:attribute>
					<xsl:attribute name="title" >
						<xsl:value-of select="/dri:document/dri:meta/dri:pageMeta/dri:metadata[@element='opensearch'][@qualifier='shortName']"/>
					</xsl:attribute>
				</link>
			</xsl:if>
			
			<!-- The following javascript removes the default text of empty text areas when they are focused on or submitted -->
			<!-- There is also javascript to disable submitting a form when the 'enter' key is pressed. -->
			<script type="text/javascript">
          //Clear default text of emty text areas on focus
          function tFocus(element)
          {
                  if (element.value == '<i18n:text>xmlui.dri2xhtml.default.textarea.value</i18n:text>'){element.value='';}
          }
          //Clear default text of emty text areas on submit
          function tSubmit(form)
          {
                  var defaultedElements = document.getElementsByTagName("textarea");
                  for (var i=0; i != defaultedElements.length; i++){
                          if (defaultedElements[i].value == '<i18n:text>xmlui.dri2xhtml.default.textarea.value</i18n:text>'){
                                  defaultedElements[i].value='';}}
          }
          //Disable pressing 'enter' key to submit a form (otherwise pressing 'enter' causes a submission to start over)
          function disableEnterKey(e)
          {
               var key;

               if(window.event)
                    key = window.event.keyCode;     //Internet Explorer
               else
                    key = e.which;     //Firefox and Netscape

               if(key == 13)  //if "Enter" pressed, then disable!
                    return false;
               else
                    return true;
          }

          function FnArray()
          {
              this.funcs = new Array;
          }

          FnArray.prototype.add = function(f)
          {
              if( typeof f!= "function" )
              {
                  f = new Function(f);
              }
              this.funcs[this.funcs.length] = f;
          };

          FnArray.prototype.execute = function()
          {
              for( var i=0; i <xsl:text disable-output-escaping="yes">&lt;</xsl:text> this.funcs.length; i++ )
              {
                  this.funcs[i]();
              }
          };

          var runAfterJSImports = new FnArray();
            </script>
			
			<!-- Modernizr enables HTML5 elements & feature detects -->
			<script type="text/javascript">
                <xsl:attribute name="src">
                		<xsl:value-of select="$theme-path"/>
                    <xsl:text>/lib/js/modernizr-1.5.min.js</xsl:text>
                </xsl:attribute>&#160;</script>
			
			<!-- Add the title in -->
			<xsl:variable name="page_title" select="/dri:document/dri:meta/dri:pageMeta/dri:metadata[@element='title']" />
			<title>
				<xsl:text>RiverRun</xsl:text>
				<xsl:if test="$page_title">
					<xsl:text> | </xsl:text>
					<xsl:copy-of select="$page_title/node()" />
				</xsl:if>
			</title>
			
			<!-- Head metadata in item pages -->
			<xsl:if test="/dri:document/dri:meta/dri:pageMeta/dri:metadata[@element='xhtml_head_item']">
				<xsl:value-of select="/dri:document/dri:meta/dri:pageMeta/dri:metadata[@element='xhtml_head_item']"
					disable-output-escaping="yes"/>
			</xsl:if>
			
			<!-- Add all Google Scholar Metadata values -->
			<xsl:for-each select="/dri:document/dri:meta/dri:pageMeta/dri:metadata[substring(@element, 1, 9) = 'citation_']">
				<meta name="{@element}" content="{.}"></meta>
			</xsl:for-each>
			
		</head>
	</xsl:template>


  <!-- 
    The header (distinct from the HTML head element) contains the title,
    subtitle, login box and various placeholders for header images
  -->
  <xsl:template name="buildHeader">
    <div id="ds-header-wrapper">
      <div id="ds-header" class="clearfix">
        
        <a id="ds-header-logo-link">
          <xsl:attribute name="href">
            <xsl:value-of select="/dri:document/dri:meta/dri:pageMeta/dri:metadata[@element='contextPath'][not(@qualifier)]"/>
            <xsl:text>/</xsl:text>
          </xsl:attribute>
          <span id="ds-header-logo">&#160;</span>
          <span id="ds-header-logo-text">RiverRun</span>
        </a>
        
        <h1 class="pagetitle visuallyhidden">
          <xsl:choose>
            <!-- protection against an empty page title -->
            <xsl:when test="not(/dri:document/dri:meta/dri:pageMeta/dri:metadata[@element='title'])">
              <xsl:text> </xsl:text>
            </xsl:when>
            <xsl:otherwise>
              <xsl:copy-of select="/dri:document/dri:meta/dri:pageMeta/dri:metadata[@element='title']/node()"/>
            </xsl:otherwise>
          </xsl:choose>
        </h1>
        
        <h2 class="static-pagetitle visuallyhidden">
          <i18n:text>xmlui.dri2xhtml.structural.head-subtitle</i18n:text>
        </h2>

        <!-- begin list of links in user box -->
        <div id="ds-user-box">
          <p>
            <!-- user logged in? -->
            <xsl:choose>
              <xsl:when test="/dri:document/dri:meta/dri:userMeta/@authenticated = 'yes'">
                <a>
                  <xsl:attribute name="href">
                    <xsl:value-of
                      select="/dri:document/dri:meta/dri:userMeta/dri:metadata[@element='identifier' and @qualifier='url']"/>
                  </xsl:attribute>
                  <i18n:text>xmlui.dri2xhtml.structural.profile</i18n:text>
                  <xsl:value-of select="/dri:document/dri:meta/dri:userMeta/dri:metadata[@element='identifier' and @qualifier='firstName']"/>
                  <xsl:text> </xsl:text>
                  <xsl:value-of select="/dri:document/dri:meta/dri:userMeta/dri:metadata[@element='identifier' and @qualifier='lastName']"/>
                </a>
                <xsl:text> | </xsl:text>
                <a>
                <xsl:attribute name="href">
                  <xsl:value-of select="/dri:document/dri:meta/dri:userMeta/dri:metadata[@element='identifier' and @qualifier='logoutURL']"/>
                </xsl:attribute>
                <i18n:text>xmlui.dri2xhtml.structural.logout</i18n:text>
                </a>
              </xsl:when>
              <xsl:otherwise>
                <!-- not logged in -->
                <a>
                  <xsl:attribute name="href">
                    <xsl:value-of
                      select="/dri:document/dri:meta/dri:userMeta/dri:metadata[@element='identifier' and @qualifier='loginURL']"/>
                  </xsl:attribute>
                  <i18n:text>xmlui.dri2xhtml.structural.login</i18n:text>
                </a>
              </xsl:otherwise>
            </xsl:choose>
            
            <!-- Add a help link -->
            <xsl:text> | </xsl:text>
            <a>
              <!-- @fixme: add help page URL to DRI metadata (see contact, feedback links)-->
              <xsl:attribute name="href">
                <xsl:value-of
                        select="/dri:document/dri:meta/dri:pageMeta/dri:metadata[@element='contextPath'][not(@qualifier)]"/>
                <xsl:text>/help</xsl:text>
              </xsl:attribute>
              <i18n:text>xmlui.dri2xhtml.structural.help</i18n:text>
            </a>
          </p>
        </div><!-- end div#ds-user-box -->
        
      </div> <!-- end div#ds-header -->
    </div> <!-- end div#ds-header-wrapper -->
    
  </xsl:template>
  	
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
                      <!-- @fixme: contact page URL is available in DRI metadata -->
                        <xsl:attribute name="href">
                            <xsl:value-of
                                    select="/dri:document/dri:meta/dri:pageMeta/dri:metadata[@element='contextPath'][not(@qualifier)]"/>
                            <xsl:text>/contact</xsl:text>
                        </xsl:attribute>
                        <i18n:text>xmlui.dri2xhtml.structural.contact-link</i18n:text>
                    </a>
                    <xsl:text> | </xsl:text>
                    <a>
                      <!-- @fixme: feedback page URL is available in DRI metadata -->
                        <xsl:attribute name="href">
                            <xsl:value-of
                                    select="/dri:document/dri:meta/dri:pageMeta/dri:metadata[@element='contextPath'][not(@qualifier)]"/>
                            <xsl:text>/feedback</xsl:text>
                        </xsl:attribute>
                        <i18n:text>xmlui.dri2xhtml.structural.feedback-link</i18n:text>
                    </a>
                    <xsl:text> | </xsl:text>                    
                    <a>
                      <!-- @fixme: add help page URL to DRI -->
                      <xsl:attribute name="href">
                        <xsl:value-of select="/dri:document/dri:meta/dri:pageMeta/dri:metadata[@element='contextPath'][not(@qualifier)]"/>
                        <xsl:text>/help</xsl:text>
                      </xsl:attribute>
                      <i18n:text>xmlui.dri2xhtml.structural.help</i18n:text>
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