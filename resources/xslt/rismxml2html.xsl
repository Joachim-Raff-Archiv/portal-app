<xsl:stylesheet xmlns="http://www.w3.org/1999/xhtml" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema" exclude-result-prefixes="xs" version="2.0">
    <xsl:output method="xhtml" encoding="UTF-8"/>
    <xsl:template match="/">
        <table border="1">
            <tr>
                <th width="15%">Signatur</th>
                <th width="7%">BauDi-ID</th>
                <th width="20%">Titel</th>
                <th width="11%">Gattung</th>
                <th width="30%">Besetzung</th>
                <th>RISM-ID</th>
                <th>best.</th>
                <th>erf.</th>
                <th>ber.</th>
                <th>digi</th>
                <th>incip</th>
            </tr>
            <xsl:apply-templates/>
        </table>
    </xsl:template>
    <xsl:template match="corpus">
        <xsl:for-each select="dataNode">
            <xsl:sort select="subject" order="ascending"/>
            <xsl:sort select="shelfmark" order="ascending"/>
            <tr>
                <td>
                    <xsl:value-of select="shelfmark"/>
                </td>
                <td align="center">
                    <xsl:value-of select="baudiID"/>
                </td>
                <td>
                    <xsl:value-of select="title"/>
                </td>
                <td>
                    <xsl:value-of select="subject"/>
                </td>
                <td>
                    <xsl:value-of select="perfMedium"/>
                </td>
                <td>
                    <xsl:value-of select="rismID"/>
                </td>
                <td align="center">
                    <xsl:value-of select="bestellt"/>
                </td>
                <td align="center">
                    <xsl:value-of select="erfasst"/>
                </td>
                <td align="center">
                    <xsl:value-of select="bereinigt"/>
                </td>
                <td align="center">
                    <xsl:value-of select="digital"/>
                </td>
                <td align="center">
                    <xsl:value-of select="incipit"/>
                </td>
            </tr>
        </xsl:for-each>
    </xsl:template>
</xsl:stylesheet>