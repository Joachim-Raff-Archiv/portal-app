<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:local="https://portal.raff-archive.ch/ns/local" exclude-result-prefixes="xs" xpath-default-namespace="http://www.tei-c.org/ns/1.0" version="2.0">
    <xsl:output method="xhtml" encoding="UTF-8"/>
    <xsl:include href="linking.xsl"/>
    <xsl:include href="formattingDate.xsl"/>

    <xsl:variable name="sourceDesc" select="//sourceDesc"/>
<!--    <xsl:variable name="graphic" select="./ancestor::TEI/facsimile/graphic[1]"/>-->

    <xsl:template match="/">
                <xsl:call-template name="writingMetadataView"/>
    </xsl:template>

    <xsl:template name="writingMetadataView">
        <table class="letterView">
            <tr>
                <td valign="top">Titel:</td>
                <td><xsl:value-of select="$sourceDesc//title[1]"/></td>
            </tr>
            <tr>
                <td valign="top">Autor:</td>
                <td><xsl:value-of select="$sourceDesc//author[1]"/></td>
            </tr>
            <tr>
                <td valign="top">Verlag:</td>
                <td><xsl:value-of select="$sourceDesc//imprint/publisher[1]"/></td>
            </tr>
            <tr>
                <td valign="top">Ort:</td>
                <td><xsl:value-of select="$sourceDesc//imprint/pubPlace[1]"/></td>
            </tr>
            <tr>
                <td valign="top">Jahr:</td>
                <td><xsl:value-of select="$sourceDesc//imprint/date[1]"/></td>
            </tr>
        </table>
        <xsl:if test="//@cert"><br/>
            <hr/>
            * Daten nicht verifiziert
            <br/></xsl:if>
    </xsl:template>

</xsl:stylesheet>