<xsl:stylesheet xmlns="http://www.w3.org/1999/xhtml" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:mei="http://www.music-encoding.org/ns/mei" xmlns:xlink="http://www.w3.org/1999/xlink" version="2.0">
    <xsl:output method="xhtml" encoding="UTF-8" indent="yes"/>
    <xsl:include href="linking.xsl"/>
    <xsl:template match="/">
        <div>
            <table border="0" width="100%">
                <tr>
                    <th/>
                    <th/>
                </tr>
                
                <xsl:if test="exists(//mei:titleStmt/mei:title/mei:titlePart[@type = 'sub'])">
                    <tr>
                        <td>Untertitel:</td>
                        <td>
                            <xsl:value-of select="//mei:titleStmt/mei:title[@type ='uniform' and @xml:lang='de']/mei:titlePart[@type = 'sub']/text()"/>
                        </td>
                    </tr>
                </xsl:if>
                <xsl:if test="not(//mei:titleStmt/mei:title/mei:titlePart[@type = 'desc']/data(.) = '')">
                    <tr>
                        <td>Werkbeschreibung:</td>
                        <td>
                            <xsl:value-of select="//mei:titleStmt/mei:title/mei:titlePart[@type = 'desc' and @xml:lang = 'de']"/>
                        </td>
                    </tr>
                </xsl:if>
                <xsl:if test="not(//mei:workList/mei:work/mei:title/mei:titlePart[@type = 'mainAlt']/data(.) = '')">
                    <tr>
                        <td>Alternativer Titel:</td>
                        <td>
                            <xsl:value-of select="//mei:workList/mei:work/mei:title/mei:titlePart[@type = 'mainAlt']"/>
                        </td>
                    </tr>
                </xsl:if>
                <xsl:if test="not(//mei:workList/mei:work/mei:title/mei:titlePart[@type = 'subAlt']/data(.) = '')">
                    <tr>
                        <td>Alternativer Untertitel:</td>
                        <td>
                            <xsl:value-of select="//mei:titleStmt/mei:title/mei:titlePart[@type = 'subAlt']"/>
                        </td>
                    </tr>
                </xsl:if>
                
                <xsl:if test="not(exists(//mei:term[@type = 'source' and @subtype = 'special' and contains(., 'Sammelquelle')]))">
                    <xsl:if test="not(//mei:titleStmt/mei:composer = '')">
                        <tr>
                            <td>Komponist:</td>
                            <td><a href="{concat($registerRootPerson,//mei:workList/mei:work/mei:composer/@xml:id,'.xml')}" target="_blank"><xsl:value-of select="//mei:workList/mei:work/mei:composer"/></a></td>
                        </tr>
                    </xsl:if>
                    <xsl:if test="not(//mei:workList/mei:work/mei:lyricist = '')">
                        <tr>
                            <td>Textdichter:</td>
                            <td>
                                <xsl:value-of select="//mei:workList/mei:work/mei:lyricist"/>
                            </td>
                        </tr>
                    </xsl:if>
                </xsl:if>
                <!--<xsl:if test="exists(//mei:term[@type = 'source' and @subtype = 'special' and contains(., 'Sammelquelle')])">
                    <xsl:if test="not(//mei:titleStmt/mei:composer = '')">
                        <tr>
                            <xsl:choose>
                                <xsl:when test="count(//mei:titleStmt/mei:composer) > 1">
                                    <td>Komponist(en):</td>
                                    <td>
                                        <xsl:for-each select="//mei:titleStmt/mei:composer">
                                            <li>
                                                <xsl:value-of select="."/>
                                            </li>
                                        </xsl:for-each>
                                    </td>
                                </xsl:when>
                                <xsl:otherwise>
                                    <td>Komponist:</td>
                                    <td>
                                        <xsl:value-of select="//mei:titleStmt/mei:composer"/>
                                    </td>
                                </xsl:otherwise>
                            </xsl:choose>
                        </tr>
                    </xsl:if>
                    <xsl:if test="not(//mei:titleStmt/mei:lyricist = '')">
                        <tr>
                            <td>Textdichter:</td>
                            <xsl:choose>
                                <xsl:when test="count(//mei:titleStmt/mei:lyricist) > 1">
                                    <td>
                                        <xsl:for-each select="//mei:titleStmt/mei:lyricist">
                                            <li>
                                                <xsl:value-of select="."/>
                                            </li>
                                        </xsl:for-each>
                                    </td>
                                </xsl:when>
                                <xsl:otherwise>
                                    <td>
                                        <xsl:value-of select="//mei:titleStmt/mei:lyricist"/>
                                    </td>
                                </xsl:otherwise>
                            </xsl:choose>
                        </tr>
                    </xsl:if>
                </xsl:if>-->
                <xsl:if test="not(//mei:workList/mei:work/mei:key/@mode/data(.) = '')">
                    <tr>
                        <td>Tonart:</td>
                        <td>
                            <xsl:choose>
                                <xsl:when test="//mei:workList/mei:work/mei:key/@mode/data(.) = 'minor'">
                                    <xsl:value-of select="lower-case(//mei:workList/mei:work/mei:key/@pname)"/>-Moll
                                </xsl:when>
                                <xsl:when test="//mei:workList/mei:work/mei:key/@mode/data(.) = 'major'">
                                    <xsl:value-of select="upper-case(//mei:workList/mei:work/mei:key/@pname)"/>-Dur
                                </xsl:when>
                                <xsl:when test="not(//mei:workList/mei:work/mei:key/@mode/data(.) = 'major') and not(//mei:workList/mei:work/mei:key/@mode/data(.) = 'minor')">
                                    <xsl:value-of select="lower-case(//mei:workList/mei:work/mei:key/@pname)"/>-<xsl:value-of select="//mei:workList/mei:work/mei:key/@mode"/>
                                </xsl:when>
                                <xsl:otherwise>
                                    [unbekannt]
                                </xsl:otherwise>
                            </xsl:choose>
                        </td>
                    </tr>
                </xsl:if>
                <xsl:if test="not(//mei:meter/@count/data(.) = '')">
                    <tr>
                        <td>Taktart:</td>
                        <td>
                            <xsl:value-of select="//mei:workList/mei:work/mei:meter/@count"/>/<xsl:value-of select="//mei:workList/mei:work/mei:meter/@unit"/>
                        </td>
                    </tr>
                </xsl:if>
                <xsl:if test="not(empty(mei:tempo))">
                    <tr>
                        <td>Tempobezeichnung:</td>
                        <td>
                            <xsl:value-of select="//mei:workList/mei:work/mei:tempo"/>
                        </td>
                    </tr>
                </xsl:if>
                <xsl:if test="not(//mei:persResList/data(.) = '')">
                    <tr>
                        <td valign="top">Besetzung:</td>
                        <td>
                            <xsl:for-each select="//mei:perfMedium/mei:perfResList/mei:perfRes">
                                <xsl:sort select="." order="ascending" data-type="text"/>
                                <li>
                                        <xsl:value-of select="."/>
                                        <xsl:if test="./@count &gt; 0">(<xsl:value-of select="./@count"/>)</xsl:if>
                                    
                                </li>
                            </xsl:for-each>
                        </td>
                    </tr>
                </xsl:if>
                <tr>
                    <td colspan="2">Zugehörige Quellen:</td>
                </tr>
                <tr>
                    <td colspan="2">
                        <ul style="list-style-type:circle">
                            <xsl:for-each select="//mei:componentList/mei:manifestation">
                                <xsl:variable name="sourceTarget" select="@target"/>
                                <xsl:choose>
                                    <xsl:when test="doc-available(concat('../../../../contents/sources/music/', $sourceTarget, '.xml'))">
                                        <li>
                                            <xsl:value-of select="mei:titleStmt/mei:title"/> | <xsl:value-of select="ancestor::mei:work/mei:relationList/mei:relation[contains(@target,$sourceTarget)]/@rel"/> (<a href="{concat($registerRootManuskript,$sourceTarget)}" target="_blank">
<xsl:value-of select="ancestor::mei:work/mei:relationList/mei:relation[contains(@target,$sourceTarget)]/@target"/>
                                            </a>)
                                        </li>
                                    </xsl:when>
                                    <xsl:otherwise>
                                        <li>
                                            <xsl:value-of select="mei:contents/mei:contentItem"/> | <xsl:value-of select="ancestor::mei:work/mei:relationList/mei:relation[contains(@source,$sourceTarget)]/@rel"/> | <xsl:value-of select="ancestor::mei:work/mei:relationList/mei:relation[contains(@source,$sourceTarget)]/@source"/>
                                        </li>
                                    </xsl:otherwise>
                                </xsl:choose>
                            </xsl:for-each>
                        </ul>
                    </td>
                </tr>
                <xsl:if test="not(//mei:key/@mode/data(.) = '')"/>
            </table>
        </div>
    </xsl:template>
</xsl:stylesheet>