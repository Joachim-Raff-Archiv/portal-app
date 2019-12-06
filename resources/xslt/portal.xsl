<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema" exclude-result-prefixes="xs" xpath-default-namespace="http://www.tei-c.org/ns/1.0" version="2.0">
    <xsl:output method="xhtml" encoding="UTF-8"/>
    <xsl:include href="formattingText.xsl"/>
    <xsl:template match="/">
        <xsl:apply-templates select="//body"/>
    </xsl:template>
    <xsl:template match="figure[@type='icon']">
        <xsl:variable name="picture" select="@source"/>
        <img src="{$picture}" width="20"/>
    </xsl:template>
    <xsl:template match="figure[@type='logo']">
        <xsl:variable name="picture" select="@source"/>
        <img src="{$picture}" width="115"/>
    </xsl:template>
</xsl:stylesheet>