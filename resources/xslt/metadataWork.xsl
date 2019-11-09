<xsl:stylesheet xmlns="http://www.w3.org/1999/xhtml" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:mei="http://www.music-encoding.org/ns/mei" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:local="http://portal.raff-archive.ch/ns/local" xmlns:xlink="http://www.w3.org/1999/xlink" version="2.0">
    <xsl:output method="xhtml" encoding="UTF-8" indent="yes"/>
    <xsl:include href="linking.xsl"/>
    <xsl:include href="formattingDate.xsl"/>
    <xsl:template match="/">
        <div>
            <table class="workView">
                <tr>
                    <td>ID:</td>
                    <td>
                        <xsl:value-of select="mei:mei/@xml:id"/>
                    </td>
                </tr>
                <!--                <xsl:if test="//mei:creation/mei:dedication/not(normalize-space(.)='')">-->
                <tr>
                    <td>Widmung:</td>
                    <td>
                        <xsl:value-of select="//mei:creation/mei:dedication/text()[1]"/>
                    </td>
                </tr>
                <!--</xsl:if>-->
                <!--                <xsl:if test="//mei:creation/mei:dedication/mei:dedicatee/not(normalize-space(.)='')">-->
                <tr>
                    <td>Widmungsträger:</td>
                    <td>
                        <xsl:value-of select="//mei:creation/mei:dedication/mei:dedicatee"/>
                    </td>
                </tr>
                <!--</xsl:if>-->
                <!--                <xsl:if test="not(//mei:manifestationList/mei:manifestation/mei:titleStmt/mei:lyricist = '')">-->
                <tr>
                    <td>Textdichter:</td>
                    <td>
                        <!--                                <xsl:when test="doc-available(concat('../../../../contents/jra/persons/', //mei:manifestationList/mei:manifestation/mei:titleStmt/mei:lyricist/mei:persName/@auth, '.xml'))">-->
                        <a href="{concat($viewPerson, //mei:composer/mei:persName/@auth)}" target="_blank">
                            <xsl:value-of select="//mei:manifestationList/mei:manifestation/mei:titleStmt/mei:lyricist/mei:persName"/>
                        </a>
                        <!--</xsl:when>-->
                        <ul>
                            <xsl:for-each select="//mei:manifestationList/mei:manifestation/mei:titleStmt/mei:lyricist/mei:persName">
                                <xsl:variable name="mdivNo" select="./ancestor::mei:mei//mei:mdiv[@xml:id = //mei:manifestationList/mei:manifestation/mei:titleStmt/mei:lyricist/mei:persName/@corresp]"/>
                                <li>
                                    <xsl:value-of select="concat('zu Nr. ', $mdivNo)"/>
                                </li>
                            </xsl:for-each>
                        </ul>
                    </td>
                </tr>
                <!--</xsl:if>-->
            </table>
            <table class="workView">
                <tr>
                    <td>Besetzung:</td>
                    <td>
                        <xsl:choose>
                            <xsl:when test="//mei:workList/mei:work/mei:perfMedium/mei:perfResList/count(mei:perfRes[not(@type = 'alt')]) = 1">
                                <xsl:value-of select="//mei:workList/mei:work/mei:perfMedium/mei:perfResList/mei:perfRes[not(@type = 'alt')]/normalize-space(text())"/>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:for-each select="//mei:workList/mei:work/mei:perfMedium/mei:perfResList/mei:perfRes[not(contains(@type, 'alt'))]">
                                    <xsl:value-of select="./normalize-space(text())"/>
                                    <br/>
                                </xsl:for-each>
                            </xsl:otherwise>
                        </xsl:choose>
                    </td>
                </tr>
                <!--                <xsl:if test="exists(//mei:workList/mei:work/mei:perfMedium/mei:perfResList/mei:perfRes[@type='alt'])">-->
                <tr>
                    <td>Alternative Besetzung:</td>
                    <td>
                        <xsl:choose>
                            <xsl:when test="//mei:workList/mei:work/mei:perfMedium/mei:perfResList/count(mei:perfRes[@type = 'alt']) = 1">
                                <xsl:value-of select="//mei:workList/mei:work/mei:perfMedium/mei:perfResList/mei:perfRes[@type = 'alt']/normalize-space(text())"/>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:for-each select="//mei:workList/mei:work/mei:perfMedium/mei:perfResList/mei:perfRes[@type = 'alt']">
                                    <xsl:value-of select="./normalize-space(text())"/>
                                    <br/>
                                </xsl:for-each>
                            </xsl:otherwise>
                        </xsl:choose>
                    </td>
                </tr>

                <!--</xsl:if>-->
            </table>
            <!--                <xsl:if test="exists(//mei:creation/mei:date[@type='composition']">-->
            <table class="workView">
                <tr>
                    <!--                <xsl:if test="exists(//mei:creation/mei:date[@type='composition']/@isodate)">-->

                    <td>Kompositionsdatum:</td>
                    <td>
                        <xsl:value-of select="local:formatDate(//mei:creation/mei:date[@type = 'composition']/@isodate)"/>
                    </td>
                </tr>
                <!--</xsl:if>-->
                <!--                <xsl:if test="exists(//mei:creation/mei:date[@type='composition']/@notbefore) and exists(//mei:creation/mei:date[@type='composition']/@notafter)">-->
                <tr>
                    <td>Kompositionszeitraum:</td>
                    <td>
                        <xsl:value-of select="local:formatDate(//mei:creation/mei:date[@type = 'composition']/@notbefore)"/> bis
                            <xsl:value-of select="local:formatDate(//mei:creation/mei:date[@type = 'composition']/@notafter)"/>
                    </td>
                </tr>
                <!--</xsl:if>-->
                <!--                <xsl:if test="exists(//mei:creation/mei:date[@type='composition']/@notbefore) and not(exists(//mei:creation/mei:date[@type='composition']/@notafter))">-->
                <tr>
                    <td>Kompositionszeitraum:</td>
                    <td>Nach <xsl:if test="string-length(//mei:creation/mei:date[@type = 'composition']/@notbefore)=10">dem </xsl:if><xsl:value-of select="local:formatDate(//mei:creation/mei:date[@type = 'composition']/@notbefore)"/>
                    </td>
                </tr>
                <!--</xsl:if>-->
                <!--                <xsl:if test="not(exists(//mei:creation/mei:date[@type='composition']/@notbefore)) and exists(//mei:creation/mei:date[@type='composition']/@notafter)">-->
                <tr>
                    <td>Kompositionszeitraum:</td>
                    <td>Vor <xsl:if test="string-length(//mei:creation/mei:date[@type = 'composition']/@notafter)=10">dem </xsl:if><xsl:value-of select="local:formatDate(//mei:creation/mei:date[@type = 'composition']/@notafter)"/>
                    </td>
                </tr>
                <!--</xsl:if>-->
            </table>
            <!--            </xsl:if>-->
            <!--                <xsl:if test="exists(//mei:componentList/mei:manifestation/mei:biblList/mei:bibl)">-->
            <table class="workView">
                <tr>
                    <td>Bekannte Ausgaben:</td>
                    <td>
                        <xsl:choose>
                            <xsl:when test="//mei:componentList/mei:manifestation/mei:biblList/count(mei:bibl) = 1">
                                <xsl:value-of select="//mei:componentList/mei:manifestation/mei:biblList/mei:bibl/concat(./mei:publisher, ' (', ./mei:date, ')')"/>
                            </xsl:when>
                            <xsl:otherwise>
                                <ul>
                                    <xsl:for-each select="//mei:componentList/mei:manifestation/mei:biblList/mei:bibl">
                                        <li>
                                            <xsl:value-of select="concat(./mei:publisher, ' (', ./mei:date, ')')"/>
                                        </li>
                                    </xsl:for-each>
                                </ul>
                            </xsl:otherwise>
                        </xsl:choose>
                    </td>
                </tr>
                <!--</xsl:if>-->
                <!--                <xsl:if test="//mei:history/mei:eventList/count(mei:event[exists(mei:head) and exists(mei:desc)]) >= 1">-->
                <tr>
                    <td>Werkgeschichte:</td>
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
                <!--</xsl:if>-->
            </table>
            <table class="workView">
                <!--                <xsl:if test="//mei:eventList/mei:event[@type='UA']"> <!-\-  and not(child::text()/normalize-space(.)='') -\->-->
                <tr>
                    <td>Uraufführung:</td>
                    <td>
                        <xsl:variable name="UAdate" select="local:formatDate(//mei:eventList/mei:event[@type = 'UA']/mei:date/text())"/>
                        <xsl:variable name="UAort" select="//mei:eventList/mei:event[@type = 'UA']/mei:geogName/text()"/>
                        <xsl:variable name="UAconductor" select="//mei:eventList/mei:event[@type = 'UA']/mei:persName[@role = 'conductor']/text()"/>
                        <xsl:variable name="UAinterpret" select="//mei:eventList/mei:event[@type = 'UA']/mei:persName[contains(@role,'interpret')]"/>
                        <xsl:choose>
                            <xsl:when test="not(empty($UAdate)) and not(empty($UAort))">
                                <xsl:value-of select="concat('Am ', $UAdate, ' in ', $UAort)"/>
                            </xsl:when>
                            <xsl:when test="not(empty($UAdate)) and empty($UAort)">
                                <xsl:value-of select="concat('Am ', $UAdate)"/>
                            </xsl:when>
                            <xsl:when test="empty($UAdate) and not(empty($UAort))">
                                <xsl:value-of select="concat('In ', $UAort)"/>
                            </xsl:when>
                        </xsl:choose>
                        <xsl:if test="not(empty($UAconductor))">
                            <br/>
                            <xsl:value-of select="concat('Dirigent: ', $UAconductor)"/>
                        </xsl:if>
                        <xsl:if test="$UAinterpret">
                            <xsl:for-each select="$UAinterpret">
                                <br/>
                                <xsl:value-of select="concat('Interpret: ', ./text()[1])"/>
                                <xsl:if test="contains(./@role,' ')">
                                    <xsl:value-of select="concat(' (',string-join(subsequence(tokenize(./@role,' '),2),'|'),')')"/>
                                </xsl:if>
                            </xsl:for-each>
                        </xsl:if>
                    </td>
                </tr>
                <!--</xsl:if>-->
            </table>
            <table class="workView">
                <!--                <xsl:if test="exists(//mei:music/mei:body/mei:mdiv/@label)">-->
                <tr>
                    <td>Musikalische Abschnitte:</td>
                    <td>
                        <xsl:for-each select="//mei:music/mei:body/mei:mdiv">
                            <xsl:value-of select="concat('Nr. ', ./@label)"/>
                            <br/>
                            <xsl:if test="exists(./mei:mdiv)">
                                <ul>
                                    <xsl:for-each select="./mei:mdiv">

                                        <xsl:value-of select="concat('Nr. ', ./@n, ' ', ./@label)"/>
                                        <br/>
                                    </xsl:for-each>
                                </ul>
                            </xsl:if>
                        </xsl:for-each>
                    </td>
                </tr>
                <!--</xsl:if>-->
            </table>
            <!--            <xsl:if test="exists(//mei:componentList/mei:manifestation/mei:itemList/mei:item)">-->
            <table class="workView">
                <tr>
                    <td colspan="2">Zugehörige Quellen:</td>
                </tr>
                <tr>
                    <td colspan="2">
                        <ul style="list-style-type:circle">
                            <xsl:for-each select="//mei:componentList/mei:manifestation/mei:itemList/mei:item">
                                <xsl:variable name="sourceClass" select="//mei:componentList/mei:manifestation/mei:itemList/mei:item/@codedval"/>
                                <li> [<xsl:value-of select="document('../../../../contents/jra/definitions/sourceClassification.xml')//mei:classDecls/mei:taxonomy/mei:category[@xml:id = $sourceClass]/mei:desc[@xml:lang = 'de']"/>] <xsl:value-of select=".//mei:locus"/>
                                </li>
                            </xsl:for-each>
                        </ul>
                    </td>
                </tr>
            </table>
            <!--</xsl:if>-->
        </div>
    </xsl:template>
</xsl:stylesheet>