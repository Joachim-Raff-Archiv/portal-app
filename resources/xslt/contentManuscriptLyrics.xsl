<xsl:stylesheet xmlns="http://www.w3.org/1999/xhtml" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:mei="http://www.music-encoding.org/ns/mei" xmlns:xlink="http://www.w3.org/1999/xlink" version="2.0">
    <xsl:output method="xhtml" encoding="UTF-8" indent="yes"/>
    <xsl:template match="/">
        <div>
            <p>
                <strong>
                    <xsl:value-of select="//mei:lg[@label='title']"/>
                </strong>
            </p>
            <p>
                <xsl:for-each select="//mei:div[@decls = 'songtext']/mei:lg[not(@label='title')]">
                    <p> 
                Strophe <xsl:value-of select="./@n"/>:<br/>
                    </p>
                    <p>
                        <xsl:for-each select="./mei:l"> (V. <xsl:value-of select="@xml:id/substring-after(substring-before(.,'-de'), 'verse-')"/>) <xsl:value-of select="."/>
                            <br/>
                        </xsl:for-each>
                    </p>
                </xsl:for-each>
            </p>
        </div>
    </xsl:template>
</xsl:stylesheet>