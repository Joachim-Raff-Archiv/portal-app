<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema" exclude-result-prefixes="xs" xpath-default-namespace="http://www.tei-c.org/ns/1.0" version="2.0">
    <xsl:output method="xhtml" encoding="UTF-8"/>
    <xsl:variable name="LinkZurPerson" select="concat('http://baumann-digital.de:8080/exist/apps/raffArchive/html/person/', ./@key, '.xml')"/>
    <xsl:template name="genannteDaten" match="/">
        <p>Erwähnte Zeiträume</p>
        <xsl:for-each select="//div[@type = 'page']//date/@from-iso">
            <xsl:sort select="data(.)" data-type="text" order="ascending"/>
            <xsl:value-of select="parent::node()"/> ab <xsl:if test="string-length(.) = 10">
                <xsl:value-of select="./substring(., 9, 10)"/>.</xsl:if>
            <xsl:if test="string-length(.) = 7 or string-length(.) = 10">
                <xsl:value-of select="./substring(., 6, 2)"/>.</xsl:if>
            <xsl:value-of select="./substring(., 1, 4)"/>
            <br/>
        </xsl:for-each>
        <br/>
        <xsl:for-each select="//div[@type = 'page']//date[not(@from-iso)]/@to-iso">
            <xsl:sort select="data(.)" data-type="text" order="ascending"/> bis <xsl:if test="string-length(.) = 10">
                <xsl:value-of select="./substring(., 9, 10)"/>.</xsl:if>
            <xsl:if test="string-length(.) = 7 or string-length(.) = 10">
                <xsl:value-of select="./substring(., 6, 2)"/>.</xsl:if>
            <xsl:value-of select="./substring(., 1, 4)"/> (<xsl:value-of select="parent::node()"/>)<br/>
        </xsl:for-each>
        <br/>
        <table>
            <tr>
                <td>Nennung</td>
                <td>Entsprechung</td>
            </tr>
            <xsl:for-each select="//div[@type = 'page']//date/@when-iso">
                <xsl:sort select="data(.)" data-type="text" order="ascending"/>
                <tr>
                    <td>
                        <xsl:value-of select="parent::node()"/>
                    </td>
                    <td>
                        <xsl:if test="string-length(.) = 10">
                            <xsl:value-of select="./substring(., 9, 10)"/>.</xsl:if>
                        <xsl:if test="string-length(.) = 7 or string-length(.) = 10">
                            <xsl:value-of select="./substring(., 6, 2)"/>.</xsl:if>
                        <xsl:value-of select="./substring(., 1, 4)"/>
                    </td>
                </tr>
            </xsl:for-each>
        </table>
    </xsl:template>
</xsl:stylesheet>
