<xsl:stylesheet xmlns="http://www.w3.org/1999/xhtml" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:mei="http://www.music-encoding.org/ns/mei" xmlns:xlink="http://www.w3.org/1999/xlink" version="2.0">
    <xsl:output method="xhtml" encoding="UTF-8" indent="yes"/>
    <xsl:template match="/">
        <div class="row">
            <xsl:for-each select="//mei:div[@type = 'songtext']">
                <div class="col">
                    <p>
                        <strong>
                            <xsl:value-of select="mei:lg[@label = 'title']"/>
                        </strong>
                        <br/>
                        (<i>
                            <xsl:choose>
                                <xsl:when test="./@xml:lang = 'de'">deutsch</xsl:when>
                                <xsl:when test="./@xml:lang = 'en'">englisch</xsl:when>
                                <xsl:when test="./@xml:lang = 'fr'">französisch</xsl:when>
                                <xsl:when test="./@xml:lang = 'it'">italienisch</xsl:when>
                            </xsl:choose>
                        </i>)
                    </p>
                    <p>
                        <xsl:for-each select="mei:lg[not(@label = 'title')]">
                            <p>
                                <xsl:if test="not(exists(./@label))">
                                    <xsl:choose>
                                        <xsl:when test="./@type/data(.) = 'stanza'">[Strophe </xsl:when>
                                        <xsl:when test="./@type/data(.) = 'chorous'">[Refrain </xsl:when>
                                    </xsl:choose>
                                    <xsl:value-of select="./@n"/>]</xsl:if>
                                <xsl:if test="exists(./@label)">[<xsl:value-of select="./@label"/>]</xsl:if>
                                <br/>
                            </p>
                            <p>
                                <xsl:for-each select="./mei:l"> (V. <xsl:choose>
                                        <xsl:when test="contains(@xml:id, '-de')">
                                            <xsl:value-of select="@xml:id/substring-after(substring-before(., '-de'), 'verse-')"/>
                                        </xsl:when>
                                        <xsl:otherwise>
                                            <xsl:value-of select="@xml:id/substring-after(., 'verse-')"/>
                                        </xsl:otherwise>
                                    </xsl:choose>
                                    <xsl:choose>
                                        <xsl:when test="contains(@xml:id, '-de')">
                                            <xsl:value-of select="@xml:id/substring-after(substring-before(., '-de'), 'Verse-')"/>
                                        </xsl:when>
                                        <xsl:otherwise>
                                            <xsl:value-of select="@xml:id/substring-after(., 'Verse-')"/>
                                        </xsl:otherwise>
                                    </xsl:choose>) <xsl:value-of select="."/>
                                    <br/>
                                </xsl:for-each>
                            </p>
                        </xsl:for-each>
                    </p>
                </div>
            </xsl:for-each>
        </div>
    </xsl:template>
</xsl:stylesheet>