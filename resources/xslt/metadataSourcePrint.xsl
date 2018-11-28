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
                            <xsl:value-of select="//mei:titleStmt/mei:title[@type = 'uniform' and @xml:lang = 'de']"/>
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
                <xsl:if test="not(//mei:titleStmt/mei:title[@type = 'subordinate']/data(.) = '')">
                    <tr>
                        <td>Untertitel (dipl.):</td>
                        <td>
                            <xsl:value-of select="//mei:titleStmt/mei:title[@type = 'subordinate']"/>
                        </td>
                    </tr>
                </xsl:if>
                <xsl:if test="not(//mei:titleStmt/mei:title[@type = 'desc']/data(.) = '')">
                    <tr>
                        <td>Werkbeschreibung:</td>
                        <td>
                            <xsl:value-of select="//mei:titleStmt/mei:title[@type = 'desc' and  @xml:lang = 'de']"/>
                        </td>
                    </tr>
                </xsl:if>
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
            </table>
        </div>
    </xsl:template>
</xsl:stylesheet>