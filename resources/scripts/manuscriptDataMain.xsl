<xsl:stylesheet xmlns="http://www.w3.org/1999/xhtml" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:mei="http://www.music-encoding.org/ns/mei" xmlns:xlink="http://www.w3.org/1999/xlink" version="2.0">
    <xsl:output method="xhtml" encoding="UTF-8" indent="yes"/>
    <xsl:template match="/">
        <div>
            <table border="0" width="100%">
                <tr>
                    <th/>
                    <th/>
                </tr>
                <xsl:if test="not(//mei:titleStmt/mei:title[@type = 'uniform' and @xml:lang = 'de']/data(.) = '')">
                    <tr>
                        <td>Einheitstitel der Quelle:</td>
                        <td>
                            <xsl:value-of select="//mei:titleStmt/mei:title[@type = 'uniform' and @xml:lang = 'de']/mei:titlePart[@type='main']"/> <xsl:value-of select="//mei:titleStmt/mei:title[@type = 'uniform' and @xml:lang = 'de']/mei:titlePart[@type='sub']"/>  <xsl:value-of select="//mei:titleStmt/mei:title[@type = 'uniform' and @xml:lang = 'de']/mei:titlePart[@type='desc']"/> 
                        </td>
                    </tr>
                </xsl:if>
                <xsl:if test="not(//mei:titleStmt/mei:title[@type = 'main']/data(.) = '')">
                    <tr>
                        <td>Titel (diplomatisch):</td>
                        <td>
                            <xsl:value-of select="//mei:titleStmt/mei:title[@type = 'main']"/>
                        </td>
                    </tr>
                </xsl:if>
                <xsl:if test="not(//mei:titleStmt/mei:title[@type = 'sub']/data(.) = '')">
                    <tr>
                        <td>Untertitel (dipl.):</td>
                        <td>
                            <xsl:value-of select="//mei:titleStmt/mei:title[@type = 'sub']"/>
                        </td>
                    </tr>
                </xsl:if>
                <xsl:if test="not(//mei:titleStmt/mei:title[@type = 'desc']/data(.) = '')">
                    <tr>
                        <td>Werkbeschreibung:</td>
                        <td>
                            <xsl:value-of select="//mei:titleStmt/mei:title[@type = 'uniform' and @xml:lang = 'de']/mei:titlePart[@type='desc']"/>
                        </td>
                    </tr>
                </xsl:if>
                <xsl:if test="not(exists(//mei:term[@type = 'source' and @subtype = 'special' and contains(., 'Sammelquelle')]))">
                    <xsl:if test="not(//mei:titleStmt/mei:composer = '')">
                        <tr>
                            <td>Komponist:</td>
                            <td>
                                <xsl:value-of select="//mei:titleStmt/mei:composer"/>
                            </td>
                        </tr>
                    </xsl:if>
                    <xsl:if test="not(//mei:titleStmt/mei:lyricist = '')">
                        <tr>
                            <td>Textdichter:</td>
                            <td>
                                <xsl:value-of select="//mei:titleStmt/mei:lyricist"/>
                            </td>
                        </tr>
                    </xsl:if>
                </xsl:if>
                <xsl:if test="exists(//mei:term[@type = 'source' and @subtype = 'special' and contains(., 'Sammelquelle')])">
                    <xsl:if test="not(//mei:titleStmt/mei:composer = '')">
                        <tr>
                            <xsl:choose>
                                <xsl:when test="count(//mei:sourceDesc//mei:titleStmt/mei:composer) &gt; 1">
                                    <td>Komponist(en):</td>
                                    <td>
                                        <xsl:for-each select="//mei:sourceDesc//mei:titleStmt/mei:composer">
                                            <li>
                                                <xsl:value-of select="."/>
                                            </li>
                                        </xsl:for-each>
                                    </td>
                                </xsl:when>
                                <xsl:otherwise>
                                    <td>Komponist:</td>
                                    <td>
                                        <xsl:value-of select="//mei:sourceDesc//mei:titleStmt/mei:composer"/>
                                    </td>
                                </xsl:otherwise>
                            </xsl:choose>
                        </tr>
                    </xsl:if>
                    <xsl:if test="not(//mei:titleStmt/mei:lyricist = '')">
                        <tr>
                            <td>Textdichter:</td>
                            <xsl:choose>
                                <xsl:when test="count(//mei:sourceDesc//mei:titleStmt/mei:lyricist) &gt; 1">
                                    <td>
                                        <xsl:for-each select="//mei:sourceDesc//mei:titleStmt/mei:lyricist">
                                            <li>
                                                <xsl:value-of select="."/>
                                            </li>
                                        </xsl:for-each>
                                    </td>
                                </xsl:when>
                                <xsl:otherwise>
                                    <td>
                                        <xsl:value-of select="//mei:sourceDesc//mei:titleStmt/mei:lyricist"/>
                                    </td>
                                </xsl:otherwise>
                            </xsl:choose>
                        </tr>
                    </xsl:if>
                </xsl:if>
            </table>
        </div>
    </xsl:template>
</xsl:stylesheet>