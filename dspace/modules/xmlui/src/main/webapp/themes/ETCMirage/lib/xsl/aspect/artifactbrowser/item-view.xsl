<!--
	ETCMirage customizations to item view constructed by Mirage base theme.
	
	* Modifies named template itemSummaryView-DIM-fields to fix 
		https://jira.duraspace.org/browse/DS-967
	
	* Adds a named template, dimField, that generates a row of metadata in the
		table presented on detailed item view. dimField can be invoked with modified
	  content from matching templates, as needed.
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

	<xsl:template name="itemSummaryView-DIM-fields">
		<xsl:param name="clause" select="'1'"/>
		<xsl:param name="phase" select="'even'"/>
		<xsl:variable name="otherPhase">
			<xsl:choose>
				<xsl:when test="$phase = 'even'">
					<xsl:text>odd</xsl:text>
				</xsl:when>
				<xsl:otherwise>
					<xsl:text>even</xsl:text>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>

		<xsl:choose>
			<!-- Title row -->
			<xsl:when test="$clause = 1">

				<xsl:choose>
					<xsl:when test="count(dim:field[@element='title'][not(@qualifier)]) &gt; 1">
						<!-- display first title as h1 -->
						<h1>
							<xsl:value-of select="dim:field[@element='title'][not(@qualifier)][1]/node()"/>
						</h1>
						<div class="simple-item-view-other">
							<span class="bold"><i18n:text>xmlui.dri2xhtml.METS-1.0.item-title</i18n:text>:</span>
							<span>
								<xsl:for-each select="dim:field[@element='title'][not(@qualifier)]">
									<xsl:value-of select="./node()"/>
									<xsl:if
										test="count(following-sibling::dim:field[@element='title'][not(@qualifier)]) != 0">
										<xsl:text>; </xsl:text>
										<br/>
									</xsl:if>
								</xsl:for-each>
							</span>
						</div>
					</xsl:when>
					<xsl:when test="count(dim:field[@element='title'][not(@qualifier)]) = 1">
						<h1>
							<xsl:value-of select="dim:field[@element='title'][not(@qualifier)][1]/node()"/>
						</h1>
					</xsl:when>
					<xsl:otherwise>
						<h1>
							<i18n:text>xmlui.dri2xhtml.METS-1.0.no-title</i18n:text>
						</h1>
					</xsl:otherwise>
				</xsl:choose>
				<xsl:call-template name="itemSummaryView-DIM-fields">
					<xsl:with-param name="clause" select="($clause + 1)"/>
					<xsl:with-param name="phase" select="$otherPhase"/>
				</xsl:call-template>
			</xsl:when>

			<!-- Author(s) row -->
			<xsl:when
				test="$clause = 2 and (dim:field[@element='contributor'][@qualifier='author'] or dim:field[@element='creator'] or dim:field[@element='contributor'])">
				<div class="simple-item-view-authors">
					<xsl:choose>
						<xsl:when test="dim:field[@element='contributor'][@qualifier='author']">
							<xsl:for-each select="dim:field[@element='contributor'][@qualifier='author']">
								<span>
									<xsl:if test="@authority">
										<xsl:attribute name="class">
											<xsl:text>ds-dc_contributor_author-authority</xsl:text>
										</xsl:attribute>
									</xsl:if>
									<xsl:copy-of select="node()"/>
								</span>
								<xsl:if
									test="count(following-sibling::dim:field[@element='contributor'][@qualifier='author']) != 0">
									<xsl:text>; </xsl:text>
								</xsl:if>
							</xsl:for-each>
						</xsl:when>
						<xsl:when test="dim:field[@element='creator']">
							<xsl:for-each select="dim:field[@element='creator']">
								<xsl:copy-of select="node()"/>
								<xsl:if test="count(following-sibling::dim:field[@element='creator']) != 0">
									<xsl:text>; </xsl:text>
								</xsl:if>
							</xsl:for-each>
						</xsl:when>
						<xsl:when test="dim:field[@element='contributor']">
							<xsl:for-each select="dim:field[@element='contributor']">
								<xsl:copy-of select="node()"/>
								<xsl:if test="count(following-sibling::dim:field[@element='contributor']) != 0">
									<xsl:text>; </xsl:text>
								</xsl:if>
							</xsl:for-each>
						</xsl:when>
						<xsl:otherwise>
							<i18n:text>xmlui.dri2xhtml.METS-1.0.no-author</i18n:text>
						</xsl:otherwise>
					</xsl:choose>
				</div>
				<xsl:call-template name="itemSummaryView-DIM-fields">
					<xsl:with-param name="clause" select="($clause + 1)"/>
					<xsl:with-param name="phase" select="$otherPhase"/>
				</xsl:call-template>
			</xsl:when>

			<!-- identifier.uri row -->
			<xsl:when test="$clause = 3 and (dim:field[@element='identifier' and @qualifier='uri'])">
				<div class="simple-item-view-other">
					<span class="bold"><i18n:text>xmlui.dri2xhtml.METS-1.0.item-uri</i18n:text>:</span>
					<span>
						<xsl:for-each select="dim:field[@element='identifier' and @qualifier='uri']">
							<a>
								<xsl:attribute name="href">
									<xsl:copy-of select="./node()"/>
								</xsl:attribute>
								<xsl:copy-of select="./node()"/>
							</a>
							<xsl:if
								test="count(following-sibling::dim:field[@element='identifier' and @qualifier='uri']) != 0">
								<br/>
							</xsl:if>
						</xsl:for-each>
					</span>
				</div>
				<xsl:call-template name="itemSummaryView-DIM-fields">
					<xsl:with-param name="clause" select="($clause + 1)"/>
					<xsl:with-param name="phase" select="$otherPhase"/>
				</xsl:call-template>
			</xsl:when>

			<!-- date.issued row -->
			<xsl:when test="$clause = 4 and (dim:field[@element='date' and @qualifier='issued'])">
				<div class="simple-item-view-other">
					<span class="bold"><i18n:text>xmlui.dri2xhtml.METS-1.0.item-date</i18n:text>:</span>
					<span>
						<xsl:for-each select="dim:field[@element='date' and @qualifier='issued']">
							<xsl:copy-of select="substring(./node(),1,10)"/>
							<xsl:if
								test="count(following-sibling::dim:field[@element='date' and @qualifier='issued']) != 0">
								<br/>
							</xsl:if>
						</xsl:for-each>
					</span>
				</div>
				<xsl:call-template name="itemSummaryView-DIM-fields">
					<xsl:with-param name="clause" select="($clause + 1)"/>
					<xsl:with-param name="phase" select="$otherPhase"/>
				</xsl:call-template>
			</xsl:when>

			<!-- Abstract row -->
			<!-- 
				Modified to fix https://jira.duraspace.org/browse/DS-967, reported in
				DSpace 1.7.1
			-->
			<xsl:when test="$clause = 5 and (dim:field[@element='description' and @qualifier='abstract']) and normalize-space(node())">
				<div class="simple-item-view-description">
					<h3><i18n:text>xmlui.dri2xhtml.METS-1.0.item-abstract</i18n:text>:</h3>
					<div>
						<xsl:if test="count(dim:field[@element='description' and @qualifier='abstract']) &gt; 1">
							<div class="spacer">&#160;</div>
						</xsl:if>
						<xsl:for-each select="dim:field[@element='description' and @qualifier='abstract']">
							<xsl:copy-of select="./node()"/>
							<xsl:if
								test="count(following-sibling::dim:field[@element='description' and @qualifier='abstract']) != 0">
								<div class="spacer">&#160;</div>
							</xsl:if>
						</xsl:for-each>
						<xsl:if test="count(dim:field[@element='description' and @qualifier='abstract']) &gt; 1">
							<div class="spacer">&#160;</div>
						</xsl:if>
					</div>
				</div>
				<xsl:call-template name="itemSummaryView-DIM-fields">
					<xsl:with-param name="clause" select="($clause + 1)"/>
					<xsl:with-param name="phase" select="$otherPhase"/>
				</xsl:call-template>
			</xsl:when>

			<!-- Description row -->
			<xsl:when test="$clause = 6 and (dim:field[@element='description' and not(@qualifier)])">
				<div class="simple-item-view-description">
					<h3 class="bold"><i18n:text>xmlui.dri2xhtml.METS-1.0.item-description</i18n:text>:</h3>
					<div>
						<xsl:if
							test="count(dim:field[@element='description' and not(@qualifier)]) &gt; 1 and not(count(dim:field[@element='description' and @qualifier='abstract']) &gt; 1)">
							<div class="spacer">&#160;</div>
						</xsl:if>
						<xsl:for-each select="dim:field[@element='description' and not(@qualifier)]">
							<xsl:copy-of select="./node()"/>
							<xsl:if
								test="count(following-sibling::dim:field[@element='description' and not(@qualifier)]) != 0">
								<div class="spacer">&#160;</div>
							</xsl:if>
						</xsl:for-each>
						<xsl:if test="count(dim:field[@element='description' and not(@qualifier)]) &gt; 1">
							<div class="spacer">&#160;</div>
						</xsl:if>
					</div>
				</div>
				<xsl:call-template name="itemSummaryView-DIM-fields">
					<xsl:with-param name="clause" select="($clause + 1)"/>
					<xsl:with-param name="phase" select="$otherPhase"/>
				</xsl:call-template>
			</xsl:when>

			<xsl:when test="$clause = 7 and $ds_item_view_toggle_url != ''">
				<p class="ds-paragraph item-view-toggle item-view-toggle-bottom">
					<a>
						<xsl:attribute name="href">
							<xsl:value-of select="$ds_item_view_toggle_url"/>
						</xsl:attribute>
						<i18n:text>xmlui.ArtifactBrowser.ItemViewer.show_full</i18n:text>
					</a>
				</p>
			</xsl:when>

			<!-- recurse without changing phase if we didn't output anything -->
			<xsl:otherwise>
				<!-- IMPORTANT: This test should be updated if clauses are added! -->
				<xsl:if test="$clause &lt; 8">
					<xsl:call-template name="itemSummaryView-DIM-fields">
						<xsl:with-param name="clause" select="($clause + 1)"/>
						<xsl:with-param name="phase" select="$phase"/>
					</xsl:call-template>
				</xsl:if>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>


	<!-- 
		dimField
		
		parameters:
			value:  Content to be displayed in metadata table row; default value is 
							content of current node.
							
		Invoked with modified content in $value parameter by templates matching
		DIM metadata elements that require special handling.  Invoked without
		parameters by all other templates matching DIM metadata elements, for 
		generic handling.
	-->
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

	<!-- 
		Special handling for dc.identifier.uri: display as link
	-->
	<xsl:template match="dim:field[@mdschema='dc' and @element='identifier' and @qualifier='uri']"
		mode="itemDetailView-DIM">
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

	<!-- 
		Special handling for dc.identifier.doi: display as link
	-->
	<xsl:template match="dim:field[@mdschema='dc' and @element='identifier' and @qualifier='doi']"
		mode="itemDetailView-DIM">

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

	<!-- 
		All remaining DIM fields
	-->
	<xsl:template match="dim:field" mode="itemDetailView-DIM">
		<xsl:call-template name="dimField"/>
	</xsl:template>



</xsl:stylesheet>
