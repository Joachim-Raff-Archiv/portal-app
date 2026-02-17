<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema" exclude-result-prefixes="xs" xpath-default-namespace="http://www.tei-c.org/ns/1.0" version="2.0">
    <xsl:output method="xhtml" encoding="UTF-8"/>
    
    <xsl:template match="/">
        <ul>
            <xsl:apply-templates select=".//place"/>
        </ul>
    </xsl:template>
    
    <xsl:template match="placeName[@type='reg']">
        <li>
            <xsl:text>Name: </xsl:text><xsl:value-of select="."/>
        </li>
    </xsl:template>

    <xsl:template match="idno[@type='geonames']">
        <li>
            <xsl:text>Geonames: </xsl:text><xsl:value-of select="."/>
        </li>
    </xsl:template>
    
    <xsl:template match="note[@type = 'editor']">
        <i>[<xsl:apply-templates/>]</i>
    </xsl:template>
</xsl:stylesheet>