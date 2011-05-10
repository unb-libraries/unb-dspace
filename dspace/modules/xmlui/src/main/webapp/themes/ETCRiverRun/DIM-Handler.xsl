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
	
	<!-- A community rendered in the summaryList pattern. Encountered on the community-list and on 
		on the front page. -->
	<xsl:template name="communitySummaryList-DIM">
		<xsl:variable name="data" select="./mets:dmdSec/mets:mdWrap/mets:xmlData/dim:dim"/>
		<!-- @custom begin -->
		<!-- @todo fix the paths; they'll break on live server -->
		<p class="ListPlus">
			<img class="collapseicon" src="/xmlui/themes/Reference/images/arrow_right.png"/>
		</p>
		<p class="ListMinus">
			<img class="collapseicon" src="/xmlui/themes/Reference/images/arrow_down.png"/>
		</p>
		<!-- @custom end -->
		<span class="bold">
			<!-- @custom begin -->
			<!-- class added -->
			<a href="{@OBJID}" class="communitySummaryListAnchorDIM">
			<!-- @custom end -->
				<xsl:choose>
					<xsl:when test="string-length($data/dim:field[@element='title'][1]) &gt; 0">
						<xsl:value-of select="$data/dim:field[@element='title'][1]"/>
					</xsl:when>
					<xsl:otherwise>
						<i18n:text>xmlui.dri2xhtml.METS-1.0.no-title</i18n:text>
					</xsl:otherwise>
				</xsl:choose>
			</a>
			<!--Display community strengths (item counts) if they exist-->
			<xsl:if
				test="string-length($data/dim:field[@element='format'][@qualifier='extent'][1]) &gt; 0">
				<xsl:text> [</xsl:text>
				<xsl:value-of select="$data/dim:field[@element='format'][@qualifier='extent'][1]"/>
				<xsl:text>]</xsl:text>
			</xsl:if>
		</span>
	</xsl:template>
		
	<!-- render each field on a row, alternating phase between odd and even -->
	<!-- recursion needed since not every row appears for each Item. -->
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
			
			<!--  artifact?
				<tr class="ds-table-row odd">
				<td><span class="bold"><i18n:text>xmlui.dri2xhtml.METS-1.0.item-preview</i18n:text>:</span></td>
				<td>
				<xsl:choose>
				<xsl:when test="mets:fileSec/mets:fileGrp[@USE='THUMBNAIL']">
				<a class="image-link">
				<xsl:attribute name="href"><xsl:value-of select="@OBJID"/></xsl:attribute>
				<img alt="Thumbnail">
				<xsl:attribute name="src">
				<xsl:value-of select="mets:fileSec/mets:fileGrp[@USE='THUMBNAIL']/
				mets:file/mets:FLocat[@LOCTYPE='URL']/@xlink:href"/>
				</xsl:attribute>
				</img>
				</a>
				</xsl:when>
				<xsl:otherwise>
				<i18n:text>xmlui.dri2xhtml.METS-1.0.no-preview</i18n:text>
				</xsl:otherwise>
				</xsl:choose>
				</td>
				</tr>-->
			
			<!-- Title row -->
			<xsl:when test="$clause = 1">
				<tr class="ds-table-row {$phase}">
					<td>
						<span class="bold"><i18n:text>xmlui.dri2xhtml.METS-1.0.item-title</i18n:text>: </span>
					</td>
					<td>
						<span class="Z3988">
							<xsl:attribute name="title">
								<xsl:call-template name="renderCOinS"/>
							</xsl:attribute>
							<xsl:choose>
								<xsl:when test="count(dim:field[@element='title'][not(@qualifier)]) &gt; 1">
									<xsl:for-each select="dim:field[@element='title'][not(@qualifier)]">
										<xsl:value-of select="./node()"/>
										<xsl:if
											test="count(following-sibling::dim:field[@element='title'][not(@qualifier)]) != 0">
											<xsl:text>; </xsl:text>
											<br/>
										</xsl:if>
									</xsl:for-each>
								</xsl:when>
								<xsl:when test="count(dim:field[@element='title'][not(@qualifier)]) = 1">
									<xsl:value-of select="dim:field[@element='title'][not(@qualifier)][1]/node()"/>
								</xsl:when>
								<xsl:otherwise>
									<i18n:text>xmlui.dri2xhtml.METS-1.0.no-title</i18n:text>
								</xsl:otherwise>
							</xsl:choose>
						</span>
					</td>
				</tr>
				<xsl:call-template name="itemSummaryView-DIM-fields">
					<xsl:with-param name="clause" select="($clause + 1)"/>
					<xsl:with-param name="phase" select="$otherPhase"/>
				</xsl:call-template>
			</xsl:when>
			
			<!-- Author(s) row -->
			<xsl:when
				test="$clause = 2 and (dim:field[@element='contributor'][@qualifier='author'] or dim:field[@element='creator'] or dim:field[@element='contributor'])">
				<tr class="ds-table-row {$phase}">
					<td>
						<span class="bold"><i18n:text>xmlui.dri2xhtml.METS-1.0.item-author</i18n:text>:</span>
					</td>
					<td>
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
					</td>
				</tr>
				<xsl:call-template name="itemSummaryView-DIM-fields">
					<xsl:with-param name="clause" select="($clause + 1)"/>
					<xsl:with-param name="phase" select="$otherPhase"/>
				</xsl:call-template>
			</xsl:when>
			
			<!-- Abstract row -->
			<xsl:when test="$clause = 3 and (dim:field[@element='description' and @qualifier='abstract'])">
				<tr class="ds-table-row {$phase}">
					<td>
						<span class="bold"><i18n:text>xmlui.dri2xhtml.METS-1.0.item-abstract</i18n:text>:</span>
					</td>
					<td>
						<xsl:if test="count(dim:field[@element='description' and @qualifier='abstract']) &gt; 1">
							<hr class="metadata-seperator"/>
						</xsl:if>
						<xsl:for-each select="dim:field[@element='description' and @qualifier='abstract']">
							<xsl:copy-of select="./node()"/>
							<xsl:if
								test="count(following-sibling::dim:field[@element='description' and @qualifier='abstract']) != 0">
								<hr class="metadata-seperator"/>
							</xsl:if>
						</xsl:for-each>
						<xsl:if test="count(dim:field[@element='description' and @qualifier='abstract']) &gt; 1">
							<hr class="metadata-seperator"/>
						</xsl:if>
					</td>
				</tr>
				<xsl:call-template name="itemSummaryView-DIM-fields">
					<xsl:with-param name="clause" select="($clause + 1)"/>
					<xsl:with-param name="phase" select="$otherPhase"/>
				</xsl:call-template>
			</xsl:when>
			
			<!-- Description row -->
			<xsl:when test="$clause = 4 and (dim:field[@element='description' and not(@qualifier)])">
				<tr class="ds-table-row {$phase}">
					<td>
						<span class="bold"
							><i18n:text>xmlui.dri2xhtml.METS-1.0.item-description</i18n:text>:</span>
					</td>
					<td>
						<xsl:if
							test="count(dim:field[@element='description' and not(@qualifier)]) &gt; 1 and not(count(dim:field[@element='description' and @qualifier='abstract']) &gt; 1)">
							<hr class="metadata-seperator"/>
						</xsl:if>
						<xsl:for-each select="dim:field[@element='description' and not(@qualifier)]">
							<xsl:copy-of select="./node()"/>
							<xsl:if
								test="count(following-sibling::dim:field[@element='description' and not(@qualifier)]) != 0">
								<hr class="metadata-seperator"/>
							</xsl:if>
						</xsl:for-each>
						<xsl:if test="count(dim:field[@element='description' and not(@qualifier)]) &gt; 1">
							<hr class="metadata-seperator"/>
						</xsl:if>
					</td>
				</tr>
				<xsl:call-template name="itemSummaryView-DIM-fields">
					<xsl:with-param name="clause" select="($clause + 1)"/>
					<xsl:with-param name="phase" select="$otherPhase"/>
				</xsl:call-template>
			</xsl:when>
			
			
			<!-- identifier.uri row -->
			<xsl:when test="$clause = 5 and (dim:field[@element='identifier' and @qualifier='uri'])">
				<tr class="ds-table-row {$phase}">
					<td>
						<span class="bold"><i18n:text>xmlui.dri2xhtml.METS-1.0.item-uri</i18n:text>:</span>
					</td>
					<td>
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
						
						
						<!-- @custom begin -->
						<xsl:for-each select="dim:field[@element='identifier'][not(@qualifier)]">
							<br/>
							<a>
								<xsl:attribute name="href">
									<xsl:copy-of select="./node()"/>
								</xsl:attribute>
								<xsl:copy-of select="./node()"/>
							</a>
						</xsl:for-each>
						<!-- @custom end -->
					</td>
				</tr>
				<xsl:call-template name="itemSummaryView-DIM-fields">
					<xsl:with-param name="clause" select="($clause + 1)"/>
					<xsl:with-param name="phase" select="$otherPhase"/>
				</xsl:call-template>
			</xsl:when>
			
			
			<!-- date.issued row -->
			<xsl:when test="$clause = 6 and (dim:field[@element='date' and @qualifier='issued'])">
				<tr class="ds-table-row {$phase}">
					<td>
						<span class="bold"><i18n:text>xmlui.dri2xhtml.METS-1.0.item-date</i18n:text>:</span>
					</td>
					<td>
						<xsl:for-each select="dim:field[@element='date' and @qualifier='issued']">
							<xsl:copy-of select="substring(./node(),1,10)"/>
							<xsl:if
								test="count(following-sibling::dim:field[@element='date' and @qualifier='issued']) != 0">
								<br/>
							</xsl:if>
						</xsl:for-each>
					</td>
				</tr>
				<xsl:call-template name="itemSummaryView-DIM-fields">
					<xsl:with-param name="clause" select="($clause + 1)"/>
					<xsl:with-param name="phase" select="$otherPhase"/>
				</xsl:call-template>
			</xsl:when>
			
			<!-- recurse without changing phase if we didn't output anything -->
			<xsl:otherwise>
				<!-- IMPORTANT: This test should be updated if clauses are added! -->
				<xsl:if test="$clause &lt; 7">
					<xsl:call-template name="itemSummaryView-DIM-fields">
						<xsl:with-param name="clause" select="($clause + 1)"/>
						<xsl:with-param name="phase" select="$phase"/>
					</xsl:call-template>
				</xsl:if>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	
</xsl:stylesheet>
