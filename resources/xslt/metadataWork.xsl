<xsl:stylesheet xmlns="http://www.w3.org/1999/xhtml" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:mei="http://www.music-encoding.org/ns/mei" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:local="https://portal.raff-archive.ch/ns/local" xmlns:functx = "http://www.functx.com" xmlns:xlink="http://www.w3.org/1999/xlink" version="2.0">
    <xsl:output method="xhtml" encoding="UTF-8" indent="yes"/>
    <xsl:include href="formattingText.xsl"/>
    <xsl:include href="formattingDate.xsl"/>
    
    <xsl:function name="functx:contains-any-of" as="xs:boolean"
        xmlns:functx="http://www.functx.com">
        <xsl:param name="arg" as="xs:string?"/>
        <xsl:param name="searchStrings" as="xs:string*"/>
        
        <xsl:sequence select="
            some $searchString in $searchStrings
            satisfies contains($arg,$searchString)
            "/>
        
    </xsl:function>
    
    <xsl:function name="local:switch2Roman">
        <xsl:param name="n"/>
        <xsl:choose>
            <xsl:when test="$n = '1'">I</xsl:when>
            <xsl:when test="$n = '2'">II</xsl:when>
            <xsl:when test="$n = '3'">III</xsl:when>
            <xsl:when test="$n = '4'">IV</xsl:when>
            <xsl:when test="$n = '5'">V</xsl:when>
            <xsl:when test="$n = '6'">VI</xsl:when>
            <xsl:when test="$n = '7'">VII</xsl:when>
            <xsl:when test="$n = '8'">VIII</xsl:when>
            <xsl:when test="$n = '9'">IX</xsl:when>
            <xsl:when test="$n = '10'">X</xsl:when>
            <xsl:when test="$n = '11'">XI</xsl:when>
            <xsl:when test="$n = '12'">XII</xsl:when>
            <xsl:when test="$n = '13'">XIII</xsl:when>
            <xsl:when test="$n = '14'">XIV</xsl:when>
            <xsl:when test="$n = '15'">XV</xsl:when>
            <xsl:when test="$n = '16'">XVI</xsl:when>
            <xsl:when test="$n = '17'">XVII</xsl:when>
            <xsl:when test="$n = '18'">XVIII</xsl:when>
            <xsl:when test="$n = '19'">XIX</xsl:when>
            <xsl:when test="$n = '20'">XX</xsl:when>
            <xsl:when test="$n = '21'">XXI</xsl:when>
            <xsl:when test="$n = '22'">XXII</xsl:when>
            <xsl:when test="$n = '23'">XXIII</xsl:when>
            <xsl:when test="$n = '24'">XXIV</xsl:when>
            <xsl:when test="$n = '25'">XXV</xsl:when>
            <xsl:when test="$n = '26'">XXVI</xsl:when>
            <xsl:when test="$n = '27'">XXVII</xsl:when>
            <xsl:when test="$n = '28'">XXVIII</xsl:when>
            <xsl:when test="$n = '29'">XXIX</xsl:when>
            <xsl:when test="$n = '30'">XXX</xsl:when>
            <xsl:otherwise><xsl:value-of select="$n"/></xsl:otherwise>
        </xsl:choose>
    </xsl:function>
    
    <xsl:function name="local:matches-cat">
        <xsl:param name="seq"/>
        <xsl:param name="string"/>
        <xsl:variable name="seq-analyzed">
        <xsl:for-each select="$seq">
            <xsl:choose>
                <xsl:when test="matches(., $string) = true()">
                    <xsl:value-of select="'true'"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="'false'"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:for-each>
        </xsl:variable>
        <xsl:if test="functx:contains-any-of('true',($seq-analyzed))">
            <xsl:value-of select="true()"/>
        </xsl:if>
    </xsl:function>
    
    <xsl:template match="/">
        <div>
            <table class="workView">
                <tr>
                    <td valign="top">ID:</td>
                    <td>
                        <xsl:value-of select="mei:mei/@xml:id"/>
                    </td>
                </tr>
                <xsl:if test="//mei:workList/mei:work/mei:title[@type = 'alt' and @xml:lang = 'de']">
                <tr>
                    <td valign="top">Alternativer Titel:</td>
                    <td>
                        <xsl:value-of select="//mei:workList/mei:work/mei:title[@type = 'alt' and @xml:lang = 'de']/normalize-space(text())"/>
                    </td>
                </tr>
                </xsl:if>
                <xsl:if test="//mei:workList/mei:work/mei:title[@type = 'popular' and @xml:lang = 'de']">
                <tr>
                    <td valign="top">Populartitel:</td>
                    <td>
                        <xsl:value-of select="//mei:workList/mei:work/mei:title[@type = 'popular' and @xml:lang = 'de']/normalize-space(text())"/>
                    </td>
                </tr>
                </xsl:if>
                <xsl:if test="//mei:creation/mei:dedication/text()/normalize-space(.) !=''">
                <tr>
                    <td valign="top">Widmung:</td>
                    <td>
                        <xsl:value-of select="string-join(//mei:creation/mei:dedication//text(), ' ')"/>
                    </td>
                </tr>
                </xsl:if>
                <xsl:if test="//mei:creation/mei:dedication/mei:dedicatee//text() !=''">
                <tr>
                    <td valign="top">Widmungsträger:</td>
                    <td>
                        <xsl:for-each select="//mei:work//mei:dedication/mei:dedicatee">
                            <xsl:variable name="dedicateeIntended" select="./@type"/>
                            <xsl:choose>
                                <xsl:when test="mei:persName">
                                    <xsl:for-each select="mei:persName">
                                        <xsl:if test="$dedicateeIntended = 'intended'">
                                            [intendiert]
                                        </xsl:if>
                                        <xsl:value-of select="."/>
                                        <xsl:if test="@auth">
                                            (<a href="{concat($viewPerson, @auth)}">
                                                <xsl:value-of select="@auth"/>
                                            </a>)
                                        </xsl:if>
                                        <br/>
                                    </xsl:for-each>
                                    </xsl:when>
                                <xsl:when test="mei:corpName">
                                    <xsl:for-each select="mei:corpName">
                                    <xsl:value-of select="."/>
                                    <xsl:if test="@auth">
                                        (<a href="{concat($viewPerson, @auth)}">
                                            <xsl:value-of select="@auth"/>
                                        </a>)
                                    </xsl:if>
                                    <br/>
                                    </xsl:for-each>
                                    </xsl:when>
                                <xsl:otherwise>
                                    <xsl:value-of select="."/>
                                    <br/>
                                </xsl:otherwise>
                            </xsl:choose>
                        </xsl:for-each>
                    </td>
                </tr>
                </xsl:if>
                <xsl:if test="//mei:workList/mei:work/mei:composer[@type='theme'] != ''">
                    <tr>
                        <td valign="top">Themenlieferant:</td>
                        <td>
                            
                            <xsl:for-each select="//mei:workList/mei:work/mei:composer[@type='theme']">
                                <xsl:value-of select="mei:persName"/>
                                <xsl:if test="mei:persName/@auth">
                                    (<a href="{concat($viewPerson, mei:persName/@auth)}">
                                        <xsl:value-of select="mei:persName/@auth"/>
                                    </a>)
                                </xsl:if>
                            </xsl:for-each>
                        </td>
                    </tr>
                </xsl:if>
                <xsl:if test="//mei:workList/mei:work/mei:lyricist[not(@type='stoff')]//text() != ''">
                <tr>
                    <td valign="top">Textdichter(in):</td>
                    <td>
                        <xsl:for-each select="//mei:workList/mei:work/mei:lyricist">
                            <xsl:choose>
                                <xsl:when test="mei:persName/text()">
                                <xsl:value-of select="mei:persName"/>
                                <xsl:if test="mei:persName/@auth">
                                    (<a href="{concat($viewPerson, mei:persName/@auth)}">
                                        <xsl:value-of select="mei:persName/@auth"/>
                                    </a>)
                                </xsl:if>
                            </xsl:when>
                                <xsl:when test="text() !=''"><xsl:value-of select="text()"/></xsl:when>
                                <xsl:otherwise>[unbekannt]</xsl:otherwise>
                            </xsl:choose>
                            <br/>
                        </xsl:for-each>
                    </td>
                </tr>
                </xsl:if>
                <xsl:if test="//mei:workList/mei:work/mei:lyricist[@type='stoff']">
                    <tr>
                        <td valign="top">Lieferant(in) des Stoffes:</td>
                        <td>
                            <xsl:for-each select="//mei:workList/mei:work/mei:lyricist">
                                <xsl:choose>
                                    <xsl:when test="mei:persName/text()">
                                        <xsl:value-of select="mei:persName"/>
                                        <xsl:if test="mei:persName/@auth">
                                            (<a href="{concat($viewPerson, mei:persName/@auth)}">
                                                <xsl:value-of select="mei:persName/@auth"/>
                                            </a>)
                                        </xsl:if>
                                    </xsl:when>
                                    <xsl:when test="text() !=''"><xsl:value-of select="text()"/></xsl:when>
                                    <xsl:otherwise>[unbekannt]</xsl:otherwise>
                                </xsl:choose>
                                <br/>
                            </xsl:for-each>
                        </td>
                    </tr>
                </xsl:if>
                <xsl:if test="//mei:workList/mei:work/mei:componentList/mei:work != ''">
                    <tr>
                        <td valign="top">Enthaltene Werke:</td>
                        <td>
                            <xsl:for-each select="//mei:workList/mei:work/mei:componentList/mei:work">
                                
                                <xsl:choose>
                                    <xsl:when test="@type='issue'">
                                        <xsl:choose>
                                            <xsl:when test="@label"><xsl:value-of select="concat('Heft ', @n, ': ', @label)"/></xsl:when>
                                        <xsl:otherwise>
                                            <xsl:value-of select="concat('Heft ', @n)"/>
                                        </xsl:otherwise>
                                        </xsl:choose>
                                        <xsl:if test="exists(./mei:componentList)">
                                            <ul>
                                                <xsl:for-each select="./mei:componentList/mei:work">
                                                Nr.&#160;<xsl:value-of select="@n"/>&#160;<em><xsl:value-of select="mei:title"/></em>
                                                    <xsl:if test="mei:lyricist and local:matches-cat(ancestor::mei:meiHead//mei:classification//mei:term/text(),'cat-01')">
                                                    <xsl:choose>
                                                        <xsl:when test="mei:lyricist/mei:persName/@auth">
                                                            &#160;(<a href="{concat($viewPerson, mei:lyricist/mei:persName/@auth)}"><xsl:value-of select="mei:lyricist/mei:persName/text()"/></a>)
                                                        </xsl:when>
                                                        <xsl:when test="mei:lyricist/mei:persName">
                                                            &#160;(<xsl:value-of select="mei:lyricist/mei:persName/text()"/>)
                                                        </xsl:when>
                                                        <xsl:when test="mei:lyricist/normalize-space(text()) != ''">&#160;(<xsl:value-of select="mei:lyricist/text()"/>)</xsl:when>
                                                        <xsl:otherwise>
                                                            &#160;(unbekannt)
                                                        </xsl:otherwise>
                                                    </xsl:choose>
                                                </xsl:if>
                                                <br/>
                                                </xsl:for-each>
                                            </ul>
                                        </xsl:if>
                                    </xsl:when>
                                    <xsl:otherwise>
                                        Nr.&#160;<xsl:value-of select="@n"/>&#160;<em><xsl:value-of select="mei:title"/></em>
                                        <xsl:if test="mei:lyricist and local:matches-cat(ancestor::mei:meiHead//mei:classification//mei:term/text(), 'cat-01')">
                                        <xsl:choose>
                                            <xsl:when test="mei:lyricist/mei:persName/@auth">
                                                &#160;(<a href="{concat($viewPerson, mei:lyricist/mei:persName/@auth)}"><xsl:value-of select="mei:lyricist/mei:persName/text()"/></a>)
                                            </xsl:when>
                                            <xsl:when test="mei:lyricist/mei:persName">
                                                &#160;(<xsl:value-of select="mei:lyricist/mei:persName/text()"/>)
                                            </xsl:when>
                                            <xsl:when test="mei:lyricist/normalize-space(text()) != ''">&#160;(<xsl:value-of select="mei:lyricist/text()"/>)</xsl:when>
                                            <xsl:otherwise>
                                                &#160;(unbekannt)
                                            </xsl:otherwise>
                                        </xsl:choose>
                                        </xsl:if>
                                        <br/>
                                    </xsl:otherwise>
                                </xsl:choose>
                            </xsl:for-each>
                        </td>
                    </tr>
                </xsl:if>
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
                <xsl:choose>
                    <xsl:when test="//mei:work//mei:creation/mei:date[@type='composition']/@isodate">
                <tr>
                    <td valign="top">Kompositionsdatum:</td>
                    <td>
                        <xsl:value-of select="local:formatDate(//mei:work//mei:creation/mei:date[@type = 'composition']/@isodate)"/>
                    </td>
                </tr>
                </xsl:when>
                    <xsl:when test="//mei:work//mei:creation/mei:date[@type='composition']/@notbefore and //mei:work//mei:creation/mei:date[@type='composition']/@notafter">
                <tr>
                    <td valign="top">Kompositionszeitraum:</td>
                    <td>
                        <xsl:choose>
                            <xsl:when test="local:formatDate(//mei:work//mei:creation/mei:date[@type = 'composition']/@notafter) = local:formatDate(//mei:work//mei:creation/mei:date[@type = 'composition']/@notbefore)">
                                <xsl:value-of select="local:formatDate(//mei:work//mei:creation/mei:date[@type = 'composition']/@notbefore)"/>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:value-of select="local:formatDate(//mei:work//mei:creation/mei:date[@type = 'composition']/@notbefore)"/> bis
                                <xsl:value-of select="local:formatDate(//mei:work//mei:creation/mei:date[@type = 'composition']/@notafter)"/>
                            </xsl:otherwise>
                        </xsl:choose>
                    </td>
                </tr>
                </xsl:when>
                    <xsl:when test="//mei:work//mei:creation/mei:date[@type='composition']/@notbefore and not(//mei:work//mei:creation/mei:date[@type='composition']/@notafter)">
                <tr>
                    <td>Kompositionszeitraum:</td>
                    <td>Nach <xsl:if test="string-length(//mei:work//mei:creation/mei:date[@type = 'composition']/@notbefore)=10">dem </xsl:if><xsl:value-of select="local:formatDate(//mei:work//mei:creation/mei:date[@type = 'composition']/@notbefore)"/>
                    </td>
                </tr>
                </xsl:when>
                    <xsl:when test="not(//mei:work//mei:creation/mei:date[@type='composition']/@notbefore) and //mei:work//mei:creation/mei:date[@type='composition']/@notafter">
                <tr>
                    <td>Kompositionszeitraum:</td>
                    <td>Vor <xsl:if test="string-length(//mei:work//mei:work//mei:creation/mei:date[@type = 'composition']/@notafter)=10">dem </xsl:if><xsl:value-of select="local:formatDate(//mei:work//mei:creation/mei:date[@type = 'composition']/@notafter)"/>
                    </td>
                </tr>
                </xsl:when>
                <xsl:otherwise>
                    <tr>
                        <td valign="top">Kompositionsdatum:</td>
                        <td>
                            [unbekannt]
                        </td>
                    </tr>
                </xsl:otherwise>
                </xsl:choose>
                        <!--</xsl:if>-->
            
            <xsl:if test="//mei:eventList/mei:event[@type='UA']/normalize-space() !=''">
                <tr>
                    <td valign="top">Uraufführung:</td>
                    <td>
                        <xsl:variable name="UAdate" select="local:formatDate(//mei:eventList/mei:event[@type = 'UA']/mei:date/text())"/>
                        <xsl:variable name="UAort" select="normalize-space(string-join(//mei:eventList/mei:event[@type = 'UA']/mei:geogName//text(), ' '))"/>
                        <xsl:variable name="UAconductor" select="//mei:eventList/mei:event[@type = 'UA']/mei:persName[@role = 'conductor'][./text() != '']"/>
                        <xsl:choose>
                            <xsl:when test="not(empty($UAdate)) and not(empty($UAort))">
                                <xsl:value-of select="concat($UAdate, ' in ', $UAort)"/>
                            </xsl:when>
                            <xsl:when test="not(empty($UAdate)) and empty($UAort)">
                                <xsl:value-of select="$UAdate"/>
                            </xsl:when>
                            <xsl:when test="empty($UAdate) and not(empty($UAort))">
                                <xsl:value-of select="$UAort"/>
                            </xsl:when>
                        </xsl:choose>
                        <xsl:if test="not(empty($UAconductor/text()))">
                            <br/>
                            Dirigent*in: <xsl:apply-templates select="$UAconductor"/>
                        </xsl:if>
                        <xsl:if test="//mei:eventList/mei:event[@type = 'UA']/mei:persName[contains(@role,'interpret')]/text()/normalize-space() !=''">
                            <xsl:for-each select="//mei:eventList/mei:event[@type = 'UA']/mei:persName[contains(@role,'interpret')]">
                                <br/>
                                Interpret*in: <xsl:apply-templates select="."/>
                                <xsl:if test="contains(./@role,' ')">
                                    <xsl:value-of select="concat(' (',string-join(subsequence(tokenize(./@role,' '),2),'|'),')')"/>
                                </xsl:if>
                            </xsl:for-each>
                        </xsl:if>
                    </td>
                </tr>
            </xsl:if>
            </table>
            </xsl:if>
            <xsl:if test="//mei:music/mei:body/mei:mdiv/@label">
            <table class="workView">
                <tr>
                    <td>
                        <xsl:choose>
                            <xsl:when test="//mei:music/mei:body/mei:mdiv[@type]">Musikalische Abschnitte:</xsl:when>
                            <xsl:otherwise>Sätze:</xsl:otherwise>
                        </xsl:choose>
                    </td>
                    <td>
                        <xsl:for-each select="//mei:music/mei:body/mei:mdiv">
                            <xsl:choose>
                                <xsl:when test="@type= 'section'">
                                    <xsl:value-of select="concat('Abteilung ', @n, ': ', @label)"/>
                                </xsl:when>
                                <xsl:when test="@type= 'component'">
                                    <xsl:value-of select="concat('Teil ', @n, ': ', @label)"/>
                                </xsl:when>
                                <xsl:when test="@type= 'issue'">
                                    <xsl:value-of select="concat('Heft ', @n, ': ', @label)"/>
                                </xsl:when>
                                <!--<xsl:when test="number(@n) &lt; 1000">
                                    <xsl:value-of select="concat('Nr. ', ./@label)"/>
                                </xsl:when>-->
                                <xsl:when test="@n">
                                    <xsl:value-of select="concat(local:switch2Roman(@n), '. ', @label)"/>
                                </xsl:when>
                                <xsl:otherwise>
                                    <xsl:value-of select="@label"/>
                                </xsl:otherwise>
                            </xsl:choose>
                            <xsl:if test="exists(./mei:mdiv)">
                                <ul>
                                    <xsl:for-each select="./mei:mdiv">
                                        <xsl:choose>
                                            <xsl:when test="@n">
                                                <xsl:value-of select="concat(local:switch2Roman(@n), '. ', @label)"/>
                                            </xsl:when>
                                            <xsl:otherwise>
                                                <xsl:value-of select="@label"/>
                                            </xsl:otherwise>
                                        </xsl:choose>
                                        <br/>
                                        <xsl:if test="exists(./mei:mdiv)">
                                            <ul>
                                                <xsl:for-each select="./mei:mdiv">
                                                    <xsl:choose>
                                                        <xsl:when test="@n">
                                                            <xsl:value-of select="concat(local:switch2Roman(@n), '. ', @label)"/>
                                                        </xsl:when>
                                                        <xsl:otherwise>
                                                            <xsl:value-of select="@label"/>
                                                        </xsl:otherwise>
                                                    </xsl:choose>
                                                    <br/>
                                                </xsl:for-each>
                                            </ul>
                                        </xsl:if>
                                    </xsl:for-each>
                                </ul>
                            </xsl:if>
                            <xsl:if test="not(./mei:mdiv)"><br/></xsl:if>
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
                                <li> [<xsl:value-of select="document('../../../../apps/jraDefinitions/data/sourceClassification.xml')//mei:classDecls/mei:taxonomy/mei:category/id($sourceClass)/mei:desc[@xml:lang = 'de']"/>] <xsl:value-of select=".//mei:locus"/>
                                </li>
                            </xsl:for-each>
                        </ul>
                    </td>
                </tr>
            </table>
            </xsl:if>
            <xsl:if test="//mei:componentList/mei:manifestation/mei:biblList/mei:bibl">
                <table class="workView">
                    <tr>
                        <td>Erfasste Ausgaben:</td>
                        <td>
                            <xsl:variable name="biblList" select="//mei:componentList/mei:manifestation/mei:biblList"/>
                            <xsl:choose>
                                <xsl:when test="$biblList/count(mei:bibl) = 1">
                                    <xsl:apply-templates select="$biblList/mei:bibl/mei:publisher"/>
                                    <xsl:value-of select="concat('(', $biblList/mei:bibl//mei:date, ')')"/>
                                </xsl:when>
                                <xsl:otherwise>
                                    <ul>
                                        <xsl:for-each select="$biblList/mei:bibl">
                                            <li>
                                                <xsl:apply-templates select="$biblList/mei:bibl/mei:publisher"/>
                                                <xsl:value-of select="concat('(', $biblList/mei:bibl//mei:date, ')')"/>
                                            </li>
                                        </xsl:for-each>
                                    </ul>
                                </xsl:otherwise>
                            </xsl:choose>
                        </td>
                    </tr>
                </table>
            </xsl:if>
        </div>
    </xsl:template>
</xsl:stylesheet>