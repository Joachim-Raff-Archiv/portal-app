<xsl:stylesheet xmlns="http://www.w3.org/1999/xhtml" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:mei="http://www.music-encoding.org/ns/mei" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:local="http://portal.raff-archive.ch/ns/local" xmlns:xlink="http://www.w3.org/1999/xlink" version="2.0">
    <xsl:output method="xhtml" encoding="UTF-8" indent="yes"/>
    <xsl:include href="formattingText.xsl"/>
    <xsl:include href="formattingDate.xsl"/>
    <xsl:template match="/">
        <div>
            <table class="workView">
                <tr>
                    <td valign="top">ID:</td>
                    <td>
                        <xsl:value-of select="mei:mei/@xml:id"/>
                    </td>
                </tr>
                </table>
            <table class="workView">
                <xsl:if test="//mei:creation/mei:dedication/text()/normalize-space(.) !=''">
                <tr>
                    <td valign="top">Widmung:</td>
                    <td>
                        <xsl:value-of select="//mei:creation/mei:dedication/text()[1]"/>
                    </td>
                </tr>
                </xsl:if>
                                <xsl:if test="//mei:creation/mei:dedication/mei:dedicatee/normalize-space(.) !=''">
                <tr>
                    <td valign="top">Widmungsträger:</td>
                    <td>
                        <xsl:for-each select="//mei:dedication/mei:dedicatee">
                            <xsl:variable name="corresp" select="substring-after(@corresp,'#')"/>
                            <xsl:choose>
                                <xsl:when test="mei:persName">
                                    <xsl:if test="$corresp">
                                        <xsl:value-of select="concat('Nr. ',//mei:mdiv[@xml:id=$corresp]/@n,' – ')"/>
                                    </xsl:if>
                                    <xsl:value-of select="mei:persName"/>
                                    <xsl:if test="mei:persName/@auth">
                                        (<a href="{concat($viewPerson, mei:persName/@auth)}">
                                            <xsl:value-of select="mei:persName/@auth"/>
                                        </a>)
                                    </xsl:if>
                                    <br/>
                                </xsl:when>
                                <xsl:when test="mei:corpName">
                                    <xsl:if test="$corresp">
                                        <xsl:value-of select="concat('Nr. ',//mei:mdiv[@xml:id=$corresp]/@n,' – ')"/>
                                    </xsl:if>
                                    <xsl:value-of select="mei:corpName"/>
                                    <xsl:if test="mei:corpName/@auth">
                                        (<a href="{concat($viewPerson, mei:corpName/@auth)}">
                                            <xsl:value-of select="mei:corpName/@auth"/>
                                        </a>)
                                    </xsl:if>
                                    <br/>
                                </xsl:when>
                                <xsl:otherwise>
                                    <xsl:if test="$corresp">
                                        <xsl:value-of select="concat('Nr. ',//mei:mdiv[@xml:id=$corresp]/@n,' – ')"/>
                                    </xsl:if>
                                    <xsl:value-of select="."/>
                                    <br/>
                                </xsl:otherwise>
                            </xsl:choose>
                        </xsl:for-each>
                    </td>
                </tr>
                </xsl:if>
                                <xsl:if test="//mei:manifestationList/mei:manifestation/mei:titleStmt/mei:lyricist != ''">
                                    
                <tr>
                    <td valign="top">Textdichter:</td>
                    <td>
                        
                        <xsl:for-each select="//mei:manifestationList/mei:manifestation/mei:titleStmt/mei:lyricist">
                            <xsl:variable name="corresp" select="substring-after(@corresp,'#')"/>
                        <xsl:choose>
                            <xsl:when test="mei:persName">
                            <xsl:value-of select="mei:persName"/>
                            (<a href="{concat($viewPerson, mei:persName/@auth)}">
                                <xsl:value-of select="mei:persName/@auth"/>
                            </a>)
                            <xsl:if test="$corresp">
                                <xsl:value-of select="concat(' [Nr. ',//mei:mdiv[@xml:id=$corresp]/@n,']')"/>
                            </xsl:if>
                            <br/>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:value-of select="."/>
                                <xsl:if test="$corresp">
                                    <xsl:value-of select="concat(' [Nr. ',//mei:mdiv[@xml:id=$corresp]/@n,']')"/>
                                </xsl:if>
                                <br/>
                            </xsl:otherwise>
                        </xsl:choose>
                        </xsl:for-each>
                    </td>
                </tr>
                </xsl:if>
            </table>
            <table class="workView">
                <tr>
                    <td valign="top">Besetzung:</td>
                    <td>
                        <xsl:choose>
                            <xsl:when test="/mei:perfMedium/mei:perfResList//count(mei:perfRes[not(@type = 'alt')]) = 1">
                                <xsl:value-of select="//mei:perfMedium/mei:perfResList//mei:perfRes[not(@type = 'alt')]/normalize-space(text())"/>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:for-each select="//mei:perfMedium/mei:perfResList//mei:perfRes[not(contains(@type, 'alt'))]">
                                    <xsl:value-of select="./normalize-space(text())"/>
                                    <br/>
                                </xsl:for-each>
                            </xsl:otherwise>
                        </xsl:choose>
                    </td>
                </tr>
                                <xsl:if test="exists(//mei:workList/mei:work/mei:perfMedium/mei:perfResList//mei:perfRes[@type='alt'])">
                <tr>
                    <td valign="top">Alternative Besetzung:</td>
                    <td>
                        <xsl:choose>
                            <xsl:when test="//mei:workList/mei:work/mei:perfMedium/mei:perfResList//count(mei:perfRes[@type = 'alt']) = 1">
                                <xsl:value-of select="//mei:workList/mei:work/mei:perfMedium/mei:perfResList//mei:perfRes[@type = 'alt']/normalize-space(text())"/>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:for-each select="//mei:workList/mei:work/mei:perfMedium/mei:perfResList//mei:perfRes[@type = 'alt']">
                                    <xsl:value-of select="./normalize-space(text())"/>
                                    <br/>
                                </xsl:for-each>
                            </xsl:otherwise>
                        </xsl:choose>
                    </td>
                </tr>

                </xsl:if>
            </table>
                            <xsl:if test="//mei:creation/mei:date[@type='composition']">
            <table class="workView">
                <xsl:if test="//mei:creation/mei:date[@type='composition']/@isodate">
                <tr>
                    <td valign="top">Kompositionsdatum:</td>
                    <td>
                        <xsl:value-of select="local:formatDate(//mei:creation/mei:date[@type = 'composition']/@isodate)"/>
                    </td>
                </tr>
                </xsl:if>
                <xsl:if test="//mei:creation/mei:date[@type='composition']/@notbefore and //mei:creation/mei:date[@type='composition']/@notafter">
                <tr>
                    <td valign="top">Kompositionszeitraum:</td>
                    <td>
                        <xsl:value-of select="local:formatDate(//mei:creation/mei:date[@type = 'composition']/@notbefore)"/> bis
                            <xsl:value-of select="local:formatDate(//mei:creation/mei:date[@type = 'composition']/@notafter)"/>
                    </td>
                </tr>
                </xsl:if>
                                <xsl:if test="//mei:creation/mei:date[@type='composition']/@notbefore and not(//mei:creation/mei:date[@type='composition']/@notafter)">
                <tr>
                    <td>Kompositionszeitraum:</td>
                    <td>Nach <xsl:if test="string-length(//mei:creation/mei:date[@type = 'composition']/@notbefore)=10">dem </xsl:if><xsl:value-of select="local:formatDate(//mei:creation/mei:date[@type = 'composition']/@notbefore)"/>
                    </td>
                </tr>
                </xsl:if>
                <xsl:if test="not(//mei:creation/mei:date[@type='composition']/@notbefore) and //mei:creation/mei:date[@type='composition']/@notafter">
                <tr>
                    <td>Kompositionszeitraum:</td>
                    <td>Vor <xsl:if test="string-length(//mei:creation/mei:date[@type = 'composition']/@notafter)=10">dem </xsl:if><xsl:value-of select="local:formatDate(//mei:creation/mei:date[@type = 'composition']/@notafter)"/>
                    </td>
                </tr>
                </xsl:if>
            </table>
                        </xsl:if>
            
            <table class="workView">
                <xsl:if test="//mei:history/mei:eventList/mei:event[@type='entstehung']">
                <tr>
                    <td>Entstehungsgeschichte:</td>
                    <td>
<!--                        <xsl:value-of select="//mei:history/mei:eventList/mei:event[@type='entstehung']/mei:desc"/>-->
                        <xsl:apply-templates select="//mei:event[@type='entstehung']/mei:desc"/>
                    </td>
                </tr>
                </xsl:if>
            <xsl:if test="//mei:eventList/mei:event[@type='UA']/normalize-space() !=''">            
                <tr>
                    <td valign="top">Uraufführung:</td>
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
                        <xsl:if test="$UAinterpret/normalize-space() !=''">
                            <xsl:for-each select="$UAinterpret">
                                <br/>
                                <xsl:value-of select="concat('Interpret(en): ', ./text()[1])"/>
                                <xsl:if test="contains(./@role,' ')">
                                    <xsl:value-of select="concat(' (',string-join(subsequence(tokenize(./@role,' '),2),'|'),')')"/>
                                </xsl:if>
                            </xsl:for-each>
                        </xsl:if>
                    </td>
                </tr>
            </xsl:if>
            </table>
            
            <xsl:if test="//mei:componentList/mei:manifestation/mei:biblList/mei:bibl">
            <table class="workView">
                <tr>
                    <td>Erfasste Ausgaben:</td>
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
            </table>
            </xsl:if>
            <xsl:if test="//mei:music/mei:body/mei:mdiv/@label">
            <table class="workView">
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
            </table>
            </xsl:if>
            <xsl:if test="exists(//mei:componentList/mei:manifestation/mei:itemList/mei:item)">
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
            </xsl:if>
        </div>
    </xsl:template>
</xsl:stylesheet>