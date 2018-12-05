<xsl:stylesheet xmlns="http://www.w3.org/1999/xhtml" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:mei="http://www.music-encoding.org/ns/mei" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:xlink="http://www.w3.org/1999/xlink" version="2.0">
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
                            <!--<a href="{concat($registerRootPerson,//mei:workList/mei:work/mei:composer/@xml:id,'.xml')}" target="_blank">-->
                            <xsl:value-of select="//mei:manifestationList/mei:manifestation/mei:titleStmt/mei:composer"/>
                            <!--</a>-->
                        </td>
                    </tr>
                </xsl:if>

                <xsl:if test="not(//mei:manifestationList/mei:manifestation/mei:titleStmt/mei:lyricist = '')">
                    <tr>
                        <td valign="top">Textdichter:</td>
                        <td>
                            <xsl:choose>
                                <xsl:when test="doc-available(concat('../../../../contents/jra/persons/', //mei:manifestationList/mei:manifestation/mei:titleStmt/mei:lyricist/@auth, '.xml'))">
                                    <a href="{concat($registerRootPerson, //mei:composer/mei:persName/@auth)}" target="_blank">
                                        <xsl:value-of select="//mei:manifestationList/mei:manifestation/mei:titleStmt/mei:lyricist"/>
                                    </a>
                                </xsl:when>
                                <xsl:otherwise>
                                    <ul>
                                    <xsl:for-each select="tokenize(//mei:manifestationList/mei:manifestation/mei:titleStmt/mei:lyricist/normalize-space(text()),' \| ')">
                                        <li><xsl:value-of select="concat('zu Nr. ',.)"/></li>
                                    </xsl:for-each>
                                    </ul>
                                </xsl:otherwise>
                            </xsl:choose>
                        </td>
                    </tr>
                </xsl:if>
                <tr>
                    <td valign="top">Besetzung:</td>
                    <td>
                        <xsl:choose>
                            <xsl:when test="//mei:workList/mei:work/mei:perfMedium/mei:perfResList/count(mei:perfRes[not(@type='alt')]) = 1">
                                <xsl:value-of select="//mei:workList/mei:work/mei:perfMedium/mei:perfResList/mei:perfRes[not(@type='alt')]/text()"/>
                            </xsl:when>
                            <xsl:otherwise>
                                <ul>
                                    <xsl:for-each select="//mei:workList/mei:work/mei:perfMedium/mei:perfResList/mei:perfRes[not(@type='alt')]">
                                        <li>
                                            <xsl:value-of select="./text()"/>
                                        </li>
                                    </xsl:for-each>
                                </ul>
                            </xsl:otherwise>
                        </xsl:choose>
                    </td>
                </tr>
                <xsl:if test="exists(//mei:workList/mei:work/mei:perfMedium/mei:perfResList/mei:perfRes[@type='alt'])">
                    <tr>
                        <td valign="top">Alternative Besetzung:</td>
                        <td>
                            <xsl:choose>
                                <xsl:when test="//mei:workList/mei:work/mei:perfMedium/mei:perfResList/count(mei:perfRes[@type='alt']) = 1">
                                    <xsl:value-of select="//mei:workList/mei:work/mei:perfMedium/mei:perfResList/mei:perfRes[@type='alt']/text()"/>
                                </xsl:when>
                                <xsl:otherwise>
                                    <ul>
                                        <xsl:for-each select="//mei:workList/mei:work/mei:perfMedium/mei:perfResList/mei:perfRes[@type='alt']">
                                            <li>
                                                <xsl:value-of select="./text()"/>
                                            </li>
                                        </xsl:for-each>
                                    </ul>
                                </xsl:otherwise>
                            </xsl:choose>
                        </td>
                    </tr>
                </xsl:if>
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
                    <!--  and not(child::text()/normalize-space(.)='') -->
                    <tr>
                        <td valign="top">Uraufführung:</td>
                        <td>
                            <xsl:variable name="UAdate" select="//mei:eventList/mei:event[@type='UA']/mei:date/format-date(xs:date(.),'[D11].[M11].[Y]')"/>
                            <xsl:variable name="UAort" select="//mei:eventList/mei:event[@type='UA']/mei:geogName"/>
                            <xsl:variable name="UAconductor" select="//mei:eventList/mei:event[@type='UA']/mei:persName[@role='conductor']"/>
                            <xsl:variable name="UAinterpret" select="//mei:eventList/mei:event[@type='UA']/mei:persName[@role='interpret']"/>
                            <xsl:choose>
                                <xsl:when test="not(empty($UAdate)) and not(empty($UAort))">
                                    <xsl:value-of select="concat('Am ',$UAdate,' in ',$UAort)"/>
                                </xsl:when>
                                <xsl:when test="not(empty($UAdate)) and empty($UAort)">
                                    <xsl:value-of select="concat('Am ',$UAdate)"/>
                                </xsl:when>
                                <xsl:when test="empty($UAdate) and not(empty($UAort))">
                                    <xsl:value-of select="concat('In ',$UAort)"/>
                                </xsl:when>
                            </xsl:choose>
                            <xsl:if test="not(empty($UAconductor))">
                                <br/><xsl:value-of select="concat('Dirigent: ',$UAconductor)"/>
                            </xsl:if>
                            <xsl:if test="not(empty($UAinterpret))">
                                <xsl:for-each select="$UAinterpret/node()">
                                <br/><xsl:value-of select="concat('Interpret: ',.)"/>
                                </xsl:for-each>
                            </xsl:if>
                            </td>
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
                </table>
        <xsl:if test="exists(//mei:componentList/mei:manifestation/mei:itemList/mei:item)">
                <xsl:variable name="sourceClass" select="//mei:componentList/mei:manifestation/mei:itemList/mei:item/@codedval"/>
                <br/>
            <table>
                <tr>
                    <td colspan="2">Zugehörige Quellen:</td>
                </tr>
                <tr>
                    <td colspan="2">
                        <ul style="list-style-type:circle">
                            <xsl:for-each select="//mei:componentList/mei:manifestation/mei:itemList/mei:item">
                                        <li>
                                            [<xsl:value-of select="document('../../../../contents/jra/definitions/sourceClassification.xml')//mei:classDecls/mei:taxonomy/mei:category[@xml:id=$sourceClass]/mei:desc[@xml:lang='de']"/>] <xsl:value-of select="//mei:locus"/>
                                        </li>
                            </xsl:for-each>
                        </ul>
                    </td>
                </tr>
            </table>
        </xsl:if>
        </div>
    </xsl:template>
</xsl:stylesheet>
