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

    <xsl:output indent="yes"/>
	
    <xsl:template name="buildHead">
        <head>
			<!-- @custom begin -->
			<!-- @todo: messages.xml reference -->
            <title>RiverRun | UNB</title>
			<!-- @custom end -->

            <meta http-equiv="Content-Type" content="text/html; charset=UTF-8"/>
            <meta name="Generator">
                <xsl:attribute name="content">
                    <xsl:text>DSpace</xsl:text>
                    <xsl:if test="/dri:document/dri:meta/dri:pageMeta/dri:metadata[@element='dspace'][@qualifier='version']">
                        <xsl:text> </xsl:text>
                        <xsl:value-of select="/dri:document/dri:meta/dri:pageMeta/dri:metadata[@element='dspace'][@qualifier='version']"/>
                    </xsl:if>
                </xsl:attribute>
            </meta>
			<!-- Add stylsheets -->
            <xsl:for-each select="/dri:document/dri:meta/dri:pageMeta/dri:metadata[@element='stylesheet']">
                <link rel="stylesheet" type="text/css">
                    <xsl:attribute name="media">
                        <xsl:value-of select="@qualifier"/>
                    </xsl:attribute>
                    <xsl:attribute name="href">
                        <xsl:value-of select="/dri:document/dri:meta/dri:pageMeta/dri:metadata[@element='contextPath'][not(@qualifier)]"/>
                        <xsl:text>/themes/</xsl:text>
                        <xsl:value-of select="/dri:document/dri:meta/dri:pageMeta/dri:metadata[@element='theme'][@qualifier='path']"/>
                        <xsl:text>/</xsl:text>
                        <xsl:value-of select="."/>
                    </xsl:attribute>
                </link>
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
                                          key = window.event.keyCode; //Internet Explorer
                                     else
                                          key = e.which; //Firefox and Netscape
                                
                                     if(key == 13) //if "Enter" pressed, then disable!
                                          return false;
                                     else
                                          return true;
                                }
            </script>

			
			<!-- Add theme javascipt  -->

            <xsl:for-each select="/dri:document/dri:meta/dri:pageMeta/dri:metadata[@element='javascript'][not(@qualifier)]">
                <script type="text/javascript">
                    <xsl:attribute name="src">
                        <xsl:value-of select="/dri:document/dri:meta/dri:pageMeta/dri:metadata[@element='contextPath'][not(@qualifier)]"/>
                        <xsl:text>/themes/</xsl:text>
                        <xsl:value-of select="/dri:document/dri:meta/dri:pageMeta/dri:metadata[@element='theme'][@qualifier='path']"/>
                        <xsl:text>/</xsl:text>
                        <xsl:value-of select="."/>
                    </xsl:attribute>&#160;
                </script>
            </xsl:for-each>
			
			<!-- add "shared" javascript from static, path is relative to webapp root-->

            <xsl:for-each select="/dri:document/dri:meta/dri:pageMeta/dri:metadata[@element='javascript'][@qualifier='static']">
                <script type="text/javascript">
                    <xsl:attribute name="src">
                        <xsl:value-of select="/dri:document/dri:meta/dri:pageMeta/dri:metadata[@element='contextPath'][not(@qualifier)]"/>
                        <xsl:text>/</xsl:text>
                        <xsl:value-of select="."/>
                    </xsl:attribute>&#160;
                </script>
            </xsl:for-each>
			
			
			<!-- Add a google analytics script if the key is present -->

            <xsl:if test="/dri:document/dri:meta/dri:pageMeta/dri:metadata[@element='google'][@qualifier='analytics']">
                <script type="text/javascript">
                    <xsl:text>var gaJsHost = (("https:" == document.location.protocol) ? "https://ssl." : "http://www.");</xsl:text>
                    <xsl:text>document.write(unescape("%3Cscript src='" + gaJsHost + "google-analytics.com/ga.js' type='text/javascript'%3E%3C/script%3E"));</xsl:text>
                </script>
                <script type="text/javascript">
                    <xsl:text>try {</xsl:text>
                    <xsl:text>var pageTracker = _gat._getTracker("</xsl:text>
                    <xsl:value-of select="/dri:document/dri:meta/dri:pageMeta/dri:metadata[@element='google'][@qualifier='analytics']"/>
                    <xsl:text>");</xsl:text>
                    <xsl:text>pageTracker._trackPageview();</xsl:text>
                    <xsl:text>} catch(err) {}</xsl:text>
                </script>
            </xsl:if>

			
			
			<!-- Add the title in -->

            <xsl:variable name="page_title" select="/dri:document/dri:meta/dri:pageMeta/dri:metadata[@element='title']" />
            <title>
                <xsl:choose>
                    <xsl:when test="not($page_title)">

                        <xsl:text>  </xsl:text>

                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:copy-of select="$page_title/node()" />
                    </xsl:otherwise>
                </xsl:choose>
            </title>
			
			<!-- Head metadata in item pages -->
            <xsl:if test="/dri:document/dri:meta/dri:pageMeta/dri:metadata[@element='xhtml_head_item']">
                <xsl:value-of select="/dri:document/dri:meta/dri:pageMeta/dri:metadata[@element='xhtml_head_item']"
					disable-output-escaping="yes"/>
            </xsl:if>
			

        </head>
    </xsl:template>


    <!-- The header (distinct from the HTML head element) contains the title, subtitle, login box and various
        placeholders for header images -->

    <xsl:template name="buildHeader">
        <div id="ds-header">
            <a>
                <xsl:attribute name="href">
                    <xsl:value-of select="/dri:document/dri:meta/dri:pageMeta/dri:metadata[@element='contextPath'][not(@qualifier)]"/>
                    <xsl:text>/</xsl:text>
                </xsl:attribute>
                <span id="ds-header-logo">&#160;</span>
            </a>
            <h1 class="pagetitle">
                <xsl:choose>
                        <!-- protectiotion against an empty page title -->
                    <xsl:when test="not(/dri:document/dri:meta/dri:pageMeta/dri:metadata[@element='title'])">
                        <xsl:text> </xsl:text>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:copy-of select="/dri:document/dri:meta/dri:pageMeta/dri:metadata[@element='title']/node()"/>
                    </xsl:otherwise>
                </xsl:choose>

            </h1>
            <h2 class="static-pagetitle">
                <i18n:text>xmlui.dri2xhtml.structural.head-subtitle</i18n:text>
            </h2>


            <ul id="ds-trail">
                <xsl:choose>
                    <xsl:when test="count(/dri:document/dri:meta/dri:pageMeta/dri:trail) = 0">
                        <li class="ds-trail-link first-link"> - </li>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:apply-templates select="/dri:document/dri:meta/dri:pageMeta/dri:trail"/>
                    </xsl:otherwise>
                </xsl:choose>
            </ul>



            <div id="ds-user-box">
                <p>
                    <xsl:choose>

                        <xsl:when test="/dri:document/dri:meta/dri:userMeta/@authenticated = 'yes'">
                            <a>
                                <xsl:attribute name="href">
                                    <xsl:value-of select="/dri:document/dri:meta/dri:userMeta/
                                        dri:metadata[@element='identifier' and @qualifier='url']"/>
                                </xsl:attribute>
                                <i18n:text>xmlui.dri2xhtml.structural.profile</i18n:text>
                                <xsl:value-of select="/dri:document/dri:meta/dri:userMeta/
                                    dri:metadata[@element='identifier' and @qualifier='firstName']"/>
                                <xsl:text> </xsl:text>
                                <xsl:value-of select="/dri:document/dri:meta/dri:userMeta/
                                    dri:metadata[@element='identifier' and @qualifier='lastName']"/>

                            </a>
                            <xsl:text> | </xsl:text>
                            <a>
                                <xsl:attribute name="href">
                                    <xsl:value-of select="/dri:document/dri:meta/dri:userMeta/
                                        dri:metadata[@element='identifier' and @qualifier='logoutURL']"/>
                                </xsl:attribute>
                                <i18n:text>xmlui.dri2xhtml.structural.logout</i18n:text>
                            </a>
                        </xsl:when>
                        <xsl:otherwise>
                            <a>
                                <xsl:attribute name="href">
                                    <xsl:value-of select="/dri:document/dri:meta/dri:userMeta/
                                        dri:metadata[@element='identifier' and @qualifier='loginURL']"/>
                                </xsl:attribute>
                                <i18n:text>xmlui.dri2xhtml.structural.login</i18n:text>
                            </a>
                        </xsl:otherwise>
                    </xsl:choose>
                    <xsl:text> | </xsl:text>
                    <a>
                    <xsl:attribute name="href">
                        <xsl:value-of select="/dri:document/dri:meta/dri:pageMeta/dri:metadata[@element='contextPath'][not(@qualifier)]"/>
                        <xsl:text>/help</xsl:text>
                        </xsl:attribute>
                        <i18n:text>xmlui.dri2xhtml.structural.help</i18n:text>
                    </a>                    
                </p>
            </div>

        </div>
    </xsl:template>
	
	<!--
		Template modified to correct layout issues in search box.
	-->
	<xsl:template match="dri:options">
		<div id="ds-options">
			<h3 id="ds-search-option-head" class="ds-option-set-head">
				<i18n:text>xmlui.dri2xhtml.structural.search</i18n:text>
			</h3>
			<div id="ds-search-option" class="ds-option-set">
				<!-- 
					The form, complete with a text box and a button, is built from
					attributes of <pageMeta> children. 
				-->
				<form id="ds-search-form" method="post">
					<xsl:attribute name="action">
						<xsl:value-of select="/dri:document/dri:meta/dri:pageMeta/dri:metadata[@element='search'][@qualifier='simpleURL']"/>
					</xsl:attribute>

					<fieldset>
						<input class="ds-text-field " type="text">
							<xsl:attribute name="name">
								<xsl:value-of select="/dri:document/dri:meta/dri:pageMeta/dri:metadata[@element='search'][@qualifier='queryField']"/>
							</xsl:attribute>
						</input>
						<input class="ds-button-field " name="submit" type="submit" i18n:attr="value" value="xmlui.general.go" >
							<xsl:attribute name="onclick">
								<xsl:text>
                                    var radio = document.getElementById(&quot;ds-search-form-scope-container&quot;);
                                    if (radio != undefined &amp;&amp; radio.checked)
                                    {
                                    var form = document.getElementById(&quot;ds-search-form&quot;);
                                    form.action=
                                </xsl:text>
								<xsl:text>&quot;</xsl:text>
								<xsl:value-of select="/dri:document/dri:meta/dri:pageMeta/dri:metadata[@element='contextPath']"/>
								<xsl:text>/handle/&quot; + radio.value + &quot;/search&quot; ; </xsl:text>
								<xsl:text>
                                    }
                                </xsl:text>
							</xsl:attribute>
						</input>
						<!-- 
							If the container (i.e., collection or community) of the current
							object is known, provide option to restrict search to the container.
						-->
						<xsl:if test="/dri:document/dri:meta/dri:pageMeta/dri:metadata[@element='focus'][@qualifier='container']">
							<br/>
							<label>
								<input id="ds-search-form-scope-all" class="ds-radio-field" type="radio" name="scope" value="" checked="checked"/>
								<i18n:text>xmlui.dri2xhtml.structural.search</i18n:text>
							</label>
							<br/>
							<label>
								<input id="ds-search-form-scope-container" class="ds-radio-field" type="radio" name="scope">
									<xsl:attribute name="value">
										<xsl:value-of select="substring-after(/dri:document/dri:meta/dri:pageMeta/dri:metadata[@element='focus'][@qualifier='container'],':')"/>
									</xsl:attribute>
								</input>
								<xsl:choose>
									<xsl:when test="/dri:document/dri:meta/dri:pageMeta/dri:metadata[@element='focus'][@qualifier='containerType']/text() = 'type:community'">
										<i18n:text>xmlui.dri2xhtml.structural.search-in-community</i18n:text>
									</xsl:when>
									<xsl:otherwise>
										<i18n:text>xmlui.dri2xhtml.structural.search-in-collection</i18n:text>
									</xsl:otherwise>
								</xsl:choose>
							</label>
						</xsl:if>
						
					</fieldset>
				</form>
				<!-- 
					The "Advanced search" link, to be perched underneath the search box
				-->
				<a>
					<xsl:attribute name="href">
						<xsl:value-of select="/dri:document/dri:meta/dri:pageMeta/dri:metadata[@element='search'][@qualifier='advancedURL']"/>
					</xsl:attribute>
					<i18n:text>xmlui.dri2xhtml.structural.search-advanced</i18n:text>
				</a>
			</div>
			
			<!-- 
				Once the search box is built, the other parts of the options are added
			-->
			<xsl:apply-templates />
		</div>
	</xsl:template>
	
	
	
	
    <xsl:template name="buildFooter">
        <div id="ds-footer">
            <div id="ds-footer-logo-block">
                <div id="ds-footer-logo-lib" class="ds-footer-logo">
                    <a href="http://lib.unb.ca" title="UNB Libraries">
                        <img src="/xmlui/themes/ETCRiverRun/images/unb-libraries-logo.gif" alt="UNB Libraries"/>
                    </a>
                </div>
                <div id="ds-footer-logo-etc" class="ds-footer-logo">
                    <a href="http://lib.unb.ca/etc" title="Electronic Text Centre">
                        <img src="/xmlui/themes/ETCRiverRun/images/etc-logo-small.jpg" alt="Electronic Text Centre"/>
                    </a>
                </div>
            </div>
            <div id="ds-footer-text">
                <i18n:text>xmlui.dri2xhtml.structural.footer-promotional</i18n:text>
            </div>
            <div id="ds-footer-links">
                <a>
                    <xsl:attribute name="href">
                        <xsl:value-of select="/dri:document/dri:meta/dri:pageMeta/dri:metadata[@element='contextPath'][not(@qualifier)]"/>
                        <xsl:text>/help</xsl:text>
                    </xsl:attribute>
                    <i18n:text>xmlui.dri2xhtml.structural.help</i18n:text>
                </a>
                <xsl:text> | </xsl:text>
                <a>
                    <xsl:attribute name="href">
                        <xsl:value-of select="/dri:document/dri:meta/dri:pageMeta/dri:metadata[@element='contextPath'][not(@qualifier)]"/>
                        <xsl:text>/contact</xsl:text>
                    </xsl:attribute>
                    <i18n:text>xmlui.dri2xhtml.structural.contact-link</i18n:text>
                </a>
                <xsl:text> | </xsl:text>
                <a>
                    <xsl:attribute name="href">
                        <xsl:value-of select="/dri:document/dri:meta/dri:pageMeta/dri:metadata[@element='contextPath'][not(@qualifier)]"/>
                        <xsl:text>/feedback</xsl:text>
                    </xsl:attribute>
                    <i18n:text>xmlui.dri2xhtml.structural.feedback-link</i18n:text>
                </a>
            </div>
          <!--Invisible link to HTML sitemap (for search engines) -->
            <a>
                <xsl:attribute name="href">
                    <xsl:value-of select="/dri:document/dri:meta/dri:pageMeta/dri:metadata[@element='contextPath'][not(@qualifier)]"/>
                    <xsl:text>/htmlmap</xsl:text>
                </xsl:attribute>
            </a>
        </div>
    </xsl:template>
	
	<!--
		The default version of this template applies a style attribute with a variable
		font-size property to h[#] elements.  This version removes the attribute.
	-->
    <xsl:template match="dri:div/dri:head" priority="3">
        <xsl:variable name="head_count" select="count(ancestor::dri:div)"/>
        <xsl:element name="h{$head_count}">
            <xsl:call-template name="standardAttributes">
                <xsl:with-param name="class">ds-div-head</xsl:with-param>
            </xsl:call-template>
            <xsl:apply-templates />
        </xsl:element>
    </xsl:template>

</xsl:stylesheet>
