<xsl:stylesheet xmlns="http://www.w3.org/1999/xhtml" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:mei="http://www.music-encoding.org/ns/mei" xmlns:xlink="http://www.w3.org/1999/xlink" version="2.0">
    <xsl:output method="xhtml" encoding="UTF-8" indent="yes"/>
    <xsl:include href="linking.xsl"/>
    <!--    <xsl:include href="turnDate.xsl"/>-->
    <xsl:template match="/">
        <div>
            <table border="0" width="100%">
                <tr>
                    <th width="20%"/>
                    <th/>
                </tr>

                <xsl:if test="not(//mei:workList/mei:work/mei:title[@type = 'desc']/data(.) = '')">
                    <tr>
                        <td>Werkbeschreibung:</td>
                        <td>
                            <xsl:value-of select="//mei:workList/mei:work/mei:title[@type = 'desc']"/>
                        </td>
                    </tr>
                </xsl:if>
                <xsl:if test="not(//mei:manifestationList/mei:manifestation/mei:titleStmt/mei:composer = '')">
                    <tr>
                        <td>Komponist:</td>
                        <td>
                            <xsl:choose>
                                <xsl:when test="doc-available(concat('../../../../contents/jra/persons/', //composer/persName/@auth, '.xml'))">
                                    <a href="{concat($registerRootPerson, //mei:composer/mei:persName/@auth)}" target="_blank">
                                        <xsl:value-of select="//mei:manifestationList/mei:manifestation/mei:titleStmt/mei:composer/mei:persName"/>
                                    </a>
                                </xsl:when>
                                <xsl:otherwise>
                                    <xsl:value-of select="//mei:manifestationList/mei:manifestation/mei:titleStmt/mei:composer/mei:persName"/>
                                </xsl:otherwise>
                            </xsl:choose>
                        </td>
                    </tr>
                </xsl:if>

                <xsl:if test="not(//mei:manifestationList/mei:manifestation/mei:titleStmt/mei:lyricist = '')">
                    <tr>
                        <td>Textdichter:</td>
                        <td>
                            <xsl:choose>
                                <xsl:when test="doc-available(concat('../../../../contents/jra/persons/', //mei:manifestationList/mei:manifestation/mei:titleStmt/mei:lyricist/@auth, '.xml'))">
                                    <a href="{concat($registerRootPerson, //mei:composer/mei:persName/@auth)}" target="_blank">
                                        <xsl:value-of select="//mei:manifestationList/mei:manifestation/mei:titleStmt/mei:lyricist"/>
                                    </a>
                                </xsl:when>
                                <xsl:otherwise>
                                    <xsl:value-of select="//mei:manifestationList/mei:manifestation/mei:titleStmt/mei:lyricist"/>
                                </xsl:otherwise>
                            </xsl:choose>
                        </td>
                    </tr>
                </xsl:if>
                <tr>
                    <td valign="top">Besetzung:</td>
                    <td>
                        <xsl:choose>
                            <xsl:when test="//mei:workList/mei:work/mei:perfMedium/mei:perfResList/mei:perfRes/count(node()) = 1">
                                <xsl:value-of select="//mei:workList/mei:work/mei:perfMedium/mei:perfResList/mei:perfRes/text()"/>
                            </xsl:when>
                            <xsl:otherwise>
                                <ul>
                                    <xsl:for-each select="//mei:workList/mei:work/mei:perfMedium/mei:perfResList/mei:perfRes[not(contains(@type,'alt'))]">
                                        <li>
                                            <xsl:value-of select="./text()"/>
                                        </li>
                                    </xsl:for-each>
                                </ul>
                            </xsl:otherwise>
                        </xsl:choose>
                    </td>
                </tr>
                <xsl:if test="exists(//mei:creation/mei:date[@type='composition' and 1]/@isodate)">
                <tr>
                    <td>Kompositionsdatum:</td>
                    <td>
                        <xsl:value-of select="//mei:creation/mei:date[@type='composition' and 1]/@isodate"/>
                    </td>
                </tr>
                </xsl:if>
                <xsl:if test="exists(//mei:creation/mei:date[@type='composition' and 1]/@notbefore) and exists(//mei:creation/mei:date[@type='composition' and 1]/@notafter)">
                <tr>
                    <td>Kompositionszeitraum:</td>
                    <td>
                        <xsl:value-of select="//mei:creation/mei:date[@type='composition' and 1]/@notbefore"/> bis 
                        <xsl:value-of select="//mei:creation/mei:date[@type='composition' and 1]/@notafter"/>
                    </td>
                </tr>
                </xsl:if>
                <xsl:if test="exists(//mei:creation/mei:date[@type='composition' and 1]/@notbefore) and not(exists(//mei:creation/mei:date[@type='composition' and 1]/@notafter))">
                    <tr>
                        <td>Kompositionszeitraum:</td>
                        <td>
                            nach <xsl:value-of select="//mei:creation/mei:date[@type='composition' and 1]/@notbefore"/>
                        </td>
                    </tr>
                </xsl:if>
                <xsl:if test="not(exists(//mei:creation/mei:date[@type='composition' and 1]/@notbefore)) and exists(//mei:creation/mei:date[@type='composition' and 1]/@notafter)">
                    <tr>
                        <td>Kompositionszeitraum:</td>
                        <td>
                            vor <xsl:value-of select="//mei:creation/mei:date[@type='composition' and 1]/@notafter"/>
                        </td>
                    </tr>
                </xsl:if>
                <xsl:if test="//mei:creation/mei:dedication/not(normalize-space(.)='')">
                <tr>
                    <td>Widmung:</td>
                    <td><xsl:value-of select="//mei:creation/mei:dedication/text()[1]"/></td>
                </tr>
                </xsl:if>
                <xsl:if test="//mei:creation/mei:dedication/mei:dedicatee/not(normalize-space(.)='')">
                <tr>
                    <td>Widmungsträger:</td>
                    <td><xsl:value-of select="//mei:creation/mei:dedication/mei:dedicatee"/></td>
                </tr>
                </xsl:if>
                <xsl:if test="exists(//mei:componentList/mei:manifestation/mei:biblList/mei:bibl)">
                    <tr>
                        <td valign="top">Bekannte Ausgaben:</td>
                        <td>
                        <xsl:choose>
                            <xsl:when test="//mei:componentList/mei:manifestation/mei:biblList/count(mei:bibl) = 1">
                                <xsl:value-of select="//mei:componentList/mei:manifestation/mei:biblList/mei:bibl/concat(./mei:publisher,' (',./mei:date,')')"/>
                            </xsl:when>
                            <xsl:otherwise>
                                <ul>
                                    <xsl:for-each select="//mei:componentList/mei:manifestation/mei:biblList/mei:bibl">
                                        <li>
                                            <xsl:value-of select="concat(./mei:publisher,' (',./mei:date,')')"/>
                                        </li>
                                    </xsl:for-each>
                                </ul>
                            </xsl:otherwise>
                        </xsl:choose>
                        </td>
                    </tr>
                </xsl:if>
                <xsl:if test="//mei:history/mei:eventList/count(mei:event[exists(mei:head) and exists(mei:desc)]) &gt;= 1">
                <tr>
                    <td valign="top">Werkgeschichte:</td>
                    <td>
                        <xsl:choose>
                            <xsl:when test="//mei:history/mei:eventList/count(mei:event[exists(mei:head) and exists(mei:desc)]) = 1">
                                <xsl:value-of select="//mei:history/mei:eventList/mei:event[exists(mei:head) and exists(mei:desc)]"/>
                            </xsl:when>
                            <xsl:otherwise>
                                <ul>
                                    <xsl:for-each select="//mei:history/mei:eventList/mei:event[exists(mei:head) and exists(mei:desc)]">
                                        <li>
                                            <xsl:value-of select="./mei:head"/>: <xsl:value-of select="./mei:desc"/>
                                        </li>
                                    </xsl:for-each>
                                </ul>
                            </xsl:otherwise>
                        </xsl:choose>
                        
                    </td>
                </tr>
                </xsl:if>
                <xsl:if test="//mei:eventList/mei:event[@type='UA']">
                    <tr>
                        <td>Uraufführung:</td>
                        <td>
                            <xsl:variable name="UAdate" select="//mei:eventList/mei:event[@type='UA']/mei:date"/>
                            <xsl:variable name="UAort" select="//mei:eventList/mei:event[@type='UA']/mei:geogName"/>
                            <xsl:value-of select="concat('Am ',$UAdate,' in ',$UAort)"/></td>
                    </tr>
                </xsl:if>
                <xsl:if test="exists(//mei:music/mei:body/mei:mdiv/@label)">
                    <tr>
                        <td valign="top">Sätze:</td>
                        <td>
                            <ul>
                    <xsl:for-each select="//mei:music/mei:body/mei:mdiv">
                        <li>
                            <xsl:value-of select="concat('Nr. ',./@label)"/></li>
                        <xsl:if test="exists(./mei:mdiv)">
                            <ul>
                            <xsl:for-each select="./mei:mdiv">
                                <li>
                                    <xsl:value-of select="concat('Nr. ',./@label)"/></li>
                            </xsl:for-each>
                            </ul>
                        </xsl:if>
                    </xsl:for-each>
                            </ul>
                        </td>
                    </tr>
                </xsl:if>
                <!--</xsl:if>-->
                <!--<tr>
                    <td colspan="2">Zugehörige Quellen:</td>
                </tr>-->
                <!--<tr>
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
                </tr>-->
            </table>
        </div>
    </xsl:template>
</xsl:stylesheet>