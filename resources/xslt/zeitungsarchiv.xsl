<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema" exclude-result-prefixes="xs" xpath-default-namespace="http://www.tei-c.org/ns/1.0" version="2.0">
    <xsl:output method="xhtml" encoding="UTF-8"/>
    <xsl:template match="/">
        <xsl:apply-templates select=".//text"/>
    </xsl:template>
    <xsl:template match="div">
        <xsl:for-each select=".">
            <h3>
                <xsl:value-of select="./@decls"/>
            </h3>
            <table>
                <xsl:for-each select="//bibl">
                    <xsl:sort select="date/@when-iso" order="ascending"/>
                    <tr>
                        <td width="175">
                            <a href="{ref/@target}" target="_blank">
                                <xsl:value-of select="date"/> (Nr. <xsl:value-of select="num"/>)</a>
                        </td>
                        <td>Betrifft: <xsl:value-of select="note"/>
                        </td>
                    </tr>
                </xsl:for-each>
            </table>
        </xsl:for-each>
    </xsl:template>
</xsl:stylesheet>